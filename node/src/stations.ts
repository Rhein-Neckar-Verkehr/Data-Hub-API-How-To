import { client } from './client.js';
import gql from 'graphql-tag';

const result = client
  .query({
    query: gql`
      query {
        stations(first: 3, lat: 49.483076, long: 8.468409, distance: 0.5) {
          totalCount
          elements {
            ... on Station {
              hafasID
              globalID
              longName
            }
          }
        }
      }
    `,
  })
  .then(result => console.log(JSON.stringify(result['data'], null, 2)));
