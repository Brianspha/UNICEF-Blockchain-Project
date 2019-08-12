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
                                    <v-btn color="blue darken-1" text @click="accountDetails = false">Close</v-btn>
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
                                            <model-select :options="options" v-model="item" placeholder="select item2">
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
                        <v-dialog v-model="settings" persistent max-width="600px">
                            <v-card>
                                <v-card-title>
                                    <span class="headline">My Donations</span>
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
                                    <v-btn color="blue darken-1" text @click="settings = false">Close</v-btn>
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
                                    <v-container fluid>
                                        <v-layout wrap>
                                            <v-flex v-for="n in 9" :key="n" xs4>
                                                <v-card flat tile>
                                                   ISP Name: {{n}}<br>
                                                   Country:  {{n}}<br>
                                                   Amount: {{n}}<br>
                                                   Speed: {{n}}<br>
                                                   <v-card-actions>

                                                   </v-card-actions>
                                                </v-card>
                                            </v-flex>
                                        </v-layout>
                                    </v-container>
                                </v-card-text>
                                <v-card-actions>
                                    <v-spacer></v-spacer>
                                    <v-btn color="blue darken-1" text @click="myDonations = false">Close</v-btn>
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
                                            <v-layout align-center justify-center column fill-height>Settings
                                            </v-layout>
                                        </v-card>
                                    </v-hover>
                                </v-flex>
                            </v-layout>
                        </v-card>
                    </v-flex>
                </v-layout>
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
                isLoading: false,
                fullPage: true,
                accountDetails: false,
                donate: false,
                settings: false,
                myDonations: false,
                userAddress: '',
                valid: true,
                amount: '',
                amountRules: [
                    v => !!v || 'Donation Amount is required',
                    v => (v && !isNaN(v)) || 'Donation amount must be a valid amount e.g. 10',
                ],
                email: '',
                emailRules: [
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

            }
        },
        methods: {
            showMenu(whichMenu) {
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
                        this.settings = true
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
            }
        }

    }
</script>