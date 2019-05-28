import {createStore, combineReducers} from 'redux'
import CartReducer from '../features/cart/reducer'
import productsReducer from '../features/product-listing/reducer'
import {reducer as formReducer} from 'redux-form'

const RootReducer = combineReducers({
products: productsReducer,
cart: CartReducer,
form: formReducer
})

const Store = createStore(
    RootReducer,
    window.__REDUX_DEVTOOLS_EXTENSION__ &&  window.__REDUX_DEVTOOLS_EXTENSION__()
);

export default Store;

