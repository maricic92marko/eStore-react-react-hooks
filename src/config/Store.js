import React,{useState,useEffect} from 'react';
import FetchApi from '../modules/Fetch-Api'
import createPersistedState from 'use-persisted-state';

export const ProductsContext = React.createContext()
export const CurrentClassContext = React.createContext()
export const CartContext = React.createContext()
export const ClassesContext = React.createContext()
export const ProductIdContext = React.createContext()
export const FormContext = React.createContext()
export const StoreInfoContext = React.createContext()
export const SliderImagesContext = React.createContext()

const useProductsState = createPersistedState('products')
const useStoreInfoState = createPersistedState('store_info')
const useSliderImagesState = createPersistedState('slider_images')
const useClassesState = createPersistedState('classes')

const useCurrentClassState = createPersistedState('currentClass')
const useCartState = createPersistedState('cart')
const useProductIdState = createPersistedState('product_id')

let StoreInfoObj = {
    "id":0,
    "store_address":"",
    "store_mail":"",
    "store_name":"",
    "store_delivery_company":"",
    "store_phone":""
  }
  
  let ProductsObj = [{
    "id":0,
    "class_id":0,
    "name":"",
    "description":"",
    "price":0,
    "image":"",
    "created":"",
    "updated":"","snizenje":0,
    "metric_unit_id":0,
    "img_path_list":"",
    "metric_unit":"","min_qty":0,"piece":0
  }]
  
  let ClassesObj =[{
    "id":0,
    "class_name":"",
    "image_path":""
  }]
  
  let SliderImagesObj=[{
    "id":0,
    "image_path":"",
    "page_link":"",
    "class_id":0,
    "product_id":null
  }]
 

const Store = ({children}) =>{
    let [products, setProducts] = useProductsState(ProductsObj);
    let [store_info, setStore_info] = useStoreInfoState(StoreInfoObj);
    let [slider_images, setSlider_images] = useSliderImagesState(SliderImagesObj);
    let [classes, setClasses] = useClassesState(ClassesObj);   
  
    let [currentClass, setCurrentClass] = useCurrentClassState({   });
    let [cart, setCart] = useCartState([]);
    let [product_id, setProduct_id] = useProductIdState({   });
    let [form, setForm] = useState({   });

    
    useEffect(() => {

        
        const fetchData = async () => {

          const result = await     FetchApi('get', 'http://localhost:5000/initial_state')
          .then(json => {
            
            return json
          })

          
          setProducts(result.products);
          setSlider_images(result.slider_images);
          setClasses(result.classes);
          setStore_info(result.store_info);
 
        };
        

        fetchData();
      }, [setProducts,setSlider_images,setClasses,setStore_info]);

      return(
        <ClassesContext.Provider value={[classes, setClasses]}>
            < ProductIdContext.Provider value={[product_id, setProduct_id]}>
                <FormContext.Provider value={[form, setForm]}>
                    <StoreInfoContext.Provider value={[store_info, setStore_info]}>
                        <SliderImagesContext.Provider value={[slider_images, setSlider_images]}>
                            <ProductsContext.Provider value={[products, setProducts]}>
                                <CurrentClassContext.Provider value={[currentClass, setCurrentClass]}>
                                    <CartContext.Provider value={[cart, setCart]}>
                                        {children}
                                        </CartContext.Provider>
                                </CurrentClassContext.Provider>
                            </ProductsContext.Provider>
                        </SliderImagesContext.Provider>
                    </StoreInfoContext.Provider>
                </FormContext.Provider>
            </ ProductIdContext.Provider>
        </ClassesContext.Provider>

        )
}

export default Store;

