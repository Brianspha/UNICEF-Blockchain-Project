pragma solidity ^0.5 .0;
import '../tokens/IERC20.sol';
contract UNICEFContract {

    /*=============== Struct definition Start=============== */
    struct School {
        bytes32 name;
        bytes32 postalAddress;
        bytes32 country;
        bytes32 latitude;
        bytes32 longitude;
        UserTypes userType;
        bool active;
    }
    struct ISP {
        bytes32 name;
        bytes32 email;
        bytes32 country;
        UserTypes userType;
        mapping(bytes32 => Donation) donations;
        bytes32[] donationKeys;
        mapping(address => Connection) schoolsConnecting;
        bool active;
    }
    struct User {
        bytes32 name;
        bytes32 email;
        UserTypes userType;
        bytes32[] dontaions;
        bool active;
    }
    struct Connection {
        bytes32 schoolName;
        address isp;
        uint256 gigs;
        uint256 mpbs;
        bool active;
    }
    struct Donation {
        bytes32 donationID;
        address receipient;
        uint256 amount;
        address funder;
        IERC20 token;
        bool active;
        bool isTokenDontaion;
    }
    /*=============== Modifiers definition Start=============== */
    modifier onlyUnicef() {
        require(msg.sender == unicefAddress, "Only unicef admin is allowed to call this function");
        _;
    }
    /*=============== enum definition Start=============== */
    enum UserTypes {
        SCHOOL,
        ISP,
        DEFAULT
    }
    /*=============== Contract Variables definition Start=============== */
    address unicefAddress;
    mapping(address => School) registeredSchools;
    address[] registeredSchoolsKeys;
    mapping(address => ISP) registeredISPs;
    address[] registeredISPsKeys;
    mapping(address => User) registeredDefaultUsers;
    address[] registeredDefaultUsersKeys;
    mapping(bytes32 => Donation) allDonations;
    /*=============== Contract Functions definition Start=============== */
    constructor() public {
        require(msg.sender != address(0), "Invalid sender address");
        unicefAddress = msg.sender;
    }
    /*=============== Schools Functions definition Start=============== */
    /**
    @notice the function registers a batch of schools at a time
    */

    function registerSchools(address[] memory schools, bytes32[] memory schoolnames, bytes32[] memory postaladdress,
        bytes32[] memory countries, bytes32[] memory latitudes, bytes32[] memory longitudes) public
    onlyUnicef
    returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(schools.length <= 100, "Only 100 schools can be registered at a time");
        require(schoolnames.length <=
            100, "Only 100 schools can be registered at a time");
        require(postaladdress.length <=
            100, "Only 100 schools can be registered at a time");
        require(countries.length <=
            100, "Only 100 schools can be registered at a time");
        require(latitudes.length <=
            100, "Only 100 schools can be registered at a time");
        require(longitudes.length <=
            100, "Only 100 schools can be registered at a time");
        require((schools.length == schoolnames.length) &&
            (postaladdress.length == countries.length) &&
            (latitudes.length == longitudes.length), "Arrays required to be the same length");
        for (uint256 i = 0; i <
            schools.length; i++) {
            require(!registeredSchools[schools[i]].active, "School already registered");
            registeredSchools[schools[i]].name = schoolnames[i];
            registeredSchools[schools[i]].postalAddress = postaladdress[i];
            registeredSchools[schools[i]].userType = UserTypes.SCHOOL;
            registeredSchools[schools[i]].latitude = latitudes[i];
            registeredSchools[schools[i]].longitude = longitudes[i];
            registeredSchools[schools[i]].active = true;
            registeredSchools[schools[i]].country = countries[i];
            registeredSchoolsKeys.push(schools[i]);
        }
        return true;
    }

    function registerSchool(bytes32 name, bytes32 postaladdress, bytes32 country, bytes32 latitude, bytes32 longitude)
    public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(!registeredSchools[msg.sender].active, "School already registered");
        registeredSchools[msg.sender].active = true;
        registeredSchools[msg.sender].name = name;
        registeredSchools[msg.sender].postalAddress = postaladdress;
        registeredSchools[msg.sender].country = country;
        registeredSchools[msg.sender].latitude = latitude;
        registeredSchools[msg.sender].longitude = longitude;
        registeredSchools[msg.sender].userType = UserTypes.SCHOOL;
        return true;
    }
    /*=============== ISP Function definition Start===============*/
    function registerISP(bytes32 name, bytes32 email, bytes32 country) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(!registeredISPs[msg.sender].active, "Already registered as ISP");
        require(registeredISPs[msg.sender].userType != UserTypes.DEFAULT, "Cannot register as school and ISP");
        registeredISPs[msg.sender].name = name;
        registeredISPs[msg.sender].email = email;
        registeredISPs[msg.sender].country = country;
        registeredISPs[msg.sender].userType = UserTypes.ISP;
        registeredISPs[msg.sender].active = true;
        registeredISPsKeys.push(msg.sender);
        return true;
    }
    /*=============== Default User Functions definition Start===============*/
    function registerUser(bytes32 name, bytes32 email) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(registeredDefaultUsers[msg.sender].active, "User already registered");
        registeredDefaultUsers[msg.sender].active = true;
        registeredDefaultUsers[msg.sender].name = name;
        registeredDefaultUsers[msg.sender].email = email;
        registeredDefaultUsers[msg.sender].userType = UserTypes.DEFAULT;
        return true;
    }

    /*=============== Donation Functions definition Start===============*/
    function donate(uint256 amount, address ispAddress) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(ispAddress != address(0), "Invalid ispAddress address");
        require(registeredDefaultUsers[msg.sender].active, "Only registered Default users can register");
        require(registeredISPs[ispAddress].active, "ISP not registered");
        require(amount > 0, "Invalid amount amount must be greater than 0");
        bytes32 donationID = keccak256(abi.encode(amount, msg.sender, ispAddress, now));
        registeredISPs[ispAddress].donations[donationID].donationID = donationID; //@dev this could also be done outisde of the contract *to consider*
        registeredISPs[ispAddress].donations[donationID].receipient = ispAddress;
        registeredISPs[ispAddress].donations[donationID].amount = amount;
        registeredISPs[ispAddress].donations[donationID].funder = msg.sender;
        registeredISPs[ispAddress].donations[donationID].active = true;
        allDonations[donationID] = registeredISPs[ispAddress].donations[donationID];
        registeredISPs[ispAddress].donationKeys.push(donationID);
        registeredDefaultUsers[msg.sender].dontaions.push(donationID);
        return true;
    }

    function donateERC20(uint256 amount, address ispAddress, address tokenAddress) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(ispAddress != address(0), "Invalid ispAddress address");
        require(tokenAddress != address(0), "Invalid tokenAddress");
        require(registeredDefaultUsers[msg.sender].active, "Only registered Default users can register");
        require(registeredISPs[ispAddress].active, "ISP not registered");
        require(amount > 0, "Invalid amount amount must be greater than 0");
        IERC20 donationToken = IERC20(tokenAddress);
        require(donationToken.balanceOf(msg.sender) > 0 && donationToken.balanceOf(msg.sender) > amount, "Insuffiecient token balance to make a donation");
        bytes32 donationID = keccak256(abi.encode(amount, msg.sender, ispAddress, now));
        registeredISPs[ispAddress].donations[donationID].donationID = donationID; //@dev this could also be done outisde of the contract *to consider*
        registeredISPs[ispAddress].donations[donationID].receipient = ispAddress;
        registeredISPs[ispAddress].donations[donationID].funder = msg.sender;
        bool transfered = donationToken.transfer(ispAddress, amount);
        registeredISPs[ispAddress].donations[donationID].token = donationToken;
        registeredISPs[ispAddress].donations[donationID].isTokenDontaion = true;
        registeredISPs[ispAddress].donations[donationID].active = true;
        allDonations[donationID] = registeredISPs[ispAddress].donations[donationID];
        registeredISPs[ispAddress].donationKeys.push(donationID);
        registeredDefaultUsers[msg.sender].dontaions.push(donationID);
        return transfered;
    }

    function widthdrawTokenDonation(bytes32 donationID, address receipient, uint256 amount) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(receipient != address(0), "Invalid receipient address");
        require(amount > 0, "amount to transfer must be greater than 0");
        require(registeredISPs[msg.sender].donations[donationID].active, "Donation is not valid");
        require(registeredISPs[msg.sender].donations[donationID].isTokenDontaion, "Invalid token donation");
        bool transfered = registeredISPs[msg.sender].donations[donationID].token.transfer(receipient, amount);
        return transfered;
    }
}