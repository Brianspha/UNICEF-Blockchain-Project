<template>
  <v-app id="inspire">
    <v-layout align-center justify-center row fill-height>
      <v-container grid-list-md style="height:1024px" fluid>
        <v-toolbar color="#7EC0EE">
          <v-toolbar-title>Activity</v-toolbar-title>
          <v-spacer></v-spacer>
        </v-toolbar>
        <v-layout>
          <v-flex>
            <v-card>
              <v-layout align-center row fill-height wrap>
                <v-flex xs4 v-ripple v-for="(i,index) in 9">
                  <v-hover v-slot:default="{ hover }" close-delay="200">
                    <v-card :elevation="hover ? 16 : 2" class="mx-auto" height="200">
                      <v-layout align-center justify-center column fill-height>
                        <b>Update</b> <br>
                        School Name: {{n}} <br> From: {{n}} Mpbs <br> To: {{n}} Mpbs <br> by ISP
                        Name: {{n}}
                      </v-layout>
                    </v-card>
                  </v-hover>
                </v-flex>
              </v-layout>
            </v-card>
          </v-flex>
        </v-layout>
      </v-container>
    </v-layout>
  </v-app>
</template>

<script>
  export default {
    data() {
      return {
        UNICEFContract: null,
        web3: null,
        activity: []
      }
    }
  }
</script>