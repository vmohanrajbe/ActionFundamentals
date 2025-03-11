#!/bin/bash -ex
echo "##teamcity[setParameter name='env.BUILD_STEP' value='%teamcity.build.step.name%']"

REPO_NAME=echo $GIT_URL | sed 's/.*\///'


echo '### Version was updated by CICD. Pushing update back to GitHub"
git ls-files -m | grep -x '^.*pom.xml$' | xargs git add
git status
git commit -m " [CICD] Updating version to correct release version [ci skip]"
git push

pv=$(mvn -q Dexec.executable=echo -Dexec.args='${project.version}' --non-recursive exec:exec)
echo "##teamcity[setParameter name='env.RELEASE_VERSION' value='$pv']"

