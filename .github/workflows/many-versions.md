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
        chmod +x scripts/bump_version_world_template.sh
        ./scripts/bump_version_world_template.sh
        new_version=$(cat VERSION-TEMP-WORLD)
        echo "new_version=$new_version" >> $GITHUB_ENV
        echo "::set-output name=new_version::$new_version"

        chmod +x scripts/bump_version_world_workflow.sh
        ./scripts/bump_version_world_workflow.sh
        new_world_version=$(cat VERSION-WF-WORLD)
        echo "new_world_version=$new_world_version" >> $GITHUB_ENV
        echo "::set-output name=new_world_version::$new_world_version"

        chmod +x scripts/bump_version_cpu_task.sh
        ./scripts/bump_version_cpu_task.sh
        new_cpu_version=$(cat VERSION-CPU-TASK)
        echo "new_cpu_version=$new_cpu_version" >> $GITHUB_ENV
        echo "::set-output name=new_cpu_version::$new_cpu_version"

        chmod +x scripts/bump_version_gpu_task.sh
        ./scripts/bump_version_gpu_task.sh
        new_gpu_version=$(cat VERSION-GPU-TASK)
        echo "new_gpu_version=$new_gpu_version" >> $GITHUB_ENV
        echo "::set-output name=new_gpu_version::$new_gpu_version"

    - name: Update YAML files with new versions
      run: |
        new_version=$(cat VERSION-TEMP-WORLD)
        new_world_version=$(cat VERSION-WF-WORLD)
        new_cpu_version=$(cat VERSION-CPU-TASK)
        new_gpu_version=$(cat VERSION-GPU-TASK)
        echo "Updating WorkflowTemplate.yaml and worldworkflow.yaml with versions $new_version and $new_world_version"
        sed -i "s/value: \"[0-9.]*\"/value: \"$new_version\"/g" argo-artifacts/WorkflowTemplate.yaml
        sed -i "s/value: \"[0-9.]*\"/value: \"$new_world_version\"/g" argo-artifacts/worldworkflow.yaml
        sed -i "s/value: \"[0-9.]*\"/value: \"$new_world_version\"/g" argo-artifacts/world-pipeline.yaml
        echo "Updated WorkflowTemplate.yaml and worldworkflow.yaml"

    - name: Commit updated files
      run: |
        git config --global user.name 'sosotechnologies'
        git config --global user.email 'sosotech2000@gmail.com'
        git add VERSION-TEMP-WORLD VERSION-WF-WORLD VERSION-CPU-TASK VERSION-GPU-TASK argo-artifacts/WorkflowTemplate.yaml argo-artifacts/worldworkflow.yaml argo-artifacts/world-pipeline.yaml
        git commit -m "Bump versions to ${{ steps.bump_versions.outputs.new_version }}, ${{ steps.bump_versions.outputs.new_world_version }}, ${{ steps.bump_versions.outputs.new_cpu_version }}, and ${{ steps.bump_versions.outputs.new_gpu_version }}" || echo "No changes to commit"
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
        docker build -t ${{ steps.bump_versions.outputs.new_version }} .
        IMAGE_TAG=${{ steps.bump_versions.outputs.new_version }}
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
        docker build -t ${{ steps.bump_versions.outputs.new_cpu_version }} .
        IMAGE_TAG=${{ steps.bump_versions.outputs.new_cpu_version }}
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
        docker build -t ${{ steps.bump_versions.outputs.new_gpu_version }} .
        IMAGE_TAG=${{ steps.bump_versions.outputs.new_gpu_version }}
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
        docker build -t ${{ steps.bump_versions.outputs.new_version }} .
        IMAGE_TAG=${{ steps.bump_versions.outputs.new_version }}
        ECR_REGISTRY=${{ secrets.AWS_ACCOUNT_NUMBER }}.dkr.ecr.us-east-1.amazonaws.com
        REPOSITORY=osm
        docker tag $IMAGE_TAG $ECR_REGISTRY/$REPOSITORY:$IMAGE_TAG
        docker push $ECR_REGISTRY/$REPOSITORY:$IMAGE_TAG
        docker tag $IMAGE_TAG $ECR_REGISTRY/$REPOSITORY:latest
        docker push $ECR_REGISTRY/$REPOSITORY:latest
        cd ../..