#!/usr/bin/env groovy

def defaultBobImage = 'armdocker.rnd.ericsson.se/proj-adp-cicd-drop/bob.2.0:latest'
def bob = new BobCommand()
    .bobImage(defaultBobImage)
    .envVars([
        HELM_REPO_TOKEN:'${HELM_REPO_TOKEN}',
        HOME:'/home/cbrsciadm',
        RELEASE:'${RELEASE}',
        KUBECONFIG:'${KUBECONFIG}',
        SITE_VALUES:'${SITE_VALUES}',
        USER:'${USER}',
		XRAY_USER:'${CREDENTIALS_XRAY_SELI_ARTIFACTORY_USR}',
        XRAY_TOKEN:'${CREDENTIALS_XRAY_SELI_ARTIFACTORY_PSW}',
		SERO_PASSWORD:'${SERO_PASSWORD}'
    ])
    .needDockerSocket(true)
    .toString()	
def LOCKABLE_RESOURCE_LABEL = "kaas"

pipeline {
    agent {
		node {
			label "RHEL7_GE_Dock_2"
		}
    }

    options {
        timestamps() 
        timeout(time: 60, unit: 'MINUTES')
    }

    environment {
        RELEASE = "false"
        KUBECONFIG = "${WORKSPACE}/.kube/config"
        SITE_VALUES = "${WORKSPACE}/k8s-test/hahn166_site-values.yaml"
		CREDENTIALS_XRAY_SELI_ARTIFACTORY = credentials('OSSCNCI')
    }

    stages {
        stage('Clean') {
            steps {
                archiveArtifacts allowEmptyArchive: true, artifacts: 'ruleset2.0.yaml, precodereview.Jenkinsfile'
                sh "${bob} clean"
            }
        }

        stage('Init') {
            steps {
                sh "${bob} init-precodereview"
				sh "${bob} lint:create_dir"
                script {
                    authorName = sh(returnStdout: true, script: 'git show -s --pretty=%an')
                    currentBuild.displayName = currentBuild.displayName + ' / ' + authorName
					stash includes: "*", name: "ruleset2.0.yaml", allowEmpty: true
                }
            }
        }

        stage('Lint') {
            steps {
                parallel(
                    "lint helm": {
                        sh "${bob} lint:helm"
                    },
                    "lint helm design rule checker": {
                        sh "${bob} lint:helm-chart-check"
                    }
                )
            }
            post {
                always {
                    archiveArtifacts allowEmptyArchive: true, artifacts: 'Design_Rules/design-rule-check-report.*'
                }
            }
        }

        stage('Image') {
            steps {
		withCredentials([usernamePassword(credentialsId: 'SERO_Artifactory', usernameVariable: 'SERO_USER', passwordVariable: 'SERO_PASSWORD')]) {
                sh "${bob} image"
                sh "${bob} image-dr-check"
            }
		}
            post {
                always {
                    archiveArtifacts allowEmptyArchive: true, artifacts: 'Design_Rules/check-image/image-design-rule-check-report.*, Design_Rules/check-init-image/image-design-rule-check-report.*'
                }
            }
        }

        stage('Package') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'CBRSCIADM', variable: 'HELM_REPO_TOKEN')]) {
                        sh "${bob} package"
                    }
                }
            }
        }

 stage('K8S Resource Lock') {
			options {
                lock(label: LOCKABLE_RESOURCE_LABEL, variable: 'RESOURCE_NAME', quantity: 1)
            }
			environment {
                // RESOURCE_NAME = hahn166_namespace2
                K8S_CONFIG_FILE_ID = sh(script: "echo \${RESOURCE_NAME} | cut -d'_' -f1", returnStdout: true).trim()
                // K8S_CONFIG_FILE_ID = hahn166
            }
            stages {
				stage('Vulnerability Analysis and K8S Test'){
					parallel{
					stage('K8S Test'){
						stages{
							stage('Helm Install') {
								steps {
									echo "Inject kubernetes config file (${env.K8S_CONFIG_FILE_ID}) based on the Lockable Resource name: ${env.RESOURCE_NAME}"
									configFileProvider([configFile(fileId: "${K8S_CONFIG_FILE_ID}", targetLocation: "${env.KUBECONFIG}")]) {
										sh "${bob} helm-dry-run"
										sh "${bob} create-namespace"
										sh "${bob} helm-install"
										sh "${bob} healthcheck"
										sh "${bob} networkcheck"
									}
								}
								post {
									failure {
										sh "${bob} collect-k8s-logs || true"
										archiveArtifacts allowEmptyArchive: true, artifacts: 'k8s-logs/**/*.*'
										sh "${bob} delete-namespace"
									}
								}
							}
							stage('K8S Test') {
								steps {
									echo 'sh "${bob} helm-test"'
								}
								post {
									failure {
										sh "${bob} collect-k8s-logs || true"
										archiveArtifacts allowEmptyArchive: true, artifacts: 'k8s-logs/**/*.*'
									}
								}
							}
							stage('Kubehunter') {
								steps {
									//configFileProvider([configFile(fileId: "kubehunter_config.yaml", targetLocation: "${env.WORKSPACE}/config/")]) {}
									sh "${bob} kube-hunter"
									archiveArtifacts "build/kubehunter-report/**/*"
								}
								post{
									cleanup{
										sh "${bob} delete-namespace"
									}
								}
							}
						}
					}

					stage('Kubeaudit') {
						steps {
						  //configFileProvider([configFile(fileId: "kubeaudit_config.yaml", targetLocation: "${env.WORKSPACE}/config/")]) {}
						  sh "${bob} kube-audit"
						  archiveArtifacts 'build/kube-audit-report/**/*'
						}
					}
					stage('Kubesec') {
						steps {
						  //configFileProvider([configFile(fileId: "kubesec_config.yaml", targetLocation: "${env.WORKSPACE}/config/")]) {}
						  sh "${bob} kube-sec"
						  archiveArtifacts 'build/kubesec-reports/**/*'
						}
					}
					stage('trivy') {
						steps {
						  sh "${bob} trivy-inline-scan"
						  archiveArtifacts 'build/trivy-reports/**.*'
						  archiveArtifacts 'build/trivy-reports/trivy_metadata.properties'
						}
					}
					stage('Hadolint') {
						steps {
							//configFileProvider([configFile(fileId: "hadolint_config.yaml", targetLocation: "${env.WORKSPACE}/config/")]) {}
							sh "${bob} hadolint-scan"
							archiveArtifacts "build/hadolint-scan/**.*"
						}
					}
					stage('Anchore-Grype and X-Ray'){
						stages{
							stage('Anchore-Grype') {
								steps {
									sh "${bob} anchore-grype-scan"
									archiveArtifacts 'build/anchore-reports/**.*'
								}
							}
							stage('X-Ray'){
								steps{
									sleep(120)
									sh "${bob} fetch-xray-report"
									archiveArtifacts 'build/xray-reports/xray_report.json'
									archiveArtifacts 'build/xray-reports/raw_xray_report.json'
								}
							}
						}
					}	
				}
				}
				stage('Generate Vulnerability report V2.0'){
                            steps {
                                sh "${bob} generate-VA-report-V2:no-upload"
                            }
                        }
            }
		}
    }
    post {
        always {
			script {
				sh "${bob} cleanup-trivy-anchore-images"
                sh '''
					git clone ssh://gerrit-gamma.gic.ericsson.se:29418/adp-fw/adp-fw-templates
                    cd adp-fw-templates
                    cp ../Vulnerability_Report_2.0.md .
                    git submodule update --init --recursive
                    sed -i s#user-guide-template/user_guide_template.md#Vulnerability_Report_2.0.md#g marketplace-config.yaml
                '''
                dir("adp-fw-templates"){
                    unstash "ruleset2.0.yaml"
                }
                sh "cd adp-fw-templates;${bob} clean-report init-report"
                sh "cd adp-fw-templates;${bob} generate-docs"
				sh '''
                    cd adp-fw-templates
                    mv ../Vulnerability_Report_2.0.md ../Vulnerability_Report/Vulnerability_Report_2.0.md
					mv pdf/user-guide-template/Vulnerability_Report_2.0.pdf ../Vulnerability_Report/pdf/Vulnerability_Report_2.0.pdf
					mv html/user-guide-template/Vulnerability_Report_2.0.html ../Vulnerability_Report/html/Vulnerability_Report_2.0.html 
                '''
				

                archiveArtifacts artifacts: 'Vulnerability_Report_2.0.md', allowEmptyArchive: true
                archiveArtifacts artifacts: 'Vulnerability_Report/**/*', allowEmptyArchive: true
                archiveArtifacts artifacts: 'Vulnerability_Report/**/*', allowEmptyArchive: true
            }
			deleteDir()
        }
		failure{
			deleteDir()
		}
    }
}

// More about @Builder: http://mrhaki.blogspot.com/2014/05/groovy-goodness-use-builder-ast.html
import groovy.transform.builder.Builder
import groovy.transform.builder.SimpleStrategy

@Builder(builderStrategy = SimpleStrategy, prefix = '')
class BobCommand {

    def bobImage = 'bob.2.0:latest'
    def envVars = [:]

    def needDockerSocket = false

    String toString() {
        def env = envVars
                .collect({ entry -> "-e ${entry.key}=\"${entry.value}\"" })
                .join(' ')

        def cmd = """\
            |docker run
            |--init
            |--rm
            |--workdir \${PWD}
            |--user \$(id -u):\$(id -g)
            |-v \${PWD}:\${PWD}
            |-v /etc/group:/etc/group:ro
            |-v /etc/passwd:/etc/passwd:ro
            |-v \${HOME}:\${HOME}
            |${needDockerSocket ? '-v /var/run/docker.sock:/var/run/docker.sock' : ''}
            |${env}
            |\$(for group in \$(id -G); do printf ' --group-add %s' "\$group"; done)
            |--group-add \$(stat -c '%g' /var/run/docker.sock)
            |${bobImage}
            |"""
        return cmd
                .stripMargin()           // remove indentation
                .replace('\n', ' ')      // join lines
                .replaceAll(/[ ]+/, ' ') // replace multiple spaces by one
    }
}
