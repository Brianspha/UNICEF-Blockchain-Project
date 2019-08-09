pragma solidity 0.5 .9;

contract UNICEFContract {

    /*=============== Struct definition Start=============== */
    struct School {
        bytes32 name;
        bytes32 postalAddress;
        bytes32 city;
        bytes32 country;
        bytes32 latitude;
        bytes32 longitude;
        bool active;
    }

    /*=============== Modifiers definition Start=============== */
    modifier onlyUnicef() {
        require(msg.sender == unicefAddress, "Only unicef admin is allowed to call this function");
        _;
    }
    /*=============== Contract Variables definition Start=============== */
    address unicefAddress;
    mapping(address => School) registeredSchools;
    address[] registeredSchoolsKeys;
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
        bytes32[] memory cities, bytes32[] memory countries, bytes32[] memory latitudes, bytes32[] memory longitudes) public onlyUnicef
    returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(schools.length <= 100, "Only 100 schools can be registered at a time");
        require(schoolnames.length <= 100, "Only 100 schools can be registered at a time");
        require(postaladdress.length <= 100, "Only 100 schools can be registered at a time");
        require(cities.length <= 100, "Only 100 schools can be registered at a time");
        require(countries.length <= 100, "Only 100 schools can be registered at a time");
        require(latitudes.length <= 100, "Only 100 schools can be registered at a time");
        require(longitudes.length <= 100, "Only 100 schools can be registered at a time");
        require((schools.length == schoolnames.length) && (postaladdress.length == cities.length) && (countries.length == latitudes.length) && (latitudes.length == longitudes.length), "Arrays required to be the same length");
        for (uint256 i = 0; i < schools.length; i++) {
            require(!registeredSchools[schools[i]].active, "School already registered");
            registeredSchools[schools[i]].name = schoolnames[i];
            registeredSchools[schools[i]].postalAddress = postaladdress[i];
            registeredSchools[schools[i]].city = cities[i];
            registeredSchools[schools[i]].latitude = latitudes[i];
            registeredSchools[schools[i]].longitude = longitudes[i];
            registeredSchools[schools[i]].active = true;
            registeredSchools[schools[i]].country = countries[i];
            registeredSchoolsKeys.push(schools[i]);
        }
        return true;
    }

    function registerSchool(bytes32 name, bytes32 postaladdress, bytes32 city, bytes32 country, bytes32 latitude, bytes32 longitude) public returns(bool) {
        require(msg.sender != address(0), "Invalid sender address");
        require(!registeredSchools[msg.sender].active, "School already registered");
        registeredSchools[msg.sender].active = true;
        registeredSchools[msg.sender].name = name;
        registeredSchools[msg.sender].postalAddress = postaladdress;
        registeredSchools[msg.sender].city = city;
        registeredSchools[msg.sender].country = country;
        registeredSchools[msg.sender].latitude = latitude;
        registeredSchools[msg.sender].longitude = longitude;
        return true;
    }

}