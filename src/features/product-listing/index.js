import React from 'react'
import ProductListItem from './ProductListItem'
import { connect } from 'react-redux';
import FetchApi from '../../modules/Fetch-Api'

class ProductListing extends React.Component {
    componentDidMount(){
        const {loadProducts,classReducer,products} = this.props
        if(products.length < 1)
        {debugger
            FetchApi('get', 'http://localhost:5000/initial_state')
            .then(json => {
                debugger
                loadProducts(json.products)
                classReducer(json.classes)
            })
        }
        debugger
      
    }
    render(){
        debugger
        const{addMultipleitemsToCart,removeFromCart, cart} = this.props
        let {products,currentClass} = this.props
        debugger
  
        let product_class = this.props.product_class
        if(currentClass  && !product_class)
        { 
            product_class = currentClass
        }
        debugger
        if(product_class)
        {
        products = products.filter(product => product.class_id === product_class)
        }
       
        return  (
            <div className='product-listing'>
                {
                products.map( product =>
                    <ProductListItem 
                    product={product} 
                    addMultipleitemsToCart={addMultipleitemsToCart}
                    removeFromCart={removeFromCart}
                    cartItem={cart.filter(cartItem =>cartItem.id === product.id)[0]}
                    key={product.id}
                    />)
                }
            </div>
        )
    }
}

function mapStateToProps(state){
    return {
        cart: state.cart,
        products: state.products,
        currentClass : state.currentClass
    }
}

function mapDispatchToProps(dispatch){
    
    return{
        loadProducts: (products)=>{
            dispatch({ type: 'LOAD', payload: products})
        },        
        removeFromCart: (item)=>{
            dispatch({type:'REMOVE',payload:item})
        },
        addMultipleitemsToCart: (item)=>{
            dispatch({type: 'ADDMULTIPLE', payload:item})
        },
        classReducer:(product_class)=>{
            debugger
            dispatch({type:'CLASS',payload:product_class})
        }
    }
}

export default connect(mapStateToProps,mapDispatchToProps)(ProductListing)