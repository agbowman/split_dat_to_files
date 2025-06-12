CREATE PROGRAM cclanalyze2:dba
 PROMPT
  "Enter program name: " = " "
 SET message = nowindow
 DECLARE fname = c80
 DECLARE pname = c29
 SET pname =  $1
 IF (size(trim( $1)) > 25)
  SET fname = concat("cclanalyze",curuser)
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
 CALL compile(build(fname,".tmp"))
 IF (grp=0)
  SET grp = 99
 ENDIF
 CALL parser(concat("translate into '",build(fname,".tmp"),"' _",pname,":group",
   build(grp)," with analyze go"))
 CALL parser(build("drop program _",pname,":group",grp," go"))
END GO
