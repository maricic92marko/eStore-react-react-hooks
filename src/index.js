import React from 'react';
import ReactDOM from 'react-dom';
import {BrowserRouter} from 'react-router-dom';
import Store from './config/Store';
import './index.css';
import App from './App';

const Index = () => (
    <BrowserRouter>
        <Store>      
            <App />
        </Store>
    </BrowserRouter>
)
        
ReactDOM.render(<Index/>, document.getElementById('root'));

