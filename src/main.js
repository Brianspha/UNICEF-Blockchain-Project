import Vue from 'vue'
import App from './App.vue'
import Router from './router'
import Vuetify from 'vuetify'
import VueAsyncData from "vue-async-data";
import 'vuetify/dist/vuetify.min.css' // Ensure you are using css-loader
import infiniteScroll from 'vue-infinite-scroll'
import {
  Icon
} from 'leaflet'
import 'leaflet/dist/leaflet.css'
import mapInit from 'highcharts/modules/map'
import addWorldMap from './json/worldmap'
import Highcharts from 'highcharts'
import HighchartsVue from 'highcharts-vue'
import More from 'highcharts/highcharts-more'
import highchartsFunnel from 'highcharts/modules/funnel'

highchartsFunnel(Highcharts);
More(Highcharts)


delete Icon.Default.prototype._getIconUrl;
Icon.Default.mergeOptions({
  iconRetinaUrl: require('leaflet/dist/images/marker-icon-2x.png'),
  iconUrl: require('leaflet/dist/images/marker-icon.png'),
  shadowUrl: require('leaflet/dist/images/marker-shadow.png')
});
mapInit(Highcharts)
addWorldMap(Highcharts)
Vue.use(Highcharts)
Vue.use(HighchartsVue)
Vue.use(infiniteScroll)
Vue.use(VueAsyncData)
Vue.use(Vuetify)
new Vue({
  render: h => h(App),
  router: Router

}).$mount('#app')