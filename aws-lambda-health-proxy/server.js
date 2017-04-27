'use strict';
console.log('Loading event');
var AWS = require("aws-sdk");

const BATTERY_GOOD = "good";
const BATTERY_LOW = "low";

exports.handler = function(event, context, callback) {
    console.log("received event: " + event.body);
    let data = JSON.parse(event.body);
    console.log("Battery voltage is " + data.battery_voltage)
    console.log("Comparing to min of " + process.env.battery_voltage_min_threshold)
    let battery_health = BATTERY_GOOD;
    
    if (data.battery_voltage < process.env.battery_voltage_min_threshold) {
        battery_health = BATTERY_LOW;
        
        console.log("Battery low, sending SNS alert");
        var sns = new AWS.SNS();
        var params = {
            Message: "Battery voltage is currently "
                + data.battery_voltage
                + "V.\n\nLow voltage threshold is "
                + process.env.battery_voltage_min_threshold
                + "V.", 
            Subject: "Battery voltage low!",
            TopicArn: "arn:aws:sns:us-east-1:048289345427:bamboo_monitor_health_alerts"
        };
        sns.publish(params, context.done);
    }
    
    
    let response = {
        statusCode: '200',
        body: JSON.stringify({
            status: 'success',
            battery_health: battery_health
        }),
        headers: {
            'Content-Type': 'application/json',
        }
    };
    
    callback(null, response);
};
