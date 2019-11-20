import { client } from "./client";
import gql from "graphql-tag";

client.query({
    query: gql`
      query {
        station(id:"2417") {
            hafasID
            longName
            journeys(startTime: "2019-10-24T12:00:00Z" first: 5) {
                totalCount
                elements {
                    ... on Journey {
                    
                        line {
                            id
                        }
                        
                        stops(hafasID:"2417") {
                            
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
}).then(result => console.log(result["data"]));
