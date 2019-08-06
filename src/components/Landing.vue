<template>
    <v-app id="inspire">
        <v-container align-center justify-center row fill-height>
            <v-layout>
                <v-flex>
                    <v-toolbar color="#7EC0EE" dark>
                        <v-toolbar-title>Schools</v-toolbar-title>
                        <v-spacer></v-spacer>
                    </v-toolbar>
                    <highcharts :constructor-type="'mapChart'" :options="mapOptions" class="map"></highcharts>
                </v-flex>
                <v-bottom-sheet v-model="sheet" :inset="true" :hide-overlay="true">
                    <v-sheet class="text-center" height="200px" align-center justify-center row fill-height>
                        <v-btn class="my-6" depressed color="error" @click="sheet = !sheet">close</v-btn>
                    </v-sheet>
                </v-bottom-sheet>
            </v-layout>
        </v-container>
    </v-app>
</template>

<script>
    import reverseGeoCoder from 'fast-reverse-geocoder'
    export default {
        data() {
            return {
                sheet: false,
                mapOptions: {}
            }
        },
        beforeMount() {
            this.initData()
        },
        methods: {
            initData() {
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
    .map {
        min-height: 80%;
    }
</style>