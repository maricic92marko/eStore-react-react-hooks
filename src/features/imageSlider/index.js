import React, { Component } from 'react'
import {NavLink} from 'react-router-dom'
import  { Redirect } from 'react-router-dom'
import {SliderImagesContext} from '../../config/Store'

class ImageSlider extends Component {

    constructor (props){
        super(props)
        debugger
        
        this.state = {
            sliderImages:this.props.slider_images,
            count: 0,
            opimg : 1,
            imgid :1

        }
    }

    componentWillReceiveProps()
    {
        const images =  this.props.slider_images;

        if(images && images.length>0){
            this.setState({ sliderImages : images, imgid : ((Math.floor(Math.random() * 
                            Math.round(images.length / 2 - 1)) + 1) * 2)})
        }

    }

    componentDidMount(){
        debugger
        
        const images =  this.props.slider_images;

        if(images && images.length>0){
            this.setState({ sliderImages : images, imgid : ((Math.floor(Math.random() * 
                            Math.round(images.length / 2 - 1)) + 1) * 2)})
        }

    this.myInterval = setInterval(() => {
        if(Math.round(this.state.count) === 8)
        {   
            this.setState({imgid : this.state.imgid + 1,count : 0})
            if(this.state.imgid >  this.state.sliderImages.length -1)
            {
            this.setState({imgid : 0, count : 0})
            }
        }
        this.setState({count : this.state.count + 0.015})
    }, 15);
}
    nextImage =()=>{
        if(this.state.imgid <  this.state.sliderImages.length  -1 )
        {
            this.setState({count : 0 ,imgid:this.state.imgid+1}) 

        }
    }
    previousImage =()=>{
        if(this.state.imgid >  0)
        {
        this.setState({count:0,imgid:this.state.imgid-1}) 
        }
    }

    render() {
        try{
        return (
            <div className="ImageSlider-wraper">
            <button id="btnPrevious" 
            onClick={()=>this.previousImage()} className="ImageSlider-btnPrevious">
                <img alt='arrow-left' src="/products/iconfinder_arrow-left.png"/>
            </button>
            <div className="ImageSlider"
            style ={{'transform' : `translateX(-${this.state.imgid *100}%)`}}>
                {  
                this.state.sliderImages.map( image=>
                    image.product_id ? 
                    <NavLink key={image.id} to={{
                        pathname:image.page_link,
                        product_id: image.product_id
                        }}>
                          {  
              
                        <img src={image.image_path} alt="" className="SliderImg" id="SliderImg"></img> 
                          }
                        </NavLink>
                    :<NavLink  key={image.id} to={{
                        pathname:image.page_link,
                        product_class: image.class_id
                        }}>
                        {  
                 
                        <img src={image.image_path} alt="" className="SliderImg" id="SliderImg"></img> 
                        }
                        </NavLink>)
            }
                </div>
                <button id="btnNext" 
                onClick={()=>this.nextImage()} className="ImageSlider-btnNext">
                    <img alt='arrow-right' src="/products/iconfinder_arrow-right.png"/></button>
            </div>
        )
    }
    catch(e){ 
        return <Redirect to='/'/>
    }
    }
}

export default ImageSlider