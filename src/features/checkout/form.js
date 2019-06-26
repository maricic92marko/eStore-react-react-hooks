import React from 'react'
import {Field, reduxForm} from 'redux-form'



function CheckoutForm(props) {
    const {handleSubmit} = props
  return <div>
      <form  onSubmit={handleSubmit}>
          <div >
            <lable htmlFor="order[name]">Your name</lable> <br/>
          <Field name="order[name]" component="input" type="text"/>
          </div>
          <div >
            <lable htmlFor="order[email]">Your email</lable> <br/>
          <Field name="order[email]" component="input" type="email"/>
          </div>
          <div>
              <button type="submit">Submit order</button>
          </div>
      </form>
    </div>
  
}

CheckoutForm = reduxForm({
    form: 'checkout'
})(CheckoutForm)

export default CheckoutForm