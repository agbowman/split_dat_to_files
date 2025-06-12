CREATE PROGRAM cv_chg_fld_dsfiles:dba
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
 UPDATE  FROM cv_dataset_file df,
   (dummyt d  WITH seq = value(size(request->file,5)))
  SET df.delimiter = request->file[d.seq].delimiter, df.name = request->file[d.seq].name, df.file_nbr
    = request->file[d.seq].file_nbr,
   df.extension = request->file[d.seq].extension, df.format_string = request->file[d.seq].
   format_string, df.table_name = request->file[d.seq].table_name,
   df.column_name = request->file[d.seq].column_name, df.dataset_id = request->file[d.seq].dataset_id,
   df.active_ind = 1,
   df.active_status_cd = reqdata->active_status_cd, df.active_status_dt_tm = cnvtdatetime(curdate,
    curtime3), df.active_status_prsnl_id = reqinfo->updt_id,
   df.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), df.updt_app = reqinfo->updt_app, df
   .updt_req = reqinfo->updt_req,
   df.updt_dt_tm = cnvtdatetime(curdate,curtime3), df.updt_cnt = (df.updt_cnt+ 1), df.updt_id =
   reqinfo->updt_id,
   df.updt_task = reqinfo->updt_task, df.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (request->file[d.seq].transaction=cv_trns_chg))
   JOIN (df
   WHERE (df.file_id=request->file[d.seq].file_id)
    AND df.active_ind=1)
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
  SET reply->status_data.subeventstatus[1].targetobjectname = "CV_DATASET_FILE"
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
 DECLARE cv_chg_fld_dsfiles_vrsn = vc WITH private, constant("002 BM9013 05/07/2007")
END GO
