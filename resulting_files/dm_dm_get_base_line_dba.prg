CREATE PROGRAM dm_dm_get_base_line:dba
 RECORD reply(
   1 base_line_rev = c30
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SELECT INTO "NL:"
  a.info_char
  FROM dm_info a
  WHERE a.info_name="BASE_LINE_REV"
  DETAIL
   reply->base_line_rev = a.info_char
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
