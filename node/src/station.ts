import { client } from './client.js';
import gql from 'graphql-tag';

client
  .query({
    query: gql`
      query {
        station(id: "2471") {
          hafasID
          longName
          shortName
          name
        }
      }
    `,
  })
  .then(result => console.log(JSON.stringify(result['data'], null, 2)));
