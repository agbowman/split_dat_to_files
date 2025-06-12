CREATE PROGRAM dm_eucb_encntr_plan_auth_r:dba
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
 CALL echo("*****pm_cmb_ucb_sync_auth_model_cnt.inc - 760736*****")
 DECLARE dcombined_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"COMBINED")), protect
 DECLARE ddel_cd = f8 WITH constant(uar_get_code_by("MEANING",327,"DEL")), protect
 DECLARE dactive_cd = f8 WITH constant(uar_get_code_by("MEANING",327,"ACTIVE")), protect
 SUBROUTINE (pm_del_person_plan_auth_r(dpersonplanreltnid=f8,torecordind=i2) =i2)
   DECLARE ppar_cnt = i4 WITH noconstant(0), protect
   DECLARE ppar_idx = i4 WITH noconstant(0), protect
   FREE SET person_plan_auth_r
   RECORD person_plan_auth_r(
     1 from_ppar[*]
       2 ppar_id = f8
       2 active_status_cd = f8
       2 authorization_id = f8
   )
   SELECT INTO "nl:"
    p.seq
    FROM person_plan_auth_r p
    WHERE p.person_plan_reltn_id=dpersonplanreltnid
     AND p.active_ind=true
    DETAIL
     ppar_cnt += 1, stat = alterlist(person_plan_auth_r->from_ppar,ppar_cnt), person_plan_auth_r->
     from_ppar[ppar_cnt].ppar_id = p.person_plan_auth_r_id,
     person_plan_auth_r->from_ppar[ppar_cnt].active_status_cd = p.active_status_cd,
     person_plan_auth_r->from_ppar[ppar_cnt].authorization_id = p.authorization_id
    WITH forupdatewait(e)
   ;end select
   FOR (ppar_idx = 1 TO ppar_cnt)
    UPDATE  FROM person_plan_auth_r p
     SET p.active_status_prsnl_id = reqinfo->updt_id, p.active_status_dt_tm = cnvtdatetime(sysdate),
      p.active_ind = false,
      p.active_status_cd = dcombined_cd, p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = reqinfo->updt_id,
      p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.updt_dt_tm =
      cnvtdatetime(sysdate)
     WHERE (p.person_plan_auth_r_id=person_plan_auth_r->from_ppar[ppar_idx].ppar_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = delete_error
     SET request->error_message = concat("Couldn't inactivate person_plan_auth_r record with id = ",
      cnvtstring(person_plan_auth_r->from_ppar[ppar_idx].ppar_id))
     RETURN(false)
    ELSE
     SET icombinedet += 1
     SET stat = alterlist(request->xxx_combine_det,icombinedet)
     SET request->xxx_combine_det[icombinedet].combine_action_cd = ddel_cd
     SET request->xxx_combine_det[icombinedet].entity_id = person_plan_auth_r->from_ppar[ppar_idx].
     ppar_id
     SET request->xxx_combine_det[icombinedet].entity_name = "PERSON_PLAN_AUTH_R"
     SET request->xxx_combine_det[icombinedet].prev_active_ind = true
     SET request->xxx_combine_det[icombinedet].prev_active_status_cd = person_plan_auth_r->from_ppar[
     ppar_idx].active_status_cd
     SET request->xxx_combine_det[icombinedet].to_record_ind = torecordind
     IF (pm_cmb_ucb_upt_authorization_model_cnt(person_plan_auth_r->from_ppar[ppar_idx].
      authorization_id)=false)
      SET failed = update_error
      SET request->error_message = concat(
       "Couldn't update authorization model count for authorization record with id = ",cnvtstring(
        person_plan_auth_r->from_ppar[ppar_idx].authorization_id))
      RETURN(false)
     ENDIF
    ENDIF
   ENDFOR
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (pm_add_person_plan_auth_r(dpersonplanreltnentityid=f8,dpersonplanreltnnewentityid=f8) =
  i2)
   DECLARE dpersonplanauthreltnnewentityid = f8 WITH noconstant(0.0)
   FREE SET par_columns
   RECORD par_columns(
     1 planauthr[*]
       2 col_name = c50
   )
   FREE RECORD pcpar_excl
   RECORD pcpar_excl(
     1 excl_cnt = i4
     1 qual[*]
       2 column_name = vc
   )
   DECLARE icnt = i4 WITH noconstant(0)
   DECLARE pcpar_idx = i4 WITH protect, noconstant(0)
   IF (size(par_columns->planauthr,5)=0)
    SET pcpar_excl->excl_cnt = 0
    SELECT INTO "nl:"
     FROM user_tab_cols utc
     WHERE utc.table_name="PERSON_PLAN_AUTH_R"
      AND ((utc.hidden_column="YES") OR (((utc.virtual_column="YES") OR (utc.column_name=
     "LAST_UTC_TS")) ))
     HEAD REPORT
      pcpar_excl->excl_cnt = 0, stat = alterlist(pcpar_excl->qual,0)
     DETAIL
      pcpar_excl->excl_cnt += 1, stat = alterlist(pcpar_excl->qual,pcpar_excl->excl_cnt), pcpar_excl
      ->qual[pcpar_excl->excl_cnt].column_name = utc.column_name
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     l.attr_name
     FROM dtable t,
      dtableattr a,
      dtableattrl l
     WHERE t.table_name="PERSON_PLAN_AUTH_R"
      AND t.table_name=a.table_name
      AND l.structtype="F"
      AND btest(l.stat,11)=0
      AND  NOT (l.attr_name IN ("UPDT_CNT", "UPDT_DT_TM", "UPDT_ID", "UPDT_APPLCTX", "UPDT_TASK",
     "PERSON_PLAN_AUTH_R_ID", "PERSON_PLAN_RELTN_ID"))
      AND  NOT (expand(pcpar_idx,1,pcpar_excl->excl_cnt,l.attr_name,pcpar_excl->qual[pcpar_idx].
      column_name))
     HEAD REPORT
      cnt = 0
     DETAIL
      cnt += 1
      IF (mod(cnt,10)=1)
       stat = alterlist(par_columns->planauthr,(cnt+ 9))
      ENDIF
      par_columns->planauthr[cnt].col_name = l.attr_name
     FOOT REPORT
      stat = alterlist(par_columns->planauthr,cnt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET failed = select_error
     SET request->error_message =
     "Fields on person_plan_auth_r table not selected when trying to add a new record."
     RETURN(false)
    ENDIF
   ENDIF
   RECORD personplanauthr_rec(
     1 list[*]
       2 id = f8
   ) WITH protect
   SELECT INTO "nl:"
    FROM person_plan_auth_r a
    WHERE a.person_plan_reltn_id=dpersonplanreltnentityid
     AND a.active_ind=1
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt += 1
     IF (mod(cnt,10)=1)
      stat = alterlist(personplanauthr_rec->list,(cnt+ 9))
     ENDIF
     personplanauthr_rec->list[cnt].id = a.person_plan_auth_r_id
    FOOT REPORT
     stat = alterlist(personplanauthr_rec->list,cnt)
    WITH nocounter
   ;end select
   FOR (icnt = 1 TO size(personplanauthr_rec->list,5))
     SET dpersonplanauthreltnnewentityid = 0.0
     SELECT INTO "nl:"
      y = seq(health_plan_seq,nextval)
      FROM dual
      DETAIL
       dpersonplanauthreltnnewentityid = cnvtreal(y)
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET failed = gen_nbr_error
      SET request->error_message =
      "Couldn't get next sequence value from HEALTH_PLAN_SEQ when adding new person_plan_auth_r record"
      RETURN(false)
     ENDIF
     CALL parser("insert into person_plan_auth_r (")
     FOR (x = 1 TO size(par_columns->planauthr,5))
       CALL parser(concat(trim(par_columns->planauthr[x].col_name),", "))
     ENDFOR
     CALL parser("updt_cnt, updt_dt_tm, updt_id, updt_applctx, updt_task, ")
     CALL parser("person_plan_auth_r_id, person_plan_reltn_id)")
     CALL parser("(select ")
     FOR (x = 1 TO size(par_columns->planauthr,5))
       CALL parser(concat("a.",trim(par_columns->planauthr[x].col_name),", "))
     ENDFOR
     CALL parser(build(0,", "))
     CALL parser("cnvtdatetime(curdate, curtime3), ")
     CALL parser("reqinfo->updt_id, ")
     CALL parser("reqinfo->updt_applctx, ")
     CALL parser("reqinfo->updt_task, ")
     CALL parser(build(dpersonplanauthreltnnewentityid,", ",dpersonplanreltnnewentityid," "))
     CALL parser("from person_plan_auth_r a")
     CALL parser(build("where a.person_plan_auth_r_id = ",personplanauthr_rec->list[icnt].id))
     CALL parser(")")
     CALL parser("go")
     IF (curqual=0)
      SET failed = insert_error
      SET request->error_message = "Couldn't insert new person_plan_auth_r record"
      RETURN(false)
     ENDIF
     SET icombinedet += 1
     SET stat = alterlist(request->xxx_combine_det,icombinedet)
     SET request->xxx_combine_det[icombinedet].combine_action_cd = add
     SET request->xxx_combine_det[icombinedet].entity_id = dpersonplanauthreltnnewentityid
     SET request->xxx_combine_det[icombinedet].entity_name = "PERSON_PLAN_AUTH_R"
   ENDFOR
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (pm_del_encntr_plan_auth_r(dencntrplanreltnid=f8,torecordind=i2) =i2)
   DECLARE epar_cnt = i4 WITH noconstant(0), protect
   DECLARE epar_idx = i4 WITH noconstant(0), protect
   FREE SET encntr_plan_auth_r
   RECORD encntr_plan_auth_r(
     1 from_epar[*]
       2 epar_id = f8
       2 active_status_cd = f8
       2 authorization_id = f8
   )
   SELECT INTO "nl:"
    e.seq
    FROM encntr_plan_auth_r e
    WHERE e.encntr_plan_reltn_id=dencntrplanreltnid
     AND e.active_ind=true
    DETAIL
     epar_cnt += 1, stat = alterlist(encntr_plan_auth_r->from_epar,epar_cnt), encntr_plan_auth_r->
     from_epar[epar_cnt].epar_id = e.encntr_plan_auth_r_id,
     encntr_plan_auth_r->from_epar[epar_cnt].active_status_cd = e.active_status_cd,
     encntr_plan_auth_r->from_epar[epar_cnt].authorization_id = e.authorization_id
    WITH forupdatewait(e)
   ;end select
   FOR (epar_idx = 1 TO epar_cnt)
    UPDATE  FROM encntr_plan_auth_r e
     SET e.active_status_prsnl_id = reqinfo->updt_id, e.active_status_dt_tm = cnvtdatetime(sysdate),
      e.active_ind = false,
      e.active_status_cd = dcombined_cd, e.updt_cnt = (e.updt_cnt+ 1), e.updt_id = reqinfo->updt_id,
      e.updt_applctx = reqinfo->updt_applctx, e.updt_task = reqinfo->updt_task, e.updt_dt_tm =
      cnvtdatetime(sysdate)
     WHERE (e.encntr_plan_auth_r_id=encntr_plan_auth_r->from_epar[epar_idx].epar_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = delete_error
     SET request->error_message = concat("Couldn't inactivate encntr_plan_auth_r record with id = ",
      cnvtstring(encntr_plan_auth_r->from_epar[epar_idx].epar_id))
     RETURN(false)
    ELSE
     SET icombinedet += 1
     SET stat = alterlist(request->xxx_combine_det,icombinedet)
     SET request->xxx_combine_det[icombinedet].combine_action_cd = ddel_cd
     SET request->xxx_combine_det[icombinedet].entity_id = encntr_plan_auth_r->from_epar[epar_idx].
     epar_id
     SET request->xxx_combine_det[icombinedet].entity_name = "ENCNTR_PLAN_AUTH_R"
     SET request->xxx_combine_det[icombinedet].prev_active_ind = true
     SET request->xxx_combine_det[icombinedet].prev_active_status_cd = encntr_plan_auth_r->from_epar[
     epar_idx].active_status_cd
     SET request->xxx_combine_det[icombinedet].to_record_ind = torecordind
     IF (pm_cmb_ucb_upt_authorization_model_cnt(encntr_plan_auth_r->from_epar[epar_idx].
      authorization_id)=false)
      SET failed = update_error
      SET request->error_message = concat(
       "Couldn't update authorization model count for authorization record with id = ",cnvtstring(
        encntr_plan_auth_r->from_epar[epar_idx].authorization_id))
      RETURN(false)
     ENDIF
    ENDIF
   ENDFOR
   RETURN(true)
 END ;Subroutine
 SUBROUTINE (pm_add_encntr_plan_auth_r(dencntrplanreltnentityid=f8,dencntrplanreltnnewentityid=f8) =
  i2)
   DECLARE dencntrplanauthreltnnewentityid = f8 WITH noconstant(0.0)
   FREE SET par_columns
   RECORD par_columns(
     1 planauthr[*]
       2 col_name = c50
   )
   FREE RECORD pcpar_excl
   RECORD pcpar_excl(
     1 excl_cnt = i4
     1 qual[*]
       2 column_name = vc
   )
   DECLARE icnt = i4 WITH noconstant(0)
   DECLARE pcpar_idx = i4 WITH protect, noconstant(0)
   IF (size(par_columns->planauthr,5)=0)
    SET pcpar_excl->excl_cnt = 0
    SELECT INTO "nl:"
     FROM user_tab_cols utc
     WHERE utc.table_name="ENCNTR_PLAN_AUTH_R"
      AND ((utc.hidden_column="YES") OR (((utc.virtual_column="YES") OR (utc.column_name=
     "LAST_UTC_TS")) ))
     HEAD REPORT
      pcpar_excl->excl_cnt = 0, stat = alterlist(pcpar_excl->qual,0)
     DETAIL
      pcpar_excl->excl_cnt += 1, stat = alterlist(pcpar_excl->qual,pcpar_excl->excl_cnt), pcpar_excl
      ->qual[pcpar_excl->excl_cnt].column_name = utc.column_name
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     l.attr_name
     FROM dtable t,
      dtableattr a,
      dtableattrl l
     WHERE t.table_name="ENCNTR_PLAN_AUTH_R"
      AND t.table_name=a.table_name
      AND l.structtype="F"
      AND btest(l.stat,11)=0
      AND  NOT (l.attr_name IN ("UPDT_CNT", "UPDT_DT_TM", "UPDT_ID", "UPDT_APPLCTX", "UPDT_TASK",
     "ENCNTR_PLAN_AUTH_R_ID", "ENCNTR_PLAN_RELTN_ID"))
      AND  NOT (expand(pcpar_idx,1,pcpar_excl->excl_cnt,l.attr_name,pcpar_excl->qual[pcpar_idx].
      column_name))
     HEAD REPORT
      cnt = 0
     DETAIL
      cnt += 1
      IF (mod(cnt,10)=1)
       stat = alterlist(par_columns->planauthr,(cnt+ 9))
      ENDIF
      par_columns->planauthr[cnt].col_name = l.attr_name
     FOOT REPORT
      stat = alterlist(par_columns->planauthr,cnt)
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET failed = select_error
     SET request->error_message =
     "Fields on ENCNTR_PLAN_AUTH_R table not selected when trying to add a new record."
     RETURN(false)
    ENDIF
   ENDIF
   RECORD encntrplanauthr_rec(
     1 list[*]
       2 id = f8
   ) WITH protect
   SELECT INTO "nl:"
    FROM encntr_plan_auth_r a
    WHERE a.encntr_plan_reltn_id=dencntrplanreltnentityid
     AND a.active_ind=1
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt += 1
     IF (mod(cnt,10)=1)
      stat = alterlist(encntrplanauthr_rec->list,(cnt+ 9))
     ENDIF
     encntrplanauthr_rec->list[cnt].id = a.encntr_plan_auth_r_id
    FOOT REPORT
     stat = alterlist(encntrplanauthr_rec->list,cnt)
    WITH nocounter
   ;end select
   FOR (icnt = 1 TO size(encntrplanauthr_rec->list,5))
     SET dencntrplanauthreltnnewentityid = 0.0
     SELECT INTO "nl:"
      y = seq(health_plan_seq,nextval)
      FROM dual
      DETAIL
       dencntrplanauthreltnnewentityid = cnvtreal(y)
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET failed = gen_nbr_error
      SET request->error_message =
      "Couldn't get next sequence value from HEALTH_PLAN_SEQ when adding new ENCNTR_PLAN_AUTH_R record"
      RETURN(false)
     ENDIF
     CALL parser("insert into encntr_plan_auth_r (")
     FOR (x = 1 TO size(par_columns->planauthr,5))
       CALL parser(concat(trim(par_columns->planauthr[x].col_name),", "))
     ENDFOR
     CALL parser("updt_cnt, updt_dt_tm, updt_id, updt_applctx, updt_task, ")
     CALL parser("encntr_plan_auth_r_id, encntr_plan_reltn_id)")
     CALL parser("(select ")
     FOR (x = 1 TO size(par_columns->planauthr,5))
       CALL parser(concat("a.",trim(par_columns->planauthr[x].col_name),", "))
     ENDFOR
     CALL parser(build(0,", "))
     CALL parser("cnvtdatetime(curdate, curtime3), ")
     CALL parser("reqinfo->updt_id, ")
     CALL parser("reqinfo->updt_applctx, ")
     CALL parser("reqinfo->updt_task, ")
     CALL parser(build(dencntrplanauthreltnnewentityid,", ",dencntrplanreltnnewentityid," "))
     CALL parser("from encntr_plan_auth_r a")
     CALL parser(build("where a.encntr_plan_auth_r_id = ",encntrplanauthr_rec->list[icnt].id))
     CALL parser(")")
     CALL parser("go")
     IF (curqual=0)
      SET failed = insert_error
      SET request->error_message = "Couldn't insert new encntr_plan_auth_r record"
      RETURN(false)
     ENDIF
     SET icombinedet += 1
     SET stat = alterlist(request->xxx_combine_det,icombinedet)
     SET request->xxx_combine_det[icombinedet].combine_action_cd = add
     SET request->xxx_combine_det[icombinedet].entity_id = dencntrplanauthreltnnewentityid
     SET request->xxx_combine_det[icombinedet].entity_name = "ENCNTR_PLAN_AUTH_R"
   ENDFOR
 END ;Subroutine
 SUBROUTINE (pm_cmb_ucb_upt_authorization_model_cnt(dauthorizationid=f8) =i2)
   SELECT INTO "nl:"
    FROM authorization a
    WHERE a.authorization_id=dauthorizationid
     AND a.active_ind=true
    WITH forupdatewait(a)
   ;end select
   IF (curqual > 0)
    UPDATE  FROM authorization a
     SET a.model_updt_cnt = (a.model_updt_cnt+ 1), a.model_updt_dt_tm = cnvtdatetime(sysdate), a
      .updt_id = reqinfo->updt_id,
      a.updt_applctx = reqinfo->updt_applctx, a.updt_task = reqinfo->updt_task
     WHERE a.authorization_id=dauthorizationid
     WITH nocounter
    ;end update
    IF (curqual=0)
     RETURN(false)
    ENDIF
   ENDIF
   RETURN(true)
 END ;Subroutine
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "ENCOUNTER"
  SET dcem_request->qual[1].child_entity = "ENCNTR_PLAN_AUTH_R"
  SET dcem_request->qual[1].op_type = "UNCOMBINE"
  SET dcem_request->qual[1].script_name = "dm_eucb_encntr_plan_auth_r"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 SET cust_ucb_dummy = 0
 IF ((rchildren->qual1[det_cnt].combine_action_cd=add))
  CALL cust_ucb_add(cust_ucb_dummy)
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=del))
  CALL cust_ucb_del2(cust_ucb_dummy)
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=upt))
  CALL cust_ucb_upt(cust_ucb_dummy)
 ELSEIF ((rchildren->qual1[det_cnt].combine_action_cd=eff))
  CALL cust_ucb_eff(cust_ucb_dummy)
 ELSE
  SET ucb_failed = data_error
  SET error_table = rchildren->qual1[det_cnt].entity_name
  GO TO exit_sub
 ENDIF
 SUBROUTINE cust_ucb_add(dummy)
   DECLARE cust_buff = vc WITH noconstant("")
 END ;Subroutine
 SUBROUTINE cust_ucb_del(dummy)
   DECLARE cust_buff = vc WITH noconstant("")
 END ;Subroutine
 SUBROUTINE cust_ucb_del2(dummy)
   SET cust_del2_buff = fillstring(1000," ")
   SET cust_del2_buff = concat("update into ",trim(rchildren->qual1[det_cnt].entity_name),
    " set updt_id = reqinfo->updt_id, ","updt_dt_tm = cnvtdatetime(curdate,curtime3), ",
    "updt_applctx = reqinfo->updt_applctx, ",
    "updt_cnt = updt_cnt + 1, ","updt_task = reqinfo->updt_task, ",
    "active_ind = rChildren->QUAL1[det_cnt]->PREV_ACTIVE_IND, ",
    "active_status_cd = rChildren->QUAL1[det_cnt]->PREV_ACTIVE_STATUS_CD, ",
    "active_status_dt_tm = cnvtdatetime(curdate,curtime3), ",
    "active_status_prsnl_id = reqinfo->updt_id ","where ",trim(rchildren->qual1[det_cnt].
     primary_key_attr)," = rChildren->QUAL1[det_cnt]->ENTITY_ID ","with nocounter go ")
   CALL parser(cust_del2_buff)
   IF (curqual=0)
    SET ucb_failed = reactivate_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    GO TO exit_sub
   ENDIF
   SET activity_updt_cnt += 1
   DECLARE authorization_id = f8
   SELECT INTO "nl:"
    e.seq
    FROM encntr_plan_auth_r e
    WHERE (e.encntr_plan_auth_r_id=rchildren->qual1[det_cnt].entity_id)
    DETAIL
     authorization_id = e.authorization_id
   ;end select
   FREE SET cust_del2_buff
   IF (pm_cmb_ucb_upt_authorization_model_cnt(authorization_id)=false)
    SET ucb_failed = update_error
    SET error_table = rchildren->qual1[det_cnt].entity_name
    SET request->error_message = concat(
     "Couldn't update authorization model count for authorization record with id = ",cnvtstring(
      authorization_id))
    GO TO exit_sub
   ENDIF
 END ;Subroutine
 SUBROUTINE cust_ucb_upt(dummy)
   DECLARE cust_buff = vc WITH noconstant("")
 END ;Subroutine
 SUBROUTINE cust_ucb_eff(dummy)
   DECLARE cust_buff = vc WITH noconstant("")
 END ;Subroutine
#exit_sub
END GO
