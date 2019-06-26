import {createStore, combineReducers} from 'redux'
import CartReducer from '../features/cart/reducer'
import {setClassReducer,productsReducer, classReducer} from '../features/product-listing/reducer'
import {reducer as formReducer} from 'redux-form'
import productIdReducer from '../features/product-details/reducer'

function saveToLocalStorage(state){
    try{
        const serializedState = JSON.stringify(state)
        localStorage.setItem('state',serializedState)
    }catch(e)
    {
        console.log(e)
    }
}

function loadFromLocalStorage(){
    try{
        const serializedState = localStorage.getItem('state') 
        if(!serializedState) return undefined
        return JSON.parse(serializedState)
    }catch(e)
    {
        console.log(e)
        return undefined
    }
}

const RootReducer = combineReducers({
    products: productsReducer,
    currentClass: setClassReducer,
    cart: CartReducer,
    classes : classReducer,
    product_id : productIdReducer,
    form: formReducer

})

const presistedState = loadFromLocalStorage()

const Store = createStore(
    RootReducer,
    presistedState,
    window.__REDUX_DEVTOOLS_EXTENSION__ &&  window.__REDUX_DEVTOOLS_EXTENSION__()
);

Store.subscribe(() => saveToLocalStorage(Store.getState()))

export default Store;

