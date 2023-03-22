module.exports.handler = async (event) => {
    return {
      statusCode: 200,
      body: JSON.stringify(
        {
          message: 'ROR!',
          input: event,
        },
        null,
        2
      ),
    };
  };