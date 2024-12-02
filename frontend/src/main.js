import { createApp } from 'vue'
import './style.css'
import App from './App.vue'
import { createRouter, createWebHashHistory } from 'vue-router'
import Home from './pages/Home.vue'
import Menu from './pages/Menu.vue'
import Diners from './pages/Diners.vue'
import Pay from './pages/Pay.vue'
import Orders from './pages/Orders.vue'
import Profile from './pages/Profile.vue'
import Kitchen from './pages/Kitchen.vue'
import Management from './pages/Management.vue'
import PasswordReset from './pages/PasswordReset.vue'
import Reservations from './pages/Reservations.vue'

const router = createRouter({
    history: createWebHashHistory(),
    routes: [
        { path: '/', component: Home },
        { path: '/menu', component: Menu },
        { path: '/orders', component: Orders },
        { path: '/profile', component: Profile },
        { path: '/diners', component: Diners },
        { path: '/pay', component: Pay },
        { path: '/reset-password', component: PasswordReset },
        { path: '/:notFound(.*)', redirect: '/' },
        { path: '/reservations', component: Reservations, meta: { requiresPermission: 2 } },
        { path: '/kitchen', component: Kitchen, meta: { requiresPermission: 2 } },
        { path: '/management', component: Management, meta: { requiresPermission: 2 } },
    ],
})

const getLoggedInUserFromCookie = () => {
    // Return null if no user cookie is found
    if (!document.cookie.split(';').some((item) => item.trim().startsWith('user='))) {
        return null;
    }
    const cookie = document.cookie
        .split('; ')
        .find(row => row.startsWith('user='))
        .split('=')[1];
    console.log(cookie ? JSON.parse(decodeURIComponent(cookie)) : null);
    return cookie ? JSON.parse(decodeURIComponent(cookie)) : null;
};

const user = getLoggedInUserFromCookie();

router.beforeEach((to, from, next) => {
    console.log('Navigating to:', to.path); // Log the destination path
    console.log('User permission level:', user ? user.PermissionLevel : 'No user');
    if (to.meta.requiresPermission) {
        if (user && user.PermissionLevel === to.meta.requiresPermission) {
            next(); // Allow navigation
        } else {
            next('/'); // Redirect to home if user doesn't have permission
        }
    } else {
        next(); // Proceed if no permission check is required
    }
});


/* import the fontawesome core */
import { library } from '@fortawesome/fontawesome-svg-core'

/* import font awesome icon component */
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'

/* import specific icons */
import { faCaretRight } from '@fortawesome/free-solid-svg-icons'
import { faTableList } from '@fortawesome/free-solid-svg-icons'
import { faClockRotateLeft } from '@fortawesome/free-solid-svg-icons'
import { faCircleInfo } from '@fortawesome/free-solid-svg-icons'
import { faSquarePhone } from '@fortawesome/free-solid-svg-icons'
import { faPlus } from '@fortawesome/free-solid-svg-icons'
import { faMinus } from '@fortawesome/free-solid-svg-icons'
import { faTimes } from '@fortawesome/free-solid-svg-icons'
import { faBaby } from '@fortawesome/free-solid-svg-icons'
import { faPhone } from '@fortawesome/free-solid-svg-icons'
import { faMoneyBill } from '@fortawesome/free-solid-svg-icons'
import { faExclamationTriangle } from '@fortawesome/free-solid-svg-icons'
import { faCheckCircle } from '@fortawesome/free-solid-svg-icons'
import { faBowlFood } from '@fortawesome/free-solid-svg-icons'
import { faCheck } from '@fortawesome/free-solid-svg-icons'
import { faClock } from '@fortawesome/free-solid-svg-icons'
import { faEnvelope } from '@fortawesome/free-solid-svg-icons'
import { faTrashAlt } from '@fortawesome/free-solid-svg-icons'
import { faUser } from '@fortawesome/free-solid-svg-icons'

import { faPizzaSlice } from '@fortawesome/free-solid-svg-icons'
import { faPlateWheat } from '@fortawesome/free-solid-svg-icons'
import { faLeaf } from '@fortawesome/free-solid-svg-icons'
import { faIceCream } from '@fortawesome/free-solid-svg-icons'
import { faMugSaucer } from '@fortawesome/free-solid-svg-icons'

// import fa brands
import { faInstagram } from '@fortawesome/free-brands-svg-icons'

// allergy icons
import { faSeedling } from '@fortawesome/free-solid-svg-icons'


/* add icons to the library */
library.add(faCaretRight)
library.add(faTableList)
library.add(faClockRotateLeft)
library.add(faCircleInfo)
library.add(faSquarePhone)
library.add(faPlus)
library.add(faMinus)
library.add(faTimes)
library.add(faBaby)
library.add(faPhone)
library.add(faMoneyBill)
library.add(faExclamationTriangle)
library.add(faCheckCircle)
library.add(faBowlFood)
library.add(faCheck)
library.add(faClock)
library.add(faEnvelope)
library.add(faInstagram)
library.add(faTrashAlt)
library.add(faUser)
library.add(faPizzaSlice)
library.add(faPlateWheat)
library.add(faLeaf)
library.add(faIceCream)
library.add(faSeedling)
library.add(faMugSaucer)

import PrimeVue from 'primevue/config'
import Aura from '@primevue/themes/aura';
import ToastService from 'primevue/toastservice';

import 'primeicons/primeicons.css'

const app = createApp(App);
app.use(router);
app.use(ToastService);
app.use(PrimeVue, {
    // Default theme configuration
    theme: {
        preset: Aura,
        options: {
            darkModeSelector: false || 'none',
        }
    }
});
app.component('font-awesome-icon', FontAwesomeIcon);
app.mount('#app');
