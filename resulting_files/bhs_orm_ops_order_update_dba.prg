CREATE PROGRAM bhs_orm_ops_order_update:dba
 RECORD update_orders(
   1 qual[*]
     2 order_id = f8
     2 order_status_cd = f8
     2 action_type_cd = f8
     2 action = c20
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 updt_cnt = i4
     2 oe_format_id = f8
 )
 RECORD delete_orders(
   1 qual[*]
     2 order_id = f8
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET code_set = 0.0
 SET code_value = 0.0
 SET failed_ind = 0
 SET flag = 0
 SET number_to_change = 0
 SET del_cnt = 0
 SET upd_cnt = 0
 SET now = cnvtdatetime(curdate,curtime3)
 SET ordered_cd = 0.0
 SET discontinued_cd = 0.0
 SET suspended_cd = 0.0
 SET inprocess_cd = 0.0
 SET future_cd = 0.0
 SET incomplete_cd = 0.0
 SET medstudent_cd = 0.0
 SET code_set = 6004
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET ordered_cd = code_value
 CALL echo(build("ordered code:",ordered_cd))
 SET cdf_meaning = "DISCONTINUED"
 EXECUTE cpm_get_cd_for_cdf
 SET discontinued_cd = code_value
 CALL echo(build("discontinued code:",discontinued_cd))
 SET cdf_meaning = "SUSPENDED"
 EXECUTE cpm_get_cd_for_cdf
 SET suspended_cd = code_value
 CALL echo(build("suspend code:",suspended_cd))
 SET cdf_meaning = "INPROCESS"
 EXECUTE cpm_get_cd_for_cdf
 SET inprocess_cd = code_value
 CALL echo(build("in process code:",inprocess_cd))
 SET cdf_meaning = "FUTURE"
 EXECUTE cpm_get_cd_for_cdf
 SET future_cd = code_value
 CALL echo(build("future code:",future_cd))
 SET cdf_meaning = "INCOMPLETE"
 EXECUTE cpm_get_cd_for_cdf
 SET incomplete_cd = code_value
 CALL echo(build("incomplete code:",incomplete_cd))
 SET cdf_meaning = "MEDSTUDENT"
 EXECUTE cpm_get_cd_for_cdf
 SET medstudent_cd = code_value
 CALL echo(build("medstudent code:",medstudent_cd))
 SET status_act_cd = 0.0
 SET code_set = 6003
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "STATUSCHANGE"
 EXECUTE cpm_get_cd_for_cdf
 SET status_act_cd = code_value
 CALL echo(build("stat change code:",status_act_cd))
 SET soft_stop_cd = 0.0
 SET code_set = 4009
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "SOFT"
 EXECUTE cpm_get_cd_for_cdf
 SET soft_stop_cd = code_value
 CALL echo(build("soft stop cd:",soft_stop_cd))
 SET pharm_cd = 0.0
 SET code_set = 6000
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "PHARMACY"
 EXECUTE cpm_get_cd_for_cdf
 SET pharm_cd = code_value
 CALL echo(build("pharmacy cd:",pharm_cd))
 SET system_person_id = 0.0
 DECLARE future_upd_hrs = f8 WITH noconstant(0.0)
 DECLARE incomp_upd_hrs = f8 WITH noconstant(0.0)
 DECLARE mdstud_upd_hrs = f8 WITH noconstant(0.0)
 DECLARE upd_future_orders = i2 WITH noconstant(0)
 DECLARE upd_incomp_orders = i2 WITH noconstant(0)
 DECLARE upd_mdstud_orders = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM config_prefs c
  DETAIL
   IF (c.config_name="FUTUREUPDHRS")
    IF (c.config_value="DO NOT UPDATE")
     upd_future_orders = 0
    ELSE
     upd_future_orders = 1, future_upd_hrs = cnvtreal(c.config_value)
    ENDIF
   ELSEIF (c.config_name="INCOMPUPDHRS")
    IF (c.config_value="DO NOT UPDATE")
     upd_incomp_orders = 0
    ELSE
     upd_incomp_orders = 1, incomp_upd_hrs = cnvtreal(c.config_value)
    ENDIF
   ELSEIF (c.config_name="MDSTUDUPDHRS")
    IF (c.config_value="DO NOT UPDATE")
     upd_mdstud_orders = 0
    ELSE
     upd_mdstud_orders = 1, mdstud_upd_hrs = cnvtreal(c.config_value)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (future_upd_hrs > 0.0)
  SET future_stop_time = datetimeadd(now,- ((future_upd_hrs/ 24)))
 ELSE
  SET future_stop_time = now
 ENDIF
 IF (incomp_upd_hrs > 0.0)
  SET incomp_stop_time = datetimeadd(now,- ((incomp_upd_hrs/ 24)))
 ELSE
  SET incomp_stop_time = now
 ENDIF
 IF (mdstud_upd_hrs > 0.0)
  SET mdstud_stop_time = datetimeadd(now,- ((mdstud_upd_hrs/ 24)))
 ELSE
  SET mdstud_stop_time = now
 ENDIF
 CALL echo(build("future_stop_time = ",format(future_stop_time,";;Q")))
 CALL echo(build("incomp_stop_time = ",format(incomp_stop_time,";;Q")))
 CALL echo(build("mdstud_stop_time = ",format(mdstud_stop_time,";;Q")))
 CALL echo(build("upd_future_orders = ",upd_future_orders))
 CALL echo(build("upd_incomp_orders = ",upd_incomp_orders))
 CALL echo(build("upd_mdstud_orders = ",upd_mdstud_orders))
 SELECT INTO "nl:"
  FROM order_ops ops,
   orders o
  PLAN (ops
   WHERE ops.order_id > 0
    AND ops.ops_flag=1)
   JOIN (o
   WHERE o.order_id=ops.order_id)
  DETAIL
   IF (((o.order_status_cd=ordered_cd) OR (((o.order_status_cd=inprocess_cd) OR (((o.order_status_cd=
   suspended_cd) OR (((o.order_status_cd=incomplete_cd
    AND upd_incomp_orders=1
    AND o.projected_stop_dt_tm <= incomp_stop_time) OR (((o.order_status_cd=medstudent_cd
    AND upd_mdstud_orders=1
    AND o.projected_stop_dt_tm <= mdstud_stop_time) OR (o.order_status_cd=future_cd
    AND upd_future_orders=1
    AND o.projected_stop_dt_tm <= future_stop_time)) )) )) )) )) )
    IF (o.discontinue_effective_dt_tm <= cnvtdatetime(now)
     AND o.discontinue_effective_dt_tm != null
     AND o.discontinue_ind=1
     AND o.need_rx_verify_ind=0)
     upd_cnt = (upd_cnt+ 1)
     IF (upd_cnt > size(update_orders->qual,5))
      stat = alterlist(update_orders->qual,(upd_cnt+ 10))
     ENDIF
     update_orders->qual[upd_cnt].catalog_cd = o.catalog_cd, update_orders->qual[upd_cnt].
     catalog_type_cd = o.catalog_type_cd, update_orders->qual[upd_cnt].updt_cnt = o.updt_cnt,
     update_orders->qual[upd_cnt].oe_format_id = o.oe_format_id, update_orders->qual[upd_cnt].
     order_status_cd = discontinued_cd, update_orders->qual[upd_cnt].action_type_cd = status_act_cd,
     update_orders->qual[upd_cnt].action = "STATUSCHANGE", update_orders->qual[upd_cnt].order_id = o
     .order_id,
     CALL echo(build("---DISCONTINUE--order_id:",update_orders->qual[upd_cnt].order_id))
    ELSE
     IF (((o.template_order_flag=1) OR (((o.template_order_flag=5) OR (((o.constant_ind=1) OR (((o
     .orig_ord_as_flag IN (1, 2, 3, 4)) OR (o.prn_ind=1)) )) )) ))
      AND o.projected_stop_dt_tm <= cnvtdatetime(now)
      AND o.projected_stop_dt_tm != null
      AND o.need_rx_verify_ind=0
      AND o.stop_type_cd != soft_stop_cd)
      upd_cnt = (upd_cnt+ 1)
      IF (upd_cnt > size(update_orders->qual,5))
       stat = alterlist(update_orders->qual,(upd_cnt+ 10))
      ENDIF
      update_orders->qual[upd_cnt].catalog_cd = o.catalog_cd, update_orders->qual[upd_cnt].
      catalog_type_cd = o.catalog_type_cd, update_orders->qual[upd_cnt].updt_cnt = o.updt_cnt,
      update_orders->qual[upd_cnt].oe_format_id = o.oe_format_id, update_orders->qual[upd_cnt].
      order_status_cd = discontinued_cd, update_orders->qual[upd_cnt].action_type_cd = status_act_cd,
      update_orders->qual[upd_cnt].action = "STATUSCHANGE", update_orders->qual[upd_cnt].order_id = o
      .order_id,
      CALL echo(build("---DISCONTINUE--order_id:",update_orders->qual[upd_cnt].order_id))
     ELSE
      IF (o.template_order_flag=0
       AND o.constant_ind=0
       AND o.prn_ind=0
       AND o.catalog_type_cd=pharm_cd
       AND o.projected_stop_dt_tm <= cnvtdatetime(now)
       AND o.projected_stop_dt_tm != null
       AND o.need_rx_verify_ind=0
       AND o.stop_type_cd != soft_stop_cd)
       upd_cnt = (upd_cnt+ 1)
       IF (upd_cnt > size(update_orders->qual,5))
        stat = alterlist(update_orders->qual,(upd_cnt+ 10))
       ENDIF
       update_orders->qual[upd_cnt].catalog_cd = o.catalog_cd, update_orders->qual[upd_cnt].
       catalog_type_cd = o.catalog_type_cd, update_orders->qual[upd_cnt].updt_cnt = o.updt_cnt,
       update_orders->qual[upd_cnt].oe_format_id = o.oe_format_id, update_orders->qual[upd_cnt].
       order_status_cd = discontinued_cd, update_orders->qual[upd_cnt].action_type_cd = status_act_cd,
       update_orders->qual[upd_cnt].action = "STATUSCHANGE", update_orders->qual[upd_cnt].order_id =
       o.order_id,
       CALL echo(build("---DISCONTINUE ONE TIME PHARMACY--order_id:",update_orders->qual[upd_cnt].
        order_id))
      ELSE
       IF (((o.order_status_cd=ordered_cd) OR (o.order_status_cd=inprocess_cd))
        AND o.need_rx_verify_ind < 2
        AND o.suspend_ind=1
        AND o.suspend_effective_dt_tm <= cnvtdatetime(now))
        upd_cnt = (upd_cnt+ 1)
        IF (upd_cnt > size(update_orders->qual,5))
         stat = alterlist(update_orders->qual,(upd_cnt+ 10))
        ENDIF
        update_orders->qual[upd_cnt].catalog_cd = o.catalog_cd, update_orders->qual[upd_cnt].
        catalog_type_cd = o.catalog_type_cd, update_orders->qual[upd_cnt].updt_cnt = o.updt_cnt,
        update_orders->qual[upd_cnt].oe_format_id = o.oe_format_id, update_orders->qual[upd_cnt].
        order_status_cd = suspended_cd, update_orders->qual[upd_cnt].action_type_cd = status_act_cd,
        update_orders->qual[upd_cnt].action = "STATUSCHANGE", update_orders->qual[upd_cnt].order_id
         = o.order_id,
        CALL echo(build("---SUSPEND-- order_id:",update_orders->qual[upd_cnt].order_id))
       ENDIF
       IF (((o.order_status_cd=ordered_cd) OR (((o.order_status_cd=suspended_cd) OR (o
       .order_status_cd=inprocess_cd)) ))
        AND o.need_rx_verify_ind < 2
        AND o.resume_ind=1
        AND o.resume_effective_dt_tm <= cnvtdatetime(now))
        upd_cnt = (upd_cnt+ 1)
        IF (upd_cnt > size(update_orders->qual,5))
         stat = alterlist(update_orders->qual,(upd_cnt+ 10))
        ENDIF
        update_orders->qual[upd_cnt].catalog_cd = o.catalog_cd, update_orders->qual[upd_cnt].
        catalog_type_cd = o.catalog_type_cd, update_orders->qual[upd_cnt].updt_cnt = o.updt_cnt,
        update_orders->qual[upd_cnt].oe_format_id = o.oe_format_id, update_orders->qual[upd_cnt].
        order_status_cd = ordered_cd, update_orders->qual[upd_cnt].action_type_cd = status_act_cd,
        update_orders->qual[upd_cnt].action = "STATUSCHANGE", update_orders->qual[upd_cnt].order_id
         = o.order_id,
        CALL echo(build("---RESUME-- order_id:",update_orders->qual[upd_cnt].order_id))
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    del_cnt = (del_cnt+ 1)
    IF (del_cnt > size(delete_orders->qual,5))
     stat = alterlist(delete_orders->qual,(del_cnt+ 10))
    ENDIF
    delete_orders->qual[del_cnt].order_id = o.order_id,
    CALL echo(build("---DELETE from ORDER_OPS table--order_id:",delete_orders->qual[del_cnt].order_id
     ))
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("-----------------")
 CALL echo(build("Number of Orders_ops row that need to be deleted = ",del_cnt))
 CALL echo("-----------------")
 FOR (i = 1 TO del_cnt)
  DELETE  FROM order_ops ops
   WHERE (ops.order_id=delete_orders->qual[i].order_id)
    AND ops.ops_flag=1
   WITH nocounter
  ;end delete
  COMMIT
 ENDFOR
 CALL echo("-----------------")
 CALL echo(build("Number of Orders to be updated = ",upd_cnt))
 CALL echo("-----------------")
 IF (upd_cnt > 0)
  SET buf = uar_fill_order_request()
  IF (buf > 0)
   SET reply->status_data.subeventstatus[1].operationname = "uar_cont_ord_update"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "uar_fill_order_request"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = cnvtstring(buf)
   SET failed_ind = 1
   GO TO exit_script
  ENDIF
  FOR (i = 1 TO upd_cnt)
    IF ((update_orders->qual[i].order_id > 0))
     CALL echo(build("------------ before uar_fill_order -----order_id:",update_orders->qual[i].
       order_id))
     SET buf = uar_fill_order(update_orders->qual[i].order_id,update_orders->qual[i].order_status_cd,
      update_orders->qual[i].action_type_cd,update_orders->qual[i].action,update_orders->qual[i].
      catalog_cd,
      update_orders->qual[i].catalog_type_cd,update_orders->qual[i].updt_cnt,update_orders->qual[i].
      oe_format_id)
     CALL echo(build("------- after uar_fill_order -----buf:",buf))
     IF (buf > 0)
      CALL echo("------- UAR FAILED !!!! ---------")
      CALL echo(build("order_id        : ",update_orders->qual[i].order_id))
      CALL echo(build("action_type_cd  : ",update_orders->qual[i].action_type_cd))
      CALL echo(build("action          : ",update_orders->qual[i].action))
      CALL echo(build("catalog_cd      : ",update_orders->qual[i].catalog_cd))
      CALL echo(build("catalog_type_cd : ",update_orders->qual[i].catalog_type_cd))
      CALL echo(build("updt_cnt        : ",update_orders->qual[i].updt_cnt))
      CALL echo(build("oe_format_id    : ",update_orders->qual[i].oe_format_id))
      CALL echo("------------------------------------")
      SET reply->status_data.subeventstatus[1].operationname = "uar_cont_ord_update"
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "uar_fill_order"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = cnvtstring(buf)
      SET failed_ind = 1
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
  CALL echo("Calling Order Server: uar_order_perform : --------------")
  SET buf = uar_order_perform()
  CALL echo(build("Back from Order Server: uar_order_perform ----- buf:",buf))
  IF (buf > 0)
   SET reply->status_data.subeventstatus[1].operationname = "uar_cont_ord_update"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "uar_order_perform"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = cnvtstring(buf)
   SET failed_ind = 1
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 CALL echo(build("failed_ind ",failed_ind))
 IF (failed_ind=0)
  CALL echo(build("status    :",reply->status_data.status))
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  CALL echo(build("status    : ",reply->status_data.status))
  CALL echo(build("failed uar: ",reply->status_data.subeventstatus[1].targetobjectname))
  CALL echo(build("buf string: ",reply->status_data.subeventstatus[1].targetobjectvalue))
  ROLLBACK
  SET reqinfo->commit_ind = 0
 ENDIF
#endprog
END GO
