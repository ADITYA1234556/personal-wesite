pipeline {
    agent any
     tools {
        git 'Default'  // This refers to the Git installation name configured in Jenkins
    }
    environment {
        DOCKER_IMAGE_FLASK = "adityahub2255/flask-app"
        DOCKER_IMAGE_MYSQL = "adityahub2255/mysql"  // Define MySQL Docker image
        DOCKER_REGISTRY_CREDENTIALS = "dockerhub-creds" // Use your Docker registry credentials
        KUBE_NAMESPACE = "default" // Kubernetes namespace to deploy to
        DOCKER_TAG = "${GIT_COMMIT}" // Tag Docker images with the git commit ID
        KUBE_CONFIG = "/tmp/kubeconfig"
        PROJECT_NAME = "flask-mysql"
        MYEMAIL = credentials('MYEMAIL') // Reference Jenkins credentials
        PASSWORD = credentials('PASSWORD')
    }
    stages {
        stage('Fetch Code') {
            steps {
                // Checkout code from Git repository
                checkout scm
                sh 'ls -l $WORKSPACE'
            }
        }

        stage('Docker compose down'){
            steps{
                script {
                    sh 'docker-compose -f $WORKSPACE/docker-compose-updated.yaml down --remove-orphans'
                }
            }
        }

        stage('Run Docker Compose build') {
            steps {
                script {
                    sh 'envsubst < $WORKSPACE/docker-compose.yaml > $WORKSPACE/docker-compose-updated.yaml'
                    sh 'cat $WORKSPACE/docker-compose-updated.yaml'
                    // Use Docker Compose to build and start the services defined in docker-compose.yaml
                    sh 'docker-compose -f $WORKSPACE/docker-compose-updated.yaml up --build -d'
                }
            }
        }

        stage('Run Docker Compose Up'){
            steps{
                script{
                sh 'docker-compose up -d'
                sh 'sleep 5'
                }
            }
        }

        stage('Build Flask Docker Image') {
            steps {
                script {
                    // Build the Flask Docker image
                    docker.build("${DOCKER_IMAGE_FLASK}:${DOCKER_TAG}", "--build-arg MYEMAIL=${MYEMAIL} --build-arg PASSWORD=${PASSWORD} .")
                }
            }
        }

        stage('Push Docker Images') {
            steps {
                script {
                    // Login to Docker Hub
                    withCredentials([usernamePassword(credentialsId: DOCKER_REGISTRY_CREDENTIALS, usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                    }

                    // Tag the MySQL image with the commit tag before pushing
                    sh "docker tag mysql:8.0 ${DOCKER_IMAGE_MYSQL}:${DOCKER_TAG}"

                    // Push the Flask Docker image to Docker Hub
                    sh "docker push ${DOCKER_IMAGE_FLASK}:${DOCKER_TAG}"

                    // Push the MySQL Docker image to Docker Hub
                    sh "docker push ${DOCKER_IMAGE_MYSQL}:${DOCKER_TAG}"
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                withCredentials([usernamePassword(credentialsId: 'aws-credentials-id',
                                                       usernameVariable: 'AWS_ACCESS_KEY_ID',
                                                       passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {

                    // Set the KUBECONFIG environment variable and apply the Kubernetes manifests
                    sh 'export KUBECONFIG=$KUBE_CONFIG'
                    sh 'KUBECONFIG=$KUBE_CONFIG kubectl config view'
                    sh 'KUBECONFIG=$KUBE_CONFIG kubectl get nodes'

                    sh ' envsubst < $WORKSPACE/mysql-dep.yaml > $WORKSPACE/mysql-deployment-updated.yaml'
                    sh ' envsubst < $WORKSPACE/flask-dep.yaml > $WORKSPACE/flask-deployment-updated.yaml'

                    // Deploy Flask app and MySQL to Kubernetes
                    sh 'KUBECONFIG=$KUBE_CONFIG kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.3/deploy/static/provider/aws/deploy.yaml'
                    sh 'KUBECONFIG=$KUBE_CONFIG kubectl apply -f $WORKSPACE/ingress.yaml'
                    sh 'KUBECONFIG=$KUBE_CONFIG kubectl apply -f $WORKSPACE/persistentvolume.yaml -n ${KUBE_NAMESPACE}'
                    sh 'KUBECONFIG=$KUBE_CONFIG kubectl apply -f $WORKSPACE/persistentvolumeclaim.yaml -n ${KUBE_NAMESPACE}'
                    sh 'KUBECONFIG=$KUBE_CONFIG kubectl apply -f $WORKSPACE/mysql-deployment-updated.yaml -n ${KUBE_NAMESPACE}'
                    sh 'KUBECONFIG=$KUBE_CONFIG kubectl apply -f $WORKSPACE/flask-deployment-updated.yaml -n ${KUBE_NAMESPACE}'
                }
                }
            }
        }
    }
}