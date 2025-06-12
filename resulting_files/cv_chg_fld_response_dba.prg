CREATE PROGRAM cv_chg_fld_response:dba
 IF (validate(cv_trns_del)=0)
  DECLARE cv_trns_add = i2 WITH protect, constant(1)
  DECLARE cv_trns_chg = i2 WITH protect, constant(2)
  DECLARE cv_trns_del = i2 WITH protect, constant(3)
 ENDIF
 DECLARE logfile = vc WITH protect, constant("LogFile.dat")
 DECLARE cv_log_to_file(string_param=vc) = null WITH protect
 SUBROUTINE cv_log_to_file(string_param)
   SELECT INTO logfile
    FROM dual d
    DETAIL
     string_param, row + 1
    WITH append
   ;end select
 END ;Subroutine
 IF (validate(reply->status_data.status,"-1")="-1")
  RECORD reply(
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
 SET reply->status_data.status = "F"
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE inicount = i4 WITH protect
 DECLARE resp_num_chg = i4 WITH protect, noconstant(size(request->response_rec,5))
 DECLARE updt_id = f8 WITH protect, noconstant(reqinfo->updt_id)
 DECLARE inicount1 = i4 WITH protect
 DECLARE bgrcnt = i4 WITH protect
 CALL echorecord(request,"cer_Temp:cv_response_chgrequest.dat")
 SELECT INTO "nl:"
  FROM cv_response resp,
   (dummyt d  WITH seq = value(resp_num_chg))
  PLAN (d
   WHERE (request->response_rec[d.seq].transaction=cv_trns_chg))
   JOIN (resp
   WHERE (resp.response_id=request->response_rec[d.seq].response_id)
    AND resp.active_ind=1)
  DETAIL
   inicount = (inicount+ 1)
  WITH nocounter, forupdate(resp)
 ;end select
 IF (curqual=0)
  CALL cvnet_add_error(cvnet_lock,cvnet_script_fail,"Didn't Lock cv_response All rows",cvnet_lock_msg,
   0,
   0,0)
  SET failed = "T"
  GO TO response_lock_failed
 ENDIF
 UPDATE  FROM cv_response resp,
   (dummyt d  WITH seq = value(resp_num_chg))
  SET resp.field_type = request->response_rec[d.seq].field_type, resp.response_internal_name =
   request->response_rec[d.seq].response_internal_name, resp.a1 = request->response_rec[d.seq].a1,
   resp.a2 = request->response_rec[d.seq].a2, resp.a3 = request->response_rec[d.seq].a3, resp.a4 =
   request->response_rec[d.seq].a4,
   resp.a5 = request->response_rec[d.seq].a5, resp.xref_id = request->response_rec[d.seq].xref_id,
   resp.updt_cnt = (resp.updt_cnt+ 1),
   resp.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), resp.end_effective_dt_tm = cnvtdatetime
   ("31-dec-2100"), resp.updt_dt_tm = cnvtdatetime(curdate,curtime),
   resp.updt_id = reqinfo->updt_id, resp.updt_task = reqinfo->updt_task, resp.updt_applctx = reqinfo
   ->updt_applctx,
   resp.active_status_cd = reqdata->active_status_cd, resp.updt_req = reqinfo->updt_req, resp
   .updt_app = reqinfo->updt_app
  PLAN (d
   WHERE (request->response_rec[d.seq].transaction=cv_trns_chg))
   JOIN (resp
   WHERE (resp.response_id=request->response_rec[d.seq].response_id)
    AND resp.active_ind=1)
  WITH nocounter
 ;end update
 IF (curqual=0)
  GO TO exit_script
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 GO TO exit_script
 IF (curqual != inicount)
  CALL cvnet_add_error(cvnet_update,cvnet_script_fail,"updating response fields",cvnet_update_msg,0,
   0,0)
  SET failed = "T"
  GO TO response_update_failed
 ENDIF
#response_lock_failed
 SET stat = alter(reply->status_data.subeventstatus,1)
 SET reply->status_data.subeventstatus[1].operationname = "lock_Rows"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "cv_response"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "chg_response table"
 SET failed = "T"
 GO TO exit_script
#response_updt_failed
 SET stat = alter(reply->status_data.subeventstatus,1)
 SET reply->status_data.subeventstatus[1].operationname = "update"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "cv_response"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "chg_response"
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  ROLLBACK
 ELSE
  SET reqinfo->commit_ind = 1
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply,"cer_Temp:cv_response_chgreply.dat")
 EXECUTE cv_updt_response_with_nomen
 DECLARE cv_chg_fld_response_vrsn = vc WITH private, constant("001 BM9013 05/07/2007")
END GO
