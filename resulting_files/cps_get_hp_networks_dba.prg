CREATE PROGRAM cps_get_hp_networks:dba
 RECORD reply(
   1 networks[*]
     2 network_id = f8
     2 network_name = vc
     2 network_description = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 cps_error
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
 )
 SET count = 0
 DECLARE cps_lock = i4 WITH public, constant(100)
 DECLARE cps_no_seq = i4 WITH public, constant(101)
 DECLARE cps_updt_cnt = i4 WITH public, constant(102)
 DECLARE cps_insuf_data = i4 WITH public, constant(103)
 DECLARE cps_update = i4 WITH public, constant(104)
 DECLARE cps_insert = i4 WITH public, constant(105)
 DECLARE cps_delete = i4 WITH public, constant(106)
 DECLARE cps_select = i4 WITH public, constant(107)
 DECLARE cps_auth = i4 WITH public, constant(108)
 DECLARE cps_inval_data = i4 WITH public, constant(109)
 DECLARE cps_ens_note_story_not_locked = i4 WITH public, constant(110)
 DECLARE cps_lock_msg = c33 WITH public, constant("Failed to lock all requested rows")
 DECLARE cps_no_seq_msg = c34 WITH public, constant("Failed to get next sequence number")
 DECLARE cps_updt_cnt_msg = c28 WITH public, constant("Failed to match update count")
 DECLARE cps_insuf_data_msg = c38 WITH public, constant("Request did not supply sufficient data")
 DECLARE cps_update_msg = c24 WITH public, constant("Failed on update request")
 DECLARE cps_insert_msg = c24 WITH public, constant("Failed on insert request")
 DECLARE cps_delete_msg = c24 WITH public, constant("Failed on delete request")
 DECLARE cps_select_msg = c24 WITH public, constant("Failed on select request")
 DECLARE cps_auth_msg = c34 WITH public, constant("Failed on authorization of request")
 DECLARE cps_inval_data_msg = c35 WITH public, constant("Request contained some invalid data")
 DECLARE cps_success = i4 WITH public, constant(0)
 DECLARE cps_success_info = i4 WITH public, constant(1)
 DECLARE cps_success_warn = i4 WITH public, constant(2)
 DECLARE cps_deadlock = i4 WITH public, constant(3)
 DECLARE cps_script_fail = i4 WITH public, constant(4)
 DECLARE cps_sys_fail = i4 WITH public, constant(5)
 IF ((request->carrier_id=0.0)
  AND (request->health_plan_id=0.0))
  CALL cps_add_error(cps_inval_data,cps_script_fail,"No HP/Carrier id specified",cps_inval_data_msg,0,
   0,0)
  GO TO exit_script
 ENDIF
 IF ((request->carrier_id != 0.0)
  AND (request->health_plan_id != 0.0))
  CALL cps_add_error(cps_inval_data,cps_script_fail,"Both HP/Carrier id specified",cps_inval_data_msg,
   0,
   0,0)
  GO TO exit_script
 ENDIF
 IF ((request->beg_effective_dt_tm <= 0))
  SET request->beg_effective_dt_tm = cnvtdatetime(curdate,curtime3)
 ENDIF
 IF ((request->end_effective_dt_tm <= 0))
  SET request->end_effective_dt_tm = cnvtdatetime(curdate,curtime3)
 ENDIF
 SET stat = alterlist(reply->networks,100)
 IF ((request->health_plan_id != 0.0))
  SELECT INTO "nl:"
   FROM plan_ntwk_r pnr,
    network n
   PLAN (pnr
    WHERE (pnr.health_plan_id=request->health_plan_id))
    JOIN (n
    WHERE n.network_id=pnr.network_id
     AND n.beg_effective_dt_tm <= cnvtdatetime(request->beg_effective_dt_tm)
     AND n.end_effective_dt_tm > cnvtdatetime(request->end_effective_dt_tm))
   DETAIL
    count = (count+ 1)
    IF (mod(count,100)=0)
     stat = alterlist(reply->networks,(count+ 100))
    ENDIF
    reply->networks[count].network_id = n.network_id, reply->networks[count].network_name = n
    .network_name, reply->networks[count].network_description = n.network_description,
    reply->networks[count].beg_effective_dt_tm = n.beg_effective_dt_tm, reply->networks[count].
    beg_effective_dt_tm = n.end_effective_dt_tm
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM network n
   WHERE (n.carrier_id=request->carrier_id)
    AND n.beg_effective_dt_tm <= cnvtdatetime(request->beg_effective_dt_tm)
    AND n.end_effective_dt_tm > cnvtdatetime(request->end_effective_dt_tm)
   DETAIL
    count = (count+ 1)
    IF (mod(count,100)=0)
     stat = alterlist(reply->networks,(count+ 100))
    ENDIF
    reply->networks[count].network_id = n.network_id, reply->networks[count].network_name = n
    .network_name, reply->networks[count].network_description = n.network_description,
    reply->networks[count].beg_effective_dt_tm = n.beg_effective_dt_tm, reply->networks[count].
    beg_effective_dt_tm = n.end_effective_dt_tm
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->networks,count)
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 SUBROUTINE cps_add_error(cps_errcode,severity_level,supp_err_txt,def_msg,idx1,idx2,idx3)
   SET reply->cps_error.cnt = (reply->cps_error.cnt+ 1)
   SET errcnt = reply->cps_error.cnt
   SET stat = alterlist(reply->cps_error.data,errcnt)
   SET reply->cps_error.data[errcnt].code = cps_errcode
   SET reply->cps_error.data[errcnt].severity_level = severity_level
   SET reply->cps_error.data[errcnt].supp_err_txt = supp_err_txt
   SET reply->cps_error.data[errcnt].def_msg = def_msg
   SET reply->cps_error.data[errcnt].row_data.lvl_1_idx = idx1
   SET reply->cps_error.data[errcnt].row_data.lvl_2_idx = idx2
   SET reply->cps_error.data[errcnt].row_data.lvl_3_idx = idx3
 END ;Subroutine
#exit_script
END GO
