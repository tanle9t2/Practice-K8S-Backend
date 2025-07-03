pipeline {
    agent any
    tools {

    }
    environment {
        CI = true
        SCANNER_HOME = tool 'sonar-scanner'
        IMAGE_NAME = "tanle92/backend"
        BRANCH = "main"
        REPO = 'https://github.com/tanle9t2/Practice-K8S-Backend.git'
        REPO_CONFIG = 'https://github.com/tanle9t2/Practice-K8S-Backend-Config.git'
    }

    stages {
        stage("Checkout") {
            steps {
                git branch: env.BRANCH, url: env.REPO
            }
        }
        stage("Sonarqube Check") {
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
        stage('Detect Changes') {
            steps {
                script {
                    def changedFiles = sh(
                            script: "git diff --name-only HEAD~1 HEAD",
                            returnStdout: true
                    ).trim()
                    if (changedFiles.readLines().any { it.startsWith('src/') }) {
                        env.RUN_PIPELINE = "true"
                    } else {
                        env.RUN_PIPELINE = "false"
                    }
                    echo "Different: ${RUN_PIPELINE}"
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
                    if (env.RUN_PIPELINE) {
                        sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                    }
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                withDockerRegistry(credentialsId: 'dockerhub', url: 'https://index.docker.io/v1/') {
                    script {
                        if (env.RUN_PIPELINE) {
                            sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                        }
                    }
                }


            }
        }


        stage("Update Manifest") {
            steps {
                script {
                    if (env.RUN_PIPELINE) {
                        echo 'Updating K8s Manifest'
                        sshagent(credentials: ['github-ssh-key']) {
                            sh '''
                                rm -rf Practice-K8S-Backend-Config

                                git config --global user.name "tanle9t2"
                                git config --global user.email "fcletan12@gmail.com"
        
                                mkdir -p ~/.ssh
                                ssh-keyscan github.com >> ~/.ssh/known_hosts
        
                                git clone git@github.com:tanle9t2/Practice-K8S-Backend-Config.git
        
                                cd Practice-K8S-Backend-Config
                                sed -i "s|tag: .*|tag: ${IMAGE_TAG}|" helm/values.yaml
                                git add helm/values.yaml
                                git commit -m "Update image tag to ${IMAGE_TAG}" || true
                                git push origin main
                            '''
                        }
                    }
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