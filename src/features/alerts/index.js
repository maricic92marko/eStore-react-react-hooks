import React, { Component } from 'react'
import FetchApi from '../../modules/Fetch-Api'
import  { Redirect } from 'react-router-dom'

export default class index extends Component {


    
    componentDidMount(){
        debugger
        if(this.props.alert.length >0 ){
            const url =" http://localhost:5000/cancel_order"+this.props.alert
            FetchApi('get', url)
            .then(json => {
                debugger
                alert(json.result)
            })
        }
    }
    render() {
        return (
            <div>
                <Redirect to='/'/>
            </div>
        )
    }
}
