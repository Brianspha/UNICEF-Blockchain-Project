

module.exports = function(embark) {
  embark.registerClientWeb3Provider(function(options) {
    return "web3 = new Web3(new Web3.providers.HttpProvider('http://" + options.rpcHost + ":" + options.rpcPort + "'));";
  });
}