pipeline {
    agent {
        docker {
            image 'ubuntu:24.04'
            args '-u root -v /var/run/docker.sock:/var/run/docker.sock'
            reuseNode true
        }
    }

    stages {

        stage('Environment Check') {
            steps {
                sh '''
                    echo "Running inside Docker agent"
                    cat /etc/os-release
                    uname -a
                '''
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install CI Tools') {
            steps {
                sh '''
                    export DEBIAN_FRONTEND=noninteractive

                    apt-get update

                    apt-get install -y \
                        git \
                        curl \
                        unzip \
                        python3 \
                        python3-pip \
                        docker.io
                '''
            }
        }

        stage('Terraform Validation') {
            steps {
                sh '''
                    curl -fsSL \
                      https://releases.hashicorp.com/terraform/1.12.2/terraform_1.12.2_linux_amd64.zip \
                      -o /tmp/terraform.zip

                    unzip -o /tmp/terraform.zip -d /usr/local/bin

                    terraform version
                    terraform fmt -check -recursive
                    terraform init -backend=false
                    terraform validate
                '''
            }
        }

        stage('Ansible Validation') {
            steps {
                sh '''
                    pip3 install --break-system-packages ansible

                    cd ansible

                    ansible --version
                    ansible-playbook site.yml --syntax-check
                '''
            }
        }

        stage('Docker Check') {
            steps {
                sh '''
                    docker version
                    docker info
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    echo "Building application Docker image..."

                    docker build \
                      -t three-tier-app:${BUILD_NUMBER} \
                      -t three-tier-app:latest \
                      .

                    docker images | grep three-tier-app
                '''
            }
        }

        stage('Docker Test') {
            steps {
                sh '''
                    echo "Starting test container..."

                    docker rm -f three-tier-test 2>/dev/null || true

                    docker run -d \
                      --name three-tier-test \
                      -p 18080:8080 \
                      three-tier-app:${BUILD_NUMBER}

                    sleep 5

                    echo "Testing application..."
                    curl -f http://localhost:18080

                    echo
                    echo "Testing health endpoint..."
                    curl -f http://localhost:18080/health

                    echo
                    echo "Docker test successful!"

                    docker rm -f three-tier-test
                '''
            }
        }
    }

    post {
        success {
            echo 'Docker CI pipeline completed successfully!'
        }

        failure {
            echo 'Docker CI pipeline failed.'
        }

        always {
            sh '''
                docker rm -f three-tier-test 2>/dev/null || true
            '''
        }
    }
}
