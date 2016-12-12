#!/usr/bin/env bash



curl -X GET -H "Cache-Control: no-cache" "https://opendata.paris.fr/api/v2/catalog/datasets/place-de-la-nation-mesures-de-bruit-valeur-minimum/records?rows=-1&timezone=UTC" | gzip > place-de-la-nation-mesures-de-bruit-valeur-minimum.json.gz
curl -X GET -H "Cache-Control: no-cache" "https://opendata.paris.fr/api/v2/catalog/datasets/place-de-la-nation-mesure-de-buit-valeur-maximum/records?rows=-1&timezone=UTC" | gzip > place-de-la-nation-mesures-de-bruit-valeur-maximum.json.gz
curl -X GET -H "Cache-Control: no-cache" "https://opendata.paris.fr/api/v2/catalog/datasets/place-de-la-nation-emplacements-capteurs-bruits/records?rows=-1&timezone=UTC" | gzip > place-de-la-nation-emplacements-capteurs-bruits.json.gz
curl -X GET -H "Cache-Control: no-cache" "https://opendata.paris.fr/api/v2/catalog/datasets/place-de-la-nation-rh/records?rows=-1&timezone=UTC" | gzip > place-de-la-nation-rh.json.gz
curl -X GET -H "Cache-Control: no-cache" "https://opendata.paris.fr/api/v2/catalog/datasets/place-de-la-nation-temperature/records?rows=-1&timezone=UTC" | gzip > place-de-la-nation-temperature.json.gz
curl -X GET -H "Cache-Control: no-cache" "https://opendata.paris.fr/api/v2/catalog/datasets/place-de-la-nation-flux-vehicules/records?rows=-1&timezone=UTC" | gzip > place-de-la-nation-flux-vehicules.json.gz
curl -X GET -H "Cache-Control: no-cache" "https://opendata.paris.fr/api/v2/catalog/datasets/place-de-nation-flux-pietons/records?rows=-1&timezone=UTC" | gzip > place-de-nation-flux-pietons.json.gz
curl -X GET -H "Cache-Control: no-cache" "https://opendata.paris.fr/api/v2/catalog/datasets/place-de-nation-flux-velos/records?rows=-1&timezone=UTC" | gzip > place-de-nation-flux-velos.json.gz
curl -X GET -H "Cache-Control: no-cache" "https://opendata.paris.fr/api/v2/catalog/datasets/place-de-la-nation-points-de-mesure-flux/records?rows=-1&timezone=UTC" | gzip > place-de-la-nation-points-de-mesure-flux.json.gz
