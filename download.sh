#!/usr/bin/env bash

curl -X GET -H "Cache-Control: no-cache" "https://opendata.paris.fr/explore/dataset/place-de-la-nation-mesures-de-bruit-valeur-minimum/download/?format=json&timezone=UTC" > ./data/place-de-la-nation-mesures-de-bruit-valeur-minimum.json
curl -X GET -H "Cache-Control: no-cache" "https://opendata.paris.fr/explore/dataset/place-de-la-nation-mesure-de-buit-valeur-maximum/download/?format=json&timezone=UTC" > ./data/place-de-la-nation-mesures-de-bruit-valeur-maximum.json
curl -X GET -H "Cache-Control: no-cache" "https://opendata.paris.fr/explore/dataset/place-de-la-nation-rh/download/?format=json&timezone=UTC" > ./data/place-de-la-nation-rh.json
curl -X GET -H "Cache-Control: no-cache" "https://opendata.paris.fr/explore/dataset/place-de-la-nation-temperature/download/?format=json&timezone=UTC" > ./data/place-de-la-nation-temperature.json
curl -X GET -H "Cache-Control: no-cache" "https://opendata.paris.fr/explore/dataset/place-de-la-nation-flux-vehicules/download/?format=json&timezone=UTC" > ./data/place-de-la-nation-flux-vehicules.json
curl -X GET -H "Cache-Control: no-cache" "https://opendata.paris.fr/explore/dataset/place-de-nation-flux-pietons/download/?format=json&timezone=UTC" > ./data/place-de-nation-flux-pietons.json
curl -X GET -H "Cache-Control: no-cache" "https://opendata.paris.fr/explore/dataset/place-de-nation-flux-velos/download/?format=json&timezone=UTC" > ./data/place-de-nation-flux-velos.json
