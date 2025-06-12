CREATE PROGRAM bbt_get_dta_by_activity_type:dba
 RECORD reply(
   1 qual[*]
     2 task_assay_cd = f8
     2 mnemonic = vc
     2 activity_type_cd = f8
     2 activity_type_disp = vc
     2 activity_type_mean = c12
     2 bb_result_processing_cd = f8
     2 bb_result_processing_disp = vc
     2 bb_result_processing_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET act_cnt = size(request->actlist,5)
 DECLARE task_assay_cd = f8 WITH protect, noconstant(0.0)
 IF (validate(request->task_assay_cd)=1)
  SET task_assay_cd = request->task_assay_cd
 ENDIF
 SET select_ok_ind = 0
 IF (act_cnt > 0)
  SET d_cnt = act_cnt
  SET cdf_meaning = fillstring(12," ")
  SET code_value = 0.0
  SET idx = 0
  SET failed = 0
  FOR (idx = 1 TO act_cnt)
    SET cdf_meaning = request->actlist[idx].activity_type_mean
    SET stat = uar_get_meaning_by_codeset(106,cdf_meaning,1,code_value)
    IF (stat=1)
     SET failed = 1
    ELSE
     SET request->actlist[idx].activity_type_cd = code_value
    ENDIF
    CALL echo(request->actlist[idx].activity_type_cd)
  ENDFOR
  IF (failed=1)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "uar get activity codes"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_get_dta_by_activity_type"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "could not get activity codes for activity means"
   GO TO exit_script
  ENDIF
 ELSE
  SET d_cnt = 1
 ENDIF
 SET stat = alterlist(reply->qual,20)
 SET select_ok_ind = 0
 SELECT
  IF (task_assay_cd > 0.0)
   FROM discrete_task_assay dta
   PLAN (dta
    WHERE (dta.task_assay_cd=request->task_assay_cd)
     AND dta.active_ind=1)
  ELSE
   FROM (dummyt d  WITH seq = value(d_cnt)),
    discrete_task_assay dta
   PLAN (d)
    JOIN (dta
    WHERE ((act_cnt=0) OR (act_cnt > 0
     AND (dta.activity_type_cd=request->actlist[d.seq].activity_type_cd)
     AND dta.active_ind=1)) )
  ENDIF
  INTO "nl:"
  dta.task_assay_cd, dta.mnemonic, dta.activity_type_cd,
  dta.bb_result_processing_cd
  ORDER BY dta.task_assay_cd
  HEAD REPORT
   select_ok_ind = 0, qual_cnt = 0
  DETAIL
   qual_cnt = (qual_cnt+ 1)
   IF (mod(qual_cnt,20)=1
    AND qual_cnt != 1)
    stat = alterlist(reply->qual,(qual_cnt+ 19))
   ENDIF
   reply->qual[qual_cnt].task_assay_cd = dta.task_assay_cd, reply->qual[qual_cnt].mnemonic = dta
   .mnemonic, reply->qual[qual_cnt].activity_type_cd = dta.activity_type_cd,
   reply->qual[qual_cnt].bb_result_processing_cd = dta.bb_result_processing_cd
  FOOT REPORT
   stat = alterlist(reply->qual,qual_cnt), select_ok_ind = 1
  WITH nocounter, nullreport
 ;end select
 IF (select_ok_ind != 1)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "get processing means"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbt_get_dta_by_activity_type"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "could not get processing means for activity codes"
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
END GO
