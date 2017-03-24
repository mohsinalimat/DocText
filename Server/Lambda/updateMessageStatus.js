var aws = require('aws-sdk');
var docClient = new aws.DynamoDB.DocumentClient();

exports.handler = (event, context, callback) => {
    var paramvalid = '';
    if(isEmpty(event.messageIds) || event.messageIds.length <= 0){
        paramValid = 'Message Ids cannot be empty';
    }
    if(isEmpty(event.roomId)){
        paramValid += 'Room Id cannot be empty';
    }
    if(isEmpty(event.messageStatus)){
        paramValid += 'Message Status cannot be empty';
    }
    // if(isEmpty(event.senderId)){
    //     paramValid += 'Sender Id cannot be empty';
    // }
    if(!isEmpty(paramValid)){
        callback(paramValid);
    }
    console.log(event);
    var params = {
        TableName : 'lambdachat',
        Key:{
            "room_id":event.roomId,
            "message_id":event.messageIds[0]
        },
        UpdateExpression: "set message_status=:ms",
        // ConditionExpression: "sender_id <> :sender_id",
        ExpressionAttributeValues:{
            ":ms":event.messageStatus,
            // ":sender_id":event.senderId
        },
        ReturnValues:"UPDATED_NEW"
    };
    updateStatus(params, 0, event.messageIds);
    
    
    function updateStatus(params, index, messageIds){
        if(index < messageIds.length){
            docClient.update(params, function(err, data){
               if(err) {
                   callback(null, {'success' : 0, error: err});
               }else{
                   console.log(data);
                   params.Key.message_id = messageIds[++index];
                   console.log(params);
                   updateStatus(params, index, messageIds);
               }
            });     
        }else{
            callback(null, {'success':1});
        }  
    }
    
    
    
    function isEmpty(str){
	    return str !== null || str !== '' || typeof str !== 'undefined';
	}
};