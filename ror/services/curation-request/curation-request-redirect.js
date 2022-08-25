exports.handler = (evt, ctx, cb) => {
  const response = {
      statusCode: 301,
      headers: {
        Location: 'https://docs.google.com/forms/d/e/1FAIpQLSdJYaMTCwS7muuTa-B_CnAtCSkKzt19lkirAKG4u7umH9Nosg/viewform',
      }
    };

  cb(null, response);
}