PartyBar App - Screen Structure
🎯 Core App Flow
1. Onboarding & Welcome

Welcome Screen - App introduction, key features overview
Onboarding Slides - How to use (browse cocktails, join parties, create bars)
Permission Requests - Notifications, location (if needed for nearby parties)

2. Main Navigation Screens
Home/Dashboard

Featured cocktails of the day
Quick access to "Join Party" button
Popular cocktail categories
Recent activity (if authenticated)
"Create Party" CTA for hosts

Explore Cocktails

Cocktail Library - Browse all available cocktails (no auth required)
Cocktail Details - Recipe, ingredients, preparation steps, difficulty level
Search & Filter - Search by name, ingredient, type, difficulty
Categories - Classic, Modern, Shots, etc.

My Bars (Requires Authentication)

Personal Cocktail Collections - User's saved favorite cocktails
Create/Edit Bar - Add cocktails to personal collection
Share Bar - Generate shareable links to your cocktail collection

🎉 Party Features
3. Party Management
Host Screens

Create Party - Set party name, select available cocktails from library
Party Setup - Configure party settings, generate join code/QR
Host Dashboard - Active party management

Incoming orders queue
Order notifications
Mark orders as "preparing" → "ready" → "delivered"
Party statistics (orders count, popular drinks)


Edit Party - Modify available cocktails during active party

Guest Screens

Join Party - Enter party code or scan QR code
Party Menu - Browse host's available cocktails
Order Cocktail - Select drink, add special requests/notes
Order Status - Track current order status
Order History - Previous orders from current party session

4. Party Discovery (Future Enhancement)

Nearby Parties - Find public parties in area (optional feature)

👤 User Management
5. Authentication & Profile

Login/Register - Email/phone or social login
Profile Management - Name, avatar, preferences
Settings - Notifications, privacy, app preferences
Order History - Complete history across all parties

6. User Preferences

Dietary Restrictions - Allergies, alcohol preferences
Favorite Ingredients - For personalized recommendations
Notification Settings - Order updates, party invites

🔧 Utility Screens
7. Additional Screens

Help & Support - FAQs, contact support
About - App info, terms, privacy policy
Tutorial - How to create parties, join parties, use features
Feedback - Rate app, report issues

📱 Screen Hierarchy & Navigation
┌─ Onboarding (First Launch)
│
├─ Main App (Bottom Navigation)
│  ├─ 🏠 Home/Dashboard
│  ├─ 🍸 Explore Cocktails
│  │  └─ Cocktail Details
│  │  └─ Search Results
│  ├─ 🎉 Party Hub
│  │  ├─ Join Party
│  │  ├─ Create Party (Auth Required)
│  │  └─ Active Party View
│  ├─ 📚 My Bars (Auth Required)
│  │  ├─ Create/Edit Bar
│  │  └─ Bar Details
│  └─ 👤 Profile (Auth Required)
│     ├─ Settings
│     ├─ Order History
│     └─ Help & Support
│
└─ Authentication Modal
   ├─ Login
   └─ Register
🚀 MVP Priority Levels
Phase 1 (Core MVP)

Welcome/Onboarding
Cocktail Library (no auth browsing)
Cocktail Details
Basic Search
Join Party (guest flow)
Create Party (host flow)
Party management screens
Basic authentication

Phase 2 (Enhanced Features)

Personal Bars creation
Advanced search & filters
Order history
Profile customization
Push notifications

Phase 3 (Future Enhancements)

Social features (share bars)
Party discovery
Advanced analytics for hosts
Integration with recipe APIs
Photo sharing for cocktail presentations

🎨 Key UI Considerations

Guest Priority: Make joining parties and browsing cocktails super intuitive
Host Efficiency: Quick party setup and order management
Visual Appeal: Rich cocktail imagery and clear recipe presentation
Offline Support: Cache frequently viewed cocktails for offline browsing
Quick Actions: Floating action buttons for "Join Party" and "Create Party"
