jenkins:
    systemMessage: "Pay Theory Build Server"
    numExecutors: 0
    agentProtocols:
        - "JNLP4-connect"
    securityRealm:
        local:
            allowsSignup: false
            users:
                - id: ecsuser
                  password: \$${ADMIN_PWD}
    authorizationStrategy:
        globalMatrix:
            grantedPermissions:
                - "Overall/Read:authenticated"
                - "Job/Read:authenticated"
                - "View/Read:authenticated"
                - "Overall/Administer:authenticated"
    crumbIssuer: "standard"
    slaveAgentPort: 50000
    clouds:
        - ecs:
              numExecutors: 1
              allowedOverrides: "inheritFrom,label,memory,cpu,image"
              credentialsId: ""
              cluster: ${ecs_cluster_fargate_spot}
              name: "fargate-cloud-spot"
              regionName: ${cluster_region}
              retentionTimeout: 10
              jenkinsUrl: "http://${jenkins_cloud_map_name}:${jenkins_controller_port}"
              templates:
                  - cpu: "512"
                    image: "805600764437.dkr.ecr.us-east-1.amazonaws.com/inbound-agent-repository:latest"
                    label: "build-example-spot"
                    executionRole: ${execution_role_arn}
                    launchType: "FARGATE"
                    memory: 0
                    memoryReservation: 1024
                    networkMode: "awsvpc"
                    privileged: false
                    remoteFSRoot: "/home/jenkins"
                    securityGroups: ${agent_security_groups}
                    sharedMemorySize: 0
                    subnets: ${subnets}
                    templateName: "build-example"
                    uniqueRemoteFSRoot: false
        - ecs:
              numExecutors: 1
              allowedOverrides: "inheritFrom,label,memory,cpu,image"
              credentialsId: ""
              cluster: ${ecs_cluster_fargate}
              name: "fargate-cloud"
              regionName: ${cluster_region}
              retentionTimeout: 10
              jenkinsUrl: "http://${jenkins_cloud_map_name}:${jenkins_controller_port}"
              templates:
                  - cpu: "512"
                    image: "jenkins/inbound-agent:latest-alpine-jdk21"
                    label: "build-example"
                    executionRole: ${execution_role_arn}
                    launchType: "FARGATE"
                    memory: 0
                    memoryReservation: 1024
                    networkMode: "awsvpc"
                    privileged: false
                    remoteFSRoot: "/home/jenkins"
                    securityGroups: ${agent_security_groups}
                    sharedMemorySize: 0
                    subnets: ${subnets}
                    templateName: "build-example"
                    uniqueRemoteFSRoot: false
security:
  sSHD:
    port: -1
jobs:
  - script: >
      pipelineJob('Simple job critical task') {
        definition {
          cps {
            script('''
              pipeline {
                  agent {
                      ecs {
                          inheritFrom 'build-example'
                      }
                  }
                  stages {
                    stage('Test') {
                        steps {
                            script {
                                sh "echo this was executed on non spot instance"
                            }
                            sh 'sleep 120'
                            sh 'echo sleep is done'
                        }
                    }
                  }
              }'''.stripIndent())
              sandbox()
          }
        }
      }
  - script: >
      pipelineJob('Simple job non critical task') {
        definition {
          cps {
            script('''
              pipeline {
                  agent {
                      ecs {
                          inheritFrom 'build-example-spot'
                      }
                  }
                  stages {
                    stage('Test') {
                        steps {
                            script {
                                sh "echo this was executed on a spot instance"
                            }
                            sh 'sleep 120'
                            sh 'echo sleep is done'
                        }
                    }
                  }
              }'''.stripIndent())
              sandbox()
          }
        }
      }
