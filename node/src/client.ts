import pkg from "@apollo/client/core/core.cjs";
const { ApolloClient, InMemoryCache, ApolloLink, HttpLink } = pkg;
import { setContext } from "@apollo/client/link/context/context.cjs";
import fetch from "node-fetch";
/* import {
  CLIENT_API_URL,
  OAUTH_URL,
  CLIENT_ID,
  CLIENT_SECRET,
  RESOURCE_ID,
} from "./env.js";
 */
import dotenv from "dotenv";

dotenv.config();

export const CLIENT_API_URL = process.env.CLIENT_API_URL;
export const OAUTH_URL = process.env.OAUTH_URL;
export const CLIENT_ID = process.env.CLIENT_ID;
export const CLIENT_SECRET = process.env.CLIENT_SECRET;
export const RESOURCE_ID = process.env.RESOURCE_ID;

const accessToken = async () => {
  const promise = new Promise(async (resolve, reject) => {
    const response = await fetch(OAUTH_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body:
        `grant_type=client_credentials&client_id=${CLIENT_ID}` +
        `&client_secret=${CLIENT_SECRET}&resource=${RESOURCE_ID}`,
    });

    resolve(response.json());
  });

  const json = await promise;
  return json["access_token"];
};

const httpLink = new HttpLink({
  uri: CLIENT_API_URL,
  credentials: "same-origin",
});

const authMiddleware = setContext(
  (request) =>
    new Promise(async (resolve, reject) => {
      const token = await accessToken();

      resolve({
        headers: {
          authorization: `Bearer ${token}`,
        },
      });
    })
);
export const client = new ApolloClient({
  link: ApolloLink.from([authMiddleware, httpLink]),
  cache: new InMemoryCache(),
});
