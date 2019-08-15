import React from 'react'
import {NavLink} from 'react-router-dom'
import SearchInput from '../features/searchInput'
import HamburgerMenu from '../features/hamburgerMenu'
import ProductMenu from '../features/productsMenu'

 class Header extends React.Component {
 
  constructor(props) {
    super(props);
    this.state = { width: 0, height: 0,product_menu_toggle: false };
    this.updateWindowDimensions = this.updateWindowDimensions.bind(this);
  }


  onClickHandlerProducts = () =>{
      this.setState({ product_menu_toggle  : true  })
  }

  onMouseLeaveHandlerProducts = () =>{
      this.setState({ product_menu_toggle  : false  })
  }


  componentDidMount() {

    this.updateWindowDimensions();
    window.addEventListener('resize', this.updateWindowDimensions);
  }
  
  componentWillUnmount() {
    window.removeEventListener('resize', this.updateWindowDimensions);
  }
  
  updateWindowDimensions() {
    this.setState({ width: window.innerWidth, height: window.innerHeight });
  }

  render() {
    window.onscroll =()=>this.onMouseLeaveHandlerProducts()

    return (
      <div id="Header-part" className="Header-part">
        <div className="Header-top">
        {
            this.state.width >  900 ?
          <NavLink to ='/'>
          <img alt="logo" className="logoMali" src='/products/logoMali.png'></img>

            <img alt="logo" className="logoVeliki" src='/products/logoVeliki.png'></img>
            
          </NavLink> 
          :  this.state.width >350?
          <NavLink to ='/'>
          <img alt="logo" className="logoMali" src='/products/logoMali.png'></img>
         </NavLink>:null
        } 
          <div className="cartBag">
          <NavLink className="cartLink" to ='/cart'>
            <div className="cartBagImg">
            <img alt="" src="./products/Online-Shopping-Cart-PNG-Free-Commercial-Use-Image.png"></img>
                <span className="quantityProducts">{this.props.count}</span>
            </div>
            </NavLink>
            <span className="priceTag">Korpa {this.props.price} RSD</span>
          </div> 
        </div>
        <div className="Header-botom">
        {
            this.state.width <  900 ?
            <HamburgerMenu
            classes={this.props.classes}
            products={this.props.products}/>:
            <ul className="Header-botom-ul">
              <li className="products-menu-link"
                onClick={this.onClickHandlerProducts} 
              >Proizvodi</li>
              <li className="bot-menu-link"><NavLink  to ='/'>Početna</NavLink></li>
              <li className="bot-menu-link"><NavLink  to ='/InfoContact'>Informacije i kontakti</NavLink></li>
              <li className="bot-menu-link"><NavLink  to ='/cart'>Korpa</NavLink></li>
            </ul>
        }
      {  this.state.product_menu_toggle?
      <div
      onMouseEnter={this.onMouseEnterHandlerProducts} 
      onMouseLeave={this.onMouseLeaveHandlerProducts} 
      className="products-menu-container">
          <ProductMenu 
          classes={this.props.classes}
          products={this.props.products}/>
        </div> :null}
          <SearchInput products={this.props.products}/>

        </div>
      </div>
    )
  }
}



export default Header
