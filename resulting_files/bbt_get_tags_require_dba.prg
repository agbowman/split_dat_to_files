CREATE PROGRAM bbt_get_tags_require:dba
 RECORD reply(
   1 component_yn_ind = i2
   1 emergency_yn_ind = i2
   1 crossmatch_yn_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE get_code_value(sub_code_set,sub_cdf_meaning) = f8
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   SET gsub_code_value = 0.0
   SET cdf_meaning = fillstring(12," ")
   SET cdf_meaning = sub_cdf_meaning
   SET stat = uar_get_meaning_by_codeset(sub_code_set,cdf_meaning,1,gsub_code_value)
   RETURN(gsub_code_value)
 END ;Subroutine
 SET reply->status_data.status = "F"
 SET val_count = 0
 SET ext_count = 0
 SET code_value = 0.0
 SET code_value = get_code_value(1662,request->cdf_meaning)
 SELECT INTO "nl:"
  cve.field_name, cve.field_type, cve.field_value,
  cve.updt_cnt
  FROM code_value_extension cve
  PLAN (cve
   WHERE cve.code_value=code_value)
  DETAIL
   IF (cve.field_name="Component Tag")
    reply->component_yn_ind = cnvtint(cve.field_value)
   ELSEIF (cve.field_name="Emergency Tag")
    reply->emergency_yn_ind = cnvtint(cve.field_value)
   ELSEIF (cve.field_name="Crossmatch Tag")
    reply->crossmatch_yn_ind = cnvtint(cve.field_value)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
