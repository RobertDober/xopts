defmodule Support.GroupedOpts do
  
  use XOpts

  option :leex, :boolean, :group, :parser
  option :recursive, :boolean, :group, :parser
  option :regex, :boolean, :group, :parser
  group_option :all, for: :parser

end
