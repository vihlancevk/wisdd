pipeline {
    agent any
    tools {
        allure 'allure'
    }

    environment {
        VENV = ".venv"
        ALLURE_RESULTS = "allure-results"
        SONARQUBE = credentials("sonar_token")
        NEXUS_URL = "http://nexus:8081"
    }

    stages {

        stage("Environment Check") {
            steps {
                sh '''
                    echo "Python version:"
                    python3 --version || true
                '''
            }
        }

        stage("Git clone") {
            steps {
                git branch: 'main', url: 'https://github.com/vihlancevk/app-repo.git'
            }
        }

        stage("Setup venv") {
            steps {
                sh '''
                    python3 -m venv ${VENV}
                    . ${VENV}/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements.txt
                    pip install pytest allure-pytest
                '''
            }
        }

        stage("Run tests + Allure results") {
            steps {
                sh '''
                    . ${VENV}/bin/activate
                    pytest --alluredir=${ALLURE_RESULTS}
                '''
            }
            post {
                always {
                    allure includeProperties: false, jdk: '', results: [[path: 'allure-results']]
                }
            }
        }

        stage("SonarQube Analysis") {
            steps {
                withSonarQubeEnv('sonarqube') {
                    script {
                        def scannerHome = tool "sonar-scanner"
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                              -Dsonar.projectKey=python-app \
                              -Dsonar.sources=src \
                              -Dsonar.tests=tests \
                              -Dsonar.exclusions=**/venv/**,**/__pycache__/**,**/allure-*/**,**/*.xml \
                              -Dsonar.host.url=${SONAR_HOST_URL} \
                              -Dsonar.login=${SONARQUBE}
                        """
                    }
                }
            }
        }

        stage("Package artifact") {
            steps {
                sh """
                    mkdir -p dist
                    tar --exclude='*/__pycache__' -czf dist/python-app.tar.gz src requirements.txt run.sh
                """
                archiveArtifacts artifacts: 'dist/python-app.tar.gz', fingerprint: true
            }
        }

        stage("Upload to Nexus") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus_cred', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh '''
                        curl -u ${USER}:${PASS} --upload-file dist/python-app.tar.gz \
                        ${NEXUS_URL}/repository/raw-releases/python-app/python-app.tar.gz
                    '''
                }
            }
        }
    }

    post {
        success { echo "Build OK" }
        failure { echo "Build failed" }
    }
}
