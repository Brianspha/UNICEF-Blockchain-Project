<template>
    <v-app id="inspire">
        <v-container align-center justify-center row fill-height>
            <v-layout>
                <v-flex>
                    <v-toolbar color="#7EC0EE">
                        <v-toolbar-title>Schools</v-toolbar-title>
                        <v-spacer></v-spacer>
                    </v-toolbar>
                    <highcharts :constructor-type="'mapChart'" :options="mapOptions" class="map"></highcharts>
                </v-flex>
                <v-dialog v-model="dialog" max-width="100%" fullscreen hide-overlay lazy
                    transition="dialog-bottom-transition">
                    <v-card>
                        <v-toolbar dark color="#7EC0EE">
                            <v-toolbar-title>{{country}}</v-toolbar-title>
                            <v-spacer></v-spacer>
                            <v-toolbar-items>
                                <v-btn dark flat @click="dialog = false;">Close</v-btn>
                            </v-toolbar-items>
                        </v-toolbar>
                        <v-tabs v-model="tabs" centered color="transparent" slider-color="white">
                            <v-tab v-for="(tab,index ) in tabItems" :key="index">
                                {{ tab.title }}
                            </v-tab>
                        </v-tabs>
                        <v-tabs-items v-model="tabs">
                            <v-tab-item style="height:1024px">
                                <v-map :zoom="zoom" :center="center" min-height="1024px">
                                    <v-icondefault></v-icondefault>
                                    <v-tilelayer :url="url">
                                    </v-tilelayer>
                                    <v-marker-cluster :options="clusterOptions" @clusterclick="" @click="">
                                        <v-marker v-for="school in schools" :key="school.name+school.position"
                                            :lat-lng="school.position" :icon="icon" :color="school.color">
                                            <v-popup :content="school.description">
                                            </v-popup>
                                        </v-marker>
                                    </v-marker-cluster>
                                </v-map>
                            </v-tab-item>
                            <v-tab-item style="height:1024px">
                                <highcharts :options="DetailsOptions" :updateArgs="updateArgs">
                                </highcharts>
                                <highcharts :options="ispOptions" :updateArgs="updateArgs">
                                </highcharts>
                            </v-tab-item>
                            <v-tab-item style="height:1024px">
                                <highcharts :options="activityOptions" :updateArgs="updateArgs">
                                </highcharts>
                                <highcharts :options="ispDonorOptions" :updateArgs="updateArgs">
                                </highcharts>
                            </v-tab-item>
                        </v-tabs-items>
                    </v-card>
                </v-dialog>
            </v-layout>
            <loading :active.sync="isLoading" :can-cancel="false" :is-full-page="fullPage">
            </loading>
        </v-container>
    </v-app>
</template>

<script>
    import JSON5 from 'json5'
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
    import reverseGeoCoder from 'fast-reverse-geocoder'
    import Loading from 'vue-loading-overlay';
    import EmbarkJS from '../../embarkArtifacts/embarkjs'
    import {
        rejects
    } from 'assert';
    export default {
        components: {
            'v-map': Vue2Leaflet.LMap,
            'v-tilelayer': Vue2Leaflet.LTileLayer,
            'v-icondefault': Vue2Leaflet.LIconDefault,
            'v-marker': Vue2Leaflet.LMarker,
            'v-popup': Vue2Leaflet.LPopup,
            'v-marker-cluster': Vue2LeafletMarkerCluster,
            'v-icondefault': Vue2Leaflet.LIconDefault,
            'v-marker': Vue2Leaflet.LMarker,
            'v-popup': Vue2Leaflet.LPopup,
            Loading
        },
        data() {
            return {
                updateArgs: [true, true, true],
                country: '',
                sheet: false,
                mapOptions: {},
                dialog: false,
                limit: 50,
                clickedCountry: null,
                schools: [],
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
                clusterOptions: {},
                RhodeITContract: null,
                limit: 500,
                countries: [],
                center: L.latLng(-33.311836, 26.520642),
                sheet: false,
                colors: [],
                DetailsOptions: {},
                tabItems: [{
                        title: "View Map"
                    },
                    {
                        title: "Infographics"
                    },
                    {
                        title: "Activity"
                    }
                ],
                tabs: null,
                isLoading: false,
                fullPage: true,
                months: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September',
                    'October', 'November', 'December'
                ],
                selectedCountry: '',
                activityOptions: {},
                ispOptions: {},
                ispDonorOptions: {},
                UNICEFContract: null,
                ispCategories: [],
                speeds: []
            }
        },
        watch: {
            map: function () {
                this.$forceUpdate()
                this.map.invalidateSize()
            }
        },
        beforeMount() {
            this.initData()
            this.init()
        },
        methods: {
            init() {
                EmbarkJS.onReady((err) => {
                    console.log(err)
                    this.UNICEFContract = require('../../embarkArtifacts/contracts/UNICEF')
                })
            },
            initData() {
                let This = this
                this.mapOptions = {
                    chart: {
                        map: 'myMapName'
                    },
                    title: {
                        text: 'Schools under the supervision of UNICEF '
                    },
                    subtitle: {
                        text: 'Source map: World Map showing the number of schools who are connected to the internet through the aid of UNICEF</a>'
                    },
                    mapNavigation: {
                        enabled: true,
                        buttonOptions: {
                            alignTo: 'spacingBox'
                        }
                    },

                    colorAxis: {
                        min: 1,
                        type: 'logarithmic',
                        minColor: '#EEEEFF',
                        maxColor: '#000022',
                        stops: [
                            [0, '#EFEFFF'],
                            [0.67, '#4444FF'],
                            [1, '#000022']
                        ]
                    },
                    plotOptions: {
                        series: {
                            point: {
                                events: {
                                    click: function (e) {
                                        //("country: ", this.name)
                                        This.isLoading = true
                                        This.dialog = true
                                        This.country = this.name
                                        This.getISPDetails(this.name)
                                        This.getISPForSchools(this.name)
                                        This.getISPActivity(this.name)
                                        This.getISPDonorsForCountry(This.name)
                                        This.getISPConnectionSpeeds(this.name)
                                        This.getISPForCountry(this.name)
                                        This.getAverageISPConnectionSpeed(this.name)
                                        This.findCountrySchools(this.name)
                                        This.isLoading = false
                                    }
                                }
                            }
                        }
                    },
                    series: [{
                        legend: {
                            enabled: false
                        },
                        animation: {
                            duration: 1000
                        },
                        data: this.getConnectedSchools(),
                        name: 'Total number of Schools ',
                        tooltip: {
                            pointFormat: '{point.value}  in {point.name}<br><br> Click for more details'
                        }
                    }]
                }
            },
            getISPActivity(country) {
                let This = this
                this.activityOptions = {
                    chart: {
                        type: 'column'
                    },
                    title: {
                        text: 'Charts Showing activity related to ISP, Donors and UNICEF'
                    },
                    subtitle: {
                        text: 'Source: UNICEF'
                    },
                    xAxis: {
                        categories: [
                            this.months[new Date().getMonth()]
                        ],
                        crosshair: true
                    },
                    yAxis: {
                        min: 0,
                        title: {
                            text: 'No of Schools Connected to the Internet by ISP '
                        }
                    },
                    tooltip: {
                        headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
                        pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
                            '<td style="padding:0"><b>{point.y:.1f}</b></td></tr>',
                        footerFormat: '</table>',
                        shared: true,
                        useHTML: true
                    },
                    plotOptions: {
                        column: {
                            pointPadding: 0.2,
                            borderWidth: 0
                        }
                    },
                    series: []
                }
                this.ispDonorOptions = {
                    chart: {
                        type: 'packedbubble',
                        height: '50%'
                    },
                    title: {
                        text: 'Graph showing donors who provide funding to ISP to provide Internet Connection'
                    },
                    tooltip: {
                        useHTML: true,
                        pointFormat: '<b>School ISP Name:</b>{point.name} <br> <b>Amount (Eth):</b> {point.value} <br> <b>ConnectionSpeed:</b> {point.speed}'
                    },
                    plotOptions: {
                        packedbubble: {
                            minSize: '20%',
                            maxSize: '100%',
                            zMin: 0,
                            zMax: 1000,
                            layoutAlgorithm: {
                                gravitationalConstant: 0.05,
                                splitSeries: true,
                                seriesInteraction: false,
                                dragBetweenSeries: true,
                                parentNodeLimit: true
                            },
                            dataLabels: {
                                enabled: true,
                                format: '{point.name}',
                                filter: {
                                    property: 'y',
                                    operator: '>',
                                    value: 250
                                },
                                style: {
                                    color: 'black',
                                    textOutline: 'none',
                                    fontWeight: 'normal'
                                }
                            }
                        }
                    },
                    series: []
                }

            },
            getISPConnectionSpeeds(country) {
                let This = this
                this.ispOptions = {
                    chart: {
                        type: 'bar',
                        marginLeft: 100
                    },
                    title: {
                        text: 'Average Speed by Internet Service Provider (ISP) in Mbps',
                        align: 'left',
                        x: 90
                    },

                    credits: {
                        enabled: false
                    },

                    xAxis: {
                        categories: [],
                        labels: {
                            enabled: true
                        }
                    },

                    yAxis: {
                        allowDecimals: false,
                        title: {
                            text: null
                        },
                        min: 0,
                        max: 10
                    },
                    legend: {
                        enabled: false
                    },
                    series: []
                }
            },
            getAverageISPConnectionSpeed: async function (countryName) {
                let This = this
                var speeds = []
                var results = await this.UNICEFContract.methods.getRegisteredSchoolIDs().call({
                    gas: 8000000
                })
                results = results.map((id) => {
                    var ispID, schoolName, address, country, latitude, longitude,
                        upload, download, postalAddress;
                    var details = web3.eth.abi.decodeParameters(["address", "bytes",
                        "bytes",
                        "bytes", "bytes", "bytes", "uint256", "uint256"
                    ], id)
                    schoolName = web3.utils.toAscii((details[1]))
                    postalAddress = web3.utils.toAscii((details[2]))
                    address = ((details[0]))
                    country = web3.utils.toAscii((details[3]))
                    latitude = web3.utils.toAscii((details[4]))
                    longitude = web3.utils.toAscii((details[5]))
                    upload = (details[6])
                    download = (details[7])
                    longitude = This.removetrailingZeros(longitude)
                    latitude = This.removetrailingZeros(latitude)
                    latitude = latitude.replace(/m/g, '-')
                    longitude = longitude.replace(/m/g, '-')
                    return {
                        schoolName: schoolName,
                        postalAddress: postalAddress,
                        address: address,
                        country: country,
                        latitude: latitude,
                        longitude: longitude,
                        download: download,
                        upload: upload
                    }
                    console.log(results)
                })
                results = results.map((item) => {
                    if (countryName === item.country && web3.utils.isAddress(item.address)) {
                        return This.UNICEFContract.methods.getISPDetails(item.address)
                            .call({
                                gas: 8000000
                            }).then((results, err) => {
                                return [item, results, err]
                            })
                    }
                })
                await Promise.all(results).then((values) => {
                    values.forEach((details) => {
                        var address = details[1][0];
                        var name = Web3.utils.hexToAscii(details[1][1]);
                        name = This.removetrailingZeros(name)
                        if (!This.ispOptions.series.some((school) => school.name ===
                                name)) {

                            This.ispOptions.series.push({
                                "name": name,
                                data: [parseInt(details[0].upload)],
                            })
                            This.ispOptions.xAxis.categories.push(name)
                        }
                    })
                    if (This.ispOptions.xAxis.categories.length === 0) {
                        This.ispOptions.xAxis.categories.push("NO ISP")
                        This.ispOptions.series.push({
                            "name": "No ISP",
                            data: [0],
                        })
                    }
                    console.log(values)
                })
                console.log(speeds)
                return speeds
            },
            getISPForCountry(countryName) {
                return this.ispCategories
            },
            getISPDonorsForCountry: async function (countryName) {
                //@dev query smart contract
                var donations = []
                let This = this
                var keys = await this.UNICEFContract.methods.getallDonationKeys().call({
                    gas: 8000000
                })
                if (keys.length > 0) {
                    keys.forEach(async (key) => {
                        var details = await This.UNICEFContract.methods.getDonation(key).call({
                            gas: 8000000
                        })
                        var name, country, amount, funder;
                        name = This.removetrailingZeros(web3.utils.toAscii(details[0]))
                        country = web3.utils.toAscii(details[1])
                        amount = web3.utils.toAscii(details[2])
                        funder = details[3]
                        console.log(funder, name, country, amount)
                        if (!This.ispDonorOptions.series.some((donor) => donor
                                .name === funder)) {
                            This.ispDonorOptions.series.push({
                                name: funder,
                                data: [{
                                    name: name,
                                    value: amount,
                                    country: country
                                }]
                            })
                        } else {
                            This.ispDonorOptions.series = This.ispDonorOptions.series.map((donor) => {
                                if (donor.name === funder) {
                                    donor.data.push({
                                        name: name,
                                        value: amount,
                                        country: country
                                    })
                                }
                            })
                        }
                    })
                } else {
                    This.ispDonorOptions.series = [{
                        name: 'No Donors',
                        data: [{
                            name: 'No ISP',
                            value: 0,
                            speed: 0
                        }]
                    }]
                }
            },
            findCountrySchools(countryName) {
                var schools = require('../json/schools.json')
                this.schools = []
                let This = this
                let count = 1
                schools.forEach((schools) => {
                    if (!schools.GIS_Latitude || !schools.GIS_Longitude) {
                        return
                    }
                    schools.GIS_Latitude = schools.GIS_Latitude.toString().replace(/,/g, '.')
                    schools.GIS_Longitude = schools.GIS_Longitude.toString().replace(/,/g, '.')
                    // //console.log(schools.GIS_Latitude === schools.GIS_Longitude, schools.GIS_Latitude, schools
                    //   .GIS_Longitude
                    //    .toString())
                    if (schools.GIS_Latitude === schools.GIS_Longitude) {
                        ////console.log("equal")
                        return
                    }
                    var country = reverseGeoCoder.search(schools.GIS_Longitude.toString()
                        .replace(/ /g, ''),
                        schools.GIS_Latitude.toString().replace(/ /g, ''))
                    //console.log(reverseGeoCoder.search(schools.GIS_Longitude.toString().replace(/ /g,'')))
                    if (!country || country.name !== countryName) {
                        return
                    }
                    this.center = [schools.GIS_Latitude, schools.GIS_Longitude]
                    this.schools.push({
                        name: schools.Official_Institution_Name,
                        color: "#7EC0EE",
                        description: ("Name: " + schools.Official_Institution_Name +
                            "<br>Address: " +
                            schools
                            .StreetAddress +
                            "\n" + schools.PostalAddress +
                            "\n" + schools.TownCity),
                        position: latLng(
                            schools.GIS_Latitude.toString().replace(/ /g, ''),
                            schools.GIS_Longitude.toString().replace(/ /g, '')
                        ),
                        country: country
                    })
                })
                return this.schools
            },
            getISPDetails(country) {
                let This = this
                this.DetailsOptions = {
                    chart: {
                        type: 'column'
                    },
                    title: {
                        text: 'Schools Connected by ISP'
                    },
                    subtitle: {
                        text: 'Source: UNICEF'
                    },
                    xAxis: {
                        categories: [
                            this.months[new Date().getMonth()]
                        ],
                        crosshair: true
                    },
                    yAxis: {
                        min: 0,
                        title: {
                            text: 'No of Schools Connected to the Internet by ISP '
                        }
                    },
                    tooltip: {
                        headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
                        pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
                            '<td style="padding:0"><b>{point.y:.1f}</b></td></tr>',
                        footerFormat: '</table>',
                        shared: true,
                        useHTML: true
                    },
                    plotOptions: {
                        column: {
                            pointPadding: 0.2,
                            borderWidth: 0
                        }
                    },
                    series: []
                }
            },
            getISPForSchools: async function (countryName) {
                this.isLoading = true
                var schoolsFormated = []
                var count = 0
                let This = this
                let registeredSchools = []
                var results = await this.UNICEFContract.methods.getRegisteredSchoolIDs().call({
                    gas: 8000000
                })
                if (results.length > 0) {
                    results.map((id) => {
                        var ispID, schoolName, address, country, latitude,
                            longitude,
                            upload, download, postalAddress;
                        var details = web3.eth.abi.decodeParameters(["address",
                            "bytes",
                            "bytes",
                            "bytes", "bytes", "bytes", "uint256", "uint256"
                        ], id)
                        schoolName = web3.utils.toAscii((details[1]))
                        postalAddress = web3.utils.toAscii((details[2]))
                        address = ((details[0]))
                        country = web3.utils.toAscii((details[3]))
                        latitude = web3.utils.toAscii((details[4]))
                        longitude = web3.utils.toAscii((details[5]))
                        upload = (details[6])
                        download = (details[7])
                        longitude = This.removetrailingZeros(longitude)
                        latitude = This.removetrailingZeros(latitude)
                        latitude = latitude.replace(/m/g, '-')
                        longitude = longitude.replace(/m/g, '-')
                        if (countryName === country) {
                            console.log("address: ", address)
                            console.log("postalAddress: ", postalAddress)
                            This.UNICEFContract.methods.getISPDetails(address)
                                .call({
                                    gas: 8000000
                                }).then((dets, err) => {
                                    if (err) {
                                        console.log("error: ", err)
                                    }
                                    if (dets) {
                                        var address = dets[0];
                                        var name = Web3.utils.hexToAscii(
                                            dets[1]);
                                        name = This.removetrailingZeros(name)
                                        console.log("dets: ", dets)
                                        if (!This.DetailsOptions.series.some((school) =>
                                                school
                                                .name ===
                                                name)) {
                                            This.DetailsOptions.series.push({
                                                name: name,
                                                speed: upload,
                                                data: [1],
                                                schools: [schoolName]
                                            })
                                            This.activityOptions.series.push({
                                                name: name,
                                                speed: upload,
                                                data: [1],
                                                schools: [schoolName]
                                            })
                                            console.log("adding: ", name)
                                        } else {
                                            This.DetailsOptions.series =
                                                This.DetailsOptions.series.map((
                                                    school) => {
                                                    if (school.name ===
                                                        name) {
                                                        console.log("updating: ", school)
                                                        school.data[0] += 1
                                                        school.schools.push(
                                                            schoolName)
                                                    }
                                                    return school
                                                })
                                            This.activityOptions.series = This.activityOptions
                                                .series.map((
                                                    activity) => {
                                                    if (activity.name ===
                                                        name) {
                                                        console.log("updating: ", activity)
                                                        activity.data[0] += 1
                                                        activity.schools.push(
                                                            schoolName)
                                                    }
                                                    return school
                                                })

                                            //This.DetailsOptions.series = registeredSchools
                                        }
                                    } else {
                                        console.log('Something went wrong: ',
                                            error)
                                    }
                                }).catch((err) => {
                                    console.log(err)
                                })
                        }
                    })
                    This.DetailsOptions.series.push({
                        name: "Not Connected",
                        speed: 0,
                        data: [This.findCountrySchools(countryName).length - results.length],
                        schools: []
                    })
                    This.activityOptions.series.push({
                        name: "No Activity",
                        speed: 0,
                        data: [This.findCountrySchools(countryName).length - results.length],
                        schools: []
                    })
                } else {
                    This.DetailsOptions.series.push({
                        name: "Not Connected",
                        speed: 0,
                        data: [This.findCountrySchools(countryName).length],
                        schools: []
                    })
                    This.activityOptions.series.push({
                        name: "No Activity",
                        speed: 0,
                        data: [This.findCountrySchools(countryName).length],
                        schools: []
                    })
                }
            },
            removetrailingZeros(string) {
                console.log(string.split('').filter((c) => c.match(/^[0-9a-zA-Z-.]+$/)))
                return string.split('').filter((c) => c.match(/^[0-9a-zA-Z-.]+$/)).join("")
            },
            getCountriesSchools() {
                var schools = require('../json/schools.json')
                var countries = []
                schools.forEach((school) => {
                    if (!school.GIS_Latitude || !school.GIS_Longitude) {
                        return
                    } else {
                        school.GIS_Latitude = school.GIS_Latitude.toString().replace(/,/g,
                                '.')
                            .toString()
                            .replace(/ /g, '')
                        school.GIS_Longitude = school.GIS_Longitude.toString().replace(/,/g,
                                '.')
                            .toString()
                            .replace(/ /g, '')
                        if (school.GIS_Latitude === school.GIS_Longitude) {
                            ////console.log("equal")
                            return
                        }
                        // ////console.log(school)
                        var country = reverseGeoCoder.search(school.GIS_Longitude, school
                            .GIS_Latitude)
                        //console.log(country)
                        if (!country) {
                            return
                        }
                        if (!countries.some((county => county[0] === country.name))) {
                            countries.push([country.name, 1])
                            // console.log("created entry: ", country.name)
                            // console.log(countries)
                        } else {
                            countries = countries.map((countryData) => {
                                //console.log("searching: ",country.name,countryData[0])
                                if (countryData[0] === country.name) {
                                    //  console.log("updated entry: ", country.name)
                                    countryData[1] += 1
                                    return countryData
                                } else {
                                    return countryData
                                }
                            })
                        }
                    }

                })
                //green well connected
                //yellow okay connection
                //red bad service
                ////console.log(countries)
                var newschoolsData = []
                countries.forEach((country) => {
                    newschoolsData.push({
                        name: "High connectivity",
                        y: 19,
                        color: "green",
                        value: country[1],
                        country: country[0]
                    })
                })
                ////console.log(newschoolsData)
                // ////console.log(newschoolsData)
                return newschoolsData
            },
            getConnectedSchools() {
                var countrySchools = this.getCountriesSchools()
                var map = require('../json/worldmapplain.json')
                // ////console.log('schools: ', countrySchools)
                var connectedSchools = map.features.filter((feature) => {
                    // ////console.log(feature.properties, countrySchools.some((school) => school.name === feature
                    //      .properties.name))
                    return countrySchools.some((school) => school.country === feature
                        .properties
                        .name)
                })
                //////console.log("connected: ", connectedSchools)
                connectedSchools = connectedSchools.map((country) => {
                    ////console.log(country.properties["hc-key"])
                    return [country.properties["hc-key"], countrySchools.find((school) =>
                        school
                        .country ===
                        country.properties.name).value]
                })
                // //console.log("connectedSchools: ", connectedSchools)
                return connectedSchools
            }
        }
    }
</script>
<style scoped>
    @import "~leaflet/dist/leaflet.css";
    @import "~leaflet.markercluster/dist/MarkerCluster.css";
    @import "~leaflet.markercluster/dist/MarkerCluster.Default.css";

    #map {
        height: 100%;
        width: 100%;
    }

    v-map {
        min-width: 100%;
        min-height: 100%;
    }

    .map {
        min-height: 100%;
    }
</style>