var stripe = require('stripe')('sk_test_NuyJOQjoskkAsGOXjiFXEaUn');
var aws = require("aws-sdk");
var docClient = new aws.DynamoDB.DocumentClient(); 


exports.handler = (event, context, callback) => {
    // TODO implement
    var params = {
        TableName: "Transaction",
        FilterExpression:"attribute_not_exists(MessageId) AND Refund = :refund",
        ExpressionAttributeValues : {
            ":refund" : false
        }
    };
    docClient.scan(params, function(err, data){
        if(err){
            console.log("failed to scan Transaction Table", err);
        }else{
            console.log(JSON.stringify(data));
            refund(data.Items, 0);
        }
    });
    
    function refund(items, index) {
        if(index < items.length){
            stripe.refunds.create({
                charge : items[index].ChargeId//"ch_19sr19D1PwQ5Ye86xTdpLLWw"
            }, function(err, refundData){
                if(err){
                    console.log("Refund error",  err);
                    refund(items, ++index);
                }else{
                    console.log("Refund success for index ", index, " ", refundData);
                    var params = {
                        TableName:'Transaction',
                        Key : {
                            "ChargeId" : items[index].ChargeId
                        },
                        UpdateExpression: "set Refund = :refund",
                        ExpressionAttributeValues:{
                            ":refund" : true
                        },
                        ReturnValues:"UPDATED_NEW"
                    }
                    docClient.update(params, function(e, d){
                        if(e){
                            console.log("failed to update Transaction table refund field", e);
                        } else {
                            console.log("success to update Transaction table refund field", d);
                        }
                        refund(items, ++index);
                    });
                }
            });    
        } else {
            callback(null, 'Refund Success');
        }
        
    }
};