pragma solidity ^ 0.5 .0;
import './tokens/IERC20.sol';

//@dev contract is not optimised for gas has many illogical decisions which will be rectified
contract UNICEF {

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
        bytes32 nameAddress;
        bytes32 name;
        address Address;
        bytes32 email;
        bytes32 country;
        uint256 uploadSpeed;
        uint256 downloadSpeed;
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
        bytes32 nameAddress;
        uint256 amount;
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
    mapping(address => School) registeredSchools;
    address[] registeredSchoolsKeys;
    mapping(bytes32 => ISP) registeredISPs;
    bytes32[] registeredISPsKeys;
    mapping(address => User) registeredDefaultUsers;
    address[] registeredDefaultUsersKeys;
    mapping(bytes32 => Donation) allDonations;
    mapping(uint256 => Message) messages;
    bytes32[] messageKeys;
    uint256 uploadSpeed; //@dev required connection speed as per UNICEF
    uint256 downloadSpeed; //@dev required connection speed as per UNICEF
    /*=============== Contract Functions definition Start=============== */
    constructor() public {
        require(msg.sender != address(0), "Invalid sender address");
        unicefAddress = msg.sender;
        uploadSpeed = 5;
        downloadSpeed = 5;
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
        bytes32 nameAddress = keccak256(abi.encode(name,msg.sender)); //@dev can be done outside of the Contract
        require(!registeredISPs[nameAddress].active, "Already registered as ISP");
        require(registeredISPs[nameAddress].userType != UserTypes.DEFAULT, "Cannot register as school and ISP");
        registeredISPs[nameAddress].nameAddress = nameAddress;
        registeredISPs[nameAddress].Address = msg.sender;
        registeredISPs[nameAddress].email = email;
        registeredISPs[nameAddress].country = country;
        registeredISPs[nameAddress].userType = UserTypes.ISP;
        registeredISPs[nameAddress].active = true;
        registeredISPs[nameAddress].name = name;
        registeredISPsKeys.push(nameAddress);
        return true;
    }

    function getISPDetails(bytes32 ispID) public view returns(address,bytes32,bytes32) {
        require(!registeredISPs[ispID].active, "Already registered as ISP");
        return (registeredISPs[ispID].Address,registeredISPs[ispID].name,registeredISPs[ispID].country);
    }
    function getISPKeys() public view returns (bytes32[] memory){
        return registeredISPsKeys;
    }
    function updateuploadDownloadSpeedISP(uint256 upload, uint256 download, bytes32 ispName) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(registeredISPs[ispName].active, "Already registered as ISP");
        require(upload > 0, " upload Speed must be greater than 0");
        require(download > 0, "download Speed must be greater than 0");
        registeredISPs[ispName].uploadSpeed = upload;
        registeredISPs[ispName].downloadSpeed = download;
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
    function donate(uint256 amount, address ispAddress, bytes32 ispName) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(ispAddress != address(0), "Invalid ispAddress address");
        require(registeredDefaultUsers[msg.sender].active, "Only registered Default users can register");
        require(registeredISPs[ispName].active, "ISP not registered");
        require(amount > 0, "Invalid amount amount must be greater than 0");
        bytes32 donationID = keccak256(abi.encode(amount, registeredISPs[ispName].nameAddress, now));
        registeredISPs[ispName].donations[donationID].donationID = donationID; //@dev this could also be done outisde of the contract *to consider*
        registeredISPs[ispName].donations[donationID].receipient = ispAddress;
        registeredISPs[ispName].donations[donationID].amount = amount;
        registeredISPs[ispName].donations[donationID].funder = msg.sender;
        registeredISPs[ispName].donations[donationID].active = true;
        allDonations[donationID] = registeredISPs[ispName].donations[donationID];
        registeredISPs[ispName].donationKeys.push(donationID);
        registeredDefaultUsers[msg.sender].dontaions.push(donationID);
        return true;
    }

    function donateERC20(uint256 amount, address ispAddress, bytes32 ispName,address tokenAddress) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(ispAddress != address(0), "Invalid ispAddress address");
        require(tokenAddress != address(0), "Invalid tokenAddress");
        require(registeredDefaultUsers[msg.sender].active, "Only registered Default users can register");
        require(registeredISPs[ispName].active, "ISP not registered");
        require(amount > 0, "Invalid amount amount must be greater than 0");
        IERC20 donationToken = IERC20(tokenAddress);
        require(donationToken.balanceOf(msg.sender) > 0 && donationToken.balanceOf(msg.sender) > amount, "Insuffiecient token balance to make a donation");
        bytes32 donationID = keccak256(abi.encode(amount, registeredISPs[ispName].nameAddress, now));
        registeredISPs[ispName].donations[donationID].donationID = donationID; //@dev this could also be done outisde of the contract *to consider*
        registeredISPs[ispName].donations[donationID].receipient = ispAddress;
        registeredISPs[ispName].donations[donationID].funder = msg.sender;
        bool transfered = donationToken.transfer(ispAddress, amount);
        registeredISPs[ispName].donations[donationID].token = donationToken;
        registeredISPs[ispName].donations[donationID].isTokenDontaion = true;
        registeredISPs[ispName].donations[donationID].active = true;
        allDonations[donationID] = registeredISPs[ispName].donations[donationID];
        registeredISPs[ispName].donationKeys.push(donationID);
        registeredDefaultUsers[msg.sender].dontaions.push(donationID);
        return transfered;
    }

    function widthdrawTokenDonation(bytes32 donationID, address receipient, uint256 amount, bytes32 ispSender) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(receipient != address(0), "Invalid receipient address");
        require(amount > 0, "amount to transfer must be greater than 0");
        require(registeredISPs[ispSender].donations[donationID].active, "Donation is not valid");
        require(registeredISPs[ispSender].donations[donationID].isTokenDontaion, "Invalid token donation");
        bool transfered = registeredISPs[ispSender].donations[donationID].token.transfer(receipient, amount);
        return transfered;
    }

    function getUserDontaionKeys() public view returns(bytes32[] memory) {
        require(msg.sender != address(0), "Invalid sender address");
        require(registeredDefaultUsers[msg.sender].active, "Only registered Default users can register");
        return registeredDefaultUsers[msg.sender].dontaions;
    }

    function getDonation(bytes32 donationID) public view returns(bytes32 ispName, bytes32 ispCountry, uint256 amount) {
        return (registeredISPs[allDonations[donationID].nameAddress].name, registeredISPs[allDonations[donationID].nameAddress].country, allDonations[donationID].amount);
    }

    /*=============== Message Center Functions definition Start===============*/
    /*=============== Unicef  Functions definition Start===============*/
    function updateuploadDownloadSpeeds(uint256 upload, uint256 download) public onlyUnicef returns(bool) {
        uploadSpeed = upload;
        downloadSpeed = download;
    }
}