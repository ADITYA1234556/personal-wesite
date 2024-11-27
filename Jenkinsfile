pipeline {
    agent any
     tools {
        git 'Default'  // This refers to the Git installation name configured in Jenkins
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
                    sh 'docker-compose down --remove-orphans'
                }
            }
        }

        stage('Run Docker Compose build') {
            steps {
                script {
                    // Use Docker Compose to build and start the services defined in docker-compose.yaml
                    sh 'docker-compose -f $WORKSPACE/docker-compose.yaml up --build -d'
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
    }
}