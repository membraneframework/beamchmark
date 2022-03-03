[__DIR__, "support", "*.exs"]
|> Path.join()
|> Path.wildcard()
|> Enum.each(&Code.require_file/1)

Mix.shell(Mix.Shell.Quiet)

ExUnit.start()
