CREATE PROGRAM cclrdbdicutil
 PROMPT
  "Mode (1-6) = " = 0,
  "ObjectName = " = "object_name"
 CALL echo(build("CURCCLVER= ",curcclver,
   ": cclrdbdicutil not yet supported for CCL dictionary synch."))
END GO
