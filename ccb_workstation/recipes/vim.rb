include_recipe "pivotal_workstation::homebrew"

execute "brew install macvim" do
  user WS_USER
  brew_install "macvim"
  not_if "brew list | grep '^macvim$'"
end

execute "Link MacVim to /Applications" do
  user WS_USER
  command "brew linkapps"
end

ruby_block "test to see if MacVim link worked" do
  block do
    raise "/Applications/MacVim install failed" unless File.exists?("/Applications/MacVim.app")
  end
end

brew_install "ctags"
