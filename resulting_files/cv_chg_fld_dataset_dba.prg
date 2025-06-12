CREATE PROGRAM cv_chg_fld_dataset:dba
 IF (validate(reply->status_data.status)=0)
  RECORD reply(
    1 dataset_rec[*]
      2 dataset_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ELSE
  CALL cv_log_message("reply is already defined")
 ENDIF
 IF (validate(cv_trns_del)=0)
  DECLARE cv_trns_add = i2 WITH protect, constant(1)
  DECLARE cv_trns_chg = i2 WITH protect, constant(2)
  DECLARE cv_trns_del = i2 WITH protect, constant(3)
 ENDIF
 IF (validate(cvnet_inval_data)=0)
  DECLARE cvnet_lock = i4 WITH protect, constant(100)
  DECLARE cvnet_no_seq = i4 WITH protect, constant(101)
  DECLARE cvnet_updt_cnt = i4 WITH protect, constant(102)
  DECLARE cvnet_insuf_data = i4 WITH protect, constant(103)
  DECLARE cvnet_update = i4 WITH protect, constant(104)
  DECLARE cvnet_insert = i4 WITH protect, constant(105)
  DECLARE cvnet_delete = i4 WITH protect, constant(106)
  DECLARE cvnet_select = i4 WITH protect, constant(107)
  DECLARE cvnet_auth = i4 WITH protect, constant(108)
  DECLARE cvnet_inval_data = i4 WITH protect, constant(109)
 ENDIF
 IF (validate(cvnet_inval_data_msg)=0)
  DECLARE cvnet_lock_msg = vc WITH protect, constant("Failed to lock all requested rows")
  DECLARE cvnet_no_seq_msg = vc WITH protect, constant("Failed to get next sequence number")
  DECLARE cvnet_updt_cnt_msg = vc WITH protect, constant("Failed to match update count")
  DECLARE cvnet_insuf_data_msg = vc WITH protect, constant("Request did not supply sufficient data")
  DECLARE cvnet_update_msg = vc WITH protect, constant("Failed on update request")
  DECLARE cvnet_insert_msg = vc WITH protect, constant("Failed on insert request")
  DECLARE cvnet_delete_msg = vc WITH protect, constant("Failed on delete request")
  DECLARE cvnet_select_msg = vc WITH protect, constant("Failed on select request")
  DECLARE cvnet_auth_msg = vc WITH protect, constant("Failed on authorization of request")
  DECLARE cvnet_inval_data_msg = vc WITH protect, constant("Request contained some invalid data")
 ENDIF
 IF (validate(cvnet_sys_fail)=0)
  DECLARE cvnet_success = i2 WITH protect, constant(0)
  DECLARE cvnet_success_info = i2 WITH protect, constant(1)
  DECLARE cvnet_success_warn = i2 WITH protect, constant(2)
  DECLARE cvnet_deadlock = i2 WITH protect, constant(3)
  DECLARE cvnet_script_fail = i2 WITH protect, constant(4)
  DECLARE cvnet_sys_fail = i2 WITH protect, constant(5)
 ENDIF
 DECLARE failed = c1 WITH protect, noconstant("F")
 SET reply->status_data.status = "F"
 DECLARE inicount = i4 WITH protect
 DECLARE number_to_chg = i4 WITH protect, noconstant(1)
 SET stat = alterlist(reply->dataset_rec,number_to_chg)
 FOR (x = 1 TO number_to_chg)
   IF ((request->dataset_rec.transaction=cv_trns_chg))
    SET reply->dataset_rec[x].dataset_id = request->dataset_rec.dataset_id
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM cv_dataset d
  PLAN (d
   WHERE (d.dataset_id=request->dataset_rec.dataset_id)
    AND d.active_ind=1)
  WITH nocounter, forupdate(d)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "lock_Rows"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "dataset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "chg_dataset table"
  GO TO exit_script
 ENDIF
 IF ((request->dataset_rec.transaction != cv_trns_chg))
  SET failed = "T"
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CV_DATASET"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Not a change transaction"
  GO TO exit_script
 ENDIF
 UPDATE  FROM cv_dataset d
  SET d.display_name = request->dataset_rec.display_name, d.dataset_internal_name = request->
   dataset_rec.dataset_internal_name, d.validation_script = request->dataset_rec.validationscript,
   d.alias_pool_mean = request->dataset_rec.aliaspoolmean, d.case_date_mean = request->dataset_rec.
   casedatemean, d.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   d.end_effective_dt_tm = cnvtdatetime("31-Dec-2100"), d.updt_dt_tm = cnvtdatetime(curdate,curtime),
   d.updt_cnt = (d.updt_cnt+ 1),
   d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->
   updt_applctx,
   d.active_status_cd = reqdata->active_status_cd, d.updt_req = reqinfo->updt_req, d.updt_app =
   reqinfo->updt_app,
   d.active_ind = 1
  PLAN (d
   WHERE (d.dataset_id=request->dataset_rec.dataset_id)
    AND d.active_ind=1)
  WITH nocounter
 ;end update
 IF (curqual != 1)
  SET failed = "T"
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "update"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "dataset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "chg_dataset"
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply,"cer_temp:cv_datasetREPLY.dat")
END GO
