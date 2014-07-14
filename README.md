Sample for multiple environments
================================

This sample demonstrates how to setup continuous integration and deployment of an Express+MongoDB
project with multiple Heroku environments. After the build is triggered by the webhook and the
project builds successfully, it is first deployed to the staging environment (separate Heroku app).

At the same time, we tag the build with Shippable build number and issue a pull request to a
special `production` branch that lives in the same repository. 

Then (likely after QA team performs acceptance tests), the pull request can be accepted, which
will effect in deployment of the associated build to the production environment, which (again)
is a separate Heroku application. Using GitHub pull request to trigger the deployment also
creates an opportunity to discuss the status of the build in comments, perform code review
etc.

Shippable configuration
-----------------------

To be able to deploy to two Heroku applications, we need to add two separate remotes: `staging`, 
`production`. This is done here in `before_install` step:

    - git remote -v | grep ^staging || heroku git:remote --remote staging --app $STAGING_APP_NAME
    - git remote -v | grep ^production || heroku git:remote --remote production --app $PROD_APP_NAME

Then, all the workflow logic is handled by two scripts included in this repository: `deploy.sh` and
`github_promotion.sh` (that is invoked by `deploy.sh`).

    after_success:
      - ./node_modules/.bin/istanbul cover grunt -- -u tdd
      - ./node_modules/.bin/istanbul report cobertura --dir  shippable/codecoverage/
      - ./deploy.sh

Both scripts should work for your project with any modifications. Please refer to comments in the
scripts for description of the internals. The only configuration that is needed for the scripts
to work is GitHub API token, that you can create in 'Personal access tokens' section of
[your account settings](https://github.com/settings/applications). It then needs to be included
in the environment variables of your `shippable.yml` as `GITHUB_API_KEY`.  We strongly recommend
to add this variable as a secure (encrypted) one.

For more detailed documentation on Heroku deployment, please see Shippable's continuous
deployment section: http://docs.shippable.com/en/latest/config.html#continuous-deployment
