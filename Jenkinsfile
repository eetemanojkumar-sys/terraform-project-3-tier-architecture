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
                    echo "Checking Docker..."

                    docker version

                    docker info
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    set -e

                    echo "Building application Docker image..."

                    docker build \
                        -t three-tier-app:${BUILD_NUMBER} \
                        -t three-tier-app:latest \
                        .

                    echo "Docker images created:"

                    docker images | grep three-tier-app
                '''
            }
        }

        stage('Docker Test') {
            steps {
                sh '''
                    set -e

                    echo "Starting test container..."

                    docker rm -f three-tier-test 2>/dev/null || true

                    docker run -d \
                        --name three-tier-test \
                        -p 18080:8080 \
                        three-tier-app:${BUILD_NUMBER}

                    echo "Waiting for application..."

                    sleep 5

                    echo "Container status:"

                    docker ps

                    echo "Container logs:"

                    docker logs three-tier-test

                    echo "Testing application inside container..."

                    docker exec three-tier-test \
                        python3 -c "import urllib.request; print(urllib.request.urlopen('http://localhost:8080').read().decode())"

                    echo "Testing health endpoint..."

                    docker exec three-tier-test \
                        python3 -c "import urllib.request; print(urllib.request.urlopen('http://localhost:8080/health').read().decode())"

                    echo "Docker application test passed!"
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
