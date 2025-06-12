CREATE PROGRAM ccltranslatelock:dba
 PROMPT
  "Enter file name(CCLTRANCHECK): " = "CCLTRANCHECK",
  "Enter program name to check for translatelock: " = "*"
 SELECT INTO  $1
  FROM dprotect d
  PLAN (d
   WHERE d.object IN ("E", "P")
    AND (d.object_name= $2))
  HEAD REPORT
   cnt = 0
  DETAIL
   IF (cnt > 0
    AND mod(cnt,10000)=0)
    "set trace symbol release go", row + 1, "set trace symbol mark go",
    row + 1
   ENDIF
   "translate into ",  $1
   IF (d.object="E")
    " ekmodule "
   ELSE
    " program "
   ENDIF
   CALL print(check(d.object_name)), ":group", d.group"##;l",
   " with checklock"
   IF (cnt > 0)
    ",append"
   ENDIF
   " go", row + 1
   IF (mod(cnt,2000)=0)
    "call echo(", cnt, ") go",
    row + 1
   ENDIF
   cnt += 1
  WITH counter, noformfeed, maxrow = 1
 ;end select
 CALL compile(build( $1,".dat"))
 CALL echo(build("Output File:", $1,".ccl"))
END GO
