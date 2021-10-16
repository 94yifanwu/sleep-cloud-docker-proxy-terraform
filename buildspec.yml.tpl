version: 0.2

env:
  secrets-manager:
    BITBUCKET_PRIVATE_KEY: ${bitbucket_secret_name}:gitaccess

phases:
  install:
    runtime-versions:
      java: corretto11
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
      - COMMIT_HASH=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-7)
      - IMAGE_TAG=build-$(echo $CODEBUILD_BUILD_ID | awk -F":" '{print $2}')
      - REPOSITORY_URI=${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/${docker_image_ecr}
      - echo Establishing git credentials
      - echo $BITBUCKET_PRIVATE_KEY > /tmp/mykey64
      - base64 -d /tmp/mykey64 > ~/.ssh/id_rsa
      - chmod 600 ~/.ssh/id_rsa
      - echo ${bitbucket_public_key} > ~/.ssh/known_hosts
      - chmod 600 ~/.ssh/known_hosts
      - git config --global core.sshCommand 'ssh -vT'
      - git config --global advice.detachedHead false
      - git config --list
  build:
    commands:
      - java -version
      - mvn --version
      - aws --version
      - docker --version
      - git clone ssh://git@stash.ec2.local:7999/${project}/${dockerfile_repo}.git
      - cd ${dockerfile_repo}
      - git checkout ${git_checkout_branch}
      - cd ${dockerfile_repo_path}
      - docker build -t $REPOSITORY_URI:latest .
      - docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$IMAGE_TAG
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image to ECR...
      - docker push $REPOSITORY_URI:latest
      - docker push $REPOSITORY_URI:$IMAGE_TAG
      - echo Writing image definitions file...
      
      - printf '[{"name":"%s","imageUri":"%s"}]' ${container_name_dps} $REPOSITORY_URI:$IMAGE_TAG > imagedefinitions-dps.json
      - printf '[{"name":"%s","imageUri":"%s"}]' ${container_name_fus} $REPOSITORY_URI:$IMAGE_TAG > imagedefinitions-fus.json
      - printf '[{"name":"%s","imageUri":"%s"}]' ${container_name_rhs} $REPOSITORY_URI:$IMAGE_TAG > imagedefinitions-rhs.json
      
      - cp imagedefinitions* $CODEBUILD_SRC_DIR/
      - cd $CODEBUILD_SRC_DIR

artifacts:
  files:
    - 'imagedefinitions-dps.json'
    - 'imagedefinitions-fus.json'
    - 'imagedefinitions-rhs.json'

