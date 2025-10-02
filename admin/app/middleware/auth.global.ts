const publicRoutes = ['/sign-in']

export default defineNuxtRouteMiddleware(async (to) => {
  // Allow access to public routes
  if (publicRoutes.includes(to.path)) {
    return
  }

  // Only run on client side
  if (!import.meta.client) {
    return
  }

  try {
    const user = await getCurrentUser()

    if (!user) {
      return navigateTo('/sign-in')
    }
  } catch (error) {
    console.error('Auth error:', error)
    return navigateTo('/sign-in')
  }
})
