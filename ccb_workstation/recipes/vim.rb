brew_install "macvim"

brew_linkapps

ruby_block "test to see if MacVim link worked" do
  block do
    raise "/Applications/MacVim install failed" unless File.exists?("/Applications/MacVim.app")
  end
end
