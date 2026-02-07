# RedMineCloudImplementation

This project is part of the lecture "cloud services" at Hochschule Fulda in winter of 2025/2026

## Description

This project aims to implement the open source version control software redmine as a high availability cloud service with automatic scaling and backups

## Getting Started

### Dependencies

- eduVPN
- terraform
- bash

### Installing

Clone the repo using https or ssh.

### Executing program
1. Connect to the Hochschule Fulda Network using "eduVPN"
    - Help: https://doku.rz.hs-fulda.de/doku.php/docs:eduvpn
2. Using bash in the root of the repo, execute the following commands:
    - chmod +x launch.sh
    - ./launch.sh
    - If demanded, confirm all ssh fingerprints by typing "yes"
3. Reset the OpenStack infrastructure by executing the following commands:
    - cd terraform
    - terraform destroy

## Help

For help please contact finn-liam.wolf@informatik.hs-fulda.de

## Authors

- Finn Wolf (finn-liam.wolf@informatik.hs-fulda.de)
- Wilhelm
- Alan