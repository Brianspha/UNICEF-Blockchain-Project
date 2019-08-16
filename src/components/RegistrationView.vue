<template>

    <v-layout column align-center>
        <v-toolbar color="#7EC0EE">
            <v-toolbar-title>Schools</v-toolbar-title>
            <v-spacer></v-spacer>
        </v-toolbar>
        <v-flex style="width:100%">
            <v-form ref="form" v-model="valid" :lazy-validation="lazy">
                <v-text-field v-model="email" :rules="emailRules" label="E-mail" required></v-text-field>
                <v-select v-model="select" :items="items" :rules="[v => !!v || 'Item is required']" label="Item"
                    required>
                </v-select>
                <v-checkbox v-model="checkbox" :rules="[v => !!v || 'You must agree to continue!']"
                    label="Do you agree?" required></v-checkbox>
                <v-btn :disabled="!valid" color="success" class="mr-4" @click="validate">
                    Submit
                </v-btn>
                <v-btn color="error" class="mr-4" @click="reset">
                    Reset Form
                </v-btn>
            </v-form>
        </v-flex>
    </v-layout>
</template>

<script>
    import Portis from "@portis/web3";
    import Web3 from 'web3';
    import EmbarkJS from "../../embarkArtifacts/embarkjs";
    export default {
        data: () => ({
            valid: true,
            name: '',
            nameRules: [
                v => !!v || 'Name is required',
                v => (v && v.length <= 10) || 'Name must be less than 10 characters',
            ],
            email: '',
            emailRules: [
                v => !!v || 'E-mail is required',
                v => /.+@.+\..+/.test(v) || 'E-mail must be valid',
            ],
            select: null,
            items: [
                'Item 1',
                'Item 2',
                'Item 3',
                'Item 4',
            ],
            checkbox: false,
            lazy: false,
            Portis: null,
            web3: null,
            localNode: {
                nodeUrl: 'http://localhost:11000',
                chainId: 1234,
            }
        }),
        mounted() {
           
        },
        methods: {
            validate() {
                if (this.$refs.form.validate()) {
                    this.snackbar = true
                }
            },
            reset() {
                this.$refs.form.reset()
            },
            resetValidation() {
                this.$refs.form.resetValidation()
            },
        },
    }
</script>
<style>
    v-flex {
        height: 100%;
    }
</style>