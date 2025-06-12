CREATE PROGRAM dbc_startup:dba
 SET dictcache = 100
 SET isodbc = true WITH persist
 SET dbg = cnvtupper( $1)
 IF (((dbg="Y") OR (dbg="DEBUG")) )
  SET trace = callecho
 ENDIF
 CALL echo("*** Begin dbc_startup ***")
 SET trace = server
 SET trace = noflush
 CALL echo(concat("turning range cache on, setting to:",cnvtstring(dictcache)))
 SET trace rangecache value(dictcache)
 IF (dbg="DEBUG")
  CALL echo("FULL DEBUG LOGGING ENABLED")
  SET trace = timer
  SET trace = noshowuar
  SET trace = noshowuarpar
  SET trace = noshowuarpar2
  SET trace = notest
  SET trace = echoinput
  SET trace = rdbdebug
  SET trace = rdbplan
 ELSE
  SET trace = notest
  SET trace = noechoinput
 ENDIF
 CALL echo("*** End dbc_startup *** ")
END GO
