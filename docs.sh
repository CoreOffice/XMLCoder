#!/bin/bash

if [[ $TRAVIS_BRANCH == "master" ]]:
  PREFIX="master"
elif [[ -z $TRAVIS_TAG ]]:
  PREFIX=$TRAVIS_TAG
else
  echo "no tag set or branch isn't `master`, no upload will happen"
  exit 0
fi

echo "docs will be uploaded to s3://xmlcoder.org/docs/$PREFIX"

jazzy && aws s3 sync docs s3://xmlcoder.org/docs/$PREFIX
