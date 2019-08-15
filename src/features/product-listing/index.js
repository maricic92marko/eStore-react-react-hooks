import React,{useContext} from 'react'
import ProductListItem from './ProductListItem'
import  { Redirect } from 'react-router-dom'
import {ProductsContext,CurrentClassContext} from '../../config/Store'

const ProductListing = (props) => {

    const [products] = useContext(ProductsContext);
    const [currentClass, setCurrentClass] = useContext(CurrentClassContext)
        try{
            debugger
            let classProducts;
            let product_class = props.product_class
            if(currentClass  && !product_class)
            { 
                product_class = currentClass
            }
            debugger
            if(product_class)
            {
                setCurrentClass(product_class)
                if(product_class !== 'svi')
                {
                    classProducts = products.filter(product => product.class_id === product_class)
                }else
                {
                    classProducts = products
                }
            }
       
        return  (
            <div className='product-listing'>
                {
                classProducts.map( product =>
                    <ProductListItem 
                    product={product} 
                    key={product.id}
                    />)
                }
            </div>
        )
    }
    catch(e){
             
        return <Redirect to='/'/>
    }
}

export default ProductListing