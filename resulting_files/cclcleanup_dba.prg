CREATE PROGRAM cclcleanup:dba
 PROMPT
  "DBA Program name to cleanup dups for (*): " = "*"
 DELETE  FROM dprotect d,
   dprotect d2
  SET d2.seq = 1
  PLAN (d
   WHERE d.object="P"
    AND (d.object_name= $1)
    AND 0=d.group)
   JOIN (d2
   WHERE d.object=d2.object
    AND d.object_name=d2.object_name
    AND 0 != d2.group)
  WITH counter
 ;end delete
 DELETE  FROM dcompile d,
   dcompile d2
  SET d2.seq = 1
  PLAN (d
   WHERE d.object="P"
    AND (d.object_name= $1)
    AND 0=d.group
    AND 0=d.qual)
   JOIN (d2
   WHERE d.object=d2.object
    AND d.object_name=d2.object_name
    AND 0 != d2.group)
  WITH counter
 ;end delete
;#end
END GO
