CREATE PROGRAM dm_ecmb_encntr_prsnl_reltn:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c6 WITH noconstant(""), private
 ENDIF
 SET last_mod = "526363"
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
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "ENCOUNTER"
  SET dcem_request->qual[1].child_entity = "ENCNTR_PRSNL_RELTN"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_ECMB_ENCNTR_PRSNL_RELTN"
  SET dcem_request->qual[1].single_encntr_ind = 0
  SET dcem_request->qual[1].script_run_order = 2
  SET dcem_request->qual[1].del_chg_id_ind = 1
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_sub
 ENDIF
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[10]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 encntr_prsnl_r_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 prsnl_person_id = f8
     2 priority_seq = i4
     2 internal_seq = i4
   1 to_rec[10]
     2 to_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 encntr_prsnl_r_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 prsnl_person_id = f8
     2 priority_seq = i4
     2 internal_seq = i4
 )
 FREE SET rcolumns
 RECORD rcolumns(
   1 col[100]
     2 col_name = c50
 )
 FREE RECORD deepr_excl
 RECORD deepr_excl(
   1 excl_cnt = i4
   1 qual[*]
     2 column_name = vc
 )
 DECLARE encntrtypecd_exists = i2
 DECLARE encntrtypecd_value = f8
 DECLARE deepr_idx = i4 WITH protect, noconstant(0)
 DECLARE s_assigned_care_manager_cdf = vc WITH protect, constant("ASSIGNEDCM")
 DECLARE bfoundeffectiverecord = i2 WITH protect, noconstant(false)
 DECLARE ltorecordcount = i4 WITH protect, noconstant(1)
 DECLARE ltorecordindex = i4 WITH protect, noconstant(0)
 DECLARE llocatevalindex = i4 WITH protect, noconstant(0)
 SET encntrtypecd_exists = 0
 SET encntrtypecd_value = 0.0
 SET count1 = 0
 SET count2 = 0
 SET col_count = 0
 SET cmb_dummy = 0
 SET loopcount = 0
 IF ((validate(bcmbrefoption,- (1))=- (1)))
  DECLARE bcmbrefoption = i2 WITH noconstant(false)
 ENDIF
 IF ((validate(dcmbrefdoccd,- (99))=- (99)))
  DECLARE dcmbrefdoccd = f8 WITH noconstant(0.0)
 ENDIF
 SET stat = uar_get_meaning_by_codeset(20790,"CMBREFDOC",1,dcmbrefdoccd)
 IF (dcmbrefdoccd > 0)
  SELECT INTO "nl:"
   FROM code_value_extension cve
   WHERE cve.code_value=dcmbrefdoccd
    AND cve.field_name="OPTION"
    AND cve.code_set=20790
   DETAIL
    IF (trim(cve.field_value,3)="1")
     bcmbrefoption = true
    ELSE
     bcmbrefoption = false
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "NL:"
  l.attr_name
  FROM dtable t,
   dtableattr a,
   dtableattrl l
  WHERE t.table_name="ENCNTR_PRSNL_RELTN"
   AND t.table_name=a.table_name
   AND l.structtype="F"
   AND btest(l.stat,11)=0
   AND l.attr_name="ENCNTR_TYPE_CD"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET encntrtypecd_exists = 1
  SELECT INTO "nl:"
   FROM encounter e
   WHERE (e.encntr_id=request->xxx_combine[icombine].to_xxx_id)
   DETAIL
    encntrtypecd_value = e.encntr_type_cd
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  frm.*
  FROM encntr_prsnl_reltn frm
  WHERE (frm.encntr_id=request->xxx_combine[icombine].from_xxx_id)
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alter(rreclist->from_rec,(count1+ 9))
   ENDIF
   rreclist->from_rec[count1].from_id = frm.encntr_prsnl_reltn_id, rreclist->from_rec[count1].
   active_ind = frm.active_ind, rreclist->from_rec[count1].active_status_cd = frm.active_status_cd,
   rreclist->from_rec[count1].encntr_prsnl_r_cd = frm.encntr_prsnl_r_cd, rreclist->from_rec[count1].
   beg_effective_dt_tm = frm.beg_effective_dt_tm, rreclist->from_rec[count1].end_effective_dt_tm =
   frm.end_effective_dt_tm,
   rreclist->from_rec[count1].prsnl_person_id = frm.prsnl_person_id, rreclist->from_rec[count1].
   priority_seq = frm.priority_seq, rreclist->from_rec[count1].internal_seq = frm.internal_seq
  WITH forupdatewait(frm)
 ;end select
 IF (count1 > 0)
  SELECT INTO "nl:"
   tu.*
   FROM encntr_prsnl_reltn tu
   WHERE (tu.encntr_id=request->xxx_combine[icombine].to_xxx_id)
   DETAIL
    count2 += 1
    IF (mod(count2,10)=1
     AND count2 != 1)
     stat = alter(rreclist->to_rec,(count2+ 9))
    ENDIF
    rreclist->to_rec[count2].to_id = tu.encntr_prsnl_reltn_id, rreclist->to_rec[count2].active_ind =
    tu.active_ind, rreclist->to_rec[count2].active_status_cd = tu.active_status_cd,
    rreclist->to_rec[count2].encntr_prsnl_r_cd = tu.encntr_prsnl_r_cd, rreclist->to_rec[count2].
    beg_effective_dt_tm = tu.beg_effective_dt_tm, rreclist->to_rec[count2].end_effective_dt_tm = tu
    .end_effective_dt_tm,
    rreclist->to_rec[count2].prsnl_person_id = tu.prsnl_person_id, rreclist->to_rec[count2].
    priority_seq = tu.priority_seq, rreclist->to_rec[count2].internal_seq = tu.internal_seq
   WITH forupdatewait(tu)
  ;end select
  IF (count2 > 0)
   FOR (loopcount = 1 TO count1)
     IF ((rreclist->from_rec[loopcount].active_ind=true)
      AND (rreclist->from_rec[loopcount].beg_effective_dt_tm <= cnvtdatetime(sysdate))
      AND (rreclist->from_rec[loopcount].end_effective_dt_tm >= cnvtdatetime(sysdate)))
      SET from_cdf = fillstring(12," ")
      SET from_display_key = fillstring(40," ")
      SELECT INTO "nl:"
       c.cdf_meaning
       FROM code_value c
       WHERE (c.code_value=rreclist->from_rec[loopcount].encntr_prsnl_r_cd)
       DETAIL
        from_cdf = trim(c.cdf_meaning), from_display_key = trim(c.display_key)
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET failed = select_error
       SET request->error_message = concat("encntr_prsnl_r_cd invalid for encntr_prsnl_reltn_id=",
        cnvtstring(rreclist->from_rec[loopcount].from_id))
       GO TO exit_sub
      ENDIF
      IF (((from_cdf="ADMITDOC") OR (((from_cdf="ATTENDDOC") OR (bcmbrefoption
       AND from_cdf="REFERDOC")) )) )
       SELECT INTO "nl:"
        c.cdf_meaning
        FROM code_value c,
         (dummyt d  WITH seq = value(count2))
        PLAN (d
         WHERE (rreclist->to_rec[d.seq].active_ind=true)
          AND (rreclist->to_rec[d.seq].beg_effective_dt_tm <= cnvtdatetime(sysdate))
          AND (rreclist->to_rec[d.seq].end_effective_dt_tm >= cnvtdatetime(sysdate)))
         JOIN (c
         WHERE (c.code_value=rreclist->to_rec[d.seq].encntr_prsnl_r_cd)
          AND c.cdf_meaning=from_cdf
          AND c.display_key=from_display_key)
        WITH nocounter
       ;end select
       IF (curqual=0)
        CALL add_to(cmb_dummy)
        CALL del_from(cmb_dummy)
       ELSE
        SELECT INTO "nl:"
         c.cdf_meaning
         FROM code_value c,
          (dummyt d  WITH seq = value(count2))
         PLAN (d
          WHERE (rreclist->to_rec[d.seq].active_ind=true)
           AND (rreclist->to_rec[d.seq].beg_effective_dt_tm <= cnvtdatetime(sysdate))
           AND (rreclist->to_rec[d.seq].end_effective_dt_tm >= cnvtdatetime(sysdate))
           AND (rreclist->to_rec[d.seq].prsnl_person_id=rreclist->from_rec[loopcount].prsnl_person_id
          ))
          JOIN (c
          WHERE (c.code_value=rreclist->to_rec[d.seq].encntr_prsnl_r_cd)
           AND c.cdf_meaning=from_cdf
           AND c.display_key=from_display_key)
         WITH nocounter
        ;end select
        IF (curqual=0)
         CALL eff_from(cmb_dummy)
        ELSE
         CALL del_from(cmb_dummy)
        ENDIF
       ENDIF
      ELSEIF (from_cdf=s_assigned_care_manager_cdf)
       SET bfoundeffectiverecord = false
       SELECT INTO "nl:"
        FROM code_value cv
        WHERE expand(ltorecordcount,1,count2,true,rreclist->to_rec[ltorecordcount].active_ind,
         rreclist->from_rec[loopcount].priority_seq,rreclist->to_rec[ltorecordcount].priority_seq,
         rreclist->from_rec[loopcount].internal_seq,rreclist->to_rec[ltorecordcount].internal_seq,cv
         .code_value,
         rreclist->to_rec[ltorecordcount].encntr_prsnl_r_cd,cv.cdf_meaning,from_cdf)
        DETAIL
         IF ( NOT (bfoundeffectiverecord))
          ltorecordindex = locateval(llocatevalindex,1,size(rreclist->to_rec,5),true,rreclist->
           to_rec[llocatevalindex].active_ind,
           rreclist->from_rec[loopcount].priority_seq,rreclist->to_rec[llocatevalindex].priority_seq,
           rreclist->from_rec[loopcount].internal_seq,rreclist->to_rec[llocatevalindex].internal_seq,
           cv.code_value,
           rreclist->to_rec[llocatevalindex].encntr_prsnl_r_cd)
          IF ((rreclist->to_rec[ltorecordindex].beg_effective_dt_tm <= cnvtdatetime(sysdate))
           AND (rreclist->to_rec[ltorecordindex].end_effective_dt_tm > cnvtdatetime(sysdate)))
           bfoundeffectiverecord = true
          ENDIF
         ENDIF
        WITH nocounter, expand = 0
       ;end select
       IF ( NOT (bfoundeffectiverecord))
        CALL add_to(cmb_dummy)
        CALL del_from(cmb_dummy)
       ELSE
        CALL del_from(cmb_dummy)
       ENDIF
      ELSE
       SELECT
        IF (trim(from_cdf)="")
         PLAN (d
          WHERE (rreclist->to_rec[d.seq].active_ind=true)
           AND (rreclist->to_rec[d.seq].beg_effective_dt_tm <= cnvtdatetime(sysdate))
           AND (rreclist->to_rec[d.seq].end_effective_dt_tm >= cnvtdatetime(sysdate))
           AND (rreclist->to_rec[d.seq].prsnl_person_id=rreclist->from_rec[loopcount].prsnl_person_id
          ))
          JOIN (c
          WHERE (c.code_value=rreclist->to_rec[d.seq].encntr_prsnl_r_cd)
           AND c.cdf_meaning=null
           AND c.display_key=from_display_key)
        ELSE
         PLAN (d
          WHERE (rreclist->to_rec[d.seq].active_ind=true)
           AND (rreclist->to_rec[d.seq].beg_effective_dt_tm <= cnvtdatetime(sysdate))
           AND (rreclist->to_rec[d.seq].end_effective_dt_tm >= cnvtdatetime(sysdate))
           AND (rreclist->to_rec[d.seq].prsnl_person_id=rreclist->from_rec[loopcount].prsnl_person_id
          ))
          JOIN (c
          WHERE (c.code_value=rreclist->to_rec[d.seq].encntr_prsnl_r_cd)
           AND c.cdf_meaning=from_cdf
           AND c.display_key=from_display_key)
        ENDIF
        INTO "nl:"
        c.cdf_meaning
        FROM code_value c,
         (dummyt d  WITH seq = value(count2))
        WITH nocounter
       ;end select
       IF (curqual=0)
        CALL add_to(cmb_dummy)
        CALL del_from(cmb_dummy)
       ELSE
        CALL del_from(cmb_dummy)
       ENDIF
      ENDIF
     ELSE
      CALL upt_from(cmb_dummy)
     ENDIF
   ENDFOR
  ELSE
   FOR (loopcount = 1 TO count1)
     IF ((rreclist->from_rec[loopcount].active_ind=true)
      AND (rreclist->from_rec[loopcount].beg_effective_dt_tm <= cnvtdatetime(sysdate))
      AND (rreclist->from_rec[loopcount].end_effective_dt_tm >= cnvtdatetime(sysdate)))
      CALL add_to(cmb_dummy)
      CALL del_from(cmb_dummy)
     ELSE
      CALL upt_from(cmb_dummy)
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SET ecode = 0
 SET emsg = fillstring(132," ")
 SET ecode = error(emsg,1)
 IF (ecode != 0)
  SET failed = ccl_error
 ENDIF
#exit_sub
 SUBROUTINE add_to(dummy)
   IF (col_count=0)
    SELECT INTO "nl:"
     FROM user_tab_cols utc
     WHERE utc.table_name="ENCNTR_PRSNL_RELTN"
      AND ((utc.hidden_column="YES") OR (((utc.virtual_column="YES") OR (utc.column_name=
     "LAST_UTC_TS")) ))
     HEAD REPORT
      deepr_excl->excl_cnt = 0
     DETAIL
      deepr_excl->excl_cnt += 1, stat = alterlist(deepr_excl->qual,deepr_excl->excl_cnt), deepr_excl
      ->qual[deepr_excl->excl_cnt].column_name = utc.column_name
     WITH nocounter
    ;end select
    SELECT INTO "NL:"
     l.attr_name
     FROM dtable t,
      dtableattr a,
      dtableattrl l
     WHERE t.table_name="ENCNTR_PRSNL_RELTN"
      AND t.table_name=a.table_name
      AND l.structtype="F"
      AND btest(l.stat,11)=0
      AND  NOT (l.attr_name IN ("UPDT_CNT", "UPDT_DT_TM", "UPDT_ID", "UPDT_APPLCTX", "UPDT_TASK",
     "ENCNTR_PRSNL_RELTN_ID", "ENCNTR_ID"))
      AND  NOT (expand(deepr_idx,1,deepr_excl->excl_cnt,l.attr_name,deepr_excl->qual[deepr_idx].
      column_name))
     DETAIL
      col_count += 1
      IF (mod(col_count,100)=1)
       stat = alter(rcolumns->col,(col_count+ 99))
      ENDIF
      rcolumns->col[col_count].col_name = l.attr_name
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET failed = select_error
     SET request->error_message =
     "Fields on encntr_prsnl_reltn table not selected when trying to add a new record."
     GO TO exit_sub
    ENDIF
   ENDIF
   SET new_encntr_prsnl_reltn_id = 0.0
   SELECT INTO "nl:"
    y = seq(encounter_seq,nextval)
    FROM dual
    DETAIL
     new_encntr_prsnl_reltn_id = cnvtreal(y)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET failed = gen_nbr_error
    SET request->error_message =
    "Couldn't get next sequence value from encounter_seq when adding new encntr_person_reltn record"
    GO TO exit_sub
   ENDIF
   CALL parser("insert into encntr_prsnl_reltn (")
   FOR (x = 1 TO col_count)
     CALL parser(concat(trim(rcolumns->col[x].col_name),", "))
   ENDFOR
   CALL parser("updt_cnt, updt_dt_tm, updt_id, updt_applctx, updt_task, ")
   CALL parser("encntr_prsnl_reltn_id, encntr_id)")
   CALL parser("(select ")
   FOR (x = 1 TO col_count)
     IF (encntrtypecd_exists=1)
      IF (trim(rcolumns->col[x].col_name,3)="ENCNTR_TYPE_CD")
       CALL parser(build(encntrtypecd_value,","))
      ELSE
       CALL parser(concat("FRM.",trim(rcolumns->col[x].col_name),", "))
      ENDIF
     ELSE
      CALL parser(concat("FRM.",trim(rcolumns->col[x].col_name),", "))
     ENDIF
   ENDFOR
   CALL parser("INIT_UPDT_CNT, ")
   CALL parser("cnvtdatetime(curdate, curtime3), ")
   CALL parser("reqinfo->updt_id, ")
   CALL parser("reqinfo->updt_applctx, ")
   CALL parser("reqinfo->updt_task, ")
   CALL parser("NEW_ENCNTR_PRSNL_RELTN_ID, ")
   CALL parser("request->xxx_combine[iCombine]->to_xxx_id ")
   CALL parser("from encntr_prsnl_reltn FRM")
   CALL parser(build("where FRM.encntr_prsnl_reltn_id = ",rreclist->from_rec[loopcount].from_id,")"))
   CALL parser("go")
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = add
   SET request->xxx_combine_det[icombinedet].entity_id = new_encntr_prsnl_reltn_id
   SET request->xxx_combine_det[icombinedet].entity_name = "ENCNTR_PRSNL_RELTN"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ENCNTR_ID"
   IF (curqual=0)
    SET failed = insert_error
    SET request->error_message = "Couldn't insert new encntr_prsnl_reltn record"
    GO TO exit_sub
   ENDIF
 END ;Subroutine
 SUBROUTINE del_from(dummy)
   UPDATE  FROM encntr_prsnl_reltn frm
    SET frm.encntr_id = request->xxx_combine[icombine].to_xxx_id, frm.active_status_cd = combinedaway,
     frm.active_ind = false,
     frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo->
     updt_applctx,
     frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm = cnvtdatetime(sysdate)
    WHERE (frm.encntr_prsnl_reltn_id=rreclist->from_rec[loopcount].from_id)
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = rreclist->from_rec[loopcount].from_id
   SET request->xxx_combine_det[icombinedet].entity_name = "ENCNTR_PRSNL_RELTN"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ENCNTR_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = rreclist->from_rec[loopcount].
   active_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = rreclist->from_rec[loopcount].
   active_status_cd
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = concat(
     "Couldn't inactivate encntr_prsnl_reltn record with encntr_prsnl_reltn_id=",cnvtstring(rreclist
      ->from_rec[loopcount].from_id))
    GO TO exit_sub
   ENDIF
 END ;Subroutine
 SUBROUTINE upt_from(dummy)
   IF (encntrtypecd_exists=1)
    UPDATE  FROM encntr_prsnl_reltn frm
     SET frm.encntr_id = request->xxx_combine[icombine].to_xxx_id, frm.encntr_type_cd =
      encntrtypecd_value, frm.updt_cnt = (frm.updt_cnt+ 1),
      frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task =
      reqinfo->updt_task,
      frm.updt_dt_tm = cnvtdatetime(sysdate)
     WHERE (frm.encntr_prsnl_reltn_id=rreclist->from_rec[loopcount].from_id)
    ;end update
   ELSE
    UPDATE  FROM encntr_prsnl_reltn frm
     SET frm.encntr_id = request->xxx_combine[icombine].to_xxx_id, frm.updt_cnt = (frm.updt_cnt+ 1),
      frm.updt_id = reqinfo->updt_id,
      frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm =
      cnvtdatetime(sysdate)
     WHERE (frm.encntr_prsnl_reltn_id=rreclist->from_rec[loopcount].from_id)
    ;end update
   ENDIF
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = rreclist->from_rec[loopcount].from_id
   SET request->xxx_combine_det[icombinedet].entity_name = "ENCNTR_PRSNL_RELTN"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ENCNTR_ID"
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = concat(
     "Couldn't update encntr_prsnl_reltn record with encntr_prsnl_reltn_id=",cnvtstring(rreclist->
      from_rec[loopcount].from_id))
    GO TO exit_sub
   ENDIF
 END ;Subroutine
 SUBROUTINE eff_from(dummy)
   IF (encntrtypecd_exists=1)
    UPDATE  FROM encntr_prsnl_reltn frm
     SET frm.encntr_id = request->xxx_combine[icombine].to_xxx_id, frm.end_effective_dt_tm =
      cnvtdatetime(sysdate), frm.encntr_type_cd = encntrtypecd_value,
      frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo->
      updt_applctx,
      frm.updt_task = reqinfo->updt_task, frm.updt_dt_tm = cnvtdatetime(sysdate)
     WHERE (frm.encntr_prsnl_reltn_id=rreclist->from_rec[loopcount].from_id)
    ;end update
   ELSE
    UPDATE  FROM encntr_prsnl_reltn frm
     SET frm.encntr_id = request->xxx_combine[icombine].to_xxx_id, frm.end_effective_dt_tm =
      cnvtdatetime(sysdate), frm.updt_cnt = (frm.updt_cnt+ 1),
      frm.updt_id = reqinfo->updt_id, frm.updt_applctx = reqinfo->updt_applctx, frm.updt_task =
      reqinfo->updt_task,
      frm.updt_dt_tm = cnvtdatetime(sysdate)
     WHERE (frm.encntr_prsnl_reltn_id=rreclist->from_rec[loopcount].from_id)
    ;end update
   ENDIF
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = eff
   SET request->xxx_combine_det[icombinedet].entity_id = rreclist->from_rec[loopcount].from_id
   SET request->xxx_combine_det[icombinedet].entity_name = "ENCNTR_PRSNL_RELTN"
   SET request->xxx_combine_det[icombinedet].attribute_name = "ENCNTR_ID"
   SET request->xxx_combine_det[icombinedet].prev_end_eff_dt_tm = rreclist->from_rec[loopcount].
   end_effective_dt_tm
   IF (curqual=0)
    SET failed = eff_error
    SET request->error_message = concat(
     "Couldn't restore effectivity of encntr_prsnl_reltn record with encntr_prsnl_reltn_id=",
     cnvtstring(rreclist->from_rec[loopcount].from_id))
    GO TO exit_sub
   ENDIF
 END ;Subroutine
 FREE SET rreclist
 FREE SET rcolumns
END GO
