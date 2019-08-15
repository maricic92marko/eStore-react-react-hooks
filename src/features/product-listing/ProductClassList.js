import React,{useContext} from 'react'
import {NavLink} from 'react-router-dom'
import ImageSlider from '../../features/imageSlider'
import ProductListItem from '../../features/product-listing/ProductListItem'
import  { Redirect } from 'react-router-dom'
import {SliderImagesContext,CurrentClassContext,ProductsContext,ClassesContext} from '../../config/Store'
 
export default function ProductClassList(props) {
    const [currentClass, setCurrentClass] = useContext(CurrentClassContext)
    const [products] = useContext(ProductsContext);
    const [classes] = useContext(ClassesContext)
    const [sliderImages] = useContext(SliderImagesContext)
    
    try{
    return (
        <div className="ImageSlider-ProductClassList">
            <ImageSlider slider_images={sliderImages}/>
            <div className="ProductClassList-wraper">                
                <div className="ProductClassList">
                    { 
                        
                        classes.map(pClass => 
                        <div className="ProductClassLink-wraper" key={pClass.id}>
                            <p>{pClass.class_name.toUpperCase()}</p>
                            <NavLink  className="ProductClassLink"
                            onClick={()=>{ setCurrentClass(pClass.id)}} to ={
                                {
                                    pathname:'/ProductList',
                                    product_class:pClass.id
                                }
                            }>
                                <img alt=" " src={pClass.image_path}/>
                            </NavLink>
                        </div>)
                    }
                </div>      
            </div> 
            {     
                products.filter(product => product.snizenje === 1).length > 0 ?
                <div className="snizenja_container">
                    <h3>Proizvodi na sniženju</h3>
                    <div className="snizenja">
                        {
                           products.filter(product => product.snizenje === 1).map( product =>
                            <ProductListItem 
                                product={product} 
                                key={product.id}
                            />
                            )
                        }
                    </div>
                </div>: null
                     }
        </div>
    )
}
catch(e){
         
    return <Redirect to='/'/>
}
}