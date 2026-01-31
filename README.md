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
    vorläufige Anleitung zum starten:
    ssh ubuntu@<CONTROL_PLANE_FLOATING_IP>

    git clone <REPO_URL> Redmine
    cd Redmine

    cd k8s2/cluster
    chmod +x install-k3s-server.sh
    ./install-k3s-server.sh <CONTROL_PLANE_FLOATING_IP>

    sudo cat /var/lib/rancher/k3s/server/node-token
    Token kopieren

    per ssh jump auf worker
    ssh -J ubuntu@<CONTROL_PLANE_FLOATING_IP> ubuntu@<WORKER_PRIVATE_IP>

    git clone <REPO_URL> Redmine
    cd Redmine

    cd k8s22/cluster
    chmod +x install-k3s-agent.sh
    ./install-k3s-agent.sh <CONTROL_PLANE_PRIVATE_IP> TOKEN

    AUF ALLEN 3 WORKERN MACHEN

    Cluster auf der conntrol plane prüfen
    sudo k3s kubectl get nodes -o wide

    Deploy (wegen kubectl müssen im zweifesfall noch rechte gesetzt werden)
    kubectl apply -k k8s/apps/redmine/base
    kubectl -n redmine get pods -w

    im Browser
    http://<CONTROL_PLANE_FLOATING_IP>:30080
    