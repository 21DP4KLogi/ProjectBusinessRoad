import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

const { resolve } = require('path')

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    vue(),
  ],
  build: {
    rollupOptions: {
      input: {
        index: resolve(__dirname, 'src/index/index.html'),
        //login: resolve(__dirname, 'src/login/index.html'),
        //register: resolve(__dirname, 'src/register/index.html'),
        test: resolve(__dirname, 'src/test/index.html')
      }
    }
  },
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  }
})
