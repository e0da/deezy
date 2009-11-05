# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def select_scope
    select 'entry', 'scope', Entry.find(:all, :group => 'scope').map {|e| [e.scope,e.scope]}
  end
end
