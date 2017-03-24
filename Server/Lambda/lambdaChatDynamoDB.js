console.log('Loading function');
var async = require('async');
var aws = require('aws-sdk');
var ddb = new aws.DynamoDB(
    {endpoint: "https://dynamodb.us-west-2.amazonaws.com/",
     params: {TableName: "Lambdachat"}});
var s3 = new aws.S3();
// change bucket name to match your bucket name
var bucket = "mrtext";
var keyname = "data.json";


function escapeHtml(text) {
  var map = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#039;'
  };

  return text.replace(/[&<>"']/g, function(m) { return map[m]; });
}


exports.handler = function(event, context) {
    console.log('Handle DynamoDB Streams event');
    console.log(JSON.stringify(event, null, 2));
    var new_object = event.Records[0].dynamodb;
    var channel = "default";
    // if ('channel' in new_object.NewImage) {
    //     channel = new_object.NewImage.channel.S;
    // }
    // console.log("channel = " + channel);


    async.waterfall([
        function getrecords(next) {
            var params = {
                "IndexName": "message_id",
                "KeyConditions": {
                    "channel": { 
                        "AttributeValueList": [{
                            "S": channel
                        }],
                        "ComparisonOperator": "EQ"
                    }

                },
                "Limit": 20,
                "ScanIndexForward": false
            }
            console.log("Scanning the table");
            ddb.query(params, next);
        },
        function buildjson(response, next) {
            console.log("Building JSON file");
            console.log(JSON.stringify(response));
            var messageData = {
                messages: []
            };

            for (var i = response.Items.length - 1; i >= 0; i--) {
                ii = response.Items[i];
                var message = {};
                message['id'] = ii.message_id['S'];
                message['room_id'] = escapeHtml(ii.room_id['S']);
                message['message'] = escapeHtml(ii.message['S']);
                message['sender_id'] = ii.sender_id['S'];
                messageData.messages.push(message);
            }
            next(null, JSON.stringify(messageData));
        },
        function savetos3(jsonstring, next) {
            console.log(jsonstring);
            // s3.putObject({
            //     Bucket: bucket,
            //     Key: keyname,
            //     Body: jsonstring
            //     }, next);
        }
    ], function (err) {
        if (err) {
            console.log('got an error');
            console.log(err, err.stack);
        } else {
            console.log('Saved Data to S3');
        }
       context.done(err, '');
   });

};
