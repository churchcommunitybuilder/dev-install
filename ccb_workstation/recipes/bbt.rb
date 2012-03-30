node.override["rvm"]["rubies"] = { "ruby-1.9.2-p180" => { :command_line_options => "--with-gcc=clang" } }

include_recipe "ccb_workstation::rvm"

# node["rvm"]["rubies"].each do |ruby_version_string, options|
#   rvm_ruby_install(ruby_version_string,options)
# end

include_recipe "ccb_workstation::mysql"

directory "#{WS_HOME}/CCB/src" do
  owner WS_USER
  action :create
  recursive true
end

# git "CCB/src/bbt" do
#   repository "git@testdrivesite.beanstalkapp.com:/bbt.git"
#   branch "master"
#   destination "#{WS_HOME}/CCB/src/bbt"
#   action :sync
#   user WS_USER
# end

include_recipe "ccb_workstation::gearman"

remote_file "/tmp/gearman-mysql-udf-#{node[:gearman_mysql_udf][:version]}.tar.gz" do
  source "https://launchpad.net/gearman-mysql-udf-#{node[:gearman_mysql_udf][:version]}.tar.gz"
  checksum node[:gearman_mysql_udf][:checksum]
  notifies :run, "bash[install_gearman-mysql-udf]", :immediately
end

bash "install_gearman-mysql-udf" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    tar -zxf gearman-mysql-udf-#{node[:gearman_mysql_udf][:version]}.tar.gz
    (cd gearman-mysql-udf-#{node[:gearman_mysql_udf][:version]}/ && ./configure --with-mysql=$(brew --prefix mysql)/bin/mysql_config --libdir=$(brew --prefix mysql)/lib/plugin && make && make install)
  EOH
  action :nothing
end

mysql_connection_info = {:host => "localhost", :username => 'root', :password => node[:mysql][:default_root_password]}

mysql_database "create gearman mysql udfs" do
  connection mysql_connection_info
  action :query
  sql <<-SQL
    CREATE FUNCTION gman_do RETURNS STRING
          SONAME "libgearman_mysql_udf.so";
    CREATE FUNCTION gman_do_high RETURNS STRING
          SONAME "libgearman_mysql_udf.so";
    CREATE FUNCTION gman_do_low RETURNS STRING
          SONAME "libgearman_mysql_udf.so";
    CREATE FUNCTION gman_do_background RETURNS STRING
          SONAME "libgearman_mysql_udf.so";
    CREATE FUNCTION gman_do_high_background RETURNS STRING
          SONAME "libgearman_mysql_udf.so";
    CREATE FUNCTION gman_do_low_background RETURNS STRING
          SONAME "libgearman_mysql_udf.so";
    CREATE AGGREGATE FUNCTION gman_sum RETURNS INTEGER
          SONAME "libgearman_mysql_udf.so";
    CREATE FUNCTION gman_servers_set RETURNS STRING
          SONAME "libgearman_mysql_udf.so";
  SQL
end

