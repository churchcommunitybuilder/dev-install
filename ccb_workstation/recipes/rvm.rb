include_recipe "ccb_workstation::bash_profile"

rvm_git_revision_hash  = version_string_for("rvm")

::RVM_HOME = "#{WS_HOME}/.rvm"
::RVM_COMMAND = "#{::RVM_HOME}/bin/rvm"

bash_profile_include("rvm")

run_unless_marker_file_exists(marker_version_string_for("rvm")) do
  directory "#{RVM_HOME}/src/rvm" do
    action :create
    owner WS_USER
    recursive true
  end

  execute "download rvm" do
    command "curl -Lsf http://github.com/wayneeseguin/rvm/tarball/#{rvm_git_revision_hash} | tar xvz -C#{RVM_HOME}/src/rvm --strip 1"
    user WS_USER
  end

  execute "install rvm" do
    cwd "#{RVM_HOME}/src/rvm"
    command "./install"
    user WS_USER
  end

  execute "check rvm" do
    command "#{RVM_COMMAND} --version | grep Wayne"
    user WS_USER
  end

  %w{readline autoconf openssl zlib}.each do |rvm_pkg|
    execute "install rvm pkg: #{rvm_pkg}" do
      command "#{::RVM_COMMAND} pkg install #{rvm_pkg}"
      user WS_USER
    end
  end
end
