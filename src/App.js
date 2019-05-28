import React, { Component } from 'react';
import { withRouter} from 'react-router-dom';
import {connect} from 'react-redux';
import Router from './Router';
import Header from './pages/Header';
    
const  count = ({cart}) =>{
  return cart.reduce((acc, item)=>{
    return acc + item.quantity
  }, 0)
}

const  price = ({cart}) =>{
  return cart.reduce((acc, item)=>{
    return Math.round((acc + item.quantity * item.price) * 100) / 100 
  }, 0)
}


class App extends Component {
 
  render() {

    return (
      <div className="page-container">
      <header>
      <Header count={count(this.props)}
      price={price(this.props)}/>
      </header>
      <div className="page-body" >
        <h1>Products</h1>
        <Router/>
        </div>
      </div>
    )
  }
}

function mapStateToProps(state){
  return{
    cart: state.cart
  }
}

export default withRouter(connect(mapStateToProps)(App));

