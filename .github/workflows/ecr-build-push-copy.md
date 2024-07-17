name: Argo CD GitOps CI/CD

on:
  push:
    branches:
      - main

jobs:
  build:
    name: Build and Push the image
    runs-on: ubuntu-latest

    steps:
    - name: Check out code
      uses: actions/checkout@v2

    - name: Bump versions
      id: bump_versions
      run: |
        chmod +x world/bump_version_world_template.sh
        ./world/bump_version_world_template.sh
        new_version=$(cat VERSION-TEMP-WORLD)
        echo "new_version=$new_version" >> $GITHUB_ENV
        echo "::set-output name=new_version::$new_version"

        chmod +x world/bump_version_world_workflow.sh
        ./world/bump_version_world_workflow.sh
        new_world_version=$(cat VERSION-WF-WORLD)
        echo "new_world_version=$new_world_version" >> $GITHUB_ENV
        echo "::set-output name=new_world_version::$new_world_version"

    - name: Update YAML files with new versions
      run: |
        new_version=$(cat VERSION-TEMP-WORLD)
        new_world_version=$(cat VERSION-WF-WORLD)
        echo "Updating WorkflowTemplate.yaml and worldworkflow.yaml with versions $new_version and $new_world_version"
        sed -i "s/value: \"[0-9.]*\"/value: \"$new_version\"/g" world/WorkflowTemplate.yaml
        sed -i "s/value: \"[0-9.]*\"/value: \"$new_world_version\"/g" world/worldworkflow.yaml
        echo "Updated WorkflowTemplate.yaml and worldworkflow.yaml"

    - name: Commit updated files
      run: |
        git config --global user.name 'sosotechnologies'
        git config --global user.email 'sosotech2000@gmail.com'
        git add VERSION-TEMP-WORLD VERSION-WF-WORLD world/WorkflowTemplate.yaml world/worldworkflow.yaml
        git commit -m "Bump versions to ${{ steps.bump_versions.outputs.new_version }} and ${{ steps.bump_versions.outputs.new_world_version }}" || echo "No changes to commit"
        git stash
        git pull --rebase origin main
        git stash pop || echo "No stashed changes"
        git push origin main

    - name: Build the Docker image
      run: |
        cd docker/world-docker
        docker build -t ${{ steps.bump_versions.outputs.new_version }} .

    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: '${{ steps.bump_versions.outputs.new_version }}'
        format: 'table'
        exit-code: '0'
        ignore-unfixed: true
        vuln-type: 'os,library'
        severity: 'MEDIUM,HIGH,CRITICAL'
        output: 'trivy-report.txt'

    - name: Upload Trivy report
      uses: actions/upload-artifact@v3
      with:
        name: trivy-report
        path: world/trivy-report.txt

    - name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1

    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1

    - name: Tag and Push Docker image to Amazon ECR
      run: |
        IMAGE_TAG=${{ steps.bump_versions.outputs.new_version }}
        ECR_REGISTRY=${{ secrets.AWS_ACCOUNT_NUMBER }}.dkr.ecr.us-east-1.amazonaws.com
        REPOSITORY=xcite
        docker tag $IMAGE_TAG $ECR_REGISTRY/$REPOSITORY:$IMAGE_TAG
        docker push $ECR_REGISTRY/$REPOSITORY:$IMAGE_TAG
        docker tag $IMAGE_TAG $ECR_REGISTRY/$REPOSITORY:latest
        docker push $ECR_REGISTRY/$REPOSITORY:latest

  deploy:
    name: Deploy to Argo CD
    runs-on: ubuntu-latest
    needs: build

    steps:
    - name: Check out code
      uses: actions/checkout@v2

    - name: Check VERSION-TEMP-WORLD file content
      run: cat VERSION-TEMP-WORLD

    - name: Print WorkflowTemplate.yaml before update
      run: cat world/WorkflowTemplate.yaml
    
    # - name: Check VERSION-TEMP-WORLD file content
    #   run: cat VERSION-WF-WORLD

    # - name: Print worldworkflow.yaml before update
    #   run: cat world/worldworkflow.yaml