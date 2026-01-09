You are a Firebase security expert

Your task is to think, review the entire codebase, understand the app logic and firebase schema.
Then, you must create 2 files, one firestore database rule and one storage rule that will allow the app to be functional, allow the correct interaction while keeping it secure.
You MUST keep it simple and to safety minimum, don't overengineer

Follow the guidelines

# A Guide to Firebase Security Rules for Firestore & Storage

Welcome\! This guide is your starting point for understanding, writing, and managing security rules for **Cloud Firestore** and **Cloud Storage**. Security is one of the most critical parts of our application, and these rules are the primary defense for our users' data.

-----

## 🛡️ What Are Security Rules & Why Are They Essential?

Firebase allows our app's clients (like a web browser or mobile app) to talk directly to the database and storage. This is fast and efficient, but it means we can't have a traditional server in the middle checking for permissions.

**Firebase Security Rules** fill that gap. They live on Firebase's servers and act as a powerful gatekeeper. Every single time a user tries to read, write, or delete data, Firebase checks the security rules first. If the rules allow the operation, it succeeds. If not, it's rejected.

This is crucial because:

  * **Security is not on the client.** Clients can't be trusted. Our rules provide security that can't be bypassed.
  * **Bugs in the app won't compromise data.** Even if our app has a flaw, the rules will still protect the data on the backend.
  * **Access can be incredibly granular.** We can control access down to a single document or file based on who the user is, what data they're sending, and much more.

-----

## 🔑 Core Concepts & Syntax

The language for Firestore and Storage rules is based on the **Common Expression Language (CEL)**. The structure is simple and declarative.

### The Basic Structure

Every rules file has this fundamental structure:

```
// 1. Specify the rules version (always use '2')
rules_version = '2';

// 2. Declare the service: 'cloud.firestore' or 'firebase.storage'
service cloud.firestore {
  
  // 3. Match the database path
  match /databases/{database}/documents {

    // 4. Match a specific collection or document path
    match /users/{userId} {

      // 5. Allow certain methods if a condition is true
      allow read, write: if <condition>;
    }
  }
}
```

Let's break that down:

  * **`service`**: This declares which Firebase product the rules apply to. You'll use `cloud.firestore` for Firestore and `firebase.storage` for Storage. They must be in separate files.
  * **`match`**: This defines the **path** to the data your rule applies to. It's like defining a URL endpoint. Match statements can be nested to create more specific paths.
  * **`allow`**: This is the actual rule. It specifies which **methods** (`read`, `write`, etc.) are permitted **if** a certain condition is met.

### Path Matching with Wildcards

You rarely want to write a rule for just one specific document. Wildcards let you create rules for patterns of paths.

  * **Single-Segment Wildcard: `{variable}`**
    This matches any single segment of a path (like a single folder or document ID). The matched value is captured in the variable name.

    ```
    // Matches any document in the 'posts' collection
    // e.g., /posts/post_abc, /posts/post_123
    // The actual ID ('post_abc') is stored in the `postId` variable
    match /posts/{postId} { ... }
    ```

  * **Recursive Wildcard: `{variable=**}`**
    This matches any document or file at the current path **and any path nested below it**.

    ```
    // Matches /users/user_123
    // AND /users/user_123/profile_images/image.png
    // AND /users/user_123/some/deeply/nested/doc
    match /users/{userId}/{allUserData=**} { ... }
    ```

    ⚠️ **Use with caution\!** A recursive wildcard can grant broad permissions unintentionally. Always prefer more specific paths when possible.

### Allowed Methods

The `allow` statement grants permission for specific methods.

| Method | Description |
| :--- | :--- |
| **Convenience Methods** | |
| `read` | Grants permission for `get` and `list`. |
| `write` | Grants permission for `create`, `update`, and `delete`. |
| **Standard Methods** | |
| `get` | Reading a single document or file. |
| `list` | Reading a collection or listing files. |
| `create` | Writing a new document or file. |
| `update` | Changing an existing document or file metadata. |
| `delete` | Deleting a document or file. |

**Important Rule Logic**: Rules are evaluated with **`OR`**, not `AND`. If multiple rules match a request, the request is allowed if **any** of them evaluates to true. You cannot grant access at a broad path (e.g., `/users/{userId}`) and then try to restrict it in a more specific, nested path (e.g., `/users/{userId}/privateData`).

-----

## ✍️ Building Conditions: The Logic of Your Rules

The `if <condition>;` part is where the real magic happens. This boolean expression determines if access is granted. You have access to two special variables to help you.

### The `request` Variable

This object contains information about the incoming request from the user. The most important part is `request.auth`.

  * `request.auth`: If the user is signed in with **Firebase Authentication**, this object is populated with their info. If they are not signed in, it is `null`.
      * `request.auth.uid`: The user's unique ID. This is the **most common and reliable way to identify a user.**
      * `request.auth.token`: Contains custom claims if we've set them on a user (e.g., roles like `admin` or `editor`).

### The `resource` Variable

This object represents the data itself.

  * `resource` (in `update` or `delete` rules): Represents the document **as it currently exists** in the database *before* the operation. You can access its fields with `resource.data.fieldName`.
  * `request.resource` (in `create` or `update` rules): Represents the document **as it would be** if the write were allowed. You can access the incoming data with `request.resource.data.fieldName`.

-----

## 🧩 Writing Reusable Logic with Functions

As rules get complex, you'll find yourself repeating the same conditions. Functions let you wrap this logic for reuse and clarity.

  * **Syntax**: `function functionName(args) { return <condition>; }`
  * **Limitations**:
      * Can only contain a single `return` statement.
      * Cannot have loops or call external services.
      * The total call stack depth is limited to 20.

**Example:**

```
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // A function to check if a user is the owner of a document
    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    // A function to check if a post is public
    function isPublic() {
      // 'request.resource' is the data being written
      return request.resource.data.visibility == 'public';
    }

    match /posts/{postId} {
      // Anyone can create a public post if they are logged in
      allow create: if request.auth != null && isPublic();
      
      // Only the owner can update their own post
      allow update: if isOwner(resource.data.authorId);

      // Anyone can read a post
      allow read: if true;
    }
  }
}
```

-----

## 📜 Common Rule Patterns & Examples

Here are some of the most common rule patterns you'll implement.

### 1\. Content-Owner Only

This is the most fundamental security pattern. Only the user who created the data can read or write it. This is perfect for user-specific data like profiles or settings.

```
service cloud.firestore {
  match /databases/{database}/documents {
    // The document path includes the user's ID
    match /users/{userId}/privateData/{docId} {
      // Allow read/write if the requesting user's UID matches the {userId} in the path
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 2\. Mixed Public and Private Access

This allows anyone to read data, but only authenticated owners can modify it. This is great for blog posts, product listings, etc.

```
service cloud.firestore {
  match /databases/{database}/documents {
    match /posts/{postId} {
      // Anyone can read
      allow read: if true;

      // Only the author can create, update, or delete
      // Note: `resource.data` is the existing data
      // `request.resource.data` is the new data being sent
      allow create: if request.auth.uid == request.resource.data.author_uid;
      allow update, delete: if request.auth.uid == resource.data.author_uid;
    }
  }
}
```

### 3\. Role-Based Access (using Custom Claims)

A very powerful pattern where you can assign roles (like `admin` or `editor`) to users via Firebase Authentication Custom Claims.

```
service cloud.firestore {
  match /databases/{database}/documents {
    match /adminContent/{docId} {
      // Check for an 'admin' claim in the user's authentication token
      allow read, write: if request.auth.token.admin == true;
    }
  }
}
```

-----

## ⚠️ Best Practices & Pitfalls to Avoid

  * **NEVER Use Open Rules in Production**: `allow read, write: if true;` means anyone on the internet can steal, modify, or delete your entire database. This is only for the very earliest stages of development, if ever.
  * **Start with Locked Rules**: Always begin with default rules that deny all access (`if false;`) and then explicitly grant access where needed. It's safer to add permissions than to take them away.
  * **Be Explicit with Subcollections**: Rules are **not** inherited. A rule on a collection (e.g., `/users/{userId}`) does **not** automatically apply to its subcollections (e.g., `/users/{userId}/posts`). You must write explicit rules for subcollections.

-----


# Examples

## Denying All Reads
Sometimes you want to store data, but you just don’t want it to be accessed.

Maybe you have sensitive data that you want to persist, but that you don’t want to be accessible via your API. Maybe you didn’t follow the advice in this article and user data is leaking out into places it shouldn’t be and you need to turn off the tap quickly.

Either way there are many legitimate reasons for denying all reads to your database, and luckily, with Firestore rules it is very easy to do.
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read: if false;
    }
  }
}
```

## Denying All Writes
Denying all writes is another thing that you might find yourself wanting to do. Maybe you have written a bunch of articles and manually added them to your Firestore database. You want to display them on your website, but want to make sure that no one can modify or delete them.

Similarly to the above denying all writes is trivial.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow write: if false;
    }
  }
}
```

If you want deny both reading and writing to the database, then the two can be combined like so.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

## Checking if a User is Authenticated
If you don’t want to deny all read and write access to your database, and want users to be able to see, create and change things on your website or app, then you are probably going to want them to be authenticated.

The following Firestore rule example does this by checking that the request being made to your database contains a uid.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: request.auth.uid != null;
    }
  }
}
```

## Checking if a Document Being Accessed Belongs to the Requesting User
Now, using the previous example we made sure that only authenticated users can access our data, but what about if we want to take this one step further?

Often we don’t want to just let all users access all data, but further separate it out, and only let users see their own documents.

To do this in Firestore, when creating documents you should create a userID field and store the creating user’s uid in it. Then, when trying to access that document later on, check to see if the uid in the request matches the user ID that is stored in the resource being accessed.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /petowners/{ownerId} {
      request.auth.uid == resource.data.userId;
    }
  }
}
```

## Checking if a Document Being Created Belongs to the Requesting User
In addition to only letting users see their own data, we only want to let them write data that belongs to their account. Letting users write to other peoples accounts could get us in all sorts of trouble!

This is done in a similar fashion to the example above. The only difference is that instead of checking the resource object’s user id, we check the request.resource object’s one.

The request.resource object is the document that is being sent in the request to your database.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /petowners/{ownerId} {
      request.auth.uid == request.resource.data.userId;
    }
  }
}
```

## Using Functions
You often want to check the same things over and over again. However, writing the rules out every time is a bad idea.

It takes more time than it should, creates superfluous code and is inconvenient, but worst of all, it is a security hazard.

Let’s say that you have a rule that checks whether a user has permission to access a document or not. It is needed in many different places, for read, delete, modify and create rules. You then copy and paste this rule into each place where it is needed.

It works. Fantastic. Right?

No.

Imagine that now, the requirements for accessing a document change and you go through each instance of the rule you copy and pasted and update them. Cumbersome, but you can deal with it.

However, you missed one instance and a user who shouldn’t have access to a document manages to permanently delete it.

Oops.

This is why you should be using functions and keeping your firestore.rules file DRY.

```
rules_version = '2';
service cloud.firestore {
  function userIsAuthenticated() {
    return request.auth.uid != null;
  }
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if userIsAuthenticated();
    }
  }
}
```

As you can probably see, another advantage to functions is that rules become more readable. This is especially important as rule sets get larger and more complicated.

Out of all of these firestore rules examples, this one is the one that you should remember and put into practice!

## Verifying a Value’s Type
One of the great things about Firestore rules is that you can deny the creation or modification of a document, if the value being provided in the request isn’t what you expect it to be.

One way to check for this, is to check for the type of the value. This means that you can check that names are strings, ages are numbers and choices are booleans, for example.

If someone tries to write a value whose type does not match the defined one, it will be denied. Useful for keeping data as clean as possible.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /petowners/{ownerId} {
      allow write: if request.resource.data.name is string &&
                      request.resource.data.email is string;
    }
  }
}
```

## Verifying That a Value Belongs to a List of Values
Another way to check if a value is what you expect, is to check if the value being provided is in a list of values that you have defined.

For example, if you wanted to store the state of email sending, you could define four possible states; ‘sending’, ‘hard-bounced’, ‘soft-bounced’ and ‘received’.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /emails/{emailId} {
      allow write: if request.resource.data.status in ['sending', 'soft-bounce', 'hard-bounce', 'received']
    }
  }
}
```

## Verifying a Value’s Length
Did you know that RFC 2821 defines the maximum length of an email address in MAIL and RCPT commands to be 254 characters?

No?

Well now you do, and you had better enforce this in your database too!

Luckily in situations like this where you want to limit the length of a value, Firestore has your back once again.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /emailaddresses/{emailAddressId} {
      allow write: if request.resource.data.address.size() < 254;
    }
  }
}
```

## Getting a Document From Another Collection
One of the convenient features of relational databases is the existence foreign keys. Being able to link objects together can be very useful at times.

Due to Firestore being a schema-less, document-based database, we don’t have foreign keys in our toolbelt. We can however store IDs of other documents in a field, and then use that to retrieve them in our rules – using get.

For example, below we have two collections; petowners and pets. We want pet owners to only be able to see their own pets.

So, when a request is made to see a pet, we get the owner of it and check that the petowners document belongs to the currently authenticated user.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /pets/{petId} {
      allow read: if get(/databases/$(database)/documents/petowners/$(request.resource.data.ownerId)).data.userId == request.auth.uid
    }
  }
}
```

## Firebase Functions

The Cloud Function code is placed in a special directory named functions inside your main project folder, right alongside your Flutter lib, ios, and android folders.
You create this directory using the Firebase CLI (Command Line Interface).
Your project structure will look like this:

your_flutter_project/
├── lib/         <-- Your Flutter/Dart code for the app lives here
├── ios/
├── android/
│
└── functions/   <-- ✅ Your secure backend code lives here
    ├── node_modules/
    ├── index.js <-- ❗️ You write the function code in THIS file.
    └── package.json

### Step-by-Step: How to Set Up and Write the Function

If you haven't done this before, here are the exact steps.
Step 1: Install the Firebase CLI

firebase login
Initialize the functions service by running:
Bash
firebase init functions
The CLI will ask you a few questions:
Please select an option: Choose "Use an existing project".
Select a default Firebase project: Choose your project from the list.
What language would you like to use? Choose JavaScript.
Do you want to use ESLint...? You can say Yes (Y).
Do you want to install dependencies with npm now? Say Yes (Y).
This process will create the functions directory with the index.js file inside it.
Step 3: Write the Code in index.js
Now, open the newly created functions/index.js file and replace its contents with the secure function code:
JavaScript
// File: functions/index.js

const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize the Admin SDK, which gives the function server-level access
admin.initializeApp();

/**
 * A callable function to securely check if an email exists in Firebase Auth.
 */
exports.checkEmailExists = functions.https.onCall(async (data, context) => {
  const email = data.email;

  // Basic validation
  if (!email || typeof email !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "The function must be called with a valid email."
    );
  }

  try {
    // This uses the Admin SDK to look up a user by email.
    // This is secure and bypasses all security rules.
    const userRecord = await admin.auth().getUserByEmail(email);
    // If the lookup succeeds, the email exists.
    return { exists: true, uid: userRecord.uid };
  } catch (error) {
    if (error.code === "auth/user-not-found") {
      // This is the expected error if the email does not exist.
      return { exists: false };
    }
    // For any other errors, we throw an exception.
    throw new functions.https.HttpsError("internal", error.message);
  }
});
Step 4: Deploy the Function
Finally, go back to your terminal (still at the root of your project) and run the deploy command. This uploads your function to Google's servers and makes it active.
Bash
firebase deploy --only functions
Once the deployment is successful, your Flutter app can call the checkEmailExists function, and your database will remain secure.