exports.handler = (evt, ctx, cb) => {
    const response = {
        statusCode: 200,
        body: JSON.stringify(
        {
            message: 'Let\'s ROR!',
            input: evt,
        },
        null,
        2
        ),
      };

    cb(null, response);
  }