CREATE PROGRAM dm_pucb_prsnl:dba
 CALL echo("*****dm_pucb_prsnl.prg - 679553*****")
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
 DECLARE dppl_cdv_cnt = i4 WITH protect, noconstant(0)
 DECLARE col_prsnl = i4 WITH protect, noconstant(0)
 DECLARE dppl_cdv_stmt = vc WITH protect, noconstant("")
 DECLARE dppl_to_col_list = vc WITH protect, noconstant("")
 DECLARE dppl_frm_col_list = vc WITH protect, noconstant("")
 DECLARE dppl_val = vc WITH protect, noconstant("")
 DECLARE dppl_num = i4 WITH protect, noconstant(0)
 DECLARE sprevioususername = vc WITH protect, noconstant("")
 DECLARE stempusername = vc WITH protect, constant("TEMPUSERNAME")
 DECLARE dpersonid = f8 WITH protect, noconstant(0.0)
 FREE RECORD dpucbpl_columns
 RECORD dpucbpl_columns(
   1 prsnl[*]
     2 column_name = vc
     2 column_type = vc
     2 to_value = vc
     2 null_ind = i2
     2 trailing_spaces_count = i4
 )
 FREE RECORD dpp_excols
 RECORD dpp_excols(
   1 cnt = i4
   1 qual[*]
     2 col_name = vc
 )
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "PRSNL"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "DM_PUCB_PRSNL"
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
  FROM prsnl frm
  WHERE (frm.person_id=request->xxx_uncombine[ucb_cnt].from_xxx_id)
  DETAIL
   sprevioususername = frm.username
  WITH forupdatewait(frm)
 ;end select
 SET dpersonid = request->xxx_uncombine[ucb_cnt].to_xxx_id
 SELECT INTO "NL:"
  FROM combine_det_value cdv
  WHERE (cdv.combine_id=request->xxx_uncombine[ucb_cnt].xxx_combine_id)
   AND cdv.entity_name="PRSNL"
   AND (cdv.parent_entity=request->parent_table)
   AND cdv.column_name != "PERSON_ID"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  CALL update_ucb_username(stempusername,dpersonid)
  SELECT INTO "nl:"
   FROM user_tab_cols utc
   WHERE utc.table_name="PRSNL"
    AND ((utc.hidden_column="YES") OR (((utc.virtual_column="YES") OR (utc.column_name="LAST_UTC_TS"
   )) ))
   DETAIL
    dpp_excols->cnt += 1, stat = alterlist(dpp_excols->qual,dpp_excols->cnt), dpp_excols->qual[
    dpp_excols->cnt].col_name = utc.column_name
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM dtable t,
    dtableattr a,
    dtableattrl l
   WHERE t.table_name="PRSNL"
    AND t.table_name=a.table_name
    AND l.structtype="F"
    AND btest(l.stat,11)=0
    AND  NOT (l.attr_name IN ("PERSON_ID", "UPDT*"))
    AND  NOT (expand(dppl_num,1,dpp_excols->cnt,l.attr_name,dpp_excols->qual[dppl_num].col_name))
   ORDER BY l.attr_name DESC
   DETAIL
    col_prsnl += 1, stat = alterlist(dpucbpl_columns->prsnl,col_prsnl)
    IF (col_prsnl > 1
     AND  NOT (l.attr_name IN ("PERSON_ID", "ACTIVE_IND")))
     dppl_to_col_list = concat(dppl_to_col_list,",FRM.",l.attr_name), dppl_frm_col_list = concat(
      dppl_frm_col_list,",CDV.",l.attr_name)
    ELSEIF ( NOT (l.attr_name IN ("PERSON_ID", "ACTIVE_IND")))
     dppl_to_col_list = concat("FRM.",l.attr_name), dppl_frm_col_list = concat("CDV.",l.attr_name)
    ENDIF
    dpucbpl_columns->prsnl[col_prsnl].column_name = l.attr_name
    IF (l.type="F")
     dpucbpl_columns->prsnl[col_prsnl].column_type = "F8"
    ELSEIF (l.type="I")
     dpucbpl_columns->prsnl[col_prsnl].column_type = "I4"
    ELSEIF (l.type="C")
     IF (btest(l.stat,13))
      dpucbpl_columns->prsnl[col_prsnl].column_type = "VC"
     ELSE
      dpucbpl_columns->prsnl[col_prsnl].column_type = build(l.type,l.len)
     ENDIF
    ELSEIF (l.type="Q")
     dpucbpl_columns->prsnl[col_prsnl].column_type = "DQ8"
    ENDIF
   WITH nocounter
  ;end select
  FOR (cdv_cols = 1 TO size(dpucbpl_columns->prsnl,5))
   CALL cmb_read_column_value("PRSNL",request->xxx_uncombine[ucb_cnt].from_xxx_id,dpucbpl_columns->
    prsnl[cdv_cols].column_name)
   IF (nullval(cmb_det_value->to_value,"!NL!")="!NL!")
    SET dpucbpl_columns->prsnl[cdv_cols].to_value = ""
   ELSE
    SET dpucbpl_columns->prsnl[cdv_cols].to_value = cmb_det_value->to_value
   ENDIF
  ENDFOR
  SET dppl_cdv_stmt = concat("UPDATE into prsnl FRM "," SET (",dppl_to_col_list,
   ",ACTIVE_IND,UPDT_APPLCTX,UPDT_CNT,UPDT_DT_TM, ","UPDT_ID, UPDT_TASK) (",
   "SELECT ")
  FOR (dpp_i = 1 TO size(dpucbpl_columns->prsnl,5))
   IF ((dpucbpl_columns->prsnl[dpp_i].to_value=""))
    SET dppl_val = "NULL"
   ELSE
    IF ((dpucbpl_columns->prsnl[dpp_i].column_type="DQ8"))
     SET dppl_val = concat(" cnvtdatetime('",dpucbpl_columns->prsnl[dpp_i].to_value,"')")
    ELSEIF ((dpucbpl_columns->prsnl[dpp_i].column_type="*C*"))
     SET dppl_val = concat(" '",dpucbpl_columns->prsnl[dpp_i].to_value,"'")
    ELSE
     SET dppl_val = dpucbpl_columns->prsnl[dpp_i].to_value
    ENDIF
   ENDIF
   IF (dpp_i=1)
    SET dppl_cdv_stmt = concat(dppl_cdv_stmt," ",dppl_val)
   ELSE
    SET dppl_cdv_stmt = concat(dppl_cdv_stmt,",",dppl_val)
   ENDIF
  ENDFOR
  SET dppl_cdv_stmt = concat(dppl_cdv_stmt," ,reqinfo->updt_applctx, FRM.updt_cnt + 1, ",
   "cnvtdatetime(curdate,curtime3), reqinfo->updt_id, reqinfo->updt_task "," FROM dual)",
   " WHERE FRM.person_id = ",
   trim(cnvtstring(request->xxx_uncombine[ucb_cnt].from_xxx_id)),".0 WITH NOCOUNTER go")
  CALL parser(dppl_cdv_stmt,1)
  CALL update_ucb_username(sprevioususername,dpersonid)
 ENDIF
 IF ((rchildren->qual1[det_cnt].combine_action_cd=del))
  CALL cust_ucb_del2(0)
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=add))
  CALL cust_ucb_add(0)
 ELSE
  SET ucb_failed = data_error
  SET error_table = rchildren->qual1[det_cnt].entity_name
  GO TO exit_sub
 ENDIF
 SUBROUTINE (cust_ucb_add(dummy=i2) =null)
   UPDATE  FROM prsnl p
    SET p.active_ind = false, p.active_status_cd = reqdata->inactive_status_cd, p
     .active_status_prsnl_id = reqinfo->updt_id,
     p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_applctx = reqinfo->
     updt_applctx,
     p.updt_cnt = (p.updt_cnt+ 1), p.updt_task = reqinfo->updt_task
    WHERE (p.person_id=rchildren->qual1[det_cnt].entity_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ucb_failed = delete_error
    SET error_table = "PRSNL"
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
 SUBROUTINE (cust_ucb_del2(dummy=i2) =null)
   UPDATE  FROM prsnl pp
    SET pp.updt_id = reqinfo->updt_id, pp.updt_dt_tm = cnvtdatetime(sysdate), pp.updt_applctx =
     reqinfo->updt_applctx,
     pp.updt_cnt = (pp.updt_cnt+ 1), pp.updt_task = reqinfo->updt_task, pp.active_ind = rchildren->
     qual1[det_cnt].prev_active_ind,
     pp.active_status_cd = rchildren->qual1[det_cnt].prev_active_status_cd, pp.active_status_dt_tm =
     cnvtdatetime(sysdate), pp.active_status_prsnl_id = reqinfo->updt_id
    WHERE (pp.person_id=request->xxx_uncombine[ucb_cnt].to_xxx_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET ucb_failed = reactivate_error
    SET error_table = "PRSNL"
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
 END ;Subroutine
 SUBROUTINE (update_ucb_username(susername=vc,dtemppersonid=f8) =null)
   UPDATE  FROM prsnl pp
    SET pp.username = susername, pp.updt_cnt = (pp.updt_cnt+ 1), pp.updt_id = reqinfo->updt_id,
     pp.updt_applctx = reqinfo->updt_applctx, pp.updt_task = reqinfo->updt_task, pp.updt_dt_tm =
     cnvtdatetime(sysdate)
    WHERE pp.person_id=dtemppersonid
   ;end update
 END ;Subroutine
#exit_sub
END GO
