name: Argo CD GitOps CI/CD

on:
  push:
    branches:
      - two-files

jobs:
  build:
    name: Build and Push the image
    runs-on: ubuntu-latest

    steps:
    - name: Check out code
      uses: actions/checkout@v2

    - name: Bump version
      id: bump_version
      run: |
        chmod +x build-push-to-ecr/bump_version.sh
        ./build-push-to-ecr/bump_version.sh
        new_version=$(cat VERSION)
        echo "new_version=$new_version" >> $GITHUB_ENV
        echo "::set-output name=new_version::$new_version"

    - name: Update WorkflowTemplate.yaml with new version
      run: |
        new_version=$(cat VERSION)
        echo "Updating WorkflowTemplate.yaml with version $new_version"
        sed -i "s/value: \"[0-9.]*\"/value: \"$new_version\"/g" build-push-to-ecr/WorkflowTemplate.yaml
        echo "Updated WorkflowTemplate.yaml with version $new_version"
      
    - name: Commit updated files
      run: |
        git config --global user.name 'sosotechnologies'
        git config --global user.email 'sosotech2000@gmail.com'
        git add VERSION build-push-to-ecr/WorkflowTemplate.yaml
        git commit -m "Bump-it-up version to ${{ steps.bump_version.outputs.new_version }}" || echo "No changes to commit"
        git stash
        git pull --rebase origin two-files
        git stash pop || echo "No stashed changes"
        git push origin two-files
    

    - name: Bump version
      id: bump_version2
      run: |
        chmod +x build-push-to-ecr/bump_version2.sh
        ./build-push-to-ecr/bump_version2.sh
        new_version=$(cat VERSION-WORLD)
        echo "new_version=$new_version" >> $GITHUB_ENV
        echo "::set-output name=new_version::$new_version"

    - name: Update worldworkflow.yaml with new version
      run: |
        new_version=$(cat VERSION-WORLD)
        echo "Updating worldworkflow.yaml with version $new_version"
        sed -i "s/value: \"[0-9.]*\"/value: \"$new_version\"/g" build-push-to-ecr/worldworkflow.yaml
        echo "Updated worldworkflow.yaml with version $new_version"
      
    - name: Commit updated files
      run: |
        git config --global user.name 'sosotechnologies'
        git config --global user.email 'sosotech2000@gmail.com'
        git add VERSION-WORLD build-push-to-ecr/worldworkflow.yaml
        git commit -m "Bump-it-up version to ${{ steps.bump_version.outputs.new_version }}" || echo "No changes to commit"
        git stash
        git pull --rebase origin two-files
        git stash pop || echo "No stashed changes"
        git push origin two-files

    - name: Build the Docker image
      run: |
        cd build-push-to-ecr
        docker build -t ${{ steps.bump_version.outputs.new_version }} .

    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: '${{ steps.bump_version.outputs.new_version }}'
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
        path: build-push-to-ecr/trivy-report.txt

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
        IMAGE_TAG=${{ steps.bump_version.outputs.new_version }}
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

    - name: Check VERSION file content
      run: cat VERSION

    - name: Print WorkflowTemplate.yaml before update
      run: cat build-push-to-ecr/WorkflowTemplate.yaml

    - name: Print worldworkflow.yaml before update
      run: cat build-push-to-ecr/worldworkflow.yaml