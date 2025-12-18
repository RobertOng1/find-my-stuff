# find-my-stuff

## App Name and Short Description
**FindMyStuff** – Smart Lost &amp; Found Assistant.  
A simple mobile application built with **Flutter** that helps users **report, search, and recover lost or found items** in their community.  
It connects people who lose their belongings with those who find them, making it easier to return lost items responsibly.

## Team Members
- Rayza Indafri Yahya (231402005)  
- Robert Ong (231402023)  
- Muhammad Farras Prasetya (231402047)  
- Nayla Az Zahra (231402050)  
- Louis Claudio (231402068)

## Features
1. **Firebase Authentication**
   Secure login with username/password and Sign In with Google.
2. **Dashboard**
   View list of all lost and found reports posted by community. User can **search using filter**, **chat with Reporter** or **claim** the Found Lost item by submitting a **Proof Form**.
4. **Status**  
   View the status of reported and claimed items. 
5. **Report Lost Item Form**  
   Allows user to report if they had lost an item. When creating a Lost Item Report, require details such as item name, description, category, location, and the image.  
6. **Report Found Item Form**
   Allow user to report if they had found a lost item. When creating a Found Item Report, require details such as item name, description, category, location, and the image. 
7. **Message**  
   Display all messages to improve communication between reporter and claimant.  
8. **Profile**  
   Allow user to change personal information such as profile picture, username, email, and password. User can also view all badges that they have recieved.
9. **Notification**
   In-app and push notification.
   
## Project Description
**Framework:** Flutter  
**Language:** Dart  
**Firebase Services Used:**  
- Firebase Authentication  
- Cloud Firestore 
**Image Storage**: Cloudinary

**Minimum Requirements:**
- Dart SDK: 3.9.2 or higher
- Flutter SDK: 3.35.3 or higher 
- Android SDK: API Level 21 (Android 5.0 Lollipop) or higher

**Permission Required:**
- `android.permission.INTERNET` **REQUIRED**
- `android.permission.POST_NOTIFICATIONS` (Android 13+): **REQUIRED** Allow the app to send push notification.
- `android.permission.CAMERA`: Required when user chooses to capture image when submitting report.
- `android.permission.READ_EXTERNAL_STORAGE` / `READ_MEDIA_IMAGES` (Android 13+): Required when user chooses to upload existing image when submitting report.
- `android.permission.RECORD_AUDIO`: Required when user wants to send voice message.

P.S. Development is ongoing. We will be pushing updates regularly. Stay tuned!
