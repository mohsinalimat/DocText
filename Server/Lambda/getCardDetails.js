var stripe = require('stripe')('sk_test_NuyJOQjoskkAsGOXjiFXEaUn');
var aws = require("aws-sdk");
var docClient = new aws.DynamoDB.DocumentClient(); 
exports.handler = (event, context, callback) => {
    
    // parameter validation
    var paramValidation = '';
    if(!isNotEmpty(event.customerId)){
        paramValidation += 'customerId cannot be empty.';
    }
    if(!isNotEmpty(event.cardId)){
        paramValidation += 'cardId cannot be empty.';
    }
    if(isNotEmpty(paramValidation)){
        callback({success:0, validationError:paramValidation});
    }
    stripe.customers.retrieveCard(event.customerId, event.cardId, 
    function(err, card) {
        if(err){
            console.log(err);
            callback(null, {success : 0, validationError : err});
        }else{
            console.log('card : ', card);
            var current_year = new Date().getFullYear();
            var current_month = new Date().getMonth();
            var error = '';
            if(card.exp_year > current_year){
                switch(card.cvc_check){
                    case 'fail':
                        error = 'cvc fail. Update it!';
                        break;
                    case 'unavailable':
                        error = 'cvc unavailable. Update it!';
                        break;
                    case 'unchecked':
                        error = 'cvc unchecked.';
                        break;
                    default:
                        break;
                }
            }else if(card.exp_year === current_year){
                if(card.exp_month < current_month) {
                    error = "This card has expired. Update it!";
                }
            }else{
                error = "This card has expired. Update it!";
            }
            if(error !== null & error !== ''){
                callback(null, {success : 0, card : card, validationError : error});        
            }else{
                callback(null, {success : 1, card : card});    
            }
            
        }
    });
    
    function isNotEmpty(str){
        return str !== null && str !== '' && typeof str !== 'undefined';
    }
};