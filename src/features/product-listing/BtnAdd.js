import React from 'react'
import  { Redirect } from 'react-router-dom'

export default function AddButton(props){
    try{
        return (<button 
        onClick={() => {props.addToCart(props.product); props.addValue()}}
        >add to cart ({
            (props.cartItem && props.cartItem.quantity) || 0
        })</button>)
    }
    catch(e){ 
        return <Redirect to='/'/>
    }
}
