pipeline {
    agent {
        docker {
            image 'ubuntu:24.04'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
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
                    apt-get update
                    apt-get install -y \
                        git \
                        curl \
                        unzip \
                        python3 \
                        python3-pip
                '''
            }
        }

        stage('Terraform Validation') {
            steps {
                sh '''
                    curl -fsSL https://releases.hashicorp.com/terraform/1.12.2/terraform_1.12.2_linux_amd64.zip -o /tmp/terraform.zip
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
                    apt-get install -y docker.io
                    docker version
                '''
            }
        }
    }

    post {
        success {
            echo 'Docker-agent CI pipeline completed successfully!'
        }

        failure {
            echo 'Docker-agent CI pipeline failed.'
        }
    }
}
