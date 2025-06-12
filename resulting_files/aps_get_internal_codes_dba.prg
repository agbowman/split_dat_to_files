CREATE PROGRAM aps_get_internal_codes:dba
 RECORD reply(
   1 qual[*]
     2 nomenclature_id = f8
     2 source_string = vc
     2 source_identifier = c50
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET cdf_meaning = "APINTERNAL"
 SET code_value = 0.0
 SET code_set = 400
 DECLARE ap_internal_cd = f8 WITH protect, noconstant(0.0)
 EXECUTE cpm_get_cd_for_cdf
 SET ap_internal_cd = code_value
 SELECT INTO "nl:"
  n.nomenclature_id
  FROM nomenclature n
  WHERE n.source_vocabulary_cd=ap_internal_cd
   AND n.active_ind=1
   AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->qual,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].nomenclature_id = n.nomenclature_id, reply->qual[cnt].source_string = n
   .source_string, reply->qual[cnt].source_identifier = n.source_identifier
  FOOT REPORT
   stat = alterlist(reply->qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NOMENCLATURE"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
