CREATE PROGRAM dm_prcmb_ce_rte_prsnl_reltn:dba
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
 SUBROUTINE (gettablecolumns(tablename=vc,primarycolumn=vc,rec_columns=vc(ref)) =i2 WITH protect)
   FREE RECORD cgtcu_excols
   RECORD cgtcu_excols(
     1 cnt = i4
     1 qual[*]
       2 col_name = vc
   )
   DECLARE pk_col = vc WITH protect, noconstant("")
   DECLARE gtc_num = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM user_tab_cols utc
    WHERE utc.table_name=cnvtupper(trim(tablename))
     AND ((utc.hidden_column="YES") OR (((utc.virtual_column="YES") OR (utc.column_name="LAST_UTC_TS"
    )) ))
    HEAD REPORT
     cgtcu_excols->cnt = 0
    DETAIL
     cgtcu_excols->cnt += 1, stat = alterlist(cgtcu_excols->qual,cgtcu_excols->cnt), cgtcu_excols->
     qual[cgtcu_excols->cnt].col_name = utc.column_name
    WITH nocounter
   ;end select
   IF (primarycolumn != null)
    SET pk_col = cnvtupper(trim(primarycolumn))
   ENDIF
   SELECT INTO "nl:"
    l.attr_name
    FROM dtable t,
     dtableattr a,
     dtableattrl l
    WHERE t.table_name=cnvtupper(trim(tablename))
     AND t.table_name=a.table_name
     AND l.structtype="F"
     AND btest(l.stat,11)=0
     AND  NOT (l.attr_name IN (pk_col, "UPDT_APPLCTX", "UPDT_CNT", "UPDT_ID", "UPDT_TASK"))
     AND  NOT (expand(gtc_num,1,cgtcu_excols->cnt,l.attr_name,cgtcu_excols->qual[gtc_num].col_name))
    HEAD REPORT
     rec_columns->column_count = 0
    DETAIL
     rec_columns->column_count += 1
     IF ((rec_columns->column_count > size(rec_columns->list,5)))
      stat = alterlist(rec_columns->list,(rec_columns->column_count+ 9))
     ENDIF
     rec_columns->list[rec_columns->column_count].column_name = l.attr_name
     IF (l.type="F")
      rec_columns->list[rec_columns->column_count].column_type = "F8"
     ELSEIF (l.type="I")
      rec_columns->list[rec_columns->column_count].column_type = build(l.type,l.len)
     ELSEIF (l.type="C")
      IF (btest(l.stat,13))
       rec_columns->list[rec_columns->column_count].column_type = "VC"
      ELSE
       rec_columns->list[rec_columns->column_count].column_type = build(l.type,l.len)
      ENDIF
     ELSEIF (l.type="Q")
      rec_columns->list[rec_columns->column_count].column_type = "DQ8"
     ENDIF
    FOOT REPORT
     stat = alterlist(rec_columns->list,rec_columns->column_count)
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 FREE RECORD rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 ce_rte_prsnl_reltn_id = f8
     2 ce_event_action_id = f8
     2 reltn_type_cd = f8
     2 duplicate_found_ind = i2
     2 col_values[*]
       3 col_value = vc
 )
 FREE RECORD crpr_columns
 RECORD crpr_columns(
   1 column_count = i4
   1 list[*]
     2 column_name = vc
     2 column_type = vc
 )
 DECLARE v_cust_count1 = i4 WITH protect, noconstant(0)
 DECLARE col_idx = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE locateval_idx = i4 WITH protect, noconstant(0)
 DECLARE crpr_errmsg = vc WITH protect, noconstant(fillstring(132," "))
 DECLARE new_list_size = i4 WITH protect, noconstant(0)
 DECLARE cur_list_size = i4 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH protect, constant(200)
 DECLARE nstart = i4 WITH protect, noconstant(0)
 DECLARE loop_cnt = i4 WITH protect, noconstant(0)
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PRSNL"
  SET dcem_request->qual[1].child_entity = "CE_RTE_PRSNL_RELTN"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PRCMB_CE_RTE_PRSNL_RELTN"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 2
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 IF (error(crpr_errmsg,1))
  SET failed = ccl_error
  SET request->error_message = crpr_errmsg
  GO TO exit_sub
 ENDIF
 IF (gettablecolumns("CE_RTE_PRSNL_RELTN","CE_RTE_PRSNL_RELTN_ID",crpr_columns)=0)
  SET failed = select_error
  SET request->error_message = "Unable to retrieve columns for CE_RTE_PRSNL_RELTN table."
  GO TO exit_sub
 ENDIF
 CALL parser(" select into 'nl:'")
 CALL parser(" FRM.*")
 CALL parser(" from CE_RTE_PRSNL_RELTN FRM")
 CALL parser(build(" where FRM.action_prsnl_id = ",request->xxx_combine[icombine].from_xxx_id))
 CALL parser(" detail")
 CALL parser("  v_cust_count1 = v_cust_count1 + 1")
 CALL parser("  if (v_cust_count1 > size(rRecList->from_rec, 5))")
 CALL parser("   stat = alterlist(rRecList->from_rec, v_cust_count1 + 9)")
 CALL parser("  endif")
 CALL parser("  rRecList->from_rec[v_cust_count1].ce_rte_prsnl_reltn_id = FRM.ce_rte_prsnl_reltn_id")
 CALL parser("  rRecList->from_rec[v_cust_count1].ce_event_action_id = FRM.ce_event_action_id")
 CALL parser("  rRecList->from_rec[v_cust_count1].reltn_type_cd = FRM.reltn_type_cd")
 CALL parser("  rRecList->from_rec[v_cust_count1].duplicate_found_ind = 0")
 CALL parser(build("  stat = alterlist(rRecList->from_rec[v_cust_count1].col_values,",crpr_columns->
   column_count,")"))
 FOR (col_idx = 1 TO crpr_columns->column_count)
   IF ((crpr_columns->list[col_idx].column_type="DQ8"))
    CALL parser(build("  rRecList->from_rec[v_cust_count1].col_values[",col_idx,
      "].col_value = format(FRM.",crpr_columns->list[col_idx].column_name,", ';;Q')"))
   ELSEIF ((crpr_columns->list[col_idx].column_type IN ("C*", "VC*")))
    CALL parser(build("  rRecList->from_rec[v_cust_count1].col_values[",col_idx,"].col_value = FRM.",
      crpr_columns->list[col_idx].column_name))
   ELSE
    CALL parser(build("  rRecList->from_rec[v_cust_count1].col_values[",col_idx,
      "].col_value = cnvtstring(FRM.",crpr_columns->list[col_idx].column_name,")"))
   ENDIF
 ENDFOR
 CALL parser(" foot report")
 CALL parser("  stat = alterlist(rRecList->from_rec, v_cust_count1)")
 CALL parser(" with forupdatewait(FRM) go")
 IF (error(crpr_errmsg,0))
  SET failed = select_error
  SET request->error_message = build("Unable to lock ce_rte_prsnl_reltn rows with prsnl_id (",request
   ->xxx_combine[icombine].from_xxx_id,")")
 ENDIF
 SET cur_list_size = size(rreclist->from_rec,5)
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(rreclist->from_rec,new_list_size)
 SET nstart = 1
 FOR (idx = (cur_list_size+ 1) TO new_list_size)
  SET rreclist->from_rec[idx].ce_event_action_id = rreclist->from_rec[cur_list_size].
  ce_event_action_id
  SET rreclist->from_rec[idx].reltn_type_cd = rreclist->from_rec[cur_list_size].reltn_type_cd
 ENDFOR
 IF (v_cust_count1 > 0)
  CALL parser(" select into 'nl:'")
  CALL parser("  TU.*")
  CALL parser(" from (dummyt d1 with seq = value(loop_cnt)), CE_RTE_PRSNL_RELTN TU")
  CALL parser(build("plan d1 where initarray(nstart,evaluate(d1.seq,1,1,nstart+batch_size))",
    "join TU where TU.action_prsnl_id = ",request->xxx_combine[icombine].to_xxx_id,
    " and expand(idx, nstart, nstart+(BATCH_SIZE-1), TU.ce_event_action_id, rRecList->from_rec[idx].ce_event_action_id,",
    "         TU.reltn_type_cd, rRecList->from_rec[idx].reltn_type_cd)"))
  CALL parser(" detail")
  CALL parser(build("  idx = locateval(locateval_idx, 1, v_cust_count1,",
    "          TU.ce_event_action_id, rRecList->from_rec[locateval_idx].ce_event_action_id,",
    "          TU.reltn_type_cd, rRecList->from_rec[locateval_idx].reltn_type_cd)"))
  CALL parser("  if (idx > 0)")
  CALL parser("   rRecList->from_rec[idx].duplicate_found_ind = 1")
  CALL parser("  endif")
  CALL parser(" foot report")
  CALL parser("  stat = alterlist(rRecList->from_rec, cur_list_size)")
  CALL parser(" with forupdatewait(TU) go")
  IF (error(crpr_errmsg,0))
   SET failed = select_error
   SET request->error_message = build(
    "Unable to lock duplicate ce_rte_prsnl_reltn rows with prsnl_id (",request->xxx_combine[icombine]
    .to_xxx_id,")")
  ENDIF
  FOR (loopcount = 1 TO v_cust_count1)
    IF ((rreclist->from_rec[loopcount].duplicate_found_ind=1))
     SET breturn = del_from(rreclist->from_rec[loopcount].ce_rte_prsnl_reltn_id)
     IF (breturn=false)
      GO TO exit_sub
     ENDIF
     FOR (col_idx = 1 TO crpr_columns->column_count)
      SET breturn = cmb_save_column_value("CE_RTE_PRSNL_RELTN",rreclist->from_rec[loopcount].
       ce_rte_prsnl_reltn_id,crpr_columns->list[col_idx].column_name,"",rreclist->from_rec[loopcount]
       .col_values[col_idx].col_value,
       "")
      IF (breturn=false)
       SET failed = insert_error
       SET request->error_message = build(
        "Unable to insert COMBINE_DET_VALUE record with ENTITY_ID = ",rreclist->from_rec[loopcount].
        ce_rte_prsnl_reltn_id)
       GO TO exit_sub
      ENDIF
     ENDFOR
    ELSE
     SET breturn = updt_from(rreclist->from_rec[loopcount].ce_rte_prsnl_reltn_id,request->
      xxx_combine[icombine].to_xxx_id)
     IF (breturn=false)
      GO TO exit_sub
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE (updt_from(s_uf_pk_id=f8,to_fk_id=f8) =i2 WITH protect)
   UPDATE  FROM ce_rte_prsnl_reltn frm
    SET frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo
     ->updt_applctx,
     frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm = frm.updt_dt_tm, frm.action_prsnl_id =
     to_fk_id
    PLAN (frm
     WHERE frm.ce_rte_prsnl_reltn_id=s_uf_pk_id)
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = request->xxx_combine[icombine].from_xxx_id
   SET request->xxx_combine_det[icombinedet].entity_name = "CE_RTE_PRSNL_RELTN"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ACTION_PRSNL_ID"
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "CE_RTE_PRSNL_RELTN_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = s_uf_pk_id
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = build(
     "UPDT_FROM: Unable to update CE_CE_RTE_PRSNL_RELTN record with CE_RTE_PRSNL_RELTN_id = ",
     s_uf_pk_id)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (del_from(s_pk_id=f8) =i2 WITH protect)
   DELETE  FROM ce_rte_prsnl_reltn frm
    WHERE frm.ce_rte_prsnl_reltn_id=s_pk_id
    WITH nocounter
   ;end delete
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = request->xxx_combine[icombine].from_xxx_id
   SET request->xxx_combine_det[icombinedet].entity_name = "CE_RTE_PRSNL_RELTN"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ACTION_PRSNL_ID"
   SET stat = alterlist(request->xxx_combine_det[icombinedet].entity_pk,1)
   SET request->xxx_combine_det[icombinedet].entity_pk[1].col_name = "ce_rte_prsnl_reltn_ID"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_type = "NUMBER"
   SET request->xxx_combine_det[icombinedet].entity_pk[1].data_number = s_pk_id
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = build(
     "DEL_FROM: No values found on the ce_rte_prsnl_reltn table with ce_rte_prsnl_reltn_id = ",
     s_pk_id)
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
#exit_sub
 FREE RECORD rreclist
 FREE RECORD crpr_columns
END GO
