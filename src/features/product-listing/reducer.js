export  function productsReducer  (state=[], action){
    debugger
    switch(action.type){
        case 'LOAD':
        return action.payload
        default:
        return state
    }   
}


export  function setClassReducer  (state=[], action){
    debugger
    switch(action.type){
        case 'SETCLASS':
        return action.payload
        default:
        return state
    }   
}

export  function classReducer  (state=[], action){
    debugger
    switch(action.type){
        case 'CLASS':
        return action.payload
        default:
        return state
    }   
}
