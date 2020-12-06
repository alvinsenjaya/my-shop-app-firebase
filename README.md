# My Shop App

Online shop app mobile application, built using flutter and firebase for authentication and database.

## How to Run in Development

1. Install flutter
2. In /lib/variable.dart file, change your firebase authentication api key and your firebase realtime database url
3. In your firebase realtime database, add the following rules
```
    {
      "rules": {
        "products" : {
              ".indexOn": ["userId"],
          		".read": true,
              ".write": "auth != null",
        			"userId": {
                ".validate": "data.exists() ? data.val() === auth.uid : newData.val() === auth.uid"
              }    
        },
        "carts" : {
              "$uid":{
                ".read": "$uid === auth.uid",
                ".write": "$uid === auth.uid",
                ".indexOn": ["productId"],
              },
            },
        "orders" : {
              "$uid":{
                ".read": "$uid === auth.uid",
                ".write": "$uid === auth.uid",
              },
            },
        "user-favorites" : {
              "$uid":{
                ".read": "$uid === auth.uid",
                ".write": "$uid === auth.uid",
                ".indexOn": ["isFavorite"],
              },
            },
      ".read": false,
      ".write": false,
      },
    }
```
4. In root directory, run this command
`flutter run`

## Snapshot of Application
![My Shop App Snapshot](https://raw.githubusercontent.com/alvinsenjaya/my-shop-app-firebase/master/snapshot.png)

