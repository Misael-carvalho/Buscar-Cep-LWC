public with sharing class CepLookupController {

    private static final String INTEGRATION_DATA_NAME = 'CepLookup';

    @AuraEnabled(cacheable=true)
    public static EnderecoVO getCepDetails(String cep) {
        EnderecoVO resposta = new EnderecoVO();
        
        IntegrationData__c IntegrationData = IntegrationData__c.getValues(INTEGRATION_DATA_NAME);
        IntegrationData.Endpoint__c = IntegrationData.Endpoint__c + cep + IntegrationData.Type__c;

        IntegrationUtils.RequestResponseObject response = IntegrationUtils.executeCallout( integrationData, null, null, integrationData.HTTPMethod__c );
        try {
            if (response.success && response.statusCode == 200) {
                DadosEndereco endereco = (DadosEndereco)JSON.deserialize(response.body, DadosEndereco.class);
                if(!String.isBlank(endereco?.logradouro)){
                    resposta.logradouro = endereco.logradouro;
                    resposta.bairro = !String.isBlank(endereco?.bairro) ? endereco.bairro: '';
                    resposta.localidade = !String.isBlank(endereco?.localidade) ? endereco?.localidade : '';
                    resposta.uf = !String.isBlank(endereco?.uf) ? endereco?.uf : '';
                    // IntegrationUtils.WSLog(INTEGRATIO8N_DATA_NAME, '', response.body, '', false);
                    return resposta;
                } else {
                    // IntegrationUtils.WSLog(INTEGRATION_DATA_NAME, '', response.body, '', false);
                    resposta.error = true;
                    resposta.digitadoErrado = 'Cep Inválido, digite novamente.';
                    return resposta;
                }
            } else {
                // IntegrationUtils.WSLog(INTEGRATION_DATA_NAME, 'Erro ao Buscar Cep', 'response.getStatusCode() '+ response.statusCode, '', true);
                resposta.error = true;
                return resposta;
            }
        } catch( Exception e ) {
            // IntegrationUtils.WSLog(INTEGRATION_DATA_NAME, e.getMessage(), '', '', true);
            resposta.error = true;
            return resposta;
        }
    }
    
    @AuraEnabled
    public static Boolean saveAddress(String data) {
        DataAccount datas = (DataAccount) JSON.deserialize(data, DataAccount.class);
        try {
            Account acc = [SELECT Id, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode FROM Account WHERE Id = :datas.accountId LIMIT 1];
            
            if (acc != null) {
                if (String.isNotBlank(datas.uf)) {
                    datas.uf = String.escapeSingleQuotes(datas.uf).unescapeHtml4();
                }
                if (String.isNotBlank(datas.bairro)) {
                    datas.bairro = String.escapeSingleQuotes(datas.bairro).unescapeHtml4();
                }
                if (String.isNotBlank(datas.logradouro)) {
                    datas.logradouro = String.escapeSingleQuotes(datas.logradouro).unescapeHtml4();
                }
                if (String.isNotBlank(datas.localidade)) {
                    datas.localidade = String.escapeSingleQuotes(datas.localidade).unescapeHtml4();
                }
                if (String.isNotBlank(datas.complemento)) {
                    datas.complemento = String.escapeSingleQuotes(datas.complemento).unescapeHtml4();
                }
                if (String.isNotBlank(datas.numero)) {
                    datas.numero = String.escapeSingleQuotes(datas.numero).unescapeHtml4();
                }
                
                datas.logradouro =  (String.isNotBlank(datas.logradouro) ? datas.logradouro : acc.ShippingStreet) + 
                                    (String.isNotBlank(datas.numero) ? ', ' + datas.numero : '') +
                                    (String.isNotBlank(datas.complemento) ? ', ' + datas.complemento : '');
                                    (String.isNotBlank(datas.bairro) ? ', ' + datas.bairro : '');
                
                acc.ShippingNeighborhood = datas.logradouro;
                acc.ShippingCity = String.isNotBlank(datas.numero) ? datas.localidade : acc.ShippingCity;
                acc.ShippingState = String.isNotBlank(datas.numero) ? datas.uf : acc.ShippingState;
                acc.ShippingPostalCode = String.isNotBlank(datas.numero) ? datas.cep : acc.ShippingPostalCode;
                
                update acc;
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            System.debug('Erro ao salvar endereço de entrega: ' + e.getMessage());
            return false;
        }
    }


    public class DadosEndereco {
        public String uf;
        public String bairro;
        public String logradouro;
        public String localidade;
    }

    public class DataAccount{
        public String accountId;
        public String cep;
        public String uf;
        public String bairro;
        public String logradouro;
        public String localidade;
        public String complemento;
        public String numero;
    }
}