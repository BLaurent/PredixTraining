#!/usr/bin/env bash


cf cs predix-uaa Free "uaa-lab" -c  '{"adminClientSecret":"admin","subdomain":"lab-bl"}'
uaac token client get admin -s admin
uaaIssuerId=$(./cfcred.sh "uaa-lab" | jq  -r '.system_env_json.VCAP_SERVICES."predix-uaa"[].credentials.issuerId')
cf create-service predix-timeseries Free timeseries-lab -c '{"trustedIssuerIds":["'${uaaIssuerId}'"]}'
timeseriesZoneId=$(./cfcred.sh "timeseries-lab" | jq -r '.system_env_json.VCAP_SERVICES."predix-timeseries"[].credentials.ingest."zone-http-header-value"')

uaac group add timeseries.zones.${timeseriesZoneId}.user
uaac group add timeseries.zones.${timeseriesZoneId}.ingest
uaac group add timeseries.zones.${timeseriesZoneId}.query

uaac client add timeseries-ingestion-service -s timeseries-ingestion-service --authorized_grant_types "client_credentials" --authorities "uaa.none uaa.resource timeseries.zones.${timeseriesZoneId}.user timeseries.zones.${timeseriesZoneId}.query timeseries.zones.${timeseriesZoneId}.ingest"  --access_token_validity 1800

uaac client add rest_client -s rest_client --authorized_grant_types "client_credentials" --authorities "uaa.none uaa.resource"
