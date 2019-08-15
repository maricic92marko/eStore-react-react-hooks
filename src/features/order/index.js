import React from 'react'
import FetchApi from '../../modules/Fetch-Api'
import CheckOut from '../checkout'

class Order extends React.Component{
    //state = {order: null}




    componentDidMount(){
        
        const {changeOrder,products} = this.props
        if(!products)
        {  
            const url =" http://localhost:5000/user_order_list"+this.props.id
            FetchApi('get', url)
            .then(json => {
                console.log(json)
                
                changeOrder(json)
            })
        
        }   
    }

    render(){
        return <div>
            <CheckOut/>
        </div>

    }
}


export default Order