import React, { Component } from 'react'
import { connect } from 'react-redux';

class ProductMenu extends Component {

    constructor(props)
    {
        super(props)
        this.state = {class_menu_toggle : false , product_menu_toggle: false, class_id : 0}
    }

    toggleClassMenu = () =>{
        debugger
        this.setState({ class_menu_toggle : this.state.class_menu_toggle? false : true })
    }

    toggleProductMenu = () =>{
        debugger
        this.setState({class_id : this.props.product_class.id ,product_menu_toggle : this.state.product_menu_toggle? false : true })
    }

    render() {
        return (
            <div className="products-drop-menu"> 
            <p className="products-link" onClick={this.toggleClassMenu} >Products</p>
           
                {  
                this.state.class_menu_toggle?
                    <ul className="class-drop-menu-list">
                        {
                            this.props.product_class.map(pClass => 
                            <li onClick={this.toggleProductMenu} className="class-drop-menu-list-item">{pClass.class_name}
                              { 
                                this.state.product_menu_toggle?
                                <ul className="products-drop-menu-list">
                                    { this.props.products.filter(product => product.class_id === this.state.class_id)
                                    .map(product => 
                                    <li>{product.name}</li>
                                    )}
                                </ul>:null
                                }
                            </li>)
                            
                        }
                    </ul> :null     
                }    
                    
            </div>
        )
    }
}

function mapStateToProps(state){
    return {
        cart: state.cart,
        products: state.products,
        product_class: state.classes
    }
}

function mapDispatchToProps(dispatch){
    
    return{
        
        loadProducts: (products)=>{
            
        dispatch({ type: 'LOAD', payload: products})
        },
        classReducer:(product_class)=>{
            debugger
            dispatch({type:'CLASS',payload:product_class})
        },
        setClassReducer:(class_id)=>{
            debugger
            dispatch({type:'SETCLASS',payload:class_id})
        }
    }
}


export default connect(mapStateToProps,mapDispatchToProps)(ProductMenu)