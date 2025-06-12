CREATE PROGRAM cv_add_fld_dataset:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 dataset_rec[*]
      2 dataset_id = f8
    1 cvnet_error
      2 cnt = i4
      2 data[*]
        3 code = i4
        3 severity_level = i4
        3 supp_err_txt = c32
        3 def_msg = vc
        3 row_data
          4 lvl_1_idx = i4
          4 lvl_2_idx = i4
          4 lvl_3_idx = i4
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
 SUBROUTINE cvnet_add_error(cvnet_errcode,severity_level,supp_err_txt,def_msg,idx1,idx2,idx3)
   DECLARE errcnt = i4 WITH protect
   SET reply->cvnet_error.cnt = (reply->cvnet_error.cnt+ 1)
   SET errcnt = reply->cvnet_error.cnt
   SET stat = alterlist(reply->cvnet_error.data,errcnt)
   SET reply->cvnet_error.data[errcnt].code = cvnet_errcode
   SET reply->cvnet_error.data[errcnt].severity_level = severity_level
   SET reply->cvnet_error.data[errcnt].supp_err_txt = supp_err_txt
   SET reply->cvnet_error.data[errcnt].def_msg = def_msg
   SET reply->cvnet_error.data[errcnt].row_data.lvl_1_idx = idx1
   SET reply->cvnet_error.data[errcnt].row_data.lvl_2_idx = idx2
   SET reply->cvnet_error.data[errcnt].row_data.lvl_3_idx = idx3
 END ;Subroutine
 DECLARE cnt = i4 WITH protect, noconstant(size(request->dataset_rec,5))
 DECLARE stat = i4 WITH protect
 SET stat = alterlist(reply->dataset_rec,cnt)
 FOR (x = 1 TO cnt)
   SELECT INTO "NL:"
    nextseqnum = seq(card_vas_seq,nextval)
    FROM dual
    DETAIL
     reply->dataset_rec[x].dataset_id = nextseqnum
    WITH format
   ;end select
 ENDFOR
 DECLARE failed = c1 WITH protect, noconstant("F")
 SET reply->status_data.status = "F"
 DECLARE dataset_id = f8 WITH protect
 INSERT  FROM cv_dataset d
  SET d.dataset_id = reply->dataset_rec[1].dataset_id, d.display_name = request->dataset_rec.
   display_name, d.dataset_internal_name = request->dataset_rec.dataset_internal_name,
   d.validation_script = request->dataset_rec.validationscript, d.alias_pool_mean = request->
   dataset_rec.aliaspoolmean, d.case_date_mean = request->dataset_rec.casedatemean,
   d.active_ind = 1, d.active_status_dt_tm = cnvtdatetime(curdate,curtime3), d.active_status_cd =
   reqdata->active_status_cd,
   d.active_status_prsnl_id = reqinfo->updt_id, d.active_status_dt_tm = cnvtdatetime(curdate,curtime3
    ), d.data_status_cd = reqdata->data_status_cd,
   d.data_status_prsnl_id = reqinfo->updt_id, d.data_status_dt_tm = cnvtdatetime(curdate,curtime3), d
   .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   d.end_effective_dt_tm = cnvtdatetime("31-Dec-2100 00:00:00.00"), d.updt_dt_tm = cnvtdatetime(
    curdate,curtime3), d.updt_task = reqinfo->updt_task,
   d.updt_app = reqinfo->updt_app, d.updt_applctx = reqinfo->updt_applctx, d.updt_req = reqinfo->
   updt_req,
   d.updt_cnt = 0, d.updt_id = reqinfo->updt_id
  PLAN (d
   WHERE (request->dataset_rec.transaction=cv_trns_add))
  WITH nocounter
 ;end insert
 IF (curqual=0)
  CALL cvnet_add_error(cvnet_insert,cvnet_script_fail,"inserting dataset",cvnet_insert_msg,0,
   0,0)
  SET failed = "T"
  GO TO dataset_insert_failed
 ENDIF
 GO TO exit_script
#dataset_insert_failed
 SET reply->status_data.subeventstatus[1].operationname = "insert"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "cv_dataset"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CV_add_fld_dataset"
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  ROLLBACK
 ELSE
  SET reqinfo->commit_ind = 1
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
 DECLARE cv_add_fld_dataset = vc WITH private, constant("001 BM9013 05/08/2007")
END GO
