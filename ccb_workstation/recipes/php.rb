include_recipe "ccb_workstation::homebrew"

brew_tap "josegonzalez/homebrew-php"

brew_install "gearman-php"
brew_install "imagick-php"
brew_install "mcrypt-php"
brew_install "oauth-php"
brew_install "xdebug-php"

run_unless_marker_file_exists("pear") do
  execute "php install-pear-nozlib.phar" do
    cwd "/usr/lib/php"
  end
end

php_pear "DB" do
  action :install
end

php_pear "timezonedb" do
  action :install
end

phpunit_channel = php_pear_channel "pear.phpunit.de" do
  action :discover
end

php_pear "PHPUnit" do
  preferred_state "beta"
  channel phpunit_channel.channel_name
  action :install
end
