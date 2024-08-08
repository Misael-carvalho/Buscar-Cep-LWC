public with sharing class EnderecoVO {
    public  EnderecoVO(){}
        
     @AuraEnabled public Boolean error = false;
     @AuraEnabled public String digitadoErrado;
     @AuraEnabled public String logradouro;
     @AuraEnabled public String bairro;
     @AuraEnabled public String localidade;
     @AuraEnabled public String uf;
}