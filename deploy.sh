#!/bin/bash

# if this build is triggered by pull request, exit without deploying
[[ $PULL_REQUEST != 'None' ]] && exit 0

# determine target environment based on the branch name
[[ $BRANCH = 'production' ]] && REMOTE=production || REMOTE=staging

# push to Heroku
git push -f $REMOTE master

# submit pull request for the production deployment if applicable
[[ $REMOTE = 'staging' ]] && ./github_promotion.sh
