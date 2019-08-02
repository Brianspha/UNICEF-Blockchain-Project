pragma solidity ^0.5.0;

import "./Token.sol";
import "node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Unicef {
    using SafeMath for uint;

    //Variables
    address public feeDonation; // the account that receives donation fees
    uint256 public feePercent; // the fee percentage
    address constant ETHER = address(0); // store Ether in tokens mapping with blank address
    mapping(address => mapping(address => uint256)) public tokens;
    mapping(uint256 => _Donation) public donations;
    uint256 public donationCount;
    mapping(uint256 => bool) public donationCancelled;
    mapping(uint256 => bool) public donationFilled;

    // Events
    event Deposit(address token, address user, uint256 amount, uint256 balance);
    event Withdraw(address token, address user, uint256 amount, uint256 balance);
    event Donation(
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        uint256 timestamp
    );
    event Cancel(
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        uint256 timestamp
    );
    event Donate(
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        address userFill,
        uint256 timestamp
    );

    // Structs
    struct _Donation {
        uint256 id;
        address user;
        address tokenGet;
        uint256 amountGet;
        address tokenGive;
        uint256 amountGive;
        uint256 timestamp;
    }

    constructor (address _feeDonation, uint256 _feePercent) public {
        feeDonation = _feeDonation;
        feePercent = _feePercent;
    }

    // Fallback: reverts if Ether is sent to this smart contract by mistake
    function() external {
        revert();
    }

    function depositEther() payable public {
        tokens[ETHER][msg.sender] = tokens[ETHER][msg.sender].add(msg.value);
        emit Deposit(ETHER, msg.sender, msg.value, tokens[ETHER][msg.sender]);
    }

    function withdrawEther(uint _amount) public {
        require(tokens[ETHER][msg.sender] >= _amount);
        tokens[ETHER][msg.sender] = tokens[ETHER][msg.sender].sub(_amount);
        msg.sender.transfer(_amount);
        emit Withdraw(ETHER, msg.sender, _amount, tokens[ETHER][msg.sender]);
    }

    function balanceOf(address _token, address _user) public view returns (uint256) {
        return tokens[_token][_user];
    }

    function makeDonation(address _tokenGet, uint256 _amountGet, address _tokenGive, uint256 _amountGive) public {
        donationCount = donationCount.add(1);
        donations[donationCount] = _Donation(donationCount, msg.sender, _tokenGet, _amountGet, _tokenGive, _amountGive, now);
        emit Donation(donationCount, msg.sender, _tokenGet, _amountGet, _tokenGive, _amountGive, now);
    }

    function cancelDonation(uint256 _id) public {
        _Donation storage _donation = donations[_id];
        require(address(_donation.user) == msg.sender);
        require(_donation.id == _id); // The donation must exist
        donationCancelled[_id] = true;
        emit Cancel(_donation.id, msg.sender, _donation.tokenGet, _donation.amountGet, _donation.tokenGive, _donation.amountGive, now);
    }

    function fillDonation(uint256 _id) public {
        require(_id > 0 && _id <= donationCount);
        require(!donationFilled[_id]);
        require(!donationCancelled[_id]);
        _Donation storage _donation = donations[_id];
        _Donate(_donation.id, _donation.user, _donation.tokenGet, _donation.amountGet, _donation.tokenGive, _donation.amountGive);
        donationFilled[_donation.id] = true;
    }

    function _Donate(uint256 _donationId, address _user, address _tokenGet, uint256 _amountGet, address _tokenGive, uint256 _amountGive) internal {
        // Fee paid by the user that fills the order, a.k.a. msg.sender.
        uint256 _feeAmount = _amountGive.mul(feePercent).div(100);

        tokens[_tokenGet][msg.sender] = tokens[_tokenGet][msg.sender].sub(_amountGet.add(_feeAmount));
        tokens[_tokenGet][_user] = tokens[_tokenGet][_user].add(_amountGet);
        tokens[_tokenGet][feeDonation] = tokens[_tokenGet][feeDonation].add(_feeAmount);
        tokens[_tokenGive][_user] = tokens[_tokenGive][_user].sub(_amountGive);
        tokens[_tokenGive][msg.sender] = tokens[_tokenGive][msg.sender].add(_amountGive);

        emit Donate(_donationId, _user, _tokenGet, _amountGet, _tokenGive, _amountGive, msg.sender, now);
    }
}