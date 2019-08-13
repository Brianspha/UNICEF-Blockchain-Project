<template>
    <v-app id="inspire">
        <v-container align-center justify-center row fill-height>
            <v-dialog v-if="dialog" v-model="dialog" width="100%" align-start justify-center row fill-height>
                <v-card-title>
                    <span class="headline">School Details</span>
                </v-card-title>
                <v-card-text>School Name: {{selectedSchool.name}}</v-card-text>
                <v-card-text>PostalAddress: {{(selectedSchool.postalAddress)}}</v-card-text>
                <v-card-text>Town-City: {{selectedSchool.cityTown}}
                </v-card-text>
                <v-card-text>Latitude: {{selectedSchool.latitude}}</v-card-text>
                <v-card-text>Longitude: {{selectedSchool.longitude}}</v-card-text>
                <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn color="#7E57C2" flat="flat" @click="dialog = false">Close</v-btn>
                </v-card-actions>
            </v-dialog>
            <v-layout>
                <v-flex>
                    <v-card class="elevation-12" align-center justify-center column fill-height>
                        <v-toolbar color="#7EC0EE">
                            <v-toolbar-title>Schools Database</v-toolbar-title>
                            <v-spacer></v-spacer>
                        </v-toolbar>

                        <v-flex class="containerflex" style="height:900px;">
                            <v-card>
                                <MultiSelect :selected-options="selectedSchools" :options="schoolsOptions"
                                    label="School" @select="onSelect"
                                    placeholder="Search School: e.g. AJ Mwelase Primary School">
                                </MultiSelect>
                                <v-card-actions>
                                    <v-btn color="#7EC0EE" @click="registerschool()">
                                        Register
                                    </v-btn>
                                </v-card-actions>
                            </v-card>
                            <v-card>
                                <virtual-list class="list" :size="size" :remain="remain" :start="start" :item="item"
                                    :itemcount="itemCount" :itemprops="getItemprops">
                                </virtual-list>
                            </v-card>
                        </v-flex>
                        <loading :active.sync="isLoading" :can-cancel="false" :is-full-page="fullPage">
                        </loading>
                    </v-card>
                </v-flex>
            </v-layout>
        </v-container>
    </v-app>
</template>
<script>
    import {
        MultiSelect
    } from 'vue-search-select'
    import {
        ModelSelect
    } from 'vue-search-select'
    import virtualList from 'vue-virtual-scroll-list'
    import Loading from 'vue-loading-overlay';
    import Swal from 'sweetalert2'
    import {
        async
    } from 'q';
    import 'vue-loading-overlay/dist/vue-loading.css';
    import InfiniteLoading from 'vue-infinite-loading';
    import {
        setInterval,
        setTimeout
    } from 'timers';
    import sort from 'fast-sort';
    import reverseGeoCoder from 'fast-reverse-geocoder'
    import item from '../components/ListItem'
    export default {
        components: {
            InfiniteLoading,
            Loading,
            'virtual-list': virtualList,
            item,
            ModelSelect,
            MultiSelect

        },
        data() {
            return {
                selectedSchool: null,
                Schools: [],
                schoolsOptions: [],
                dialog: false,
                isLoading: false,
                fullPage: true,
                itemComponent: item,
                remain: 20,
                size: 80,
                itemCount: 0,
                start: 0,
                item: item,
                scrollelement: null,
                bench: 100,
                selectedSchools: []
            }
        },
        beforeMount() {
            this.loadSchools()
        },
        mounted() {},
        watch: {
            schools: async function () {
                let This = this
            },
            itemCount: async function () {

            }
        },
        methods: {
            onSelect(items, lastSelectItem) {
                this.selectedSchools = items
                this.selectedSchool = lastSelectItem
            },
            getItemprops(itemIndex) {
                // <item/> will render with following data object:
                // https://vuejs.org/v2/guide/render-function.html#The-Data-Object-In-Depth
                console.log(itemIndex, this.start)
                return {
                    props: {
                        name: this.Schools[itemIndex].name,
                        country: this.Schools[itemIndex].country,
                        isp: this.Schools[itemIndex].isp,
                        registered: this.Schools[itemIndex].registered,
                        index: itemIndex,
                        postalAddress: this.Schools[itemIndex].postalAddress,
                        cityTown: this.Schools[itemIndex].cityTown,
                        latitude: this.Schools[itemIndex].latitude,
                        longitude: this.Schools[itemIndex].longitude
                    },
                }
            },
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
                        latitude: school.latitude,
                        longitude: school.longitude,
                        text: `${school.Official_Institution_Name} - ${country.name}`
                    })
                    this.itemCount++
                    //console.log(newSchool)
                    newSchoolData.push(newSchool)
                })
                this.Schools = newSchoolData
                console.log("itemCount: ", this.itemCount)
            },
            initData() {

            },
            onHeaderDataChange(type, value) {
                if (type === 'start') {
                    this.start = value
                    console.log('start: ', start)
                }
            },
            getSchoolInformation(index) {

            },
            registerschool() {

            },
            removeSchool() {

            }

        }
    }
</script>
<style>
    .containerflex {
        display: flex;
        flex-direction: column;
        height: 100%;
        overflow: auto;
    }
</style>