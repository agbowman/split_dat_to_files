CREATE PROGRAM crmapp_load_appbar:dba
 CALL echo(
  "This script has been obsoleted and is no longer required. All appbar changes will automatically take place as the user"
  )
 CALL echo(
  "logs off and logs back on. If there is an Operation Job that automatically runs this script please disable the same."
  )
 CALL echo("For more information contact IAC Foundation team.")
END GO
