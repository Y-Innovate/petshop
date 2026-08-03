           05 L43000GC.
              10 WOR.
                 15 IVR.
                    20 RLR-RLT-IVR        PIC X(9)   .
                    20 RLR-CME-IVR        PIC X(15)  .
                    20 SFN-RLT-IVR        PIC X(9)   .
                    20 LBL                PIC X(3)   .
                    20 IDC-RKG            PIC X(1)   .
                    20 IDC-KLE            PIC X(1)   .
                    20 IDC-MMO            PIC X(1)   .
                    20 IDC-MRT            PIC X(1)   .
                    20 IDC-ERD            PIC X(1)   .
                    20 IDC-KMK            PIC X(1)   .
                    20 DTM-GBT-RLT-IVR    PIC X(8)   .
                    20 KDE-GST-RLT-IVR    PIC X(1)   .
                    20                    PIC X(49)  .
                 15 UVR.
                    20 RLR-RLT            PIC X(9)   .
                    20 DTM-GBT-RLT        PIC X(8)   .
                    20 KDE-GST-RLT        PIC X(1)   .
                    20 VLS-RLT            PIC X(6)   .
                    20 VVS-RLT            PIC X(10)  .
                    20 ESE-VNA-RLT        PIC X(15)  .
                    20 ATR-DAK-RLT        PIC X(25)  .
                    20 ADD-NGB-RLT        PIC X(1)   .
                    20 OSV-ADD-NGB        PIC X(55)  .
                    20 PAD-RLT            PIC X(9)   .
                    20 HNR-RLT            PIC X(5)   .
                    20 HNG-RLT            PIC X(4)   .
                    20 SNM-RLT            PIC X(24)  .
                    20 WPN-RLT            PIC X(24)  .
                    20 KDE-LRT            PIC X(2)   .
                    20 OSV-KDE-LRT        PIC X(25)  .
                    20 DTM-IGG-LRT        PIC X(8)   .
                    20 DTM-EDE-LRT        PIC X(8)   .
                    20 KDE-NTL            PIC X(2)   .
                    20 OSV-KDE-NTL        PIC X(25)  .
                    20 SFN-RLT            PIC X(9)   .
                    20 STS-SFN-RLT        PIC X(2)   .
                    20 OSV-STS-SFN        PIC X(55)  .
                    20 TLO-PVE-RLT        PIC X(15)  .
                    20 TLO-ZAK-RLT        PIC X(15)  .
                    20 TTE-VOR-VNA-RLT    PIC X(3)   .
                    20 OSV-TTE-VOR-VNA    PIC X(55)  .
                    20 TTE-AT0-ATR-RLT    PIC X(3)   .
                    20 OSV-TTE-AT0-ATR    PIC X(55)  .
                    20 DTM-EDE-RLT        PIC X(8)   .
                    20 RLR-CME            PIC X(15)  .
                    20 VVS-AER            PIC X(10)  .
                    20 ATR-EGT-DAK-AER    PIC X(25)  .
                    20 DTM-IGG-AER        PIC X(8)   .
                    20 DTM-EDE-AER        PIC X(8)   .
                    20 NAM-SMS            PIC X(90)  .
                    20 RSA.
                       25 DTM-IGG-RSA     PIC X(8)   .
                       25 DTM-EDE-RSA     PIC X(8)   .
                       25 PAD-RSA         PIC X(9)   .
                       25 HNR-RSA         PIC X(5)   .
                       25 HNG-RSA         PIC X(4)   .
                       25 SNM-RSA         PIC X(24)  .
                       25 WPN-RSA         PIC X(24)  .
                       25 KDE-LND-RSA     PIC X(2)   .
                       25 OSV-KDE-LND-RSA PIC X(25)  .
                    20 EML-ADS            PIC X(100) .
                    20 KDE-GBR-EML-ADS    PIC X(2)   .
                    20 OSV-GBR-EML-ADS    PIC X(55)  .
                    20 ICS-MMT            PIC X(2)   .
                    20 OSV-ICS-MMT        PIC X(55)  .
                    20 VNZ-ACG            PIC X(2)   .
                    20 OSV-VNZ-ACG        PIC X(55)  .
                    20 RKG-GGV OCCURS 5.
                       25 SRT-ICO         PIC X(3)   .
                       25 OSV-SRT-ICO     PIC X(55)  .
                       25 DTM-IGG-RKG     PIC X(8)   .
                       25 DTM-EDE-RKG     PIC X(8)   .
                       25 IBN-ICS         PIC X(34)  .
                       25 BIC-ICS         PIC X(11)  .
                       25 WZE-ICS         PIC X(1)   .
                       25 OSV-WZE-ICS     PIC X(55)  .
                       25 IBN-EKS         PIC X(34)  .
                       25 BIC-EKS         PIC X(11)  .
                       25 WZE-EKS         PIC X(1)   .
                       25 OSV-WZE-EKS     PIC X(55)  .
                    20 KLE-GGV.
                       25 KDE-KLE-AGM     PIC X(3)   .
                       25 OSV-KLE-AGM     PIC X(10)  .
                       25 KDE-KLE-PLI     PIC X(3)   .
                       25 OSV-KLE-PLI     PIC X(10)  .
                       25 DTM-IGG-KLE     PIC X(8)   .
                       25 DTM-EDE-KLE     PIC X(8)   .
                    20 ATL-MMO            PIC X(2)   .
                    20 MMO-GGV OCCURS 30.
                       25 MMO-RGE         PIC X(72)  .
                    20 ATL-MRT            PIC X(2)   .
                    20 MRT-GGV OCCURS 15.
                       25 TPE-MRT         PIC X(6)   .
                       25 OSV-TPE-MRT     PIC X(55)  .
                       25 KDE-MRT         PIC X(1)   .
                       25 OSV-KDE-MRT     PIC X(55)  .
                       25 DTM-IGG-MRT     PIC X(8)   .
                       25 DTM-EDE-MRT     PIC X(8)   .
                    20 ATL-ERD            PIC X(2)   .
                    20 ERD-GGV OCCURS 10.
                       25 TPE-TEN         PIC X(2)   .
                       25 OSV-TPE-TEN     PIC X(55)  .
                       25 ETN-RNR-ERD     PIC X(15)  .
                       25 DTM-IGG-ERD     PIC X(8)   .
                       25 DTM-EDE-ERD     PIC X(8)   .
                    20 TVR-EML-ADS        PIC X(100) .
                    20 KMK-GGV OCCURS 20.
                       25 KDE-KMK         PIC X(7)   .
                       25 WDE-KMK         PIC X(1)   .
                       25 DTM-IGG-KMK     PIC X(8)   .
                       25 DTM-EDE-KMK     PIC X(8)   .
                    20                    PIC X(485) .
              10 PAR                      REDEFINES WOR PIC X(8650).
