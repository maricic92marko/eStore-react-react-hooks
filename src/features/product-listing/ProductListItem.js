import React,{useContext} from 'react'
import QuantityInput from './QuantityInput'
import {NavLink} from 'react-router-dom'
import  { Redirect } from 'react-router-dom'
import {CartContext} from '../../config/Store'

export default function ProductListItem(props)  {

  const [cart, setCart] = useContext(CartContext)
  const cartItem = cart.filter(cartItem =>cartItem.id === props.product.id)[0]


  try{
  return (
  <div  className='product-list-item'>
      <h3>{ props.product.name}</h3>
      <img height={100}
        alt={''}
        title={ props.product.name}
        src={ props.product.image}
      />
      <br></br>
      {  
        props.product.description  ?
        <button className="product-list-item-btn" >      
          <NavLink to={{
            pathname:'/ProductDetails',
            product_id:  props.product.id
            }}>Show description
          </NavLink>
        </button> : null
      }

      {
        props.product.snizenje === 1 ?
        <div className="price-snizenje">{props.product.metric_unit +' -'+ props.product.price}RSD</div>
        :<div>{props.product.metricUnitName +' '+ props.product.price}RSD</div> 
      }
        <QuantityInput
          product={props.product}
          cart={cart}
          setCart ={(value)=>setCart(value)}
          />
  </div>
  )
    }
  catch(e){
             
    return <Redirect to='/'/>
}
}
