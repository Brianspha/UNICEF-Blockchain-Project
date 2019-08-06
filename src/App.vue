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
              <v-list-tile>
                <v-list-tile-content>
                  <v-list-tile-title>
                    {{ item.text }}
                  </v-list-tile-title>
                </v-list-tile-content>
              </v-list-tile>
            </template>
            <v-list-tile v-for="(child, i) in item.children" :key="i">
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
        <span class="hidden-sm-and-down">UNICEF</span>
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
          <v-btn bottom color="skyblue" dark fab fixed right @click="dialog = !dialog">
            <v-icon>error_outline</v-icon>
          </v-btn>
        </v-container>
      </v-content>
    </main>
  </v-app>
</template>

<script>
  import Swal from 'sweetalert2'
  import {
    setInterval,
    clearInterval
  } from 'timers';
  export default {
    data: () => ({
      drawer: null,
      fullPage: true,
      isLoading: false,
      items: [{
          icon: 'find_in_page',
          text: 'View Connected Schools',
          to: "/ViewSchools",
          render: true
        },
        {
          icon: 'find_in_page',
          text: 'Landing',
          to: "/Landing",
          render: true
        }
      ],
    }),
    mounted() {
      this.watchForAccountChanges()
    },
    props: {
      source: String
    },
    methods: {
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
      }

    }
  }
</script>