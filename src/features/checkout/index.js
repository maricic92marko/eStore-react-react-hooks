import React from 'react'
import {connect} from 'react-redux'
import Cart from '../cart'
import CheckoutForm  from './form'
import fetchApi from '../../modules/Fetch-Api';

function submitOrder(values, cart){
  debugger
  if (values.order !== undefined) {
    
  const { email , name} = values.order
  if (email === undefined || name === undefined) {
    alert('You need to enter email and name')
  }
    else{
      if(cart.length < 1)
      {
        alert('Cart is empty')
      }
      else{
        
        fetchApi('POST', 'http://localhost:5000/createorder',{
                  order:{
                    name,
                    email,
                    order_items_attributes : cart.map(item => ({
                    product_id : item.id,
                    qty:item.quantity
                }))
              }
          }).then(json =>{
            debugger
            localStorage.clear();

            if (json.errors) {
              alert('something went wrong!')
              document.location.href = `http://localhost:3000`
              return
            }      
            alert(json)
            document.location.href = `http://localhost:3000`
            return
          })
  }
  }
}

  else{
      alert('You need to enter email and name')
  }
}

function Chekout(props) {
  const {cart} = props
  return <div>
      <div style={{border : '1px solid black'}}>
        <Cart/>
      </div>
      <CheckoutForm onSubmit={(values)=>submitOrder(values, cart)}/>
    </div>  
}

function mapStateToProps(state){
    return{
        cart: state.cart,
    }
}

export default connect(mapStateToProps)(Chekout)
