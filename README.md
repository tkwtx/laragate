# LaraGate

## setup
1. Build the docker image in the local environment.
   ```bazaar
   $ docker build -t laragate/composer:latest -f ./docker/composer/Dockerfile .
   $ docker build -t laragate/nginx:latest -f ./docker/nginx/Dockerfile .
   $ docker build -t laragate/laravel:latest -f ./docker/laravel/Dockerfile .
1. Verify that the source appears in the local environment with docker-compose.
1. Register nginx and laravel images in ECR.(xxxxx=your aws account id)
   ```bazaar
   $ aws ecr get-login-password --region ap-northeast-1 | \
        docker login --username AWS --password-stdin xxxxx.dkr.ecr.ap-northeast-1.amazonaws.com
   $ docker tag laragate/nginx:latest xxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/laragate/nginx:latest
   $ docker tag laragate/laravel:latest xxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/laragate/laravel:latest
   $ docker push xxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/laragate/nginx:latest
   $ docker push xxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/laragate/laravel:latest
1. Enter values in the Terraform configuration file.(./terraform/environments/dev/terraform.tfvars)
1. Register APP_KEY created in local environment to ssm.
1. Register the route53 ns server records with an official domain registration service.
1. Using terraform to build AWS resources.
1. Set up the laragate project in CircleCI and register the following environment variables.(Slack notification is optional)
    ```bazaar
   APP_PREFIX = laragate
   AWS_ECR_ACCOUNT_URL_ENV_VAR_NAME = xxxxx.dkr.ecr.ap-northeast-1.amazonaws.com
   AWS_REGION_ENV_VAR_NAME = ap-northeast-1
   ACCESS_KEY_ID_ENV_VAR_NAME = ${your_aws_access_key}
   SECRET_ACCESS_KEY_ENV_VAR_NAME = ${your_secret_access_key}
   SLACK_ACCESS_TOKEN=${your_slack_access_token}
   SLACK_DEFAULT_CHANNEL=${your_slack_channel}
