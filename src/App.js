import React, { Component } from 'react';
import { withRouter} from 'react-router-dom';
import {connect} from 'react-redux';
import Router from './Router';
import Header from './pages/Header';
import Footer from './pages/Footer';

const  count = ({cart}) =>{
  return cart.reduce((acc, item)=>{

    return parseInt(acc) + parseInt(item.quantity)
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
      <Header count={parseInt(count(this.props))}
      price={price(this.props)}/>
      </header>
    
      <div className="page-body" >
        
        <Router/>
        </div>
        <Footer/>
      </div>
    )
  }
}

function mapStateToProps(state){
  return{
    cart: state.cart
  }
}

function mapDispatchToProps(dispatch){
    
  return{
       
      setCurrentClass: (product_class)=>{
          debugger
          dispatch({ type: 'CLASS', payload: product_class})
      },
      
      addMultipleitemsToCart: (item)=>{
          dispatch({type: 'ADDMULTIPLE', payload:item})
      }
  }
}

export default withRouter(connect(mapStateToProps,mapDispatchToProps)(App));

