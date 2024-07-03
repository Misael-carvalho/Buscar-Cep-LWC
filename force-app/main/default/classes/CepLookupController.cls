public with sharing class CepLookupController {

    @AuraEnabled(cacheable=true)
    public static EnderecoVO getCepDetails(String cep) {
        EnderecoVO resposta = new EnderecoVO();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://viacep.com.br/ws/' + cep + '/json/');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            DadosEndereco endereco = (DadosEndereco)JSON.deserialize(response.getBody(), DadosEndereco.class);
            if(!String.isBlank(endereco?.logradouro)){
                resposta.logradouro = endereco.logradouro;
                resposta.bairro = !String.isBlank(endereco?.bairro) ? endereco.bairro: '';
                resposta.localidade = !String.isBlank(endereco?.localidade) ? endereco?.localidade : '';
                resposta.uf = !String.isBlank(endereco?.uf) ? endereco?.uf : '';
                return resposta;
            } else {
                resposta.error = true;
                resposta.digitadoErrado = 'Cep Inválido, digite novamente.';
                return resposta;
            }
        } else {
            resposta.error = true;
            return resposta;
        }
    }
     public class DadosEndereco {
        public String uf;
        public String bairro;
        public String logradouro;
        public String localidade;
    }
}