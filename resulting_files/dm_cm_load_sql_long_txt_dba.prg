CREATE PROGRAM dm_cm_load_sql_long_txt:dba
 DECLARE rec_exist = vc WITH private
 DECLARE s_long_text_id = f8 WITH protect, noconstant(0.0)
 DECLARE s_dmpref_id = f8 WITH protect, noconstant(0.0)
 DECLARE err_msg = vc WITH protect, noconstant(" ")
 DECLARE ref_id = f8 WITH protect, noconstant(0.0)
 DECLARE dcdi_domain_info_cnt = i4 WITH protect, noconstant(size(requestin->list_0,5))
 FREE RECORD reply_long_text
 RECORD reply_long_text(
   1 dmpref_id = f8
   1 pref_ltr_id = f8
   1 pref_value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply_long_text->status_data.status = "F"
 SET rec_exist = validate(reply->status_data.status,"N")
 FOR (dcdi_i = 1 TO dcdi_domain_info_cnt)
   IF (cnvtreal(requestin->list_0[dcdi_i].pref_cd) > 0)
    SELECT INTO "NL:"
     pref.pref_id
     FROM dm_prefs pref
     WHERE (pref.pref_section=requestin->list_0[dcdi_i].pref_section)
      AND (pref.pref_name=requestin->list_0[dcdi_i].pref_name)
      AND pref.pref_cd=cnvtreal(requestin->list_0[dcdi_i].pref_cd)
     DETAIL
      ref_id = pref.pref_id
     WITH nocounter
    ;end select
    IF (error(err_msg,1) > 0)
     SET reply_long_text->status_data.subeventstatus[1].targetobjectvalue = err_msg
     SET reply_long_text->status_data.subeventstatus[1].targetobjectname = "dm_cm_load_sql_long_txt"
     GO TO exit_program
    ENDIF
    IF (ref_id > 0)
     DELETE  FROM long_text_reference
      WHERE parent_entity_name="DM_PREFS"
       AND parent_entity_id=ref_id
      WITH nocounter
     ;end delete
     IF (error(err_msg,1) > 0)
      SET reply_long_text->status_data.subeventstatus[1].targetobjectvalue = err_msg
      SET reply_long_text->status_data.subeventstatus[1].targetobjectname = "dm_cm_load_sql_long_txt"
      GO TO exit_program
     ENDIF
     DELETE  FROM dm_prefs
      WHERE pref_id=ref_id
      WITH nocounter
     ;end delete
     IF (error(err_msg,1) > 0)
      SET reply_long_text->status_data.subeventstatus[1].targetobjectvalue = err_msg
      SET reply_long_text->status_data.subeventstatus[1].targetobjectname = "dm_cm_load_sql_long_txt"
      ROLLBACK
      GO TO exit_program
     ENDIF
    ENDIF
    SET s_dmpref_id = s_insert_dmpref(requestin->list_0[dcdi_i].pref_section,requestin->list_0[dcdi_i
     ].pref_name,cnvtreal(requestin->list_0[dcdi_i].pref_cd))
    IF (s_dmpref_id > 0)
     SET s_long_text_id = s_insert_ltr(requestin->list_0[dcdi_i].pref_value,s_dmpref_id)
     IF (s_long_text_id > 0)
      SET reply_long_text->status_data.status = "S"
      SET reply_long_text->dmpref_id = s_dmpref_id
      SET reply_long_text->pref_ltr_id = s_long_text_id
      SET reply_long_text->pref_value = requestin->list_0[dcdi_i].pref_value
     ELSE
      ROLLBACK
      GO TO exit_program
     ENDIF
    ELSE
     SET reply_long_text->status_data.status = "F"
     SET reply_long_text->status_data.subeventstatus[1].targetobjectvalue =
     "Unable to create record for dm_prefs"
     SET reply_long_text->status_data.subeventstatus[1].targetobjectname = "dm_cm_load_sql_long_txt"
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE (s_insert_ltr(v_i_field_value=vc,v_dmpref_id=f8) =f8)
   DECLARE s_ltr_id = f8 WITH protect, noconstant(0)
   IF (textlen(trim(v_i_field_value,3)) > 0
    AND v_dmpref_id > 0)
    SELECT INTO "NL:"
     y = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      s_ltr_id = y
     WITH nocounter
    ;end select
    IF (error(err_msg,1) > 0)
     SET reply_long_text->status_data.subeventstatus[1].targetobjectvalue = err_msg
     SET reply_long_text->status_data.subeventstatus[1].targetobjectname = "s_insert_ltr"
     GO TO exit_program
    ENDIF
    INSERT  FROM long_text_reference ltr
     SET ltr.long_text_id = s_ltr_id, ltr.parent_entity_id = v_dmpref_id, ltr.parent_entity_name =
      "DM_PREFS",
      ltr.long_text = v_i_field_value, ltr.updt_cnt = 0, ltr.updt_task = reqinfo->updt_task,
      ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_dt_tm = cnvtdatetime(sysdate), ltr.updt_id
       = reqinfo->updt_id
     WITH nocounter
    ;end insert
    IF (error(err_msg,1) > 0)
     SET reply_long_text->status_data.subeventstatus[1].targetobjectvalue = err_msg
     SET reply_long_text->status_data.subeventstatus[1].targetobjectname = "s_insert_ltr"
     ROLLBACK
     GO TO exit_program
    ENDIF
    UPDATE  FROM dm_prefs dmp
     SET dmp.parent_entity_id = s_ltr_id, dmp.updt_applctx = reqinfo->updt_applctx, dmp.updt_cnt = 1,
      dmp.updt_dt_tm = cnvtdatetime(sysdate), dmp.updt_id = reqinfo->updt_id, dmp.updt_task = reqinfo
      ->updt_task
     WHERE dmp.pref_id=v_dmpref_id
     WITH nocounter
    ;end update
    IF (error(err_msg,1) > 0)
     SET reply_long_text->status_data.subeventstatus[1].targetobjectvalue = err_msg
     SET reply_long_text->status_data.subeventstatus[1].targetobjectname = "s_insert_ltr"
     ROLLBACK
     GO TO exit_program
    ENDIF
   ENDIF
   RETURN(s_ltr_id)
 END ;Subroutine
 SUBROUTINE (s_insert_dmpref(v_pref_section=vc,v_pref_name=vc,v_pref_cd=f8) =f8)
   DECLARE s_new_dmpref_id = f8 WITH protect, noconstant(0.0)
   IF (textlen(trim(v_pref_section,3)) > 0
    AND textlen(trim(v_pref_name,3)) > 0
    AND v_pref_cd > 0)
    SELECT INTO "nl:"
     s_nextseqnum = format(seq(dm_clinical_seq,nextval),"#################;rp0")
     FROM dual
     DETAIL
      s_new_dmpref_id = cnvtreal(s_nextseqnum)
     WITH format
    ;end select
    IF (((error(err_msg,1) > 0) OR (s_new_dmpref_id=0.0)) )
     SET reply_long_text->status_data.subeventstatus[1].targetobjectvalue = err_msg
     SET reply_long_text->status_data.subeventstatus[1].targetobjectname = "s_insert_dmpref"
     ROLLBACK
     GO TO exit_program
    ENDIF
    INSERT  FROM dm_prefs dmp
     SET dmp.pref_id = s_new_dmpref_id, dmp.pref_domain = "CONTENT MANAGER", dmp.parent_entity_name
       = "LONG_TEXT_REFERENCE",
      dmp.pref_section = v_pref_section, dmp.pref_name = v_pref_name, dmp.updt_cnt = 0,
      dmp.updt_task = reqinfo->updt_task, dmp.updt_applctx = 0, dmp.updt_dt_tm = cnvtdatetime(sysdate
       ),
      dmp.updt_id = reqinfo->updt_id, dmp.pref_cd = v_pref_cd
     WITH nocounter
    ;end insert
    IF (error(err_msg,1) > 0)
     SET reply_long_text->status_data.subeventstatus[1].targetobjectvalue = err_msg
     SET reply_long_text->status_data.subeventstatus[1].targetobjectname = "s_insert_dmpref"
     ROLLBACK
     GO TO exit_program
    ENDIF
   ENDIF
   RETURN(s_new_dmpref_id)
 END ;Subroutine
#exit_program
 IF ( NOT (rec_exist="N"))
  SET reply->status_data.status = reply_long_text->status_data.status
 ENDIF
END GO
