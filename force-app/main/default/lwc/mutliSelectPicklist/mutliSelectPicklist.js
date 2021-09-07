import { LightningElement, track, api } from 'lwc';

export default class App extends LightningElement {

    @api
    values = [];

    @track
    selectedvalues = [];

    @api
    picklistlabel = 'Status';

    showdropdown;

    handleleave() {
        
        let sddcheck= this.showdropdown;

        if(sddcheck){
            this.showdropdown = false;
            this.fetchSelectedValues();
        }
    }

    connectedCallback(){
        this.values.forEach(element => element.selected 
                            ? this.selectedvalues.push(element.value) : '');
    }

    @api
    vals(){
        this.selectedvals = [];
        for(let i=0; i<this.values.length; i++){
            if(this.values[i].selected == true){
                this.selectedvals.push(this.values[i].label);
            }
        }
        return this.selectedvals;
    }

    fetchSelectedValues() {
        this.selectedvalues = [];

        //get all the selected values
        this.template.querySelectorAll('c-picklist-value').forEach(
            element => {
                if(element.selected){
                    if(!this.selectedvalues.includes(element.value)){
                        this.selectedvalues.push(element.value);
                    }
                    
                }
            }
        );
        //console.log("Update?");
        // Creates the event with the data.
        /*const selectedEvent = new CustomEvent("updateflag", {
            detail: true
        });
    
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);*/

        //this.dispatchEvent( new CustomEvent( 'updateflag', { detail: { value: true }} ));

        //refresh original list
        this.refreshOrginalList();
    }

    refreshOrginalList() {
        const picklistvalues = this.values.map(eachvalue => ({...eachvalue}));
        
        picklistvalues.forEach((element, index) => {
            if(this.selectedvalues.includes(element.value)){
                picklistvalues[index].selected = true;
            }else{
                picklistvalues[index].selected = false;
            }
        });

        this.values = picklistvalues;
    }

    handleShowdropdown(){
        let sdd = this.showdropdown;
        if(sdd){
            this.showdropdown = false;
            this.fetchSelectedValues();
        }else{
            this.showdropdown = true;
        }
    }

    closePill(event){
        let selection = event.target.dataset.value;
        let selectedpills = this.selectedvalues;
        let pillIndex = selectedpills.indexOf(selection);
        this.selectedvalues.splice(pillIndex, 1);
        this.refreshOrginalList();
    }

    get selectedmessage() {
        return this.selectedvalues.length + ' values are selected';
    }
}