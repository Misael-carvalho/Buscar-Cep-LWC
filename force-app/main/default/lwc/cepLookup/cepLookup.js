import { LightningElement, api, track} from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { FlowNavigationNextEvent} from 'lightning/flowSupport';

import getCepDetails from '@salesforce/apex/CepLookupController.getCepDetails';
import saveAddress from '@salesforce/apex/CepLookupController.saveAddress';

export default class CepLookup extends LightningElement {
    @api recordId;
    @api accountId = '';
    @api cep = '';
    @api uf = '';
    @api bairro = '';
    @api logradouro = '';
    @api localidade = '';
    @api complemento = '';
    @api numero = '';
    @api NameFlow = '';
    @api flow = false;
    @track data = {};
    readonly = false;

    handleChangeAddress(e){
        this[e.target.name] = e.detail.value;
    }

    handleInputChange(event) {
        this.resetData(false);
        let inputValue =  event.target.value.replace(/\D/g, '');
        if (inputValue.length > 5) {
            inputValue = `${inputValue.slice(0, 2)}.${inputValue.slice(2, 5)}-${inputValue.slice(5)}`;
        } else if (inputValue.length > 2) {
            inputValue = `${inputValue.slice(0, 2)}.${inputValue.slice(2)}`;
        }
        this.cep = inputValue;
        if (inputValue.length === 10) {
            this.handleSearch();
        }
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
                // console.log(JSON.stringify(response));
                Object.keys(response).forEach(key => {
                    this[key] = response[key];
                });
                this.readonly = true;
            }
             else {
                if(response.digitadoErrado != null){
                    this.showToast('error', 'Buscar cep.', response.digitadoErrado, 'dismissable');
                } else {
                    this.showToast('error', 'Buscar cep.', 'Erro ao buscar cep, tente mais tarde.', 'dismissable');
                }
                this.readonly = false;
            }
        } catch (error) {
            console.error('Erro ao buscar CEP: ', error);
        }
    }

    async saveAddress() {
        try {
            if (!this.validateFields()) {
                return;
            }
            let dataToSend = {
                accountId: this.recordId,
                cep: this.cep.replace(/\D/g, ''),
                uf: this.uf,
                bairro: this.bairro,
                logradouro: this.logradouro,
                localidade: this.localidade,
                complemento: this.complemento,
                numero: this.numero
            };
            // console.log(JSON.stringify(dataToSend));
            const data = await saveAddress({ data: JSON.stringify(dataToSend) });
    
            if (data) {
                this.resetData(true);
                this.showToast('success', 'Sucesso', 'Endereço salvo com sucesso.', 'dismissable');
                if(this.flow){
                    this.navigateToFlow();
                } else {
                    setTimeout(() => {
                        this.refreshPage();
                    }, 2000); 
                }
            } else {
                this.showToast('error', 'Erro', 'Erro ao salvar endereço, tente mais tarde.', 'dismissable');
            }
        } catch (error) {
            console.error('Erro ao salvar endereço: ', error);
            this.showToast('error', 'Erro', 'Erro ao salvar endereço.', 'dismissable');
        }
    }
    
    navigateToFlow() {
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }
    

    resetData(cep) { 
        if(cep) this.cep= '';
        this.uf= '';
        this.bairro= '';
        this.logradouro= '';
        this.localidade= '';
        this.numero= '';
        this.complemento= '';
        this.readonly = false;
    }

    validateFields() {
        if (!this.logradouro || !this.bairro || !this.localidade || !this.uf) {
            this.showToast('warning', 'Campos obrigatórios', 'Preencha todos os campos obrigatórios.', 'dismissable');
            return false;
        }
        return true;
    }
    
    refreshPage() {
        location.reload();
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