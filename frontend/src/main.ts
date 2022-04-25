import { createApp } from 'vue'

// Load tailwind
import './index.css';

// Fake polyfill to make starknet.js work.
window.Buffer = {
    alloc: function() {},
};
window.gsw = true;

import AppAsync from './AppAsync.vue'

let app = createApp(AppAsync);

// Routing

import { createWebHistory, createRouter } from "vue-router";
const router = createRouter({
    history: createWebHistory(),
    routes: [
        {
            path: "/",
            name: "HomeA",
            component: async () => await import('@/HomeA.vue'),
        },
        {
            path: "/homeB",
            name: "HomeB",
            component: async () => await import('@/HomeB.vue'),
        },
        {
            path: "/game",
            name: "game",
            component: async () => await import('@/GamePage.vue'),
        },
    ]
});
app.use(router);


app.mount('#app')
