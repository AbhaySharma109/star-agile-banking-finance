pipeline {
  agent any
  environment {
    TF_IN_AUTOMATION = 'true'
    AWS_SHARED_CREDENTIALS_FILE='/root/.aws/credentials'
  }

  stages {
    stage ("github clone") {
      steps{
        git url: "https://github.com/AbhaySharma109/star-agile-banking-finance.git", branch: "master"
      }
    }

    stage ("Maven build"){
      steps {
        script{
          sh 'mvn clean package'
        }
      }
    }

    stage ("Build docker image"){
      steps{
        script{
          sh 'docker build -t abhay123321/staragileprojectfinance:v1'
          sh 'docker images'
        }
      }
    }

    stage('Docker login'){
      steps{
        withCredentials([usernamePassword(credentialsId: 'dockerhub-pwd', passwordVariable: 'USER')]){
          sh "echo $PASS | docker login -u $USER --password-stdin:
          sh "docker push abhay123321/staragileprojectfinance:v1"
        }
      }
    }
    
    stage('Init TF') {
      steps {
        sh '''
          ls -al
          sed -i "s|/home/dungpham/.aws/credentials|/root/.aws/credentials|g" main.tf
          cat main.tf
          terraform init
        '''
      }
    }

    stage('Plan TF') {
      steps {
        sh '''
          terraform plan
        '''
      }
    }

    stage('Validate TF') {
      input {
        message "Do you want to apply this Plan?"
        ok "Apply Plan"
      }
      steps {
        echo 'Plan Accepted'
      }
    }

    stage('Apply TF') {
      steps {
        sh '''
          terraform apply -auto-approve
        '''
      }
    }

    stage('Print Inventory') {
      steps {
        sh '''
          echo $(terraform output -json ec2_public_ip) | awk -F'"' '{print $2}' > aws_hosts
          cat aws_hosts
        '''
      }
    }

    stage('Wait EC2') {
      steps {
        sh '''
          aws ec2 wait instance-status-ok --region ap-southeast-1 --instance-ids `$(terraform output -json ec2_id_test) | awk -F'"' '{print $2}'`
        '''
      }
    }

    stage('Validate Ansible') {
      input {
        message "Do you want to run Ansible Playbook?"
        ok "Run Ansible"
      }
      steps {
        echo "Ansible Accepted"
      }
    }

    stage('Run Ansible') {
      steps {
        ansiblePlaybook(credentialsId: 'ec2.ssh.key	', inventory: 'aws_hosts', playbook: 'ansible/docker.yml')
      }
    }

    stage('Validate Destroy') {
      input {
        message "Do you want to destroy Terraform Infra?"
        ok "Destroy"
      }
      steps {
        echo "Destroy Accepted"
      }
    }

    stage('Destroy TF') {
      steps {
        sh '''
          terraform destroy -auto-approve
        '''
      }
    }
  }
}
