#!/bin/sh
#
# Gets the VCAP_SERVICES credentials of one or more CF services instanced in a space
#
# Usage: getcred <service instance name> [<service instance name2> ...]
#
# Output is JSON suitable for use with 'jq'.
#
# Example:
#
# getcred uaa
# {
#    "staging_env_json": {},
#    "running_env_json": {},
#    "environment_json": {},
#    "system_env_json": {
#       "VCAP_SERVICES": {
#          "predix-uaa": [
#             {
#                "name": "uaa",
#                "label": "predix-uaa",
#                "tags": [],
#                "plan": "beta",
#               ...
#
# getcred uaa |  jq -r '.system_env_json.VCAP_SERVICES."predix-uaa"[].credentials.issuerId'
# https://804d4489-d60d-46eb-8344-0d4b90861da3.predix-uaa.run.asv-pr.ice.predix.io/oauth/token
#
if [ -z "$1" ]
  then
    echo "Gets the VCAP_SERVICES credentials of one or more CF services instanced in a space"
    echo "usage: $0: <service instance name> [<service instance name2> ...]"
    exit 1
fi

# create a random 'tmp' dir to create a temp cf app in, name of dir is CF app name
cftempapp_dir=`mktemp -d /tmp/cfapp-XXXXXX`
cd $cftempapp_dir
cftempapp_name=${PWD##*/}

# create the 'app' its just an empty file expected by the null buildpack
touch Procfile

# push the temp app to cf
cf push $cftempapp_name -b http://github.com/ryandotsmith/null-buildpack.git --no-start --no-route -m 32m >/dev/null

# bind the temp app to each service instance named
for service_name in "$@"
do
  cf bs $cftempapp_name $service_name >/dev/null
done

# get the temp app's GUID (needed for CURL API... CURL API is needed to get back raw JSON)
cftempapp_guid=`cf app ${cftempapp_name} --guid`

# spew the temp app's environment to stdout
cf curl /v2/apps/$cftempapp_guid/env

# gingerly clean up the mess
cf delete $cftempapp_name -f >/dev/null
cd
rm $cftempapp_dir/Procfile
rmdir $cftempapp_dir

# eof
