import React from 'react';
import {Switch, Route} from 'react-router-dom';
import HomePage from './pages/HomePage';
import CartPage from './pages/CartPage';
import OrderPage from './pages/OrderPage';
import CheckOutPage from './pages/CheckoutPage'
import Alerts from './pages/AlertPage'
import ProductDetailsPage from './pages/ProductDetailsPage'
import ProductListPage from './pages/ProductListPage'

const Router = () => (
    
    <Switch>
        <Route exact path ='/' component={HomePage}/>
        <Route exact path ='/cart' component={CartPage}/>
        <Route exact path ='/orders' component={OrderPage}/>
        <Route exact path ='/checkout' component={CheckOutPage}/>
        <Route exact path ='/alerts' component={Alerts}/>
        <Route exact path ='/ProductList' component={ProductListPage}/>
        <Route exact path ="/ProductDetails" component={ProductDetailsPage}  />
    </Switch>
    
)

export default Router;

