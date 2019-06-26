import React, { Component } from 'react'
import FetchApi from '../../modules/Fetch-Api'
import {NavLink} from 'react-router-dom'


export default class searchInput extends Component {

    constructor(props) {
        super(props);
        this.state = {
        value :"",
        searcherItems : []
    }
        
       
    }
    

    searcherItems = []
    handleChange = (event) => {

           let value =event.target.value
            debugger
            if (event.target.value.length > 0) {
                
            
            const url =" http://localhost:5000/search_products?search_str="+event.target.value
            FetchApi('get', url)
             .then(json => {
                debugger
                 console.log(json)
                 this.setState({value: value,
                    searcherItems : JSON.parse(json)})
            })}else{
                this.setState({value: '',
                    searcherItems : []})
            }
           

            debugger
    }
    
     handleSubmit = () => {
        debugger
          return  this.state.value
    }

    render() {
        const claerSearch =() =>
        {
            let searchIn = document.getElementById("searchIn");
            searchIn.value = '';
            this.setState({
                value :"",
                searcherItems : []
            })

        }
        return (
            <div className="searchInput">
            <div className="searchInput-input">
            <img onClick={this.handleSubmit} alt="" src="./products/icons-search-white.png" className="searchIcon"></img>
            <input id="searchIn" onChange={this.handleChange} type="text" placeholder="Search"></input>
          </div>
 {         this.state.value.length > 0 ?
          <div onClick={claerSearch} 
          className="autocomplete_menu" >
            
           {   
              this.state.searcherItems.map(item => 
              <div>
                       <NavLink to={{
          pathname:'/ProductDetails',
          product_id: item.id
          }}>{item.name} </NavLink></div>
              ) }
            
          </div> : null}
          </div>
        )
    }
}
