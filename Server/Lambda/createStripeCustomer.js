var stripe = require('stripe')('sk_test_NuyJOQjoskkAsGOXjiFXEaUn');
var aws = require("aws-sdk");
var docClient = new aws.DynamoDB.DocumentClient();
exports.handler = (event, context, callback) => {
    
    if(isNotEmpty(event.customerId)){
        console.log('customer Id : ', event.customerId);
        createCard(event.customerId);    
    }else{
        // parameter validation
        if(!isNotEmpty(event.userId)){
            callback('userId cannot be empty.');
        }
    
        stripe.customers.create({
            email: event.userId
        }, function(err, customer){
            if(err){
                console.log(err);
                callback(null, {success : 0});
            }else{
                createCard(customer.id);   
            }
        });    
    }
    
    function updateCustomerId(customerId, cardId){
        var params = {
            TableName : 'User',
            Key : {
                userName : event.userId
            },
            UpdateExpression : "set StripeCustomerId = :stripe_customer_id, StripeCardId = :stripe_card_id",
            ExpressionAttributeValues : {
                ':stripe_customer_id' : customerId,
                ':stripe_card_id' : cardId
            }
        };
        
        docClient.update(params, function(err, data){
            if(err){
                console.log(err);
                return callback(null, {success : 0});
            }else{
                console.log("data : ", data);        
            }
        });
    }
    
    function createCard(customerId){
        stripe.customers.createSource(customerId, { source: {
            object: event.type,
            exp_month: event.exp_month,
            exp_year: event.exp_year,
            number: event.card_number,
            cvc: event.cvc,
            address_zip:event.zip_code
        }}, function(err, source){
            if(err){
                console.log(err);
                callback(null, {success : 0});    
            }else{
                updateCustomerId(customerId, source.id);
                console.log("card : ", source);
                callback(null, {'customerId':customerId, cardId:source.id, success:1});        
            }    
        }); 
    }
    
    function isNotEmpty(str){
	    return str !== null && str !== '' && typeof str !== 'undefined';
	}
    
};