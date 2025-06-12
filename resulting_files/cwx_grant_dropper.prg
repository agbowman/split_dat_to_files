CREATE PROGRAM cwx_grant_dropper
 SET grant_exist = "N"
 SET date_current = "N"
 SET database_name = "123456789"
 SET app_node = cnvtupper(curnode)
 SET script_name =  $1
 CALL echo(script_name)
 SET drop_date = cnvtdate( $2)
 SELECT INTO "NOFORMS"
  x = drop_date"MM/DD/YYYY HH:MM:SS;;d"
  FROM dummyt
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  object_name = substring(2,30,g.rest)
  FROM (dgeneric g  WITH access_code = "5", user_code = none)
  WHERE g.platform="H0000"
   AND g.rcode="5"
   AND evaluate(substring(274,6,g.data),"<sec1>",band(ichar(substring(248,1,g.data)),15),0)=1
   AND (substring(2,30,g.rest)= $1)
  DETAIL
   grant_exist = "Y"
  WITH nocounter
 ;end select
 IF (grant_exist="Y")
  CALL echo("grant exists")
  SELECT INTO "NL:"
   datestamp
   FROM dprotect
   WHERE datestamp >= cnvtdate( $2)
    AND object="P"
    AND (object_name= $1)
   DETAIL
    date_current = "Y"
   WITH nocounter
  ;end select
  IF (date_current="Y")
   CALL echo("date current, removing grant")
   SET drop_name = concat("grant execute on ", $1," to all with rdbopt = 8 go")
   CALL parser(drop_name)
   CALL echo(drop_name)
   SELECT INTO "NL:"
    v.name
    FROM v$database v
    DETAIL
     database_name = v.name
    WITH nocounter
   ;end select
   INSERT  FROM dm_info d
    SET d.info_name = "CWX_GRANT_DROPPER", d.info_domain = concat("Database_name = ",database_name,
      ", App node = ",app_node,", Script name =",
      script_name), d.updt_dt_tm = sysdate
    WITH nocounter
   ;end insert
   COMMIT
  ENDIF
 ENDIF
END GO
