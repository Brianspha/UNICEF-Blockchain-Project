<template>
    <v-card>
        <v-list-tile :key="index+new Date().getTime()" avatar ripple  @click="">
            <v-list-tile-content>
                <v-list-tile-title>School Name: {{name}}
                </v-list-tile-title>
                <v-list-tile-sub-title>Country: {{ country }}
                </v-list-tile-sub-title>
                <v-list-tile-sub-title>ISP Provider: {{ isp }}
                </v-list-tile-sub-title>
            </v-list-tile-content>
            <v-tooltip top>
                <template v-slot:activator="{ on }">
                    <v-btn icon x-smal ripple>
                        <v-icon color="grey lighten-1" @click="selectedVenue=venue; registerschool(name)" v-on="on">
                            check_circle_outline
                        </v-icon>
                    </v-btn>
                </template>
                <span>Register School</span>
            </v-tooltip>
            <v-tooltip top>
                <template v-slot:activator="{ on }">
                    <v-btn icon x-smal ripple>
                        <v-icon color="grey lighten-1" @click="selectedVenue=venue;removeSchool()" v-on="on">
                            remove_circle_outline</v-icon>
                    </v-btn>
                </template>
                <span>Remove School</span>
            </v-tooltip>
        </v-list-tile>
        <v-divider></v-divider>
    </v-card>
</template>

<script>
    export default {
        props: ['name', 'index', 'country', 'isp', 'registered', 'postalAddress', 'cityTown', 'latitude', 'longitude'],
        mounted() {
            console.log("school: ", name)
        },
        data() {
            return {
                selectedSchool: null,
                dialog: false
            }
        },
        methods: {
            registerschool() {

            },
            getSchoolInformation(index) {

            },
            removeSchool() {

            }
        }
    }
</script>