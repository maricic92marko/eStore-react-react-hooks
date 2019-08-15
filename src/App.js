import React,{ useContext}  from 'react';
import { withRouter} from 'react-router-dom';
import {CartContext,ProductsContext,ClassesContext} from './config/Store'
import Router from './Router';
import Header from './pages/Header';
import Footer from './pages/Footer';

const  count = (cart) =>{
  debugger
  if(cart && cart.length > 0)
  {
    return cart.reduce((acc, item)=>{

      return parseInt(acc) + parseInt(item.quantity)
    }, 0)
  }
  else
  {
    return 0
  }

}

const  price = (cart) =>{
  debugger
  if(cart && cart.length > 0)
  {
    return cart.reduce((acc, item)=>{
      return Math.round((acc +  item.priceSum) * 100) / 100
    }, 0)
  }
  else
  {
    return 0
  }
}

const App = () => {
  debugger
  const [cart] = useContext(CartContext)
  const [products] = useContext(ProductsContext)
  const [classes] = useContext(ClassesContext)

  debugger
    return (
      <div className="page-container">
      <header>
      <Header count={parseInt(count(cart))}
      price={price(cart)}
      products={products}
      classes={classes}/>
      </header>
      <div className="page-body" >
        <Router/>
        </div>
        <footer>
        <Footer/>
        </footer>
      </div>
    )
}

export default withRouter(App);

