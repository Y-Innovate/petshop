# CLAUDE.md

## Project
Backend of the Y-Innovate petshop demo app: CICS + COBOL + DB2 on z/OS,
exposed as a REST API (`/petshop/API/v1`) through the LWW API gateway,
which maps JSON to COBOL copybooks. The React frontend lives in a separate
repo (`petshop-frontend`); its built output is copied into `ui/`.

Source is edited on Linux/VS Code, but builds, deploys and the Python
scripts in `ZMAKE/`, `profile*.sh` run on z/OS USS from the repo root
(they call `submit`, `zoautil_py`, `/u/ybtks/venv`). You can't build or run
the COBOL here, so check changes by reading them carefully. Python syntax
can be checked with `python3 -m py_compile`.

## Layout
| Dir | Content |
|---|---|
| `COBOL/` | COBOL programs (see naming below) |
| `COPY/` | Copybooks: `LPETxnnn` = linkage/IO areas, `TBPETnnn` = DCLGEN, `LINKPAR` = LWW link parms |
| `ASM/` | `PETA990` – HLASM, finds the userid (CICS or batch) for CREATEDBY/UPDATEDBY |
| `BMSMAP/` | `PETB00`–`PETB07` BMS maps for the emergency 3270 transaction |
| `DDL/` | `AA0000nn.sql` DB2 DDL, Jinja `{{VAR}}` placeholders; `$INFO.txt` is the change log for these members |
| `envs/` | `dev1.yaml`, `dev2.yaml`, `t01.yaml` – values for the `{{...}}` placeholders in DDL and JCL |
| `JCL/` | Jinja-templated JCL: BINDPLAN, CICSCSD, RACF, RUNDDL |
| `LKED/` | One link-edit control per load module |
| `OPTFILE/` | Compiler options: `CICS.opt`, `DB2.opt` |
| `ZMAKE/` | `BUILD.zmake`, `DEPLOY.zmake` (z/OS make, run via ISPFMAKE) |
| `openapi/` | API specs (see below) |
| `python/` | Build/deploy wrappers, test-data generators, API test and upload scripts |
| `ui/` | Built frontend + `API/v1` placeholders; the `.name` dot-files are LWW file metadata for the upload |

## Program naming and structure
Table numbers `nnn` are the same everywhere (`TBPETnnn`, `LPETMnnn`, `PETMnnn`, `PETCnnn`, `*_TBNR` in `envs/*.yaml`):

| nnn | Table | nnn | Table |
|---|---|---|---|
| 001 | REFTABLES | 008 | CUSTOMERS |
| 002 | STORES | 009 | PURCHASES |
| 003 | SUPPLIERS | 010 | ORDERS |
| 004 | PRODUCTS | 011 | ADDRESSES |
| 005 | INVENTORY | 012 | CONTACTINFOS |
| 006 | ANIMALS | 013 | STORESUPPL |
| 007 | PRICESANDDISCOUNTS | | |

- `PETM0nn` – DB2 CRUD module for table nnn. `OPCODE` C/R/U/D; returns
  `RETURNCODE`/`REASONCODE`/`INFOMESSAGE`. The header comment lists all
  codes; keep it up to date. Convention: `04 01` not found, `08 0x` invalid
  input, `08 11` duplicate, `08 12/21/32/42` SQL errors, `08 13/33` missing
  FK parent, `08 31/41` update/delete of missing key, `08 90` PETA990 failed.
- `PETM2nn` – DB2 list module (paging with `*-SINCE` keys, filters,
  `OCCURS ... DEPENDING ON` up to 20 rows) with copybook `LPETM2nn`.
- `PETC0nn` / `PETC2nn` – thin CICS wrappers called by LWW: GET CONTAINER
  `LWW-LINK-PAR-03` (IO area) and `LWW-LINK-PAR-00` (`LINKPAR`) on channel
  `LWW-LINK-CHL-00`, CALL the `PETMnnn` module, map return/reason code to
  an HTTP status in `STSCODE`/`STSTXT`, PUT both containers back.
  All `PETC0nn` (and all `PETC2nn`) are nearly identical; when changing
  one, check whether the others need the same change (`diff` them).
- `PETC900` – router for emergency transaction PE90 (channel
  `PT90-CHANNEL`, container `LPETC900` with CURRENT/NEXT-SCREEN).
  `PETC901` = menu (map PETB00), `PETC902`–`PETC908` = screens for tables
  001–007 (maps PETB01–PETB07).
- `PETC290` – GET `/me`: RACF userid and RACF profile name of the signed-in
  user (`EXEC CICS ASSIGN USERID USERNAME`), IO area `LPETC290`; no DB2,
  no `PETMnnn` module. Used by the frontend for the user in the sidebar.
- 008–012 only have a CRUD module (`PETM008`–`PETM012`): no list module,
  CICS wrapper or API path yet.

The build tells module types apart by name: `PETM*.cbl` compile with the
DB2 coprocessor (`OPTFILE/DB2.opt`, DBRM, bound to package at deploy),
`PETC*.cbl` with the CICS translator (`OPTFILE/CICS.opt`).

### Adding a new program or table
A new table usually needs: `DDL/AA0000nn.sql` + line in `DDL/$INFO.txt`,
`*_TBNR/TBSNAME/TBNAME/IXNAME*` keys in **all three** `envs/*.yaml`,
`COPY/TBPETnnn.cpy` (DCLGEN layout), `COPY/LPETMnnn.cpy`, `COBOL/PETMnnn.cbl`,
`COBOL/PETCnnn.cbl`, an `LKED/<member>.lked` per load module (PETM includes
`DSNCLI`), x-ioareas + processing steps + paths in `openapi/`, and
possibly CSV/generator in `python/`. STORESUPPL (013) is the most recent
complete example to copy from.

## Coding conventions
- **Encoding**: everything except `ui/` and `python/` is ISO8859-1 (see
  `.gitattributes`). Don't introduce non-ASCII characters in mainframe sources.
- **Fixed format**: COBOL cols 1–6 sequence (blank), 7 indicator, 8–72
  code; nothing past col 72. Same for HLASM/BMS (continuation `*` in col 72)
  and SQL/JCL (cols 1–72; JCL ≤ 80, `profilePDS.py` truncates at 80).
- Member names ≤ 8 characters, upper case.
- DB2 tables are `CCSID UNICODE` with `GRAPHIC`/`VARGRAPHIC` columns, so
  COBOL uses national data: `PIC N`, `N'..'` literals, `FUNCTION NATIONAL-OF`
  / `DISPLAY-OF`. Timestamps are `PIC N(26)` in IO areas, `PIC X(26)` in DCLGEN.
- Nullable columns: `-IND` indicator in DCLGEN; LOW-VALUES (or spaces, as
  documented per module) in the IO area means NULL.
- Program style: `MAIN SECTION` performing `R001-INIT`, `R002-CHECKPARM`,
  `R1x0-<op>`, `R009-FINISH`; every section has a `*====*` banner comment
  and an `-END. EXIT.` paragraph. Use `OF` qualification for copybook fields
  (same names in `W-` and `P-` copies). Errors via `DSNTIAR` (DB2) or
  `CEEMOUT` (CICS).
- Containers: always clamp the received length to the target field length
  before `MOVE P-CHAR(1:len)` (commit f176fff fixed this bug).
- CREATEDDATE/UPDATEDDATE are set by DB2 (`CURRENT TIMESTAMP`) and read
  back via `SELECT ... FROM FINAL TABLE (INSERT/UPDATE ...)`.
- Python: plain scripts, camelCase names, shared state in `Globals`, HTTP
  via `MyRequests`. `ruamel.yaml` is vendored in `python/vendor/`.

## OpenAPI / LWW
- `openapi/petshop_1.1.0.yaml` – public API (paths, schemas). Each operation
  has `x-LWWProcessingSteps: $ref` into `petshop_2_1.1.0.yaml`.
- `openapi/petshop_2_1.1.0.yaml` – LWW processing steps per operation
  (`AllocateIOArea`, `ParseRequestJSON`, `Mapping`, `Link program: PETCnnn`,
  `Condition`, `CreateObject`, ...) and `components/x-ioareas/LPETMnnn` field
  lists. **Keep x-ioareas in sync with the copybooks**: field order, length
  (`PIC N(n)` → `CHARARRAY1200` length n, VARGRAPHIC → `VARCHAR1200`) and
  the `AllocateIOArea size` (bytes; national chars are 2 bytes).
  The two files refer to each other by filename, so renaming a version means
  updating every cross-file `$ref`.
- `openapi/LWWAPI_v3.0.1.yml` – the LWW gateway's own management API (reference).
- `openapi/xlate_*.yaml` – small copybook↔JSON translation examples.
- `python/merge.py` flattens the two specs into one, but still points at
  the old names `petshop.yaml` / `petshop_2.yaml`; update before using.

## Build & deploy (on z/OS USS, from repo root)
- `. ./setenv` then `build` – submits `python/build.py` → `ZMAKE/BUILD.zmake`
  target `BUILD_ALL` into `<userid>.PETSHOP.V1.*`. `python python/build.py
  [hlq] <target>` for a specific target. BMS DSECT copybooks are also written
  to `COPY.NOCOMMIT/` (not committed).
- `python python/deploy.py [DEPLOY_ALL] [t01|dev1|dev2]` – copies to
  `YINCIC.CPSM.<ENV>.PET.*`, BINDs `PETM*` packages, renders DDL and JCL
  with `envs/<env>.yaml`. Note the default target HLQ in `deploy.py` is T01.
- JCL in `JCL/` (CSD, RACF, BIND PLAN, RUNDDL) is submitted manually after deploy.

## Test data (`python/`)
- `data/*.csv` are the source data; `gen<Table>.py` generate DSNTEP2 INSERTs
  per table, `genAll.py` generates `alldata.sql` (DELETE children first,
  INSERT parents first, one COMMIT). FKs refer by code, not identity ID.
- `python python/genAll.py -e envs/dev1.yaml -o python/alldata.sql`
  (needs `pyyaml`). This one does run locally.

## API testing (`python/`)
- `testAPI.py` (full CRUD walk-through), `testAPI2.py` (quick checks),
  `processYAML.py` (register a spec with LWW), `uploadui*.py` (upload `ui/`
  to LWW). They talk to real hosts (`t01.yinhdisv.nl:8081`,
  `mainframeyin:8091/8092`) – ask before running them.
- Credentials come from `~/.creds` (JSON for Entra ID client credentials,
  or a `(user, password)` tuple for the API's `/token`). **Never hardcode
  or commit credentials**; keep them out of these scripts.

## Workflow
- Branch `v1` is the working branch; PRs go to `main`.
- When the API contract changes, tell the user that `petshop-frontend`
  (its mocks and SPEC) may need the same change.
- If something about the mainframe environment is unclear, ask rather than guess.
