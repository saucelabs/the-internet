# Every GET page users rely on. Shared by the page and snapshot specs.
#   text:     a string that must appear in the page
#   layout:   rendered inside layout.erb (shared chrome must be present)
#   snapshot: markup is deterministic, so it is compared to snapshots/
PAGES = {
  '/'                              => { text: 'Welcome to the-internet', snapshot: false }, # list changes with examples.csv
  '/abtest'                        => { text: 'No A/B Test' },
  '/abtest_cookies'                => { text: 'A/B Test Cookies' },
  '/abtest_manual'                 => { text: 'A/B Test Manual' },
  '/add_remove_elements/'          => { text: 'Add/Remove Elements' },
  '/broken_images'                 => { text: 'Broken Images' },
  '/challenging_dom'               => { text: 'Challenging DOM', snapshot: false }, # random ids/labels
  '/checkboxes'                    => { text: 'Checkboxes' },
  '/context_menu'                  => { text: 'Context Menu' },
  '/disappearing_elements'         => { text: 'Disappearing Elements', snapshot: false }, # random
  '/download'                      => { text: 'File Downloader', snapshot: false }, # lists uploads
  '/drag_and_drop'                 => { text: 'Drag and Drop' },
  '/dropdown'                      => { text: 'Dropdown List' },
  '/multiple_dropdown'             => { text: 'Multiple Select Dropdown List', unreleased: true },
  '/dynamic_content'               => { text: 'Dynamic Content', snapshot: false }, # random
  '/dynamic_controls'              => { text: 'Dynamic Controls' },
  '/dynamic_loading'               => { text: 'Dynamically Loaded Page Elements' },
  '/dynamic_loading/1'             => { text: 'Example 1: Element on page that is hidden' },
  '/dynamic_loading/2'             => { text: 'Example 2: Element rendered after the fact' },
  '/email_sent'                    => { text: "Your e-mail's been sent!" },
  '/entry_ad'                      => { text: 'Entry Ad' },
  '/exit_intent'                   => { text: 'Exit Intent' },
  '/floating_menu'                 => { text: 'Floating Menu', snapshot: false }, # random lorem
  '/forgot_password'               => { text: 'Forgot Password' },
  '/frames'                        => { text: 'Frames' },
  '/frame_top'                     => { text: '', layout: false },
  '/frame_bottom'                  => { text: 'BOTTOM', layout: false },
  '/frame_left'                    => { text: 'LEFT', layout: false },
  '/frame_middle'                  => { text: 'MIDDLE', layout: false },
  '/frame_right'                   => { text: 'RIGHT', layout: false },
  '/geolocation'                   => { text: 'Geolocation' },
  '/horizontal_slider'             => { text: 'Horizontal Slider' },
  '/hovers'                        => { text: 'Hovers' },
  '/iframe'                        => { text: 'An iFrame containing the TinyMCE WYSIWYG Editor' },
  '/infinite_scroll'               => { text: 'Infinite Scroll' },
  '/inputs'                        => { text: 'Inputs' },
  '/javascript_alerts'             => { text: 'JavaScript Alerts' },
  '/javascript_error'              => { text: 'This page has a JavaScript error in the onload event.', layout: false },
  '/jqueryui'                      => { text: 'JQuery UI' },
  '/jqueryui/menu'                 => { text: 'JQueryUI - Menu' },
  '/key_presses'                   => { text: 'Key Presses' },
  '/large'                         => { text: 'Large & Deep DOM', snapshot: false }, # 700KB; /large/3 covers the template
  '/large/3'                       => { text: 'Large & Deep DOM' },
  '/login'                         => { text: 'Login Page' },
  '/nested_frames'                 => { text: 'frame-top', layout: false },
  '/notification_message_rendered' => { text: 'Notification Message' },
  '/redirector'                    => { text: 'Redirection' },
  '/shadowdom'                     => { text: 'Simple template' },
  '/shifting_content'              => { text: 'Shifting Content' },
  '/shifting_content/image'        => { text: 'Shifting Content: Image' },
  '/shifting_content/list'         => { text: 'Shifting Content: List', snapshot: false }, # shuffled
  '/shifting_content/menu'         => { text: 'Shifting Content: Menu Element' },
  '/slow'                          => { text: 'Slow Resources' },
  '/status_codes'                  => { text: 'Status Codes' },
  '/subdirectories'                => { text: 'Subdirectories', unreleased: true },
  '/subdirectories/one'            => { text: 'Subdirectory One', unreleased: true },
  '/subdirectories/two'            => { text: 'Subdirectory Two', unreleased: true },
  '/tables'                        => { text: 'Data Tables' },
  '/tinymce'                       => { text: 'An iFrame containing the TinyMCE WYSIWYG Editor' },
  '/typos'                         => { text: 'Typos', snapshot: false }, # random
  '/windows'                       => { text: 'Opening a new window' },
  '/windows/new'                   => { text: 'New Window', layout: false },
}.freeze

def snapshot_name(path)
  name = path.delete_prefix('/').tr('/', '_').chomp('_')
  name.empty? ? 'index' : name
end
