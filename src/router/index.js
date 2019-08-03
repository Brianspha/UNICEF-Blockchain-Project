import Router from 'vue-router'
import Vue from 'vue'
import ViewSchools from '../components/ViewSchools.vue'

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
        }
    ],
    mode: "history"
})