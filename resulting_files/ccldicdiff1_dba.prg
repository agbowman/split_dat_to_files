CREATE PROGRAM ccldicdiff1:dba
 PROMPT
  "Enter object type(P): " = "P"
 SELECT INTO "cclcheck1"
  d.object, d.object_name, d.group,
  d.datestamp"#####;rp0", d.timestamp"######;rp0"
  FROM dprotect d
  WHERE (d.object= $1)
   AND d.group=0
  WITH counter, check, noheading
 ;end select
END GO
