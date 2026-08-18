pipeline {

 agent {
    docker {
        image 'ubuntu:24.04'
        args '''
          --network host
          -u root
          -v /var/run/docker.sock:/var/run/docker.sock
          -v /usr/local/bin/minikube:/usr/local/bin/minikube:ro
          -v /usr/local/bin/helm:/usr/local/bin/helm:ro
          -v /snap/bin/kubectl:/usr/local/bin/kubectl:ro
          -v /var/lib/jenkins/.kube:/root/.kube:ro
          -v /home/ubuntu/.minikube:/home/ubuntu/.minikube:ro
        '''
        reuseNode true
        }
      }

    environment {
        APP_NAME = 'three-tier-app'
        HELM_RELEASE = 'three-tier-app'
        HELM_CHART = './three-tier-chart'
        IMAGE_TAG = "${BUILD_NUMBER}"
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

        stage('Install Terraform') {
            steps {
                sh '''
                    curl -fsSL \
                      https://releases.hashicorp.com/terraform/1.12.2/terraform_1.12.2_linux_amd64.zip \
                      -o /tmp/terraform.zip

                    unzip -o /tmp/terraform.zip -d /usr/local/bin

                    terraform version
                '''
            }
        }

        stage('Terraform Validation') {
            steps {
                sh '''
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
                    echo "Building application image..."

                    docker build \
                      -t ${APP_NAME}:${IMAGE_TAG} \
                      -t ${APP_NAME}:latest \
                      .

                    docker images | grep ${APP_NAME}
                '''
            }
        }

        
        stage('Docker Test') {
          steps {
             sh '''
               set -e

               echo "Starting application test container..."
  
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

               echo "Testing application from inside container..."
 
                docker exec three-tier-test \
                python3 -c "import urllib.request; print(urllib.request.urlopen('http://localhost:8080/health').read().decode())"

               echo "Application health check passed!"

              echo "Testing root endpoint..."

              docker exec three-tier-test \
                python3 -c "import urllib.request; print(urllib.request.urlopen('http://localhost:8080/').read().decode())"

              echo "Application test passed!"
            '''
         }
     }

        stage('Helm Validation') {
            steps {
                sh '''
                    echo "Validating Helm chart..."

                    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
                      | bash

                    helm version
                    helm lint ${HELM_CHART}
                    helm template ${HELM_RELEASE} ${HELM_CHART}
                '''
            }
        }

        stage('Load Image into Minikube') {
             steps {
               sh '''
                 set -e

                   echo "Loading image into Minikube..."

                   export MINIKUBE_HOME=/home/ubuntu/.minikube

                   minikube status

                   minikube image load ${APP_NAME}:${IMAGE_TAG}

                    echo "Image loaded successfully!"
               '''
          }
       }

       stage('Helm Deploy') {
    steps {
        sh '''
            set -e

            export KUBECONFIG=/root/.kube/config
            export MINIKUBE_HOME=/home/ubuntu/.minikube

            echo "Deploying application with Helm..."

            helm upgrade --install ${HELM_RELEASE} ${HELM_CHART} \
              --set image.repository=${APP_NAME} \
              --set image.tag=${IMAGE_TAG} \
              --set image.pullPolicy=Never

            helm list

            kubectl get pods
            kubectl get svc
        '''
    }
  }
        stage('Kubernetes Verification') {
            steps {
                sh '''
                    echo "Checking Kubernetes deployment..."

                    kubectl get deployment
                    kubectl get pods
                    kubectl get svc
                    kubectl get ingress

                    echo "Waiting for application..."

                    sleep 10

                    kubectl get pods
                '''
            }
        }

        stage('Application Health Check') {
            steps {
                sh '''
                    set -e

                    MINIKUBE_IP=$(minikube ip)

                    echo "Testing Kubernetes application..."

                    curl -f \
                      -H "Host: three-tier.local" \
                      http://${MINIKUBE_IP}/health

                    echo
                    echo "Kubernetes health check PASSED!"
                '''
            }
        }
    }

    post {

        success {
            echo '======================================'
            echo 'CI/CD PIPELINE COMPLETED SUCCESSFULLY'
            echo '======================================'
        }

        failure {
            echo '======================================'
            echo 'CI/CD PIPELINE FAILED'
            echo '======================================'
        }

        always {
            sh '''
                docker rm -f three-tier-test 2>/dev/null || true
            '''
        }
    }
}
