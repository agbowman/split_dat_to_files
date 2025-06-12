CREATE PROGRAM core_get_cd_set_access_ind:dba
 SET modify = predeclare
 IF ((validate(reply->access_ind,- (123))=- (123)))
  FREE RECORD reply
  RECORD reply(
    1 access_ind = i2
    1 dev_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  PLAN (di
   WHERE di.info_domain="COREBUILDER"
    AND di.info_name="CODESET_INSERT"
    AND di.info_number=1)
  DETAIL
   reply->access_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  do.object_name
  FROM dba_objects do
  PLAN (do
   WHERE do.object_name="CODE_SET_SEQ"
    AND do.owner IN ("PUBLIC", "V500")
    AND do.object_type IN ("SYNONYM", "SEQUENCE")
    AND do.status="VALID")
  DETAIL
   reply->dev_ind = 1
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET failed = "T"
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "001 03/16/07 KV011080"
END GO
