CREATE PROGRAM cclcompilechk:dba
 PROMPT
  "Output name(MINE)   :" = "MINE",
  "Object type(*)      :" = "*",
  "Object name(*)      :" = "*"
 SELECT
  IF (ichar( $2)=ichar("Z"))
   PLAN (p
    WHERE p.object IN ("E", "P")
     AND (p.object_name= $3)
     AND p.ccl_version != 3)
    JOIN (c
    WHERE "P"=c.object
     AND p.object_name=c.object_name
     AND p.group=c.group)
   HEAD brk
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
   FOOT  brk
    IF (p.binary_cnt != cnt)
     CASE (p.object)
      OF "E":
       CALL print("drop ekmodule ")
      OF "P":
       CALL print("drop program ")
     ENDCASE
     IF (c.group=0)
      CALL print(build(p.object_name,":dba"))
     ELSE
      CALL print(build(p.object_name,":group",p.group))
     ENDIF
     " go", row + 1
    ENDIF
   WITH counter, outerjoin = p, noformfeed,
    maxrow = 1, filesort
  ELSE
  ENDIF
  INTO  $1
  brk = concat(p.object,p.object_name,format(p.group,"##;rp0")), p.object, p.object_name,
  p.binary_cnt
  FROM dprotect p,
   dcompile c
  PLAN (p
   WHERE p.object IN ("E", "P")
    AND (p.object_name= $3)
    AND (p.object= $2)
    AND p.ccl_version != 3)
   JOIN (c
   WHERE "P"=c.object
    AND p.object_name=c.object_name
    AND p.group=c.group)
  ORDER BY brk, c.qual
  HEAD REPORT
   line = fillstring(100,"=")
  HEAD PAGE
   "CCLCOMPILECHK Report of objects (E,P) in dictionary dprotect and dcompile counts do not match object:",
    $2, " name:",
    $3, row + 1, "Object  Group Objectname                       BinaryCnt      MaxCnt",
   row + 1, line, row + 1
  HEAD brk
   cnt = 0
  DETAIL
   cnt += 1
  FOOT  brk
   IF (p.binary_cnt != cnt)
    col 0, p.object, col + 1,
    p.group, col + 1, p.object_name,
    col + 1, p.binary_cnt, col + 1,
    cnt, row + 1
   ENDIF
  WITH counter, outerjoin = p, filesort
 ;end select
END GO
