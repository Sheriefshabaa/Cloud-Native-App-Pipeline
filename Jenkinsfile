pipeline {
  agent any

  environment {
    AWS_ACCOUNT_ID = "058264315018"
    AWS_ACCESS_KEY_ID = credentials('aws_access_key')
    AWS_SECRET_ACCESS_KEY = credentials('aws_secret_key')
    AWS_DEFAULT_REGION = "eu-west-1"
   
    ECR_BACKEND_REPO = "h-project-ecr-backend-image"
    ECR_FRONTEND_REPO = "h-project-ecr-frontend-image"
    BACKEND_REPO_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_BACKEND_NAME}"
    FRONTEND_REPO_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_FRONTEND_NAME}"
    IMAGE_TAG = "${BUILD_NUMBER}"

    GIT_USERNAME = "Hesham-14"
    GIT_REPO = "Cloud-Native-App-Pipeline"

    EKS_NAME = "h-project-eks-cluster"
  }

  stages {
    
    stage('Logging into AWS ECR') {
      steps {
        sh "echo Welcome To Cloud-Native-App Pipeline"
        sh "STAGE 1: Loging into AWS..."
        sh "aws ecr get-login-password --region ${env.AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
      }
    }

    stage('Building & pushing images') {
      steps {
        sh "STAGE 2: Building & pushing images..."
        script {
          dir('app/backend') {
            sh "docker build -t ${env.BACKEND_REPO_URL}:${env.IMAGE_TAG} ."
            sh "docker push ${env.BACKEND_REPO_URL}:${env.IMAGE_TAG}" 
          }
          dir('app/frontend') {
            sh "docker build -t ${env.FRONTEND_REPO_URL}:${env.IMAGE_TAG} ."
            sh "docker push ${env.FRONTEND_REPO_URL}:${env.IMAGE_TAG}" 
          }
        }
      }
    }

    stage('Update deployment file') {
      steps {
        withCredentials([string(credentialsId: 'GITHUB_TOKEN', variable: 'GITHUB_TOKEN')]) {

          sh "STAGE 3: Update deployment files..."

          sh "git remote set-url origin hhtps://${env.GIT_USERNAME}:${GITHUB_TOKEN}@github.com/${env.GIT_USERNAME}/${env.GIT_REPO}.git/"
          sh "git config user.email jenkins@gmail.com"
          sh "git config user.name jenkins"

          sh "sed -i 's|image:.*|image: ${env.BACKEND_REPO_URL}:${env.IMAGE_TAG}|g' ./k8s/backend-deployment.yaml"
          sh "sed -i 's|image:.*|image: ${env.FRONTEND_REPO_URL}:${env.IMAGE_TAG}|g' ./k8s/frontend-deployment.yaml"

          sh "git add ."
          sh "git commit -m 'Update deployment image to version ${env.IMAGE_TAG}'"
          sh "git push origin HEAD:main"
        }
      }
    }

    // stage('Applying deployments'){
    //   steps{
    //     sh "STAGE 4: Update deployment files..."
    //     sh "chmod +x ./k8s/k8s.sh"
    //     sh "aws eks update-kubeconfig --region ${env.AWS_DEFAULT_REGION} --name 4{env.EKS_NAME}"
    //     sh "./k8s/k8s.sh"
    //   }
    // }
  }
}
