import React from 'react'
import ProductDetails from '../features/product-details'


export default function ProductDetailsPage(props) {
  debugger
  return ( 
  <div>
 
    <ProductDetails product_id={props.location.product_id}/>
    <h2>Product page</h2>
  </div>
  )
}
