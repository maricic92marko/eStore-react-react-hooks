import React from 'react'
import {NavLink} from 'react-router-dom'
import ProductMenu from '../productsMenu'

export default class hamburgerMenu extends React.Component{
    constructor(props)
    {
        super(props)
        this.state = {menu_toggle : false}
    }

    toggleMenu = () =>{
        debugger
        this.setState({menu_toggle : this.state.menu_toggle? false : true })
    }

    render(){
        return (
            <div className="Hambrger-Menu-Container">
                <div onClick={this.toggleMenu} className="Hambrger-Menu">
                    <div className="Hambrger-Menu-Icon"></div>
                    <div className="Hambrger-Menu-Icon"></div>
                    <div className="Hambrger-Menu-Icon"></div>
                </div>
                {
                    this.state.menu_toggle?
                    <div className="Hambrger-Menu-List">
                        <ul>
                        
                            <li><NavLink to ='/'>Women</NavLink></li><br /> 
                            <li><NavLink to ='/'>Man</NavLink></li><br /> 
                            <li><NavLink to ='/'>Kids</NavLink></li><br /> 
                            <li><NavLink to ='/'>Help & Contact</NavLink></li><br /> 
                            <li><NavLink to ='/orders/:id'>Order</NavLink></li><br /> 
                            <li><NavLink to ='/cart'>Cart</NavLink></li><br /> 
                            <li>
                                <div>
                                    <ProductMenu/>
                                </div>
                            </li>
                        </ul>
                    </div>
                    : null
                }
            </div>
        )
    }
}
