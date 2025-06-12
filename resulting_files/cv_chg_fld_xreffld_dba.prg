CREATE PROGRAM cv_chg_fld_xreffld:dba
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
 UPDATE  FROM cv_xref_field t,
   (dummyt d  WITH seq = value(size(request->field,5)))
  SET t.file_id = request->field[d.seq].file_id, t.position = request->field[d.seq].position, t
   .length = request->field[d.seq].length,
   t.format = request->field[d.seq].field_format, t.start_pos = request->field[d.seq].start, t
   .xref_id = request->field[d.seq].xref_id,
   t.dataset_id = request->field[d.seq].dataset_id, t.display_name = request->field[d.seq].
   display_name, t.active_ind = 1,
   t.active_status_cd = reqdata->active_status_cd, t.active_status_dt_tm = cnvtdatetime(curdate,
    curtime3), t.active_status_prsnl_id = reqinfo->updt_id,
   t.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_app = reqinfo->updt_app, t.updt_req
    = reqinfo->updt_req,
   t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_cnt = (t.updt_cnt+ 1), t.updt_id = reqinfo->
   updt_id,
   t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (request->field[d.seq].transaction=cv_trns_chg))
   JOIN (t
   WHERE (t.xref_field_id=request->field[d.seq].xref_field_id)
    AND t.active_ind=1)
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
  SET reply->status_data.subeventstatus[1].targetobjectname = "CV_XREF_FIELD"
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
 DECLARE cv_chg_fld_xreffld_vrsn = vc WITH private, constant("MOD 002 BM9013 05/07/2007")
END GO
