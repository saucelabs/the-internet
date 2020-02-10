#0.58.0
+ Added /shadowdom example (PR #45)

#0.57.0
+ Added sitemap

#0.56.0
+ Changed /context_menu to fire a JS alert on a context click. Fixes #12
+ Added an input field to the key_presses example, and simplified its JS

#0.55.0
+ Made it so the example on /dropdown dynamically updates the "selected" attribute to the currently selected option

#0.54.0
+ Added an example for digest authentication

#0.53.0
+ Added an example to demonstrate a number input

#0.52.0
+ Added an example to demonstrate a display ad shortly after page load (/entry_ad)
+ Added an example to easily add and remove elements from the page (/add_remove_elements/)

#0.51.0
+ Added an async enable/disable element example to /dynamic_controls

#0.50.1
+ Updates to README.template and README.md

#0.50.0
+ Pulled in PR for Horizontal Slider (thanks [pittgoose](https://github.com/pittgoose)!)

#0.49.5
+ Removed missed dependency that was causing a production outage

#0.49.4
+ Removed unused Gems from Gemfile
+ Specify Ruby version number in Gemfile

#0.49.3
+ Added MIT license to project
+ Cleaned up unused configurations for NewRelic and TravisCI

#0.49.1
+ Added /exit_intent example which triggers a modal dialog when the mouse leaves the viewport window

#0.48.4
+ Fixed broken sorting functionality on /tables

#0.48.3
+ Added footer to all pages with "Power by" info

#0.48.2
+ Added a Rake task to cleanup uploads directory

#0.48.1
+ Fixed a typo on /infinite_scroll
+ Adjusted the duration for the floating menu to follow the user scroll from 400 ms to 1 ms

#0.48.0
+ Added an /infinite_scroll example
+ Added a /floating_menu example

#0.47.1
+ Made it so the last row of /dynamic_content when viewing it in static mode will have a unique image on each page refresh

#0.47.0
+ Updated file upload so you can drag/drop a file from outside of the browser. Updated jQuery in the process, and added jQuery-UI
+ Made it so all of the copy in /shifting_content/list is static, while preserving the dynamic order on page refresh

#0.46.0
+ Added parameter to /dynamic_content that can make some of the list items static
+ Updated parameter copy on /shifting_content/image that tells users how to load a simple image
+ Added a new /shifting_content example with dynamic list data that has a recurring value which persists and moves around

#0.45.1
+ Updated /checkboxes checkbox field text to be more accurate

#0.45.0
+ Updated /checkboxes so it auto updates the markup to denote which checkboxes are checked

#0.44.1
+ Fixed /tables sorting

#0.44.0
+ Updated Font Awesome version and its icon usage in /login

#0.43.1
+ Added /nested_frames back to the examples list

#0.43.0
+ Updated new window example so the page title is more descriptive on the new window that gets loaded

#0.42.0
+ Changed the typo example so the typo appears at the end of the sentence
+ Added a more detailed image for the shifting image example with URL parameter option to display the simpler one instead

#0.41.0
+ Split /shifting_content into a main page with two sub-examples (menu element and images, respectively)
+ Added a new example that demonstrates typos randomly appearing on each page load

#0.40.2
+ Added some semantic markup on the /dynamic_content page to make it easier for targeting individual rows in automated tests.

#0.40.1
+ Fixed a bug in the /shifting_content random example and down-sized it all down to one route that handles all use cases (e.g., normal, random, and specified pixel count). Also added helper text with links to the view

#0.40.0
+ Made is so the number of pixels can be specified in the URL for /shifting_content and /shifting_content/random

#0.39.0
+ Pulled in the pull request for a dynamic controls example

#0.38.4
+ Added a /shifting_content/random to load the shift randomly for simpler automated visual testing

#0.38.3
+ Updated /shifting_content so it alternates the shift on each page load rather than randomly

#0.38.2
+ Changed pixel shifting on /shifting_content from 20 to 25 pixels

#0.38.1
+ Removed pixel specification by URL from /shifting_content
+ Reworked the example in /shifting_content so it leverages a menu bar that has a rogue button from time to time

#0.38.0
+ Updated shifting content so it defaults to 10 pixels, but can be changed in the URL by adding a /number (e.g., /shifting_content/100)
+ Added an example for disappearing/reappearing elements on each page load

#0.37.1
+ Added missing gem to Gemfile
+ Updated buttons on /challenging\_dom so there are fewer and their text changes on each page load

#0.37.0
+ Small copy tweak to /dynamic_content
+ Added body text that shifts by 1 pixel to /shifting_content
+ Added /challenging_dom example

#0.36.1
+ Fixed a small rendering issue on /dynamic_content

#0.36.0
+ Added 2 examples to help aid with automated visual testing.

1. Loads dynamic text and images on each page refresh
2. Renders the page contents off by a few pixels

#0.35.1
+ Added secure file downloads to the examples list

#0.35.0
+ Added an example for broken images

#0.34.0
+ Added an example that demonstrates a slow loading resource

#0.33.3
+ More of the same -- found some more external resources that needed to be brought internally due to latency (CSS and JS files)

#0.33.2
+ Pulled the GitHub ribbon image to the repo to avoid latency issues when running on slow connections

#0.33.1
+ Added a unique ID to the context menu example for easier scoping
+ Also added a note to the context menu example stating that it currently only works in Firefox (and linked to the open issue for it)

#0.33.0
+ Fixed invalid markup per issue #11
+ Added an example for right-click menu additions (a.k.a. context menus)

#0.32.0
+ Added key presses example

#0.31.0
+ Updated upload example to not assume an image was being uploaded. So now it just lists the file that was uploaded.

#0.30.0
+ Reworked /frames so now it is a guide page with links to /nested_frames and /iframe

#0.29.0
+ Added [JQuery Growl](http://ksylvest.github.io/jquery-growl/) to public assets (CSS and JavaScript)

#0.28.2
+ Fixed bogus alt text in /hovers example

#0.28.1
+ Updated /hovers markup to be more semantic

#0.28.0
+ Added hovers example
+ Added /tinymce WYSIWYG Editor example to main list
+ Cleaned up old test harness remnants

#0.27.1
+ Added missing configuration changes needed for newrelic support

#0.27.0
+ Added newrelic coverage for the production app

#0.26.0
+ Added a checkbox example, with one checked and one unchecked

#0.25.3
+ Added more info to the forgot password example email, noting that login could be tested at /login -- and provided credentials

#0.25.2
+ Changed the from e-mail on the forgot password example

#0.25.1
+ Added a forgot password example
+ Skipped 0.25.0 due to a naming conflict

#0.24.2
+ Added missing example (dropdowns) to list of available examples

#0.24.1
+ Updated the readme

#0.24.0
Release date: February 25, 2014

+ Added a drag and drop example

#0.23.0
Release date: January 23, 2014

+ Changed the username and password values in the Login example

#0.22.15
Release date: January 21, 2014

+ Added a class to the table header of the large DOM example

#0.22.14
Release date: January 21, 2014

+ Added more class markup to the siblings in the large DOM example for easier traversing

#0.22.13
Release date: January 21, 2014

+ Added a header to the table in the large DOM example

#0.22.12
Release date: January 21, 2014

+ Added top level markup for each of the large DOM examples

#0.22.11
Release date: January 20, 2014

+ Added a table example and reworked the siblings example (in the large DOM example)

#0.22.10
Release date: January 20, 2014

+ Fixed indenting in the large DOM example so it happens at the correct level for each tier

#0.22.9
Release date: January 20, 2014

+ Fixed a typo in the markup in the large DOM example

#0.22.8
Release date: January 20, 2014

+ Updated more of the large DOM example's markup

#0.22.7
Release date: January 20, 2014

+ Made the IDs unique on the large DOM example

#0.22.6
Release date: January 20, 2014

+ Added markup for the no siblings case in the large DOM example

#0.22.5
Release date: January 20, 2014

+ Updated the siblings example of the large DOM example

#0.22.4
Release date: January 20, 2014

+ Lowered the default nested value to 50 for the large DOM example
+ Also made the large DOM example dynamic by accepting a number for nested levels in the URL ('e.g., /large/100')

#0.22.3
Release date: January 20, 2014

+ Fixed ribbon rendering issues

#0.22.3
Release date: January 20, 2014

+ Reduced the nested levels in the Large & Deep DOM example from 500 to 100 to make it more manageable for browser inspection.
+ Small bit of refactoring in the Large & Deep DOM example to pull out hard coded values into a variable
+ Added 'Fork Me On Github' to every page

#0.22.1
Release date: January 20, 2014

+ Reworked the Large & Deep DOM example to use simple divs instead of a table

#0.22.0
Release date: January 20, 2014

+ Added a Large & Deep DOM example
+ Added 'Fork Me On GitHub' ribbon to homepage

#0.21.2
Release date: December 11, 2013

+ Added helpful CSS selectors around coordinates and the map link

#0.21.1
Release date: December 11, 2013

+ Added a link to Google Maps for the latitude and longitutde on Geolocation

#0.21.0
Release date: December 11, 2013

+ Added Geolocation

#0.20.4
Release date: November 8, 2013

+ Pluralized table example (in name and URL path)

#0.20.1, 0.20.2, 0.20.3
Release date: November 8, 2013

+ Fixed JavaScript errors in IE for the Data Table example

#0.20.0
Release date: November 8, 2013

+ Added a second Data Table that has Class and ID attributes to group like data together

#0.19.0

Release date: November 8, 2013

+ Added an example of a Data Table that is sortable

#0.18.0

Release date: October 25, 2013

+ Broke apart the Dynamic Loading example into 2 examples and a base description page to help account for different automation use cases

#0.17.2

Release date: October 25,2013

+ Changed the method used to hide elements on load in the Dynamic Loading example (from JQuery to CSS) which fixes a small flit of the hidden text when initially rendering the page.


#0.17.1

Release date: October 25, 2013

+ Increased the time to display the loading bar on the Dynamic Loading example from 1 second to 5 seconds


#0.17.0

Release date: October 24, 2013

+ Added available examples with links to the Index page
+ Added a Rake generator to create markdown and HTML versions of examples and their URLs from a central CSV file (sorted alphabetically by title) and inject them where needed
+ Renamed javascript_alert to javascript_alerts since there are multiple examples in one
+ Added a missing view for the Multiple Windows example
+ Added a Dynamic Loading example


#0.16.0

Release date: October 11, 2013

+ Pulled in JavaScript Alerts pull request


#0.15.1

+ Added missing gem to Gemfile (compass)
+ Added Ruby version to Gemfile (1.9.3)


#0.15.0

Release date: September 26, 2013

+ Added form authentication
+ Updated styles
+ Added basic test framework with ckit


#0.14.0

Release date: September 16, 2013

+ Pulled in pull requests from jimevans (Thank you!) for JavaScript onload event errors and redirection.


#0.13.0

Release date: September 14, 2013

+ Added heroku app links to the readme


#0.12.0

Release date: September 14, 2013

+ Added HTTP Status Codes (/status_codes) that is dynamic (/status_codes/200, /status_codes/404, etc.)


#0.11.0

Release date: September 8, 2013

+ Copy tweak on initial A/B test example
+ Added 2 new views for A/B opt-in examples


#0.10.0

Release date: September 3, 2013

+ Secure File Downloads with Basic Auth


#0.9.1

Release date: August 14, 2013

+ Added trailing slash to support to the basic auth URL


#0.9.0

Release date: August 14, 2013

+ Added a basic auth example


#0.8.3 & 0.8.4

Release date: August 13, 2013

+ Changed the heading text of the abtest view to more clearly demonstrate when no A/B test has been set or if an opt-out has occurred


#0.8.2

Release date: August 13, 2013

+ Small text change to the view


#0.8.1

Release date: August 13, 2013

+ Moved the Optimizely Javascript to the proper location (the head tag of the layout)
+ Added helper test to the abtest view


#0.8.0

Release date: August 13, 2013

+ Added an A/B Testing View that works with Optimizely


#0.7.2

Release date July 29, 2013

+ Added an updated NewRelic config yaml file


#0.7.1

Release date July 29, 2013

+ Added NewRelic Monitoring
+ Added a missing refesh link to the notification message view


#0.7.0

Release date July 29, 2013

+ Added notification flash messages
