import { createApp } from 'vue'

// Load tailwind
import './index.css';

// Fake polyfill to make starknet.js work.
window.Buffer = {
    alloc: function() {},
};
window.gsw = true;

import App from './App.vue'

createApp(App).mount('#app')
