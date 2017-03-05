const { createFill, createBatchFill, createCancel } = require('./formatUtil.js');

module.exports = exchange => {
  return {
    fill: (order, { fillValueM, from }) => {
      let params = createFill(order, fillValueM);
      return exchange.fill(
        params.traders,
        params.feeRecipient,
        params.tokens,
        params.values,
        params.fees,
        params.expiration,
        params.fillValueM,
        params.v,
        params.rs,
        { from }
      );
    },
    batchFill: (orders, { fillValuesM, from }) => {
      let params = createBatchFill(orders, fillValuesM);
      return exchange.batchFill(
        params.traders,
        params.feeRecipients,
        params.tokens,
        params.values,
        params.fees,
        params.expirations,
        params.fillValuesM,
        params.v,
        params.rs,
        { from }
      );
    },
    cancel: (order, { cancelValueM, from }) => {
      let params = createCancel(order, cancelValueM);
      return exchange.cancel(
        params.traders,
        params.tokens,
        params.values,
        params.expiration,
        params.cancelValueM,
        { from }
      );
    }
  };
};
