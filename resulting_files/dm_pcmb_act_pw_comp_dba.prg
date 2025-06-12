CREATE PROGRAM dm_pcmb_act_pw_comp:dba
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
     2 from_originating_encntr_id = f8
     2 encntr_id = f8
     2 valid_originating_encntr_id = f8
     2 from_person_id = f8
     2 to_person_id = f8
   1 to_rec[*]
     2 to_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
 )
 DECLARE check_originating_encounter_id_for_person(null) = null
 DECLARE upt_from(act_pw_comp_id,to_person_id) = null
 DECLARE upt_encntr_from(act_pw_comp_id,to_person_id,from_originating_encntr_id,
  valid_originating_encntr_id) = null
 DECLARE upt_originating_encounter_id_from_person(act_pw_comp_id,from_person_id,from_encntr_id,
  from_originating_encntr_id) = null
 DECLARE nfromcompcount = i4
 DECLARE nnumindex = i4
 DECLARE ndebugind = i4
 DECLARE nindex = i4
 DECLARE breturn = i2
 SET nfromcompcount = 0
 SET nnumindex = 0
 IF (validate(request->debug_ind)=1)
  SET ndebugind = 1
 ELSE
  SET ndebugind = 0
 ENDIF
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "ACT_PW_COMP"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "dm_pcmb_act_pw_comp"
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
   PLAN (frm
    WHERE (frm.person_id=request->xxx_combine[icombine].from_xxx_id))
  ELSE
   PLAN (frm
    WHERE (frm.person_id=request->xxx_combine[icombine].from_xxx_id)
     AND (((frm.encntr_id=request->xxx_combine[icombine].encntr_id)) OR ((frm.originating_encntr_id=
    request->xxx_combine[icombine].encntr_id))) )
  ENDIF
  INTO "nl:"
  frm.*
  FROM act_pw_comp frm
  HEAD REPORT
   nfromcompcount = 0
  DETAIL
   nfromcompcount += 1
   IF (nfromcompcount > size(rreclist->from_rec,5))
    stat = alterlist(rreclist->from_rec,(nfromcompcount+ 10))
   ENDIF
   rreclist->from_rec[nfromcompcount].from_id = frm.act_pw_comp_id, rreclist->from_rec[nfromcompcount
   ].active_ind = frm.active_ind, rreclist->from_rec[nfromcompcount].active_status_cd = 0.00,
   rreclist->from_rec[nfromcompcount].from_originating_encntr_id = frm.originating_encntr_id,
   rreclist->from_rec[nfromcompcount].encntr_id = frm.encntr_id, rreclist->from_rec[nfromcompcount].
   from_person_id = request->xxx_combine[icombine].from_xxx_id,
   rreclist->from_rec[nfromcompcount].to_person_id = request->xxx_combine[icombine].to_xxx_id,
   rreclist->from_rec[nfromcompcount].valid_originating_encntr_id = 0.0
  FOOT REPORT
   IF (nfromcompcount > 0)
    stat = alterlist(rreclist->from_rec,nfromcompcount)
   ENDIF
  WITH forupdatewait(frm)
 ;end select
 IF (size(rreclist->from_rec,5) > 0)
  CALL check_originating_encounter_id_for_person(null)
 ENDIF
 FOR (nindex = 1 TO size(rreclist->from_rec,5))
   IF ((request->xxx_combine[icombine].encntr_id=0.0))
    CALL upt_from(rreclist->from_rec[nindex].from_id,rreclist->from_rec[nindex].to_person_id)
   ELSEIF ((request->xxx_combine[icombine].encntr_id > 0.0))
    IF ((rreclist->from_rec[nindex].encntr_id != rreclist->from_rec[nindex].
    from_originating_encntr_id)
     AND (rreclist->from_rec[nindex].from_originating_encntr_id > 0.0)
     AND (rreclist->from_rec[nindex].from_originating_encntr_id=request->xxx_combine[icombine].
    encntr_id))
     CALL upt_originating_encounter_id_from_person(rreclist->from_rec[nindex].from_id,rreclist->
      from_rec[nindex].from_person_id,rreclist->from_rec[nindex].encntr_id,rreclist->from_rec[nindex]
      .from_originating_encntr_id)
    ELSE
     CALL upt_encntr_from(rreclist->from_rec[nindex].from_id,rreclist->from_rec[nindex].to_person_id,
      rreclist->from_rec[nindex].from_originating_encntr_id,rreclist->from_rec[nindex].
      valid_originating_encntr_id)
    ENDIF
   ENDIF
 ENDFOR
 IF (ndebugind=1)
  CALL echorecord(rreclist)
 ENDIF
 SUBROUTINE check_originating_encounter_id_for_person(null)
   SET nnumindex = 0
   SELECT INTO "nl:"
    FROM encounter e
    WHERE expand(nnumindex,1,size(rreclist->from_rec,5),e.person_id,rreclist->from_rec[nnumindex].
     to_person_id)
     AND e.encntr_id > 0.0
    DETAIL
     FOR (nindex = 1 TO size(rreclist->from_rec,5))
       IF ((e.encntr_id=rreclist->from_rec[nindex].from_originating_encntr_id)
        AND (e.person_id=rreclist->from_rec[nindex].to_person_id))
        rreclist->from_rec[nindex].valid_originating_encntr_id = rreclist->from_rec[nindex].
        from_originating_encntr_id
       ENDIF
     ENDFOR
    WITH nocounter, expand = 2
   ;end select
   IF (ndebugind=1)
    CALL echorecord(rreclist)
   ENDIF
 END ;Subroutine
 SUBROUTINE upt_from(act_pw_comp_id,to_person_id)
   IF (ndebugind=1)
    CALL echo(build("upt_encntr_from"))
    CALL echo(build("act_pw_comp_id:",act_pw_comp_id))
    CALL echo(build("to_person_id:",to_person_id))
   ENDIF
   UPDATE  FROM act_pw_comp frm
    SET frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo
     ->updt_applctx,
     frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm = cnvtdatetime(sysdate), frm.person_id =
     to_person_id
    WHERE frm.act_pw_comp_id=act_pw_comp_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = act_pw_comp_id
   SET request->xxx_combine_det[icombinedet].entity_name = "ACT_PW_COMP"
   SET request->xxx_combine_det[icombinedet].attribute_name = "person_id"
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",act_pw_comp_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE upt_encntr_from(act_pw_comp_id,to_person_id,from_originating_encntr_id,
  valid_originating_encntr_id)
   IF (ndebugind=1)
    CALL echo(build("upt_encntr_from"))
    CALL echo(build("act_pw_comp_id:",act_pw_comp_id))
    CALL echo(build("to_person_id:",to_person_id))
    CALL echo(build("from_originating_encntr_id:",from_originating_encntr_id))
    CALL echo(build("valid_originating_encntr_id:",valid_originating_encntr_id))
   ENDIF
   SET breturn = 0
   UPDATE  FROM act_pw_comp frm
    SET frm.updt_applctx = reqinfo->updt_applctx, frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_dt_tm =
     cnvtdatetime(sysdate),
     frm.updt_id = reqinfo->updt_id, frm.updt_task = reqinfo->updt_task, frm.person_id = to_person_id,
     frm.originating_encntr_id = valid_originating_encntr_id
    WHERE frm.act_pw_comp_id=act_pw_comp_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = act_pw_comp_id
   SET request->xxx_combine_det[icombinedet].entity_name = "ACT_PW_COMP"
   SET request->xxx_combine_det[icombinedet].attribute_name = "person_id"
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",act_pw_comp_id))
    RETURN(0)
   ENDIF
   SET breturn = cmb_save_column_value("ACT_PW_COMP",act_pw_comp_id,"ORIGINATING_ENCNTR_ID","f8",
    cnvtstring(from_originating_encntr_id),
    cnvtstring(valid_originating_encntr_id))
   IF (breturn=0)
    SET failed = insert_error
    SET request->error_message = "Could not save originating_encntr_id in cmb_save_column_value"
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE upt_originating_encounter_id_from_person(act_pw_comp_id,from_person_id,from_encntr_id,
  from_originating_encntr_id)
   IF (ndebugind=1)
    CALL echo(build("upt_originating_encounter_id_from_person"))
    CALL echo(build("act_pw_comp_id:",act_pw_comp_id))
    CALL echo(build("from_person_id:",from_person_id))
    CALL echo(build("from_encntr_id:",from_encntr_id))
    CALL echo(build("from_originating_encntr_id:",from_originating_encntr_id))
   ENDIF
   DECLARE bfound = i2
   SET bfound = 0
   IF (((from_originating_encntr_id=0.0) OR (from_person_id=0.0)) )
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM encounter e
    WHERE e.encntr_id=from_originating_encntr_id
     AND e.person_id=from_person_id
    DETAIL
     bfound = 1
    WITH nocounter
   ;end select
   IF (bfound=0)
    UPDATE  FROM act_pw_comp frm
     SET frm.updt_applctx = reqinfo->updt_applctx, frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_dt_tm
       = cnvtdatetime(sysdate),
      frm.updt_id = reqinfo->updt_id, frm.updt_task = reqinfo->updt_task, frm.originating_encntr_id
       = 0.0
     WHERE frm.act_pw_comp_id=act_pw_comp_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = update_error
     SET request->error_message = substring(1,132,build("Could not update pk val=",act_pw_comp_id))
     RETURN(0)
    ENDIF
    SET breturn = cmb_save_column_value("ACT_PW_COMP",act_pw_comp_id,"ORIGINATING_ENCNTR_ID","f8",
     cnvtstring(from_originating_encntr_id),
     cnvtstring(bfound))
    IF (breturn=0)
     SET failed = insert_error
     SET request->error_message = "Could not save originating_encntr_id in cmb_save_column_value"
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_sub
 FREE SET rreclist
END GO
