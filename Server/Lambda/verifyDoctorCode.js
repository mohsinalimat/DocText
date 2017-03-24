var async = require('async');
var aws = require('aws-sdk');
var ddb = new aws.DynamoDB(
    {
        endpoint: 'https://dynamodb.us-west-2.amazonaws.com/',
        params: {TableName: 'Invitation_Table'}
    });
    
var docClient = new aws.DynamoDB.DocumentClient();    
    
exports.handler = (event, context, callback) => {
    var doctor;
	var doctorId;
	
    // parameter validation
    var paramValidation = '';
    if(!isNotEmpty(event.phone)){
        paramValidation += "phoneno cannot be empty.";
    }
    if(!isNotEmpty(event.code)){
        paramValidation += 'code cannot be empty.';
    }
    if(isNotEmpty(paramValidation)){
        callback(null, {success : 0, err : paramValidation});
    }

	async.waterfall([
		function getVerificationDetail(next){
		    console.log(event.phone);
			var prms = {
			    TableName: 'invitation_table',
				Key: {
					PhoneNo:  event.phone
				}
			};
			docClient.get(prms, function(err, data){
			    if(err){
			        console.log("err : ", err);
			        next(err);
			    }else{
			        console.log("data : ", data);
			        next(null, data);
			    }
			});
		},
		
		function verifyCode(response, next){
			if(response.Item && response.Item.VerificationCode && response.Item.VerificationCode.toString().trim() == event.code.toString().trim() && response.Item.IsVerified.toString() === 'false'){
				console.log('response : ', response);
				var doctorId = response.Item.DoctorId?response.Item.DoctorId:'';
				var roomParam = {
				    TableName : 'Room_Table',
                    FilterExpression: "doctorId = :doctorId AND patientId = :patientId",
                    ExpressionAttributeValues:{
                        ":doctorId": doctorId,
                        ":patientId": event.patientId
                    }
				};
				docClient.scan(roomParam, function(e,d){
				    if(e){
				       next(e); 
				    }else{
				        console.log(d);
				        if(d.Count === 0){
				            var params = {
                                TableName : 'invitation_table',
                                Key : {
                                    "PhoneNo": event.phone
                                },
                                UpdateExpression: "set IsVerified=:ms",
                                ExpressionAttributeValues:{
                                    ":ms":true
                                },
                                ReturnValues:"UPDATED_NEW"
                            };
                            docClient.update(params, function(err, data){
                                if(err){
                                    next(err);
                                }else{
                                    next(null, doctorId);
                                }
                            });    
				        }else{
				            next('already verified');
				        }
				    }
				});
    		   
			}else{
				next('verification failed');
			}
		},
		function getDoctorDetails(doctorId, next){
		    if(isNotEmpty(doctorId)){
		        var params = {
    				TableName: "User",
    				Key:{
    					"userName": doctorId
    				}
			};
			docClient.get(params, function(err, data){
			    if (err) {
    				next(err);
    			} else {
    				next(null, data);
    			}
			});    
		    }	
		}], function(err, data){
			if (err) {
				console.log(err);
				callback(null, {success : 0, err : err});
			} else {
			    console.log("success");
				callback(null, {'success' : 1, doctor : data.Item});
			}
		});
		
		
		function isNotEmpty(str){
		    return str !== null && str !== '' && typeof str !== 'undefined';
		}
};