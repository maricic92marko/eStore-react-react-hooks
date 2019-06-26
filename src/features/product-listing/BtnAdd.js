import React from 'react'

export default function AddButton(props){

    return (<button 
    onClick={() => {props.addToCart(props.product); props.addValue()}}
    >add to cart ({
        (props.cartItem && props.cartItem.quantity) || 0
    })</button>)
}
