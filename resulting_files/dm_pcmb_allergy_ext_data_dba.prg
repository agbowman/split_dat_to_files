CREATE PROGRAM dm_pcmb_allergy_ext_data:dba
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
 SUBROUTINE (loadfromprovenanceallergylist(prov_list_ref=vc(ref)) =null)
   IF ((prov_list_ref->allergy_knt <= 0))
    SET failed = select_error
    SET request->error_message = "No allergies supplied"
    RETURN(null)
   ENDIF
   IF ((prov_list_ref->parent_entity_name != "ALLERGY")
    AND (prov_list_ref->parent_entity_name != "ALLERGY_EXT_DATA"))
    SET failed = select_error
    SET request->error_message = "Invalid parent entity name supplied"
    RETURN(null)
   ENDIF
   IF ((prov_list_ref->allergy_knt != size(prov_list_ref->allergy,5)))
    SET failed = select_error
    SET request->error_message =
    "Mismatch between supplied allergy count and number of supplied allergies"
    RETURN(null)
   ENDIF
   DECLARE num = i4 WITH protect
   DECLARE knt = i4 WITH public, noconstant(0)
   DECLARE paknt = i4 WITH public, noconstant(0)
   DECLARE paeknt = i4 WITH public, noconstant(0)
   DECLARE papknt = i4 WITH public, noconstant(0)
   DECLARE duplicatepae = i4 WITH public, noconstant(0)
   DECLARE duplicatepap = i4 WITH public, noconstant(0)
   SET knt = 0
   SET paknt = 0
   SET paeknt = 0
   SET papknt = 0
   SELECT INTO "nl:"
    FROM provenance_allergy pa,
     (left JOIN prov_allergy_entity pae ON pa.provenance_allergy_id=pae.provenance_allergy_id
      AND pae.active_ind=1),
     (left JOIN prov_allergy_participant pap ON pa.provenance_allergy_id=pap.provenance_allergy_id
      AND pap.active_ind=1)
    PLAN (pa
     WHERE expand(num,1,prov_list_ref->allergy_knt,pa.parent_entity_id,prov_list_ref->allergy[num].
      allergy_id)
      AND (pa.parent_entity_name=prov_list_ref->parent_entity_name)
      AND pa.active_ind=1)
     JOIN (pae)
     JOIN (pap)
    ORDER BY pa.parent_entity_id, pa.provenance_allergy_id, pae.prov_allergy_entity_id,
     pap.prov_allergy_participant_id
    HEAD REPORT
     CALL alterlist(prov_list_ref->allergy,10)
    HEAD pa.parent_entity_id
     knt += 1, paknt = 0
     IF (mod(knt,10)=1
      AND knt != 1)
      CALL alterlist(prov_list_ref->allergy,(knt+ 9))
     ENDIF
     CALL alterlist(prov_list_ref->allergy[knt].provenance_allergy,10)
    HEAD pa.provenance_allergy_id
     IF (pa.provenance_allergy_id > 0)
      paeknt = 0, papknt = 0, paknt += 1,
      prov_list_ref->allergy[knt].allergy_id = pa.parent_entity_id
      IF (mod(paknt,10)=1
       AND paknt != 1)
       CALL alterlist(prov_list_ref->allergy[knt].provenance_allergy,(paknt+ 9))
      ENDIF
      CALL alterlist(prov_list_ref->allergy[knt].provenance_allergy[paknt].prov_allergy_entity,10),
      CALL alterlist(prov_list_ref->allergy[knt].provenance_allergy[paknt].prov_allergy_participant,
      10), prov_list_ref->allergy[knt].provenance_allergy[paknt].provenance_allergy_id = pa
      .provenance_allergy_id,
      prov_list_ref->allergy[knt].provenance_allergy[paknt].parent_entity_id = pa.parent_entity_id,
      prov_list_ref->allergy[knt].provenance_allergy[paknt].parent_entity_name = pa
      .parent_entity_name, prov_list_ref->allergy[knt].provenance_allergy[paknt].
      provenance_recorded_dt_tm = pa.provenance_recorded_dt_tm,
      prov_list_ref->allergy[knt].provenance_allergy[paknt].client_ident = pa.client_ident,
      prov_list_ref->allergy[knt].provenance_allergy[paknt].group_id = pa.group_id, prov_list_ref->
      allergy[knt].provenance_allergy[paknt].persona_txt = pa.persona_txt,
      prov_list_ref->allergy[knt].provenance_allergy[paknt].active_ind = pa.active_ind, prov_list_ref
      ->allergy[knt].provenance_allergy[paknt].active_status_cd = pa.active_status_cd
     ENDIF
    HEAD pae.prov_allergy_entity_id
     duplicatepae = 0
     FOR (i = 1 TO paeknt)
       IF ((pae.prov_allergy_entity_id=prov_list_ref->allergy[knt].provenance_allergy[paknt].
       prov_allergy_entity[i].prov_allergy_entity_id))
        duplicatepae = 1
       ENDIF
     ENDFOR
     IF (pae.prov_allergy_entity_id > 0
      AND duplicatepae=0)
      paeknt += 1
      IF (mod(paeknt,10)=1
       AND paeknt != 1)
       CALL alterlist(prov_list_ref->allergy[knt].provenance_allergy[paknt].prov_allergy_entity,(
       paeknt+ 9))
      ENDIF
      prov_list_ref->allergy[knt].provenance_allergy[paknt].prov_allergy_entity[paeknt].
      prov_allergy_entity_id = pae.prov_allergy_entity_id, prov_list_ref->allergy[knt].
      provenance_allergy[paknt].prov_allergy_entity[paeknt].provenance_allergy_id = pae
      .provenance_allergy_id, prov_list_ref->allergy[knt].provenance_allergy[paknt].
      prov_allergy_entity[paeknt].parent_entity_id = pae.parent_entity_id,
      prov_list_ref->allergy[knt].provenance_allergy[paknt].prov_allergy_entity[paeknt].
      parent_entity_name = pae.parent_entity_name, prov_list_ref->allergy[knt].provenance_allergy[
      paknt].prov_allergy_entity[paeknt].entity_role_cd = pae.entity_role_cd, prov_list_ref->allergy[
      knt].provenance_allergy[paknt].prov_allergy_entity[paeknt].active_ind = pae.active_ind,
      prov_list_ref->allergy[knt].provenance_allergy[paknt].prov_allergy_entity[paeknt].
      active_status_cd = pae.active_status_cd
     ENDIF
    HEAD pap.prov_allergy_participant_id
     duplicatepap = 0
     FOR (i = 1 TO papknt)
       IF ((pap.prov_allergy_participant_id=prov_list_ref->allergy[knt].provenance_allergy[paknt].
       prov_allergy_participant[i].prov_allergy_participant_id))
        duplicatepap = 1
       ENDIF
     ENDFOR
     IF (pap.prov_allergy_participant_id > 0
      AND duplicatepap=0)
      papknt += 1
      IF (mod(papknt,10)=1
       AND papknt != 1)
       CALL alterlist(prov_list_ref->allergy[knt].provenance_allergy[paknt].prov_allergy_participant,
       (papknt+ 9))
      ENDIF
      prov_list_ref->allergy[knt].provenance_allergy[paknt].prov_allergy_participant[papknt].
      prov_allergy_participant_id = pap.prov_allergy_participant_id, prov_list_ref->allergy[knt].
      provenance_allergy[paknt].prov_allergy_participant[papknt].provenance_allergy_id = pap
      .provenance_allergy_id, prov_list_ref->allergy[knt].provenance_allergy[paknt].
      prov_allergy_participant[papknt].participation_type_cd = pap.participation_type_cd,
      prov_list_ref->allergy[knt].provenance_allergy[paknt].prov_allergy_participant[papknt].
      participant_entity_id = pap.participant_entity_id, prov_list_ref->allergy[knt].
      provenance_allergy[paknt].prov_allergy_participant[papknt].participant_entity_name = pap
      .participant_entity_name, prov_list_ref->allergy[knt].provenance_allergy[paknt].
      prov_allergy_participant[papknt].participant_role_cd = pap.participant_role_cd,
      prov_list_ref->allergy[knt].provenance_allergy[paknt].prov_allergy_participant[papknt].
      active_ind = pap.active_ind, prov_list_ref->allergy[knt].provenance_allergy[paknt].
      prov_allergy_participant[papknt].active_status_cd = pap.active_status_cd
     ENDIF
    FOOT  pa.provenance_allergy_id
     prov_list_ref->allergy[knt].provenance_allergy[paknt].prov_allergy_entity_knt = paeknt,
     prov_list_ref->allergy[knt].provenance_allergy[paknt].prov_allergy_participant_knt = papknt,
     CALL alterlist(prov_list_ref->allergy[knt].provenance_allergy[paknt].prov_allergy_entity,paeknt),
     CALL alterlist(prov_list_ref->allergy[knt].provenance_allergy[paknt].prov_allergy_participant,
     papknt)
    FOOT  pa.parent_entity_id
     prov_list_ref->allergy_knt = knt, prov_list_ref->allergy[knt].provenance_allergy_knt = paknt,
     CALL alterlist(prov_list_ref->allergy[knt].provenance_allergy,paknt)
    FOOT REPORT
     CALL alterlist(prov_list_ref->allergy,knt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (createprovenanceallergy(parententityname=vc,parententityid=f8,recordeddttm=f8,groupid=f8,
  clientident=vc,personatxt=vc) =f8)
   DECLARE active_status_cd = f8 WITH protect
   DECLARE provenance_allergy_id = f8 WITH protect
   SET active_status_cd = uar_get_code_by("DISPLAY",48,"Active")
   IF (active_status_cd <= 0)
    SET failed = select_error
    SET request->error_message = "Could not retrieve code_value for display Active from codeset 48"
    RETURN(0)
   ENDIF
   SET provenance_allergy_id = 0.0
   SELECT INTO "nl:"
    num = seq(provenance_seq,nextval)
    FROM dual
    DETAIL
     provenance_allergy_id = cnvtreal(num)
    WITH format, counter
   ;end select
   IF (provenance_allergy_id=0)
    SET failed = insert_error
    SET request->error_message = "Could not generate a new provenance_allergy_id"
    RETURN(0)
   ENDIF
   IF (groupid=0)
    SET groupid = provenance_allergy_id
   ENDIF
   INSERT  FROM provenance_allergy pa
    SET pa.provenance_allergy_id = provenance_allergy_id, pa.parent_entity_name = trim(
      parententityname), pa.parent_entity_id = parententityid,
     pa.provenance_recorded_dt_tm = cnvtdatetime(recordeddttm), pa.group_id = groupid, pa.active_ind
      = true,
     pa.active_status_cd = active_status_cd, pa.client_ident = clientident, pa.persona_txt =
     personatxt,
     pa.updt_cnt = 0, pa.updt_dt_tm = cnvtdatetime(sysdate), pa.updt_id = reqinfo->updt_id,
     pa.updt_task = reqinfo->updt_task, pa.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   RETURN(provenance_allergy_id)
 END ;Subroutine
 SUBROUTINE (createprovallergyentity(provenanceallergyid=f8,parententityname=vc,parententityid=f8,
  entityrolecd=f8) =f8)
   DECLARE active_status_cd = f8 WITH protect
   DECLARE prov_allergy_entity_id = f8 WITH protect
   SET active_status_cd = uar_get_code_by("DISPLAY",48,"Active")
   IF (active_status_cd <= 0)
    SET failed = select_error
    SET request->error_message = "Could not retrieve code_value for display Active from codeset 48"
    RETURN(0)
   ENDIF
   SET prov_allergy_entity_id = 0.0
   SELECT INTO "nl:"
    num = seq(provenance_seq,nextval)
    FROM dual
    DETAIL
     prov_allergy_entity_id = cnvtreal(num)
    WITH format, counter
   ;end select
   IF (prov_allergy_entity_id=0)
    SET failed = insert_error
    SET request->error_message = "Could not generate a new prov_allergy_entity_id"
    RETURN(0)
   ENDIF
   INSERT  FROM prov_allergy_entity pae
    SET pae.prov_allergy_entity_id = prov_allergy_entity_id, pae.provenance_allergy_id =
     provenanceallergyid, pae.parent_entity_name = trim(parententityname),
     pae.parent_entity_id = parententityid, pae.entity_role_cd = entityrolecd, pae.active_ind = true,
     pae.active_status_cd = active_status_cd, pae.updt_cnt = 0, pae.updt_dt_tm = cnvtdatetime(sysdate
      ),
     pae.updt_id = reqinfo->updt_id, pae.updt_task = reqinfo->updt_task, pae.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   RETURN(prov_allergy_entity_id)
 END ;Subroutine
 SUBROUTINE (createprovallergyparticipant(provenanceallergyid=f8,participationtypecd=f8,
  participantentityid=f8,participantentityname=vc,participantrolecd=f8) =f8)
   DECLARE active_status_cd = f8 WITH protect
   DECLARE prov_allergy_participant_id = f8 WITH protect
   SET active_status_cd = uar_get_code_by("DISPLAY",48,"Active")
   IF (active_status_cd <= 0)
    SET failed = select_error
    SET request->error_message = "Could not retrieve code_value for display Active from codeset 48"
    RETURN(0)
   ENDIF
   SET prov_allergy_participant_id = 0.0
   SELECT INTO "nl:"
    num = seq(provenance_seq,nextval)
    FROM dual
    DETAIL
     prov_allergy_participant_id = cnvtreal(num)
    WITH format, counter
   ;end select
   IF (prov_allergy_participant_id=0)
    SET failed = insert_error
    SET request->error_message = "Could not generate a new prov_allergy_participant_id"
    RETURN(0)
   ENDIF
   INSERT  FROM prov_allergy_participant pap
    SET pap.prov_allergy_participant_id = prov_allergy_participant_id, pap.provenance_allergy_id =
     provenanceallergyid, pap.participation_type_cd = participationtypecd,
     pap.participant_entity_id = participantentityid, pap.participant_entity_name = trim(
      participantentityname), pap.participant_role_cd = participantrolecd,
     pap.active_ind = true, pap.active_status_cd = active_status_cd, pap.updt_cnt = 0,
     pap.updt_dt_tm = cnvtdatetime(sysdate), pap.updt_id = reqinfo->updt_id, pap.updt_task = reqinfo
     ->updt_task,
     pap.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   RETURN(prov_allergy_participant_id)
 END ;Subroutine
 SUBROUTINE (find_new_allergy_id(old_allergy_id=f8,allergy_rltn_ref=vc(ref)) =f8)
   DECLARE index = i4
   FOR (index = 1 TO allergy_rltn_ref->allergy_knt)
     IF ((allergy_rltn_ref->allergy[index].old_allergy_id=old_allergy_id))
      RETURN(allergy_rltn_ref->allergy[index].new_allergy_id)
     ENDIF
   ENDFOR
   SET failed = error
   SET serrmsg = concat("Couldn't find new allergy id for old id: ",build(old_allergy_id))
   SET request->error_message = serrmsg
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE (handleprovenanceadd(prov_list_ref=vc(ref),allergy_rltn_ref=vc(ref)) =null)
   CALL echo("***")
   CALL echo("***   HandleProvenanceAdd")
   CALL echo("***")
   DECLARE combine_knt = i4
   SET combine_knt = 0
   SELECT INTO "n1:"
    ut.table_name
    FROM user_tables ut
    WHERE ut.table_name IN ("PROVENANCE_ALLERGY", "PROV_ALLERGY_ENTITY", "PROV_ALLERGY_PARTICIPANT")
    WITH nocounter
   ;end select
   IF (curqual >= 3)
    CALL loadfromprovenanceallergylist(prov_list_ref)
    IF (failed != false)
     SET table_name = "PROVENANCE_ALLERGY"
     SET serrmsg = request->error_message
     SET a_cmb_err = true
     GO TO exit_script
    ENDIF
    DECLARE newprovallergyid = f8 WITH protect
    DECLARE newproventityid = f8 WITH protect
    DECLARE newprovparticipantid = f8 WITH protect
    SET stat = alterlist(request->xxx_combine_det,(combine_knt+ 10))
    FOR (acnt = 1 TO prov_list_ref->allergy_knt)
      FOR (pacnt = 1 TO prov_list_ref->allergy[acnt].provenance_allergy_knt)
        IF ((prov_list_ref->allergy[acnt].provenance_allergy[pacnt].provenance_allergy_id > 0))
         DECLARE new_allergy_id = f8 WITH protect
         SET new_allergy_id = find_new_allergy_id(prov_list_ref->allergy[acnt].allergy_id,
          allergy_rltn_ref)
         SET newprovallergyid = createprovenanceallergy(prov_list_ref->allergy[acnt].
          provenance_allergy[pacnt].parent_entity_name,new_allergy_id,prov_list_ref->allergy[acnt].
          provenance_allergy[pacnt].provenance_recorded_dt_tm,prov_list_ref->allergy[acnt].
          provenance_allergy[pacnt].group_id,prov_list_ref->allergy[acnt].provenance_allergy[pacnt].
          client_ident,
          prov_list_ref->allergy[acnt].provenance_allergy[pacnt].persona_txt)
         IF (failed != false)
          SET stat = alterlist(request->xxx_combine_det,icombinedet)
          SET table_name = "PROVENANCE_ALLERGY"
          SET serrmsg = request->error_message
          SET a_cmb_err = true
          GO TO exit_script
         ENDIF
         SET icombinedet += 1
         SET stat = alterlist(request->xxx_combine_det,icombinedet)
         SET request->xxx_combine_det[icombinedet].combine_action_cd = add
         SET request->xxx_combine_det[icombinedet].entity_id = newprovallergyid
         SET request->xxx_combine_det[icombinedet].entity_name = "PROVENANCE_ALLERGY"
         SET request->xxx_combine_det[icombinedet].prev_active_ind = prov_frm_list->allergy[acnt].
         provenance_allergy[pacnt].active_ind
         SET request->xxx_combine_det[icombinedet].prev_active_status_cd = prov_frm_list->allergy[
         acnt].provenance_allergy[pacnt].active_status_cd
         FOR (paecnt = 1 TO prov_list_ref->allergy[acnt].provenance_allergy[pacnt].
         prov_allergy_entity_knt)
           IF ((prov_list_ref->allergy[acnt].provenance_allergy[pacnt].prov_allergy_entity[paecnt].
           prov_allergy_entity_id > 0))
            SET newproventityid = createprovallergyentity(newprovallergyid,prov_list_ref->allergy[
             acnt].provenance_allergy[pacnt].prov_allergy_entity[paecnt].parent_entity_name,
             prov_list_ref->allergy[acnt].provenance_allergy[pacnt].prov_allergy_entity[paecnt].
             parent_entity_id,prov_list_ref->allergy[acnt].provenance_allergy[pacnt].
             prov_allergy_entity[paecnt].entity_role_cd)
            IF (failed != false)
             SET stat = alterlist(request->xxx_combine_det,icombinedet)
             SET table_name = "PROV_ALLERGY_ENTITY"
             SET serrmsg = request->error_message
             SET a_cmb_err = true
             GO TO exit_script
            ENDIF
            SET icombinedet += 1
            SET stat = alterlist(request->xxx_combine_det,icombinedet)
            SET request->xxx_combine_det[icombinedet].combine_action_cd = add
            SET request->xxx_combine_det[icombinedet].entity_id = newproventityid
            SET request->xxx_combine_det[icombinedet].entity_name = "PROV_ALLERGY_ENTITY"
            SET request->xxx_combine_det[icombinedet].attribute_name = "PROVENANCE_ALLERGY_ID"
            SET request->xxx_combine_det[icombinedet].prev_active_ind = prov_frm_list->allergy[acnt].
            provenance_allergy[pacnt].prov_allergy_entity[paecnt].active_ind
            SET request->xxx_combine_det[icombinedet].prev_active_status_cd = prov_frm_list->allergy[
            acnt].provenance_allergy[pacnt].prov_allergy_entity[paecnt].active_status_cd
           ENDIF
         ENDFOR
         FOR (papcnt = 1 TO prov_list_ref->allergy[acnt].provenance_allergy[pacnt].
         prov_allergy_participant_knt)
           IF ((prov_list_ref->allergy[acnt].provenance_allergy[pacnt].prov_allergy_participant[
           papcnt].prov_allergy_participant_id > 0))
            SET newprovparticipantid = createprovallergyparticipant(newprovallergyid,prov_list_ref->
             allergy[acnt].provenance_allergy[pacnt].prov_allergy_participant[papcnt].
             participation_type_cd,prov_list_ref->allergy[acnt].provenance_allergy[pacnt].
             prov_allergy_participant[papcnt].participant_entity_id,prov_list_ref->allergy[acnt].
             provenance_allergy[pacnt].prov_allergy_participant[papcnt].participant_entity_name,
             prov_list_ref->allergy[acnt].provenance_allergy[pacnt].prov_allergy_participant[papcnt].
             participant_role_cd)
            IF (failed != false)
             SET stat = alterlist(request->xxx_combine_det,icombinedet)
             SET table_name = "PROV_ALLERGY_PARTICIPANT"
             SET serrmsg = request->error_message
             SET a_cmb_err = true
             GO TO exit_script
            ENDIF
            SET icombinedet += 1
            SET stat = alterlist(request->xxx_combine_det,icombinedet)
            SET request->xxx_combine_det[icombinedet].combine_action_cd = add
            SET request->xxx_combine_det[icombinedet].entity_id = newprovparticipantid
            SET request->xxx_combine_det[icombinedet].entity_name = "PROV_ALLERGY_PARTICIPANT"
            SET request->xxx_combine_det[icombinedet].attribute_name = "PROVENANCE_ALLERGY_ID"
            SET request->xxx_combine_det[icombinedet].prev_active_ind = prov_frm_list->allergy[acnt].
            provenance_allergy[pacnt].prov_allergy_participant[papcnt].active_ind
            SET request->xxx_combine_det[icombinedet].prev_active_status_cd = prov_frm_list->allergy[
            acnt].provenance_allergy[pacnt].prov_allergy_participant[papcnt].active_status_cd
           ENDIF
         ENDFOR
        ENDIF
      ENDFOR
    ENDFOR
    SET stat = alterlist(request->xxx_combine_det,icombinedet)
   ENDIF
 END ;Subroutine
 FREE SET rreclist
 RECORD rreclist(
   1 from_rec[*]
     2 from_id = f8
     2 active_ind = i2
     2 active_status_cd = f8
 )
 FREE RECORD prov_frm_list
 RECORD prov_frm_list(
   1 allergy_knt = i4
   1 parent_entity_name = vc
   1 allergy[*]
     2 allergy_id = f8
     2 provenance_allergy_knt = i4
     2 provenance_allergy[*]
       3 prov_allergy_entity_knt = i4
       3 prov_allergy_participant_knt = i4
       3 provenance_allergy_id = f8
       3 parent_entity_id = f8
       3 parent_entity_name = vc
       3 provenance_recorded_dt_tm = dq8
       3 client_ident = vc
       3 group_id = f8
       3 persona_txt = vc
       3 active_ind = i2
       3 active_status_cd = f8
       3 prov_allergy_entity[*]
         4 prov_allergy_entity_id = f8
         4 provenance_allergy_id = f8
         4 parent_entity_id = f8
         4 parent_entity_name = vc
         4 entity_role_cd = f8
         4 active_ind = i2
         4 active_status_cd = f8
       3 prov_allergy_participant[*]
         4 prov_allergy_participant_id = f8
         4 provenance_allergy_id = f8
         4 participation_type_cd = f8
         4 participant_entity_id = f8
         4 participant_entity_name = vc
         4 participant_role_cd = f8
         4 active_ind = i2
         4 active_status_cd = f8
 )
 FREE RECORD allergy_rltn
 RECORD allergy_rltn(
   1 allergy_knt = i4
   1 allergy[*]
     2 old_allergy_id = f8
     2 new_allergy_id = f8
 )
 DECLARE new_ext_id = f8 WITH public, noconstant(0.0)
 DECLARE map_allergies(mode=vc,old_allergy_ext_id=f8,new_allergy_ext_id=f8) = i4 WITH map = "HASH"
 DECLARE found_alg_cnt = i4 WITH protect, noconstant(0)
 DECLARE v_cust_loopcount = i4 WITH protect, noconstant(0)
 DECLARE active_status_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 CALL dm_cmb_get_context(0)
 IF ((dm_cmb_cust_script->exc_maint_ind=1))
  SET stat = alterlist(dcem_request->qual,1)
  SET dcem_request->qual[1].parent_entity = "PERSON"
  SET dcem_request->qual[1].child_entity = "ALLERGY_EXT_DATA"
  SET dcem_request->qual[1].op_type = "COMBINE"
  SET dcem_request->qual[1].script_name = "DM_PCMB_ALLERGY_EXT_DATA"
  SET dcem_request->qual[1].single_encntr_ind = 1
  SET dcem_request->qual[1].script_run_order = 1
  SET dcem_request->qual[1].del_chg_id_ind = 0
  SET dcem_request->qual[1].delete_row_ind = 0
  EXECUTE dm_cmb_exception_maint
  CALL dm_cmb_exc_maint_status(dcem_reply->status,dcem_reply->err_msg,dcem_request->qual[1].
   child_entity)
  GO TO exit_script
 ENDIF
 SELECT
  IF ((request->xxx_combine[icombine].encntr_id > 0.0))
   WHERE (aed.person_id=request->xxx_combine[icombine].from_xxx_id)
    AND (aed.encntr_id=request->xxx_combine[icombine].encntr_id)
    AND aed.active_ind=1
  ELSE
   WHERE (aed.person_id=request->xxx_combine[icombine].from_xxx_id)
    AND aed.active_ind=1
  ENDIF
  INTO "nl:"
  FROM allergy_ext_data aed
  DETAIL
   found_alg_cnt += 1
   IF (mod(found_alg_cnt,10)=1)
    stat = alterlist(rreclist->from_rec,(found_alg_cnt+ 9))
   ENDIF
   rreclist->from_rec[found_alg_cnt].from_id = aed.allergy_ext_data_id, rreclist->from_rec[
   found_alg_cnt].active_ind = aed.active_ind, rreclist->from_rec[found_alg_cnt].active_status_cd =
   aed.active_status_cd
  WITH forupdatewait(aed)
 ;end select
 SET stat = alterlist(rreclist->from_rec,found_alg_cnt)
 DECLARE findidfrommap = i4
 SET findidfrommap = 0
 IF (found_alg_cnt > 0)
  SET stat = alterlist(allergy_rltn->allergy,found_alg_cnt)
  SET allergy_rltn->allergy_knt = found_alg_cnt
  SET stat = alterlist(prov_frm_list->allergy,found_alg_cnt)
  SET prov_frm_list->allergy_knt = found_alg_cnt
  SET prov_frm_list->parent_entity_name = "ALLERGY_EXT_DATA"
  FOR (v_cust_loopcount = 1 TO found_alg_cnt)
    IF (duplicate_allergy_to_new_person(rreclist->from_rec[v_cust_loopcount].from_id,request->
     xxx_combine[icombine].to_xxx_id,request->xxx_combine[icombine].from_xxx_id)=0)
     GO TO exit_script
    ENDIF
    IF (combine_away_old_patient(rreclist->from_rec[v_cust_loopcount].from_id,rreclist->from_rec[
     v_cust_loopcount].active_ind,rreclist->from_rec[v_cust_loopcount].active_status_cd)=0)
     GO TO exit_script
    ENDIF
    SET findidfrommap = map_allergies("FIND",rreclist->from_rec[v_cust_loopcount].from_id,new_ext_id)
    IF (findidfrommap != 1)
     SET failed = select_error
     SET request->error_message = concat(
      "Unable to find the new allergy ext id for allergy_ext_data_id = ",rreclist->from_rec[
      v_cust_loopcount].from_id)
     GO TO exit_script
    ENDIF
    SET allergy_rltn->allergy[v_cust_loopcount].old_allergy_id = rreclist->from_rec[v_cust_loopcount]
    .from_id
    SET allergy_rltn->allergy[v_cust_loopcount].new_allergy_id = new_ext_id
    SET prov_frm_list->allergy[v_cust_loopcount].allergy_id = rreclist->from_rec[v_cust_loopcount].
    from_id
  ENDFOR
  CALL handleprovenanceadd(prov_frm_list,allergy_rltn)
 ENDIF
 SUBROUTINE (duplicate_allergy_to_new_person(old_pk_id=f8,new_person_id=f8,old_person_id=f8) =i4)
   DECLARE v_at_new_id = f8
   SET v_at_new_id = 0.0
   SELECT INTO "nl:"
    num = seq(health_status_seq,nextval)
    FROM dual
    DETAIL
     v_at_new_id = cnvtreal(num)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET failed = insert_error
    SET request->error_message = "Could not generate a new allergy_ext_data_id"
    RETURN(0)
   ENDIF
   SET stat = map_allergies("ADDREP",old_pk_id,v_at_new_id)
   SET at_acv_size = size(dm_cmb_cust_cols->add_col_val,5)
   IF (at_acv_size=0)
    SET stat = alterlist(dm_cmb_cust_cols->add_col_val,(at_acv_size+ 9))
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 1)].col_name = "ALLERGY_EXT_DATA_ID"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 1)].col_value = build(v_at_new_id)
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 2)].col_name = "PERSON_ID"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 2)].col_value = build(new_person_id)
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 3)].col_name = "ALLERGY_ID"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 3)].col_value = build(v_at_new_id)
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 4)].col_name = "ACTIVE_IND"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 4)].col_value = "TRUE"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 5)].col_name = "ACTIVE_STATUS_CD"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 5)].col_value = build(active_status_code_value)
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 6)].col_name = "CMB_ALLERGY_EXT_DATA_ID"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 6)].col_value = build(old_pk_id)
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 7)].col_name = "CMB_PERSON_ID"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 7)].col_value = build(old_person_id)
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 8)].col_name = "CMB_PRSNL_ID"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 8)].col_value = build(reqinfo->updt_id)
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 9)].col_name = "CMB_DT_TM"
    SET dm_cmb_cust_cols->add_col_val[(at_acv_size+ 9)].col_value = "CNVTDATETIME(CURDATE,CURTIME3)"
   ELSE
    FOR (val_loop = 1 TO at_acv_size)
      CASE (dm_cmb_cust_cols->add_col_val[val_loop].col_name)
       OF "ALLERGY_EXT_DATA_ID":
        SET dm_cmb_cust_cols->add_col_val[val_loop].col_value = build(v_at_new_id)
       OF "PERSON_ID":
        SET dm_cmb_cust_cols->add_col_val[val_loop].col_value = build(new_person_id)
       OF "ALLERGY_ID":
        SET dm_cmb_cust_cols->add_col_val[val_loop].col_value = build(v_at_new_id)
       OF "ACTIVE_IND":
        SET dm_cmb_cust_cols->add_col_val[val_loop].col_value = "TRUE"
       OF "ACTIVE_STATUS_CD":
        SET dm_cmb_cust_cols->add_col_val[val_loop].col_value = build(active_status_code_value)
       OF "CMB_ALLERGY_EXT_DATA_ID":
        SET dm_cmb_cust_cols->add_col_val[val_loop].col_value = build(old_pk_id)
       OF "CMB_PERSON_ID":
        SET dm_cmb_cust_cols->add_col_val[val_loop].col_value = build(old_person_id)
       OF "CMB_PRSNL_ID":
        SET dm_cmb_cust_cols->add_col_val[val_loop].col_value = build(reqinfo->updt_id)
       OF "CMB_DT_TM":
        SET dm_cmb_cust_cols->add_col_val[val_loop].col_value = "CNVTDATETIME(CURDATE,CURTIME3)"
      ENDCASE
    ENDFOR
   ENDIF
   SET stat = alterlist(dm_cmb_cust_cols->where_col_val,1)
   SET dm_cmb_cust_cols->where_col_val[1].col_name = "ALLERGY_EXT_DATA_ID"
   SET dm_cmb_cust_cols->where_col_val[1].col_value = build(old_pk_id)
   IF (size(dm_cmb_cust_cols->col,5)=0)
    SET dm_cmb_cust_cols->tbl_name = "ALLERGY_EXT_DATA"
    SET dm_cmb_cust_cols->sub_select_from_tbl = "ALLERGY_EXT_DATA"
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
   SET request->xxx_combine_det[icombinedet].entity_name = "ALLERGY_EXT_DATA"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (combine_away_old_patient(old_pk_id=f8,old_person_active_ind=i2,old_person_act_status=f8
  ) =i4)
   UPDATE  FROM allergy_ext_data aed
    SET aed.active_ind = false, aed.active_status_cd = combinedaway, aed.updt_cnt = (aed.updt_cnt+ 1),
     aed.updt_id = reqinfo->updt_id, aed.updt_applctx = reqinfo->updt_applctx, aed.updt_task =
     reqinfo->updt_task,
     aed.updt_dt_tm = cnvtdatetime(sysdate)
    WHERE aed.allergy_ext_data_id=old_pk_id
    WITH nocounter
   ;end update
   SET icombinedet += 1
   SET stat = alterlist(request->xxx_combine_det,icombinedet)
   SET request->xxx_combine_det[icombinedet].combine_action_cd = del
   SET request->xxx_combine_det[icombinedet].entity_id = old_pk_id
   SET request->xxx_combine_det[icombinedet].entity_name = "ALLERGY_EXT_DATA"
   SET request->xxx_combine_det[icombinedet].attribute_name = "PERSON_ID"
   SET request->xxx_combine_det[icombinedet].prev_active_ind = old_person_active_ind
   SET request->xxx_combine_det[icombinedet].prev_active_status_cd = old_person_act_status
   IF (curqual=0)
    SET failed = delete_error
    SET request->error_message = concat(
     "Couldn't inactivate allergy_ext_data record with allergy_ext_data_id = ",old_pk_id)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_script
 CALL echo(request->error_message)
 FREE SET rreclist
 FREE RECORD prov_frm_list
 FREE RECORD allergy_rltn
END GO
