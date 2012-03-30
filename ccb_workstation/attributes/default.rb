default[:mysql][:default_root_password] = "1337-633k"
default[:mysql][:connection_info] = {
  :host     => "localhost",
  :username => "root",
  :password => node[:mysql][:default_root_password]
}

default[:gearman_mysql_udf] = {
  :version  => "0.5",
  :checksum => "1dbfec2467af4acd72307f22152d121a"
}
