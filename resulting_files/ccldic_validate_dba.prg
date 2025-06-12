CREATE PROGRAM ccldic_validate:dba
 PROMPT
  "Object name(*): " = "*"
 DECLARE errmsg = vc
 SET objvalid = 1
 SET objtype = "P"
 SET objname = trim(cnvtupper( $1))
 CALL echo(concat("Validate script: ",objname))
 SELECT INTO "nl:"
  brk = concat(dp.object,dp.object_name,format(dp.group,"##;rp0"))
  FROM dprotect dp,
   dcompile dc
  PLAN (dp
   WHERE dp.platform="H0000"
    AND dp.rcode="5"
    AND dp.object_name=cnvtupper(objname)
    AND dp.object=objtype)
   JOIN (dc
   WHERE dp.platform=dc.platform
    AND "9"=dc.rcode
    AND dp.object=dc.object
    AND dp.object_name=dc.object_name
    AND dp.group=dc.group)
  ORDER BY brk, dc.qual
  HEAD brk
   cnt = 0
  DETAIL
   cnt += 1
  FOOT  brk
   IF (dp.binary_cnt != cnt)
    objvalid = - (1)
   ENDIF
  WITH counter, outerjoin = dp
 ;end select
 IF (curqual=0)
  SET objvalid = 0
 ENDIF
 SET errorcode = error(errmsg,0)
 IF (errorcode != 0)
  CALL echo(concat("Error occurred: ",errmsg))
  SET objvalid = - (2)
 ENDIF
 RETURN(objvalid)
END GO
