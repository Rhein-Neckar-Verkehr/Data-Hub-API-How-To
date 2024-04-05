import { client } from './client.js';
import gql from 'graphql-tag';

client
  .query({
    query: gql`
      query {
        station(id: "2417") {
          hafasID
          longName
          journeys(startTime: "2024-02-26T17:00:00Z", first: 3) {
            totalCount
            elements {
              ... on Journey {
                id
                line {
                  id
                }
                loadsForecastType

                loads(onlyHafasID: "2417") {
                  realtime
                  forecast
                  adjusted
                  loadType
                  ratio
                }

                stops(only: "2417") {
                  plannedDeparture {
                    isoString
                  }

                  realtimeDeparture {
                    isoString
                  }
                }
              }
            }
          }
        }
      }
    `,
  })
  .then(result => console.log(JSON.stringify(result['data'], null, 2)));
