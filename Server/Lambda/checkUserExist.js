var aws = require("aws-sdk");
var docClient = new aws.DynamoDB.DocumentClient();
exports.handler = (event, context, callback) => {
    
    // parametar validation
    if(!isNotEmpty(event.userId)){
        callback('userId cannot be empty.');
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
            if(isNotEmpty(data.Item)){
                callback(null, {isExist : 1});    
            }else{
                if(validateEmail(event.userId)){
                    callback(null, {isExist : 0, isValid : 1});
                }else{
                    callback(null, {isExist : 0, isValid : 0});    
                }
            }
                
        }
    });
    
    function isNotEmpty(str){
        return str !== null && str !== '' && typeof str !== 'undefined';
    }
    
    function validateEmail(email) {
      var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
      return re.test(email);
    }
};