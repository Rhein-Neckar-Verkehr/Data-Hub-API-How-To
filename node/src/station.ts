import { client } from "./client";
import gql from "graphql-tag";

client.query({
    query: gql`
      query {
        station(id:"2471") {
            hafasID
            longName
            shortName
            name
        }
      }
    `,
}).then(result => console.log(result["data"])).catch(error => console.log(error));
