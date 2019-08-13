<template>
    <v-app id="inspire">
        <v-layout align-center justify-center row fill-height>
            <v-container grid-list-md style="height:1024px" fluid>
                <template>
                    <v-layout justify-center>
                        <v-dialog v-model="accountDetails" persistent max-width="600px">
                            <v-card>
                                <v-card-title>
                                    <span class="headline">My Details</span>
                                </v-card-title>
                                <v-card-text>
                                    <v-container grid-list-md>
                                        <v-layout wrap>
                                            Wallet Address: {{userAddress}}
                                        </v-layout>
                                    </v-container>
                                </v-card-text>
                                <v-card-actions>
                                    <v-spacer></v-spacer>
                                    <v-btn color="#7EC0EE" text @click="accountDetails = false">Close</v-btn>
                                </v-card-actions>
                            </v-card>
                        </v-dialog>
                    </v-layout>
                </template>

                <template>
                    <v-layout justify-center>
                        <v-dialog v-model="donate" persistent max-width="600px">
                            <v-card>
                                <v-card-title>
                                    <span class="headline">Make a Donation</span>
                                </v-card-title>
                                <v-card-text>
                                    <v-layout wrap>
                                        <v-form ref="form" v-model="valid" lazy-validation style="width:100%;">
                                            <v-text-field v-model="amount" :rules="amountRules" label="Amount" hint="12"
                                                required>
                                            </v-text-field>
                                            <v-text-field v-if="customToken" v-model="tokenAddress"
                                                :rules="tokenAddressRules" label="Token Address" hint="e.g. 0xa1s..."
                                                required>
                                            </v-text-field>
                                            <model-select :options="ISPS" label="ISP Name" v-model="ispName"
                                                placeholder="ISP Name e.g. Cell C- South Africa">
                                            </model-select>
                                            <v-spacer></v-spacer>
                                            <v-checkbox v-model="customToken" label="Donate using a custom token?"
                                                required></v-checkbox>
                                            <v-checkbox v-model="checkbox"
                                                :rules="[v => !!v || 'You must agree to continue!']"
                                                label="Do you agree?" required></v-checkbox>
                                            <v-btn :disabled="!valid" color="success" class="mr-4"
                                                @click="validate; donateToISP()">
                                                Donate
                                            </v-btn>
                                            <v-btn color="#7EC0EE" @click="donate=false">
                                                Close
                                            </v-btn>
                                        </v-form>
                                    </v-layout>
                                </v-card-text>
                            </v-card>
                        </v-dialog>
                    </v-layout>
                </template>

                <template>
                    <v-layout justify-center>
                        <v-dialog v-model="messageCenter" persistent max-width="600px">
                            <v-card>
                                <v-card-title>
                                    <span class="headline">Message Center</span>
                                </v-card-title>
                                <v-card-text>
                                    <v-container grid-list-md>
                                        <v-layout align-center row fill-height wrap>
                                            <v-layout align-center row fill-height wrap>
                                                <v-flex v-for="(n,index) in 9" :key="n" xs4>
                                                    <v-hover v-slot:default="{ hover }" close-delay="200">
                                                        <v-card :elevation="hover  ? 16 : 2" class="mx-auto"
                                                            height="200" outlined>
                                                            <v-layout align-center justify-center column fill-height>
                                                                From: {{n}}<br>
                                                                Message {{n}}<br>
                                                                <v-card-actions>
                                                                    <v-tooltip top>
                                                                        <template v-slot:activator="{ on }">
                                                                            <v-btn class="ma-2" tile large
                                                                                color="#7EC0EE" icon v-ripple v-on="on"
                                                                                @click="removeFromMessages(index)">
                                                                                <v-icon>done</v-icon>
                                                                            </v-btn>
                                                                        </template>
                                                                        <span>Mark as Read</span>
                                                                    </v-tooltip>
                                                                </v-card-actions>
                                                            </v-layout>
                                                        </v-card>
                                                    </v-hover>
                                                    <v-spacer></v-spacer>
                                                </v-flex>
                                            </v-layout>
                                        </v-layout>
                                    </v-container>
                                </v-card-text>
                                <v-card-actions>
                                    <v-spacer></v-spacer>
                                    <v-btn color="#7EC0EE" text @click="messageCenter = false">Close</v-btn>
                                </v-card-actions>
                            </v-card>
                        </v-dialog>
                    </v-layout>
                </template>

                <template>
                    <v-layout justify-center>
                        <v-dialog v-model="myDonations" persistent max-width="600px">
                            <v-card>
                                <v-card-title>
                                    <span class="headline">My Donations</span>
                                </v-card-title>
                                <v-card-text>
                                    <v-container grid-list-md>
                                        <v-layout align-center row fill-height wrap>
                                            <v-layout align-center row fill-height wrap>
                                                <v-flex v-for="(n,index) in 9" :key="n" xs4>
                                                    <v-hover v-slot:default="{ hover }" close-delay="200">
                                                        <v-card :elevation="hover  ? 16 : 2" class="mx-auto"
                                                            height="200" outlined>
                                                            <v-layout align-center justify-center column fill-height>
                                                                ISP Name: {{n}}<br>
                                                                Country: {{n}}<br>
                                                                Amount: {{n}} ETH<br>
                                                                Data Bundles: {{n}} MB<br>
                                                                Speed: {{n}}<br>
                                                                <v-card-actions>
                                                                    <v-tooltip top>
                                                                        <template v-slot:activator="{ on }">
                                                                            <v-btn class="ma-2" tile large
                                                                                color="#7EC0EE" icon v-ripple v-on="on"
                                                                                @click="reportISP(index)">
                                                                                <v-icon>error</v-icon>
                                                                            </v-btn>
                                                                        </template>
                                                                        <span>Report</span>
                                                                    </v-tooltip>
                                                                </v-card-actions>
                                                            </v-layout>
                                                        </v-card>
                                                    </v-hover>
                                                    <v-spacer></v-spacer>
                                                </v-flex>
                                            </v-layout>
                                        </v-layout>
                                    </v-container>
                                </v-card-text>
                                <v-card-actions>
                                    <v-spacer></v-spacer>
                                    <v-btn color="#7EC0EE" text @click="myDonations = false">Close</v-btn>
                                </v-card-actions>
                            </v-card>
                        </v-dialog>
                    </v-layout>
                </template>

                <template>
                    <v-layout justify-center>
                        <v-dialog v-model="ispRegistration" persistent max-width="600px">
                            <v-card>
                                <v-card-title>
                                    <span class="headline">ISP Registration</span>
                                </v-card-title>
                                <v-card-text>
                                    <v-layout wrap>
                                        <v-form ref="form" v-model="valid" lazy-validation style="width:100%;">
                                            <v-text-field v-model="ispName" :rules="ispNameRules" label="ISP Name"
                                                hint="e.g. Cell C" required>
                                            </v-text-field>
                                            <v-text-field v-model="ispEmail" :rules="ispEmailRules" label="Email"
                                                hint="e.g. admin@cellc.com" required>
                                            </v-text-field>
                                            <model-select :options="countries" label="Country" v-model="selectedCountry"
                                                placeholder="South Africa">
                                            </model-select>
                                            <v-spacer></v-spacer>
                                            <v-checkbox v-model="checkbox"
                                                :rules="[v => !!v || 'You must agree to continue!']"
                                                label="Agree to Terms and Conditions?" required></v-checkbox>
                                            <v-btn color="#7EC0EE" @click="ispTCS=true;">
                                                Terms and Conditions
                                            </v-btn>
                                            <v-btn :disabled="!valid" color="success" class="mr-4"
                                                @click="validate;registerISP()">
                                                Register
                                            </v-btn>
                                            <v-btn color="#7EC0EE" @click="ispRegistration=false;valid=true">
                                                Close
                                            </v-btn>
                                        </v-form>
                                    </v-layout>
                                </v-card-text>
                            </v-card>
                        </v-dialog>
                    </v-layout>
                </template>

                <template>
                    <v-layout justify-center>
                        <v-dialog v-model="newSchoolTCS" persistent max-width="600px">
                            <v-card>
                                <v-card-title>
                                    <span class="headline">Terms and Conditions</span>
                                </v-card-title>
                                <v-card-text>
                                    <v-container grid-list-md>
                                        <v-layout wrap>
                                            By Registering {{schoolName}} you agree that the information provided is
                                            legitamite click register to continue
                                        </v-layout>
                                    </v-container>
                                </v-card-text>
                                <v-card-actions>
                                    <v-spacer></v-spacer>
                                    <v-btn color="#7EC0EE " text @click="registerasSchool()">Register</v-btn>
                                    <v-btn color="#7EC0EE " text @click="newSchoolTCS = false">Close</v-btn>
                                </v-card-actions>
                            </v-card>
                        </v-dialog>
                    </v-layout>
                </template>

                <template>
                    <v-layout justify-center>
                        <v-dialog v-model="ispTCS" persistent max-width="600px">
                            <v-card>
                                <v-card-title>
                                    <span class="headline">Terms and Conditions</span>
                                </v-card-title>
                                <v-card-text>
                                    <v-container grid-list-md>
                                        <v-layout wrap>
                                            Terms and Conditions
                                        </v-layout>
                                    </v-container>
                                </v-card-text>
                                <v-card-actions>
                                    <v-spacer></v-spacer>
                                    <v-btn color="#7EC0EE " text @click="ispTCS = false">Close</v-btn>
                                </v-card-actions>
                            </v-card>
                        </v-dialog>
                    </v-layout>
                </template>

                <template>
                    <v-layout justify-center>
                        <v-dialog v-model="updateCountrySpeed" persistent max-width="600px">
                            <v-card>
                                <v-card-title>
                                    <span class="headline">Update Connection</span>
                                </v-card-title>
                                <v-card-text>
                                    <v-container grid-list-md>
                                        <v-layout wrap>
                                            <v-form ref="form" v-model="valid" lazy-validation style="width:100%;">
                                                <v-text-field v-model="newSpeed" :rules="newSpeedRules"
                                                    label="New Speed (Mbps)" hint="e.g. 10  " required>
                                                </v-text-field>
                                                <v-text-field v-model="dataBundles" :rules="dataBundlesRules"
                                                    label="Data Bundles (MB)" hint="e.g. 100" required>
                                                </v-text-field>
                                                <v-btn :disabled="!valid" color="success" class="mr-4"
                                                    @click="validate; updateConnectionSpeed()">
                                                    Update
                                                </v-btn>
                                                <v-btn color="#7EC0EE" @click="updateCountrySpeed=false;valid=true">
                                                    Close
                                                </v-btn>
                                            </v-form>
                                        </v-layout>
                                    </v-container>
                                </v-card-text>
                            </v-card>
                        </v-dialog>
                    </v-layout>
                </template>


                <template>
                    <v-layout justify-center>
                        <v-dialog v-model="ispUpdate" persistent max-width="600px">
                            <v-card>
                                <v-card-title>
                                    <span class="headline">ISP Connection Update</span>
                                </v-card-title>
                                <v-card-text>
                                    <v-container grid-list-md>
                                        <v-layout align-center row fill-height wrap>
                                            <v-layout align-center row fill-height wrap>
                                                <v-flex v-for="(n,index) in 9" :key="n" xs4>
                                                    <v-hover v-slot:default="{ hover }" close-delay="200">
                                                        <v-card :elevation="hover  ? 16 : 2" class="mx-auto"
                                                            height="200" outlined>
                                                            <v-layout align-center justify-center column fill-height>
                                                                Country: {{n}}<br>
                                                                Current Speed: {{n}}<br>
                                                                Schools Connected: {{n}}<br>
                                                                Data Bundles: {{n}} MB
                                                                <v-card-actions>
                                                                    <v-tooltip top>
                                                                        <template v-slot:activator="{ on }">
                                                                            <v-btn rounded class="ma-2" tile large
                                                                                color="#7EC0EE" icon v-ripple v-on="on"
                                                                                @click="updateCountrySpeed=true; selectedCountryToUpdate=index; ">
                                                                                <v-icon>build</v-icon>
                                                                            </v-btn>
                                                                        </template>
                                                                        <span>Update</span>
                                                                    </v-tooltip>
                                                                </v-card-actions>
                                                            </v-layout>
                                                        </v-card>
                                                    </v-hover>
                                                    <v-spacer></v-spacer>
                                                </v-flex>
                                            </v-layout>
                                        </v-layout>
                                    </v-container>
                                </v-card-text>
                                <v-card-actions>
                                    <v-spacer></v-spacer>
                                    <v-btn color="#7EC0EE" text @click="ispUpdate = false">Close</v-btn>
                                </v-card-actions>
                            </v-card>
                        </v-dialog>
                    </v-layout>
                </template>

                <template>
                    <v-layout justify-center>
                        <v-dialog v-model="isSchoolRegistration" persistent max-width="600px">
                            <v-card>
                                <v-card-title>
                                    <span class="headline">School Registration</span>
                                </v-card-title>
                                <v-card-text>
                                    <v-container grid-list-md>
                                        <v-layout wrap>
                                            <v-form ref="form" v-model="valid" lazy-validation style="width:100%;">
                                                <v-text-field v-model="schoolName" :rules="schoolNameRules"
                                                    label="School Name" hint="e.g. AJ Mwelase Secondary School"
                                                    required>
                                                </v-text-field>
                                                <v-text-field v-model="schoolAddress" :rules="schoolAddressRules"
                                                    label="School Postal Address"
                                                    hint="e.g. PO BOX X123  12 Ntuli Street Lamontville Durban South Africa"
                                                    required>
                                                </v-text-field>
                                                <v-text-field v-model="schoolEmail" :rules="schoolEmailRules"
                                                    label="School Email Address" hint="AJMwelase@gov.za" required>
                                                </v-text-field>
                                                <v-text-field v-model="latitude" :rules="latitudeRules"
                                                    label="School Latitude Position" hint="e.g. -33.5532" required>
                                                </v-text-field>
                                                <v-text-field v-model="Longitude" :rules="LongitudeRules"
                                                    label="School Longitude Position" hint="e.g. -33.5532" required>
                                                </v-text-field>
                                                <v-checkbox v-model="checkbox"
                                                    :rules="[v => !!v || 'You must agree to continue!']"
                                                    label="Do you agree?" required></v-checkbox>
                                                <v-btn :disabled="!valid" color="success" class="mr-4"
                                                    @click="validate; newSchoolTCS=true">
                                                    Update
                                                </v-btn>
                                                <v-btn color="#7EC0EE" @click="isSchoolRegistration=false;valid=true">
                                                    Close
                                                </v-btn>
                                            </v-form>
                                        </v-layout>
                                    </v-container>
                                </v-card-text>
                            </v-card>
                        </v-dialog>
                    </v-layout>
                </template>

                <v-toolbar color="#7EC0EE">
                    <v-toolbar-title>Profile</v-toolbar-title>
                    <v-spacer></v-spacer>
                </v-toolbar>
                <v-layout>
                    <v-flex>
                        <v-card>
                            <v-layout align-center row fill-height wrap>
                                <v-flex xs4 v-ripple @click="showMenu(1)">
                                    <v-hover v-slot:default="{ hover }" close-delay="200">
                                        <v-card :elevation="hover ? 16 : 2" class="mx-auto" height="200">
                                            <v-layout align-center justify-center column fill-height>
                                                Account Details
                                            </v-layout>
                                        </v-card>
                                    </v-hover>
                                </v-flex>


                                <v-flex xs4 v-ripple @click="showMenu(2)">
                                    <v-hover v-slot:default="{ hover }" close-delay="200">
                                        <v-card :elevation="hover ? 16 : 2" class="mx-auto" height="200">
                                            <v-layout align-center justify-center column fill-height>
                                                Donate
                                            </v-layout>
                                        </v-card>
                                    </v-hover>
                                </v-flex>


                                <v-flex xs4 v-ripple @click="showMenu(3)">
                                    <v-hover v-slot:default="{ hover }" close-delay="200">
                                        <v-card :elevation="hover ? 16 : 2" class="mx-auto" height="200">
                                            <v-layout align-center justify-center column fill-height>
                                                Your Donations
                                            </v-layout>
                                        </v-card>
                                    </v-hover>
                                </v-flex>


                                <v-flex xs4 v-ripple @click="showMenu(5)">
                                    <v-hover v-slot:default="{ hover }" close-delay="200">
                                        <v-card :elevation="hover ? 16 : 2" class="mx-auto" height="200">
                                            <v-layout align-center justify-center column fill-height>
                                                Register as ISP
                                            </v-layout>
                                        </v-card>
                                    </v-hover>


                                </v-flex>
                                <v-flex xs4 v-ripple @click="showMenu(4)">
                                    <v-hover v-slot:default="{ hover }" close-delay="200">
                                        <v-card :elevation="hover ? 16 : 2" class="mx-auto" height="200">
                                            <v-layout align-center justify-center column fill-height>Message Center
                                            </v-layout>
                                        </v-card>
                                    </v-hover>
                                </v-flex>

                                <v-flex xs4 v-ripple @click="showMenu(6)">
                                    <v-hover v-slot:default="{ hover }" close-delay="200">
                                        <v-card :elevation="hover ? 16 : 2" class="mx-auto" height="200">
                                            <v-layout align-center justify-center column fill-height>Update Connection
                                                Speed
                                            </v-layout>
                                        </v-card>
                                    </v-hover>
                                </v-flex>

                                <v-flex xs4 v-ripple @click="showMenu(7)">
                                    <v-hover v-slot:default="{ hover }" close-delay="200">
                                        <v-card :elevation="hover ? 16 : 2" class="mx-auto" height="200">
                                            <v-layout align-center justify-center column fill-height>Register as School
                                            </v-layout>
                                        </v-card>
                                    </v-hover>
                                </v-flex>
                            </v-layout>
                        </v-card>
                    </v-flex>
                </v-layout>
                <vue-snotify></vue-snotify>
                <loading :active.sync="isLoading" :can-cancel="false" :is-full-page="fullPage">
                </loading>
            </v-container>
        </v-layout>
    </v-app>
</template>
<script>
    import Portis from "@portis/web3";
    import Web3 from 'web3';
    import Loading from 'vue-loading-overlay';
    import {
        ModelSelect
    } from 'vue-search-select'
    import EmbarkJS from '../../embarkArtifacts/embarkjs';

    export default {
        components: {
            Loading,
            ModelSelect
        },
        data() {
            return {
                userAddress: '',
                valid: true,
                dataBundles: -1,
                selectedCountry: '',
                countries: [],
                schoolEmail: '',
                schoolEmailRules: [
                    v => !!v || 'E-mail is required',
                    v => /.+@.+\..+/.test(v) || 'School E-mail must be valid',
                ],
                latitude: '',
                latitudeRules: [
                    v => !!v || 'Latitude position for school is required',
                    v => (v && !isNaN(v)) || 'Invalid Latitude number valid number is in this form e.g. -33.012'
                ],
                Longitude: '',
                LongitudeRules: [
                    v => !!v || 'Longitude position for school is required',
                    v => (v && !isNaN(v)) || 'Invalid Longitude number valid number is in this form e.g. -33.012'
                ],
                schoolName: '',
                schoolNameRules: [
                    v => !!v || 'School name is required',
                    v => (v && v.length > 1) || 'School name si required to have more than 1 character'
                ],
                schoolAddress: '',
                schoolAddressRules: [
                    v => !!v || 'School Postal Address is required',
                    v => (v && v.length > 5) || 'School Postal required to have more than 1 character'
                ],
                dataBundlesRules: [
                    v => !!v || 'New Data bundles value is required',
                    v => (v && !isNaN(v)) || 'Invalid New Speed connection must be a valid Number E.g. 2000'
                ],
                newSpeed: -1,
                newSpeedRules: [
                    v => !!v || 'New Connection Speed is required',
                    v => (v && !isNaN(v)) || 'Invalid New Speed connection must be a valid Number E.g. 12'
                ],
                ispName: '',
                ispNameRules: [
                    v => !!v || 'ISP Name is required',
                    v => (v && v.length > 1) || 'ISP Name must be at least 2 characters'
                ],
                amount: '',
                amountRules: [
                    v => !!v || 'Donation Amount is required',
                    v => (v && !isNaN(v)) || 'Donation amount must be a valid amount e.g. 10',
                ],
                ispEmail: '',
                ispEmailRules: [
                    v => !!v || 'E-mail is required',
                    v => /.+@.+\..+/.test(v) || 'ISP E-mail must be valid',
                ],
                tokenAddress: '',
                tokenAddressRules: [
                    v => !!v || "Token Address is required",
                    v => (v && v.length === 42) || 'Token address must have 42 characters'
                ],
                selectedCountry: '',
                countries: [],
                select: null,
                options: [{
                        value: '1',
                        text: 'aa' + ' - ' + '1'
                    },
                    {
                        value: '2',
                        text: 'ab' + ' - ' + '2'
                    },
                    {
                        value: '3',
                        text: 'bc' + ' - ' + '3'
                    },
                    {
                        value: '4',
                        text: 'cd' + ' - ' + '4'
                    },
                    {
                        value: '5',
                        text: 'de' + ' - ' + '5'
                    }
                ],
                item: {
                    value: '',
                    text: ''
                },
                checkbox: false,
                customToken: false,
                messages: [],
                ispDonatingTo: [],
                fullPage: true,
                updateCountrySpeed: false,
                selectedCountryToUpdate: -1,
                ispTCS: false,
                isLoading: false,
                fullPage: true,
                accountDetails: false,
                donate: false,
                messageCenter: false,
                myDonations: false,
                ispRegistration: false,
                ispUpdate: false,
                isISP: true,
                isSchoolRegistration: false,
                newSchoolTCS: false,
                UNICEFContract: null,
                ISPS: [],
                Portis: null,
                localNode: {
                    nodeUrl: 'http://localhost:11000',
                    chainId: 1234,
                }


            }
        },
        mounted() {
            this.init()
        },
        methods: {
            init() {
                this.UNICEFContract = require('../../embarkArtifacts/contracts/UNICEF')
                this.Portis = new Portis('0705023c-3e90-405e-a0c3-6ab9ad4be7ed', this.localNode, {
                    scope: ["email"]
                });
                this.Portis.config.registerPageByDefault = false
                console.log(this.Portis.config.registerPageByDefault)
                var web3 = new Web3(this.Portis.provider);
                this.UNICEFContract.Providers = web3
                console.log(this.UNICEFContract)
                this.UNICEFContract.methods.getISPKeys().call({
                    gas: 8000000
                }).then((keys, err) => {
                    keys.forEach(key => {
                        this.UNICEFContract.methods.getISPDetails(key).call({
                            gas: 8000000
                        }).then((details, err) => {
                            var address;
                            var name;
                            var country;
                            address, name, country = details
                            name = EmbarkJS.Utils.fromAscii(name);
                            country = EmbarkJS.Utils.fromAscii(country);
                            this.ISPS.push({
                                value: key,
                                text: `${name} - ${country}`,
                                address: address
                            })
                        }).catch((err) => {
                            console.log("Something went wrong!!! ", err)
                        })
                    });
                }).catch((err) => {
                    console.log("Something went wrong!!! ", err)
                })
            },
            showMenu(whichMenu) {
                console.log(this.dataBundles)
                switch (whichMenu) {
                    case 1:
                        this.accountDetails = true
                        break
                    case 2:
                        this.donate = true
                        break
                    case 3:
                        this.myDonations = true
                        break
                    case 4:
                        this.messageCenter = true
                        break
                    case 5:
                        this.ispRegistration = true
                        break
                    case 6:
                        this.ispUpdate = true
                        break
                    case 7:
                        this.isSchoolRegistration = true
                        break
                }
            },
            selectFromParentComponent1() {
                // select option from parent component
                this.item = this.options[0]
            },
            validate() {
                if (this.$refs.form.validate()) {
                    this.snackbar = true
                }
            },
            removeFromMessages(index) {
                console.log(`message to remove ${index}`)
                this.$snotify.success('Message marked as read', 'Message read', {
                    timeout: 2000,
                    showProgressBar: false,
                    closeOnClick: false,
                    pauseOnHover: true
                });
            },
            reportISP(index) {
                console.log(`ISP to report ${index}`)
            },
            updateConnectionSpeed(index) {

            },
            registerasSchool() {
                this.isLoading = true
            },
            donateToISP() {
                console.log(this.ispName)
                let This = this
                this.isLoading = true
                if (valid) {
                    if (customToken) {
                        this.UNICEFContract.methods.donateERC20(EmbarkJS.Utils.toAscii(this.amount), EmbarkJS.Utils
                            .toAscii(this.ispName.address), EmbarkJS.Utils.toAscii(this.ispName.value), this
                            .tokenAddress).send({
                            gas: 8000000
                        }).then((receipt, err) => {
                            if (err) {
                                console.log(err)
                            } else {
                                console.log(receipt)
                                This.success('Successfully donated ', This.amount, 'to ', this.ispName)
                            }
                            this.isLoading = false
                        }).catch((err) => {
                            This.error('Something went wrong whilst trying to donate please try again')
                            This.isLoading = false
                        })
                    } else {
                        this.UNICEFContract.methods.donate(EmbarkJS.Utils.toAscii(this.amount), EmbarkJS.Utils.toAscii(
                            this.ispName.address), EmbarkJS.Utils.toAscii(this.ispName.value)).send({
                            gas: 8000000
                        }).then((receipt, err) => {
                            if (err) {
                                console.log(err)
                            } else {
                                console.log(receipt)
                                This.success('Successfully donated ', This.amount, 'to ', this.ispName)
                            }
                            this.isLoading = false
                        }).catch((err) => {
                            This.error('Something went wrong whilst trying to donate please try again')
                            This.isLoading = false
                        })
                    }
                }
            },
            registerISP() {
                let This = this
                this.isLoading = true
                if (valid) {
                    this.UNICEFContract.methods.registerISP(EmbarkJS.Utils.toAscii(this.ispName), EmbarkJS.Utils
                        .toAscii(this.ispEmail), EmbarkJS.Utils.toAscii(this.selectedCountry)).send({
                        gas: 8000000
                    }).then((receipt, err) => {
                        if (err) {
                            console.log(err)
                        } else {
                            This.success('Succesfully registered as an ISP')
                        }
                        This.isLoading = false

                    }).catch((err) => {
                        This.error(
                            'Something went wrong whilst trying to register you as an ISP wont you try again'
                        )
                        This.isLoading = false
                    })
                }
            },
            success(message) {
                Swal.fire(
                    'Success',
                    message,
                    'success'
                )
            },
            error(message) {
                Swal.fire({
                    type: 'error',
                    title: 'Oops...',
                    text: message,
                    allowOutsideClick: true
                })
            }
        }

    }
</script>


<style>
    @import "~vue-snotify/styles/material.css"
</style>