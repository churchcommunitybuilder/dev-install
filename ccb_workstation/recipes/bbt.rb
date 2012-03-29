include_recipe "ccb_workstation::rvm"
include_recipe "ccb_workstation::gearman"
include_recipe "ccb_workstation::mysql"

git "CCB/src/bbt" do
  repository "git@testdrivesite.beanstalkapp.com:/bbt.git"
  branch "master"
  destination "#{WS_HOME}/CCB/src/bbt"
  action :sync
  user WS_USER
end


