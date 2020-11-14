# AWS Fargate Demo

This is a brief demo for deploying an existing Docker Container to AWS Fargate and setting that up to connect to an RDS Database in AWS. There is a full video [here].

## AWS ECS Fargate

Create a new repository for the app (only needs to be done once)

```
aws ecr create-repository --repository-name demo/rails
```

Make a note of the `repositoryUri` (e.g. [your-aws-account-id].dkr.ecr.ap-southeast-1.amazonaws.com/demo/rails)

### Create Task Definition to run the Rails App and run DB Migrations

This only needs to be run once for each task definition.

* **NOTE** to update the placeholders in the JSON file before running!
* **NOTE** if there is a task definition registered with the same name then a new version is created.

```
aws ecs register-task-definition --cli-input-json file://aws/railsdemo.json
```

...for the migrations:

```
aws ecs register-task-definition --cli-input-json file://aws/railsmigrations.json
```

### Create a new ECS Cluster

This only needs to be done once.

```
aws ecs create-cluster --cluster-name railsdemo
```

### Create a new ECS Service

We need a service for our Rails app that will run in our ECS Cluster. The service will:

* Provision load balancers
* Implement auto scaling
* Use an elastic IP address for the load balancers

### Deploy to AWS Container Services (ECS) using AWS Fargate

When we are ready to deploy we need to:

1. Authenticate with ECR
1. Precompile any assets
1. Build the Docker Image
1. Check the contents of Image
1. Tag the image for ECR
1. Push the Image to ECR
1. Run the database migrations
1. Update the running ECS Service instance.

**Authenticate Docker Client with AWS ECR**

Using `aws` cli, authenticate with the AWS Container Registry (ECR) like so:

```
aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin [your-aws-account-id].dkr.ecr.ap-southeast-1.amazonaws.com
```

**Precompile the assets**

```
SECRET_KEY_BASE=asecret RAILS_ENV=staging bundle exec rake assets:precompile
```

**Build the docker image**

```
docker build -t rails6demo:latest .
```

**(Optional) check the contents of the image**

```
docker run -it rails6demo:latest bash
```

**Tag the image for AWS ECR**

```
docker tag rails6demo:latest [your-aws-account-id].dkr.ecr.ap-southeast-1.amazonaws.com/demo/rails:latest
```

**Push to AWS ECR**

```
docker push [your-aws-account-id].dkr.ecr.ap-southeast-1.amazonaws.com/demo/rails:latest
```

**Run migrations**

```
aws ecs run-task --cluster railsdemonew --launch-type FARGATE --task-definition railsmmm:7 --network-configuration '{
  "awsvpcConfiguration": {
    "subnets": ["your-subnet-1", "your-subnet-2"],
    "securityGroups": ["your-security-group"],
    "assignPublicIp": "ENABLED"
  }
}'
```

**Deploy to service**

The command below will force the running tasks in the service `railsdemoservice` to redeploy with the latest docker image that was just pushed to AWS ECR.

```
aws ecs update-service --cluster railsdemo --service railsapp --force-new-deployment --region ap-southeast-1
```

## RDS

If you prefer to run db migrations from a bastion host or CI/CD server then please note that RDS needs to have the security group to be configured correctly to allow to connect to it from a bastion host or from your local machine.

Connect to it using `psql`

```
psql -h hostname -U username database
```

Run migrations:

```
SECRET_KEY_BASE=asecret RAILS_ENV=staging DATABASE_URL=postgres://username:password@hostname/database bundle exec rake db:migrate
```