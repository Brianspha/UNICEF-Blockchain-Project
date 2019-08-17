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
                                            <v-checkbox v-model="validDonate"
                                                :rules="[v => !!v || 'You must agree to continue!']"
                                                label="Do you agree?" required></v-checkbox>
                                            <v-btn :disabled="!validDonate" color="success" class="mr-4"
                                                @click="validate(); donateToISP()">
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
                        <v-dialog v-model="supportingSchools" persistent max-width="800px" lazy>
                            <v-card>
                                <v-card-title>
                                    <span class="headline">Schools Connected to ISP</span>
                                </v-card-title>
                                <v-card-text>
                                    <v-container grid-list-md>
                                        <v-layout align-center row fill-height wrap>
                                            <v-layout align-center row fill-height wrap
                                                style="height:1024px;width:800px;" v-if="schools.length>0">
                                                <v-map :zoom="zoom" :center="center" min-height="1024px">
                                                    <v-icondefault></v-icondefault>
                                                    <v-tilelayer :url="url">
                                                    </v-tilelayer>
                                                    <v-marker-cluster :options="clusterOptions" @clusterclick=""
                                                        @click="">
                                                        <v-marker v-for="school in schools"
                                                            :key="school.name+school.position"
                                                            :lat-lng="school.position" :icon="icon"
                                                            :color="school.color">
                                                            <v-popup :content="school.description">
                                                            </v-popup>
                                                        </v-marker>
                                                    </v-marker-cluster>
                                                </v-map>
                                                <v-spacer></v-spacer>
                                            </v-layout>
                                        </v-layout>
                                    </v-container>
                                </v-card-text>
                                <v-card-actions>
                                    <v-spacer></v-spacer>
                                    <v-btn color="#7EC0EE" text @click="supportingSchools = false">Close</v-btn>
                                </v-card-actions>
                            </v-card>
                        </v-dialog>
                    </v-layout>
                </template>

                <template>
                    <v-layout justify-center>
                        <v-dialog v-model="myDonationsDialog" persistent max-width="600px">
                            <v-card>
                                <v-card-title>
                                    <span class="headline">My Donations</span>
                                </v-card-title>
                                <v-card-text>
                                    <v-container grid-list-md>
                                        <v-layout align-center row fill-height wrap>
                                            <v-layout align-center row fill-height wrap>
                                                <v-flex v-if="myDonations.length===0">
                                                    <v-card>
                                                        <v-card-text>
                                                            No donations yet..
                                                        </v-card-text>
                                                    </v-card>
                                                </v-flex>
                                                <v-flex v-if="myDonations.length>0 && myDonationsDialog" v-for="(donation,index) in myDonations " :key="index"
                                                    xs4>
                                                    <v-hover v-slot:default="{ hover }" close-delay="200">
                                                        <v-card :elevation="hover  ? 16 : 2" class="mx-auto"
                                                            height="200" outlined>
                                                            <v-layout align-center justify-center column fill-height>
                                                                ISP Name: {{donation.ispName}}<br>
                                                                Country: {{donation.country}}<br>
                                                                Amount: {{donation.amount}} ETH<br>
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
                                    <v-btn color="#7EC0EE" text @click="myDonationsDialog = false">Close</v-btn>
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
                                            <v-checkbox v-model="validIspTCS"
                                                :rules="[v => !!v || 'You must agree to continue!']"
                                                label="Agree to Terms and Conditions?" required></v-checkbox>
                                            <v-btn color="#7EC0EE" @click="validIspTCS=true;">
                                                Terms and Conditions
                                            </v-btn>
                                            <v-btn :disabled="!validIspTCS" color="success" class="mr-4"
                                                @click="validate();registerISP()">
                                                Register
                                            </v-btn>
                                            <v-btn color="#7EC0EE"
                                                @click="ispRegistration=false;valid=true;checkbox=false">
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
                                                <v-flex v-for="(connection,index) in supportingCountries" :key="index"
                                                    xs4>
                                                    <v-hover v-slot:default="{ hover }" close-delay="200">
                                                        <v-card :elevation="hover  ? 16 : 2" class="mx-auto"
                                                            height="200" outlined>
                                                            <v-layout align-center justify-center column fill-height>
                                                                Country: {{connection.country}}<br>
                                                                Current Speed: {{connection.speed}} (Mbps)<br>
                                                                Schools Connected: {{connection.totalSchools}}<br>
                                                                <v-card-actions>
                                                                    <v-tooltip top>
                                                                        <template v-slot:activator="{ on }">
                                                                            <v-btn rounded class="ma-2" tile large
                                                                                color="#7EC0EE" icon v-ripple v-on="on"
                                                                                @click="updateConnectionSpeed(connection) ">
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
                                    <span class="headline">Connect Schools Registration</span>
                                </v-card-title>
                                <v-card-text>
                                    <v-container grid-list-md>
                                        <v-layout wrap>
                                            <v-flex class="containerflex" style="height:400px;">
                                                <MultiSelect :selected-options="selectedSchools"
                                                    :options="schoolsOptions" label="School" @select="onSelect"
                                                    placeholder="Search School: e.g. AJ Mwelase Primary School">
                                                </MultiSelect>
                                            </v-flex>
                                        </v-layout>
                                        <v-btn color="#7EC0EE" @click="connectSchools()">
                                            Register
                                        </v-btn>
                                        <v-btn color="#7EC0EE" @click="isSchoolRegistration=false;selectedSchools=[]">
                                            Close
                                        </v-btn>
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
                                            <v-layout align-center justify-center column fill-height>View Schools
                                                Connecting
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
                                            <v-layout align-center justify-center column fill-height>Connect Schools
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
    import NetworkSpeed from '@quantfive/network-speed'
    import Portis from "@portis/web3";
    import {
        getNames
    } from 'country-list'
    import Web3 from 'web3';
    import Loading from 'vue-loading-overlay';
    import {
        ModelSelect
    } from 'vue-search-select'
    import EmbarkJS from '../../embarkArtifacts/embarkjs';
    import Swal from 'sweetalert2'
    import {
        MultiSelect
    } from 'vue-search-select'
    import reverseGeoCoder from 'fast-reverse-geocoder'
    import {
        LMap,
        LTileLayer,
        LMarker,
        LIconDefault,
        LPopup
    } from 'vue2-leaflet';
    import * as Vue2Leaflet from 'vue2-leaflet'
    import Vue2LeafletMarkerCluster from 'vue2-leaflet-markercluster'
    import {
        latLng,
        Icon,
        icon
    } from 'leaflet'
    import InfiniteLoading from 'vue-infinite-loading';
    import iconUrl from 'leaflet/dist/images/marker-icon.png'
    import shadowUrl from 'leaflet/dist/images/marker-shadow.png'
    export default {
        components: {
            Loading,
            ModelSelect,
            MultiSelect,
            'v-map': Vue2Leaflet.LMap,
            'v-tilelayer': Vue2Leaflet.LTileLayer,
            'v-icondefault': Vue2Leaflet.LIconDefault,
            'v-marker': Vue2Leaflet.LMarker,
            'v-popup': Vue2Leaflet.LPopup,
            'v-marker-cluster': Vue2LeafletMarkerCluster,
            'v-icondefault': Vue2Leaflet.LIconDefault,
            'v-marker': Vue2Leaflet.LMarker,
            'v-popup': Vue2Leaflet.LPopup
        },
        data() {
            return {
                userAddress: '',
                valid: false,
                validDonate: false,
                validIspTCS: false,
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
                supportingSchools: false,
                myDonations: [],
                myDonationsDialog:false,
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
                },
                Web3: null,
                selectedSchools: [],
                Schools: [],
                schoolsOptions: [],
                testNetworkSpeed: new NetworkSpeed(),
                clusterOptions: {},
                url: 'http://{s}.tile.osm.org/{z}/{x}/{y}.png',
                attribution: '&copy; <a href=" http://osm.org/copyright">OpenStreetMap </a> contributors',
                map: null,
                zoom: 7,
                maxBoundsViscosity: 1.0,
                layers: [L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
                    maxZoom: 18,
                    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors, Points &copy 2012 LINZ'
                })],
                icon: icon(Object.assign({}, Icon.Default.prototype.options, {
                    iconUrl,
                    shadowUrl
                })),
                schools: [],
                center: [],
                supportingCountries: []


            }
        },
        mounted() {
            this.init()
            this.loadSchools()
            setTimeout(() => {
                console.log('done')
                this.$nextTick(() => {
                    this.clusterOptions = {
                        disableClusteringAtZoom: 6
                    }
                });
            }, 5000);
        },
        methods: {
            loadSchools() {
                var schoolsData = require('../json/schools.json')
                let newSchoolData = []
                schoolsData.map((school) => {
                    if (!school || !school.GIS_Longitude || !school.GIS_Latitude) {
                        return
                    }
                    var country = reverseGeoCoder.search(school.GIS_Longitude.toString().replace(/ /g, ''),
                        school.GIS_Latitude.toString().replace(/ /g, ''))
                    //console.log(country)
                    if (!country || !country.name) {
                        return
                    }
                    var newSchool = {
                        name: school.Official_Institution_Name,
                        postalAddress: school.PostalAddress,
                        cityTown: school.TownCity,
                        latitude: school.GIS_Latitude,
                        longitude: school.GIS_Longitude,
                        country: country.name,
                        isp: "Querying Contract",
                        registered: false
                    }
                    this.schoolsOptions.push({
                        value: school.Official_Institution_Name,
                        latitude: school.GIS_Latitude,
                        longitude: school.GIS_Longitude,
                        text: `${school.Official_Institution_Name} - ${country.name}`,
                        postalAddress: school.PostalAddress,
                        country: country.name,
                    })
                    this.itemCount++
                    //console.log(newSchool)
                    newSchoolData.push(newSchool)
                })
                this.Schools = newSchoolData
                console.log("itemCount: ", this.itemCount)
            },
            onSelect(items, lastSelectItem) {
                this.selectedSchools = items
                this.selectedSchool = lastSelectItem
            },
            connectSchools() {
                console.log(this.selectedSchools)
                this.isLoading = true
                let This = this
                const baseUrl = 'http://eu.httpbin.org/stream-bytes/50000000';
                const fileSize =
                    500000; //@dev we just assume that the upload speed is the same as the download speed terrible assumption :XD
                this.testNetworkSpeed.checkDownloadSpeed(baseUrl, fileSize).then((downloadSpeed) => {
                    console.log('speed: ', downloadSpeed);
                    var schoolNames = []
                    var postalAddresses = []
                    var countries = []
                    var latitudes = []
                    var longitudes = []
                    This.selectedSchools.forEach((school) => {
                        school.latitude = school.latitude.toString().replace(/-/g,
                            'm') //@dev everytime we encounter a - replace with m
                        school.longitude = school.longitude.toString().replace(/-/g, 'm')
                        schoolNames.push(web3.utils.hexToBytes(web3.utils.utf8ToHex(school.value)))
                        postalAddresses.push(web3.utils.hexToBytes(web3.utils.utf8ToHex(school
                            .postalAddress)))
                        countries.push(web3.utils.hexToBytes(web3.utils.utf8ToHex(school.country)))
                        longitudes.push(web3.utils.hexToBytes(web3.utils.utf8ToHex(school.longitude)))
                        latitudes.push(web3.utils.hexToBytes(web3.utils.utf8ToHex(school.latitude)))
                        var index = This.selectedSchools.indexOf(school)
                        console.log("index: ", index)
                        console.log(This.selectedSchools)
                    })
                    downloadSpeed = Math.round(downloadSpeed.mbps, 4)
                    console.log('speed: ', downloadSpeed)
                    This.UNICEFContract.methods.registerSchools(downloadSpeed, downloadSpeed, schoolNames,
                        postalAddresses, countries, latitudes, longitudes).send({
                        gas: 8000000
                    }).then((receipt, error) => {
                        if (receipt) {
                            This.success('Succesfully registered Schools')
                        } else {
                            console.log(error)
                        }
                        This.isLoading = false
                    }).catch((err) => {
                        This.error(
                            'Something went wrong whilst registering the selected schools please try again!!'
                        )
                    })
                });


            },
            init() {
                EmbarkJS.onReady((err) => {
                    this.countries = getNames().map((country) => {
                        return {
                            value: country,
                            text: country
                        }
                    })
                    this.Web3 = web3 //@dev browser web3 object
                    this.UNICEFContract = require('../../embarkArtifacts/contracts/UNICEF')
                    this.initISPS()
                    this.getMyDonations()
                })
            },
            initISPS() {
                let This = this
                this.ISPS = []
                this.UNICEFContract.methods.getISPKeys().call({
                    gas: 8000000
                }).then((keys, err) => {
                    console.log(keys, err)
                    keys.forEach(key => {
                        this.UNICEFContract.methods.getISPDetails(key).call({
                            gas: 8000000
                        }).then((details, err) => {
                            var address = details[0];
                            var name = details[1];
                            var country = details[2];
                            console.log(`name: ${name} address: ${address}`)
                            name = this.Web3.utils.hexToAscii(name);
                            country = this.Web3.utils.hexToAscii(country);
                            this.ISPS.push({
                                value: name,
                                text: `${name} - ${country}`,
                                address: address,
                                key: key
                            })
                            console.log(`key: ${key}`)
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
                        this.initISPS()
                        break
                    case 3:
                        this.getMyDonations()
                        this.myDonationsDialog = true
                        break
                    case 4:
                        this.getSchoolsConnectedToISP()
                        this.supportingSchools = true
                        break
                    case 5:
                        this.ispRegistration = true
                        break
                    case 6:
                        this.getSchoolsConnectedToISP()
                        this.ispUpdate = true
                        break
                    case 7:
                        this.isSchoolRegistration = true
                        break
                }
            },
            removetrailingZeros(string) {
                console.log(string.split('').filter((c) => c.match(/^[0-9a-zA-Z-.]+$/)))
                return string.split('').filter((c) => c.match(/^[0-9a-zA-Z-.]+$/)).join("")
            },
            getSchoolsConnectedToISP() {
                this.schools = []
                this.supportingCountries = []
                let This = this
                this.UNICEFContract.methods.getSchoolsConnectedTOISPKeys().call({
                    gas: 8000000
                }).then((keys, error) => {
                    if (!error) {
                        keys.forEach((key) => {
                            var details = web3.eth.abi.decodeParameters(["address", "bytes",
                                "bytes",
                                "bytes", "bytes", "bytes", "uint256", "uint256"
                            ], key)
                            console.log(details)
                            var ispID, schoolName, address, country, latitude, longitude,
                                upload, download;
                            ispID = details[0]
                            schoolName = web3.utils.toAscii((details[1]))
                            address = web3.utils.toAscii((details[2]))
                            country = web3.utils.toAscii((details[3]))
                            latitude = web3.utils.toAscii((details[4]))
                            longitude = web3.utils.toAscii((details[5]))
                            var trail = This.removetrailingZeros(latitude)
                            console.log("trailing: ", trail, " orig: ",
                                latitude)
                            upload = (details[6])
                            download = (details[7])
                            longitude = This.removetrailingZeros(longitude)
                            latitude = This.removetrailingZeros(latitude)
                            latitude = latitude.replace(/m/g, '-')
                            longitude = longitude.replace(/m/g, '-')
                            This.schools.push({
                                name: schoolName,
                                position: latLng(latitude, longitude),
                                color: "#7EC0EE",
                                description: ("Name: " + schoolName +
                                    "<br>Address: " + address + "<br>Country:" + country +
                                    "<br>Upload-Speed: " + upload +
                                    " <b>(mbps)</b><br>Download-Speed: " + download +
                                    " <b>(mbps)</b>")
                            })
                            if (This.supportingCountries.length === 0||!This.supportingCountries.some((conty)=>conty.country ===country)) {
                                This.supportingCountries.push({
                                    country: country,
                                    uploadSpeed: upload,
                                    downloadSpeed: download,
                                    totalSchools: 1
                                })
                            } else {
                                This.supportingCountries.map((cnty) => {
                                    if (cnty.country === country) {
                                        cnty.totalSchools += 1
                                    }
                                    return cnty
                                })
                            }

                            This.center = [latitude, longitude]
                        })
                        This.supportingCountries = This.supportingCountries.map((country) => {
                            console.log(country.speed)
                            country.speed = Math.round(country.uploadSpeed / country.totalSchools, 2)
                            return country
                        })
                        console.log(This.schools, " center: ", This.center, " supportingCountries: ", This
                            .supportingCountries)
                    }
                }).catch((err) => {
                    console.log("err: ", err)
                    This.error('Something went wrong whilst loading schools you provide internet services to')
                })
            },
            getMyDonations() {
                let This = this
                this.UNICEFContract.methods.getUserDontaionKeys().call({
                    gas: 8000000
                }).then((keys, err) => {
                    if (keys.length > 0) {
                        keys.forEach((key) => {
                            This.UNICEFContract.methods.getDonation(key).call({
                                gas: 8000000
                            }).then((details, err) => {
                                if (details) {
                                    var name, country, amount;
                                    name = web3.utils.hexToAscii(details[0])
                                    country = web3.utils.hexToAscii(details[1])
                                    amount = details[2]
                                    This.myDonations.push({
                                        ispName: name,
                                        country: country,
                                        amount: amount
                                    })
                                }
                            }).catch((err) => {

                            })
                        })
                    } else {
                        console.log("no user donations")
                    }
                }).catch((err) => {
                    console.log(err)
                    console.log('Something went wrong whilst retrivieng your donations')
                })
            },
            selectFromParentComponent() {
                // select option from parent component
                this.item = this.options[0]
            },
            validate() {
                if (this.$refs.form.validate()) {
                    this.snackbar = true
                    this.valid = true
                    this.validDonate = true
                    this.validIspTCS = true
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
            updateConnectionSpeed(country) {
                console.log("country: ", country)
                let This = this
                this.isLoading = true
                const baseUrl = 'http://eu.httpbin.org/stream-bytes/50000000';
                const fileSize =
                    500000; //@dev we just assume that the upload speed is the same as the download speed terrible assumption :XD
                this.testNetworkSpeed.checkDownloadSpeed(baseUrl, fileSize).then((downloadSpeed) => {
                    downloadSpeed = Math.round(downloadSpeed.mbps)
                    this.UNICEFContract.methods.updateuploadDownloadSpeedISP(downloadSpeed, downloadSpeed)
                        .send({
                            gas: 8000000
                        }).then((receipt, error) => {
                            if (receipt) {
                                this.success("Succefully updated Connection Speed to: " + downloadSpeed +
                                    " Mbps")
                            }
                            This.isLoading = false
                        }).catch((err) => {
                            console.log(err)
                            This.error("Something went wrong whilst trying to update the connection speed")
                            This.isLoading = false
                        })
                })

            },
            registerasSchool() {
                this.isLoading = true
            },
            getISP(name) {
                var isp = this.ISPS.filter((isp) => {
                    console.log(isp)
                    return isp.value === name
                })
                return isp
            },
            registerDonation(isp) {
                let This = this
                console.log(this.amount)
                this.UNICEFContract.methods.donate(isp.address).send({
                    gas: 8000000,
                    value: this.amount
                }).then((receipt, err) => {
                    if (err) {
                        console.log(err)
                    } else {
                        console.log(receipt)
                        This.success('Successfully donated ', This.amount, 'to ', this
                            .ispName)
                    }
                    this.isLoading = false
                }).catch((err) => {
                    console.log("error: ", err)
                    This.error(
                        'Something went wrong whilst trying to donate please try again')
                    This.isLoading = false
                })
            },
            transferEther(from, to, amount, ispKey, isp) {
                let This = this
                if (from === to) {
                    this.error("Ooops cannot donate to your self")

                    This.isLoading = false
                } else {
                    //  var isp =this.getISP(this.ispName)
                    console.log(ispKey)
                    this.UNICEFContract.methods.ispRegistered(ispKey).call({
                        gas: 8000000
                    }).then((exist, err) => {
                        if (exist) {
                            const amountToSend = Web3.utils.toWei(this.amount,
                                "ether"); //convert to wei value
                            var send = this.Web3.eth.sendTransaction({
                                from: from,
                                to: to,
                                value: this.value
                            }).then((receipt, err) => {
                                if (!err) {
                                    This.registerDonation(isp, amount)
                                }
                                console.log(receipt)
                            }).catch((err) => {
                                console.log(err)
                                This.isLoading = false
                            });


                        } else {
                            this.error("Receipient of donation is not a valid ISP")
                            This.isLoading = false
                        }
                    }).catch((err) => {
                        this.error("Receipient of donation is not a valid ISP")
                        This.isLoading = false
                    })


                }
            },
            donateToISP() {
                console.log(this.ispName)
                let This = this
                var isp = this.getISP(this.ispName)
                if (isp.length === 1) {
                    isp = isp[0]
                } else {
                    //@dev to implement in the instance where an ISP operates in more than 1 country

                }
                if (!isp || isp.length === 0) {
                    isp = isp.address
                    this.error("We are unable to register you as an ISP please try again soon")
                } else {
                    if (this.validDonate) {
                        this.isLoading = true
                        if (this.customToken) {
                            this.UNICEFContract.methods.donateERC20(this.amount,
                                isp, this.Web3.utf8ToHex(this.ispName),
                                this
                                .tokenAddress).send({
                                gas: 8000000
                            }).then((receipt, err) => {
                                if (err) {
                                    console.log(err)
                                } else {
                                    console.log(receipt)
                                    This.success('Successfully donated ', This.amount, 'to ', this
                                        .ispName)
                                }
                                this.isLoading = false
                            }).catch((err) => {
                                This.error(
                                    'Something went wrong whilst trying to donate please try again')
                                This.isLoading = false
                            })
                        } else {
                            console.log(this.Web3.utils.utf8ToHex(this.ispName))
                            this.Web3.eth.getAccounts((accounts) => {
                                console.log(accounts)
                            })
                            this.transferEther(this.Web3.eth.defaultAccount, isp.address, this.amount, isp.key, isp)
                        }
                    }
                }
            },
            registerISP() {
                let This = this
                if (this.validIspTCS) {
                    this.isLoading = true
                    console.log(this.Web3.utils.utf8ToHex(this.ispName))
                    console.log(this.Web3.utils.utf8ToHex(this.ispEmail))
                    console.log(this.Web3.utils.utf8ToHex(this.selectedCountry))
                    this.UNICEFContract.methods.registerISP(this.Web3.utils.utf8ToHex(this.ispName), this
                            .Web3.utils
                            .utf8ToHex(this.ispEmail), this.Web3.utils.utf8ToHex(this.selectedCountry))
                        .send({
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
                } else {
                    this.validate()
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
