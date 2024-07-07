[https://argo-workflows.readthedocs.io/en/latest/quick-start/](https://argo-workflows.readthedocs.io/en/latest/quick-start/)
[Github release](https://github.com/argoproj/argo-workflows)
[Install argo-Cli](https://github.com/argoproj/argo-workflows/releases/)

## First, specify the version you want to install in an environment variable. Modify the command below:
```sh
kubectl create namespace argo 
wget https://github.com/argoproj/argo-workflows/releases/download/v3.5.6/quick-start-minimal.yaml
kubectl apply -n argo -f  quick-start-minimal.yaml
kubectl -n argo get po  
kubectl -n argo get deploy argo-server
kubectl -n argo wait deploy --all --for condition=Available --timeout 2m
kubectl port-forward svc/argo-server -n argo --address 0.0.0.0 8084:2746
# kubectl patch service argo-server -n argo -p '{"spec": {"type": "LoadBalancer"}}'
```

## Edit service to Loadbalancer
https://localhost:8084/

## Submit an example workflow
```sh
argo submit -n argo --watch https://raw.githubusercontent.com/argoproj/argo-workflows/main/examples/hello-world.yaml
argo list -n argo
argo get -n argo @latest
argo logs -n argo @latest
```

## delete the workflow
```sh
argo list -n argo
argo delete -n argo hello-world-7mglc 
```

## create workflow files

### 1. common example

```sh
kubectl -n argo apply -f 1-example-workflow.yaml
```

### 2. with ecr private repo image

***create the secret***

```sh
kubectl create secret docker-registry ecr-registry-secret-argo \
  --docker-server=368085106192.dkr.ecr.${AWS_REGION}.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region us-east-1) \
  --namespace=argo \
  --docker-email=example@example.com  \
  --dry-run=client -o yaml > aws-ecr-secret-argo.yaml
```

```sh
kubectl -n argo apply -f 2-example-workflow.yaml
```

### 3. Create  DAG

```sh
kubectl -n argo apply -f 3-DAG-example-workflow.yaml
```


### Not related - Create a sa for argo and use that to submit workflow
k -n argo create sa soso
k -n argo create rolebinding soso --serviceaccount=argo:soso --role=workflow-role
k submit --serviceaccount soso  mywffile.yaml