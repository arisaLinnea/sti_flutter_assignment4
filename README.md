# sti_flutter_assignment4

Sixth assignment on my Dart/Flutter course at STI

# 1. Start applications

To run this application you will need to add a <span style="color:yellow"> _.env-file_</span> in the root of repo. That file holds some credentials to Firebase.

## 1.1 Admin

- Dependancies updated with `flutter pub get`.
- This application I have started with `flutter run -d "macOS" ` in /parking_admin root.
  (It's been tested in Mac OS Desktop simulator).

## 1.2 User

- Dependancies updated with `flutter pub get`.
- This application I have started with `flutter run -d "IPhone 16"` in /parking_user root.
  (It's been tested in IPhone 16 simulator.)

# 2. Features

- Implementation of notification using `flutter_local_notifications`.
- 4 actions for the notifications (see more under 2.2 New features)
- Added a modal for choosing new endtime for parking. It's visible on the parking overview.
- A check is added so that active parkings that ends while the user uses the app will move to ended parkings

## 2.1 Admin

- Login (but not synced with any account in database)
- See, add, remove and update parking spaces
- See active and ended/inactive parkings
- See most popular parking lots
- See total earnings from ended parkings
- Switch between dark and light mode

New feaures

- No new features

## 2.2 User

- Login with email and password (Firebase auth)
- Registration of new customers
- Switch between dark and light mode
- See, add, update and delete vehicles registered to the logged in user.
- See all free parkings lots
- See, add and update (set endTime to now) to parkings for logged in user.
- See users ended parkings

New features

- Set endtime (from now) on the parking overview
- Possibility to add a notification, you can set time yourself.
- Can remove/cancel a notification
- When a parking is ended, notifications for that parking id is removed from the list
- 4 actions possible on the notifications
  - Add 1 minute to the parking endtime (will also trigger a new notification that will trigger 45s before endtime)
  - Add 20 minutes to the parking endtime (will also trigger a new notification that will trigger 45s before endtime)
  - Change displaytime on notification, so it will trigger again when it's 15s left of the parking
  - Add a custom text to notificatiom, that will trigger when it's 15s left of the parking.

# 3. Known limitations

NEW

- The notifications in action are triggered at very strange interval (45s and 15s before parking ends.) That is probably something you would change if it was to be used for real in some way. But for demo purpose it works good.
- The action to add 1 minut to the parking endtime is also very unrealistic.
- None of the notifications takes into considuration how long time is left on the parking.
- No control that you can't park the same car on two different places

OLD

- Have implemented some realtime updates, but only on first level. For example if the price of a parking lot is changed, it will (hopefully) update the parking lot list, however a parking that contains a parking lot will not be effected.
- Better hanling of removing objects that is being used elsewhere. For example if you remove a parking lot but someone has a parking there. Might be a good idea to add a check that you can't remove a parking lot in an active parking. (But since you also want to display ended parking, there might be hard to find a solution that works for every situation)
- Lacks some responsive features
