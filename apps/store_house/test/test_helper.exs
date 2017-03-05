alias StoreHouse.CLI

CLI.create_schema()
:mnesia.start()
CLI.init()
System.at_exit fn _ ->
  :mnesia.stop()
  CLI.delete_schema()
end

ExUnit.start()
