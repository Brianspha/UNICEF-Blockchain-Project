import Router from 'vue-router'
import Vue from 'vue'
import ViewSchools from '../components/ViewSchools.vue'
import Landing from '../components/Landing.vue'
import RegisteredSchools from '../components/RegisterSchools.vue'

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
        }
    ],
    mode: "history"
})