CREATE PROGRAM core_get_extension_by_cd:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 extension_list[*]
     2 field_name = c32
     2 field_type = i4
     2 field_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE ext_cnt = i4 WITH public, noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cve.field_name, cve.field_type, cve.field_value
  FROM code_value_extension cve
  PLAN (cve
   WHERE (cve.code_value=request->code_value))
  HEAD REPORT
   ext_cnt = 0
  DETAIL
   ext_cnt = (ext_cnt+ 1)
   IF (mod(ext_cnt,10)=1)
    stat = alterlist(reply->extension_list,(ext_cnt+ 9))
   ENDIF
   reply->extension_list[ext_cnt].field_name = cve.field_name, reply->extension_list[ext_cnt].
   field_type = cve.field_type, reply->extension_list[ext_cnt].field_value = cve.field_value
  FOOT REPORT
   stat = alterlist(reply->extension_list,ext_cnt)
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "000 02/24/03 JF8275"
END GO
