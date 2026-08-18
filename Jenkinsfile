pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Format Check') {
            steps {
                sh 'terraform fmt -check -recursive'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform init -backend=false'
                sh 'terraform validate'
            }
        }

        stage('Ansible Syntax Check') {
            steps {
                sh '''
                    cd ansible
                    ansible-playbook site.yml --syntax-check
                '''
            }
        }
    }

    post {
        success {
            echo 'CI validation completed successfully!'
        }

        failure {
            echo 'CI validation failed.'
        }
    }
}
