import { createApp } from 'vue'

// Load tailwind
import './index.css';

// Fake polyfill to make starknet.js work.
window.Buffer = {
    alloc: function() {},
};
window.gsw = true;

import AppAsync from './AppAsync.vue'

createApp(AppAsync).mount('#app')
