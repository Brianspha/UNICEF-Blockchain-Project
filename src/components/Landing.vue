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
                <v-layout justify-center v-if="dialog">
                    <v-dialog v-model="dialog" fullscreen hide-overlay transition="dialog-bottom-transition">

                        <v-toolbar dark color="primary">
                            <v-btn icon dark @click="dialog = false">
                                <v-icon>close</v-icon>
                            </v-btn>
                            <v-toolbar-title>{{country}}</v-toolbar-title>
                            <v-spacer></v-spacer>
                            <v-toolbar-items>
                                <v-btn  text @click="dialog = false" color="transparent">Save</v-btn>
                            </v-toolbar-items>
                        </v-toolbar>
                        <v-map :zoom="zoom" :center="center" style="z-index:1;">
                            <v-icondefault></v-icondefault>
                            <v-tilelayer url="http://{s}.tile.osm.org/{z}/{x}/{y}.png"></v-tilelayer>
                            <v-marker-cluster :options="clusterOptions" @clusterclick="sheet=true;" @click="">
                                <v-marker v-for="school in schools" :key="school.name+school.position"
                                    :lat-lng="school.position" :icon="icon" :color="school.color">
                                    <v-popup :content="school.description">
                                    </v-popup>
                                </v-marker>
                            </v-marker-cluster>
                        </v-map>
                    </v-dialog>
                </v-layout>
            </v-layout>
        </v-container>
    </v-app>
</template>

<script>
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
    import iconUrl from 'leaflet/dist/images/marker-icon.png'
    import shadowUrl from 'leaflet/dist/images/marker-shadow.png'
    import reverseGeoCoder from 'fast-reverse-geocoder'
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
        },
        data() {
            return {
                country: '',
                sheet: false,
                mapOptions: {},
                dialog: false,
                clickedCountry: null,
                schools: [],
                url: 'http://{s}.tile.osm.org/{z}/{x}/{y}.png',
                attribution: '&copy; <a href=" http://osm.org/copyright">OpenStreetMap </a> contributors',
                map: null,
                zoom: 10,
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
                colors: []
            }
        },
        watch: {
            map: function () {
                this.$forceUpdate()
            }
        },
        beforeMount() {
            this.initData()
        },
        methods: {
            initData() {
                let This = this
                this.mapOptions = {
                    chart: {
                        map: 'myMapName'
                    },
                    title: {
                        text: 'Schools connected to the internet by country'
                    },
                    subtitle: {
                        text: 'Source map: World Map shwoing Schools connected to the internet by country provided by UNICEF</a>'
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
                                    click: function () {
                                        This.dialog = true
                                        This.country = this.name
                                        This.findCountrySchools()
                                    }
                                }
                            }
                        }
                    },
                    drilldown: {
                        activeDataLabelStyle: {
                            color: '#FFFFFF',
                            textDecoration: 'none',
                            textOutline: '1px #000000'
                        },
                        drillUpButton: {
                            relativeTo: 'plotBox',
                            position: {
                                x: 70,
                                y: 280
                            }
                        },
                        series: [{}]
                    },
                    series: [{
                        animation: {
                            duration: 1000
                        },
                        data: this.getConnectedSchools(),
                        name: 'Total number of Schools connected to the Internet ',
                        tooltip: {
                            pointFormat: '{point.value}'
                        }
                    }]
                }
            },
            findCountrySchools() {
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
                    console.log(schools.GIS_Latitude === schools.GIS_Longitude, schools.GIS_Latitude, schools
                        .GIS_Longitude
                        .toString())
                    if (schools.GIS_Latitude === schools.GIS_Longitude) {
                        console.log("equal")
                        return
                    }
                    this.center = [schools.GIS_Latitude, schools.GIS_Longitude]
                    this.schools.push({
                        name: schools.Official_Institution_Name,
                        color: "#7EC0EE",
                        description: ("Name: " + schools.Official_Institution_Name + "<br>Address: " +
                            schools
                            .StreetAddress +
                            "\n" + schools.PostalAddress +
                            "\n" + schools.Suburb + "\n" + schools.TownCity),
                        position: latLng(
                            schools.GIS_Latitude.toString().replace(/ /g, ''),
                            schools.GIS_Longitude.toString().replace(/ /g, '')
                        ),
                        country: reverseGeoCoder.search(schools.GIS_Longitude.toString().replace(/ /g,
                                ''),
                            schools
                            .GIS_Latitude.toString().replace(/ /g, ''))
                    })
                })
                return this.schools
            },
            getCountriesSchools() {
                var schools = require('../json/schools.json')
                var countries = []
                schools.forEach((school) => {
                    if (!school.GIS_Latitude || !school.GIS_Longitude) {
                        return
                    } else {
                        school.GIS_Latitude = school.GIS_Latitude.toString().replace(/,/g, '.')
                            .toString()
                            .replace(/ /g, '')
                        school.GIS_Longitude = school.GIS_Longitude.toString().replace(/,/g, '.')
                            .toString()
                            .replace(/ /g, '')
                        if (school.GIS_Latitude === school.GIS_Longitude) {
                            console.log("equal")
                            return
                        }
                        // console.log(school)
                        var country = reverseGeoCoder.search(school.GIS_Longitude, school.GIS_Latitude)
                        //console.log(country)
                        if (!country) {
                            return
                        }
                        if (!countries.some((county => county.name !== country.name))) {
                            countries.push([country.name, 1])
                        } else {
                            countries.map((countryData) => {
                                if (countryData[0] == country.name) {
                                    countryData[1] += 1
                                    return countryData
                                }
                            })
                        }
                    }

                })
                //green well connected
                //yellow okay connection
                //red bad service
                console.log(countries)
                var newschoolsData = []
                countries.forEach((country) => {
                    newschoolsData.push({
                        name: "High connectivity",
                        y: 19,
                        color: "green",
                        value: country[1],
                        countryName: country[0]
                    })
                })
                console.log(newschoolsData)
                // console.log(newschoolsData)
                return newschoolsData
            },
            getConnectedSchools() {
                var countrySchools = this.getCountriesSchools()
                var map = require('../json/worldmapplain.json')
                // console.log('schools: ', countrySchools)
                var connectedSchools = map.features.filter((feature) => {
                    // console.log(feature.properties, countrySchools.some((school) => school.name === feature
                    //      .properties.name))
                    return countrySchools.some((school) => school.countryName === feature.properties
                        .name)
                })
                //console.log("connected: ", connectedSchools)
                connectedSchools = connectedSchools.map((country) => {
                    console.log(country.properties["hc-key"])
                    return [country.properties["hc-key"], countrySchools.find((school) => school
                        .countryName ===
                        country.properties.name).value]
                })
                // console.log("connectedSchools: ", connectedSchools)
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
    }

    .map {
        min-height: 80%;
    }
</style>