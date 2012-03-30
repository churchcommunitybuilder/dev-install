class Chef::Recipe
  BREW_CMD = "/usr/local/bin/brew"

  def brew_install(package, opts={})
    include_recipe "ccb_workstation::homebrew"

    if brew_installed?(package) && (brew_outdated?(package) || brew_has_multiple_versions_installed?(package))
      execute "#{BREW_CMD} remove --force #{package} && #{BREW_CMD} install #{package} #{opts[:brew_args]}" do
        user WS_USER
      end
    end

    unless brew_installed?(package)
      execute "#{BREW_CMD} install #{package} #{opts[:brew_args]}" do
        user WS_USER
      end
    end
  end

  def brew_outdated?(package)
    outdated=system("#{BREW_CMD} outdated | grep -q #{package}")
    Chef::Log.debug("#{BREW_CMD} package #{package} " + (outdated ? "IS" : "IS NOT") + " outdated.") 
    outdated
  end

  def brew_installed?(package)
    include_recipe "ccb_workstation::homebrew"

    installed=(system("#{BREW_CMD} list #{package} > /dev/null") || brew_has_multiple_versions_installed?(package))
    Chef::Log.debug("#{BREW_CMD} package #{package} " + (installed ? "IS" : "IS NOT") + " installed.")
    installed
  end
  
  def brew_has_multiple_versions_installed?(package)
    multiple=system("#{BREW_CMD} list #{package} | grep -q '#{package} has multiple installed versions'")
    Chef::Log.debug("#{BREW_CMD} package #{package} " + (multiple ? "HAS" : "does NOT HAVE") + " multiple versions.") 
    multiple
  end

  def brew_remove(package)
    include_recipe "ccb_workstation::homebrew"

    if brew_installed? package
      execute "#{BREW_CMD} remove #{package}" do
        user WS_USER
        command "#{BREW_CMD} remove #{package}"
      end
    end
  end

  def brew_update
    include_recipe "ccb_workstation::homebrew"

    execute "#{BREW_CMD} update" do
      user WS_USER
      command "#{BREW_CMD} update"
    end
  end

  def brew_linkapps
    include_recipe "ccb_workstation::homebrew"

    execute "#{BREW_CMD} linkapps" do
      user WS_USER
      command "#{BREW_CMD} linkapps"
    end
  end
end
