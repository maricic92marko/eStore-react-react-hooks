import React, { Component } from 'react'
import  { Redirect } from 'react-router-dom'
import {addToCart} from '../cart/cartFunctions'
 class QuantityInput extends Component {

    constructor(props) {
        super(props);
        if(this.props.cartItem)
        {
        this.state = {
            duzina :  this.props.cartItem.duzina,
            sirina :  this.props.cartItem.sirina,
            metar:  this.props.cartItem.metar,
            komad:  this.props.cartItem.quantity
        }
        }else
        {
        this.state = {
            duzina :  undefined,
            sirina :  undefined,
            metar:  undefined,
            komad:  undefined
            }
        }
        
    }

    handleChange = (event) => {
        debugger
        if (event.target.value > -1 ) {
            let name = event.target.name
            if(event.target.value > 100 )
            {
                this.setState({[name]:99});
            }
            else
            {
                this.setState({[name]: event.target.value});
            }
        }
    }

     handleSubmit = () => {
        debugger
        let val;
        let priceSum;
        if(this.props.product.metric_unit ==='m2')
        {   
            if((!this.state.duzina || this.state.duzina === 0)||
            (!this.state.sirina || this.state.sirina === 0))
            {
                alert('Morate uneti dužinu i širinu!')
                return
            }
            val = this.state.duzina * this.state.sirina;
            if( val < 100)
            {
                alert('Vaša porudžbina će biti po ceni od 1 metara kvadratnog jer je to najmanja obračuska jedinica ovog proizvoda za naručivanje!')
                val = 100;
            }
            priceSum = val * Math.round(this.state.komad) * this.props.product.price
        }
        else if(this.props.product.metric_unit ==='m')
        {
            if(!this.state.metar || this.state.metar === 0)
            {
                alert('Morate uneti dužinu!')
                return
            }
            val = this.state.metar 
            if( val < 150)
            {
                alert('Vaša porudžbina će biti po ceni od 1.5 metara jer je to najmanja obračuska jedinica ovog proizvoda za naručivanje!')
                val = 150;
            }
            priceSum = val * Math.round(this.state.komad) * this.props.product.price
        }
        else
        {   val =  Math.round(this.state.komad)

            priceSum = val *  this.props.product.price
        }

         if(val< this.props.product.min_qty)
         {
            this.props.product.quantity = 0;
            alert('Ne mozete naručiti manje od ' + this.props.product.min_qty+' ' +this.props.product.metric_unit)
         }
         else
         {
            debugger
            this.props.product.quantity = Math.round(this.state.komad)
            this.props.product.duzina =this.state.duzina
            this.props.product.sirina =this.state.sirina
            this.props.product.metar =this.state.metar
            this.props.product.priceSum = priceSum;
            debugger
    
            this.props.setCart(addToCart(this.props.cart, this.props.product))
            this.setState({
                duzina :  undefined,
                sirina :  undefined,
                metar:  undefined,
                komad:  undefined
                })
            
         }
         

    }


    render() {
        try{
        return (
            <div className="Quantity" >
{
    this.props.product.metric_unit ==='m'?

                <div className="Quantity_m_wrapper">
                    <input         
                    className="Quantity_Input" 
                    name='metar'
                    type="number"  
                    value={this.state.metar}
                    onChange={this.handleChange} 
                    placeholder='cm'
                    /><br></br>
                    <p>cm</p><br></br>
                </div>:null
                }
                {     this.props.product.metric_unit ==='m2'?

                <div className="Quantity_m2_wrapper">
                    <input         
                    className="Quantity_Input" 
                    name='duzina'
                    type="number"  
                    value={this.state.duzina}
                    onChange={this.handleChange} 
                    placeholder='cm'
                    /><br></br>
                    <p>Dužina cm</p><br></br>
                    <input         
                    className="Quantity_Input" 
                    name='sirina'
                    type="number"  
                    value={this.state.sirina}
                    onChange={this.handleChange} 
                    placeholder='cm'
                    /><br></br>
                    <p>Širina cm</p><br></br>
                </div>:null}
                    
                <div className="Quantity_komad_wrapper">
                    <input         
                        className="Quantity_Input" 
                        name='komad'
                        type="number"  
                        value={this.state.komad}
                        onChange={this.handleChange} 
                    /><br></br>
                    <p>Količina</p>
                </div>
                { this.state.komad > 0? 
                    <button className="submit_item_btn"  onClick={()=>this.handleSubmit()}>Dodaj u korpu</button>
                    : <button className="submit_item_btn" onClick={()=>alert('morate uneti količinu!')}>Dodaj u korpu</button>       
                }
            </div>
        )
    }
    catch(e){
             
        return <Redirect to='/'/>
    }
    }
}

export default (QuantityInput)
      
      