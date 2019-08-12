import Router from 'vue-router'
import Vue from 'vue'
import ViewSchools from '../components/ViewSchools.vue'
import Landing from '../components/Landing.vue'
import RegisteredSchools from '../components/RegisterSchools.vue'
import RegistrationView from '../components/RegistrationView.vue'
import ProfileView from '../components/ProfileView.vue'
import ActivityView from '../components/ActivityView.vue'

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
        },
        {
            path: '/ProfileView',
            name: 'profileView',
            component: ProfileView
        },
        {
            path: '/ActivityView',
            name: 'activityView',
            component: ActivityView
        }
    ],
    mode: "history"
})