import { client } from "./client";
import gql from "graphql-tag";

client.query({
    query: gql`
      query {
  trips(originGlobalID:"de:08222:2471" destinationGlobalID:"de:08222:2417" departureTime:"2019-11-18T15:15:00Z") {
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
            	name
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
            	name
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
}).then(result => console.log(result["data"]));
