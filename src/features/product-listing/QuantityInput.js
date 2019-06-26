import React, { Component } from 'react'

 class QuantityInput extends Component {

    constructor(props) {
        super(props);
        this.state = {value : 
            (this.props.cartItem && this.props.cartItem.quantity) || 0}
    }

    handleChange = (event) => {
        if (event.target.value > -1 ) {
            if(event.target.value > 100 )
            {
                this.setState({value:99});

            }
            else
            this.setState({value: event.target.value});
        }
    }

     handleSubmit = () => {
      this.props.product.quantity = this.state.value
     return  this.props.product
    }

    render() {
        return (
            <div className="Quantity" >
                <input         
                className="Quantity_Input" 
                type="number"  
                value={this.state.value}
                onChange={this.handleChange} />
                { this.state.value > 0? 
                    <button className="submit_item_btn"  onClick={()=> this.props.addMultipleitemsToCart(this.handleSubmit())}>submit</button>
                    :null        
                }
            </div>
        )
    }
}

export default (QuantityInput)
      
      