var AWS = require('aws-sdk');

var region = 'us-east-1'; // e.g. us-west-1
var domain = 'search-movies-YOUR_MOVIES_DOMAIN_ID_HERE.us-east-1.es.amazonaws.com'; // e.g. search-domain.region.es.amazonaws.com
var index = 'movies';
var type = '_search';

exports.lambdaHandler = (event, context, callback) => {
	let endpoint = new AWS.Endpoint(domain);
	let request = new AWS.HttpRequest(endpoint);
	// let credentials = new AWS.EnvironmentCredentials('AWS');

	let query = {
		"size": 25,
		"query": {
			"multi_match": {
				"query": event['queryStringParameters']['q'],
				"fields": ["fields.title^4", "fields.plot^2", "fields.actors", "fields.directors"]
			}
		}
	}

	request.method = 'POST';
	request.path += index + '/' + type;
	request.body = JSON.stringify(query);
	request.headers['Content-Type'] = 'application/json';
	request.headers['host'] = domain;
	// returns an object, but needs to be a string
	// turns out including it does, in fact, hurt anything
	// request.headers['Content-Length'] = Buffer.byteLength(request.body);

	// const signer = new AWS.Signers.V4(request, 'es');
	// signer.addAuthorization(credentials, new Date());

	console.log('REQUEST, YO : ', request);

	let client = new AWS.HttpClient();
	client.handleRequest(request, null, (response) => {
		let responseBody = '';
		response.on('data', (chunk) => {
			responseBody += chunk;
		});
		response.on('end', (chunk) => {
			let responseToApiGateway = {
				"statusCode": 200,
				headers: {
					"Access-Control-Allow-Headers" : "'Content-Type,X-Amz-Date',Authorization,X-Api-Key,X-Amz-Security-Token'",
					"Access-Control-Allow-Methods" : "'GET,OPTIONS'",
					"Access-Control-Allow-Origin" : "*"
				},
				"isBase64Encoded": false,
				"body": responseBody
			}
			callback(null, responseToApiGateway);
		});
	})
}
