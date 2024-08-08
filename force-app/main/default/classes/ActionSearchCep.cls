public with sharing class ActionSearchCep {
    
    private static final String INTEGRATION_DATA_NAME = 'CepLookup';
  
    @InvocableMethod(label='Search Cep')
    public static List<Results> getInvoice(List<DateCep> cnpjInputs) {
        Results resposta = new Results();
        
        IntegrationData__c IntegrationData = IntegrationData__c.getValues(INTEGRATION_DATA_NAME);
        IntegrationData.Endpoint__c = IntegrationData.Endpoint__c + cnpjInputs[0].cep + IntegrationData.Type__c;

        IntegrationUtils.RequestResponseObject response = IntegrationUtils.executeCallout( integrationData, null, null, integrationData.HTTPMethod__c );
        try {
            if (response.success && response.statusCode == 200) {
                DadosEndereco endereco = (DadosEndereco)JSON.deserialize(response.body, DadosEndereco.class);
                if(!String.isBlank(endereco?.logradouro)){
                    resposta.logradouro = endereco.logradouro;
                    resposta.bairro = !String.isBlank(endereco?.bairro) ? endereco.bairro: '';
                    resposta.localidade = !String.isBlank(endereco?.localidade) ? endereco?.localidade : '';
                    resposta.uf = !String.isBlank(endereco?.uf) ? endereco?.uf : '';
                    // IntegrationUtils.WSLog(INTEGRATION_DATA_NAME, '', response.getBody(), JSON.serializePretty(request), false);
                    return new List<Results>{resposta};
                } else {
                    // IntegrationUtils.WSLog(INTEGRATION_DATA_NAME, '', response.getBody(), JSON.serializePretty(request), false);
                    resposta.hasSearch = false;
                    resposta.digitadoErrado = 'Cep Inválido, digite novamente.';
                    return new List<Results>{resposta};
                }
            } else {
                // IntegrationUtils.WSLog(INTEGRATION_DATA_NAME, 'Erro ao Buscar Cep', 'response.getStatusCode() '+ response.getStatusCode(), JSON.serializePretty(request), true);
                resposta.hasSearch = false;
                return new List<Results>{resposta};
            }
        } catch( Exception e ) {
            IntegrationUtils.WSLog(INTEGRATION_DATA_NAME, e.getMessage(), '', '', true);
            resposta.hasSearch = false;
            return new List<Results>{resposta};
        }
    }

    public class DateCep{     
        @InvocableVariable(required=true)   
        public String cep;  
    }
    
    public class Results {
        @InvocableVariable
        public String uf;
        @InvocableVariable
        public String bairro;
        @InvocableVariable
        public String logradouro;
        @InvocableVariable
        public String localidade;
        @InvocableVariable
        public Boolean hasSearch = true;
        @InvocableVariable
        public String digitadoErrado;
    }

    public class DadosEndereco {
        public String uf;
        public String bairro;
        public String logradouro;
        public String localidade;
    }
}