import Router from 'vue-router'
import Vue from 'vue'
import ViewSchools from '../components/ViewSchools.vue'
import Landing from '../components/Landing.vue'
import RegisteredSchools from '../components/RegisterSchools.vue'
import RegistrationView from '../components/RegistrationView.vue'

Vue.use(Router)

export default new Router({
    routes: [{
            path: '/',
            component: Landing
        },
        {
            path: '/Landing',
            name: 'landing',
            component: Landing
        },
        {
            path: '/RegisterSchools',
            name: 'registerschool',
            component: RegisteredSchools
        },
        {
            path: '/RegistrationView',
            name: 'registrationview',
            component: RegistrationView
        }
    ],
    mode: "history"
})