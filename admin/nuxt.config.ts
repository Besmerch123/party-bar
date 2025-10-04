// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  modules: [
    '@nuxt/eslint',
    '@nuxt/ui',
    '@vueuse/nuxt',
    'nuxt-vuefire'
  ],

  ssr: false,

  devtools: {
    enabled: true
  },

  css: ['~/assets/css/main.css'],

  routeRules: {
    '/api/**': {
      cors: true
    }
  },

  compatibilityDate: '2024-07-11',

  eslint: {
    config: {
      stylistic: {
        commaDangle: 'never',
        braceStyle: '1tbs',
        semi: true
      }
    }
  },

  vuefire: {
    auth: {
      enabled: true,
      sessionCookie: false
    },
    config: {
      apiKey: 'AIzaSyAvoHw3eHP8UXyz0xpKKrmlRav1mZc5XLI',
      authDomain: 'party-bar.firebaseapp.com',
      projectId: 'party-bar',
      storageBucket: 'party-bar.firebasestorage.app',
      messagingSenderId: '768164532049',
      appId: '1:768164532049:web:be5756bf63a51a6cf04d70'
    }
  }
})

// const firebaseConfig = {
//   apiKey: "AIzaSyAvoHw3eHP8UXyz0xpKKrmlRav1mZc5XLI",
//   authDomain: "party-bar.firebaseapp.com",
//   projectId: "party-bar",
//   storageBucket: "party-bar.firebasestorage.app",
//   messagingSenderId: "768164532049",
//   appId: "1:768164532049:web:be5756bf63a51a6cf04d70"
// };
