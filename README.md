# UNICEF-Blockchain-Project

Reducing the digital divide with blockchain & crypto
We want to connect every kid in the world to the best services the internet has to offer and in order to do that we need to connect every school in the world to an appropriate supply of gigabytes. We need to figure out how to pay for that connectivity and account for those payments in a fair and transparent manner. We need a blockchain based system for dynamic load balancing, accounting and arbitrage across multiple different chains of value from connectivity to energy to IOTsensors in the schools to create new economies and make this effort self-sustaining.Systems exist for doing this type of monitoring in the fields of connectivity and electricity but they are mostly built for more wealthy and well-connected environments.

This particular bounty is to create the code and user-interfaces for applying distributed ledger technologies to disconnected, rural and resource-poor environments
https://www.unicef.org/innovation/stories/trip-amazonas
https://www.unicef.org/innovation/Magicbox/school-connectivity-kyrgyz-republic
UNICEF already has 600,000 schools mapped, 120,000 of which have connectivity data. You can learn more at http://school-mapping.azurewebsites.net/. This is just the start - we’re looking to the community, leveraging blockchain accounting and transparency & crypto for financing, on how to bring connectivity to every child.

The opportunity
Develop a way to transparently connect and manage school connectivity around theworld, creating a reality where young people have access to opportunity but also to create value for themselves in their communities. We envision this system having several parts to it, including:

1. Application to enable governments, the public, and connectivity/network providers to view connectivity for a specific country; ISP, donors and the general public can leverage data from this dashboard to view the connectivity for each country. When ledgers are public and the accounting is being done for the system in a straightforward manner, it will then be clear when and where there is an ability to meet service contracts. 2. Application to hold all parties accountable; Mobile network operators, and other service providers will have connectivity data in the public domain, while investors, funders and users will be able to track and understand connectivity better. Smart contracts can adjudicate contractual status in realtime (i.e. if a provider isn't providing…the contract can automatically move to a next vendor etc.)

Note: While this challenge is around a project that UNICEF Innovation is currently working on, this bounty is funded through the generosity of an external group.

Criteria & Requirements for Completion
List your assumptions: where is this, what is the scope, etc.
Readme with setup instructions and explanations for implementation details
All code (Variables, function names, comments, etc.) is in English
Open source code (link must be shared via GitHub)
Submit link(s) to working (D)App / tool / API
Web application must have a working front-end
Application to enable governments, the public, and connectivity/network providers to view connectivity for a specific country;
ISP, donors and the general public can leverage data from this dashboard to view the connectivity for each country

Users can see a list of countries
Users can select a specific country and view the schools related to the selected item
Users can view the schools that are connected and not connected for that country
Users can see the status of that country (e.g. if donors have provided funding, if ISPs are engaged, number of schools connected and not connected etc.)
Application to hold all parties accountable
ISP will be required to update donors and the general public about the connectivity in countries around the world

ISPs are responsible for updating users on an ongoing (can be daily, weekly, etc.) basis re. the connectivity for a specific country
If the ISP fails to grant a minimum download and upload speed for more than n (can be days, weeks, etc.) duration of time, the ISP will not receive funding from donors
If the ISP fails to grant a minimum download and upload speed for more than n (can be days, weeks, etc.) duration of time, the solution will change to a new ISP, which is than responsible for providing internet to the country
Reports should be generated at an ongoing basis re. the connectivity of schools for the country that the ISP is providing connectivity for and donors are providing funding for


# To run the project 
1. install metamask https://metamask.io/?gclid=EAIaIQobChMIlbj24oOI5AIVQ_hRCh31MgdeEAAYASAAEgLvu_D_BwE and setup an account
2. install Geth https://github.com/ethereum/go-ethereum/wiki/Installing-Geth
2. npm install 
3. npm install -g @vue/cli
4. npm install -g embark (in the instance where this fails please ensure you have git installed see: https://git-scm.com/downloads also ensure you have the windows build tools if you using a windows machine just run the following command in admin mode: npm install --global windows-build-tools
 see: https://www.npmjs.com/package/windows-build-tools for more instructions)
5. ```embark run --nodashboard```
6. ```npm run serve```

should be good to go in the instance where you dont have geth instead of running  embark run --nodashboard open a new CLI and navigate to the project folder from there run 

```embark simulator```
or you can install ganache and change the configuration specified in the contracts file

at the moment its running of my private chain if you wish to run it off this just run the following command

``embark run Chain --nodashboard``

if you wish to spin off you own ganache instance just modify the 

```
deployment: {
      protocol: "http",
      type: "rpc",
      host: "146.231.123.137",
      port: "11000",
    }
contained in the contracts file to

deployment: {
      protocol: "http",
      type: "rpc",
      host: "localhost/ip address",
      port: "your ganache port number",
    }
```
# Assumptions
1. All payments paid through Eth or if the donor has token they can also pay using that token
2. When an ISP updates its speed connection they use the same network there is no need for a UI where they can input these values this is calculated in real time
3. Everything is stored on the UNICEF contract
4. All users have to register as a Normal user before being classified as an ISP or school
