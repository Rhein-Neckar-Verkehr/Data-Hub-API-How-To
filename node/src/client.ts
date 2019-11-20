import { ApolloClient } from 'apollo-client';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { HttpLink } from 'apollo-link-http';
import { ApolloLink } from 'apollo-link';
import { setContext } from 'apollo-link-context';
import fetch from 'node-fetch';


import { CLIENT_API_URL, OAUTH_URL, CLIENT_ID, CLIENT_SECRET, RESOURCE_ID } from './env';

const accessToken = async () => {

    const promise = new Promise(async (resolve, reject) => {

        const response = await fetch(OAUTH_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: `grant_type=client_credentials&client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}&resource=${RESOURCE_ID}`
        });

        resolve(response.json());
    })

    const json = await promise;
    return json["access_token"];
}

const httpLink = new HttpLink({
    uri: CLIENT_API_URL,
    credentials: 'same-origin',
    fetch: fetch
});

const authMiddleware = setContext((request) => new Promise(async (resolve, reject) => {

    const token = await accessToken();

    resolve({
        headers: {
            authorization: `Bearer ${token}`,
        }
    })
}));


export const client = new ApolloClient({
    link: ApolloLink.from([authMiddleware, httpLink]),
    cache: new InMemoryCache()
});