import React from 'react'
import AddBtn from './BtnAdd'
import RemoveBtn from './BtnRemove'

export default function ProductListItem(props) {
  return (
    <div className='product-list-item'>
      <h3>{props.product.name}</h3>
      <img height={100}
        alt={''}
        title={props.product.name}
        src={props.product.image}
      />
      <div>{props.product.description}</div>
      <div>${props.product.price}</div>
      <div>
          <AddBtn 
          cartItem={props.cartItem} 
          product={props.product}
          addToCart={props.addToCart}
          />
          {
            props.cartItem
            ? <RemoveBtn 
              cartItem={props.cartItem} 
              product={props.product}
              removeFromCart={props.removeFromCart}
              />
            : null
          }
          
      </div>
    </div>
  )
}
