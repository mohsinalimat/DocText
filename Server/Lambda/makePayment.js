var stripe = require('stripe')('sk_test_NuyJOQjoskkAsGOXjiFXEaUn');
var aws = require("aws-sdk");
var docClient = new aws.DynamoDB.DocumentClient(); 
exports.handler = (event, context, callback) => {
    
    // parameter validation
    var paramValidation = '';
    if(!isNotEmpty(event.customerId)){
        paramValidation += 'customerId cannot be empty. ';
    }
    if(!isNotEmpty(event.currency)){
        paramValidation += 'currency cannot be empty. ';
    }
    if(isNotEmpty(paramValidation)){
        callback(paramValidation)
    }
    console.log(event.customerId);
    stripe.charges.create({
        amount : event.amount,
        currency : event.currency,
        customer : event.customerId
    }, function(err, charge){
        if(err){
            console.log(err);
            callback(err);
        }else{
            console.log(charge);
            var params = {
                TableName : "Transaction",
                Item : {
                    "ChargeId" : charge.id,
                    "Refund" : false
                }
            }
            docClient.put(params, function(e, d){
                if(e){
                    console.log("failed to insert data in Trasaction table", e);
                } else {
                    console.log("success to insert data in Trasaction table", e);
                }
                callback(null, charge);
            });
        }
    });
    
    function isNotEmpty(str){
        return str !== null && str !== '' && typeof str !== 'undefined';
    }
};