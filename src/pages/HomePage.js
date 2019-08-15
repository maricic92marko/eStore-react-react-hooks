import React,{useContext} from 'react'
import ProductClassList from '../features/product-listing/ProductClassList'
import  { Redirect } from 'react-router-dom'
import {ClassesContext} from '../config/Store'

function HomePage() {

  const [classes] = useContext(ClassesContext)

  try{
    return (<div className="home-page">
      {
        classes && classes.length >0 ?
        <ProductClassList/>:null
      }
    </div>)
  }
  catch(e){
     
    return <Redirect to='/'/>
  
}

}






export default HomePage
