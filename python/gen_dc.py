#!/usr/bin/env python3
"""Split a base64 string into 51-byte chunks and emit HLASM DC C'...' statements."""

import sys

CHUNK_SIZE = 51


def to_dc_statements(data: str) -> str:
    chunks = [data[i:i + CHUNK_SIZE] for i in range(0, len(data), CHUNK_SIZE)]
    return "\n".join(f"          DC    C'{chunk}'" for chunk in chunks)


def main() -> None:
    if len(sys.argv) > 1:
        data = sys.argv[1]
    else:
        data = sys.stdin.read().strip()
    print(to_dc_statements(data))


if __name__ == "__main__":
    main()
