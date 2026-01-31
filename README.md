# RedMineCloudImplementation

## Terraform

    ssh key erstellen in powershell für die control-plane:
    auf windows: ssh-keygen -t ed25519 -f $env:USERPROFILE\.ssh\id_ed25519 -C "uni-k8s"
    (auf Linux anpassen)

    terraform init
    terraform validate

    terraform apply

    floating ip der control-plane wird in der konsole ausgegeben.
    zugriff auf control-plane: ssh -i C:\Users\ #user#\ .ssh\id_ed25519 ubuntu@floating-ip (Leerzeichen vor username und .ssh muss weg. wegen formatierung)
    um auf die worker zu kommen: ssh jump -> ssh -J ubuntu@floating-ip ubuntu@privateInstanzIp 



    terraform destroy
    
## Kubernetes
