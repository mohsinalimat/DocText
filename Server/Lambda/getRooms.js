exports.handler = (event, context, callback) => {

var AWS = require("aws-sdk");
var result;

AWS.config.update({
  region: "us-west-2",
  endpoint: "https://dynamodb.us-west-2.amazonaws.com/"
});
var ddb = new AWS.DynamoDB(
{
    endpoint: 'https://dynamodb.us-west-2.amazonaws.com/',
    params: {TableName: 'User'}
});
var docClient = new AWS.DynamoDB.DocumentClient();

// parameter validation
    if(!event.sender){
        callback("senderId cannot be empty");
    }
    
console.log(event.sender);
var params = {
    TableName: "Room_Table",
    IndexName: "doctorId-patientId-index",
    FilterExpression: "doctorId = :doctorId OR patientId = :patientId",
    ExpressionAttributeValues:{
        ":doctorId": event.sender,
        ":patientId": event.sender
    }
};

console.log("Scanning Rooms table.");
docClient.scan(params, onScan);

function onScan(err, data) {
    if (err) {
        console.error("Unable to scan the table. Error JSON:", JSON.stringify(err, null, 2));
    } else {
         global.result = data;
        console.log("Scan succeeded.");
        global.result.Items.sort(function(a,b) {
            aSent_time = Date.parse(a.lastMessageTime);
            bSent_time = Date.parse(b.lastMessageTime)
            console.log(aSent_time);
            console.log(bSent_time);
            if (aSent_time > bSent_time) return 1;
            if (aSent_time < bSent_time) return -1;
            return 0;
        });
        setUnreadCount(data.Items, 0);
    }
}

function setUnreadCount(items, index){
    if(index < items.length){
        docClient.scan({
            TableName:"lambdachat",
            FilterExpression: "room_id = :room_id",
            ExpressionAttributeValues:{
                ":room_id": items[index].room_id
            }
        }, function(e,d){
            if(e){
                console.log(e);
            }else{
                var count = 0;
                d.Items.forEach(function(msg, idx){
                    console.log(msg, idx);
                    if(msg.receiver_Id === event.sender && (msg.message_status === "Sent" || msg.message_status === "Not delivered")){
                        count++;
                    }
                });
                items[index].unreadCount = count;
                console.log(d);
                setUnreadCount(items, index+1);
            }
        });    
    } else{
        setReceiverDetails(items, 0);    
    }
}

function setReceiverDetails(items, index){
    if(index <items.length){
        var params = {
            TableName: 'User',
            Key:{
                "userName" : (event.sender === items[index].doctorId)?items[index].patientId:items[index].doctorId
                
            }
        }
        docClient.get(params, function(e,d){
            if(e){
                console.log(e);
            }else{
                items[index].receiverDetails = d.Item;
                setReceiverDetails(items, index+1);
            }
        })    
    }else{
        return callback(null, items);    
    }
}
};