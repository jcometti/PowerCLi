# Tigera Challenge

This GitHub repository contains a collection of solution provide for the Tigera challenge. All manifests was created by Joao Cometti.

## Table of Contents
- [Getting Started](#getting-started)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Contact](#contact)

## Getting Started

The lab used for this challeges was create on-premises infrastructure provided by OpenText. All solution it was replicated on AWS but not using EKS, it was hands on lab created from scratch. 

## Prerequisites

Before start the challenge, make sure you meet the following requirements:

- Install a kubernetes cluster using the distribution and the environment of your choice (your laptop or cloud) including 1x master and 2x nodes.
- Do not use managed kubernetes such as EKS, AKS or GKE.
- Install calico, bookinfo (specified) and alpine pod for testing. 
- The bookinfo app is managed by a team called dev1
- Expose bookinfo product page using the method of your choice to users accessing it from utside of the cluster from a well-defined network range.
- Implement granular calico policies restricting communication among bookinfo micro-services to the bare minimum. Define your strategy with respect to implementing ingress only, egress only, or
ingress and egress controls.

## Installation

1. Docker for `Ubuntu linux`: https://docs.docker.com/engine/install/ubuntu/ 
```
sudo apt-get update
```
```
sudo apt-get install ca-certificates curl gnupg
```
```
sudo install -m 0755 -d /etc/apt/keyrings
```
```
curl -fsSL [https://download.docker.com/linux/ubuntu/gpg](https://download.docker.com/linux/ubuntu/gpg) | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```
```
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```
```
echo \
"deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] [https://download.docker.com/linux/ubuntu](https://download.docker.com/linux/ubuntu) \
"$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
```
```
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
```
sudo apt-get update
```
```
VERSION_STRING=5:20.10.20~3-0~ubuntu-jammy
```
```
sudo apt-get install docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING [containerd.io](http://containerd.io/) docker-buildx-plugin docker-compose-plugin
```

2. Kubenetes: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

The k8s requires certain GNU/Linux kernel modules to be loaded for its full operation, and that these modules are loaded at the time of computer startup. To do this, create the file /etc/modules-load.d/k8s.conf with the following content on all your nodes.

  ```
  vim /etc/modules-load.d/k8s.conf
 
  ```
  ```
  br_netfilter
  ip_vs
  ip_vs_rr
  ip_vs_sh
  ip_vs_wrr
  nf_conntrack_ipv4
  overlay
  ```
Enabling packet forwarding and have iptables manage the packets that are traveling through the bridges. For this, we will use systcl to parameterize the kernel.
  
   ```
   vim /etc/sysctl.d/k8s.conf
   ```
   ```
   net.bridge.bridge-nf-call-ip6tables = 1
   net.bridge.bridge-nf-call-iptables = 1
   net.ipv4.ip_forward = 1
   ```
   To read the setup above. 
   ```
   sysctl --system
   ```
   ```
   sudo apt update
   sudo apt upgrade -y
   ```
Update the apt package index and install packages needed to use the Kubernetes apt repository:
   ```
   sudo apt-get update
   sudo apt-get install -y apt-transport-https ca-certificates curl
   ```
 
Download the Google Cloud public signing key:
   ```
  curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
   ```
Add the Kubernetes apt repository:
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

   ```
   apt-get update
   ```
   k8s `Version 1.23`
   ```
   apt-get install -y kubelet=1.23.1-00 kubeadm=1.23.1-00 kubectl=1.23.1-00 --allow-downgrades
   ```
   k8s `version 1.26`
   ```
   apt-get install -y kubelet=1.26.1-00 kubeadm=1.26.1-00 kubectl=1.26.1-00 --allow-downgrades
   ```
For Master node only:
Version 1.26.1 cidr 10.10.0.0/16
   ```
   kubeadm init --pod-network-cidr 10.10.0.0/16 --kubernetes-version 1.26.1 --node-name lab-k8s-master
   ```
Version 1.23.1 cidr 192.168.0.0/16
   ```
   kubeadm init --pod-network-cidr 192.168.0.0/16 --kubernetes-version 1.23.1 --node-name lab-k8s-master
   ```
Setup Kubectl
   
   ```
   mkdir -p $HOME/.kube 
   cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config
   ```
Get worker node commands to run to join additional nodes into cluster
   ```
   kubectl apply -f custom-resources.yaml
   ```
Extra: To install `auto-completition`
   ```
   sudo apt install -y bash-completion
   kubectl completion bash > /etc/bash_completion.d/kubectl
   source <(kubectl completion bash)
   ```

3. CALICO

Installing Container Network Interface (CNI) 
Calico 3.25 CNI - https://docs.tigera.io/calico/3.25/getting-started/kubernetes/quickstart
   ```
   kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml
   wget https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/custom-resources.yaml

   ```
Edit custom-resources.yaml - change for the ip chosen (CIDR) on kubeadm init 192.168.0.0/16 or 10.10.0.0/16 

Install CalicoCTL
   ```
   curl -L https://github.com/projectcalico/calico/releases/latest/download/calicoctl-linux-amd64 -o calicoctl
   chmod +x ./calicoctl
   mv calicoctl /usr/local/bin/
   ```
   
   ```
   curl -L https://github.com/projectcalico/calico/releases/latest/download/calicoctl-linux-amd64 -o kubectl-calico
   chmod +x kubectl-calico
   ```
Type:
   ```
   nano /etc/calico/calicoctl.cfg
   ```
Copy and past inside the calicoctl.cfg
   ```
   apiVersion: projectcalico.org/v3
   kind: CalicoAPIConfig
   metadata:
   spec:
     datastoreType: "kubernetes"
     kubeconfig: "/home/labuser/.kube/config"

   ```




## Usage

1. Deploying `bookinfo app`.
Create a new manifest called bookinfo.yaml and past the file content. 
  ```
  kubectl apply -f bookinfo.yaml
  ```

```bash
kubectl get pods

NAME                              READY   STATUS    RESTARTS   AGE
details-v1-8444789857-bgsb2       1/1     Running   0          2m49s
productpage-v1-748b468c6c-6xghf   1/1     Running   0          2m46s
ratings-v1-588b5477fc-ddfmp       1/1     Running   0          2m49s
reviews-v1-577c5f7847-6vwgt       1/1     Running   0          2m48s
reviews-v2-7c74fb5d49-nqf4h       1/1     Running   0          2m48s
reviews-v3-58cb55c99-fjvz2        1/1     Running   0          2m47s

kubectl get services

NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
details       ClusterIP   10.102.61.183   <none>        9080/TCP   24m
kubernetes    ClusterIP   10.96.0.1       <none>        443/TCP    1d1h
productpage   ClusterIP   10.97.188.234   <none>        9080/TCP   24m
ratings       ClusterIP   10.98.244.32    <none>        9080/TCP   24m
reviews       ClusterIP   10.109.242.61   <none>        9080/TCP   24m
```


2. Nginx-Controller - https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/deploy.yaml

Creating ingress to access booking external 
2.nginx-controller.svc.yaml 

```bash
# nano 2.nginx-controller.svc.yaml

apiVersion: v1
kind: Service
metadata:
  name: ingress-nginx
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
spec:
  type: NodePort
  ports:
    - name: http
      port: 80
      targetPort: 80
      protocol: TCP
    - name: https
      port: 443
      targetPort: 443
  selector:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
---
# nano 4.productpage-ingress-rules.yaml

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: productpage-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    #kubernetes.io/ingress.class: ingress-nginx
spec:
  ingressClassName: nginx #should be same name of kubectl get ingressClass
  rules:
  - http:
      paths:
      - path: /productpage #http://10.96.53.86:30865/appv1
        pathType: Prefix
        backend:
          service:
            name: productpage #referencia ao servico criado. 
            port:
              number: 9080 #porta definida no services
      - path: /static #http://10.96.53.86:30865/appv1
        pathType: Prefix
        backend:
          service:
            name: productpage #referencia ao servico criado. 
            port:
              number: 9080 #porta definida no services
      - path: /login #http://10.96.53.86:30865/appv1
        pathType: Prefix
        backend:
          service:
            name: productpage #referencia ao servico criado. 
            port:
              number: 9080 #porta definida no services
      - path: /logout #http://10.96.53.86:30865/appv1
        pathType: Prefix
        backend:
          service:
            name: productpage #referencia ao servico criado. 
            port:
              number: 9080 #porta definida no services
      - path: /api/v1/products #http://10.96.53.86:30865/appv1
        pathType: Prefix
        backend:
          service:
            name: productpage #referencia ao servico criado. 
            port:
              number: 9080 #porta definida no services

```
The external IP of my cluster is the cluster ip, so to access the page external type: 

```bash
ingress-nginx      ingress-nginx-controller             NodePort    10.97.231.221    <none>        80:**31644**/TCP,443:31490/TCP

The external port is: 31644
```

3. Creating Service Account called `dev1` and associate it to productpage pod, create roles for the services account and Rolebinding with it.
   
```bash

   #roles a service account that can create permission to list pods.
---
# 1. Create service account
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dev1
---
# 2. create a pod using the service account above.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vm-dev1
  labels:
    app: front
spec:
  replicas: 1
  selector:
    matchLabels:
      app: front
  template:
    metadata:
      labels:
        app: front
    spec:
      serviceAccountName: dev1
      containers:
      - name: nginx
        image: nginx:alpine
---
#3. create a role to use with the SA
apiVersion: rbac.authorization.k8s.io/v1 #kubectl api-resources |grep -i roles
kind: Role
metadata:
  namespace: default
  name: productpg-reader
rules:
- apiGroups: [""]
  resources: ["pods"] #This role only allow toe list, watch and get pods.
  verbs: ["get", "watch", "list"]
#- apiGroups: ["apps"]
#  resouces: ["deployments"]
#  verbs: ["get", "watch", "list"]
---
#4. Rolebinding associated to with SA
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: sa-pods
  namespace: default
subjects:
- kind: ServiceAccount
  name: dev1 #The SA name above
  apiGroup: ""
roleRef:
  kind: Role #Roler Group
  name: productpg-reader #This should match the name of Role or ClusterRole
  apiGroup: rbac.authorization.k8s.io
```

4. Network policies:

The idea is setup the zero-trust, blocking all comunication and allowing between the pod by label in a specific namespace. 

It was deployed 3 pods with 3 services. When apply the network policies all traffic is blocked and the allow ingress didn't work. 

```bash
# 5.calico-policys.yaml
---
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: default-deny-all
spec:
  selector: all()
  types:
  - Ingress
---
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: allow-vm03-to-vm01
spec:
  selector: app == 'aaa'
  types:
  - Ingress
  ingress:
  - action: Allow
    protocol: TCP
    source:
      selector: app == 'ccc'
    destination:
      ports:
      - 8080
---
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: allow-vm02-to-vm03
spec:
  selector: app == 'ccc'
  types:
  - Ingress
  ingress:
  - action: Allow
    protocol: TCP
    source:
      selector: app == 'bbb'
    destination:
      ports:
      - 8080
---
```

## Contact

If you have any questions, issues, or suggestions, feel free to open an issue on GitHub or reach out to the maintainer at [youremail@example.com](mailto:joao.cometti@gmail.com).
