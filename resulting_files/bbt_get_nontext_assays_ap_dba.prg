CREATE PROGRAM bbt_get_nontext_assays_ap:dba
 RECORD reply(
   1 qual[*]
     2 task[*]
       3 task_cd = f8
       3 task_disp = vc
       3 meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
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
 SET count1 = 0
 SET hold_task_assay = 0.0
 SET ap_cd = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "1"
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(106,"AP",cv_cnt,ap_cd)
 SET task_count = 0
 DECLARE task_chunk = i4 WITH protect, constant(100)
 DECLARE task_max_size = i4 WITH protect, constant(65535)
 IF (ap_cd=0.0)
  SET reply->status_data.subeventstatus[1].sourceobjectname = "BBT_GET_NONTEXT_ASSAYS_AP.PRG"
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "unable to retrieve activity type"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 0
  GO TO exit_script
 ENDIF
 SET code_value = get_code_value(289,cdf_meaning)
 SELECT INTO "nl:"
  dta.task_assay_cd, dta.mnemonic
  FROM discrete_task_assay dta
  PLAN (dta
   WHERE dta.default_result_type_cd != code_value
    AND dta.activity_type_cd=ap_cd
    AND dta.active_ind=1)
  HEAD REPORT
   count1 = 1, task_count = 0
  DETAIL
   IF (dta.task_assay_cd != hold_task_assay)
    IF (count1=1)
     stat = alterlist(reply->qual,count1)
    ENDIF
    IF (task_count >= task_max_size)
     stat = alterlist(reply->qual[count1].task,task_count), count1 = (count1+ 1), task_count = 0,
     stat = alterlist(reply->qual,count1)
    ENDIF
    IF (mod(task_count,task_chunk)=0)
     stat = alterlist(reply->qual[count1].task,(task_count+ task_chunk))
    ENDIF
    hold_task_assay = dta.task_assay_cd, task_count = (task_count+ 1), reply->qual[count1].task[
    task_count].task_cd = dta.task_assay_cd,
    reply->qual[count1].task[task_count].task_disp = dta.mnemonic, reply->qual[count1].task[
    task_count].meaning = uar_get_code_meaning(dta.default_result_type_cd)
   ENDIF
  WITH counter
 ;end select
 SET stat = alterlist(reply->qual[count1].task,task_count)
 IF (((curqual != 0) OR (count1 > 0)) )
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
