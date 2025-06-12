CREATE PROGRAM dm_pcmb_health_concern:dba
 IF ((validate(dm_cmb_cust_script->called_by_readme_ind,- (9))=- (9)))
  RECORD dm_cmb_cust_script(
    1 called_by_readme_ind = i2
    1 exc_maint_ind = i2
  )
 ENDIF
 SUBROUTINE (dm_cmb_get_context(dummy=i2) =null)
   SET dm_cmb_cust_script->called_by_readme_ind = 0
   IF (validate(readme_data->status,"b") != "b"
    AND validate(readme_data->message,"CUSTCMBVALIDATE") != "CUSTCMBVALIDATE")
    SET dm_cmb_cust_script->called_by_readme_ind = 1
   ENDIF
   SET dm_cmb_cust_script->exc_maint_ind = 0
   IF ((validate(dcue_context_rec->called_by_dcue_ind,- (11)) != - (11))
    AND (validate(dcue_context_rec->called_by_dcue_ind,- (22)) != - (22)))
    SET dm_cmb_cust_script->exc_maint_ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE cust_chk_ccl_def_col(ftbl_name,fcol_name)
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE a.table_name=cnvtupper(trim(ftbl_name,3))
     AND l.attr_name=cnvtupper(trim(fcol_name,3))
     AND l.structtype="F"
     AND btest(l.stat,11)=0
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (dm_cmb_exc_maint_status(s_dcems_status=c1,s_dcems_msg=c255,s_dcems_tname=vc) =null)
   SET dcue_upt_exc_reply->status = s_dcems_status
   SET dcue_upt_exc_reply->message = s_dcems_msg
   SET dcue_upt_exc_reply->error_table = s_dcems_tname
 END ;Subroutine
 IF ((validate(dcem_request->qual[1].single_encntr_ind,- (1))=- (1)))
  FREE RECORD dcem_request
  RECORD dcem_request(
    1 qual[*]
      2 parent_entity = vc
      2 child_entity = vc
      2 op_type = vc
      2 script_name = vc
      2 single_encntr_ind = i2
      2 script_run_order = i4
      2 del_chg_id_ind = i2
      2 delete_row_ind = i2
  )
 ENDIF
 IF (validate(dcem_reply->status,"B")="B")
  FREE RECORD dcem_reply
  RECORD dcem_reply(
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 IF (validate(dm_cmb_cust_cols->tbl_name,"X")="X"
  AND validate(dm_cmb_cust_cols->tab_name,"Z")="Z")
  RECORD dm_cmb_cust_cols(
    1 tbl_name = vc
    1 updt_std_val_ind = i2
    1 active_std_val_ind = i2
    1 col[*]
      2 col_name = vc
    1 add_col_val[*]
      2 col_name = vc
      2 col_value = vc
    1 where_col_val[*]
      2 col_name = vc
      2 col_value = vc
    1 sub_select_from_tbl = vc
  )
 ENDIF
 IF (validate(dm_cmb_cust_cols2->tbl_name,"X")="X"
  AND validate(dm_cmb_cust_cols2->tab_name,"Z")="Z")
  RECORD dm_cmb_cust_cols2(
    1 tbl_name = vc
    1 updt_std_val_ind = i2
    1 active_std_val_ind = i2
    1 col[*]
      2 col_name = vc
    1 add_col_val[*]
      2 col_name = vc
      2 col_value = vc
    1 where_col_val[*]
      2 col_name = vc
      2 col_value = vc
    1 sub_select_from_tbl = vc
  )
 ENDIF
 IF (validate(dm_err->ecode,- (1)) < 0)
  FREE RECORD dm_err
  RECORD dm_err(
    1 logfile = vc
    1 debug_flag = i2
    1 ecode = i4
    1 emsg = c132
    1 eproc = vc
    1 err_ind = i2
    1 user_action = vc
    1 asterisk_line = c80
    1 tempstr = vc
    1 errfile = vc
    1 errtext = vc
    1 unique_fname = vc
    1 disp_msg_emsg = vc
    1 disp_dcl_err_ind = i2
  )
  SET dm_err->asterisk_line = fillstring(80,"*")
  SET dm_err->ecode = 0
  IF (validate(dm2_debug_flag,- (1)) > 0)
   SET dm_err->debug_flag = dm2_debug_flag
  ELSE
   SET dm_err->debug_flag = 0
  ENDIF
  SET dm_err->err_ind = 0
  SET dm_err->user_action = "NONE"
  SET dm_err->tempstr = " "
  SET dm_err->errfile = "NONE"
  SET dm_err->logfile = "NONE"
  SET dm_err->unique_fname = "NONE"
  SET dm_err->disp_dcl_err_ind = 1
 ENDIF
 SUBROUTINE (check_error(sbr_ceprocess=vc) =i2)
   DECLARE return_val = i4 WITH protect, noconstant(0)
   IF ((dm_err->err_ind=1))
    SET return_val = 1
   ELSE
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF ((dm_err->ecode != 0))
     SET dm_err->eproc = sbr_ceprocess
     SET dm_err->err_ind = 1
     SET return_val = 1
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 documented_encntr_id = f8
     2 last_updt_encntr_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 health_concern_uuid = vc
     2 health_concern_group_id = f8
 )
 DECLARE v_cust_count = i4
 DECLARE v_cust_loopcount = i4
 DECLARE v_current_dt_tm = dq8
 SET v_cust_count = 0
 SET v_cust_loopcount = 0
 SET v_current_dt_tm = cnvtdatetime(sysdate)
 EXECUTE ccluarxrtl
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "HEALTH_CONCERN"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PCMB_HEALTH_CONCERN"
  SET dcem_request->qual[1].single_encntr_ind = 1
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 SELECT
  IF ((request->xxx_combine[icombine].encntr_id=0))
   WHERE (frm.person_id=request->xxx_combine[icombine].from_xxx_id)
  ELSE
   WHERE (frm.person_id=request->xxx_combine[icombine].from_xxx_id)
    AND (((frm.documented_encntr_id=request->xxx_combine[icombine].encntr_id)) OR ((frm
   .last_updt_encntr_id=request->xxx_combine[icombine].encntr_id)))
  ENDIF
  INTO "nl:"
  frm.*
  FROM health_concern frm
  DETAIL
   v_cust_count += 1
   IF (mod(v_cust_count,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count].from_id = frm.health_concern_id, rreclist->from_rec[v_cust_count]
   .active_ind = frm.active_ind, rreclist->from_rec[v_cust_count].active_status_cd = frm
   .active_status_cd,
   rreclist->from_rec[v_cust_count].documented_encntr_id = frm.documented_encntr_id, rreclist->
   from_rec[v_cust_count].last_updt_encntr_id = frm.last_updt_encntr_id, rreclist->from_rec[
   v_cust_count].beg_effective_dt_tm = frm.beg_effective_dt_tm,
   rreclist->from_rec[v_cust_count].end_effective_dt_tm = frm.end_effective_dt_tm, rreclist->
   from_rec[v_cust_count].health_concern_uuid = frm.health_concern_uuid, rreclist->from_rec[
   v_cust_count].health_concern_group_id = frm.health_concern_group_id
  WITH forupdatewait(frm)
 ;end select
 SET stat = alterlist(rreclist->from_rec,v_cust_count)
 IF (v_cust_count > 0)
  DECLARE from_encntr_id = f8
  DECLARE documented_encntr_id = f8
  DECLARE last_updt_encntr_id = f8
  SET from_encntr_id = request->xxx_combine[icombine].encntr_id
  FOR (v_cust_loopcount = 1 TO v_cust_count)
    IF ((rreclist->from_rec[v_cust_loopcount].active_status_cd != combinedaway)
     AND (rreclist->from_rec[v_cust_loopcount].active_ind=true)
     AND (rreclist->from_rec[v_cust_loopcount].beg_effective_dt_tm <= cnvtdatetime(v_current_dt_tm))
     AND (rreclist->from_rec[v_cust_loopcount].end_effective_dt_tm >= cnvtdatetime(v_current_dt_tm)))
     SET documented_encntr_id = rreclist->from_rec[v_cust_loopcount].documented_encntr_id
     SET last_updt_encntr_id = rreclist->from_rec[v_cust_loopcount].last_updt_encntr_id
     IF (from_encntr_id != 0)
      IF (from_encntr_id=documented_encntr_id)
       IF (add_to(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
        to_xxx_id,documented_encntr_id,documented_encntr_id,rreclist->from_rec[v_cust_loopcount].
        health_concern_uuid,
        rreclist->from_rec[v_cust_loopcount].health_concern_group_id,false)=0)
        GO TO exit_sub
       ENDIF
      ELSE
       DECLARE last_health_concern_id = f8
       IF (add_to(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
        to_xxx_id,last_updt_encntr_id,last_updt_encntr_id,rreclist->from_rec[v_cust_loopcount].
        health_concern_uuid,
        rreclist->from_rec[v_cust_loopcount].health_concern_group_id,true)=0)
        GO TO exit_sub
       ENDIF
       SELECT INTO "nl:"
        FROM health_concern hc
        WHERE (hc.health_concern_uuid=rreclist->from_rec[v_cust_loopcount].health_concern_uuid)
         AND hc.active_ind=0
        ORDER BY hc.last_updt_dt_tm DESC
        HEAD REPORT
         last_health_concern_id = hc.health_concern_id, documented_encntr_id = hc
         .documented_encntr_id, last_updt_encntr_id = hc.last_updt_encntr_id
        WITH nocounter
       ;end select
       IF (curqual=0)
        SET failed = data_error
        SET request->error_message = concat(
         "Couldn't find old health_concern record with hc_uu_id = ",cnvtstring(rreclist->from_rec[
          v_cust_loopcount].health_concern_uuid))
        RETURN(0)
       ENDIF
       IF (add_to(last_health_concern_id,request->xxx_combine[icombine].from_xxx_id,
        documented_encntr_id,last_updt_encntr_id,rreclist->from_rec[v_cust_loopcount].
        health_concern_uuid,
        rreclist->from_rec[v_cust_loopcount].health_concern_group_id,false)=0)
        GO TO exit_sub
       ENDIF
      ENDIF
     ELSE
      IF (add_to(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
       to_xxx_id,documented_encntr_id,last_updt_encntr_id,rreclist->from_rec[v_cust_loopcount].
       health_concern_uuid,
       rreclist->from_rec[v_cust_loopcount].health_concern_group_id,false)=0)
       GO TO exit_sub
      ENDIF
     ENDIF
     IF (del_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
      to_xxx_id,rreclist->from_rec[v_cust_loopcount].active_ind,rreclist->from_rec[v_cust_loopcount].
      active_status_cd,rreclist->from_rec[v_cust_loopcount].end_effective_dt_tm)=0)
      GO TO exit_sub
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE add_to(s_at_from_pk_id,s_at_to_fk_id,documented_encntr_id,last_updt_encntr_id,
  health_concern_uuid,health_concern_group_id,new_health_concern)
   DECLARE v_at_new_id = f8
   DECLARE v_new_instance_uuid = vc
   DECLARE at_active_size = i4
   SET v_at_new_id = 0.0
   SET v_new_instance_uuid = uar_createuuid(0)
   SET at_active_size = 0
   SELECT INTO "nl:"
    y = seq(shx_seq,nextval)
    FROM dual
    DETAIL
     v_at_new_id = cnvtreal(y)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET failed = insert_error
    SET request->error_message = concat("Could not generate a new health_concern_id.",cnvtstring(
      s_at_from_pk_id))
    RETURN(0)
   ENDIF
   IF (new_health_concern)
    SET health_concern_uuid = v_new_instance_uuid
    SET health_concern_group_id = v_at_new_id
   ENDIF
   SET at_active_size = size(dm_cmb_cust_cols->add_col_val,5)
   IF (at_active_size=0)
    SET stat = alterlist(dm_cmb_cust_cols->add_col_val,(at_active_size+ 11))
    SET dm_cmb_cust_cols->add_col_val[(at_active_size+ 1)].col_name = "PERSON_ID"
    SET dm_cmb_cust_cols->add_col_val[(at_active_size+ 1)].col_value = build(s_at_to_fk_id)
    SET dm_cmb_cust_cols->add_col_val[(at_active_size+ 2)].col_name = "HEALTH_CONCERN_ID"
    SET dm_cmb_cust_cols->add_col_val[(at_active_size+ 2)].col_value = build(v_at_new_id)
    SET dm_cmb_cust_cols->add_col_val[(at_active_size+ 3)].col_name = "HEALTH_CONCERN_GROUP_ID"
    SET dm_cmb_cust_cols->add_col_val[(at_active_size+ 3)].col_value = build(health_concern_group_id)
    SET dm_cmb_cust_cols->add_col_val[(at_active_size+ 4)].col_name = "HEALTH_CONCERN_INSTANCE_UUID"
    SET dm_cmb_cust_cols->add_col_val[(at_active_size+ 4)].col_value = build(char(34),
     v_new_instance_uuid,char(34))
    SET dm_cmb_cust_cols->add_col_val[(at_active_size+ 5)].col_name = "HEALTH_CONCERN_UUID"
    SET dm_cmb_cust_cols->add_col_val[(at_active_size+ 5)].col_value = build(char(34),
     health_concern_uuid,char(34))
    SET dm_cmb_cust_cols->add_col_val[(at_active_size+ 6)].col_name = "BEG_EFFECTIVE_DT_TM"
    SET dm_cmb_cust_cols->add_col_val[(at_active_size+ 6)].col_value =
    "cnvtdatetime(v_current_dt_tm)"
    SET dm_cmb_cust_cols->add_col_val[(at_active_size+ 7)].col_name = "LAST_UPDT_ID"
    SET dm_cmb_cust_cols->add_col_val[(at_active_size+ 7)].col_value = build(reqinfo->updt_id)
    SET dm_cmb_cust_cols->add_col_val[(at_active_size+ 8)].col_name = "LAST_UPDT_DT_TM"
    SET dm_cmb_cust_cols->add_col_val[(at_active_size+ 8)].col_value =
    "cnvtdatetime(v_current_dt_tm)"
    SET dm_cmb_cust_cols->add_col_val[(at_active_size+ 9)].col_name = "DOCUMENTED_ENCNTR_ID"
    SET dm_cmb_cust_cols->add_col_val[(at_active_size+ 9)].col_value = build(documented_encntr_id)
    SET dm_cmb_cust_cols->add_col_val[(at_active_size+ 10)].col_name = "LAST_UPDT_ENCNTR_ID"
    SET dm_cmb_cust_cols->add_col_val[(at_active_size+ 10)].col_value = build(last_updt_encntr_id)
    SET dm_cmb_cust_cols->add_col_val[(at_active_size+ 11)].col_name = "ACTIVE_IND"
    SET dm_cmb_cust_cols->add_col_val[(at_active_size+ 11)].col_value = build(1)
   ELSE
    FOR (val_loop = 1 TO at_active_size)
      CASE (dm_cmb_cust_cols->add_col_val[val_loop].col_name)
       OF "PERSON_ID":
        SET dm_cmb_cust_cols->add_col_val[val_loop].col_value = build(s_at_to_fk_id)
       OF "HEALTH_CONCERN_ID":
        SET dm_cmb_cust_cols->add_col_val[val_loop].col_value = build(v_at_new_id)
       OF "HEALTH_CONCERN_GROUP_ID":
        SET dm_cmb_cust_cols->add_col_val[val_loop].col_value = build(health_concern_group_id)
       OF "HEALTH_CONCERN_INSTANCE_UUID":
        SET dm_cmb_cust_cols->add_col_val[val_loop].col_value = build(char(34),v_new_instance_uuid,
         char(34))
       OF "HEALTH_CONCERN_UUID":
        SET dm_cmb_cust_cols->add_col_val[val_loop].col_value = build(char(34),health_concern_uuid,
         char(34))
       OF "BEG_EFFECTIVE_DT_TM":
        SET dm_cmb_cust_cols->add_col_val[val_loop].col_value = "cnvtdatetime(v_current_dt_tm)"
       OF "LAST_UPDT_ID":
        SET dm_cmb_cust_cols->add_col_val[val_loop].col_value = build(reqinfo->updt_id)
       OF "LAST_UPDT_DT_TM":
        SET dm_cmb_cust_cols->add_col_val[val_loop].col_value = "cnvtdatetime(v_current_dt_tm)"
       OF "DOCUMENTED_ENCNTR_ID":
        SET dm_cmb_cust_cols->add_col_val[val_loop].col_value = build(documented_encntr_id)
       OF "LAST_UPDT_ENCNTR_ID":
        SET dm_cmb_cust_cols->add_col_val[val_loop].col_value = build(last_updt_encntr_id)
       OF "ACTIVE_IND":
        SET dm_cmb_cust_cols->add_col_val[val_loop].col_value = build(1)
      ENDCASE
    ENDFOR
   ENDIF
   IF (size(dm_cmb_cust_cols->col,5)=0)
    SET dm_cmb_cust_cols->tbl_name = "HEALTH_CONCERN"
    SET dm_cmb_cust_cols->sub_select_from_tbl = "HEALTH_CONCERN"
    SET dm_cmb_cust_cols->updt_std_val_ind = 1
    EXECUTE dm_cmb_get_cust_cols
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   SET stat = alterlist(dm_cmb_cust_cols->where_col_val,1)
   SET dm_cmb_cust_cols->where_col_val[1].col_name = "HEALTH_CONCERN_ID"
   SET dm_cmb_cust_cols->where_col_val[1].col_value = build(s_at_from_pk_id)
   EXECUTE dm_cmb_ins_cust_row
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = add
   SET request->xxx_combine_det[icombinedet].entity_id = v_at_new_id
   SET request->xxx_combine_det[icombinedet].entity_name = "HEALTH_CONCERN"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE del_from(s_df_pk_id,s_df_to_fk_id,s_df_prev_act_ind,s_df_prev_act_status,
  s_df_prev_end_eff_dt_tm)
   UPDATE  FROM health_concern frm
    SET frm.active_ind = false, frm.active_status_cd = combinedaway, frm.active_status_prsnl_id =
     reqinfo->updt_id,
     frm.active_status_dt_tm = cnvtdatetime(v_current_dt_tm), frm.updt_cnt = (frm.updt_cnt+ 1), frm
     .updt_id = reqinfo->updt_id,
     frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm =
     cnvtdatetime(v_current_dt_tm),
     frm.end_effective_dt_tm = cnvtdatetime(v_current_dt_tm), frm.last_updt_id = reqinfo->updt_id,
     frm.last_updt_dt_tm = cnvtdatetime(v_current_dt_tm)
    WHERE frm.health_concern_id=s_df_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_df_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "HEALTH_CONCERN"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = s_df_prev_act_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = s_df_prev_act_status
   SET request->xxx_combine_det[icombinedet].prev_end_eff_dt_tm = s_df_prev_end_eff_dt_tm
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = concat(
     "Couldn't inactivate health_concern record with health_concern_id = ",cnvtstring(s_df_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_sub
 FREE SET rreclist
END GO
