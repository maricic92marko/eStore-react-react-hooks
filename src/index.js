import React from 'react';
import ReactDOM from 'react-dom';
import {BrowserRouter} from 'react-router-dom';
import {Provider} from 'react-redux';
import Store from './config/Store';
import './index.css';
import App from './App';

const app =    <Provider store={Store}>
                    <BrowserRouter>
                        <App />
                    </BrowserRouter>
                </Provider>
           
ReactDOM.render(app, document.getElementById('root'));

