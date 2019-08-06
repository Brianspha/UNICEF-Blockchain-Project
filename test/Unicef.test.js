import { ether, EVM_REVERT, ETHER_ADDRESS } from './helpers'

const Token = artifacts.require('./Token')
const Unicef = artifacts.require('./Unicef')

require('chai')
  .use(require('chai-as-promised'))
  .should()

contract('Unicef', ([deployer, donationAccount, user1, user2]) => {
    let token
    let unicef
    const feePercent = 10
    const speedConnectivity = 12

  beforeEach(async () => {
    // Deploy token
    token = await Token.new()

    // Transfer some tokens to user1
    token.transfer(user1, tokens(100), { from: deployer })

    // Deploy unicef contract
    unicef = await Unicef.new(donationAccount, feePercent, speedConnectivity)
  })

  describe('deployment', () => {
   it('tracks the donation account', async () => {
     const result = await unicef.donationAccount()
     result.should.equal(donationAccount)
   })

   it('tracks the fee percent', async () => {
     const result = await unicef.feePercent()
     result.toString().should.equal(feePercent.toString())
   })

   it('tracks the speed connecticity', async () => {
    const result = await unicef.speedConnectivity()
    result.should.equal(speedConnectivity)
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

  describe('withdrawing Ether', async () => {
    let result
    let amount
 
    beforeEach(async () => {
      // Deposit Ether first
      amount = ether(1)
      await unicef.depositEther({ from: user1, value: amount })
    })
 
    describe('success', async () => {
      beforeEach(async () => {
        // Withdraw Ether
        result = await unicef.withdrawEther(amount, { from: user1 })
      })
 
      it('withdraws Ether funds', async () => {
        const balance = await unicef.tokens(ETHER_ADDRESS, user1)
        balance.toString().should.equal('0')
      })
 
      it('emits a "Withdraw" event', async () => {
        const log = result.logs[0]
        log.event.should.eq('Withdraw')
        const event = log.args
        event.token.should.equal(ETHER_ADDRESS)
        event.user.should.equal(user1)
        event.amount.toString().should.equal(amount.toString())
        event.balance.toString().should.equal('0')
      })
    })
 
    describe('failure', async () => {
      it('rejects withdraws for insufficient balances', async () => {
        await unicef.withdrawEther(ether(100), { from: user1 }).should.be.rejectedWith(EVM_REVERT)
      })
    })
   });

   describe('checking balances', async () => {
    beforeEach(async () => {
      unicef.depositEther({ from: user1, value: ether(1) })
    })
 
    it('returns user balance', async () => {
      const result = await unicef.balanceOf(ETHER_ADDRESS, user1)
      result.toString().should.equal(ether(1).toString())
    })
   })

   describe('making donations', async () => {
    let result
 
    beforeEach(async () => {
      result = await unicef.makeDonation(token.address, tokens(1), ETHER_ADDRESS, ether(1), { from: user1 })
    })
 
    it('tracks the newly created donation', async () => {
      const donationCount = await unicef.donationCount()
      donationCount.toString().should.equal('1')
      const donation = await unicef.donations('1')
      donation.id.toString().should.equal('1', 'id is correct')
      donation.user.should.equal(user1, 'user is correct')
      donation.tokenGet.should.equal(token.address, 'tokenGet is correct')
      donation.amountGet.toString().should.equal(tokens(1).toString(), 'amountGet is correct')
      donation.tokenGive.should.equal(ETHER_ADDRESS, 'tokenGive is correct')
      donation.amountGive.toString().should.equal(ether(1).toString(), 'amountGive is correct')
      donation.timestamp.toString().length.should.be.at.least(1, 'timestamp is present')
    })
 
    it('emits an "donation" event', async () => {
      const log = result.logs[0]
      log.event.should.eq('donation')
      const event = log.args
      event.id.toString().should.equal('1', 'id is correct')
      event.user.should.equal(user1, 'user is correct')
      event.tokenGet.should.equal(token.address, 'tokenGet is correct')
      event.amountGet.toString().should.equal(tokens(1).toString(), 'amountGet is correct')
      event.tokenGive.should.equal(ETHER_ADDRESS, 'tokenGive is correct')
      event.amountGive.toString().should.equal(ether(1).toString(), 'amountGive is correct')
      event.timestamp.toString().length.should.be.at.least(1, 'timestamp is present')
    })
   })

   describe('donation actions', async () => {

    beforeEach(async () => {
      // user1 deposits ether only
      await unicef.depositEther({ from: user1, value: ether(1) })
      // give tokens to user2
      await token.transfer(user2, tokens(100), { from: deployer })
      // user2 deposits tokens only
      await token.approve(unicef.address, tokens(2), { from: user2 })
      await unicef.depositToken(token.address, tokens(2), { from: user2 })
      // user1 makes an donation through buying tokens with Ether
      await unicef.makedonation(token.address, tokens(1), ETHER_ADDRESS, ether(1), { from: user1 })
    })

    describe('filling donations', async () => {
      let result

      describe('success', async () => {
        beforeEach(async () => {
          // user2 fills donation
          result = await unicef.fillDonation('1', { from: user2 })
        })

        it('executes the donation & charges fees', async () => {
          let balance
          balance = await unicef.balanceOf(token.address, user1)
          balance.toString().should.equal(tokens(1).toString(), 'user1 received tokens')
          balance = await unicef.balanceOf(ETHER_ADDRESS, user2)
          balance.toString().should.equal(ether(1).toString(), 'user2 received Ether')
          balance = await unicef.balanceOf(ETHER_ADDRESS, user1)
          balance.toString().should.equal('0', 'user1 Ether deducted')
          balance = await unicef.balanceOf(token.address, user2)
          balance.toString().should.equal(tokens(0.9).toString(), 'user2 tokens deducted with fee applied')
          const donationAccount = await unicef.donationAccount()
          balance = await unicef.balanceOf(token.address, donationAccount)
          balance.toString().should.equal(tokens(0.1).toString(), 'donationAccount received fee')
        })

        it('updates filled donations', async () => {
          const donationFilled = await unicef.donationFilled(1)
          donationFilled.should.equal(true)
        })

        it('emits a "Trade" event', async () => {
          const log = result.logs[0]
          log.event.should.eq('Trade')
          const event = log.args
          event.id.toString().should.equal('1', 'id is correct')
          event.user.should.equal(user1, 'user is correct')
          event.tokenGet.should.equal(token.address, 'tokenGet is correct')
          event.amountGet.toString().should.equal(tokens(1).toString(), 'amountGet is correct')
          event.tokenGive.should.equal(ETHER_ADDRESS, 'tokenGive is correct')
          event.amountGive.toString().should.equal(ether(1).toString(), 'amountGive is correct')
          event.userFill.should.equal(user2, 'userFill is correct')
          event.timestamp.toString().length.should.be.at.least(1, 'timestamp is present')
        })
      })

      describe('failure', async () => {

        it('rejects invalid donation ids', async () => {
          const invalidDonationId = 99999
          await unicef.fillDonation(invalidDonationId, { from: user2 }).should.be.rejectedWith(EVM_REVERT)
        })

        it('rejects already-filled donations', async () => {
          // Fill the donation
          await unicef.fillDonation('1', { from: user2 }).should.be.fulfilled
          // Try to fill it again
          await unicef.fillDonation('1', { from: user2 }).should.be.rejectedWith(EVM_REVERT)
        })

        it('rejects cancelled donations', async () => {
          // Cancel the donation
          await unicef.cancelDonation('1', { from: user1 }).should.be.fulfilled
          // Try to fill the donation
          await unicef.fillDonation('1', { from: user2 }).should.be.rejectedWith(EVM_REVERT)
        })
      })

    })

    describe('cancelling donations', async () => {
      let result

      describe('success', async () => {
        beforeEach(async () => {
          result = await unicef.cancelDonation('1', { from: user1 })
        })

        it('updates cancelled donations', async () => {
          const donationCancelled = await unicef.donationCancelled(1)
          donationCancelled.should.equal(true)
        })

        it('emits a "Cancel" event', async () => {
          const log = result.logs[0]
          log.event.should.eq('Cancel')
          const event = log.args
          event.id.toString().should.equal('1', 'id is correct')
          event.user.should.equal(user1, 'user is correct')
          event.tokenGet.should.equal(token.address, 'tokenGet is correct')
          event.amountGet.toString().should.equal(tokens(1).toString(), 'amountGet is correct')
          event.tokenGive.should.equal(ETHER_ADDRESS, 'tokenGive is correct')
          event.amountGive.toString().should.equal(ether(1).toString(), 'amountGive is correct')
          event.timestamp.toString().length.should.be.at.least(1, 'timestamp is present')
        })

      })

      describe('failure', async () => {
        it('rejects invalid donation ids', async () => {
          const invalidDonationId = 99999
          await unicef.cancelDonation(invalidDonationId, { from: user1 }).should.be.rejectedWith(EVM_REVERT)
        })

        it('rejects unauthorized cancelations', async () => {
          // Try to cancel the donation from another user
          await unicef.cancelDonation('1', { from: user2 }).should.be.rejectedWith(EVM_REVERT)
        })
      })
    })
  })
})