CREATE PROGRAM ccldic_recompile:dba
 PROMPT
  "Output name(MINE): " = "MINE",
  "Object name(*): " = "*",
  "Display (S)ummary or (R)einclude objects (S): " = "S"
 SET objtype = "P"
 SET outdev = trim(cnvtupper( $1))
 SET objname = trim(cnvtupper( $2))
 SET objmode = cnvtupper( $3)
 SET objcnt = 0
 SELECT INTO "cclcompilechk1.dat"
  brk = concat(p.object,p.object_name,format(p.group,"##;rp0")), p.object, p.object_name,
  p.binary_cnt
  FROM dprotect p,
   dcompile c
  PLAN (p
   WHERE p.object="P"
    AND (p.object_name= $2))
   JOIN (c
   WHERE "P"=c.object
    AND p.object_name=c.object_name
    AND p.group=c.group)
  ORDER BY brk, c.qual
  HEAD REPORT
   line = fillstring(100,"=")
  HEAD brk
   cnt = 0
  DETAIL
   cnt += 1
  FOOT  brk
   IF (p.binary_cnt != cnt)
    col 0, p.object_name, row + 1,
    objcnt += 1
   ENDIF
  WITH counter, outerjoin = p
 ;end select
 IF (objcnt=0)
  CALL echo("No objects qualified for re-include")
  GO TO end_script
 ENDIF
 FREE DEFINE rtl
 DEFINE rtl "cclcompilechk1.dat"
 SELECT INTO "cclcompilechk1.ccl"
  delete1 = concat("delete from dprotect where object=^P^ and object_name= ^",substring(1,30,trim(r
     .line)),"^ go"), delete2 = concat("delete from dcompile where object=^P^ and object_name= ^",
   substring(1,30,trim(r.line)),"^ go"), include1 = concat("call compile(^cclsource:",trim(cnvtlower(
     substring(1,30,r.line))),".prg^) go")
  FROM rtlt r
  DETAIL
   col 0, delete1, row + 1,
   col 0, delete2, row + 1,
   col 0, include1, row + 1
  WITH counter
 ;end select
 IF (objmode="S")
  SELECT INTO outdev
   *
   FROM dummyt
   DETAIL
    col 0, "DICTIONARY ERRORS FOUND", row + 1,
    col 0, "Number of scripts which do not match DPROTECT/COMPILE count: ", col + 1,
    objcnt, row + 1, col 0,
    "File generated= ccluserdir:cclcompilechk1.ccl", row + 1, col 0,
    "Command to reinclude= CALL COMPILE(^ccluserdir:cclcompilechk1.ccl^)", row + 1, row + 1,
    col 0,
    "Rebuild dictionary with bcheck or CCLDICUNIXREORG, then re-execute CCLDIC_RECOMPILE prior to re-include."
   WITH nocounter
  ;end select
 ENDIF
 IF (objmode="R")
  CALL echo("Re-including corrupt scripts: call compile(^ccluserdir:cclcompilechk1.ccl^)")
  CALL compile("ccluserdir:cclcompilechk1.ccl")
 ENDIF
#end_script
END GO
