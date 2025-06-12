CREATE PROGRAM dm2_get_purge_job_run:dba
 IF ((validate(request->job_id,- (1.0))=- (1.0)))
  RECORD request(
    1 job_id = f8
  )
 ENDIF
 IF ((validate(reply->qual_cnt,- (1))=- (1)))
  RECORD reply(
    1 qual_cnt = i4
    1 qual[*]
      2 log_id = f8
      2 purge_flag = i2
      2 start_dt_tm = dq8
      2 end_dt_tm = dq8
      2 parent_rows = i4
      2 child_rows = i4
      2 err_msg = vc
      2 err_code = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE dgpr_errmsg = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM dm_purge_job_log dpjl
  WHERE (dpjl.job_id=request->job_id)
  DETAIL
   reply->qual_cnt = (reply->qual_cnt+ 1)
   IF (mod(reply->qual_cnt,50)=1)
    stat = alterlist(reply->qual,(reply->qual_cnt+ 49))
   ENDIF
   reply->qual[reply->qual_cnt].log_id = dpjl.log_id, reply->qual[reply->qual_cnt].purge_flag = dpjl
   .purge_flag, reply->qual[reply->qual_cnt].start_dt_tm = dpjl.start_dt_tm,
   reply->qual[reply->qual_cnt].end_dt_tm = dpjl.end_dt_tm, reply->qual[reply->qual_cnt].parent_rows
    = dpjl.parent_rows, reply->qual[reply->qual_cnt].child_rows = dpjl.child_rows,
   reply->qual[reply->qual_cnt].err_msg = dpjl.err_msg, reply->qual[reply->qual_cnt].err_code = dpjl
   .err_code
  FOOT REPORT
   stat = alterlist(reply->qual,reply->qual_cnt)
  WITH nocounter
 ;end select
 IF (error(dgpr_errmsg,0) > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "fetching purge runs"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = curprog
  SET reply->status_data.subeventstatus[1].targetobjectvalue = dgpr_errmsg
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
END GO
