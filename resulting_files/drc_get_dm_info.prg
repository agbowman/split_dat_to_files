CREATE PROGRAM drc_get_dm_info
 RECORD reply(
   1 drc_flex_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH public, noconstant("F")
 SET reply->status_data.status = "F"
 SET reply->drc_flex_ind = 0
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="KNOWLEDGE INDEX APPLICATIONS"
   AND d.info_name="DRC_FLEX"
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET reply->drc_flex_ind = 0
 ELSE
  SET reply->drc_flex_ind = 1
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
