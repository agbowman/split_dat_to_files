CREATE PROGRAM dm_prcmb_rad_wrklst_def:dba
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
 DECLARE cmb_save_col_value(sv_pk_value,sv_col_name,sv_from,sv_to) = i2
 DECLARE cmb_read_col_value(rv_col_name) = i2
 DECLARE cmb_save_column_value(svf_tbl_name,svf_pk_value,svf_col_name,svf_col_type,svf_from,
  svf_to) = i2
 DECLARE cmb_read_column_value(rvf_tbl_name,rvf_pk_value,rvf_rv_col_name) = i2
 RECORD cmb_det_value(
   1 table_name = vc
   1 column_name = vc
   1 column_type = vc
   1 from_value = vc
   1 to_value = vc
 )
 SUBROUTINE cmb_save_col_value(sv_pk_value,sv_col_name,sv_from,sv_to)
  SET sv_return = cmb_save_column_value(rcmblist->custom[maincount3].table_name,sv_pk_value,
   sv_col_name,"",sv_from,
   sv_to)
  RETURN(sv_return)
 END ;Subroutine
 SUBROUTINE cmb_save_column_value(svf_tbl_name,svf_pk_value,svf_col_name,svf_col_type,svf_from,svf_to
  )
   IF (((svf_tbl_name="") OR (svf_tbl_name=" ")) )
    SET svf_tbl_name = rcmblist->custom[maincount3].table_name
   ENDIF
   INSERT  FROM combine_det_value
    SET combine_det_value_id = seq(combine_seq,nextval), combine_id = request->xxx_combine[icombine].
     xxx_combine_id, combine_parent = evaluate(cnvtupper(trim(request->parent_table,3)),"ENCOUNTER",
      "ENCNTR_COMBINE","PERSON","PERSON_COMBINE",
      "COMBINE"),
     parent_entity = request->parent_table, entity_name = cnvtupper(svf_tbl_name), entity_id =
     svf_pk_value,
     column_name = cnvtupper(svf_col_name), column_type = evaluate(svf_col_type,"",null,svf_col_type),
     from_value = svf_from,
     to_value = evaluate(svf_to,"",null,svf_to), updt_cnt = 0, updt_id = reqinfo->updt_id,
     updt_applctx = reqinfo->updt_applctx, updt_task = reqinfo->updt_task, updt_dt_tm = cnvtdatetime(
      sysdate)
    WITH nocounter
   ;end insert
   RETURN(curqual)
 END ;Subroutine
 SUBROUTINE cmb_read_col_value(rv_col_name)
  SET rv_return = cmb_read_column_value(rchildren->qual1[det_cnt].entity_name,rchildren->qual1[
   det_cnt].entity_id,rv_col_name)
  RETURN(rv_return)
 END ;Subroutine
 SUBROUTINE cmb_read_column_value(rv_tbl_name,rv_pk_value,rv_col_name)
   SET cmb_det_value->table_name = ""
   SET cmb_det_value->column_name = ""
   SET cmb_det_value->from_value = ""
   SET cmb_det_value->to_value = ""
   IF (((rv_tbl_name="") OR (rv_tbl_name=" ")) )
    SET rv_tbl_name = rchildren->qual1[det_cnt].entity_name
   ENDIF
   IF (rv_pk_value=0)
    SET rv_pk_value = rchildren->qual1[det_cnt].entity_id
   ENDIF
   SELECT INTO "nl:"
    v.column_name, v.from_value, v.to_value
    FROM combine_det_value v
    WHERE (v.combine_id=request->xxx_uncombine[ucb_cnt].xxx_combine_id)
     AND v.combine_parent=evaluate(cnvtupper(trim(request->parent_table,3)),"ENCOUNTER",
     "ENCNTR_COMBINE","PERSON","PERSON_COMBINE",
     "COMBINE")
     AND (v.parent_entity=request->parent_table)
     AND v.entity_name=cnvtupper(rv_tbl_name)
     AND v.entity_id=rv_pk_value
     AND v.column_name=cnvtupper(rv_col_name)
    DETAIL
     cmb_det_value->table_name = v.entity_name, cmb_det_value->column_name = v.column_name,
     cmb_det_value->column_type = v.column_type,
     cmb_det_value->from_value = v.from_value, cmb_det_value->to_value = v.to_value
    WITH nocounter
   ;end select
   RETURN(curqual)
 END ;Subroutine
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 prsnl_id = f8
     2 wrklst_type_cd = i8
     2 wrklst_name = vc
     2 logical_domain_id = f8
   1 to_rec[*]
     2 to_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 prsnl_id = f8
     2 wrklst_name = vc
     2 logical_domain_id = f8
 )
 DECLARE upt_from(s_uf_pk_id=f8,s_uf_to_fk_id=f8) = i4
 DECLARE v_cust_count1 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_count2 = i4 WITH protect, noconstant(0)
 DECLARE v_cust_loopcount = i4 WITH protect, noconstant(0)
 DECLARE v_cust_loopcount2 = i4 WITH protect, noconstant(0)
 DECLARE to_id_present = i4 WITH protect, noconstant(0)
 DECLARE v_wrklst_name_seq = i4 WITH protect, noconstant(1)
 DECLARE new_wrklst_name = vc
 DECLARE wrklst_name_len = f8 WITH protect, noconstant(0)
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PRSNL"
  SET dcem_request->qual[1].child_entity = "RAD_WRKLST_DEF"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PRCMB_RAD_WRKLST_DEF"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 SELECT INTO "nl:"
  frm.*
  FROM rad_wrklst_def frm
  WHERE (frm.prsnl_id=request->xxx_combine[icombine].from_xxx_id)
   AND frm.active_ind=1
  DETAIL
   v_cust_count1 += 1
   IF (mod(v_cust_count1,10)=1)
    stat = alterlist(rreclist->from_rec,(v_cust_count1+ 9))
   ENDIF
   rreclist->from_rec[v_cust_count1].from_id = frm.rad_wrklst_def_id, rreclist->from_rec[
   v_cust_count1].active_ind = frm.active_ind, rreclist->from_rec[v_cust_count1].active_status_cd =
   frm.active_status_cd,
   rreclist->from_rec[v_cust_count1].prsnl_id = frm.prsnl_id, rreclist->from_rec[v_cust_count1].
   logical_domain_id = frm.logical_domain_id, rreclist->from_rec[v_cust_count1].wrklst_name = frm
   .wrklst_name
  WITH forupdatewait(frm)
 ;end select
 IF (v_cust_count1 > 0)
  SELECT INTO "nl:"
   tu.*
   FROM rad_wrklst_def tu
   WHERE (tu.prsnl_id=request->xxx_combine[icombine].to_xxx_id)
    AND tu.active_ind=1
   DETAIL
    v_cust_count2 += 1
    IF (mod(v_cust_count2,10)=1)
     stat = alterlist(rreclist->to_rec,(v_cust_count2+ 9))
    ENDIF
    rreclist->to_rec[v_cust_count2].to_id = tu.rad_wrklst_def_id, rreclist->to_rec[v_cust_count2].
    active_ind = tu.active_ind, rreclist->to_rec[v_cust_count2].active_status_cd = tu
    .active_status_cd,
    rreclist->to_rec[v_cust_count2].prsnl_id = tu.prsnl_id, rreclist->to_rec[v_cust_count2].
    logical_domain_id = tu.logical_domain_id, rreclist->to_rec[v_cust_count2].wrklst_name = tu
    .wrklst_name
   WITH forupdatewait(tu)
  ;end select
  FOR (v_cust_loopcount = 1 TO v_cust_count1)
   FOR (v_cust_loopcount2 = 1 TO v_cust_count2)
     IF ((rreclist->from_rec[v_cust_loopcount].logical_domain_id=rreclist->to_rec[v_cust_loopcount2].
     logical_domain_id)
      AND (rreclist->from_rec[v_cust_loopcount].wrklst_name=rreclist->to_rec[v_cust_loopcount2].
     wrklst_name))
      SET to_id_present = 1
     ENDIF
   ENDFOR
   IF (to_id_present=1)
    SET wrklst_name_len = size(rreclist->from_rec[v_cust_loopcount].wrklst_name)
    IF (wrklst_name_len > 47)
     IF (v_wrklst_name_seq > 9)
      SET failed = data_error
      SET request->error_message = build("DATA ERROR:There are too many worklist with same name.",
       " From id = ",request->xxx_combine[icombine].from_xxx_id," to id = ",request->xxx_combine[
       icombine].to_xxx_id)
      GO TO exit_sub
     ENDIF
     SET new_wrklst_name = substring(1,47,rreclist->from_rec[v_cust_loopcount].wrklst_name)
    ELSE
     SET new_wrklst_name = rreclist->from_rec[v_cust_loopcount].wrklst_name
    ENDIF
    SET new_wrklst_name = build(new_wrklst_name,"(",v_wrklst_name_seq,")")
    SET v_wrklst_name_seq += 1
    IF (upt_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
     to_xxx_id,new_wrklst_name)=1)
     IF (log_to_combine_detail(rreclist->from_rec[v_cust_loopcount].from_id,rreclist->from_rec[
      v_cust_loopcount].wrklst_name,new_wrklst_name)=0)
      GO TO exit_sub
     ENDIF
    ELSE
     GO TO exit_sub
    ENDIF
   ELSE
    IF (upt_from(rreclist->from_rec[v_cust_loopcount].from_id,request->xxx_combine[icombine].
     to_xxx_id,rreclist->from_rec[v_cust_loopcount].wrklst_name)=1)
     IF (log_to_combine_detail(rreclist->from_rec[v_cust_loopcount].from_id,rreclist->from_rec[
      v_cust_loopcount].wrklst_name,rreclist->from_rec[v_cust_loopcount].wrklst_name)=0)
      GO TO exit_sub
     ENDIF
    ELSE
     GO TO exit_sub
    ENDIF
   ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE upt_from(s_uf_pk_id,s_uf_to_fk_id,s_to_wrklst_name)
   UPDATE  FROM rad_wrklst_def frm
    SET frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo
     ->updt_applctx,
     frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm = cnvtdatetime(sysdate), frm.prsnl_id =
     s_uf_to_fk_id,
     frm.wrklst_name = s_to_wrklst_name
    WHERE frm.rad_wrklst_def_id=s_uf_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_name = "RAD_WRKLST_DEF"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PRSNL_ID"
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "RAD_WRKLST_DEF_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = s_uf_pk_id
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = build(
     "Couldn't update rad_wrklst_def record with rad_wrklst_def_id = ",s_uf_pk_id)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (log_to_combine_detail(rad_wrklst_def_id=f8,old_wrklst_name=vc,new_wrklst_name=vc) =i4)
   DECLARE return_value = i4
   SET return_value = cmb_save_column_value("RAD_WRKLST_DEF",rad_wrklst_def_id,"WRKLST_NAME","VC",
    old_wrklst_name,
    new_wrklst_name)
   IF (return_value=0)
    SET failed = insert_error
    SET request->error_message = "Could not save wrklst_name in cmb_save_column_value"
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SET ecode = 0
 SET emsg = fillstring(132," ")
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SET failed = ccl_error
 ENDIF
#exit_sub
 FREE SET rreclist
END GO
