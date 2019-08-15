import React,{useContext} from 'react'
import ScrollUpButton from "react-scroll-up-button";
import {NavLink} from 'react-router-dom'
import {CurrentClassContext,StoreInfoContext,ClassesContext} from '../config/Store'

function Footer(props) {

  const [store_info] = useContext(StoreInfoContext)
  const [product_class] = useContext(ClassesContext)
const [currclass, setCurrClass ] = useContext(CurrentClassContext)
const handleClickFb = (e) => {
  let url = 'https://www.facebook.com/sharer/sharer.php?u=' + window.location.href
    window.open(url,
        'facebook-share-dialog',
        'width=800,height=600'
    );
    return false;
};

const handleClickTw = (e) => {
    let url = "https://twitter.com/share?url=" + window.location.href
      window.open(url);
      return false;
  };
    
  const handleClickLi = (e) => {
    let url = 'https://www.linkedin.com/shareArticle?mini=true&amp;url=' + window.location.href
      window.open(url);
      return false;
  };  
    return (
        <div className="footer-part">
          <div className="footerlinkList">
            <p>Proizvodi</p>
               
              {
                             product_class.map(pClass => 
                             <NavLink key={pClass.id} className="footerlinks"
                         onClick={()=>{ setCurrClass(pClass.id)}} 
                         to ={{
                         pathname:'/ProductList',
                         product_class:pClass.id
                        }} >
                         {pClass.class_name}
                         </NavLink>
                         )}
          </div>
        <div className="footerPageLinks">
              <NavLink  to ='/'>Početna</NavLink>
              <NavLink  to ='/InfoContact'>Informacije i kontakti</NavLink>
              <NavLink  to ='/cart'>Korpa</NavLink>
              <NavLink to={{pathname:'/ProductList',product_class: 'svi',}}> 
                Svi proizvodi
              </NavLink>
        </div> 
        <div className="footerContacts">
            <p>Email:{' '+store_info.store_mail}</p>
            <p>Telefon:{' '+store_info.store_phone}</p>
            <p>Adresa:{' '+store_info.store_address}</p>
        </div>
        <div className="shareButtons">
                <span onClick={handleClickFb} title="Share on Facebook"><img alt="" src="/products/icons-facebook-grey.png"/></span>
                <span onClick={handleClickTw} title="Share on Twitter"><img alt="" src="/products/icons-twitter-grey.png"/></span>
                <span onClick={handleClickLi} title="Share on LinkedIn"><img alt="" src="/products/icons-linkedin-grey.png"/></span>
        </div>
          <ScrollUpButton />
        </div>
    )
}


export default Footer