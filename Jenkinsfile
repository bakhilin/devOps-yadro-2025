@Library('jenkins-shared-library') _
import org.currency.DockerUtils

node('built-in'){
    try {   
        if (env.BRANCH_NAME == 'master' || env.BRANCH_NAME.startsWith('n.bakhilin')) {
            def dockerUsername = 'bakhilin'
            def dockerImageTag = '0.1.1'
            def dockerImageName = "${dockerUsername}/currency-rest-api"
            def buildSuccess = true
            def dockerUtils = new DockerUtils(this)
        
            stage('CLONE repo') {
                buildSuccess = pipeline_utils.errorHandler(STAGE_NAME){
                    checkout scm
                }
            }

            stage('LINT dockerfile') {
                def linter = 'hadolint/hadolint'
                def tag = 'latest'
                def flags = ''
                def command = '< Dockerfile'
                pipeline_utils.lint(linter, tag, flags, command)
            }

            stage('BUILD Docker Image') {
                if (buildSuccess) {
                    buildSuccess = pipeline_utils.errorHandler(STAGE_NAME){
                        dockerUtils.buildImage(dockerImageName, dockerImageTag)
                    }
                }
            }

            stage('SCAN and LOGIN') {
                parallel(
                    'SCAN image by Trivy': {
                        dockerUtils.scanImageTrivy(dockerImageName, dockerImageTag)
                    }, 
                    'Login to Docker Hub': {
                        if (buildSuccess) {
                            buildSuccess = pipeline_utils.errorHandler(STAGE_NAME) {
                                dockerUtils.loginToDockerHub('docker-hub-credentials')
                            }
                        }
                    }
                )
            }

            stage('DEPLOY and DELETE') {
                parallel(
                    'DEPLOY Docker Image': {
                        if (buildSuccess || currentBuild.result == null || currentBuild.result == 'SUCCESS') {
                            buildSuccess = pipeline_utils.errorHandler(STAGE_NAME) {
                                dockerUtils.pushImageDockerHub(dockerImageName, dockerImageTag)
                            }   
                        }                        
                    },
                    'DELETE bad images': {
                        pipeline_utils.errorHandler(STAGE_NAME){
                            dockerUtils.deleteImages()
                        }
                    }
                )
            }
            // if (env.BRANCH_NAME == 'master') 
            stage('DEPLOY to K8s') {
                def chart_version = "0.1.0"
                def chart_name = "currency-api"
                withCredentials([file(credentialsId: 'k8s-config', variable: 'KUBECONFIG')]) {
                    sh """
                        helm uninstall ${chart_name} -n ${dockerUsername} --wait
                        
                        helm install ${chart_name} \
                            oci://registry-1.docker.io/${dockerUsername}/${chart_name} \
                            --version ${chart_version} \
                            --namespace ${dockerUsername}
                    """
                }
            }
        } else {
            echo "Branch name not started with n.bakhilin or master, your: ${env.BRANCH_NAME}"
        }
    } catch(err) {
        echo "Caught: ${err}"
    } finally {
        pipeline_utils.logBuildInfo()
    }
}

