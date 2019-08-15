const cartWithotItem = (cart,item)=> cart.filter(cartItem=> cartItem.cartItemId !== 
    item.cartItemId)
/*
const itemInCart = (cart,item)=>cart.filter(cartItem=> cartItem.id === 
    item.id)[0]
*/


export const addToCart=(cart,item)=>{
     debugger
 
    const add  = item.quantity
    if(cart.length>0)
    {
        item.cartItemId = cart[cart.length -1 ].cartItemId +1

    }
    else
    {
        item.cartItemId = 0
    }
    if(add >= 1)
    {
    return [...cartWithotItem(cart,item),{...item,quantity:parseFloat(add)}]
    }
    else
    {
        return cart;
 
    }
}


export const removeAllFromCart=(cart,item)=>{
    return [...cartWithotItem(cart,item)]
}
 
