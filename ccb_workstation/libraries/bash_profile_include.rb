class Chef::Recipe
  def bash_profile_include(bash_file, cookbook="ccb_workstation")
    include_recipe "#{cookbook}::bash_profile"

    template "#{BASH_INCLUDES_SUBDIR}/#{bash_file}.sh" do
      source "bash_profile-#{bash_file}.sh.erb"
      owner WS_USER
      backup false
      mode "0755"
    end
  end
end
