# The Internet
=======

An example application that captures prominent and ugly functionality found on the web. Perfect for writing automated acceptance tests against.

Deployed and available at [https://the-internet.herokuapp.com](https://the-internet.herokuapp.com). What changed in each release is in [changelog.md](changelog.md).

The-internet is now wholly owned by Sauce Labs Inc.!

## Available Examples:

+ [A/B Testing](https://the-internet.herokuapp.com/abtest)
+ [Add/Remove Elements](https://the-internet.herokuapp.com/add_remove_elements/)
+ [Basic Auth](https://the-internet.herokuapp.com/basic_auth) (user and pass: admin)
+ [Broken Images](https://the-internet.herokuapp.com/broken_images)
+ [Canvas](https://the-internet.herokuapp.com/canvas)
+ [Challenging DOM](https://the-internet.herokuapp.com/challenging_dom)
+ [Checkboxes](https://the-internet.herokuapp.com/checkboxes)
+ [Context Menu](https://the-internet.herokuapp.com/context_menu)
+ [Digest Authentication](https://the-internet.herokuapp.com/digest_auth) (user and pass: admin)
+ [Disappearing Elements](https://the-internet.herokuapp.com/disappearing_elements)
+ [Drag and Drop](https://the-internet.herokuapp.com/drag_and_drop)
+ [Dropdown](https://the-internet.herokuapp.com/dropdown)
+ [Dynamic Content](https://the-internet.herokuapp.com/dynamic_content)
+ [Dynamic Controls](https://the-internet.herokuapp.com/dynamic_controls)
+ [Dynamic Loading](https://the-internet.herokuapp.com/dynamic_loading)
+ [Entry Ad](https://the-internet.herokuapp.com/entry_ad)
+ [Exit Intent](https://the-internet.herokuapp.com/exit_intent)
+ [File Download](https://the-internet.herokuapp.com/download)
+ [File Upload](https://the-internet.herokuapp.com/upload)
+ [Floating Menu](https://the-internet.herokuapp.com/floating_menu)
+ [Forgot Password](https://the-internet.herokuapp.com/forgot_password)
+ [Form Authentication](https://the-internet.herokuapp.com/login)
+ [Frames](https://the-internet.herokuapp.com/frames)
+ [Geolocation](https://the-internet.herokuapp.com/geolocation)
+ [Horizontal Slider](https://the-internet.herokuapp.com/horizontal_slider)
+ [Hovers](https://the-internet.herokuapp.com/hovers)
+ [Infinite Scroll](https://the-internet.herokuapp.com/infinite_scroll)
+ [Inputs](https://the-internet.herokuapp.com/inputs)
+ [JQuery UI Menus](https://the-internet.herokuapp.com/jqueryui/menu)
+ [JavaScript Alerts](https://the-internet.herokuapp.com/javascript_alerts)
+ [JavaScript onload event error](https://the-internet.herokuapp.com/javascript_error)
+ [Key Presses](https://the-internet.herokuapp.com/key_presses)
+ [Large & Deep DOM](https://the-internet.herokuapp.com/large)
+ [Large Form](https://the-internet.herokuapp.com/large_form)
+ [Multiple Select Dropdown](https://the-internet.herokuapp.com/multiple_dropdown)
+ [Multiple Windows](https://the-internet.herokuapp.com/windows)
+ [Nested Frames](https://the-internet.herokuapp.com/nested_frames)
+ [Notification Messages](https://the-internet.herokuapp.com/notification_message)
+ [Radio Buttons](https://the-internet.herokuapp.com/radio_buttons)
+ [Read-only Inputs](https://the-internet.herokuapp.com/readonly)
+ [Redirect Link](https://the-internet.herokuapp.com/redirector)
+ [Secure File Download](https://the-internet.herokuapp.com/download_secure)
+ [Shadow DOM](https://the-internet.herokuapp.com/shadowdom)
+ [Shifting Content](https://the-internet.herokuapp.com/shifting_content)
+ [Slow Resources](https://the-internet.herokuapp.com/slow)
+ [Sortable Data Tables](https://the-internet.herokuapp.com/tables)
+ [Status Codes](https://the-internet.herokuapp.com/status_codes)
+ [Subdirectories](https://the-internet.herokuapp.com/subdirectories)
+ [Two-Factor Login](https://the-internet.herokuapp.com/two_factor) (user: tomsmith / pass: SuperSecretPassword!)
+ [Typos](https://the-internet.herokuapp.com/typos)
+ [WYSIWYG Editor](https://the-internet.herokuapp.com/tinymce)


### Pages reached from the examples

+ [A/B Test Cookies](https://the-internet.herokuapp.com/abtest_cookies) and [A/B Test Manual](https://the-internet.herokuapp.com/abtest_manual) (unfinished A/B Testing variants)
+ [Add/Remove Elements with N buttons](https://the-internet.herokuapp.com/add_remove_elements/3) (`/add_remove_elements/:number`)
+ [Basic Auth with a trailing slash](https://the-internet.herokuapp.com/basic_auth/)
+ [Dynamic Loading Example 1](https://the-internet.herokuapp.com/dynamic_loading/1) and [Example 2](https://the-internet.herokuapp.com/dynamic_loading/2)
+ [Email Sent](https://the-internet.herokuapp.com/email_sent) (after Forgot Password)
+ File downloads: `/download/:filename`, `/download_secure/:filename` and `/download/jqueryui/menu/:filename`
+ Frames: [iFrame](https://the-internet.herokuapp.com/iframe), [top](https://the-internet.herokuapp.com/frame_top), [left](https://the-internet.herokuapp.com/frame_left), [middle](https://the-internet.herokuapp.com/frame_middle), [right](https://the-internet.herokuapp.com/frame_right), [bottom](https://the-internet.herokuapp.com/frame_bottom)
+ [Infinite Scroll page N](https://the-internet.herokuapp.com/infinite_scroll/2) (`/infinite_scroll/:number`)
+ [JQuery UI](https://the-internet.herokuapp.com/jqueryui) (linked from JQuery UI Menus)
+ [Large & Deep DOM with N levels](https://the-internet.herokuapp.com/large/3) (`/large/:level`)
+ [Multiple Windows: new window](https://the-internet.herokuapp.com/windows/new)
+ [Notification Message (rendered)](https://the-internet.herokuapp.com/notification_message_rendered)
+ [Redirect](https://the-internet.herokuapp.com/redirect) (from Redirect Link)
+ [Secure Area](https://the-internet.herokuapp.com/secure) and [Logout](https://the-internet.herokuapp.com/logout) (after Form Authentication)
+ Shifting Content: [Menu](https://the-internet.herokuapp.com/shifting_content/menu), [Image](https://the-internet.herokuapp.com/shifting_content/image), [List](https://the-internet.herokuapp.com/shifting_content/list)
+ [Slow external resource](https://the-internet.herokuapp.com/slow_external) (used by Slow Resources; takes 30 seconds)
+ [Status code pages](https://the-internet.herokuapp.com/status_codes/404) (`/status_codes/:code`)
+ [Subdirectory One](https://the-internet.herokuapp.com/subdirectories/one) and [Two](https://the-internet.herokuapp.com/subdirectories/two)
+ Two-Factor Login: code page (`/two_factor/code`) and secure area (`/two_factor/secure`), after logging in

Don't see an example you need or think should be here? Contribute!

## Contribution Guidelines

tldr;

1. Fork
2. Build Something
3. Submit a Pull Request
4. High Five!

## Getting Started

Install Ruby (version in `.ruby-version`) and your dependencies:

    bundle install

Start the server:

    rackup

Load the page you want to see in your browser:

    http://localhost:9292/url_path

Or run it with Docker:

    docker build -t the-internet .
    docker run -p 5000:5000 the-internet

Then open http://localhost:5000.

## Tests

Run the HTTP contract suite (boots the app and checks every example):

    bundle exec rake contract

Run the browser suite (Selenium, headless Chrome by default):

    bundle exec rake e2e
    BROWSER=firefox HEADLESS=false bundle exec rake e2e

Or on Sauce Labs (set `SAUCE_USERNAME` and `SAUCE_ACCESS_KEY`):

    TARGET=saucelabs BROWSER=safari BASE_URL=https://the-internet.herokuapp.com bundle exec rspec spec/e2e

## Deploying and Releasing

Every merged pull request is a release:

1. In the pull request, bump `VERSION` and add a matching entry at the top of `changelog.md`. CI checks both.
2. Once it's merged, CI deploys `main` to Heroku and then tags the commit with the version (e.g. `0.61.0`, no `v` prefix).
