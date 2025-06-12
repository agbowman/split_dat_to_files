CREATE PROGRAM cclquery2:dba
 PROMPT
  "Enter program name: " = " "
 SET message = nowindow
 DECLARE fname = c80
 DECLARE pname = c29
 SET pname =  $1
 IF (size(trim( $1)) > 25)
  SET fname = concat("cclquery",curuser)
 ELSE
  SET fname = trim(cnvtlower( $1))
 ENDIF
 IF ((validate(curgroup,- (1)) != - (1)))
  SET grp = curgroup
 ELSE
  SET grp = 1
  SELECT INTO "nl:"
   d.group
   FROM duaf d
   WHERE d.user_name=curuser
   DETAIL
    grp = d.group
   WITH nocounter
  ;end select
 ENDIF
 SET objtype = " "
 SET grpname = "DBA    "
 SET grpnum = 0
 SELECT INTO "nl:"
  d.object
  FROM dprotect d
  WHERE ((d.object="E") OR (d.object="P"))
   AND d.object_name=progname
  ORDER BY d.object_name, d.group
  HEAD d.object_name
   objtype = d.object
   IF (d.group=0)
    grpname = "DBA"
   ELSE
    grpname = build("GROUP",d.group)
   ENDIF
   grpnum = d.group
  WITH nocounter
 ;end select
 CASE (objtype)
  OF "P":
   CALL parser(concat("translate into '",build(fname,".tmp"),"' ", $1,":",
     grpname," with query go"))
  OF "E":
   CALL parser(concat("translate into '",build(fname,".tmp"),"' ekmodule ", $1,":",
     grpname," with query go"))
  ELSE
   RETURN
 ENDCASE
 SET compile = debug
 CALL compile(build(fname,".tmp"))
 IF (curqual)
  SET cclquery_stat = 1
 ENDIF
 SET compile = nodebug
 IF (currdbopt > 1)
  UPDATE  FROM dprotect d,
    dprotect d2
   SET substring(288,32,d.datarec) = substring(288,32,d2.datarec)
   PLAN (d
    WHERE d.object="P"
     AND d.object_name=build("_",trim(pname))
     AND d.group=evaluate(grp,0,99,grp))
    JOIN (d2
    WHERE d.object=d2.object
     AND trim(pname)=d2.object_name
     AND grpnum=d2.group)
   WITH nocounter
  ;end update
 ENDIF
 CALL parser(build("execute _",trim(pname),":group",evaluate(grp,0,99,grp)," go"))
 CALL parser(build("drop program _",trim(pname),":group",evaluate(grp,0,99,grp)," go"))
END GO
