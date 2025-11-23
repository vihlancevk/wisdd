pipeline {
    agent any

    environment {
        NEXUS_URL = "http://nexus:8081"
        NEXUS_CREDENTIALS_ID = "nexus_cred"
        ARTIFACT = "python-app.tar.gz"
        ANSIBLE_REPO = "https://github.com/vihlancevk/infra-repo.git"
        SSH_KEY = "ansible_ssh_key"
    }

    stages {

        stage("Download from Nexus") {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: NEXUS_CREDENTIALS_ID, usernameVariable: 'USER', passwordVariable: 'PASS')
                ]) {
                    sh '''
                        mkdir -p artifacts
                        curl -u ${USER}:${PASS} -o artifacts/${ARTIFACT} \
                        ${NEXUS_URL}/repository/raw-releases/python-app/${ARTIFACT}
                    '''
                }
            }
        }

        stage("Git clone ansible") {
            steps {
                git branch: 'main', url: ANSIBLE_REPO
            }
        }

        stage("Run ansible") {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: SSH_KEY, keyFileVariable: 'KEY', usernameVariable: 'USER')]) {
                    sh '''
                        export ANSIBLE_PRIVATE_KEY_FILE=${KEY}
                        ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/deploy_app.yml \
                        --extra-vars "artifact_path=$(pwd)/artifacts/${ARTIFACT}"
                    '''
                }
            }
        }
    }
}
