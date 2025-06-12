CREATE PROGRAM dm_prucb_ce_rte_prsnl_reltn:dba
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
 FREE RECORD crpr_columns
 RECORD crpr_columns(
   1 column_count = i4
   1 list[*]
     2 column_name = vc
     2 column_type = vc
 )
 FREE RECORD crpr_temp_rec
 RECORD crpr_temp_rec(
   1 from_values[*]
     2 col_value = vc
     2 col_populated_ind = i2
 )
 DECLARE cust_ucb_dummy = i4 WITH protect, noconstant(0)
 DECLARE col_idx = i4 WITH protect, noconstant(0)
 DECLARE crpr_errmsg = vc WITH protect, noconstant(fillstring(132," "))
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PRSNL"
  SET dcem_request->qual[1].child_entity = "CE_RTE_PRSNL_RELTN"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_PRUCB_CE_RTE_PRSNL_RELTN"
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
  SET ucb_failed = ccl_error
  SET request->error_message = crpr_errmsg
  GO TO exit_sub
 ENDIF
 IF ((rchildren->qual1[det_cnt].combine_action_cd=upt))
  CALL cust_ucb_upt(cust_ucb_dummy)
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=del))
  CALL cust_ucb_del(cust_ucb_dummy)
 ELSE
  SET ucb_failed = data_error
  SET error_table = rchildren->qual1[det_cnt].entity_name
  GO TO exit_sub
 ENDIF
 SUBROUTINE cust_ucb_upt(dummy)
   IF ((rchildren->qual1[det_cnt].attribute_name="ACTION_PRSNL_ID"))
    UPDATE  FROM ce_rte_prsnl_reltn crpr
     SET crpr.action_prsnl_id = request->xxx_uncombine[ucb_cnt].to_xxx_id, crpr.updt_dt_tm = crpr
      .updt_dt_tm, crpr.updt_applctx = reqinfo->updt_applctx,
      crpr.updt_id = reqinfo->updt_id, crpr.updt_cnt = (crpr.updt_cnt+ 1), crpr.updt_task = reqinfo->
      updt_task
     WHERE (crpr.ce_rte_prsnl_reltn_id=rchildren->qual1[det_cnt].entity_pk[1].data_number)
      AND (crpr.action_prsnl_id=request->xxx_uncombine[ucb_cnt].from_xxx_id)
     WITH nocounter
    ;end update
   ENDIF
   IF (error(crpr_errmsg,0))
    SET ucb_failed = update_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    SET request->error_message = build("Unable to update ce_rte_prsnl_reltn_id (",rchildren->qual1[
     det_cnt].entity_id,") with prsnl_id (",request->xxx_uncombine[ucb_cnt].to_xxx_id,")")
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
 SUBROUTINE cust_ucb_del(dummy)
   DECLARE pk_value = f8 WITH protect, noconstant(0.0)
   IF (gettablecolumns("CE_RTE_PRSNL_RELTN","CE_RTE_PRSNL_RELTN_ID",crpr_columns)=0)
    SET ucb_failed = select_error
    SET error_table = "DTABLE, DTABLEATTR, DTABLEATTRL"
    SET request->error_message = "Unable to retrieve columns for CE_RTE_PRSNL_RELTN table."
    GO TO exit_sub
   ENDIF
   SET pk_value = rchildren->qual1[det_cnt].entity_pk[1].data_number
   SET stat = alterlist(crpr_temp_rec->from_values,crpr_columns->column_count)
   FOR (col_idx = 1 TO crpr_columns->column_count)
    SET breturn = cmb_read_column_value("CE_RTE_PRSNL_RELTN",pk_value,crpr_columns->list[col_idx].
     column_name)
    IF (breturn > 0)
     SET crpr_temp_rec->from_values[col_idx].col_value = cmb_det_value->from_value
     SET crpr_temp_rec->from_values[col_idx].col_populated_ind = 1
    ENDIF
   ENDFOR
   DELETE  FROM combine_det_value cdv
    WHERE (cdv.combine_id=request->xxx_uncombine[ucb_cnt].xxx_combine_id)
     AND cdv.entity_name="CE_RTE_PRSNL_RELTN"
     AND cdv.entity_id=pk_value
   ;end delete
   IF (error(crpr_errmsg,0))
    SET ucb_failed = delete_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    SET error_message = build(
     "CUST_UCB_DEL: Unable to delete log from combine_det_value with entity_name = CE_RTE_PRSNL_RELTN",
     " and ce_rte_prsnl_reltn_id = ",rchildren->qual1[det_cnt].entity_pk[1].data_number,
     " and combine_id = ",request->xxx_uncombine[ucb_cnt].xxx_combine_id)
    GO TO exit_sub
   ENDIF
   CALL parser(" insert into ce_rte_prsnl_reltn crpr")
   CALL parser(" set crpr.ce_rte_prsnl_reltn_id =  seq(ocf_seq, nextval),")
   FOR (col_idx = 1 TO crpr_columns->column_count)
     IF ((crpr_temp_rec->from_values[col_idx].col_populated_ind=1))
      IF ((crpr_columns->list[col_idx].column_type="DQ8"))
       CALL parser(build("   crpr.",crpr_columns->list[col_idx].column_name," = cnvtdatetime('",
         crpr_temp_rec->from_values[col_idx].col_value,"'),"))
      ELSEIF ((crpr_columns->list[col_idx].column_type="I*"))
       CALL parser(build("   crpr.",crpr_columns->list[col_idx].column_name," = ",cnvtint(
          crpr_temp_rec->from_values[col_idx].col_value),","))
      ELSEIF ((crpr_columns->list[col_idx].column_type="F*"))
       CALL parser(build("   crpr.",crpr_columns->list[col_idx].column_name," = ",cnvtreal(
          crpr_temp_rec->from_values[col_idx].col_value),","))
      ELSE
       CALL parser(build("   crpr.",crpr_columns->list[col_idx].column_name," = '",crpr_temp_rec->
         from_values[col_idx].col_value,"',"))
      ENDIF
     ENDIF
   ENDFOR
   CALL parser("   crpr.updt_task = reqinfo->updt_task,")
   CALL parser("   crpr.updt_id = reqinfo->updt_id,")
   CALL parser("   crpr.updt_applctx = reqinfo->updt_applctx")
   CALL parser(" with nocounter go")
   IF (error(crpr_errmsg,0))
    SET ucb_failed = reactivate_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    SET error_message = build(
     "CUST_UCB_DEL: Unable to insert into ce_rte_prsnl_reltn table with ce_rte_prsnl_reltn_id = ",
     rchildren->qual1[det_cnt].entity_pk[1].data_number)
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
#exit_sub
 FREE RECORD crpr_columns
 FREE RECORD crpr_temp_rec
END GO
