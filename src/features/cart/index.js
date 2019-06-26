import React from 'react'
import {connect} from  'react-redux'
import QuantityInput from '../product-listing/QuantityInput'

function Sort(items){
    debugger
    const cart = [].concat(items).sort((a, b)=> 
         a.id - b.id
      )
      return cart
}

function Cart(props) {
    return  <table className="cartTable">
        <thead>
            <tr>
                <th>Item</th>
                <th>Quantity</th>
                <th></th>
                <th></th>
            </tr>
        </thead>
        <tbody>
            {
                Sort(props.cart).map(item=> 
                <tr>
                    <td><img alt="" className="cartImg" src={item.image}></img>
                    <td>{item.name}</td></td>
                    
                    <td>{item.quantity}</td>
                    <td>
                        <QuantityInput
                        product={item}
                        addToCart={props.addToCart}
                        cartItem={item}
                        addMultipleitemsToCart={props.addMultipleitemsToCart}
                        removeFromCart={props.removeFromCart}
                        />
                    </td>
                    <td>
                        <button className="remove_item_btn"
                        onClick={() => props.removeAllFromCart(item)}>
                            Remove from cart
                        </button>
                    </td>
                </tr>)
            }
        </tbody>
    </table>
}

function mapStateToProps(state){
    return {
        cart : state.cart
    }
}

function mapDispatchToProps(dispatch){
    return{
        addToCart: (item) =>{
            dispatch({type:'ADD',payload:item})
        },
        removeFromCart: (item)=>{
            dispatch({type:'REMOVE',payload:item})
        },
        removeAllFromCart: (item)=>{
            dispatch({type:'REMOVEALL',payload:item})
        },
        addMultipleitemsToCart: (item)=>{
            debugger
            dispatch({type: 'ADDMULTIPLE', payload:item})
        }
    }
}

export default connect(mapStateToProps,mapDispatchToProps)(Cart)