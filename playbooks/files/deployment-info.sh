#!/bin/sh

SECRET=$(kubectl get secret/fuzzball-fuzzball-secrets -n fuzzball -o json)
if [ "$?" != "0" ]
then
    error="$?"
    echo >&2 "Unable to get Fuzzball deployment data with kubectl."
    exit "${error}"
fi

getField () {
  path=$1
  echo "${SECRET}" | jq -r "${path} // empty | @base64d"
}

echo "-------------------CLUSTER INFORMATION--------------------

Keycloak URL:     $(getField .data.authURL)
Fuzzball API URL: $(getField .data.fuzzballURL)
Fuzzball UI URL:  $(getField .data.fuzzballUIURL)

Fuzzball admin account:
- username: $(getField .data.fuzzballAdminUsername)
- password: $(getField .data.fuzzballAdminPassword)

Keycloak admin account:
- username: $(getField .data.keycloakAdminUsername)
- password: $(getField .data.keycloakAdminPassword)

To connect to Fuzzball:

$ fuzzball context create default $(getField .data.fuzzballHost) $(getField .data.authURL) fuzzball-cli
$ fuzzball context use default
$ fuzzball context login --direct

If you have not created an account, you can run:

$ fuzzball account create default
$ fuzzball account use <UUID> # supply the created UUID"
