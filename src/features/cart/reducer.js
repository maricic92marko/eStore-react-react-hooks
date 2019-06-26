const cartWithotItem = (cart,item)=> cart.filter(cartItem=> cartItem.id !== 
    item.id)

const itemInCart = (cart,item)=>cart.filter(cartItem=> cartItem.id === 
    item.id)[0]

const addMultipleitemsToCart=(cart,item)=>{
debugger
    const cartItem = itemInCart(cart,item)
    
    const add  = item.quantity
 debugger
    return [...cartWithotItem(cart,item),{...item,quantity:parseInt(add)}]
    
}
  
const changeOrder = (cart,items) => {
    debugger
   const order = JSON.parse(items)
   cart = order
    return cart
//})
}



const addToCart=(cart,item)=>{
debugger
    const cartItem = itemInCart(cart,item)
    return cartItem ===undefined ? [...cartWithotItem(cart,item),{...item,quantity:1}]
    :[...cartWithotItem(cart,item),{...item,quantity:cartItem.quantity +1}]
  
}

const removeFromCart=(cart,item)=>{
    return item.quantity===1 
    ?[...cartWithotItem(cart,item)]
    :[...cartWithotItem(cart,item), {...item,quantity:item.quantity-1}]
}

const removeAllFromCart=(cart,item)=>{
    return [...cartWithotItem(cart,item)]
}

const cartReducer = (state=[],action)=>
{
    switch(action.type){
        case'ADD':
            return addToCart(state,action.payload)
        case'ADDMULTIPLE':
            return addMultipleitemsToCart(state,action.payload)
        case'REMOVE':
            return removeFromCart(state, action.payload)
        case'REMOVEALL':
            return removeAllFromCart(state, action.payload)
        case 'CHANGEORDER':
            return changeOrder(state,action.payload)
        default:
    return state;
        }
}

export default cartReducer