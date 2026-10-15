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
+ [Multiple Windows](https://the-internet.herokuapp.com/windows)
+ [Nested Frames](https://the-internet.herokuapp.com/nested_frames)
+ [Notification Messages](https://the-internet.herokuapp.com/notification_message)
+ [Redirect Link](https://the-internet.herokuapp.com/redirector)
+ [Secure File Download](https://the-internet.herokuapp.com/download_secure)
+ [Shadow DOM](https://the-internet.herokuapp.com/shadowdom)
+ [Shifting Content](https://the-internet.herokuapp.com/shifting_content)
+ [Slow Resources](https://the-internet.herokuapp.com/slow)
+ [Sortable Data Tables](https://the-internet.herokuapp.com/tables)
+ [Status Codes](https://the-internet.herokuapp.com/status_codes)
+ [Subdirectories](https://the-internet.herokuapp.com/subdirectories)
+ [Typos](https://the-internet.herokuapp.com/typos)
+ [WYSIWYG Editor](https://the-internet.herokuapp.com/tinymce)


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

Every merge to `main` deploys to Heroku once CI passes. Releases are tagged with the version number (e.g. `0.59.0`, no `v` prefix):

1. In a pull request, add an entry to `changelog.md` and bump `VERSION`.
2. Once it's merged, check out `main`, pull, and tag it:

        bundle exec rake release

   This creates an annotated tag named after `VERSION` and pushes it.
