import React, { Component } from 'react'
import {NavLink} from 'react-router-dom'
import  { Redirect } from 'react-router-dom'

class ProductMenu extends Component {

    constructor(props)
    {
        super(props)
        this.state = {class_menu_toggle : false , product_menu_toggle: false, class_id : 0}
    }


    onMouseLeaveHandlerClass = () =>{
        if(!this.stateproduct_menu_toggle)
        {
            this.setState({ class_menu_toggle  :  false })

        }
    }

    onMouseEnterHandlerProduct = (id,length) =>{
        if(length > 0 )
        {
        this.setState({class_id : id ,product_menu_toggle :  true ,class_menu_toggle : true})
        }

    }

    onMouseLeaveHandlerProduct = (id) =>{

        this.setState({product_menu_toggle :  false })
    }

    render() {
        
        debugger
        try{
        return (
            <div  className="products-drop-menu"> 
                    <ul id="classList"  className="class-drop-menu-list"
                        onMouseLeave={this.onMouseLeaveHandlerClass}>
                        {
                            this.props.classes.map(pClass => 
                            <li onClick={()=>{this.onMouseEnterHandlerProduct(pClass.id,
                                this.props.products.filter(product => product.class_id === pClass.id).length?
                                this.props.products.filter(product => product.class_id === pClass.id).length :0
                                )}} onMouseLeave={()=>{this.onMouseLeaveHandlerProduct()}}
                             className="class-drop-menu-list-item">
                            {  
                            <p>{pClass.class_name}</p>
                            }
                            </li>)
                        }
                        <li className="class-drop-menu-list-item">
                        <NavLink to={{
                                pathname:'/ProductList',
                                product_class: 'svi',
                                }}> Svi proizvodi
                                </NavLink>
                           </li>
                    </ul>    
                { 
                    this.state.product_menu_toggle && this.state.class_menu_toggle?
                        <ul onMouseEnter={()=> this.onMouseEnterHandlerProduct(this.state.class_id,1)} 
                        onMouseLeave={()=>{this.onMouseLeaveHandlerProduct(this.state.class_id,1)}}
                        className="products-drop-menu-list">
                            { this.props.products.filter(product => product.class_id === this.state.class_id )
                                .map(product => 
                                <li>
                                
                                <NavLink to={{
                                pathname:'/ProductDetails',
                                product_id: product.id,
                                }}>{product.name}
                                </NavLink>
                                </li>
                                )}
                        </ul>:null
                }
            </div>
        )
    }
    catch(e){
             
        return <Redirect to='/'/>
    }
    }
}

export default ProductMenu