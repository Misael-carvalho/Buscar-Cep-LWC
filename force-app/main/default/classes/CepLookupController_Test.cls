@isTest
public class CepLookupController_Test {
    
    @isTest
    static void testGetCepDetailsSucess() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200));
        String cep = '00000000';
        
        Test.startTest();
        EnderecoVO result = CepLookupController.getCepDetails(cep);
        Test.stopTest();
        
        Assert.areEqual('Mock Street', result.logradouro);
        Assert.areEqual('Mock Neighborhood', result.bairro);
        Assert.areEqual('Mock City', result.localidade);
        Assert.areEqual('MO', result.uf);
    }
	@isTest
    static void testGetCepDetailsError() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400));
        String cep = '00000000';
        
        Test.startTest();
        EnderecoVO result = CepLookupController.getCepDetails(cep);
        Test.stopTest();
        
    } 
	@isTest
    static void testGetCepDetailsError2() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500));
        String cep = '00000000';
        
        Test.startTest();
        EnderecoVO result = CepLookupController.getCepDetails(cep);
        Test.stopTest();
        
    }    
}