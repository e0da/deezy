module ApplicationHelper
  def app_version
    `git describe --tags --always`.chomp
  end
end
