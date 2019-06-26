import React from 'react'
import Order from '../features/order'

export default function OrdePage(props){

    return <div>
        <h2>My order</h2>
        
        <Order id={props.location.search}/>
    </div>
}