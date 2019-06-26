import React from 'react'
import QuantityInput from './QuantityInput'
import {NavLink} from 'react-router-dom'

export default class ProductListItem extends React.Component  {

  constructor(props) {
    super(props)
    this.state = { isAddTripState: false }
  }

  showDesc = () => {
    this.setState({
      isAddTripState : this.state.isAddTripState ? false :true
     
    })
  }
  render(){

  return (
    <div  className='product-list-item'>
      

      <h3>{this.props.product.name}</h3>
      <img height={100}
        alt={''}
        title={this.props.product.name}
        src={this.props.product.image}
      />
      <br></br>
      
      { this.props.product.description  ?
      <button >      
        <NavLink to={{
          pathname:'/ProductDetails',
          product_id: this.props.product.id
          }}>Show description
         </NavLink>
      </button> : null}
      {this.state.isAddTripState &&  <div>{this.props.product.description}</div>}
     
      <div>${this.props.product.price}</div>
      
        <QuantityInput
          product={this.props.product}
          cartItem={this.props.cartItem}
          addMultipleitemsToCart={this.props.addMultipleitemsToCart}
          removeFromCart={this.props.removeFromCart}
          />
    </div>
  )
  }
}
