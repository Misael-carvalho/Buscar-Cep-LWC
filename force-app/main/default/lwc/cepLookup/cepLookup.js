import { LightningElement} from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getCepDetails from '@salesforce/apex/CepLookupController.getCepDetails';

export default class CepLookup extends LightningElement {
    cep = '';
    result = {};
    showResult = false;

    handleInputChange(event) {
        let inputValue =  event.target.value.replace(/\D/g, '');
        if (inputValue.length > 5) {
            inputValue = `${inputValue.slice(0, 2)}.${inputValue.slice(2, 5)}-${inputValue.slice(5)}`;
        } else if (inputValue.length > 2) {
            inputValue = `${inputValue.slice(0, 2)}.${inputValue.slice(2)}`;
        }
        this.cep = inputValue;
    }

    async handleSearch() {
        let inputValue =  this.cep.replace(/\D/g, '');
        if (inputValue.length < 8){
            this.showToast('warning', 'Buscar cep.', 'Você precisa digitar o cep completo com 8 digitos.', 'dismissable');
            return false;
        }
        try {
            const response = await getCepDetails({ cep: inputValue });
            if (!response.error) {
                console.log('response ', response);
                this.result = response;
                this.showResult = true;
            } else {
                console.log('response ', response);
                if(response.digitadoErrado != null){
                    this.showToast('error', 'Buscar cep.', response.digitadoErrado, 'dismissable');
                } else {
                    this.showToast('error', 'Buscar cep.', 'Erro ao buscar cep, tente mais tarde.', 'dismissable');
                }
            }
        } catch (error) {
            console.error('Erro ao buscar CEP: ', error);
        }
    }

    showToast(type, title, message, mode) {
        const event = new ShowToastEvent({
            variant: type,
            title: title,
            message: message,
            mode: mode,
            duration: 2000 
        });
        this.dispatchEvent(event);
    }
}