import React from 'react'
import Alerts from '../features/alerts'

export default function AlertPage(props) {
    return (
        <div>
            <Alerts alert={props.location.search}/>
        </div>
    )
}
