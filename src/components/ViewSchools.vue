<template>
    <v-app id="inspire">
        <v-container align-center justify-center row fill-height>
            <v-layout>
                <v-flex>
                    <v-toolbar color="#7EC0EE" dark>
                        <v-toolbar-title>Schools</v-toolbar-title>
                        <v-spacer></v-spacer>
                    </v-toolbar>
                    <v-map :zoom="zoom" :center="center" style="z-index:1;">
                        <v-icondefault></v-icondefault>
                        <v-tilelayer url="http://{s}.tile.osm.org/{z}/{x}/{y}.png"></v-tilelayer>
                        <v-marker-cluster :options="clusterOptions" @clusterclick="sheet=true;" @click="">
                            <v-marker v-for="venue in venueLocations" :key="venue.name+venue.position"
                                :lat-lng="venue.position" :icon="icon" :color="venue.color">
                                <v-popup :content="venue.description">
                                </v-popup>
                            </v-marker>
                        </v-marker-cluster>
                    </v-map>
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
    import EmbarkJS from '../../embarkArtifacts/embarkjs';
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
                url: 'http://{s}.tile.osm.org/{z}/{x}/{y}.png',
                attribution: '&copy; <a href=" http://osm.org/copyright">OpenStreetMap </a> contributors',
                map: null,
                zoom: 2,
                maxBoundsViscosity: 1.0,
                venueLocations: [],
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
                colors:[]
            }
        },
        watch: {
            map: function () {
                this.$forceUpdate()
            }
        },
        mounted() {
            this.initMap();
            setTimeout(() => {
                console.log('done')
                this.$nextTick(() => {
                    this.clusterOptions = {
                        disableClusteringAtZoom: 11
                    }
                });
            }, 5000);
        },
        beforeMount() {
            var venues = require("../json/schools.json")
            let This = this
            let count = 1
            venues.forEach((venue) => {
                if (!venue.GIS_Latitude || !venue.GIS_Longitude) {
                    return
                }
                venue.GIS_Latitude = venue.GIS_Latitude.toString().replace(/,/g, '.')
                venue.GIS_Longitude = venue.GIS_Longitude.toString().replace(/,/g, '.')
                console.log(venue.GIS_Latitude === venue.GIS_Longitude, venue.GIS_Latitude, venue.GIS_Longitude
                    .toString())
                if (venue.GIS_Latitude === venue.GIS_Longitude) {
                    console.log("equal")
                    return
                }
                count++
                //console.log(`count ${count}`)
                this.venueLocations.push({
                    name: venue.Official_Institution_Name,
                    color:"#7EC0EE",
                    description: ("Name: " + venue.Official_Institution_Name + "<br>Address: " + venue
                        .StreetAddress +
                        "\n" + venue.PostalAddress +
                        "\n" + venue.Suburb + "\n" + venue.TownCity),
                    position: latLng(
                        venue.GIS_Latitude.toString().replace(/ /g, ''),
                        venue.GIS_Longitude.toString().replace(/ /g, '')
                    ),
                    country: reverseGeoCoder.search(venue.GIS_Longitude.toString().replace(/ /g, ''),
                        venue
                        .GIS_Latitude.toString().replace(/ /g, ''))
                })


            })
            //console.log(this.venueLocations)
        },
        methods: {
            initMap() {



                // this.$refs.map.addLayer(markerClusters)
            },
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

    v-map {
        z-index: 1;
    }
</style>