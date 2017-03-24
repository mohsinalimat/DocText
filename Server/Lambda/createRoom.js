var aws = require('aws-sdk');
var chatroomdb = new aws.DynamoDB(
    {
        endpoint: 'https://dynamodb.us-west-2.amazonaws.com/',
        params: {TableName: 'Room_Table'}
    });

exports.handler = (event, context, callback) => {
    
    var doctor = event.doctor;
    var patient = event.patient;
    
    var paramValidation = '';
    
    if(!isNotEmpty(doctor)){
        paramValidation += 'doctor field cannot be empty. ';
    }
    if(!isNotEmpty(patient)){
        paramValidation += 'patient field cannot be empty.';
    }
    console.log('paramValidation : ', paramValidation);
    if(isNotEmpty(paramValidation)){
        return callback(null, {success : 0, err :paramValidation});
    }
    
    
	var time = Date.now().toString();
	var params = {Item: {
				 room_id: {S: time},
				 createdTime: {S: time},
				 doctorId: {S: doctor.id},
				 patientId: {S: patient.id},
				 roomName: {S: "Room_"+time},
				 doctorName: {S: doctor.firstName + "__" + doctor.lastName},
				 patientName: {S: patient.firstName + "__" + patient.lastName},
				 doctorImageUrl: {S: doctor.profilePicUrl},
				 patientImageUrl: {S: patient.profilePicUrl}
	}};
	console.log(params);
	chatroomdb.putItem(params, function(err, data){
	    if(err){
	        callback(null, {success : 0, err :err});
	    }else{
	        callback(null, {success : 1});
	    }
	});
	
	function isNotEmpty(str){
	    return str !== null && str !== '' && typeof str !== 'undefined';
	}
};