import Router from 'vue-router'
import Vue from 'vue'
import ViewSchools from '../components/ViewSchools.vue'
import Landing from '../components/Landing.vue'

Vue.use(Router)

export default new Router({
    routes: [{
            path: '/',
            component: ViewSchools
        },
        {
            path: '/ViewSchools',
            name: 'connectedschools',
            component: ViewSchools
        },
        {
            path: '/Landing',
            name: 'landing',
            component: Landing
        }
    ],
    mode: "history"
})