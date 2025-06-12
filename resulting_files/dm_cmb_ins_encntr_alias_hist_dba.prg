CREATE PROGRAM dm_cmb_ins_encntr_alias_hist:dba
 IF ((validate(dcieah_request->encntr_alias_hist_id,- (9))=- (9)))
  RECORD dcieah_request(
    1 encntr_alias_hist_id = f8
    1 pm_hist_tracking_id = f8
    1 encntr_alias_id = f8
    1 encntr_id = f8
    1 alias = c200
  )
 ENDIF
 IF (validate(dcieah_reply->status,"b")="b")
  FREE RECORD dcieah_reply
  RECORD dcieah_reply(
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 INSERT  FROM encntr_alias_hist p
  SET p.encntr_alias_hist_id = dcieah_request->encntr_alias_hist_id, p.pm_hist_tracking_id =
   dcieah_request->pm_hist_tracking_id, p.encntr_alias_id = dcieah_request->encntr_alias_id,
   p.encntr_id = dcieah_request->encntr_id, p.change_bit = 0, p.tracking_bit = 1,
   p.transaction_dt_tm = cnvtdatetime(curdate,curtime3), p.alias = dcieah_request->alias, p
   .active_ind = 1,
   p.active_status_cd = reqdata->active_status_cd, p.active_status_dt_tm = cnvtdatetime(curdate,
    curtime3), p.active_status_prsnl_id = reqinfo->updt_id,
   p.updt_applctx = reqinfo->updt_applctx, p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->
   updt_task,
   p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (error(dcieah_reply->err_msg,1) != 0)
  SET dcieah_reply->status = "F"
 ELSE
  SET dcieah_reply->status = "S"
 ENDIF
END GO
