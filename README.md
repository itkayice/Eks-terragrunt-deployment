# Sample-go-app deployed to EKS cluster using Terraform and Gitlab

Deploy GO application to EKS using Terraform and Gitlab

## Getting started

Deploy app & infra from local system.

**Pre-requiste:**

1. AWS Account
2. Create IAM user with administrator access policy and download its access key and secret key.
4. Docker, Kubectl, Terraform & Terragrunt installed on local system.
5. Install `base-iam-authenticator` on your local system


**Setup Infrastructure:**

1. Setup AWS CLI on local system with access key and secret key
2. Go to `infrastructure` directory and configure `profile` and `region` local variables in `terragrunt.hcl` file.
3. Initialize terragrunt setup with command `terragrunt init` (This initiates terraform S3 & dynamo db backend creation)
4. Once `terragrunt init` command is executed without any error then run `terragrunt plan`
5. Finally run `terragrunt apply` command to deploy infrastructure. (This will create vpc, security groups and eks cluster in AWS account)

Once the infra is ready you can proceed to creating and deploying application.

First connect to EKS cluster using command
`aws eks --region us-west-2 update-kubeconfig --name test-cluster-QVFPpWtx --profile default-borngreat-aws-account`
then follow below steps to build and deploy application.


**Setup/Deploy Go App:**

1. Build Docker image and push it to ECR repo (ECR repo link can be found in outputs of terragrunt)
  - `aws ecr get-login-password --profile default-borngreat-aws-account | docker login --username AWS --password-stdin 944365771232.dkr.ecr.us-west-2.amazonaws.com/go-app-repo`
  - `cd docker-gs-ping`
  - `docker build -t 944365771232.dkr.ecr.us-west-2.amazonaws.com/go-app-repo:latest .`
  - `docker push 944365771232.dkr.ecr.us-west-2.amazonaws.com/go-app-repo:latest`
2. Deploy application and service using helm
  - `cd helm-charts`
  - `helm install sample-go-app sample-go-app`

Note: For first time helm project you can create sample project/files using command `helm create sample-go-app`.

**Create Gitlab pipeline**

1. Create gitlab repository
2. Setup CI/CD vars in gitlab account
  - Go to gitlab repository > Settings > CI/CD > Variables
    - Setup variables for AWS Access `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and `AWS_DEFAULT_REGION`.
    - Setup ECR Repo URL variables `ECR_REPOSITORY`   
2. Update `CLUSTER_NAME` variable in `.gitlab-ci.yml` file on local system.
3. Upload/push all files and folder to Gitlab along with `.gitlab-ci.yml` file to the gitlab repository created this will automatically create a pipeline to build and deploy application to eks cluster.


**Cleanup everything:**


1. First clean up all Kubernetes deployments/services
  - go to `helm-charts` folder and run `helm uninstall sample-go-app`
2. Cleanup infrastrucutre
  - Once deployments and services are cleanup then delete infrastructure using following commands:
    - `terragrunt init`
    - `terragrunt destroy`

## CI/CD Architecture ideas

- CI/CD pipeline can be pepared for both infra and application where infra will have a ci/cd pipeline with an upstream pipeline which handles deployment of latest application image

![Gitlab CI/CD Pipeline Architecture](gitlab_ci_cd_architecture.png)


## Future updates and features

- CI/CD pipeline for infra aswell as application couple together to give a single interface and overview of whole release pipeline.
- MR based CI/CD pipeline triggers on Gitlab
- Role based authentication for terragrunt &  CI/CD pipelines
- Kubernetes dashboard or any monitoring solution for resource optimization


## Advantages of this setup

- Multi AZ EKS setup - highly available across a given region

![VPC & EKS Architecture](eks_vpc_architecture.png)

- Clean and unified overview of whole CI/CD pipeline on Gitlab
- Auto-scalable & Auto rollback deployments
- Infrastructure state maintained via Terraform remote state on S3 & Dynamo DB
- Application Docker image is stored on ECR
- Docker in Docker based CI/CD pipelines for lightweight and quick builds aswell as deployments.


## Disadvantages of this setup

- High maintainence - one has to always update and upgrade terrafrom and terragrunt versions
- Solution tightly coupled with AWS and Gitlab (Prone to downtimes based on provider status)
- High costs (you pay for Gitlab services and AWS services)


## FAQ

Incase you face error: `You must be logged in to the server (Unauthorized)`


This happens because the user you are using to connect to the cluster is not whitelisted in configmaps to allow access. Please add the IAM users to kubernet config map using below commands.

- See config map using: `kubectl -n kube-system get configmap aws-auth -o yaml`
- Edit config map using: `kubectl -n kube-system edit configmap aws-auth`

Add following section after `mapRoles`

```
  mapUsers: |
    - userarn: arn:aws:iam::XXXXXX:user/test_user
      username: test_user
      groups:
        - system:masters
```

This will let external IAM users or roles access cluster from anywhere.

## References

- [Provision an EKS Cluster (AWS)](https://learn.hashicorp.com/tutorials/terraform/eks?in=terraform/kubernetes)