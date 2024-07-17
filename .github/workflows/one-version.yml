name: XCite CI/CD with Argo

on:
  push:
    branches:
      - main

jobs:
  build:
    name: Build and Push the images
    runs-on: ubuntu-latest

    steps:
    - name: Check out code
      uses: actions/checkout@v2

    - name: Bump versions
      id: bump_versions
      run: |
        chmod +x scripts/bump_versions.sh
        source ./scripts/bump_versions.sh
        echo "new_version_cpu=$new_version_cpu" >> $GITHUB_ENV
        echo "new_version_gpu=$new_version_gpu" >> $GITHUB_ENV
        echo "new_version_temp_world=$new_version_temp_world" >> $GITHUB_ENV
        echo "new_version_wf_world=$new_version_wf_world" >> $GITHUB_ENV

    - name: Update YAML files with new versions
      run: |
        new_version_temp_world=$(cat VERSIONS | sed -n '3p')
        new_version_wf_world=$(cat VERSIONS | sed -n '4p')
        new_version_cpu=$(cat VERSIONS | sed -n '1p')
        new_version_gpu=$(cat VERSIONS | sed -n '2p')
        echo "Updating WorkflowTemplate.yaml and worldworkflow.yaml with versions $new_version_temp_world and $new_version_wf_world"
        sed -i "s/value: \"[0-9.]*\"/value: \"$new_version_temp_world\"/g" argo-artifacts/WorkflowTemplate.yaml
        sed -i "s/value: \"[0-9.]*\"/value: \"$new_version_wf_world\"/g" argo-artifacts/worldworkflow.yaml
        sed -i "s/value: \"[0-9.]*\"/value: \"$new_version_wf_world\"/g" argo-artifacts/world-pipeline.yaml
        echo "Updated WorkflowTemplate.yaml and worldworkflow.yaml"

    - name: Commit updated files
      run: |
        git config --global user.name 'sosotechnologies'
        git config --global user.email 'sosotech2000@gmail.com'
        git add VERSIONS argo-artifacts/WorkflowTemplate.yaml argo-artifacts/worldworkflow.yaml argo-artifacts/world-pipeline.yaml
        git commit -m "Bump versions to ${{ env.new_version_cpu }}, ${{ env.new_version_gpu }}, ${{ env.new_version_temp_world }}, and ${{ env.new_version_wf_world }}" || echo "No changes to commit"
        git stash
        git pull --rebase origin main
        git stash pop || echo "No stashed changes"
        git push origin main

    - name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1

    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1

    - name: Build and Push world-docker image
      run: |
        cd docker/world-docker
        docker build -t ${{ env.new_version_temp_world }} .
        IMAGE_TAG=${{ env.new_version_temp_world }}
        ECR_REGISTRY=${{ secrets.AWS_ACCOUNT_NUMBER }}.dkr.ecr.us-east-1.amazonaws.com
        REPOSITORY=xcite
        docker tag $IMAGE_TAG $ECR_REGISTRY/$REPOSITORY:$IMAGE_TAG
        docker push $ECR_REGISTRY/$REPOSITORY:$IMAGE_TAG
        docker tag $IMAGE_TAG $ECR_REGISTRY/$REPOSITORY:latest
        docker push $ECR_REGISTRY/$REPOSITORY:latest
        cd ../..

    - name: Build and Push cpu_tasks image
      run: |
        cd docker/cpu_tasks
        docker build -t ${{ env.new_version_cpu }} .
        IMAGE_TAG=${{ env.new_version_cpu }}
        ECR_REGISTRY=${{ secrets.AWS_ACCOUNT_NUMBER }}.dkr.ecr.us-east-1.amazonaws.com
        REPOSITORY=cpu-task
        docker tag $IMAGE_TAG $ECR_REGISTRY/$REPOSITORY:$IMAGE_TAG
        docker push $ECR_REGISTRY/$REPOSITORY:$IMAGE_TAG
        docker tag $IMAGE_TAG $ECR_REGISTRY/$REPOSITORY:latest
        docker push $ECR_REGISTRY/$REPOSITORY:latest
        cd ../..

    - name: Build and Push gpu_tasks image
      run: |
        cd docker/gpu_tasks
        docker build -t ${{ env.new_version_gpu }} .
        IMAGE_TAG=${{ env.new_version_gpu }}
        ECR_REGISTRY=${{ secrets.AWS_ACCOUNT_NUMBER }}.dkr.ecr.us-east-1.amazonaws.com
        REPOSITORY=gpu-task
        docker tag $IMAGE_TAG $ECR_REGISTRY/$REPOSITORY:$IMAGE_TAG
        docker push $ECR_REGISTRY/$REPOSITORY:$IMAGE_TAG
        docker tag $IMAGE_TAG $ECR_REGISTRY/$REPOSITORY:latest
        docker push $ECR_REGISTRY/$REPOSITORY:latest
        cd ../..

    - name: Build and Push OSM image
      run: |
        cd docker/OSM
        docker build -t ${{ env.new_version_temp_world }} .
        IMAGE_TAG=${{ env.new_version_temp_world }}
        ECR_REGISTRY=${{ secrets.AWS_ACCOUNT_NUMBER }}.dkr.ecr.us-east-1.amazonaws.com
        REPOSITORY=osm
        docker tag $IMAGE_TAG $ECR_REGISTRY/$REPOSITORY:$IMAGE_TAG
        docker push $ECR_REGISTRY/$REPOSITORY:$IMAGE_TAG
        docker tag $IMAGE_TAG $ECR_REGISTRY/$REPOSITORY:latest
        docker push $ECR_REGISTRY/$REPOSITORY:latest
        cd ../..
