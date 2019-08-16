pragma solidity ^ 0.5 .0;
pragma experimental ABIEncoderV2;
import './tokens/IERC20.sol';
import './SafeMath.sol';
//@dev contract is not optimised for gas decided to use the experimental abiencoder to reduce gas usage
contract UNICEF {
    using SafeMath
    for uint256;
    /*=============== Struct definition Start=============== */
    struct School {
        bytes schoolInfo; //@dev abi ecoding of the school info
        UserTypes userType;
        bool active;
    }
    struct ISP {
        bytes32 name;
        address Address;
        bytes32 email;
        bytes32 country;
        uint256 uploadSpeed;
        uint256 downloadSpeed;
        UserTypes userType;
        bytes32[] donationKeys;
        bytes[] schoolsConnecting;
        bool active;
    }
    struct User {
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
        bytes32 country;
        bytes32 name;
        address funder;
        IERC20 token;
        bool active;
        bool isTokenDontaion;
    }

    struct Message {
        uint256 messageID;
        address from;
        bytes32 message;
        uint date;
        bool read;
        bool active;
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
    mapping(bytes => School) registeredSchools;
    bytes[] registeredSchoolsKeys;
    mapping(address => ISP) registeredISPs;
    address[] registeredISPsKeys;
    mapping(address => User) registeredDefaultUsers;
    address[] registeredDefaultUsersKeys;
    mapping(bytes32 => Donation) allDonations;
    bytes32[] allDonationsKeys;
    mapping(uint256 => Message) messages;
    bytes32[] messageKeys;
    uint256 uploadSpeed; //@dev required connection speed as per UNICEF
    uint256 downloadSpeed; //@dev required connection speed as per UNICEF
    uint256 internal etherReceived;
    /*=============== Contract Functions definition Start=============== */
    constructor() public {
        require(msg.sender != address(0), "Invalid sender address");
        unicefAddress = msg.sender;
        uploadSpeed = 5;
        downloadSpeed = 5;
        etherReceived = 0;
    }
    /*=============== Schools Functions definition Start=============== */
    /**
    @notice the function registers a batch of schools at a time
    */

    function registerSchools(uint256 upldSpeed, uint256 downldSpeed, bytes[] memory schoolnames, bytes[] memory postaladdress,
        bytes[] memory countries, bytes[] memory latitudes, bytes[] memory longitudes) public
    returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(registeredISPs[msg.sender].active, "ISP not registered");
        require(msg.sender != address(0), "Invalid sender address");
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
        require((uploadSpeed > 0 == downloadSpeed > 0) &&
            (postaladdress.length == countries.length) &&
            (latitudes.length == longitudes.length), "Arrays required to be the same length");
        for (uint256 i = 0; i <
            schoolnames.length; i++) {
            bytes memory schoolInfo = abi.encode(msg.sender, schoolnames[i], postaladdress[i], countries[i], latitudes[i], longitudes[i], upldSpeed, downldSpeed);
            require(!registeredSchools[schoolInfo].active, "School already registered");
            registeredSchools[schoolInfo].schoolInfo = schoolInfo;
            registeredSchools[schoolInfo].userType = UserTypes.SCHOOL;
            registeredISPs[msg.sender].schoolsConnecting.push(schoolInfo);
            registeredSchoolsKeys.push(schoolInfo);
        }
        return true;
    }

    function registerSchool(uint256 upldSpeed, uint256 downldSpeed, bytes32 name, bytes32 postaladdress, bytes32 country, bytes32 latitude, bytes32 longitude)
    public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(registeredISPs[msg.sender].active, "ISP not registered");
        require(registeredDefaultUsers[msg.sender].active, "User not registered before registering as a school");
        bytes memory schoolInfo = abi.encode(msg.sender, name, postaladdress, country, latitude, longitude, upldSpeed, downldSpeed);
        require(!registeredSchools[schoolInfo].active, "School already registered");
        registeredSchools[schoolInfo].active = true;
        registeredSchools[schoolInfo].schoolInfo = schoolInfo;
        registeredISPs[msg.sender].schoolsConnecting.push(schoolInfo);
        registeredSchools[schoolInfo].userType = UserTypes.SCHOOL;
        registeredSchoolsKeys.push(schoolInfo);
        return true;
    }

    function schoolRegistered(bytes memory schoolID) public view returns(bool) {
        return registeredSchools[schoolID].active;
    }

    function getRegisteredSchoolIDs() public view returns(bytes[] memory) {
        return registeredSchoolsKeys;
    }

    /*=============== ISP Function definition Start===============*/
    function registerISP(bytes32 name, bytes32 email, bytes32 country) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(!registeredISPs[msg.sender].active, "Already registered as ISP");
        require(registeredDefaultUsers[msg.sender].active, "User not registered");
        registeredISPs[msg.sender].Address = msg.sender;
        registeredISPs[msg.sender].email = email;
        registeredISPs[msg.sender].country = country;
        registeredISPs[msg.sender].userType = UserTypes.ISP;
        registeredISPs[msg.sender].active = true;
        registeredISPs[msg.sender].name = name;
        registeredISPsKeys.push(msg.sender);
        return true;
    }

    function ispRegistered(address IsP) public view returns(bool) {
        return registeredISPs[IsP].active;
    }

    function getISPDetails(address ispAddress) public view returns(address, bytes32, bytes32) {
        require(registeredISPs[ispAddress].active, "ISP doesnt exist");
        return (registeredISPs[ispAddress].Address, registeredISPs[ispAddress].name, registeredISPs[ispAddress].country);
    }

    function getISPKeys() public view returns(address[] memory) {
        return registeredISPsKeys;
    }

    function getSchoolsConnectedTOISPKeys() public view returns(bytes[] memory) {
        require(registeredISPs[msg.sender].active, "ISP not registered");
        return registeredISPs[msg.sender].schoolsConnecting;
    }

    function updateuploadDownloadSpeedISP(uint256 upload, uint256 download) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(registeredISPs[msg.sender].active, "Not registered as ISP");
        require(upload > 0, " upload Speed must be greater than 0");
        require(download > 0, "download Speed must be greater than 0");
        registeredISPs[msg.sender].uploadSpeed = upload;
        registeredISPs[msg.sender].downloadSpeed = download;
        return true;
    }
    /*=============== Default User Functions definition Start===============*/
    function registerUser(bytes32 email) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(!registeredDefaultUsers[msg.sender].active, "User already registered");
        registeredDefaultUsers[msg.sender].email = email;
        registeredDefaultUsers[msg.sender].userType = UserTypes.DEFAULT;
        registeredDefaultUsers[msg.sender].active = true;
        return true;
    }

    function userExists() public view returns(bool) {
        return registeredDefaultUsers[msg.sender].active;
    }

    /*=============== Donation Functions definition Start===============*/
    function donate(address ispAddress) public payable returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(ispAddress != address(0), "Invalid ispAddress address");
        require(registeredDefaultUsers[msg.sender].active, "Only registered Default users can register");
        require(registeredDefaultUsers[ispAddress].active, "Only registered Default users can register");
        require(registeredISPs[ispAddress].active, "ISP not registered");
        require(msg.value > 0, "Invalid amount amount must be greater than 0");
        bytes32 donationID = keccak256(abi.encode(msg.value, ispAddress, now));
        allDonations[donationID].donationID = donationID; //@dev this could also be done outisde of the contract *to consider*
        allDonations[donationID].receipient = ispAddress;
        allDonations[donationID].amount = msg.value;
        allDonations[donationID].funder = msg.sender;
        allDonations[donationID].active = true;
        allDonations[donationID].country = registeredISPs[msg.sender].country;
        allDonations[donationID].name = registeredISPs[msg.sender].name;
        allDonationsKeys.push(donationID);
        registeredISPs[msg.sender].donationKeys.push(donationID);
        registeredDefaultUsers[msg.sender].dontaions.push(donationID);
        return true;
    }

    function donateERC20(uint256 amount, address ispAddress, address tokenAddress) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(ispAddress != address(0), "Invalid ispAddress address");
        require(tokenAddress != address(0), "Invalid tokenAddress");
        require(registeredDefaultUsers[msg.sender].active, "Only registered Default users can register");
        require(registeredDefaultUsers[ispAddress].active, "Only registered Default users can register");
        require(registeredISPs[msg.sender].active, "ISP not registered");
        require(registeredISPs[ispAddress].active, "ISP not registered");
        require(amount > 0, "Invalid amount amount must be greater than 0");
        IERC20 donationToken = IERC20(tokenAddress);
        require(donationToken.balanceOf(msg.sender) > 0 && donationToken.balanceOf(msg.sender) > amount, "Insuffiecient token balance to make a donation");
        bytes32 donationID = keccak256(abi.encode(amount, ispAddress, now));
        allDonations[donationID].donationID = donationID; //@dev this could also be done outisde of the contract *to consider*
        allDonations[donationID].receipient = ispAddress;
        allDonations[donationID].funder = msg.sender;
        bool transfered = donationToken.transfer(ispAddress, amount);
        allDonations[donationID].token = donationToken;
        allDonations[donationID].isTokenDontaion = true;
        allDonations[donationID].country = registeredISPs[ispAddress].country;
        allDonations[donationID].name = registeredISPs[ispAddress].name;
        registeredISPs[ispAddress].donationKeys.push(donationID);
        registeredDefaultUsers[msg.sender].dontaions.push(donationID);
        allDonationsKeys.push(donationID);
        return transfered;
    }

    function widthdrawTokenDonation(bytes32 donationID, address receipient, uint256 amount) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(receipient != address(0), "Invalid receipient address");
        require(amount > 0, "Amount to transfer must be greater than 0");
        require(allDonations[donationID].active, "Donation is not valid");
        require(allDonations[donationID].isTokenDontaion, "Invalid token donation");
        bool transfered = allDonations[donationID].token.transfer(receipient, amount);
        return transfered;
    }

    function getUserDontaionKeys() public view returns(bytes32[] memory) {
        require(msg.sender != address(0), "Invalid sender address");
        require(registeredDefaultUsers[msg.sender].active, "Only registered Default users can register");
        return registeredDefaultUsers[msg.sender].dontaions;
    }

    function getDonation(bytes32 donationID) public view returns(bytes32 ispName, bytes32 ispCountry, uint256 amount, address funder) {
        return (allDonations[donationID].name, allDonations[donationID].country, allDonations[donationID].amount, allDonations[donationID].funder);
    }

    function getallDonationKeys() public view returns(bytes32[] memory) {
        return allDonationsKeys;
    }
    /*=============== Message Center Functions definition Start===============*/
    /*=============== Unicef  Functions definition Start===============*/
    function updateuploadDownloadSpeeds(uint256 upload, uint256 download) public onlyUnicef returns(bool) {
        uploadSpeed = upload;
        downloadSpeed = download;
    }
}