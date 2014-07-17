#!/bin/bash
tag="shippable-build-$BUILD_NUMBER"

# we need to create an annotated tag with message containing '[skip ci]' to prevent
# invoking another build for pushing the tag
git checkout $BRANCH
git tag -f $tag -m "[skip ci] Shippable build #${BUILD_NUMBER}"
# use the key that Shippable uses to connect to GitHub
ssh-agent bash -c "ssh-add ~/keys/id_${JOB_ID}; git push origin $tag"

pull_request=$(printf \
  '{"title": "Deploy build #%d to the production", "head": "%s", "base": "production"}' \
  $BUILD_NUMBER $tag)

remote_url=$(git ls-remote --get-url origin)
remote_url_wo_host=${remote_url#*:}
repo_name=${remote_url_wo_host%.*}

curl -s -H "Authorization: token $GITHUB_API_KEY" \
     -XPOST https://api.github.com/repos/$repo_name/pulls \
     -d "$pull_request"
