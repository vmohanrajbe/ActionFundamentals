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

echo "### Creating release in GitHub via API"
curl --silent --show-error --fail -u "$GIT_USER:$GIT_TOKEN" \
-X POST \
https://api.github.com/repos/MuleSoft-Bofa/${REPO_NAME}/releases \
--data \
"{\"tag_name\":\"$pv\",\"target_commitish\":\"qa\", \"name\":\"$pv\"}"
echo -e "### GitHub release created\n### Updating dev branch with new version"

git checkout dev
git branch --set-upstream-to origin/dev
git merge origin/qa
mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.nextMinorVersion}.0-SNAPSHOT
git ls-files -m | grep -x '^.*pom.xml$' | xargs git add
git status
git commit -m "[CICD] Updating version to the next SNAPSHOT [ci skip]"
git push


