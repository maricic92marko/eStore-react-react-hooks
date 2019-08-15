import React from 'react'
import {NavLink} from 'react-router-dom'
import ProductMenu from '../productsMenu'
import  { Redirect } from 'react-router-dom'

export default class hamburgerMenu extends React.Component{
    constructor(props)
    {
        super(props)
        this.state = {menu_toggle : false ,product_menu_toggle: false }
    }
    
      onMouseLeaveHandlerProducts = () =>{
          
          this.setState({ product_menu_toggle  : false   })
    
      }
    
       onMouseClickHandlerProducts = () =>{
          
          this.setState({ product_menu_toggle  :  this.state.product_menu_toggle?false:true })
      }

     toggleHamburgerMenu = () =>{
        
        this.setState({menu_toggle : this.state.menu_toggle ? false : true })
        if(!this.state.menu_toggle)
        {
            this.setState({ product_menu_toggle  :false})
        }
    }
    onMouseLeaveHamburgerMenu =()=>{
        
            this.setState({ menu_toggle  :false})
    }

    onMouseEnterHandlerProducts=()=>
    {
        this.setState({ menu_toggle  :true})
    }


    render(){
        window.onscroll =()=>this.onMouseLeaveHamburgerMenu()

        try{
        return (
            <div className="Hambrger-Menu-Container">
                <div onClick={()=>this.toggleHamburgerMenu()} 
               
                className="Hambrger-Menu">
                    <div className="Hambrger-Menu-Icon"></div>
                    <div className="Hambrger-Menu-Icon"></div>
                    <div className="Hambrger-Menu-Icon"></div>
                </div>
                {
                    this.state.menu_toggle?
                    <div  
                    

                    onMouseLeave={()=>this.onMouseLeaveHamburgerMenu()}
                     className="Hambrger-Menu-List">
                        <ul>
                            <li
                            className="hamburger-menu-link"
                             onClick={()=>this.onMouseClickHandlerProducts()}>
                                Proizvodi
                            </li>
                            <li className="hamburger-menu-link"><NavLink  to ='/'>Početna</NavLink></li>
                            <li className="hamburger-menu-link"><NavLink  to ='/InfoContact'>Informacije i kontakti</NavLink></li>
                            <li className="hamburger-menu-link"><NavLink  to ='/cart'>Korpa</NavLink></li>

                        </ul>
  
                    </div>
                    : null
                }
                { this.state.product_menu_toggle &&  this.state.menu_toggle ?
                    <div
                    onScroll={()=>this.onMouseLeaveHandlerProducts()}
                    onMouseEnter={()=>this.onMouseEnterHandlerProducts()}
                    onMouseLeave={()=>this.onMouseLeaveHandlerProducts()} 
                    className="Hambrger-Menu-List-ProductMenu">
                      
                        <ProductMenu 
                         classes={this.props.classes}
                         products={this.props.products} />
                    </div>:null}
            </div>
        )
    }
    catch(e){ 
        return <Redirect to='/'/>
    }
    }
}
