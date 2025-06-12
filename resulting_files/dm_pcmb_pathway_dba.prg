CREATE PROGRAM dm_pcmb_pathway:dba
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
 FREE RECORD rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_id = f8
     2 active_ind = i4
     2 active_status_cd = f8
     2 pathway_group_id = f8
     2 type_mean = c12
     2 warning_level_bit = i4
     2 pw_status_cd = f8
 )
 FREE RECORD rimpactedgroups
 RECORD rimpactedgroups(
   1 impacted_groups[*]
     2 pathway_group_id = f8
     2 pathway_id = f8
     2 type_mean = c12
     2 person_id = i4
     2 warning_level_bit = i4
     2 warning_level_bit_updt = i4
     2 pw_status_cd = f8
 )
 DECLARE populate_impacted_groups(null) = null
 DECLARE updt_pw_warning_level_bit(null) = null
 DECLARE upt_encntr_from(pathway_id,to_person_id,encntr_id) = null
 DECLARE calc_warning_level_bit(null) = null
 DECLARE from_pw_count = i4
 DECLARE cust_pw_loopcount = i4
 DECLARE impacted_groups_count = i4
 DECLARE from_rec_idx = i4
 DECLARE warning_bit = i4
 DECLARE warning_bit_updt = i4
 DECLARE protocol_person_id = i4
 DECLARE dot_person_id = i4
 DECLARE protcol_phase_pos = i4
 DECLARE protocol_grp_id = i4
 DECLARE impacted_grp_id_cnt = i4
 DECLARE dot_grp_id = i4
 DECLARE idebug_ind = i4
 DECLARE pw_void_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"VOID"))
 SET from_pw_count = 0
 SET pw_loopcount = 0
 SET impacted_groups_count = 0
 SET from_rec_idx = 0
 SET warning_bit = 0
 SET warning_bit_updt = 0
 SET protocol_person_id = 0
 SET dot_person_id = 0
 SET protcol_phase_pos = 0
 SET protocol_grp_id = 0
 SET impacted_grp_id_cnt = 0
 SET protocol_dot_saperation = 0
 SET idebug_ind = 0
 IF (validate(request->debug_ind)=1)
  SET idebug_ind = 1
 ELSE
  SET idebug_ind = 0
 ENDIF
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "PATHWAY"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "dm_pcmb_pathway"
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
     AND (frm.encntr_id=request->xxx_combine[icombine].encntr_id))
  ENDIF
  INTO "nl:"
  frm.*
  FROM pathway frm
  HEAD REPORT
   from_pw_count = 0
  DETAIL
   from_pw_count += 1
   IF (from_pw_count > size(rreclist->from_rec,5))
    stat = alterlist(rreclist->from_rec,(from_pw_count+ 10))
   ENDIF
   rreclist->from_rec[from_pw_count].from_id = frm.pathway_id, rreclist->from_rec[from_pw_count].
   active_ind = frm.active_ind, rreclist->from_rec[from_pw_count].active_status_cd = 0.00,
   rreclist->from_rec[from_pw_count].pathway_group_id = frm.pathway_group_id, rreclist->from_rec[
   from_pw_count].type_mean = trim(frm.type_mean), rreclist->from_rec[from_pw_count].
   warning_level_bit = frm.warning_level_bit,
   rreclist->from_rec[from_pw_count].pw_status_cd = frm.pw_status_cd
  FOOT REPORT
   IF (from_pw_count > 0)
    stat = alterlist(rreclist->from_rec,from_pw_count)
   ENDIF
  WITH forupdatewait(frm)
 ;end select
 SET from_pw_count = value(size(rreclist->from_rec,5))
 IF (idebug_ind=1)
  CALL echorecord(rreclist)
 ENDIF
 IF ((request->xxx_combine[icombine].encntr_id=0))
  FOR (pw_loopcount = 1 TO from_pw_count)
    SET pathway_id = rreclist->from_rec[pw_loopcount].from_id
    SET to_person_id = request->xxx_combine[icombine].to_xxx_id
    CALL upt_from(pathway_id,to_person_id)
  ENDFOR
 ELSE
  FOR (pw_loopcount = 1 TO from_pw_count)
    SET pathway_id = rreclist->from_rec[pw_loopcount].from_id
    SET to_person_id = request->xxx_combine[icombine].to_xxx_id
    SET encntr_id = request->xxx_combine[icombine].encntr_id
    CALL upt_encntr_from(pathway_id,to_person_id,encntr_id)
  ENDFOR
  CALL populate_impacted_groups(null)
  CALL calc_warning_level_bit(null)
  CALL updt_pw_warning_level_bit(null)
 ENDIF
 SUBROUTINE upt_from(pathway_id,to_person_id)
   UPDATE  FROM pathway frm
    SET frm.updt_applctx = reqinfo->updt_applctx, frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_dt_tm =
     cnvtdatetime(sysdate),
     frm.updt_id = reqinfo->updt_id, frm.updt_task = reqinfo->updt_task, frm.person_id = to_person_id
    WHERE frm.pathway_id=pathway_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = pathway_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PATHWAY"
   SET request->xxx_combine_det[icombinedet].attribute_name = "person_id"
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",pathway_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE populate_impacted_groups(null)
   SELECT INTO "nl:"
    dot_phase_ind = evaluate(trim(pw.type_mean),"DOT",1,0), pw.pw_group_nbr, pw.pathway_group_id
    FROM pathway pw
    PLAN (pw
     WHERE pw.pathway_group_id > 0
      AND expand(from_rec_idx,1,size(rreclist->from_rec,5),pw.pathway_group_id,rreclist->from_rec[
      from_rec_idx].pathway_group_id))
    ORDER BY pw.pw_group_nbr, pw.pathway_group_id, dot_phase_ind
    HEAD REPORT
     impacted_groups_count = 0
    HEAD pw.pw_group_nbr
     dummy = 0
    HEAD pw.pathway_group_id
     dummy = 0
    HEAD dot_phase_ind
     dummy = 0
    DETAIL
     IF (pw.pathway_group_id > 0)
      impacted_groups_count += 1
      IF (impacted_groups_count > size(rimpactedgroups->impacted_groups,5))
       stat = alterlist(rimpactedgroups->impacted_groups,(impacted_groups_count+ 10))
      ENDIF
      rimpactedgroups->impacted_groups[impacted_groups_count].pathway_group_id = pw.pathway_group_id,
      rimpactedgroups->impacted_groups[impacted_groups_count].pathway_id = pw.pathway_id,
      rimpactedgroups->impacted_groups[impacted_groups_count].person_id = pw.person_id,
      rimpactedgroups->impacted_groups[impacted_groups_count].type_mean = trim(pw.type_mean),
      rimpactedgroups->impacted_groups[impacted_groups_count].warning_level_bit = pw
      .warning_level_bit, rimpactedgroups->impacted_groups[impacted_groups_count].
      warning_level_bit_updt = pw.warning_level_bit
     ENDIF
    FOOT  dot_phase_ind
     dummy = 0
    FOOT  pw.pathway_group_id
     dummy = 0
    FOOT  pw.pw_group_nbr
     dummy = 0
    FOOT REPORT
     IF (impacted_groups_count > 0)
      stat = alterlist(rimpactedgroups->impacted_groups,impacted_groups_count)
     ENDIF
    WITH forupdatewait(pw), nocounter
   ;end select
   SET impacted_groups_count = value(size(rimpactedgroups->impacted_groups,5))
   IF (idebug_ind=1)
    CALL echorecord(rimpactedgroups)
   ENDIF
 END ;Subroutine
 SUBROUTINE updt_pw_warning_level_bit(null)
   FOR (impacted_grp_loopcnt = 1 TO impacted_groups_count)
     SET warning_bit = rimpactedgroups->impacted_groups[impacted_grp_loopcnt].warning_level_bit
     SET warning_bit_updt = rimpactedgroups->impacted_groups[impacted_grp_loopcnt].
     warning_level_bit_updt
     IF (warning_bit != warning_bit_updt)
      UPDATE  FROM pathway pw
       SET pw.warning_level_bit = rimpactedgroups->impacted_groups[impacted_grp_loopcnt].
        warning_level_bit_updt
       WHERE (pw.pathway_id=rimpactedgroups->impacted_groups[impacted_grp_loopcnt].pathway_id)
        AND pw.pw_status_cd != pw_void_cd
       WITH nocounter
      ;end update
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE upt_encntr_from(pathway_id,to_person_id,encntr_id)
   IF (idebug_ind=1)
    CALL echo(build("upt_encntr_from"))
    CALL echo(build("pathway_id:",pathway_id))
    CALL echo(build("to_person_id:",to_person_id))
    CALL echo(build("encntr_id:",encntr_id))
   ENDIF
   UPDATE  FROM pathway frm
    SET frm.updt_applctx = reqinfo->updt_applctx, frm.updt_cnt = (frm.updt_cnt+ 1), frm.updt_dt_tm =
     cnvtdatetime(sysdate),
     frm.updt_id = reqinfo->updt_id, frm.updt_task = reqinfo->updt_task, frm.person_id = to_person_id
    WHERE frm.pathway_id=pathway_id
     AND frm.encntr_id=encntr_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = upt
   SET request->xxx_combine_det[icombinedet].entity_id = pathway_id
   SET request->xxx_combine_det[icombinedet].entity_name = "PATHWAY"
   SET request->xxx_combine_det[icombinedet].attribute_name = "person_id"
   IF (curqual=0)
    SET failed = update_error
    SET request->error_message = substring(1,132,build("Could not update pk val=",pathway_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE calc_warning_level_bit(null)
  FOR (impacted_grp_loopcnt = 1 TO impacted_groups_count)
    IF ((((rimpactedgroups->impacted_groups[impacted_grp_loopcnt].type_mean="PHASE")) OR ((
    rimpactedgroups->impacted_groups[impacted_grp_loopcnt].type_mean="CAREPLAN"))) )
     SET protocol_person_id = rimpactedgroups->impacted_groups[impacted_grp_loopcnt].person_id
     SET protcol_phase_pos = impacted_grp_loopcnt
     SET protocol_grp_id = rimpactedgroups->impacted_groups[impacted_grp_loopcnt].pathway_group_id
     IF (btest(rimpactedgroups->impacted_groups[impacted_grp_loopcnt].warning_level_bit,0)=1)
      SET rimpactedgroups->impacted_groups[impacted_grp_loopcnt].warning_level_bit_updt = bxor(
       rimpactedgroups->impacted_groups[impacted_grp_loopcnt].warning_level_bit,1)
     ENDIF
     IF (idebug_ind=1)
      CALL echo(build("protocol_person_id:",protocol_person_id))
      CALL echo(build("protocol warning_level_bit_updt:",rimpactedgroups->impacted_groups[
        impacted_grp_loopcnt].warning_level_bit_updt))
     ENDIF
    ELSEIF ((rimpactedgroups->impacted_groups[impacted_grp_loopcnt].type_mean="DOT"))
     SET dot_person_id = rimpactedgroups->impacted_groups[impacted_grp_loopcnt].person_id
     SET dot_grp_id = rimpactedgroups->impacted_groups[impacted_grp_loopcnt].pathway_group_id
     IF (idebug_ind=1)
      CALL echo(build("dot_person_id:",dot_person_id))
     ENDIF
     IF (protocol_person_id != dot_person_id
      AND protocol_grp_id=dot_grp_id)
      IF (btest(rimpactedgroups->impacted_groups[impacted_grp_loopcnt].warning_level_bit,0) != 1)
       SET rimpactedgroups->impacted_groups[impacted_grp_loopcnt].warning_level_bit_updt = bor(
        rimpactedgroups->impacted_groups[impacted_grp_loopcnt].warning_level_bit,1)
      ENDIF
      IF (btest(rimpactedgroups->impacted_groups[protcol_phase_pos].warning_level_bit_updt,0) != 1)
       SET rimpactedgroups->impacted_groups[protcol_phase_pos].warning_level_bit_updt = bor(
        rimpactedgroups->impacted_groups[protcol_phase_pos].warning_level_bit,1)
      ENDIF
     ELSEIF (protocol_grp_id=dot_grp_id)
      IF (btest(rimpactedgroups->impacted_groups[impacted_grp_loopcnt].warning_level_bit_updt,0)=1)
       SET rimpactedgroups->impacted_groups[impacted_grp_loopcnt].warning_level_bit_updt = bxor(
        rimpactedgroups->impacted_groups[impacted_grp_loopcnt].warning_level_bit,1)
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
  IF (idebug_ind=1)
   CALL echo(build("verify warning_level_bit_updt on DOT and Protocols: "))
   CALL echorecord(rimpactedgroups)
  ENDIF
 END ;Subroutine
#exit_sub
 FREE RECORD rreclist
 FREE RECORD rimpactedgroups
END GO
