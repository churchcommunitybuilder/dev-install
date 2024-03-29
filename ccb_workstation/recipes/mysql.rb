#http://solutions.treypiepmeier.com/2010/02/28/installing-mysql-on-snow-leopard-using-homebrew/
require 'pathname'

include_recipe "ccb_workstation::homebrew"

directory "#{WS_LIBRARY}/LaunchAgents" do
  owner WS_USER
  action :create
end

brew_install("mysql")

active_mysql = Pathname.new("/usr/local/bin/mysql").realpath

ruby_block "copy mysql plist to ~/Library/LaunchAgents" do
  block do
    plist_location = (active_mysql + "../../"+"homebrew.mxcl.mysql.plist").to_s
    destination = "#{WS_LIBRARY}/LaunchAgents/homebrew.mxcl.mysql.plist"
    system("cp #{plist_location} #{destination} && chown #{WS_USER} #{destination}") || raise("Couldn't find the plist")
  end
end

ruby_block "mysql_install_db" do
  block do
    basedir = (active_mysql + "../../").to_s
    data_dir = "/usr/local/var/mysql"
    system("mysql_install_db --verbose --user=#{WS_USER} --basedir=#{basedir} --datadir=#{data_dir} --tmpdir=/tmp && chown #{WS_USER} #{data_dir}") || raise("Failed initializing mysqldb")
  end
  not_if { File.exists?("/usr/local/var/mysql/mysql/user.MYD")}
end

execute "load the mysql plist into the mac daemon startup thing" do
  command "launchctl load -w #{WS_LIBRARY}/LaunchAgents/homebrew.mxcl.mysql.plist"
  user WS_USER
  not_if "launchctl list com.mysql.mysqld"
end

ruby_block "Checking that mysql is running" do
  block do
    Timeout::timeout(60) do
      until system("ls /tmp/mysql.sock")
        sleep 1
      end
    end
  end
end

execute "set the root password to the default" do
  command "mysqladmin -uroot password #{node[:mysql][:default_root_password]}"
  not_if "mysql -uroot -p#{node[:mysql][:default_root_password]} -e 'show databases'"
end

execute "insert time zone info" do
  command "mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -uroot -p#{node[:mysql][:default_root_password]} mysql"
  not_if "mysql -uroot -p#{node[:mysql][:default_root_password]} -e 'select * from time_zone_name' | grep -q UTC"
end

gem_package "mysql" do
  action :install
end
