import React from 'react'
import Order from '../features/order'

export default function OrdePage(props){

    return <div>
        <Order id={props.location.search}/>
    </div>
}