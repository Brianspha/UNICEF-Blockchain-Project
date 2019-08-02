import { ether, EVM_REVERT, ETHER_ADDRESS } from './helpers'

const Unicef = artifacts.require('./Unicef')

require('chai')
  .use(require('chai-as-promised'))
  .should()

contract('Unicef', ([donationAccount, user1]) => {
  let unicef
  const donationAmount = 10

  beforeEach(async () => {

    // Deploy unicef contract
    unicef = await Unicef.new(donationAccount, donationAmount)
  })

  describe('deployment', () => {
   it('tracks the donation account', async () => {
     const result = await unicef.donationAccount()
     result.should.equal(donationAccount)
   })

   it('tracks the donation amount', async () => {
     const result = await unicef.donationAmount()
     result.toString().should.equal(donationAmount.toString())
   })
  })


  describe('fallback', () => {
   it('reverts when Ether is sent', async () => {
     await unicef.sendTransaction({ value: 1, from: user1 }).should.be.rejectedWith(EVM_REVERT)
   })
  })

  describe('depositing Ether', async () => {
   let result
   let amount

   beforeEach(async () => {
     amount = ether(1)
     result = await unicef.depositEther({ from: user1, value: amount})
   })

   it('tracks the Ether deposit', async () => {
     const balance = await unicef.tokens(ETHER_ADDRESS, user1)
     balance.toString().should.equal(amount.toString())
   })

   it('emits a Deposit event', async () => {
     const log = result.logs[0]
     log.event.should.eq('Deposit')
     const event = log.args
     event.token.should.equal(ETHER_ADDRESS, 'token address is correct')
     event.user.should.equal(user1, 'user address is correct')
     event.amount.toString().should.equal(amount.toString(), 'amount is correct')
     event.balance.toString().should.equal(amount.toString(), 'balance is correct')
   })
  })
})