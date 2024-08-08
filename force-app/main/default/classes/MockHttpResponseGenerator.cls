public class MockHttpResponseGenerator implements HttpCalloutMock {
     private Integer httpCode;
     
     public MockHttpResponseGenerator(Integer httpCode) {
         this.httpCode = httpCode;
     }
     public HTTPResponse respond(HTTPRequest req) {
         HTTPResponse res = new HTTPResponse();
         if(httpCode == 400){
             res.setHeader('Content-Type', 'application/json');
             res.setBody('{"logradouro":"Mock Street","bairro":"Mock Neighborhood","localidade":"Mock City","uf":"MO"}');
             res.setStatusCode(400);
             return res;
         } if(httpCode == 500){
             res.setHeader('Content-Type', 'application/json');
             res.setBody('{"logradouro":"","bairro":"Mock Neighborhood","localidade":"Mock City","uf":"MO"}');
             res.setStatusCode(200);
             return res;
         } else {
             res.setHeader('Content-Type', 'application/json');
             res.setBody('{"logradouro":"Mock Street","bairro":"Mock Neighborhood","localidade":"Mock City","uf":"MO"}');
             res.setStatusCode(200);
             return res;
         }
     }
 }