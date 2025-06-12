CREATE PROGRAM aps_get_task_protocol_reltn:dba
 RECORD reply(
   1 assignment_list[*]
     2 proc_instrmt_prot_r_id = f8
     2 task_assay_cd = f8
     2 task_assay_disp = c40
     2 task_assay_desc = c60
     2 task_assay_mean = c12
     2 instrument_protocol_id = f8
     2 instrument_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE current_dt_tm_hold = q8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE ncount = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  ptr.catalog_cd
  FROM proc_instrmt_protcl_r pipr,
   profile_task_r ptr,
   instrument_protocol ip
  PLAN (pipr
   WHERE pipr.proc_instrmt_protcl_r_id != 0)
   JOIN (ptr
   WHERE ptr.catalog_cd=pipr.catalog_cd
    AND cnvtdatetime(current_dt_tm_hold) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm
    AND ptr.active_ind=1)
   JOIN (ip
   WHERE ip.instrument_protocol_id=pipr.instrument_protocol_id)
  DETAIL
   ncount += 1
   IF (ncount > size(reply->assignment_list,5))
    stat = alterlist(reply->assignment_list,(ncount+ 9))
   ENDIF
   reply->assignment_list[ncount].proc_instrmt_prot_r_id = pipr.proc_instrmt_protcl_r_id, reply->
   assignment_list[ncount].instrument_protocol_id = pipr.instrument_protocol_id, reply->
   assignment_list[ncount].task_assay_cd = ptr.task_assay_cd,
   reply->assignment_list[ncount].instrument_type_cd = ip.instrument_type_cd
  FOOT REPORT
   stat = alterlist(reply->assignment_list,ncount)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROC_INSTRMT_PROTCL_R"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
