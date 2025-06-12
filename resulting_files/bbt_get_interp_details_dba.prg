CREATE PROGRAM bbt_get_interp_details:dba
 RECORD reply(
   1 qual[*]
     2 task_cd = f8
     2 task_display = vc
     2 result_mean = c12
     2 concept_cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET activity_type_cd = 0.0
 SET hold_task_id = 0.0
 SET cv_cnt = 1
 IF ((request->activity_type_mean="AP"))
  SET stat = uar_get_meaning_by_codeset(106,"AP",cv_cnt,activity_type_cd)
 ELSEIF ((request->activity_type_mean="BB"))
  SET stat = uar_get_meaning_by_codeset(106,"BB",cv_cnt,activity_type_cd)
 ELSEIF ((request->activity_type_mean="GLB"))
  SET stat = uar_get_meaning_by_codeset(106,"GLB",cv_cnt,activity_type_cd)
 ELSEIF ((request->activity_type_mean="BBDONOR"))
  SET stat = uar_get_meaning_by_codeset(106,"BBDONOR",cv_cnt,activity_type_cd)
 ELSEIF ((request->activity_type_mean="HLA"))
  SET stat = uar_get_meaning_by_codeset(106,"HLA",cv_cnt,activity_type_cd)
 ELSEIF ((request->activity_type_mean="HLX"))
  SET stat = uar_get_meaning_by_codeset(106,"HLX",cv_cnt,activity_type_cd)
 ELSEIF ((request->activity_type_mean="BBDONORPROD"))
  SET stat = uar_get_meaning_by_codeset(106,"BBDONORPROD",cv_cnt,activity_type_cd)
 ELSE
  SET activity_type_cd = 0.0
 ENDIF
 IF (activity_type_cd=0.0)
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbt_get_interp_details.prg"
  SET reply->status_data.subeventstatus[1].operationname = "UAR_GET_CODE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Activity code"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Code_value for activity type"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO stop
 ENDIF
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "4"
 SET stat = uar_get_meaning_by_codeset(289,cdf_meaning,1,code_value)
 SELECT INTO "nl:"
  FROM discrete_task_assay dta,
   assay_processing_r apr,
   (dummyt d  WITH seq = 1)
  PLAN (dta
   WHERE dta.default_result_type_cd=code_value
    AND dta.activity_type_cd=activity_type_cd
    AND dta.active_ind=1)
   JOIN (d
   WHERE d.seq=1)
   JOIN (apr
   WHERE apr.default_result_type_cd=code_value
    AND apr.task_assay_cd=dta.task_assay_cd
    AND apr.active_ind=1)
  HEAD REPORT
   count1 = 0
  DETAIL
   IF (hold_task_id != dta.task_assay_cd)
    hold_task_id = dta.task_assay_cd, count1 = (count1+ 1), stat = alterlist(reply->qual,count1),
    reply->qual[count1].task_cd = dta.task_assay_cd, reply->qual[count1].task_display = dta.mnemonic,
    reply->qual[count1].result_mean = uar_get_code_meaning(dta.bb_result_processing_cd),
    reply->qual[count1].concept_cki = dta.concept_cki
   ENDIF
  WITH counter, outerjoin(d)
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#stop
END GO
