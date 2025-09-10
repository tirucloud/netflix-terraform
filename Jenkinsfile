pipeline {
    agent any
    
     tools {
        maven 'maven3'
        jdk 'jdk17'
    }
    environment { 
        SCANNER_HOME= tool 'sonar-scanner' 
    }

    stages {
        stage('Git ChekOut') {
            steps {
                git branch: 'main', changelog: false, credentialsId: 'git-cred', poll: false, url: 'https://github.com/tirucloud/Terraform-Script-Swiggy.git'
            }
        }
        stage('Compile') {
            steps {
            sh  "mvn compile"
            }
        }
        stage("Sonarqube Analysis "){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=javaapp \
                    -Dsonar.projectKey=javaapp '''
                }
            }
        }
        stage("quality gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
                }
            }
        }
         stage('Package') {
            steps {
                sh "mvn package"
            }
        }
         stage('Publish Artifacts') {
            steps {
                withMaven(globalMavenSettingsConfig: 'maven-settings', jdk: 'jdk17', maven: 'maven3', mavenSettingsConfig: '', traceability: true) {
                    sh "mvn deploy"
                }
            }
         }
    }
}