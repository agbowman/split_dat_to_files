CREATE PROGRAM bbt_get_separate_aborh:dba
 RECORD reply(
   1 abo_cd = f8
   1 rh_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET count1 = 0
 SELECT INTO "nl:"
  cve.field_value, cve.field_name
  FROM code_value_extension cve
  WHERE (cve.code_value=request->aborh_cd)
  DETAIL
   IF (cve.field_name="ABOOnly_cd")
    reply->abo_cd = cnvtreal(cve.field_value)
   ELSEIF (cve.field_name="RhOnly_cd")
    reply->rh_cd = cnvtreal(cve.field_value)
   ENDIF
   select_ok_ind = 1
  WITH nocounter
 ;end select
 SET reply->status_data.subeventstatus[count1].operationname = "Get Separate ABORh"
 SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_get_separate_aborh"
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[count1].operationstatus = "S"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "SUCCESS"
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "Select on code_value failed"
 ENDIF
END GO
