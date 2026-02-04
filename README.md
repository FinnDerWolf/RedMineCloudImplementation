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
    Ablauf unter der Annahme, dass Linux oder Windows WSL genutzt wird. Terraform Outputs sollten rauskopiert worden sein.

    1. Lokale Skripte ausführbar machen
        chmod +x k8s2/cluster/install-k3s-server.sh
        chmod +x k8s2/cluster/join-workers.sh
    
    2. k3s Server installieren (auf PC ausführen)
        ssh ubuntu@<CONTROL_PLANE_FLOATING_IP> "sudo bash -s" < k8s2/cluster/install-k3s-server.sh <CONTROL_PLANE_FLOATING_IP>

    3. Traefik hostPort Config aus Repo auf Control-Plane kopieren (auf PC ausführen)
        scp k8s2/cluster/traefik-hostport.yaml ubuntu@<CONTROL_PLANE_FLOATING_IP>:/tmp/traefik-config.yaml

        ssh ubuntu@<CONTROL_PLANE_FLOATING_IP> "sudo mv /tmp/traefik-config.yaml /var/lib/rancher/k3s/server/manifests/traefik-config.yaml"

    4. Repo auf den Server klonen (von PC aus)
        ssh ubuntu@<CONTROL_PLANE_FLOATING_IP> "git clone https://github.com/FinnDerWolf/RedMineCloudImplementation.git ~/Redmine"

        git switch feature/kubernetesTest

    5. Deploy-from-Git Skript auf dem Server nutzen
        cd Redmine

        chmod +x k8s2/scripts/deploy-from-git.sh

        export OVERLAY=production BRANCH=feature/kubernetesTest && ./k8s2/scripts/deploy-from-git.sh

    6. Worker joinen (von PC aus)
        ./k8s2/cluster/join-workers.sh --server ubuntu@<CONTROL_PLANE_FLOATING_IP> --workers "ubuntu@<WORKER_PRIVATE_IP_1> ubuntu@<WORKER_PRIVATE_IP_2> ubuntu@<WORKER_PRIVATE_IP_3>"

    7. Deployment neustarten, um Pods auf worker zu verteilen
        ssh ubuntu@<CONTROL_PLANE_FLOATING_IP> "sudo k3s kubectl -n redmine rollout restart deployment redmine"

    8. Zugriff testen (im Browser)
        http://<CONTROL_PLANE_FLOATING_IP>/


    für loadtest k6 installieren
    BASE_URL=<CONTROL_PLANE_IP> k6 run loadtest/k6/redmine.js

    oder auf windows

    set BASE_URL=http://<CONTROL_PLANE_IP>
    k6 run loadtest/k6/redmine.js


    sudo k3s kubectl -n redmine get hpa -w
    sudo k3s kubectl -n redmine get pods -w
    sudo k3s kubectl top pods -n redmine
    