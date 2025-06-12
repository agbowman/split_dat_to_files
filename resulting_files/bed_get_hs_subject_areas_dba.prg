CREATE PROGRAM bed_get_hs_subject_areas:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 subject_areas[*]
      2 code_set = i4
      2 name = vc
      2 has_unmapped_data = i2
      2 has_mappable_items = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE cnt = i4
 DECLARE list_cnt = i4
 SELECT DISTINCT INTO "nl:"
  hs.code_set, r.code_value
  FROM br_hlth_sntry_item hs,
   br_hlth_sntry_mill_item r,
   code_value_set cs,
   br_name_value bv
  PLAN (hs
   WHERE hs.code_set > 0)
   JOIN (cs
   WHERE cs.code_set=hs.code_set)
   JOIN (r
   WHERE r.br_hlth_sntry_item_id=outerjoin(hs.br_hlth_sntry_item_id))
   JOIN (bv
   WHERE bv.br_nv_key1=outerjoin("HEALTHSENTIGN")
    AND cnvtreal(bv.br_name)=outerjoin(hs.br_hlth_sntry_item_id))
  ORDER BY hs.code_set
  HEAD REPORT
   cnt = 0, list_cnt = 0, stat = alterlist(reply->subject_areas,100)
  HEAD hs.code_set
   list_cnt = (list_cnt+ 1), cnt = (cnt+ 1)
   IF (list_cnt > 100)
    stat = alterlist(reply->subject_areas,(cnt+ 100)), list_cnt = 0
   ENDIF
   reply->subject_areas[cnt].code_set = cs.code_set, reply->subject_areas[cnt].name = cs.display
  DETAIL
   IF (r.code_value=0
    AND hs.ignore_ind=0
    AND cnvtreal(bv.br_name)=0.0)
    reply->subject_areas[cnt].has_unmapped_data = 1
   ENDIF
   IF (hs.ignore_ind=0)
    reply->subject_areas[cnt].has_mappable_items = 1
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->subject_areas,cnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error selecting HS Subject Areas.")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
