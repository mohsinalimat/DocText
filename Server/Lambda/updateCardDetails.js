var stripe = require('stripe')('sk_test_NuyJOQjoskkAsGOXjiFXEaUn');
var aws = require("aws-sdk");
var docClient = new aws.DynamoDB.DocumentClient();
exports.handler = (event, context, callback) => {
    
    // parameter validation
    var paramValidation = '';
    if(!isNotEmpty(event.customerId)){
        paramValidation += 'customer Id cannot be empty.';
    }
    if(!isNotEmpty(event.cardId)){
        paramValidation += ' card Id cannot be empty';
    }
    if(isNotEmpty(paramValidation)){
        callback(paramValidation);
    }
    var updateObj = {};
    stripe.customers.updateCard(
      event.customerId,
      event.cardId,
      { name: event.name, exp_month: event.exp_month, exp_year:event.exp_year, address_zip: event.zip_code },
      function(err, card) {
        if(err){
            callback({success:0, err});
        }else{
            callback(null, {success:1, card});
        }
      }
    ); 
    
    function isNotEmpty(str){
        return str !== null && str !== '' && typeof str !== 'undefined';
    }
};