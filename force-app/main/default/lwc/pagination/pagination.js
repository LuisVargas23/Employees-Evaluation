/***************************************************************************************************
 * copyright © 2021
 * Files    :   pagination.html
 *  *           pagination.js
 *              pagination.js-meta.xml
 *              
 * Purpose  : Paginates question in batch of ten.
 * 
 * Parent Component : questionPool
 *                    configForms
 * 
 * Created By: Luis Vargas on 7/29/2021
 * 
 * -------------------------------------------------------------------------------------------------
 * 
 * Release Date     Request     Updated By      Description
 * -------------------------------------------------------------------------------------------------
 * 7/29/2021                    Luis Vargas      Initial Creation
 ***************************************************************************************************/

import { LightningElement, track, api } from 'lwc';

export default class Pagination extends LightningElement {
    totalRecords
    //The recordSize defines how many questions are showed per page
    recordSize = 10

    @track currentPage = 1
    @api savedpage=1

    get records(){
        return visibleRecords
    }

    @api 
    set records(data){
        if(data){
            this.totalRecords = data
            this.totalPage= Math.ceil(data.length/this.recordSize)
            this.updateRecords()
        }
    }

    nextHandler(){
        if(this.currentPage < this.totalPage){
            this.currentPage++
            this.updateRecords()
        }
    }

    previousHandler(){
        if(this.currentPage > 1){
            this.currentPage--
            this.updateRecords()
        }
    }

    firstPageHandler(){
        this.currentPage=1;
        this.updateRecords()
    }

    lastPageHandler(){
        this.currentPage=this.totalPage;
        this.updateRecords()
    }

    updateRecords(){
        const start = (this.currentPage-1)*this.recordSize
        const end = this.recordSize*this.currentPage
        this.visibleRecords = this.totalRecords.slice(start, end)
        this.dispatchEvent(new CustomEvent('update',{
            detail:{
                records:this.visibleRecords,
                page: this.currentPage

            }
        }))
    }

    get disablePrevious(){
        return this.currentPage<=1   
    }
    get disableNext(){
        return this.currentPage >= this.totalPage
    }

   connectedCallback(){
        if(this.savedpage != 1){
            this.currentPage = this.savedpage;
        }

        if(this.currentPage > this.totalPage){
            this.currentPage = this.savedpage-1;
        }
        if(this.currentPage==0){
            this.currentPage =this.totalPage
        }
        this.updateRecords();
        this.savedpage =1;
    }

}