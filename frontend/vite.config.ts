import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path';

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => ({
  resolve:{
    alias:{
      '@' : path.resolve(__dirname, './src'),
    },
  },
  build: {
    target: "es2020",
    sourcemap: true,
    minify: mode === "production",
  },
  test: {
    globals: true,
    environment: 'jsdom',
  },
  plugins: [vue()]
}));
