// Firebase Messaging Service Worker for Web Platform
// This file is required for Firebase Cloud Messaging to work on web browsers

// Import Firebase scripts for messaging
importScripts('https://www.gstatic.com/firebasejs/10.13.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.0/firebase-messaging-compat.js');

// Initialize Firebase with your config
// Note: These values should match your Firebase project configuration
const firebaseConfig = {
  apiKey: "AIzaSyBUkGj8CuEWm6PwjRXxS7-Dz1lH3UBL8xQ",
  authDomain: "flutter-basic-project-914ad.firebaseapp.com",
  projectId: "flutter-basic-project-914ad",
  storageBucket: "flutter-basic-project-914ad.firebasestorage.app",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:abcdef1234567890abcdef"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);

// Initialize Firebase Messaging
const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message:', payload);
  
  // Customize notification here
  const notificationTitle = payload.notification?.title || 'New Message';
  const notificationOptions = {
    body: payload.notification?.body || 'You have a new message',
    icon: '/favicon.png', // Path to your app icon
    badge: '/favicon.png'
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});