<script setup lang="ts">
import { signInWithPopup, GoogleAuthProvider } from 'firebase/auth'

definePageMeta({
  layout: 'auth'
})

const googleAuthProvider = new GoogleAuthProvider()

const auth = useFirebaseAuth()!
const user = useCurrentUser()
const router = useRouter()
const isLoading = ref(false)
const errorMessage = ref('')

async function signInWithGoogle() {
  isLoading.value = true
  errorMessage.value = ''

  try {
    await signInWithPopup(auth, googleAuthProvider)
    // Auth state change will be handled by the watcher below
  } catch (error) {
    console.error('Sign-in error:', error)
    const err = error as { code?: string, message?: string }

    // Provide user-friendly error messages
    if (err.code === 'auth/popup-closed-by-user') {
      errorMessage.value = 'Sign-in cancelled. Please try again.'
    } else if (err.code === 'auth/popup-blocked') {
      errorMessage.value = 'Popup was blocked by browser. Please allow popups and try again.'
    } else if (err.code === 'auth/operation-not-allowed') {
      errorMessage.value = 'Google Sign-In is not enabled. Please contact support.'
    } else {
      errorMessage.value = err.message || 'Failed to sign in. Please try again.'
    }
    isLoading.value = false
  }
}

// Watch for user authentication changes
watch(user, (newUser) => {
  if (newUser) {
    router.push('/')
  }
})

// Check if already signed in on mount
onMounted(() => {
  if (user.value) {
    router.push('/')
  }
})

const providers = computed(() => [{
  label: 'Google',
  icon: 'i-simple-icons-google',
  onClick: signInWithGoogle,
  loading: isLoading.value
}])
</script>

<template>
  <div class="flex flex-col items-center justify-center gap-4 p-4 h-screen">
    <UPageCard class="w-full max-w-md">
      <UAuthForm
        title="Login"
        description="Use Google account to sign in"
        icon="i-lucide-user"
        :providers="providers"
      />
      <UAlert
        v-if="errorMessage"
        color="error"
        icon="i-lucide-alert-circle"
        :title="errorMessage"
        class="mt-4"
      />
    </UPageCard>
  </div>
</template>
