import React from 'react'
import {NavLink} from 'react-router-dom'
import {connect} from 'react-redux'

 function Header(cart) {
  return (
    <div className="Header">
      <div className="Header-top">
        <ul>
          <div  className="Registration">
            <li>Hi! <NavLink to ='/'> Sign in</NavLink> or </li>
            <li><NavLink to ='/'> Register</NavLink></li>
          </div>
          <li><NavLink to ='/'>Daily Deals</NavLink></li>
          <li><NavLink to ='/'>Sell</NavLink></li>
          <li><NavLink to ='/'>Help & Contact</NavLink></li>
        </ul>
        <div className="cartBag">
          <div className="cartBagImg">
            <NavLink to ='/cart'>
              <span className="quantityProducts"><p>{cart.count}</p></span>
              <img alt="" src="./products/icons-bag.png"></img>
            </NavLink>
          </div>
          <span className="priceTag"><p>Your Bag ${cart.price}</p></span>
        </div>
      </div>
      <div className="Header-botom">
        <NavLink to ='/'>
         <p className="Logo">SHOPMATE</p>
        </NavLink>
        <ul>
          <li><NavLink to ='/'>Women</NavLink></li>
          <li><NavLink to ='/'>Man</NavLink></li>
          <li><NavLink to ='/'>Kids</NavLink></li>
          <li><NavLink to ='/order'>Order</NavLink></li>
        </ul>
        <div className="searchInput">
          <img alt="" src="./products/icons-close-small-white.png" className="closeSearchInput"></img>
          <img  alt="" src="./products/icons-search-white.png" className="searchIcon"></img>
          <input  type="text" placeholder="Search"></input>
        </div>
      </div>
    </div>
  )
}

function mapStateToProps(state){
  return{
    cart: state.cart
  }
}

export default connect(mapStateToProps)(Header)
