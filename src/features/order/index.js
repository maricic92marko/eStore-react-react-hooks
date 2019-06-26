import React from 'react'
import FetchApi from '../../modules/Fetch-Api'
import { connect } from 'react-redux';
import CheckOut from '../checkout'

class Order extends React.Component{
    //state = {order: null}




    componentDidMount(){
        debugger
        const {changeOrder,products} = this.props
        if(!products)
        {  
            const url =" http://localhost:5000/user_order_list"+this.props.id
            FetchApi('get', url)
            .then(json => {
                console.log(json)
                debugger
                changeOrder(json)
            })
        debugger
        }   
    }

    render(){
        debugger
       // const {order} = this.state
        return <div>
            <CheckOut/>
        </div>

    }
}

function mapStateToProps(state){
    return{
        cart: state.cart,
    }
}

function mapDispatchToProps(dispatch){
    debugger
    return{
        
        loadProducts: (products)=>{
            debugger
        dispatch({ type: 'LOAD', payload: products})
        },
        addToCart:(item)=>{
            dispatch({type:'ADD',payload:item})
        },
        removeFromCart: (item)=>{
            dispatch({type:'REMOVE',payload:item})
        },
        addMultipleitemsToCart: (item)=>{
            debugger
            dispatch({type: 'ADDMULTIPLE', payload:item})
        },
        changeOrder: (item)=>{
            debugger
            dispatch({type: 'CHANGEORDER', payload:item})
        }
        
    }
}

export default connect(mapStateToProps,mapDispatchToProps)(Order)