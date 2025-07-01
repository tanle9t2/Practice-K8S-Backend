pipeline {
    agent any

    environment {
        CI = true
        SCANNER_HOME = tool 'sonar-scanner'
        IMAGE_NAME = "tanle92/backend"
        BRANCH = "main"
        REPO = 'https://github.com/tanle9t2/Practice-K8s.git'
    }

    stages {
        stage("Checkout") {
            steps {
                git branch: env.BRANCH, url: env.REPO
            }
        }
        stage("OWASP Scan") {
            steps {
                dependencyCheck additionalArguments: '--scan ./', odcInstallation: 'DP'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage("Sonarqube Check"){
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''
                    $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=backend-spring-boot \
                    -Dsonar.java.binaries=. \
                    -Dsonar.projectKey=backend-spring-boot
                '''
                }
            }
        }

        stage('Set Commit-Based Tag') {
            steps {
                script {
                    def commit = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    env.IMAGE_TAG = "main-${commit}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} springboot-backend/"
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                withDockerRegistry(credentialsId: 'dockerhub', url: 'https://index.docker.io/v1/') {
                    sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                }


            }
        }
    }
    post {
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed.'
        }
    }
}