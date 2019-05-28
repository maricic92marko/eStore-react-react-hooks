import React from 'react';
import {Switch, Route} from 'react-router-dom';
import HomePage from './pages/HomePage';
import CartPage from './pages/CartPage';
import OrderPage from './pages/OrderPage';

const Router = () => (
    
    <Switch>
        <Route exact path ='/' component={HomePage}/>
        <Route exact path ='/cart' component={CartPage}/>
        <Route exact path ='/orders/:id' component={OrderPage}/>
    </Switch>
    
)

export default Router;

