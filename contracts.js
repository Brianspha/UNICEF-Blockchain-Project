module.exports = {
  Chain: {
    deployment: {
      protocol: "http",
      type: "rpc",
      host: "146.231.123.137",
      port: "11000",
    },
    gas: "8000000",
    contracts: {

    }
  },
  infura: {
    deployment: {
      host: "ropsten.infura.io/v3/47fbe32af4e4448888dc594e68c40c1d",
      port: false,
      protocol: 'https',
      type: "rpc",
      accounts: [{
        mnemonic: "rescue safe canal pond candy notice woman acquire marriage place morning public",
        addressIndex: "0", // Optional. The index to start getting the address
        numAddresses: "10"
      }]
    },
    gas: "8000000",
    contracts: {
    }
  } // you can name an environment with specific settings and then specify with
  // "embark run custom_name" or "embark blockchain custom_name"
  //custom_name: {
  //}
};