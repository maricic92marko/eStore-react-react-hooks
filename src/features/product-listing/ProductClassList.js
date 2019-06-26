import React, { Component } from 'react'
import { connect } from 'react-redux';
import FetchApi from '../../modules/Fetch-Api'
import {NavLink} from 'react-router-dom'
import ImageSlider from '../../features/imageSlider'

class ProductClassList extends Component {

    componentDidMount(){
        debugger
        const {loadProducts,classReducer,products} = this.props
        if(products.length < 1)
        {debugger
            //FetchApi('get', 'https://student-example-api.herokuapp.com/v1/products.json')
            FetchApi('get', 'http://localhost:5000/initial_state')
            .then(json => {
                debugger
                loadProducts(json.products)
                classReducer(json.classes)
            })
            debugger
        }
    }
    
    render() {
        let {product_class} = this.props

        return (
            <div className="ImageSlider-ProductClassList">
                <ImageSlider/>
            <div className="ProductClassList">
                
                    { product_class.map(pClass => 
                         <NavLink className="ProductClassLink"
                         onClick={()=>{this.props.setClassReducer(pClass.id)}} 
                         to ={{
                         pathname:'/ProductList',
                         product_class:pClass.id
                        }} >
                         <p>{pClass.class_name}</p>
                         <img src={pClass.image_path}/>
                         </NavLink>
                    )
               }
            </div>
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

export default connect(mapStateToProps,mapDispatchToProps)(ProductClassList)