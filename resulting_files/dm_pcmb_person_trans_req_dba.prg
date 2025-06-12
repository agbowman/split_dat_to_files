CREATE PROGRAM dm_pcmb_person_trans_req:dba
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
 SUBROUTINE add_bb_review_queue(brq_from_person_id,brq_to_person_id,brq_parent_entity_name,
  brq_from_parent_entity_id,brq_to_parent_entity_id,brq_reverse_cmb_ind)
   CALL echo(build("BRQ_reverse_cmb_ind",brq_reverse_cmb_ind))
   SET new_pathnet_seq = 0.0 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = next_pathnet_seq(0)
   CALL echo("km_parent_entity")
   CALL echo(brq_parent_entity_name)
   IF (curqual=0)
    SET failed = select_error
    SET request->error_message = concat("Insert failed to bb_review_queue: 1")
    GO TO exit_script
   ELSE
    INSERT  FROM bb_review_queue bb
     SET bb.bb_review_queue_id = new_pathnet_seq, bb.from_person_id = brq_from_person_id, bb
      .to_person_id = brq_to_person_id,
      bb.parent_entity_name = brq_parent_entity_name, bb.from_parent_entity_id =
      brq_from_parent_entity_id, bb.to_parent_entity_id = brq_to_parent_entity_id,
      bb.rev_cmb_ind = brq_reverse_cmb_ind, bb.review_prsnl_id = 0, bb.review_outcome_cd = 0,
      bb.active_ind = 1, bb.active_status_cd = reqdata->active_status_cd, bb.active_status_dt_tm =
      cnvtdatetime(sysdate),
      bb.active_status_prsnl_id = reqinfo->updt_id, bb.updt_cnt = 0, bb.updt_dt_tm = cnvtdatetime(
       sysdate),
      bb.updt_id = reqinfo->updt_id, bb.updt_task = reqinfo->updt_task, bb.updt_applctx = reqinfo->
      updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = insert_error
     SET request->error_message = concat("Insert bb_review_queue failed")
     GO TO exit_script
    ELSE
     CALL add_combine_log(0,add,new_pathnet_seq,"BB_REVIEW_QUEUE","FROM_PERSON_ID",
      0,0.0)
    ENDIF
   ENDIF
   DECLARE next_pathnet_seq(pathnet_seq_dummy) = f8
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SUBROUTINE next_pathnet_seq(pathnet_seq_dummy)
     SET new_pathnet_seq = 0.0
     SELECT INTO "nl:"
      seqn = seq(pathnet_seq,nextval)
      FROM dual
      DETAIL
       new_pathnet_seq = seqn
      WITH format, nocounter
     ;end select
     RETURN(new_pathnet_seq)
   END ;Subroutine
   SUBROUTINE add_combine_log(sub_to_record_ind,sub_cl_action_cd,sub_entity_id,sub_entity_name,
    sub_attribute_name,sub_previous_active_ind,sub_active_status_cd)
     SET icombinedet += 1
     SET stat = alterlist(request->xxx_combine_det,icombinedet)
     SET request->xxx_combine_det[icombinedet].to_record_ind = sub_to_record_ind
     SET request->xxx_combine_det[icombinedet].combine_action_cd = sub_cl_action_cd
     SET request->xxx_combine_det[icombinedet].entity_id = sub_entity_id
     SET request->xxx_combine_det[icombinedet].entity_name = sub_entity_name
     SET request->xxx_combine_det[icombinedet].attribute_name = sub_attribute_name
     SET request->xxx_combine_det[icombinedet].prev_active_ind = sub_previous_active_ind
     SET request->xxx_combine_det[icombinedet].prev_active_status_cd = sub_active_status_cd
   END ;Subroutine
 END ;Subroutine
 DECLARE next_pathnet_seq(pathnet_seq_dummy) = f8
 DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
 SUBROUTINE next_pathnet_seq(pathnet_seq_dummy)
   SET new_pathnet_seq = 0.0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   RETURN(new_pathnet_seq)
 END ;Subroutine
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 from_requirement_cd = f8
     2 from_match_flg = c1
   1 to_rec[*]
     2 to_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 to_requirement_cd = f8
     2 to_match_flg = c1
 )
 DECLARE v_cust_count1 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_count2 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_loopcount = i4 WITH protect, noconstant(0)
 DECLARE v_cust_loopcount2 = i4 WITH protect, noconstant(0)
 DECLARE to_id_present = i4 WITH protect, noconstant(0)
 DECLARE active_status_codeset = i4 WITH public, constant(48)
 DECLARE inactive_meaning = vc WITH public, constant("INACTIVE")
 SET inactive = uar_get_code_by("MEANING",active_status_codeset,nullterm(inactive_meaning))
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "PERSON_TRANS_REQ"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PCMB_PERSON_TRANS_REQ"
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
    AND frm.active_status_cd != inactive
    AND frm.active_status_cd != combinedaway
  ELSE
   WHERE (frm.person_id=request->xxx_combine[icombine].from_xxx_id)
    AND (frm.encntr_id=request->xxx_combine[icombine].encntr_id)
    AND frm.active_status_cd != inactive
    AND frm.active_status_cd != combinedaway
  ENDIF
  INTO "nl:"
  frm.*
  FROM person_trans_req frm
  HEAD REPORT
   v_cust_count1 = 0
  DETAIL
   v_cust_count1 += 1
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].from_id = frm.person_trans_req_id, rreclist->from_rec[
   v_cust_count1].active_ind = frm.active_ind, rreclist->from_rec[v_cust_count1].active_status_cd =
   frm.active_status_cd,
   rreclist->from_rec[v_cust_count1].from_match_flg = "N", rreclist->from_rec[v_cust_count1].
   from_requirement_cd = frm.requirement_cd
  FOOT REPORT
   stat = alterlist(rreclist->from_rec,v_cust_count1)
  WITH forupdatewait(frm)
 ;end select
 SELECT INTO "nl:"
  tu.*
  FROM person_trans_req tu
  WHERE (tu.person_id=request->xxx_combine[icombine].to_xxx_id)
   AND tu.active_ind=1
  HEAD REPORT
   v_cust_count2 = 0
  DETAIL
   v_cust_count2 += 1
   IF (mod(v_cust_count2,10)=1)
    stat = alterlist(rreclist->to_rec,(v_cust_count2+ 9))
   ENDIF
   rreclist->to_rec[v_cust_count2].to_id = tu.person_trans_req_id, rreclist->to_rec[v_cust_count2].
   active_ind = tu.active_ind, rreclist->to_rec[v_cust_count2].active_status_cd = tu.active_status_cd,
   rreclist->to_rec[v_cust_count2].to_requirement_cd = tu.requirement_cd, rreclist->to_rec[
   v_cust_count2].to_match_flg = "N"
  FOOT REPORT
   stat = alterlist(rreclist->to_rec,v_cust_count2)
  WITH forupdatewait(tu)
 ;end select
 IF (v_cust_count1 > 0)
  CALL echo("MEGHA 01")
  CALL echo(v_cust_count1)
  CALL echo(v_cust_count2)
  SET v_cust_loopcount = 0
  SET v_cust_loopcount2 = 0
  FOR (v_cust_loopcount = 1 TO v_cust_count1)
    FOR (v_cust_loopcount2 = 1 TO v_cust_count2)
      IF ((rreclist->from_rec[v_cust_loopcount].from_requirement_cd=rreclist->to_rec[
      v_cust_loopcount2].to_requirement_cd)
       AND (rreclist->from_rec[v_cust_loopcount].active_ind=1))
       SET rreclist->from_rec[v_cust_loopcount].from_match_flg = "Y"
       SET rreclist->to_rec[v_cust_loopcount2].to_match_flg = "Y"
       SET v_cust_loopcount2 = v_cust_count2
      ENDIF
    ENDFOR
    IF ((rreclist->from_rec[v_cust_loopcount].from_match_flg="N"))
     IF (add_to(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].to_xxx_id
      )=0)
      GO TO exit_sub
     ELSE
      IF ((rreclist->from_rec[v_cust_loopcount].active_ind=1))
       CALL echo("MEGHA - add1")
       IF ((request->cmb_mode != "RE-CMB")
        AND  NOT (recombining))
        CALL add_bb_review_queue(request->xxx_combine[icombine].from_xxx_id,request->xxx_combine[
         icombine].to_xxx_id,"PERSON_TRANS_REQ",rreclist->from_rec[v_cust_loopcount].from_id,0,
         rev_cmb_request->reverse_ind)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF (del_from(rreclist->from_rec[v_cust_loopcount].from_id,rreclist->from_rec[v_cust_loopcount].
     active_ind,rreclist->from_rec[v_cust_loopcount].active_status_cd)=0)
     GO TO exit_sub
    ENDIF
  ENDFOR
  CALL echo(build("megha v_cust_count2",v_cust_count2))
  SET v_cust_loopcount2 = 0
  FOR (v_cust_loopcount2 = 1 TO v_cust_count2)
    CALL echo(build("megha v_cust_loopcount2",v_cust_loopcount2))
    CALL echo(build("megha to_match_flg",rreclist->to_rec[v_cust_loopcount2].to_match_flg))
    IF ((rreclist->to_rec[v_cust_loopcount2].to_match_flg="N"))
     CALL echo("MEGHA - add2")
     IF ((request->cmb_mode != "RE-CMB")
      AND  NOT (recombining))
      CALL add_bb_review_queue(request->xxx_combine[icombine].from_xxx_id,request->xxx_combine[
       icombine].to_xxx_id,"PERSON_TRANS_REQ",0,rreclist->to_rec[v_cust_loopcount2].to_id,
       rev_cmb_request->reverse_ind)
     ENDIF
    ENDIF
  ENDFOR
 ELSEIF (v_cust_count2 > 0)
  CALL echo("MEGHA 02")
  SET v_cust_loopcount2 = 0
  FOR (v_cust_loopcount2 = 1 TO v_cust_count2)
   CALL echo("MEGHA - add3")
   IF ((request->cmb_mode != "RE-CMB")
    AND  NOT (recombining))
    CALL add_bb_review_queue(request->xxx_combine[icombine].from_xxx_id,request->xxx_combine[icombine
     ].to_xxx_id,"PERSON_TRANS_REQ",0,rreclist->to_rec[v_cust_loopcount2].to_id,
     rev_cmb_request->reverse_ind)
   ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE (add_to(s_at_from_pk_id=f8,s_at_to_fk_id=f8) =i4)
   DECLARE v_at_new_id = f8 WITH protect, noconstant(0)
   DECLARE at_acv_size = i4 WITH protect, noconstant(0)
   SET v_at_new_id = next_pathnet_seq(0)
   IF (curqual=0)
    SET failed = gen_nbr_error
    GO TO exit_script
   ENDIF
   CALL echo("MEGHA - INSERT")
   SET dm_cmb_cust_cols->tbl_name = "PERSON_TRANS_REQ"
   SET dm_cmb_cust_cols->sub_select_from_tbl = "PERSON_TRANS_REQ"
   SET dm_cmb_cust_cols->updt_std_val_ind = 0
   SET stat = alterlist(dm_cmb_cust_cols->col,13)
   SET dm_cmb_cust_cols->col[1].col_name = "ENCNTR_ID"
   SET dm_cmb_cust_cols->col[2].col_name = "REQUIREMENT_CD"
   SET dm_cmb_cust_cols->col[3].col_name = "UPDT_APPLCTX"
   SET dm_cmb_cust_cols->col[4].col_name = "UPDT_DT_TM"
   SET dm_cmb_cust_cols->col[5].col_name = "UPDT_ID"
   SET dm_cmb_cust_cols->col[6].col_name = "UPDT_TASK"
   SET dm_cmb_cust_cols->col[7].col_name = "ACTIVE_IND"
   SET dm_cmb_cust_cols->col[8].col_name = "ACTIVE_STATUS_CD"
   SET dm_cmb_cust_cols->col[9].col_name = "ADDED_DT_TM"
   SET dm_cmb_cust_cols->col[10].col_name = "ADDED_PRSNL_ID"
   SET dm_cmb_cust_cols->col[11].col_name = "REMOVED_DT_TM"
   SET dm_cmb_cust_cols->col[12].col_name = "REMOVED_PRSNL_ID"
   SET dm_cmb_cust_cols->col[13].col_name = "CONTRIBUTOR_SYSTEM_CD"
   SET stat = alterlist(dm_cmb_cust_cols->add_col_val,5)
   SET dm_cmb_cust_cols->add_col_val[1].col_name = "PERSON_ID"
   SET dm_cmb_cust_cols->add_col_val[2].col_name = "PERSON_TRANS_REQ_ID"
   SET dm_cmb_cust_cols->add_col_val[3].col_name = "UPDT_CNT"
   SET dm_cmb_cust_cols->add_col_val[4].col_name = "ACTIVE_STATUS_DT_TM"
   SET dm_cmb_cust_cols->add_col_val[5].col_name = "ACTIVE_STATUS_PRSNL_ID"
   SET at_acv_size = size(dm_cmb_cust_cols->add_col_val,5)
   IF (at_acv_size=0)
    SET stat = alterlist(dm_cmb_cust_cols->add_col_val,(at_acv_size+ 5))
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 1)].col_name = "PERSON_ID"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 1)].col_value = build(s_at_to_fk_id)
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 2)].col_name = "PERSON_TRANS_REQ_ID"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 2)].col_value = build(v_at_new_id)
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 3)].col_name = "UPDT_CNT"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 3)].col_value = build(0)
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 4)].col_name = "ACTIVE_STATUS_DT_TM"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 4)].col_value = build(
     "cnvtdatetime(curdate, curtime3)")
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 5)].col_name = "ACTIVE_STATUS_PRSNL_ID"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 5)].col_value = build(reqinfo->updt_id)
   ELSE
    FOR (eecv_loop = 1 TO at_acv_size)
      CASE (dm_cmb_cust_cols->add_col_val[eecv_loop].col_name)
       OF "PERSON_ID":
        SET dm_cmb_cust_cols->add_col_val[eecv_loop].col_value = build(s_at_to_fk_id)
       OF "PERSON_TRANS_REQ_ID":
        SET dm_cmb_cust_cols->add_col_val[eecv_loop].col_value = build(v_at_new_id)
       OF "UPDT_CNT":
        SET dm_cmb_cust_cols->add_col_val[eecv_loop].col_value = build(0)
       OF "ACTIVE_STATUS_DT_TM":
        SET dm_cmb_cust_cols->add_col_val[eecv_loop].col_value = build(
         "cnvtdatetime(curdate, curtime3)")
       OF "ACTIVE_STATUS_PRSNL_ID":
        SET dm_cmb_cust_cols->add_col_val[eecv_loop].col_value = build(reqinfo->updt_id)
      ENDCASE
    ENDFOR
   ENDIF
   SET stat = alterlist(dm_cmb_cust_cols->where_col_val,1)
   SET dm_cmb_cust_cols->where_col_val[1].col_name = "PERSON_TRANS_REQ_ID"
   SET dm_cmb_cust_cols->where_col_val[1].col_value = build(s_at_from_pk_id)
   IF (size(dm_cmb_cust_cols->col,5)=0)
    SET dm_cmb_cust_cols->tbl_name = "PERSON_TRANS_REQ"
    SET dm_cmb_cust_cols->sub_select_from_tbl = "PERSON_TRANS_REQ"
    SET dm_cmb_cust_cols->updt_std_val_ind = 1
    EXECUTE dm_cmb_get_cust_cols
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
   ENDIF
   EXECUTE dm_cmb_ins_cust_row
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = add
   SET request->xxx_combine_det[icombinedet].entity_id = v_at_new_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PERSON_TRANS_REQ"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (del_from(s_df_pk_id=f8,s_df_prev_act_ind=i2,s_df_prev_act_status=f8) =i4)
   UPDATE  FROM person_trans_req frm
    SET frm.active_ind = false, frm.active_status_cd = combinedaway, frm.updt_cnt = (frm.updt_cnt+ 1),
     frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task =
     reqinfo->updt_task,
     frm.updt_dt_tm = cnvtdatetime(sysdate)
    WHERE frm.person_trans_req_id=s_df_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = s_df_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PERSON_TRANS_REQ"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = s_df_prev_act_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = s_df_prev_act_status
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = substring(1,132,build("Could not inactivate pk val=",s_df_pk_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_sub
 FREE SET rreclist
END GO
