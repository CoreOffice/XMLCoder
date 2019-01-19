#!/bin/bash

echo "TRAVIS_BRANCH is $TRAVIS_BRANCH"
if [[ $TRAVIS_BRANCH == "master" ]]; then
  PREFIX="master"
elif [[ ! -z $TRAVIS_TAG ]]; then
  PREFIX=$TRAVIS_TAG
else
  echo "no tag set or branch isn't 'master', no upload will happen"
  exit 0
fi

echo "docs will be uploaded to s3://xmlcoder.org/docs/$PREFIX"

gem install --user-install jazzy && \
  jazzy && aws s3 sync docs s3://xmlcoder.org/docs/$PREFIX
