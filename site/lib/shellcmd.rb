require 'open3'

class ShellCmdFilter < Nanoc3::Filter
  identifier :shellcmd
  #type :binary

  def run(content, cmd, params={}) #params={ :cmd => "sed s/foo/bar/" })
    Open3.popen3(cmd) do |stdin, stdout, stderr|
      stdin.write(content)
      stdin.close()
      stdout.read()
    end
  end
end
