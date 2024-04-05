#!/bin/bash

tenantID=$(awk '{if ( $0 ~ /^@tenantID=/ ) {print $0}}' graphql.http | cut -d'=' -f2)
OAUTH_URL=https://login.microsoftonline.com/${tenantID}/oauth2/token
CLIENT_ID=$(awk '{if ( $0 ~ /^@clientID=/ ) {print $0}}' graphql.http | cut -d'=' -f2)
CLIENT_SECRET=$(awk '{if ( $0 ~ /^@clientSecret=/ ) {print $0}}' graphql.http | cut -d'=' -f2)
RESOURCE_ID=$(awk '{if ( $0 ~ /^@resource=/ ) {print $0}}' graphql.http | cut -d'=' -f2)
CLIENT_API_URL=https://graphql-sandbox-dds.rnv-online.de/

echo "OAUTH_URL = $OAUTH_URL"
echo "CLIENT_ID = $CLIENT_ID"
echo "CLIENT_SECRET = $CLIENT_SECRET"
echo "RESOURCE_ID = $RESOURCE_ID"
echo "CLIENT_API_URL = $CLIENT_API_URL"

ACCESS_TOKEN=$(curl $OAUTH_URL -X POST \
	                       -H "Content-Type: application/x-www-form-urlencoded" \
                               -d grant_type=client_credentials \
                               -d client_id=$CLIENT_ID \
                               -d client_secret=$CLIENT_SECRET \
		               -d resource=$RESOURCE_ID)


ACCESS_TOKEN=$(echo ${ACCESS_TOKEN} | sed -s 's/,/ /g' | cut -d' ' -f7 | cut -d':' -f2 | cut -d'}' -f1 | sed -s 's/"//g')
echo
echo "ACCESS_TOKEN \"${ACCESS_TOKEN}\""
echo


echo "################################################################################"
echo "# Ping Request #"
echo "################################################################################"
#curl $CLIENT_API_URL -X POST -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "Content-Type: application/json" -H "Accept: application/json" -d '{"query": "{ ping { realtimeStatus dbStatus } }" }' | jq .
echo "################################################################################"
echo


echo "################################################################################"
echo "# Suche nach Haltestellen über Geokoordinaten #"
echo "################################################################################"
#curl $CLIENT_API_URL -X POST -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "Content-Type: application/json" -H "Accept: application/json" -d '{"query": "{ stations(first: 3 lat: 49.483076 long: 8.468409 distance: 0.5) { totalCount elements { ... on Station { hafasID globalID longName } } } }" }' | jq .
echo "################################################################################"
echo


echo "################################################################################"
echo "# Suche nach Haltestellen über Haltestellen-ID(hafasID) #"
echo "################################################################################"
#curl $CLIENT_API_URL -X POST -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "Content-Type: application/json" -H "Accept: application/json" -d '{"query": "{ station(id: \"2471\") { hafasID longName shortName name } }" }' | jq .
echo "################################################################################"
echo


CURRENT_DATE=$(date +"%Y-%m-%dT%H:%M:%SZ")
QUERY="{\"query\": \"{ station(id: \\\"2417\\\") { hafasID longName journeys(startTime: \\\"2024-02-26T17:00:00Z\\\" first: 2) { totalCount elements { ... on Journey { line { id } stops(onlyHafasID: \\\"2417\\\") { plannedDeparture { isoString } realtimeDeparture { isoString } } } } } } }\" }"
echo "################################################################################"
echo "# Erstellung eines Abfahrtsmonitors #"
echo "################################################################################"
#curl $CLIENT_API_URL -X POST -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "Content-Type: application/json" -H "Accept: application/json" -d "${QUERY}" | jq .
echo "################################################################################"
echo

QUERY="{\"query\": \"{station(id: \\\"2417\\\") {hafasID longName journeys(startTime: \\\"2024-02-26T17:00:00Z\\\", first: 3) {totalCount elements {... on Journey {id line {id} loadsForecastType loads(onlyHafasID: \\\"2417\\\") {realtime forecast adjusted loadType ratio} stops(only: \\\"2417\\\") {plannedDeparture {isoString} realtimeDeparture {isoString}}}}}}}\" }"
echo "################################################################################"
echo "# Abfrage der Auslastungsinformation #"
echo "################################################################################"
#curl $CLIENT_API_URL -X POST -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "Content-Type: application/json" -H "Accept: application/json" -d "${QUERY}" | jq .
echo "################################################################################"
echo


QUERY="{\"query\": \"{ trips(originGlobalID: \\\"de:08222:2471\\\" destinationGlobalID: \\\"de:08222:2417\\\" departureTime: \\\"2024-02-26T17:00:00Z\\\" ) { startTime { isoString } endTime { isoString } interchanges legs { ... on InterchangeLeg { mode } ... on TimedLeg { board { point { ... on StopPoint { ref stopPointName } } estimatedTime { isoString } timetabledTime { isoString } } alight { point { ... on StopPoint { ref stopPointName } } estimatedTime { isoString } timetabledTime { isoString } } service { type name description destinationLabel } } ... on ContinuousLeg { mode } } } }\" }"
echo "################################################################################"
echo "# Verbindungsauskunft #"
echo "################################################################################"
#curl $CLIENT_API_URL -X POST -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "Content-Type: application/json" -H "Accept: application/json" -d "${QUERY}" | jq .
echo "################################################################################"
echo

QUERY="{\"query\": \"{lines(first:3 after:\\\"10-10\\\") {totalCount elements {... on Line {id}}cursor}}\" }"
echo "################################################################################"
echo "# Cursor #"
echo "################################################################################"
curl $CLIENT_API_URL -X POST -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "Content-Type: application/json" -H "Accept: application/json" -d "${QUERY}" | jq .
echo "################################################################################"
echo


CURRENT_UNIX_TIME=$(date +"%s")
LATER_UNIX_TIME=$((${CURRENT_UNIX_TIME} + 300))
CURRENT_DATE=$(date +"%Y-%m-%dT%H:%M:%SZ" --date="@${CURRENT_UNIX_TIME}")
LATER_CURRENT_DATE=$(date +"%Y-%m-%dT%H:%M:%SZ" --date="@${LATER_UNIX_TIME}")
QUERY="{\"query\": \"{ station(hafasID: \\\"2417\\\") { name journeys(startTime: \\\"${CURRENT_DATE}\\\" endTime: \\\"${LATER_CURRENT_DATE}\\\") { totalCount elements { ... on Journey { cancelled type line { id lineGroup { id uffbasses(type: TICKER) { totalCount  elements { ... on Uffbasse { title rawTitle } } } } } stops(onlyHafasID: \\\"2417\\\") { destinationLabel pole { platform { label type locationType barrierFreeType } } plannedDeparture { isoString } realtimeDeparture { isoString } } } } } vrnStops(time: \\\"${CURRENT_DATE}\\\") { timetabledTime { isoString } service { cancelled type name destinationLabel productType } } } }\" }"
echo "################################################################################"
echo "# Erstellung eines Abfahrtsmonitors mit VRN #"
echo "################################################################################"
#curl $CLIENT_API_URL -X POST -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "Content-Type: application/json" -H "Accept: application/json" -d "${QUERY}" | jq .
echo "################################################################################"
echo

