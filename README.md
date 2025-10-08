# PartyBar

PartyBar Flutter project - A cocktail management application with Flutter mobile app and Nuxt admin panel.

## Project Structure

- `/lib` - Flutter mobile application
- `/admin` - Nuxt.js admin panel
- `/functions` - Firebase Cloud Functions (Node.js)
- `/android` - Android native code
- `/ios` - iOS native code

## Getting Started

### Prerequisites

- Flutter SDK
- Node.js 22
- Firebase CLI
- gcloud CLI

### Firebase Cloud Functions Setup

This project uses Firebase Cloud Functions Gen 2, which run on Cloud Run. After deploying functions, you **must** configure IAM permissions to allow invocation.

#### ⚠️ Important: Cloud Run IAM Configuration

Firebase callable functions (`onCall`) require the underlying Cloud Run services to allow public invocation, even though authentication is handled at the application level via Firebase Auth.

**After deploying functions, run this command to configure IAM permissions:**

```bash
# Set invoker permissions for all Cloud Run services
for service in createcocktail createequipment deletecocktail deleteequipment deleteingredient generatecocktail getallcocktails getallequipment getallingredients getcocktail getcocktailcategories getcocktailsbycategory getequipment getingredient getingredientcategories getingredientsbycategory updatecocktail updateequipment updateingredient uploadstoragefiles; do
  gcloud run services add-iam-policy-binding $service \
    --region=us-central1 \
    --member="allUsers" \
    --role="roles/run.invoker" \
    --quiet
done
```

**Why is this needed?**
- Cloud Functions Gen 2 run on Cloud Run, which has its own IAM layer
- Without public invoker permission, requests are rejected before reaching your function
- This rejection appears as a CORS error (even though it's an IAM issue)
- Firebase Auth still protects your functions via `request.auth` checks in code

**When to run this:**
- After initial deployment
- After deploying new functions
- If you get CORS errors when calling functions from localhost or deployed domains

### Deploying Functions

```bash
cd functions
pnpm install
pnpm run build
firebase deploy --only functions
# Then run the IAM configuration command above
```

### Running the Admin Panel

```bash
cd admin
pnpm install
pnpm dev
```

### Running the Flutter App

```bash
flutter pub get
flutter run
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Cloud Functions](https://firebase.google.com/docs/functions)
- [Nuxt.js Documentation](https://nuxt.com/)
