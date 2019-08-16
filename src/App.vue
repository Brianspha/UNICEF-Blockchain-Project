<template>
  <v-app id="inspire">
    <v-navigation-drawer v-model="drawer" :clipped="$vuetify.breakpoint.lgAndUp" fixed app>
      <v-list dense>
        <template v-for="item in items">
          <v-layout v-if="item.heading" :key="item.heading" row align-center>
            <v-flex xs6>
              <v-subheader v-if="item.heading">
                {{ item.heading }}
              </v-subheader>
            </v-flex>
          </v-layout>
          <v-list-group v-else-if="item.children" :key="item.text" v-model="item.model"
            :prepend-icon="item.model ? item.icon : item['icon-alt']" append-icon="">
            <template v-slot:activator>
              <v-list-tile v-ripple>
                <v-list-tile-content v-ripple>
                  <v-list-tile-title>
                    {{ item.text }}
                  </v-list-tile-title>
                </v-list-tile-content>
              </v-list-tile>
            </template>
            <v-list-tile v-for="(child, i) in item.children" :key="i" v-ripple>
              <v-list-tile-action v-if="child.render &&child.icon" :to="child.to">
                <v-icon>{{ child.icon }}</v-icon>
              </v-list-tile-action>
              <v-list-tile-content v-if="child.render">
                <v-list-tile-title>
                  {{ child.text }}
                </v-list-tile-title>
              </v-list-tile-content>
            </v-list-tile>
          </v-list-group>
          <v-list-tile :to="item.to" v-else :key="item.text">
            <v-list-tile-action v-if="item.render">
              <v-icon>{{ item.icon }}</v-icon>
            </v-list-tile-action>
            <v-list-tile-content>
              <v-list-tile-title v-if="item.render">
                {{ item.text }}
              </v-list-tile-title>
            </v-list-tile-content>
          </v-list-tile>
        </template>
      </v-list>
    </v-navigation-drawer>
    <v-toolbar :clipped-left="$vuetify.breakpoint.lgAndUp" color="#7EC0EE" light app fixed>
      <v-toolbar-title style="width: 300px" class="ml-0 pl-3">
        <v-toolbar-side-icon @click.stop="drawer = !drawer"></v-toolbar-side-icon>
        <span class="hidden-sm-and-down">XHUMA</span>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-btn icon large>
        <v-avatar size="32px" tile>
          <img height="400px" width="400px" src="http://assets.stickpng.com/thumbs/59b5bc2a6dbe923c39853e02.png">
        </v-avatar>
      </v-btn>
    </v-toolbar>
    <main>
      <v-content>
        <v-container fluid fill-height>
          <v-layout justify-center align-center>
            <v-flex>
              <router-view></router-view>
            </v-flex>
          </v-layout>
          <v-tooltip top>
            <template v-slot:activator="{ on }">
              <v-btn bottom color="sky#7EC0EE" v-ripple dark fab fixed right @click="login()" v-on="on">
                <v-icon>person_add</v-icon>
              </v-btn>
            </template>
            <span>Login/SignUp</span>
          </v-tooltip>
          <v-tooltip top>
            <template v-slot:activator="{ on }">
              <v-btn bottom color="sky#7EC0EE" v-ripple dark fab fixed left @click="about=true" v-on="on">
                <v-icon>info</v-icon>
              </v-btn>
            </template>
            <span>About</span>
          </v-tooltip>
        </v-container>
      </v-content>
    </main>
    <template>
      <div class="text-center">
        <v-dialog v-model="dialog" width="500">
          <v-card>
            <v-card-title>
              <b>Login in to Xhuma</b>
            </v-card-title>
            <v-tabs v-model="tab" color="#7EC0EE" centered dark icons-and-text>
              <v-tabs-slider></v-tabs-slider>
              <v-tab href="#tab-1">
                Login
                <v-icon>donut_large</v-icon>
              </v-tab>
            </v-tabs>
            <v-divider></v-divider>
            <v-tabs-items v-model="tab">

              <v-tab-item value='tab-1'>
                <v-card>
                  <v-form ref="form" v-model="valid" :lazy-validation="lazy">
                    <v-card flat align-center justify-center row fill-height>
                      <v-text-field label="Email" hint="e.g. email@email.com" v-model="email" :rules="emailRules">
                      </v-text-field>
                      <v-checkbox v-model="checkbox" :rules="[v => !!v || 'You must agree to continue!']"
                        label="Do you agree?" required></v-checkbox>
                    </v-card>
                    <v-card-actions>
                      <v-spacer></v-spacer>
                      <v-btn v-ripple color="error" class="mr-4" @click="privateKeyInfo=true">
                        Terms and Conditions
                      </v-btn>
                      <v-btn v-ripple color="success" class="mr-4" @click="validate;login(false)">
                        Login
                      </v-btn>
                      <v-btn v-ripple :disabled="!valid" color="success" class="mr-4" @click="validate;login(true)">
                        Create
                      </v-btn>
                    </v-card-actions>
                  </v-form>
                </v-card>
              </v-tab-item>

            </v-tabs-items>
          </v-card>
        </v-dialog>



        <template>
          <v-layout justify-center>
            <v-dialog v-model="about" persistent max-width="600px">
              <v-card>
                <v-card-title>
                  <span class="headline">About</span>
                </v-card-title>
                <v-card-text>
                  <v-container grid-list-md>
                    <v-layout wrap>
                      Welcome to UNICEF's real-time data visualization! This project is in its alpha version and is a
                      continuous work in progress. The data available does not necessarily represent a complete
                      inventory of a country's school locations and level of Internet connectivity. We are always
                      looking for more partners to validate (and add!) to our existing datasets.<br><br>Please contact
                      the
                      School Mapping team to learn more.

                      Navigating this map:<br><br>This map brings together a wide range of data, including school
                      location and
                      other key attributes as well as information on school Internet connectivity, both in terms of
                      speed (Mbs) and type (2G and 3G). Click on a country to see what information is currently
                      available and on individual dots to find out more details for a particular school.
                      <br><br><br>
                      Note:
                      Not all data has been independently verified. We also only have partial data for some countries
                      and are looking for your help to continue filling out this map. </v-layout>
                  </v-container>
                </v-card-text>
                <v-card-actions>
                  <v-spacer></v-spacer>
                  <v-btn color="#7EC0EE" text @click="about = false">Close</v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </v-layout>
        </template>
      </div>
    </template>
    <loading :active.sync="isLoading" :can-cancel="false" :is-full-page="fullPage">
    </loading>
  </v-app>
</template>

<script>
  import Loading from 'vue-loading-overlay';

  import Portis from "@portis/web3";
  import Web3 from 'web3';
  import EmbarkJS from "../embarkArtifacts/embarkjs";
  import Swal from 'sweetalert2'
  import SecureLS from 'secure-ls'
  import {
    setInterval,
    clearInterval
  } from 'timers';
  export default {
    components: {
      Loading
    },
    data() {
      return {
        fullPage: true,
        email: '',
        lazy: false,
        emailRules: [
          v => !!v || 'E-mail is required',
          v => /.+@.+\..+/.test(v) || 'User E-mail must be valid',
        ],
        dialog: false,
        drawer: null,
        fullPage: true,
        isLoading: false,
        items: [{
            icon: 'find_in_page',
            text: 'View Connected Schools',
            to: "/Landing",
            render: true
          },
          {
            icon: 'compare_arrows',
            text: 'View Updates',
            to: "/ActivityView",
            render: true
          }
        ],
        Portis: null,
        web3: null,
        localNode: {
          nodeUrl: 'http://localhost:11000',
          chainId: 1234,
        },
        loggedIn: false,
        SecureLS: new SecureLS(),
        tab: null,
        loginRequest: false,
        valid: true,
        privateKeyInfo: false,
        about: false,
        UNICEFContract: false,
        checkbox: false,
        Web3: web3,
      }
    },
    mounted() {
      this.init()
      this.watchForAccountChanges()

      //     })
    },
    props: {
      source: String
    },
    beforeMount() {
      this.checkUserType();
    },
    methods: {
      validate() {
        if (this.$refs.form.validate()) {
          this.snackbar = true
        } else {

        }
      },
      init() {
        console.log(EmbarkJS.Providers)
        EmbarkJS.onReady((err) => {
          console.log(EmbarkJS)
          this.UNICEFContract = require('../embarkArtifacts/contracts/UNICEF')
          this.about = true
        })
      },
      checkUserType() {

      },
      watchForAccountChanges() {
        let tempThis = this
        window.ethereum.on('accountsChanged', function (accounts) {
          location.reload()
        })
        window.ethereum.on('networkChanged', function (netId) {
          location.reload()
        })
        window.ethereum.on('networkChanged', function (netId) {
          location.reload()
        })
      },
      errorWithFooter(footerMessage, text) {
        Swal.fire({
          type: 'error',
          title: 'OH Noo',
          text: text,
          footer: footerMessage
        })
      },
      error(message) {
        Swal.fire({
          type: 'error',
          title: 'Oops...',
          text: message,
          allowOutsideClick: true
        })
      },
      success(message) {
        this.$snotify.success(message, {
          timeout: 2000,
          showProgressBar: false,
          closeOnClick: false,
          pauseOnHover: true
        })
      },
      registerUser(email) {

      },
      login() {
        if (!this.loginRequest) {
          this.loginRequest = true
          let This = this
          this.UNICEFContract.methods.userExists().call({
            gas: 8000000
          }).then((exists, err) => {
            if (!exists) {
              Swal.fire({
                title: 'Seems like your not registered',
                text: "Would you like to register?\nEnter your email below",
                input: 'text',
                type: 'error',
                inputAttributes: {
                  autocapitalize: 'off'
                },
                allowOutsideClick: false,
                showLoaderOnConfirm: true,
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Yes, register',
                preConfirm: async (email) => {
                  console.log(/.+@.+\..+/.test(email))
                  if (!/.+@.+\..+/.test(email)) {
                    return "error"
                  } else {
                    return "sending"
                  }
                }
              }).then((result) => {
                console.log("results: ", result)
                if (result.value === "error") {
                  This.error('Invalid user email')
                } else {
                  This.isLoading = true
                  This.UNICEFContract.methods.registerUser(web3.utils.fromAscii(result.value)).send({
                      gas: 8000000
                    }).then((receipt, err) => {
                      if (receipt) {
                        This.success('Successfully registered')
                        This.loadMenu()
                      } else {
                        console.log(err)
                      }
                      This.isLoading = false
                    })
                    .catch((err) => {
                      console.log(err)
                      This.error('Something went wrong whilst trying to register you')
                      This.isLoading = false
                    })
                }
              }).catch((err) => {
                This.error('Something went wrong')
              })
            } else {
              this.loadMenu()
            }
          }).catch((err) => {})
        } else {
          location.replace("/")
        }
      },
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
      },
      loadMenu() {
        var toPush = [{
          icon: 'person_pin',
          text: 'Profile View',
          to: "/ProfileView",
          render: true
        }]
        toPush.forEach(menuItem => {
          this.items.push(menuItem)
        });
      }

    }
  }
</script>