CREATE PROGRAM bed_get_org_sus_results:dba
 DECLARE populatereply(organism_code_value=f8) = null
 DECLARE getparentcodevalue(organism_code_value=f8) = f8
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 sus_results[*]
      2 sus_result_code_value = f8
      2 sus_result_display = vc
      2 sus_result_description = vc
      2 sus_result_cdf_meaning = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET active_code = uar_get_code_by("MEANING",48,"ACTIVE")
 DECLARE parent_code_value = f8
 DECLARE temp_code_value = f8
 SET stat = populatereply(request->organism_code_value)
 SET parent_code_value = getparentcodevalue(request->organism_code_value)
 SET stat = populatereply(parent_code_value)
 SET parent_code_value = getparentcodevalue(parent_code_value)
 SET stat = populatereply(parent_code_value)
 SET parent_code_value = getparentcodevalue(parent_code_value)
 SET stat = populatereply(parent_code_value)
 SUBROUTINE populatereply(organism_code_value)
   DECLARE sus_res_cnt = i4
   DECLARE temp_cnt = i4
   SET antibiotic_size = size(request->organism_code_value,5)
   CALL echorecord(request)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = antibiotic_size),
     mic_valid_sus_result mvsr,
     code_value cv
    PLAN (d)
     JOIN (mvsr
     WHERE mvsr.organism_cd=organism_code_value
      AND (mvsr.task_component_cd=request->antibiotics[d.seq].antibiotic_code_value))
     JOIN (cv
     WHERE cv.code_value=mvsr.sus_result_cd
      AND cv.active_ind=1
      AND cv.active_type_cd=active_code
      AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    ORDER BY cv.code_value
    HEAD REPORT
     sus_res_cnt = 0, temp_cnt = 0, stat = alterlist(reply->sus_results,10)
    HEAD cv.code_value
     sus_res_cnt = (sus_res_cnt+ 1), temp_cnt = (temp_cnt+ 1)
     IF (temp_cnt > 10)
      temp_cnt = 1, stat = alterlist(reply->sus_results,(sus_res_cnt+ 10))
     ENDIF
     reply->sus_results[sus_res_cnt].sus_result_code_value = cv.code_value, reply->sus_results[
     sus_res_cnt].sus_result_description = cv.description, reply->sus_results[sus_res_cnt].
     sus_result_display = cv.display,
     reply->sus_results[sus_res_cnt].sus_result_cdf_meaning = cv.cdf_meaning
    FOOT REPORT
     stat = alterlist(reply->sus_results,sus_res_cnt), temp_cnt = 0
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = concat(
     "Error on selecting susceptability results for organism code value: ",organism_code_value)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
   IF (sus_res_cnt > 0)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE getparentcodevalue(organism_code_value)
   SELECT INTO "nl:"
    FROM mic_organism_data mod
    PLAN (mod
     WHERE mod.organism_id=organism_code_value)
    DETAIL
     temp_code_value = mod.parent_cd
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = concat(
     "Error on selecting parent organism for for organism code value: ",organism_code_value)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
   RETURN(temp_code_value)
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
