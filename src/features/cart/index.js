import React,{useContext} from 'react'
import QuantityInput from '../product-listing/QuantityInput'
import {NavLink} from 'react-router-dom'
import  { Redirect } from 'react-router-dom'
import {CartContext} from '../../config/Store'
import {removeAllFromCart} from './cartFunctions'

function Sort(items){
    debugger
    const cart = [].concat(items).sort((a, b)=> 
         a.id - b.id
      )
      return cart
}

function Cart(props) {
    const [cart, setCart] = useContext(CartContext)

    const handleSubmit = (item) =>
    {
        const removeCart = removeAllFromCart(cart,item)   
        setCart(removeCart)
     /*   if(removeCart)
        {
            window.location.href = "http://localhost:3000/cart";

        }*/
    }

    try{
    return ( <div className="cart">
                {  
        cart && cart.length && window.location.pathname === '/cart'?   
          <NavLink className="CheckOutLink" to ='/checkout'>Naruči</NavLink>:null
        }
    {
        cart && cart.length ?
        <table className="cartTable">


            <tbody>
                {
                    Sort(cart).map(item=> 
                    <tr>
                        <td><img alt="" className="cartImg" src={item.image}></img>
                        </td>
                        <td>
                            <QuantityInput
                            product={item}
                            setCart={(value)=>setCart(value)}
                            cart={cart}
                            cartItem={item}
                            key={item.cartItemId}
                            />
                        </td>
                        <td>{item.name}</td>
                        <td>{item.metricUnitName +': '+ item.price}RSD</td>
                        <td> Ukupno:{ Math.round((item.priceSum ) * 100) / 100}RSD</td>
                        <td>
                            <button
                            data-value ={item}
                            className="remove_item_btn"
                            onClick={() =>handleSubmit(item)}> 
                                Ukloni iz korpe
                            </button>
                        </td>
                    </tr>)
                }
            </tbody>
        </table> : <h2>Korpa je prazna</h2>
    }
 
    </div>)
        }
        catch(e){ 
            return <Redirect to='/'/>
        }
}


export default Cart