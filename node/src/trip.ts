import { client } from './client.js';
import gql from 'graphql-tag';

client
  .query({
    query: gql`
      query {
        trips(
          originGlobalID: "de:08222:2471"
          destinationGlobalID: "de:08222:2417"
          departureTime: "2024-02-26T17:00:00Z"
        ) {
          startTime {
            isoString
          }

          endTime {
            isoString
          }

          interchanges

          legs {
            ... on InterchangeLeg {
              mode
            }

            ... on TimedLeg {
              board {
                point {
                  ... on StopPoint {
                    ref
                    stopPointName
                  }
                }
                estimatedTime {
                  isoString
                }
                timetabledTime {
                  isoString
                }
              }

              alight {
                point {
                  ... on StopPoint {
                    ref
                    stopPointName
                  }
                }

                estimatedTime {
                  isoString
                }
                timetabledTime {
                  isoString
                }
              }

              service {
                type
                name
                description
                destinationLabel
              }
            }

            ... on ContinuousLeg {
              mode
            }
          }
        }
      }
    `,
  })
  .then(result => console.log(JSON.stringify(result['data'], null, 2)));
