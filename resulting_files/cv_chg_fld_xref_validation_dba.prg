CREATE PROGRAM cv_chg_fld_xref_validation:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(cv_trns_del)=0)
  DECLARE cv_trns_add = i2 WITH protect, constant(1)
  DECLARE cv_trns_chg = i2 WITH protect, constant(2)
  DECLARE cv_trns_del = i2 WITH protect, constant(3)
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE failed = c1 WITH protect, noconstant("T")
 UPDATE  FROM cv_xref_validation xv,
   (dummyt d  WITH seq = value(size(request->xv_rec,5)))
  SET xv.response_id = request->xv_rec[d.seq].response_id, xv.child_xref_id = request->xv_rec[d.seq].
   child_xref_id, xv.child_response_id = request->xv_rec[d.seq].child_response_id,
   xv.xref_id = request->xv_rec[d.seq].xref_id, xv.beg_effective_dt_tm = cnvtdatetime(curdate,
    curtime3), xv.end_effective_dt_tm = cnvtdatetime("31-Dec-2100 00:00:00.00"),
   xv.rltnship_flag = request->xv_rec[d.seq].rltnship_flag, xv.reqd_flag = request->xv_rec[d.seq].
   reqd_flag, xv.offset_nbr = request->xv_rec[d.seq].offset_nbr,
   xv.active_ind = 1, xv.active_status_cd = reqdata->active_status_cd, xv.active_status_dt_tm =
   cnvtdatetime(curdate,curtime3),
   xv.active_status_prsnl_id = reqinfo->updt_id, xv.beg_effective_dt_tm = cnvtdatetime(curdate,
    curtime3), xv.updt_app = reqinfo->updt_app,
   xv.updt_req = reqinfo->updt_req, xv.updt_dt_tm = cnvtdatetime(curdate,curtime3), xv.updt_cnt = (xv
   .updt_cnt+ 1),
   xv.updt_id = reqinfo->updt_id, xv.updt_task = reqinfo->updt_task, xv.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (request->xv_rec[d.seq].transaction=cv_trns_chg))
   JOIN (xv
   WHERE (xv.xref_validation_id=request->xv_rec[d.seq].xref_validation_id)
    AND xv.active_ind=1)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "F"
  GO TO update_failure
 ENDIF
 GO TO exit_script
#update_failure
 IF (failed="F")
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "Update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CV_XREF_VALIDATION"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "update record"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  ROLLBACK
 ELSE
  SET reqinfo->commit_ind = 1
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
 DECLARE cv_chg_fld_xref_validation_vrsn = vc WITH private, constant("001 BM9013 05/09/2007")
END GO
