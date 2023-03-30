const https = require("https");
let url = "https://api.ror.org/organizations";

exports.handler = async function (event) {
    const request = event.Records[0].cf.request;
    const response = event.Records[0].cf.response;
    let statusCode;
    await new Promise(function (resolve, reject) {
        https.get(url + request.uri, (res) => {
            statusCode = res.statusCode;
            resolve(statusCode);
        }).on("error", (e) => {
            reject(Error(e));
        });
    });
    if (statusCode != 200) {
        response.status = 404
        response.body = "ROR ID not found"
    }
    return response
}