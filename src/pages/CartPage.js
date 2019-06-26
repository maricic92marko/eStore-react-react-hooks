import React from 'react'
import Cart from '../features/cart'
import {NavLink} from 'react-router-dom'
export default function CartPage(props) {
  return ( <div>
      <h1>Cart page</h1>
      <NavLink to ='/checkout'>Check out</NavLink>
      <Cart/>

    </div>
  )
}
