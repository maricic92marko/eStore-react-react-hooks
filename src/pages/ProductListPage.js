import React from 'react'
import ProductListing from '../features/product-listing'


export default function ProductListPage(props) {
  debugger
  return ( <div>
    <ProductListing product_class={props.location.product_class}/>
    <h2>Home page</h2>
    </div>
  )
}
