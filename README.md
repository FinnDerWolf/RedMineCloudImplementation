# RedMineCloudImplementation

This project is part of the lecture "cloud services" at Hochschule Fulda in winter of 2025/2026

## Description

This project aims to implement the open source version control software redmine as a high availability cloud service with automatic scaling and backups.

## Getting Started

### Dependencies

- eduVPN (for OpenStack connection)
- terraform (for deployment script)
- kubectl (for deployment script)
- git
- bash
- k6 (for load testing)

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

### Test Cluster Health, Ingress, Storage, healing and backups

The following commands must be run on the control Plane using ssh (ssh ubuntu@<CONTROL_PLANE_FLOATING_IP>) to test these services

1. Cluster Health and High Availability
            
        sudo k3s kubectl get nodes -o wide

2. All Components working

        sudo k3s kubectl get pods -A -o wide

3. Ingress and external access

        sudo k3s kubectl get ingress -A
        sudo k3s kubectl describe ingress redmine -n redmine

4. PVC

        sudo k3s kubectl -n redmine get pvc

5. Self-Healing
   
        sudo k3s kubectl -n redmine get pods
        sudo k3s kubectl -n redmine delete pod <POD_NAME>

        sudo k3s kubectl -n redmine get pods -w

6. Pod disruption Budget

        sudo k3s kubectl -n redmine get pdb
        sudo k3s kubectl -n redmine describe pdb redmine-pdb

7. Persistence

        sudo kubectl -n redmine delete pod postgres-0
        sudo kubectl -n redmine get pod postgres-0 -w

8. Manual backup

        sudo kubectl -n redmine create job --from=cronjob/postgres-backup-to-github postgres-backup-manual

9. Delete Databse and restore

        sudo kubectl -n redmine scale statefulset postgres --replicas=0
        sudo kubectl -n redmine get pods
        sudo kubectl -n redmine delete pvc pgdata-postgres-0
        sudo kubectl -n redmine scale statefulset postgres --replicas=1
        sudo kubectl -n redmine get pod postgres-0 -w

        sudo kubectl -n redmine logs postgres-0 -c restore-from-github




### Load testing and Auto scaling

For load testing follow these steps:

1. Run in root directroy of the project:
   
    - Linux: 
                    BASE_URL=http://<CONTROL_PLANE_FLOATING_IP> k6 run loadtest/k6/redmine.js

    - Windows: 
            
            set BASE_URL=http://<CONTROL_PLANE_FLOATING_IP>
            k6 run loadtest\k6\redmine.js

2. Watch on the control plane:
   
    sudo k3s kubectl -n redmine get pods -w

    sudo k3s kubectl -n redmine get hpa -w

## Disclaimer

This codebase is **not** production safe, as it disables several warnings regarding among others ssh and prints the password for the grafana admin panel when deployed 

## Help

For help please contact finn-liam.wolf@informatik.hs-fulda.de

## Acknowlegment

- The great ressources from our lecture by Prof. Rieger and teaching assistant Faizan Anwar
- To aid with coding and research, the following AI tools were used:
    - GitHub Copilot
    - ChatGPT

## Authors

- Finn Wolf (finn-liam.wolf@informatik.hs-fulda.de)
- Wilhelm Rassner (wilhelm.rassner@informatik.hs-fulda.de)
- Alan Mohammad (alan.mohammad@informatik.hs-fulda.de)
