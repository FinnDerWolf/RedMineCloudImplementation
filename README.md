# RedMineCloudImplementation

This project is part of the lecture "cloud services" at Hochschule Fulda in winter of 2025/2026

## Description

This project aims to implement the open source version control software redmine as a high availability cloud service with automatic scaling and backups.

## Getting Started

### Dependencies

- eduVPN
- terraform
- git
- bash

### Installing

1. Clone the repo using https or ssh.
2. Create ssh key using a terminal of your choice:
    - Windows: ssh-keygen -t ed25519 -f $env:USERPROFILE\.ssh\id_ed25519 -C "uni-k8s"
    - Linux/macOS: ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "uni-k8s"
3. Create your local terraform.tfvars by executing the following commands:
    - cd terraform
    - terraform.tfvars.example umbenenen:
        - Windows (PowerShell): Rename-Item terraform.tfvars.example terraform.tfvars
        - Linux/macOS: mv terraform.tfvars.example terraform.tfvars
    - open the terraform.tfvars using an editor like nano:
        - nano terraform.tfvars
    - Fill the five empty variables at the top as described by the comments 
    - Save and close the buffer

### Executing program

1. Connect to the Hochschule Fulda Network using "eduVPN"
    - Help: https://doku.rz.hs-fulda.de/doku.php/docs:eduvpn
2. Using bash in the root of the repo, execute the following commands:
    - chmod +x deploy.sh
    - ./deploy.sh
    - If demanded, confirm all ssh fingerprints by typing "yes"
3. When finished, destroy the OpenStack infrastructure by executing the following commands:
    - cd terraform
    - terraform destroy
    - When demanded confirm destruction with "yes"

## Functionality

### Reachable Endpoints

1. Redmine is running on port 80
2. Grafana dashboard is running on port 3000

### Auto scaling, healing and backups

TODO

### Load testing

TODO

## Disclaimer

This codebase is **not** production safe, as it disables several warnings regarding among others ssh and prints the password for the grafana admin panel when deployed 

## Help

For help please contact finn-liam.wolf@informatik.hs-fulda.de

## Acknowlegment

- The great ressources from our lecture by Prof. Rieger
- To aid with coding and research, the following AI tools were used:
    - GitHub Copilot
    - ChatGPT

## Authors

- Finn Wolf (finn-liam.wolf@informatik.hs-fulda.de)
- Wilhelm Rassner
- Alan