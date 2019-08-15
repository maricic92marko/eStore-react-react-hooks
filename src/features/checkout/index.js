import React,{useContext} from 'react'
import Cart from '../cart'
import fetchApi from '../../modules/Fetch-Api';
import  { Redirect } from 'react-router-dom'
import {CartContext} from '../../config/Store'

const handleSubmit = (values,cart) =>{
  
  let val = document.forms["CheckoutForm"].getElementsByTagName("input");
  submitOrder(val, cart)
}

function submitOrder(values, cart){
  
  if (values !== undefined) {
    console.log(values.Firstname.value)
      if(cart.length < 1)
      {
        alert('Cart is empty')
        return <Redirect to='/Cart'/>

      }
      else{
        
        fetchApi('POST', 'http://localhost:5000/createorder',{
                  order:{
                    Firstname: values.Firstname.value,
                    Lastname: values.Lastname.value,
                    PravnoLice: values.PravnoLice.value,
                    phone: values.phone.value,
                    Grad: values.Grad.value,
                    Ulica: values.Ulica.value,
                    Drzava:  values.Drzava.value,
                    email: values.email.value,
                    order_items_attributes : cart.map(item => ({
                    product_id : item.id,
                    qty:item.quantity,
                    duzina:item.duzina,
                    sirina: item.sirina,
                    metar: item.metar
                }))
              }
          }).then(json =>{
            
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

function Chekout(props) {
  const [cart] = useContext(CartContext);
  
  return (<div className="Chekout">
<div className="CheckoutForm">
      <form name="CheckoutForm"  onSubmit={(values)=>handleSubmit(values,cart)}>
      <div >
            <lable htmlFor="Firstname">Ime* </lable> <br/>
          <input name="Firstname" maxlength="50" component="input" type="text" required/>
          </div>
          <div >
            <lable htmlFor="Lastname">Prezime* </lable> <br/>
          <input name="Lastname" maxlength="50" component="input" type="text" required/>
          </div>
          <div >
            <lable htmlFor="PravnoLice">Pravno Lice(Opciono)</lable> <br/>
          <input name="PravnoLice" maxlength="100" component="input" type="text"/>
          </div>
          <div >
            <lable htmlFor="email">Email*</lable> <br/>
          <input name="email" maxlength="50" component="input" type="email" required/>
          </div>
          <div >
            <lable htmlFor="phone">Telefon*</lable> <br/>
          <input name="phone" maxlength="50" component="input" type="text" required/>
          </div>
          <div >
            <lable htmlFor="Grad">Grad/Naselje*</lable> <br/>
          <input name="Grad" maxlength="50" component="input" type="text" required/>
          </div>
          <div >
            <lable htmlFor="Ulica">Ulica i broj*</lable> <br/>
          <input name="Ulica" maxlength="50" component="input" type="text" required/>
          </div>
          <div >
            <lable htmlFor="Drzava">Drzava*</lable> <br/>
          <input name="Drzava" maxlength="50" component="input" type="text" required/>
          </div>
          <div>
              <button className="SubmitOrder-btn" type="submit">Naruči</button>
          </div>
      </form>
    </div>

        <div className="Chekout-cart" >
        <Cart/>
      </div>
  </div> ) 
}


export default Chekout
