## Create 4 ECR Repos: xcite
- gpu_tasks
- osm-osmosis
- cpu_tasks
- worker

## Add the following variables: 

- AWS_ACCESS_KEY_ID
- AWS_ACCOUNT_NUMBER
- AWS_REGION
- AWS_SECRET_ACCESS_KEY


## Run image
```sh
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <your-account-number>.dkr.ecr.us-east-1.amazonaws.com

docker pull <your-account-number>.dkr.ecr.us-east-1.amazonaws.com/gpu_tasks:latest

docker run -itdp 8088:8088 <your-account-number>.dkr.ecr.us-east-1.amazonaws.com/gpu_tasks:latest
```

368085106192.dkr.ecr.us-east-1.amazonaws.com/cpu_task
368085106192.dkr.ecr.us-east-1.amazonaws.com/gpu_task
368085106192.dkr.ecr.us-east-1.amazonaws.com/osm-osmosis
368085106192.dkr.ecr.us-east-1.amazonaws.com/worker