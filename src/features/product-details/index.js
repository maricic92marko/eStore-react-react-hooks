import React from 'react'
import {connect} from  'react-redux'
import QuantityInput from '../product-listing/QuantityInput'

class  ProductDetails extends React.Component {
    render()
    {
        const {productIdReducer,productsStateId} = this.props
        debugger
        
        let product_id = this.props.product_id
        if(productsStateId  && !product_id)
        { 
            product_id = productsStateId
        }
        if(product_id)
        { 
            productIdReducer(product_id)
        }
        const product = this.props.products.filter(product => product.id === parseInt(product_id))[0]
        return (
            <div className='product-item-description'>
                <h3>{product.name}</h3>
                <h3>{product.price}</h3>
                <img 
                    alt={''}
                    title={product.name}
                    src={product.image}
                />
                <br></br>
                <p>{product.description}</p>
                <QuantityInput
                product={product}
                addToCart={this.props.addToCart}
                cartItem={this.props.cart.filter(cartItem =>cartItem.id === product.id)[0]}
                addMultipleitemsToCart={this.props.addMultipleitemsToCart}
                removeFromCart={this.props.removeFromCart}
                />
            

            </div>
        )
    }
}

function mapStateToProps(state){
    debugger
    return {
        cart: state.cart,
        products: state.products,
        productsStateId : state.product_id
    }
}

function mapDispatchToProps(dispatch){
    
    return{
        productIdReducer: (id)=>{
            debugger
            dispatch({ type: 'ID', payload: id})
        },
        removeFromCart: (item)=>{
            dispatch({type:'REMOVE',payload:item})
        },
        addMultipleitemsToCart: (item)=>{
            dispatch({type: 'ADDMULTIPLE', payload:item})
        }
    }
}

export default connect(mapStateToProps,mapDispatchToProps)(ProductDetails)