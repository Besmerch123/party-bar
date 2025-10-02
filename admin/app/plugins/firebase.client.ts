export default defineNuxtPlugin(() => {
  const auth = useFirebaseAuth()
  if (!auth) {
    console.error('Firebase Auth not initialized!')
    return
  }

  // Monitor auth state changes
  auth.onAuthStateChanged((user) => {
    if (user) {
      console.log('User authenticated:', user.email)
    }
  })
})
