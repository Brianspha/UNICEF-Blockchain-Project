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
                                            <model-select :options="options" label="ISP Name" v-model="item"
                                                placeholder="ISP Name e.g. Cell C- South Africa">
                                            </model-select>
                                            <v-spacer></v-spacer>
                                            <v-checkbox v-model="customToken" label="Donate using a custom token?"
                                                required></v-checkbox>
                                            <v-checkbox v-model="checkbox"
                                                :rules="[v => !!v || 'You must agree to continue!']"
                                                label="Do you agree?" required></v-checkbox>
                                            <v-btn :disabled="!valid" color="success" class="mr-4" @click="validate">
                                                Donate
                                            </v-btn>
                                            <v-btn color="primary" @click="donate=false">
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
                                            <v-spacer></v-spacer>
                                            <v-checkbox v-model="checkbox"
                                                :rules="[v => !!v || 'You must agree to continue!']"
                                                label="Agree to Terms and Conditions?" required></v-checkbox>
                                            <v-btn color="primary" @click="ispTCS=true;">
                                                Terms and Conditions
                                            </v-btn>
                                            <v-btn :disabled="!valid" color="success" class="mr-4" @click="validate">
                                                Register
                                            </v-btn>
                                            <v-btn color="primary" @click="ispRegistration=false;valid=true">
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
                                    <v-btn color="blue darken-1" text @click="ispTCS = false">Close</v-btn>
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
                                                    label="New Speed"
                                                    hint="e.g. 10 N.B. The value is converted to <b>(Mbps)</b> "
                                                    required>
                                                </v-text-field>
                                                <v-text-field v-model="dataBundles" :rules="dataBundlesRules"
                                                    label="Data Bundles"
                                                    hint="e.g. 100  N.B. The value is converted to <b>(MB)<b> "
                                                    required>
                                                </v-text-field>
                                                <v-btn :disabled="!valid" color="success" class="mr-4"
                                                    @click="validate; updateConnectionSpeed()">
                                                    Update
                                                </v-btn>
                                                <v-btn color="primary" @click="updateCountrySpeed=false;valid=true">
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
                                    <v-btn color="blue darken-1" text @click="ispUpdate = false">Close</v-btn>
                                </v-card-actions>
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

                                <v-flex xs4 v-ripple @click="showMenu(6)" v-if="isISP">
                                    <v-hover v-slot:default="{ hover }" close-delay="200">
                                        <v-card :elevation="hover ? 16 : 2" class="mx-auto" height="200">
                                            <v-layout align-center justify-center column fill-height>Update Connection
                                                Speed
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
    import Loading from 'vue-loading-overlay';
    import {
        ModelSelect
    } from 'vue-search-select'

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
                    v => /.+@.+\..+/.test(v) || 'E-mail must be valid',
                ],
                tokenAddress: '',
                tokenAddressRules: [
                    v => !!v || "Token Address is required",
                    v => (v && v.length === 42) || 'Token address must have 42 characters'
                ],
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
                isISP: true

            }
        },
        methods: {
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

            }
        }

    }
</script>

<style>
@import "~vue-snotify/styles/material.css"

</style>
