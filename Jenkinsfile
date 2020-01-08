pipeline {
  agent any
  stages {
    stage('Container Build') {
      parallel {
        stage('Container Build') {
          steps {
            echo 'Building...'
          }
        }
        stage('tng-gtk-vnv') {
          steps {
            sh 'docker build -t registry.sonata-nfv.eu:5000/tng-gtk-vnv .'
          }
        }
      }
    }
    stage('Unit Tests') {
      steps {
        echo 'Unit Testing is on Travis-ci.org'
      }
    }
    stage('Code Style check') {
      steps {
        echo 'Code Style check....'
      }
    }
    stage('Containers Publication') {
      parallel {
        stage('Containers Publication') {
          steps {
            echo 'Publication of containers in local registry....'
          }
        }
        stage('tng-gtk-vnv') {
          steps {
            sh 'docker push registry.sonata-nfv.eu:5000/tng-gtk-vnv'
          }
        }
      }
    }
    stage('Deployment in Integration') {
      parallel {
        stage('Deployment in Integration') {
          steps {
            echo 'Deploying in integration...'
          }
        }
        stage('Deploying') {
          steps {
            sh 'rm -rf tng-devops || true'
            sh 'git clone https://github.com/sonata-nfv/tng-devops.git'
            dir(path: 'tng-devops') {
              sh 'ansible-playbook roles/vnv.yml -i environments -e "target=pre-int-vnv component=gatekeeper host_key_checking=False"'
            }
            
          }
        }
      }
    }
    stage('Smoke Tests') {
      steps {
        echo 'Performing Smoke Tests....'
      }
    }
    stage('Promoting containers to integration env') {
      when {
         branch 'master'
      }
      parallel {
        stage('Publishing containers to int') {
          steps {
            echo 'Promoting containers to integration'
          }
        }
        stage('tng-gtk-vnv') {
          steps {
            sh 'docker tag registry.sonata-nfv.eu:5000/tng-gtk-vnv:latest registry.sonata-nfv.eu:5000/tng-gtk-vnv:int'
            sh 'docker push  registry.sonata-nfv.eu:5000/tng-gtk-vnv:int'
          }
        }
      }
    }
    stage('Promoting release v5.1') {
      when {
        branch 'v5.1'
      }
      stages {
        stage('Generating release') {
          steps {
            sh 'docker tag registry.sonata-nfv.eu:5000/tng-gtk-vnv:latest registry.sonata-nfv.eu:5000/tng-gtk-vnv:v5.1'
            sh 'docker tag registry.sonata-nfv.eu:5000/tng-gtk-vnv:latest sonatanfv/tng-gtk-vnv:v5.1'
            sh 'docker push registry.sonata-nfv.eu:5000/tng-gtk-vnv:v5.1'
            sh 'docker push sonatanfv/tng-gtk-vnv:v5.1'
          }
        }
      }
    }
  }
  post {
    success {
      emailext(subject: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'", body: """<p>SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
                        <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>""", recipientProviders: [[$class: 'DevelopersRecipientProvider']])
      
    }
    
    failure {
      emailext(subject: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'", body: """<p>FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
                        <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>""", recipientProviders: [[$class: 'DevelopersRecipientProvider']])
      
    }
    
  }
}
