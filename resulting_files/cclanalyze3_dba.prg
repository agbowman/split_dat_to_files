CREATE PROGRAM cclanalyze3:dba
 PROMPT
  "Enter file name: " = "cclanalyze",
  "Enter program name to analyze: " = "*"
 SELECT INTO  $1
  FROM dprotect d
  PLAN (d
   WHERE d.object IN ("E", "P")
    AND d.group=0
    AND (d.object_name= $2))
  HEAD REPORT
   cnt = 0
  DETAIL
   "translate into ",  $1
   IF (d.object="E")
    " ekmodule "
   ELSE
    " program "
   ENDIF
   CALL print(check(d.object_name)), ":dba with analyze"
   IF (cnt > 0)
    ",append"
   ENDIF
   " go", row + 1
   IF (mod(cnt,500)=0)
    "call echo(", cnt, ") go",
    row + 1
   ENDIF
   cnt += 1
  WITH counter, noformfeed, maxrow = 1,
   maxcol = 100
 ;end select
 CALL compile(build( $1,".dat"))
END GO
