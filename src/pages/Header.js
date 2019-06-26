import React from 'react'
import {NavLink} from 'react-router-dom'
import {connect} from 'react-redux'
import SearchInput from '../features/searchInput'
import HamburgerMenu from '../features/hamburgerMenu'
import ProductMenu from '../features/productsMenu'

 class Header extends React.Component {
 
  constructor(props) {
    super(props);
    this.state = { width: 0, height: 0 };
    this.updateWindowDimensions = this.updateWindowDimensions.bind(this);
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
    return (
      <div className="Header-part">
        <div className="Header-top">
        {
            this.state.width >  900 ?
          <NavLink to ='/'>
            <p className="Logo">SHOPMATE</p>
          </NavLink> :null
        } 
          <div className="cartBag">
          <NavLink className="cartLink" to ='/cart'>
            <div className="cartBagImg">
            <img alt="" src="./products/Online-Shopping-Cart-PNG-Free-Commercial-Use-Image.png"></img>
                <span className="quantityProducts">{this.props.count}</span>
                
            </div>
            </NavLink>
            <span className="priceTag">Your Bag ${this.props.price}</span>

          </div> 

        </div>
        <div className="Header-botom">
        {
            this.state.width <  900 ?
            <HamburgerMenu/>:
            <ul>
              <li className="products-menu-link">  <ProductMenu/></li>
              <li className="bot-menu-link"><NavLink  to ='/'>Man</NavLink></li>
              <li className="bot-menu-link"><NavLink  to ='/'>Kids</NavLink></li>
              <li className="bot-menu-link"><NavLink  to ='/'>Help & Contact</NavLink></li>
              <li className="bot-menu-link"><NavLink  to ='/orders/:id'>Order</NavLink></li>
              <li className="bot-menu-link"><NavLink  to ='/cart'>Cart</NavLink></li>
            </ul>
            
        }
          <SearchInput/>

        </div>
      </div>
    )
  }
}

function mapStateToProps(state){
  return{
    cart: state.cart
  }
}

export default connect(mapStateToProps)(Header)
