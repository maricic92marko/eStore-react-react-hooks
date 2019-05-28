import fetch from 'isomorphic-fetch'
require('es6-promise').polyfill()



export default function fetchApi(metod, url, data) {
    const body = metod.toLowerCase() === 'get' 
    ? {} : {body : JSON.stringify(data)}

    return fetch(url,{
        metod,
        headers:{
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-Requested-With': 'XMLHttpRequest'
        },
        credentials: 'same-origin',
        ...body,

    }).then(response => response.json())
}


