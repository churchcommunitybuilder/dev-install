require 'pathname'

GEARMAN_LAUNCHD_PLIST = "homebrew.mxcl.gearman.plist"

include_recipe "pivotal_workstation::homebrew"

directory "/Users/#{WS_USER}/Library/LaunchAgents" do
  owner WS_USER
  action :create
end

brew_install("gearman")

ruby_block "copy gearman plist to ~/Library/LaunchAgents" do
  block do
    active_mysql = Pathname.new("/usr/local/bin/gearman").realpath
    plist_location = (active_mysql + "../../#{GEARMAN_LAUNCHD_PLIST}").to_s
    destination = "#{WS_HOME}/Library/LaunchAgents/#{GEARMAN_LAUNCHD_PLIST}"
    system("cp #{plist_location} #{destination} && chown #{WS_USER} #{destination}") || raise("Couldn't find the plist")
  end
end

execute "load the gearman plist into the mac daemon startup thing" do
  command "launchctl load -w #{WS_HOME}/Library/LaunchAgents/#{GEARMAN_LAUNCHD_PLIST}"
  user WS_USER
  not_if "launchctl list homebrew.mxcl.gearman"
end

ruby_block "Checking that gearman is running" do
  block do
    Timeout::timeout(60) do
      until %x[gearadmin --status].strip == '.'
        sleep 1
      end
    end
  end
end
