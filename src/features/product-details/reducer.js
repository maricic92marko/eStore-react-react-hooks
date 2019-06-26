export default function productIdReducer (state=[], action){
    switch(action.type){
        case 'ID':
        return action.payload
        default:
        return state
    }
}