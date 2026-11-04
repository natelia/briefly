require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [ 1400, 1400 ] do |options|
    options.binary = "/usr/bin/chromium" if File.exist?("/usr/bin/chromium")
    options.add_argument "--headless=new"
    options.add_argument "--no-sandbox"
    options.add_argument "--disable-dev-shm-usage"
    options.add_argument "--disable-gpu"
  end
end
