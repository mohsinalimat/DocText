exports.handler = (event, context, callback) => {

    var AWS = require("aws-sdk");
    var result;
    
    AWS.config.update({
      region: "us-east-1",
      endpoint: "https://dynamodb.us-west-2.amazonaws.com/"
    });
    
    var docClient = new AWS.DynamoDB.DocumentClient();
    
    // parameter validation
    var paramValidation = '';
    if(!isNotEmpty(event.userId)){
        paramValidation += 'User Id cannot be empty. ';
    }
    if(!isNotEmpty(event.deviceId)){
        paramValidation += 'Device Id cannot be empty.';
    }
    if(isNotEmpty(paramValidation)){
        callback(paramValidation);
    }
    
    var params = {
        TableName:'DeviceToken',
        Key:{
            "userId":event.userId,
            "deviceId":event.deviceId
        }
    };
    
    console.log("Attempting a conditional delete...");
    docClient.delete(params, function(err, data) {
        if (err) {
            console.error("Unable to delete item. Error JSON:", JSON.stringify(err, null, 2));
            callback({success:0, err});
        } else {
            console.log("DeleteItem succeeded:", JSON.stringify(data, null, 2));
            callback(null, {success:1});
        }
    });
    
    function isNotEmpty(str){
        return str !== null && str !== '' && typeof str !== 'undefined';
    }
};