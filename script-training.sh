#!/usr/bin/env bash -x

#cf target -o European_Foundry_Basic

#cf delete-space -f training
#cf create-space training

#userList=( gilles.taddei@ge.com jennifer.gouin@ge.com esteban.gea@ge.com suzy.broto@ge.com yannick.laumonier@ge.com fatiha.bouad@ge.com mathieu.clement@ge.com viet.luong@ge.com )

#cf target -o European_Foundry_Basic -s training

#for i in ${userList[@]}; do
#  cf set-space-role $i European_Foundry_Basic training SpaceDeveloper &
#done

#wait

#cf cs predix-uaa Free "uaa-lab" -c  '{"adminClientSecret":"admin","subdomain":"lab-ge"}'
uaaIssuerId=$(./cfcred.sh "uaa-lab" | jq  -r '.system_env_json.VCAP_SERVICES."predix-uaa"[].credentials.issuerId')
uaaUri=$(./cfcred.sh "uaa-lab" | jq  -r '.system_env_json.VCAP_SERVICES."predix-uaa"[].credentials.uri')

#uaac target ${uaaUri}
#uaac token client get admin -s admin

#cf create-service predix-timeseries Tiered timeseries-lab -c '{"trustedIssuerIds":["'${uaaIssuerId}'"]}'
#timeseriesZoneId=$(./cfcred.sh "timeseries-lab" | jq -r '.system_env_json.VCAP_SERVICES."predix-timeseries"[].credentials.ingest."zone-http-header-value"')

#uaac group add timeseries.zones.${timeseriesZoneId}.user &
#uaac group add timeseries.zones.${timeseriesZoneId}.ingest &
#uaac group add timeseries.zones.${timeseriesZoneId}.query &

#uaac client add timeseries-ingestion-service -s timeseries-ingestion-service --authorized_grant_types "client_credentials" --authorities "uaa.none uaa.resource timeseries.zones.${timeseriesZoneId}.user timeseries.zones.${timeseriesZoneId}.query timeseries.zones.${timeseriesZoneId}.ingest"  --access_token_validity 1800 &
#uaac client add rest-client -s rest-client --authorized_grant_types "client_credentials" --authorities "uaa.none uaa.resource" &

#wait

#wget https://github.build.ge.com/pages/100026625/Predix-Training/timeseries-ingestion-service.tar.gz
#wget https://github.build.ge.com/pages/100026625/Predix-Training/data/download.sh

#./data/download.sh
#tar xfz timeseries-ingestion-service.tar.gz
#cd timeseries-ingestion-service
#cf p --random-route
#cd ..
#cf cs predix-analytics-catalog Bronze analytics-catalog-lab -c '{"trustedIssuerIds":["'${uaaIssuerId}'"]}'
#analyticsCatalogZoneId=$(./cfcred.sh analytics-catalog-lab | jq -r '.system_env_json.VCAP_SERVICES."predix-analytics-catalog"[].credentials."zone-http-header-value"')

#uaac client add analytics-client -s analytics-client --authorized_grant_types "client_credentials" --authorities "uaa.resource analytics.zones.${analyticsCatalogZoneId}.user timeseries.zones.${timeseriesZoneId}.user timeseries.zones.${timeseriesZoneId}.query timeseries.zones.${timeseriesZoneId}.ingest" --access_token_validity 1800 &
#uaac group add analytics.zones.${analyticsCatalogZoneId}.user &
#wait

#analytics_runtime_payload='{"trustedIssuerIds":["'${uaaIssuerId}'"],"dependentServices":{"predixTimeseriesZoneId":"'${timeseriesZoneId}'","predixAnalyticsCatalogZoneId":"'${analyticsCatalogZoneId}'"},"trustedClientCredential":{"clientId":"analytics-client","clientSecret":"analytics-client"}}'
#cf cs predix-analytics-runtime Bronze analytics-runtime-lab -c ${analytics_runtime_payload}
#analyticsRuntimeZoneId=$(./cfcred.sh analytics-runtime-lab | jq -r '.system_env_json.VCAP_SERVICES."predix-analytics-runtime"[].credentials."zone-http-header-value"')

#uaac client update analytics-client --authorized_grant_types "client_credentials" --authorities "uaa.resource analytics.zones.${analyticsCatalogZoneId}.user timeseries.zones.${timeseriesZoneId}.user timeseries.zones.${timeseriesZoneId}.query timeseries.zones.${timeseriesZoneId}.ingest analytics.zones.${analyticsRuntimeZoneId}.user" --access_token_validity 1800 &
#uaac group add analytics.zones.${analyticsRuntimeZoneId}.user &
#wait

#uaac client add analytics-ui -s analytics-ui --authorized_grant_types "client_credentials authorization_code refresh_token" --scope "uaa.resource analytics.zones.${analyticsCatalogZoneId}.user analytics.zones.${analyticsRuntimeZoneId}.user uaa.none uaa.user" --autoapprove "uaa.user analytics.zones.${analyticsCatalogZoneId}.user analytics.zones.${analyticsRuntimeZoneId}.user" --access_token_validity 18000 &
#cf cs predix-analytics-ui Free analytics-ui-lab -c '{"uaaHostUri":"'${uaaUri}'","clientId":"analytics-ui","clientSecret":"analytics-ui","domainPrefix":"lab-ge","catalogPredixZoneId":"'${analyticsCatalogZoneId}'","runtimePredixZoneId":"'${analyticsRuntimeZoneId}'"}'

#uaac user add analytics-ui@ge.com -p analytics-ui --emails analytics-ui@ge.com
#uaac member add analytics.zones.${analyticsRuntimeZoneId}.user analytics-ui@ge.com
#uaac member add analytics.zones.${analyticsCatalogZoneId}.user analytics-ui@ge.com

app_guid=$(cf app timeseries-ingestion-service --guid)
ingesterUri=$(cf curl /v2/apps/$app_guid/env | jq -r '.application_env_json.VCAP_APPLICATION.uris[]')
basic_creds=$(echo -n timeseries-ingestion-service:timeseries-ingestion-service | base64)

dataList=(place-de-la-nation-flux-vehicules.json place-de-la-nation-temperature.json place-de-la-nation-mesures-de-bruit-valeur-maximum.json place-de-la-nation-mesures-de-bruit-valeur-minimum.json place-de-nation-flux-velos.json place-de-nation-flux-pietons.json)

for i in ${dataList[@]}; do
  TOKEN=$(curl -s -m 600 -X POST -H "Authorization: Basic ${basic_creds}" -H "Content-Type: application/x-www-form-urlencoded" -H "Cache-Control: no-cache" -d 'grant_type=client_credentials' "${uaaIssuerId}" | jq -r '.access_token')
  curl -s -m 10000 -X POST  -H "Authorization: Bearer ${TOKEN}" -F "files[]=@${i}" "https://${ingesterUri}/upload"
done

cf cs predix-blobstore Tiered blob-lab

