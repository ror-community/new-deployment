'use strict';

const https = require("https");
const path = require('path');
let url = "https://api.ror.org/v2/organizations";

exports.handler = async function (event, callback) {
    const request = event.Records[0].cf.request;

    let statusCode;
    await new Promise(function (resolve, reject) {
        https.get(url + request.uri, (res) => {
            statusCode = res.statusCode;
            resolve(statusCode);
        }).on("error", (e) => {
            reject(Error(e));
        });
    });
    if (statusCode == 200) {
        if (!path.extname(request.uri)) {
            request.uri = '/index.html';
        }
    }
    return request;
}