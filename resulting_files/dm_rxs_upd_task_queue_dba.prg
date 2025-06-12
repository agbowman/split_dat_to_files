CREATE PROGRAM dm_rxs_upd_task_queue:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failed: starting script dm_rxs_upd_task_queue..."
 DECLARE getcodevalue(codeset=i4,meaning=vc) = f8 WITH protect
 DECLARE getprefvalue(blob=vc(ref),pref_key=vc) = vc WITH protect
 DECLARE getexpiryhours(null) = f8 WITH protect
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE maxid = f8 WITH protect, noconstant(0.0)
 DECLARE minid = f8 WITH protect, noconstant(0.0)
 DECLARE curminid = f8 WITH protect, noconstant(0.0)
 DECLARE curmaxid = f8 WITH protect, noconstant(0.0)
 DECLARE batchsize = i4 WITH protect, noconstant(250000)
 DECLARE cluster_preferences = vc WITH protect, constant("RX_CLUSTER_PREFERENCES")
 DECLARE pending_cd = f8 WITH protect, constant(getcodevalue(4904,"PENDING"))
 DECLARE rxs_view_cd = f8 WITH protect, constant(getcodevalue(222,"RXSVIEW"))
 DECLARE current_dt_tm = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE expiry_hours = f8 WITH protect, constant(getexpiryhours(null))
 SUBROUTINE getcodevalue(codeset,meaning)
   DECLARE codevalue = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=codeset
     AND cv.cdf_meaning=meaning
    ORDER BY cv.code_value
    HEAD cv.code_value
     codevalue = cv.code_value
    WITH nocounter
   ;end select
   IF (error(errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("getCodeValues(): ",errmsg)
    GO TO exit_script
   ENDIF
   IF (codevalue=0.0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("No code value exists for code set ",codeset," meaning ",
     meaning)
    GO TO exit_script
   ENDIF
   RETURN(codevalue)
 END ;Subroutine
 SUBROUTINE getprefvalue(blob,pref_key)
   DECLARE key_beg_idx = i4 WITH protect, noconstant(0)
   DECLARE delimeter_idx = i4 WITH protect, noconstant(0)
   DECLARE value_end_idx = i4 WITH protect, noconstant(0)
   DECLARE key_size = i4 WITH protect, constant(size(pref_key,1))
   DECLARE newline = c1 WITH protect, constant(char(10))
   CALL echo(build("key: ",pref_key," Key Size: ",key_size))
   IF (((blob="") OR (key_size=0)) )
    RETURN("")
   ENDIF
   SET key_beg_idx = findstring(pref_key,blob,1)
   CALL echo(build("Key beg_idx=",key_beg_idx))
   IF (key_beg_idx=0)
    RETURN("")
   ENDIF
   SET delimeter_idx = findstring("=",blob,key_beg_idx)
   CALL echo(build("delimeter_idx=",delimeter_idx))
   IF (((delimeter_idx <= key_beg_idx) OR ((delimeter_idx != (key_beg_idx+ key_size)))) )
    RETURN("")
   ENDIF
   SET value_end_idx = findstring(newline,blob,delimeter_idx)
   CALL echo(build("value_end_idx=",value_end_idx))
   IF (value_end_idx <= delimeter_idx)
    RETURN("")
   ENDIF
   RETURN(trim(substring((delimeter_idx+ 1),(value_end_idx - (delimeter_idx+ 1)),blob)))
 END ;Subroutine
 SUBROUTINE getexpiryhours(null)
   DECLARE expiryhours = f8 WITH protect, noconstant(1.0)
   DECLARE prefvalue = vc WITH protect, noconstant("")
   DECLARE blob = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM code_value_extension cve_pref,
     long_text_reference ltr
    PLAN (cve_pref
     WHERE cve_pref.code_value=rxs_view_cd
      AND cve_pref.code_set=222
      AND cve_pref.field_name=cluster_preferences)
     JOIN (ltr
     WHERE ltr.long_text_id=cnvtreal(cve_pref.field_value)
      AND ltr.active_ind=1)
    ORDER BY ltr.long_text_id
    HEAD ltr.long_text_id
     blob = ltr.long_text, prefvalue = getprefvalue(blob,"rxs.order.task.queue.expiry.hrs"),
     CALL echo(build("Global expiry value=",prefvalue))
     IF (isnumeric(prefvalue) != 0)
      expiryhours = cnvtreal(prefvalue)
     ENDIF
    WITH nocounter
   ;end select
   IF (error(errmsg,0) != 0)
    SET readme_data->status = "F"
    SET readme_data->status = concat("Failed to get expiry minutes: ",errmsg)
    GO TO exit_script
   ENDIF
   CALL echo(build("Expiry hours=",expiryhours))
   RETURN(expiryhours)
 END ;Subroutine
 SELECT INTO "nl:"
  minidval = min(r.rxs_order_task_queue_id)
  FROM rxs_order_task_queue r
  WHERE r.rxs_order_task_queue_id > 0
  DETAIL
   minid = maxval(minidval,1.0)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->status = concat("Failed to get minimum ID: ",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  maxidval = max(r.rxs_order_task_queue_id)
  FROM rxs_order_task_queue r
  DETAIL
   maxid = maxidval
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->status = concat("Failed to get maximum ID: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (minid > maxid)
  SET readme_data->status = "S"
  SET readme_data->message = "No work needs to be done; exiting"
  GO TO exit_script
 ENDIF
 SET curminid = minid
 SET curmaxid = ((curminid+ batchsize) - 1)
 WHILE (curminid <= maxid)
   UPDATE  FROM rxs_order_task_queue r
    SET r.state_cd = pending_cd, r.encntr_id =
     (SELECT
      o.encntr_id
      FROM orders o
      WHERE o.order_id=r.order_id), r.begin_effective_dt_tm = r.updt_dt_tm,
     r.end_effective_dt_tm = datetimeadd(r.updt_dt_tm,(expiry_hours/ 24.0)), r.state_dt_tm =
     cnvtdatetime(current_dt_tm), r.updt_applctx = reqinfo->updt_applctx,
     r.updt_cnt = (r.updt_cnt+ 1), r.updt_dt_tm = cnvtdatetime(current_dt_tm), r.updt_id = reqinfo->
     updt_id,
     r.updt_task = reqinfo->updt_task
    WHERE r.rxs_order_task_queue_id BETWEEN curminid AND curmaxid
     AND r.state_cd=0.0
    WITH nocounter
   ;end update
   IF (error(errmsg,0) != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to update RXS_ORDER_TASK_QUEUE table: ",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
   UPDATE  FROM rxs_order_task_queue r
    SET r.encntr_id =
     (SELECT
      o.encntr_id
      FROM orders o
      WHERE o.order_id=r.order_id), r.state_dt_tm = cnvtdatetime(current_dt_tm), r.updt_applctx =
     reqinfo->updt_applctx,
     r.updt_cnt = (r.updt_cnt+ 1), r.updt_dt_tm = cnvtdatetime(current_dt_tm), r.updt_id = reqinfo->
     updt_id,
     r.updt_task = reqinfo->updt_task
    WHERE r.rxs_order_task_queue_id BETWEEN curminid AND curmaxid
     AND r.encntr_id=0.0
    WITH nocounter
   ;end update
   IF (error(errmsg,0) != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed to update RXS_ORDER_TASK_QUEUE table: ",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
   SET curminid = (curmaxid+ 1)
   SET curmaxid = ((curminid+ batchsize) - 1)
 ENDWHILE
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Readme performed all required tasks"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
