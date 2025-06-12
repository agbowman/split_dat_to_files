CREATE PROGRAM dm_temp_check:dba
 SET user_date = cnvtdatetime(curdate,curtime3)
 SET temp_date = cnvtdatetime(curdate,curtime3)
 SET userlastupdt = "N"
 SELECT INTO "nl:"
  d.info_date
  FROM dm_info d
  WHERE d.info_name="USERLASTUPDT"
  DETAIL
   user_date = d.info_date
  WITH nocounter
 ;end select
 IF (curqual=1)
  SET userlastupdt = "Y"
 ENDIF
 SELECT INTO "nl:"
  d.info_date
  FROM dm_info d
  WHERE d.info_name="TEMPLASTBLD"
  DETAIL
   temp_date = d.info_date
  WITH nocounter
 ;end select
 IF (((curqual=0) OR (userlastupdt="Y"
  AND user_date > temp_date)) )
  EXECUTE dm_temp_tables
 ENDIF
END GO
