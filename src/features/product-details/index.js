import React,{useContext} from 'react'
import QuantityInput from '../product-listing/QuantityInput'
import ProductListItem from '../../features/product-listing/ProductListItem'
import  { Redirect } from 'react-router-dom'
import {ProductIdContext,ProductsContext,CartContext} from '../../config/Store'

const  ProductDetails = (props) => {

    const [products] = useContext(ProductsContext)
    const [productId, setProductId] = useContext(ProductIdContext)
    const [cart, setCart] = useContext(CartContext)

        try{
            debugger
            let product_id = props.product_id
                    
            if(productId  && !product_id)
            { 
                product_id = productId
            }

            if(product_id)
            { 
                setProductId(product_id)
            }

            const product = products.filter(product => product.id === parseInt(product_id))[0]
            const cartItem = cart.filter(cartItem =>cartItem.id === product.id)[0]

            let imgPathList;
            if(product.img_path_list)
            {
                imgPathList =  product.img_path_list.split(',')
                imgPathList.push(product.image)
            }
            const  productImgChange =(e) =>
            {
                let curProduct = document.getElementById("descriptionImg");
                curProduct.src =e.target.src;
            }
        return (
            <div className='product-item-description'>
                <div className='product-item-description-item'>
                <h3>{product.name}</h3>
                 {Boolean(product.snizenje) ?
                    <div className="price-snizenje">-{product.price} RSD Sniženo</div>:
                    <div>{product.price}RSD</div> 
                    }

                <QuantityInput
                product={product}
                setCart={(value) => setCart(value)}
                cart={cart}
                key={product.id} 
                />
                <img 
                    id="descriptionImg"
                    alt={''}
                    title={product.name}
                    src={product.image}
                />
                <br></br>
                <p>{product.description}</p>
               
              {  imgPathList?
              <div className="product-item-description-images">
                    <ul>
                        {
                            imgPathList.map(path =>
                                <li>
                                    <img  onClick={(e) =>{productImgChange(e)}} alt="" src={path}/>
                                </li>
                            )
                        }
                    </ul>
                </div>: null
            }
                </div>
                <div className="product-item-description-class-items-wraper">
                <p>Similar Products</p>
                    <div className="product-item-description-class-items">
                {
                products.filter(prod => prod.class_id === product.class_id && prod.id !== product.id).map( product =>
                   
                    <ProductListItem 
                    product={product} 
                    key={product.id}
                    />)
                }
                    </div>
                </div>
            </div>
        )
    }
    catch(e){
         
        return <Redirect to='/'/>
    }
}


export default ProductDetails