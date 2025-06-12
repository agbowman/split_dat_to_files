CREATE PROGRAM cclcompilechk2:dba
 PROMPT
  "Output name(MINE)   :" = "MINE",
  "Object type(*)      :" = "*",
  "Object name(*)      :" = "*"
 SELECT
  IF (ichar( $2)=ichar("Z"))
   DETAIL
    IF (flag=0)
     "drop program "
     IF (c.group=0)
      CALL print(build(c.object_name,":dba"))
     ELSE
      CALL print(build(c.object_name,":group",c.group))
     ENDIF
     " go", row + 1
    ENDIF
   WITH counter, outerjoin = c, noformfeed,
    maxrow = 1
  ELSE
  ENDIF
  INTO  $1
  c.object, c.object_name, c.group,
  flag = decode(p1.seq,1,p2.seq,2,p3.seq,
   3,p4.seq,4,0)
  FROM dcompile c,
   dprotect p1,
   dprotect p2,
   dprotect p3,
   dprotect p4
  PLAN (c
   WHERE c.qual=0
    AND c.object="P"
    AND (c.object_name= $3))
   JOIN (((p1
   WHERE "E"=p1.object
    AND c.object_name=p1.object_name
    AND c.group=p1.group)
   ) ORJOIN ((((p2
   WHERE "M"=p2.object
    AND c.object_name=p2.object_name
    AND c.group=p2.group)
   ) ORJOIN ((((p3
   WHERE "P"=p3.object
    AND c.object_name=p3.object_name
    AND c.group=p3.group)
   ) ORJOIN ((p4
   WHERE "V"=p4.object
    AND c.object_name=p4.object_name
    AND c.group=p4.group)
   )) )) ))
  HEAD REPORT
   line = fillstring(100,"=")
  HEAD PAGE
   "Report of missing objects found in dcompile but not dprotect", row + 1,
   "Group        Objectname         ",
   row + 1, line, row + 1
  DETAIL
   IF (flag=0)
    c.group, col + 1, c.object_name,
    row + 1
   ENDIF
  WITH counter, outerjoin = c
 ;end select
END GO
