import fetch from 'isomorphic-fetch'
require('es6-promise').polyfill()

export default function fetchApi(method, url, data) {
   
    if (method.toLowerCase() === 'get' ) {
        return fetch(url,{
            method,
            headers:{
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            credentials: 'same-origin'
            }).then(response => response.json())
    } 
    else {
    return fetch(url,{
        method,
        headers:{
            'Accept': 'application/json',
            'Content-Type': 'application/json',
        },
        credentials: 'same-origin',
        body : JSON.stringify(data),

        }).then(response => response.json())

    }
}


