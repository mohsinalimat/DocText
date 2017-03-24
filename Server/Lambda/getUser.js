var aws = require("aws-sdk");
var docClient = new aws.DynamoDB.DocumentClient();
exports.handler = (event, context, callback) => {
    
    // parametar validation
    if(!isNotEmpty(event.userId)){
        callback('userId cannot be empty.')
    }
    var param = {
        TableName : "User",
        Key : {
            userName : event.userId
        }
    };
    docClient.get(param, function(err, data){
        if(err){
            callback(err);    
        }else{
            callback(null, data);    
        }
    });
    
    function isNotEmpty(str){
        return str !== null && str !== '' && typeof str !== 'undefined';
    }
};