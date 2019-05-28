import React from 'react'
import ProductListItem from './ProductListItem'
import { connect } from 'react-redux';
import FetchApi from '../../modules/Fetch-Api'

const   searchFor = (product, term)=>{
    if( product.name === 'I am Groot')
    {   
     return  product
    }
}

 class ProductListing extends React.Component {
  

     

    componentDidMount(){
        const {loadProducts} = this.props
        FetchApi('get', 'https://student-example-api.herokuapp.com/v1/products.json')
        .then(json => {
            loadProducts(json)
        })
    }

    render(){
        const{addToCart,removeFromCart, cart} = this.props
        let {products} = this.props
        
       // products = products.filter(product=> searchFor(product)   )
        return  (<div className='product-listing'>
        {
        products.map( product =>
            <ProductListItem 
            product={product} 
            addToCart={addToCart}
            removeFromCart={removeFromCart}
            cartItem={cart.filter(cartItem =>cartItem.id === product.id)[0]}
            key={product.id}
            />)
        }
        </div>)
  }
  
}

function mapStateToProps(state){
    return {
        cart: state.cart,
        products: state.products
    }
}

function mapDispatchToProps(dispatch){
    return{
        loadProducts: (products)=>{
        dispatch({ type: 'LOAD', payload: products})
    },
        addToCart:(item)=>{
            dispatch({type:'ADD',payload:item})
        },
        removeFromCart: (item)=>{
            dispatch({type:'REMOVE',payload:item})
        }
    }
}

export default connect(mapStateToProps,mapDispatchToProps)(ProductListing)