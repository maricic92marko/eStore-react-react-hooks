import React, { Component } from 'react'
import { connect } from 'react-redux';
import {NavLink} from 'react-router-dom'

class ImageSlider extends Component {

    constructor (props){
        super(props)
        this.state = {
            count: 0,
            opimg : Math.floor(Math.random() * 2),
            imgid : Math.floor(Math.random() * 2 +1) * 2 , 
            img1id: Math.floor(Math.random() * 3) *2  + 1}
    }

    componentDidMount(){
        let SliderImg = document.getElementById("SliderImg");
        let SliderImg1 = document.getElementById("SliderImg1");
        this.myInterval = setInterval(() => {

                if (!SliderImg.style.opacity || !SliderImg1.style.opacity) {
                    if(this.state.opimg === 0)
                   { 
                       SliderImg.style.opacity = 0;
                    SliderImg1.style.opacity = 1;
                    }
                    else
                    { 
                        SliderImg.style.opacity = 1;
                        SliderImg1.style.opacity = 0;
                    }
                }
                if ( this.state.opimg === 0) {
                    if( SliderImg.style.opacity > 0)
                    {
                        SliderImg.style.opacity = parseFloat(SliderImg.style.opacity) - 0.01;
                    }
                    if( SliderImg1.style.opacity <= 1)
                    {
                        SliderImg1.style.opacity = parseFloat(SliderImg1.style.opacity) + 0.01;
                    }
                    SliderImg1.style.zIndex = 0
                    SliderImg.style.zIndex = -1
                }
                  
                if ( this.state.opimg ===1 ){
                      
                    if( SliderImg1.style.opacity <= 1){
                        SliderImg.style.opacity = 
                        parseFloat(SliderImg.style.opacity) + 0.01;
                    }
                    if( SliderImg1.style.opacity > 0){
                        SliderImg1.style.opacity = 
                        parseFloat(SliderImg1.style.opacity) - 0.01;
                    }
                    SliderImg1.style.zIndex = -1
                    SliderImg.style.zIndex = 0
                }

                if(SliderImg.style.opacity <= 0.01 
                    && Math.round(this.state.count) === 6)
                {
                    this.setState({opimg : 1,count : 0,img1id : this.state.img1id+2})
                    if(this.state.img1id > 5)
                    {
                        this.setState({count : 0,img1id : 1})
                    }
                }

                if(SliderImg.style.opacity >= 0.99 
                    && Math.round(this.state.count) === 6)
                {
                    this.setState({opimg : 0,count : 0,imgid : this.state.imgid+2})
                    if(this.state.imgid > 5)
                    {
                        this.setState({count : 0, imgid :2})
                    }
                }
           
            this.setState({count : this.state.count + 0.015})
        }, 15);
    }
    render() {
        
        let SliderImg = document.getElementById("SliderImg");
        let SliderImg1 = document.getElementById("SliderImg1");
        
        if(SliderImg  && SliderImg1 )
        {
            if(this.props.products  && this.props.products.length > 0)
            { 
                if(SliderImg1.style.opacity <= 0.01 || !SliderImg1.src ) 
                {            
                    SliderImg1.src = this.props.products.filter(
                    product => product.id === this.state.img1id)[0].image
                }
                if(SliderImg.style.opacity <= 0.01 || !SliderImg.src) 
                { 
                    SliderImg.src = this.props.products.filter(
                    product => product.id === this.state.imgid)[0].image 
                }
            }  
        }
        return (
            <div className="ImageSlider">
                <NavLink to={{
                    pathname:'/ProductDetails',
                    product_id: this.state.imgid 
                    }}>
                        <img alt="" className="SliderImg" id="SliderImg"></img> 
                </NavLink>
                <NavLink to={{
                    pathname:'/ProductDetails',
                    product_id: this.state.img1id 
                    }}>
                        <img alt="" className="SliderImg" id="SliderImg1"></img>
                </NavLink>
            </div>
        )
    }
}

function mapStateToProps(state){
    return {
        products: state.products
    }
}



export default connect(mapStateToProps)(ImageSlider)

