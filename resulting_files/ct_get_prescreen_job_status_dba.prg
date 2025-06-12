CREATE PROGRAM ct_get_prescreen_job_status:dba
 RECORD reply(
   1 prsnl_name = vc
   1 start_dt_tm = dq8
   1 total_pt_cnt = i4
   1 curr_pt_cnt = i4
   1 completed_flag = i2
   1 error_text = vc
   1 failure_status_flag = i2
   1 job_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failure_status_flag = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE job_status = f8 WITH protect, constant(uar_get_code_by("MEANING",17917,"FAILED"))
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM ct_prescreen_job cpj,
   ct_prot_prescreen_job_info cpp,
   prsnl p,
   long_text lt
  PLAN (cpp
   WHERE (cpp.prot_master_id=request->prot_master_id))
   JOIN (cpj
   WHERE cpj.ct_prescreen_job_id=cpp.ct_prescreen_job_id)
   JOIN (lt
   WHERE lt.long_text_id=cpj.long_text_id)
   JOIN (p
   WHERE p.person_id=cpj.prsnl_id)
  ORDER BY cpj.job_start_dt_tm DESC
  HEAD cpp.prot_master_id
   IF (cpj.job_status_cd=job_status)
    failure_status_flag = 1
   ENDIF
   reply->curr_pt_cnt = cpp.curr_eval_pat_cnt, reply->total_pt_cnt = cpp.total_eval_pat_cnt, reply->
   prsnl_name = p.name_full_formatted,
   reply->start_dt_tm = cnvtdatetime(cpj.job_start_dt_tm), reply->completed_flag = cpp.completed_flag,
   reply->error_text = lt.long_text,
   reply->failure_status_flag = failure_status_flag, reply->job_id = cpj.ct_prescreen_job_id
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET last_mod = "000"
 SET mod_date = "May 06, 2021"
END GO
