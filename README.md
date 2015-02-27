## Twitter

This is a basic Twitter app to read and compose tweets via the [Twitter API](https://apps.twitter.com/).

Time spent (part 1): `12.5 hours`

Time spent (part 2): `x hours`

### Set up
You must create a config.plist file with the keys `twitterConsumerKey` and `twitterConsumerSecret` with the proper values to access the Twitter API.

### Features - Part 1

#### Required

- [x] User can sign in using OAuth login flow
- [x] User can view last 20 tweets from their home timeline
- [x] The current signed in user will be persisted across restarts
- [x] In the home timeline, user can view tweet with the user profile picture, username, tweet text, and timestamp.
- [x] User can pull to refresh
- [x] User can compose a new tweet by tapping on a compose button.
- [x] User can tap on a tweet to view it, with controls to retweet, favorite, and reply.
- [x] User can retweet, favorite, and reply to the tweet directly from the timeline feed.

#### Optional

- [x] When composing, you should have a countdown in the upper right for the tweet limit.
- [x] After creating a new tweet, a user should be able to view it in the timeline immediately without refetching the timeline from the network.
- [x] Retweeting and favoriting should increment the retweet and favorite count.
- [x] User can unfavorite and decrement favorite count.
- [x] Replies should be prefixed with the username and the reply\_id should be set when posting the tweet.
- [x] User can load more tweets once they reach the bottom of the feed using infinite loading similar to the actual Twitter client.

### Walkthrough

![Video Walkthrough](twitter.gif)

### Features - Part 2

#### Required
- [ ] Hamburger menu
   - [ ] Dragging anywhere in the view should reveal the menu.
   - [ ] The menu should include links to your profile, the home timeline, and the mentions view.
   - [ ] The menu can look similar to the LinkedIn menu below or feel free to take liberty with the UI.
- [ ] Profile page
   - [ ] Contains the user header view
   - [ ] Contains a section with the users basic stats: # tweets, # following, # followers
- [ ] Home Timeline
   - [ ] Tapping on a user image should bring up that user's profile page

#### Optional
- [ ] Profile page
   - [ ] Implement the paging view for the user description.
   - [ ] As the paging view moves, increase the opacity of the background screen. See the actual Twitter app for this effect
   - [ ] Pulling down the profile page should blur and resize the header image.
- [ ] Account switching
   - [ ] Long press on tab bar to bring up Account view with animation
   - [ ] Tap account to switch to
   - [ ] Include a plus button to Add an Account
   - [ ] Swipe to delete an account

### Walkthrough

![Video Walkthrough](...)
