CREATE PROGRAM cps_ens_scd_temp_note:dba
 IF (validate(reply,"0")="0")
  RECORD reply(
    1 notes[*]
      2 scd_story_id = f8
      2 update_lock_dt_tm = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 cps_error
      2 cnt = i4
      2 data[*]
        3 code = i4
        3 severity_level = i4
        3 supp_err_txt = c32
        3 def_msg = vc
        3 row_data
          4 lvl_1_idx = i4
          4 lvl_2_idx = i4
          4 lvl_3_idx = i4
  )
 ENDIF
 DECLARE cps_lock = i4 WITH public, constant(100)
 DECLARE cps_no_seq = i4 WITH public, constant(101)
 DECLARE cps_updt_cnt = i4 WITH public, constant(102)
 DECLARE cps_insuf_data = i4 WITH public, constant(103)
 DECLARE cps_update = i4 WITH public, constant(104)
 DECLARE cps_insert = i4 WITH public, constant(105)
 DECLARE cps_delete = i4 WITH public, constant(106)
 DECLARE cps_select = i4 WITH public, constant(107)
 DECLARE cps_auth = i4 WITH public, constant(108)
 DECLARE cps_inval_data = i4 WITH public, constant(109)
 DECLARE cps_ens_note_story_not_locked = i4 WITH public, constant(110)
 DECLARE cps_lock_msg = c33 WITH public, constant("Failed to lock all requested rows")
 DECLARE cps_no_seq_msg = c34 WITH public, constant("Failed to get next sequence number")
 DECLARE cps_updt_cnt_msg = c28 WITH public, constant("Failed to match update count")
 DECLARE cps_insuf_data_msg = c38 WITH public, constant("Request did not supply sufficient data")
 DECLARE cps_update_msg = c24 WITH public, constant("Failed on update request")
 DECLARE cps_insert_msg = c24 WITH public, constant("Failed on insert request")
 DECLARE cps_delete_msg = c24 WITH public, constant("Failed on delete request")
 DECLARE cps_select_msg = c24 WITH public, constant("Failed on select request")
 DECLARE cps_auth_msg = c34 WITH public, constant("Failed on authorization of request")
 DECLARE cps_inval_data_msg = c35 WITH public, constant("Request contained some invalid data")
 DECLARE cps_success = i4 WITH public, constant(0)
 DECLARE cps_success_info = i4 WITH public, constant(1)
 DECLARE cps_success_warn = i4 WITH public, constant(2)
 DECLARE cps_deadlock = i4 WITH public, constant(3)
 DECLARE cps_script_fail = i4 WITH public, constant(4)
 DECLARE cps_sys_fail = i4 WITH public, constant(5)
 SUBROUTINE cps_add_error(cps_errcode,severity_level,supp_err_txt,def_msg,idx1,idx2,idx3)
   SET reply->cps_error.cnt = (reply->cps_error.cnt+ 1)
   SET errcnt = reply->cps_error.cnt
   SET stat = alterlist(reply->cps_error.data,errcnt)
   SET reply->cps_error.data[errcnt].code = cps_errcode
   SET reply->cps_error.data[errcnt].severity_level = severity_level
   SET reply->cps_error.data[errcnt].supp_err_txt = supp_err_txt
   SET reply->cps_error.data[errcnt].def_msg = def_msg
   SET reply->cps_error.data[errcnt].row_data.lvl_1_idx = idx1
   SET reply->cps_error.data[errcnt].row_data.lvl_2_idx = idx2
   SET reply->cps_error.data[errcnt].row_data.lvl_3_idx = idx3
 END ;Subroutine
 IF (size(request->notes,5)=0)
  CALL cps_add_error(cps_insuf_data,cps_script_fail,"No Autosave NOTES specified",cps_insuf_data_msg,
   0,
   0,0)
  GO TO exit_script
 ENDIF
 DECLARE checklocked(null) = i2 WITH protect
 DECLARE findcodevaluebymeaning(codeset=i4,meaning=vc) = f8 WITH protect
 DECLARE insertscdstory(null) = null WITH protect
 DECLARE insertautosaveblobs(storyid=f8) = null WITH protect
 DECLARE scdgetuniqueactivityid(null) = f8 WITH protect
 DECLARE insertstorypattern(patidsize=i4,storyid=f8) = null WITH protect
 DECLARE insertconcepts(index=i4) = null WITH protect
 DECLARE failed = i2 WITH protect, noconstant(0)
 DECLARE unique_story_id = f8 WITH protect, noconstant(0.0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH public, noconstant(0)
 DECLARE serrmsg = vc WITH public, noconstant(fillstring(150," "))
 DECLARE table_name = vc WITH public, noconstant(fillstring(50," "))
 DECLARE update_cnt = i4 WITH protect, noconstant(0)
 DECLARE story_completion_status_mean = vc WITH protect, noconstant("")
 DECLARE number_notes = i4 WITH protect, constant(size(request->notes,5))
 DECLARE pat_id_cnt = i4 WITH private, noconstant(0)
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET stat = alterlist(reply->notes,number_notes)
 FOR (note_index = 1 TO number_notes)
   IF ((request->notes[note_index].action_type="ASV"))
    IF ((request->notes[note_index].scd_story_id=0.0))
     CALL insertscdstory(null)
     IF (failed=1)
      SET serrmsg = "InsertScdStory failed in cps_ens_scd_temp_note"
      SET table_name = "SCD_STORY"
      GO TO exit_script
     ENDIF
     SET pat_id_cnt = size(request->notes[note_index].scr_pattern_id,5)
     IF (pat_id_cnt != 0)
      CALL insertstorypattern(pat_id_cnt,reply->notes[note_index].scd_story_id)
      IF (failed=1)
       SET serrmsg = "InsertStoryPattern failed in cps_ens_scd_temp_note"
       SET table_name = "SCD_STORY_PATTERN"
       GO TO exit_script
      ENDIF
     ENDIF
     CALL insertconcepts(note_index)
     IF (failed=1)
      SET serrmsg = "InsertConcepts failed in cps_ens_scd_temp_note"
      SET table_name = "SCD_STORY_CONCEPT"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->notes[note_index].scd_story_id = request->notes[note_index].scd_story_id
     SET reply->notes[note_index].update_lock_dt_tm = request->notes[note_index].update_lock_dt_tm
     FREE RECORD lock_data
     RECORD lock_data(
       1 story_id = f8
       1 actn_type = c3
       1 update_lock_dt_tm = dq8
       1 note_index = i4
     )
     SET lock_data->story_id = request->notes[note_index].scd_story_id
     SET lock_data->actn_type = request->notes[note_index].action_type
     SET lock_data->update_lock_dt_tm = request->notes[note_index].update_lock_dt_tm
     SET lock_data->note_index = note_index
     DECLARE irtn = i2 WITH noconstant(0)
     SET irtn = checklocked(null)
     FREE RECORD lock_data
     IF (irtn > 0)
      SET serrmsg = "Lock check on document failed"
      SET table_name = "SCD_STORY"
      SET failed = 1
      GO TO exit_script
     ENDIF
     IF (story_completion_status_mean="AUTOSAVED")
      SET pat_id_cnt = size(request->notes[note_index].scr_pattern_id,5)
      IF (pat_id_cnt != 0)
       DELETE  FROM scd_story_pattern s
        WHERE (s.scd_story_id=request->notes[note_index].scd_story_id)
        WITH nocounter
       ;end delete
       IF (curqual=0)
        CALL cps_add_error(cps_delete,cps_script_fail,"DELETING OLD STORY_PATTERNS",cps_delete_msg,
         note_index,
         0,0)
        SET serrmsg = "Deleting old story patterns failed in cps_ens_scd_temp_note"
        SET table_name = "SCD_STORY_PATTERN"
        GO TO exit_script
       ENDIF
       CALL insertstorypattern(pat_id_cnt,request->notes[note_index].scd_story_id)
       IF (failed=1)
        SET serrmsg = "InsertStoryPattern failed in cps_ens_scd_temp_note"
        SET table_name = "SCD_STORY_PATTERN"
        GO TO exit_script
       ENDIF
      ENDIF
      DELETE  FROM scd_story_concept ssc
       WHERE (ssc.scd_story_id=request->notes[note_index].scd_story_id)
       WITH nocounter
      ;end delete
      CALL insertconcepts(note_index)
      IF (failed=1)
       SET serrmsg = "InsertConcepts failed in cps_ens_scd_temp_note"
       SET table_name = "SCD_STORY_CONCEPT"
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    CALL insertautosaveblobs(reply->notes[note_index].scd_story_id)
    IF (failed=1)
     SET serrmsg = "InsertAutoSaveBlobs failed in cps_ens_scd_temp_note"
     SET table_name = "LONG_BLOB"
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (failed=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  IF (textlen(trim(serrmsg)) > 0)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  ENDIF
  CALL echorecord(request)
 ENDIF
 SUBROUTINE scdgetuniqueid(null)
   DECLARE unique_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    next_seq = seq(scd_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     unique_id = cnvtreal(next_seq)
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET failed = 1
    CALL cps_add_error(cps_select,cps_script_fail,"Getting INSERT IDS",cps_select_msg,0,
     0,0)
   ENDIF
   RETURN(unique_id)
 END ;Subroutine
 SUBROUTINE scdgetuniqueactivityid(null)
   DECLARE unique_id = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    next_seq = seq(scd_act_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     unique_id = cnvtreal(next_seq)
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET failed = 1
    CALL cps_add_error(cps_select,cps_script_fail,"Getting INSERT IDS",cps_select_msg,0,
     0,0)
   ENDIF
   RETURN(unique_id)
 END ;Subroutine
 SUBROUTINE checklocked(null)
   FREE RECORD current_lock_data
   RECORD current_lock_data(
     1 update_lock_user_id = f8
     1 update_lock_dt_tm = dq8
   )
   SELECT INTO "NL:"
    FROM scd_story n
    WHERE (n.scd_story_id=lock_data->story_id)
     AND (n.update_lock_user_id=reqinfo->updt_id)
    DETAIL
     update_cnt = n.updt_cnt, current_lock_data->update_lock_dt_tm = n.update_lock_dt_tm
     IF (validate(story_completion_status_mean)=1)
      story_completion_status_mean = uar_get_code_meaning(n.story_completion_status_cd)
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET failed = 1
    SELECT INTO "NL:"
     FROM scd_story n
     WHERE (n.scd_story_id=lock_data->story_id)
     DETAIL
      current_lock_data->update_lock_user_id = n.update_lock_user_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL cps_add_error(cps_ens_note_story_not_locked,cps_script_fail,build("STORY NOT FOUND: ",
       lock_data->story_id),cps_select_msg,lock_data->note_index,
      0,cnvtint(reqinfo->updt_id))
     RETURN(1)
    ENDIF
    IF ((current_lock_data->update_lock_user_id=0.0))
     IF ((lock_data->actn_type="UNL"))
      CALL cps_add_error(cps_ens_note_story_not_locked,cps_success_warn,build("STORY IS NOT LOCKED: ",
        lock_data->story_id),cps_updt_cnt_msg,lock_data->note_index,
       0,cnvtint(reqinfo->updt_id))
      SET failed = 0
      RETURN(1)
     ELSE
      CALL cps_add_error(cps_ens_note_story_not_locked,cps_script_fail,"STORY IS NOT LOCKED.",
       cps_updt_cnt_msg,lock_data->note_index,
       cnvtint(lock_data->story_id),cnvtint(reqinfo->updt_id))
      RETURN(1)
     ENDIF
    ENDIF
    CALL cps_add_error(cps_ens_note_story_not_locked,cps_script_fail,"STORY NOT LOCKED BY THIS USER.",
     cps_updt_cnt_msg,lock_data->note_index,
     cnvtint(lock_data->story_id),cnvtint(reqinfo->updt_id))
    RETURN(1)
   ELSE
    IF ((lock_data->update_lock_dt_tm != 0))
     IF ((current_lock_data->update_lock_dt_tm != lock_data->update_lock_dt_tm))
      IF ((lock_data->actn_type="UNL"))
       CALL cps_add_error(cps_ens_note_story_not_locked,cps_success_warn,
        "USER HAS TWO SESSIONS,SAME STORY",cps_update_msg,lock_data->note_index,
        cnvtint(lock_data->story_id),cnvtint(reqinfo->updt_id))
       SET failed = 0
       RETURN(1)
      ELSE
       CALL cps_add_error(cps_ens_note_story_not_locked,cps_script_fail,
        "USER HAS TWO SESSIONS,SAME STORY",cps_update_msg,lock_data->note_index,
        cnvtint(lock_data->story_id),cnvtint(reqinfo->updt_id))
       SET failed = 1
       RETURN(1)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   FREE RECORD current_lock_data
   RETURN(0)
 END ;Subroutine
 SUBROUTINE findcodevaluebymeaning(codeset,meaning)
   DECLARE codevalue = f8 WITH noconstant(0.0)
   IF (textlen(trim(meaning)) > 0)
    SET codevalue = uar_get_code_by("MEANING",codeset,nullterm(meaning))
    IF ((((codevalue=- (1.0))) OR (codevalue=0.0)) )
     SET table_name = "CODE_VALUE"
     SET serrmsg = build("Failed to find (or found duplicates of) the code_value for cdf_meaning '",
      meaning,"'from code_set: ",codeset)
     SET failed = 1
    ENDIF
   ELSE
    SET codevalue = 0.0
   ENDIF
   RETURN(codevalue)
 END ;Subroutine
 SUBROUTINE insertscdstory(null)
   DECLARE new_story_id = f8 WITH protect, noconstant(0.0)
   DECLARE story_completion_status_cd = f8 WITH protect, noconstant(0.0)
   DECLARE story_type_cd = f8 WITH protect, noconstant(0.0)
   DECLARE update_lock_dt_tm = f8
   SET new_story_id = scdgetuniqueactivityid(null)
   IF (failed=1)
    RETURN
   ENDIF
   SET reply->notes[note_index].scd_story_id = new_story_id
   SET update_lock_dt_tm = cnvtdatetime(curdate,curtime3)
   SET reply->notes[note_index].update_lock_dt_tm = update_lock_dt_tm
   SET story_type_cd = findcodevaluebymeaning(15749,nullterm("DOC"))
   IF (failed=1)
    CALL cps_add_error(cps_inval_data,cps_script_fail,"Autosave - story_type_cd",cps_inval_data_msg,
     note_index,
     0,0)
    RETURN
   ENDIF
   SET story_completion_status_cd = findcodevaluebymeaning(15750,nullterm("AUTOSAVED"))
   IF (failed=1)
    CALL cps_add_error(cps_inval_data,cps_script_fail,"Autosave - story_completion_status",
     cps_inval_data_msg,note_index,
     0,0)
    RETURN
   ENDIF
   IF ((request->notes[note_index].entry_mode_cd=0))
    SET request->notes[note_index].entry_mode_cd = findcodevaluebymeaning(29520,nullterm(request->
      notes[note_index].entry_mode_mean))
    IF (failed=1)
     CALL cps_add_error(cps_inval_data,cps_script_fail,"Autosave - ENTRY MODE",cps_inval_data_msg,
      note_index,
      0,0)
     RETURN
    ENDIF
   ENDIF
   INSERT  FROM scd_story n
    SET n.scd_story_id = new_story_id, n.story_type_cd = story_type_cd, n.title = request->notes[
     note_index].title,
     n.author_id = request->notes[note_index].author_id, n.event_id = 0.0, n.encounter_id = request->
     notes[note_index].encounter_id,
     n.person_id = request->notes[note_index].person_id, n.story_completion_status_cd =
     story_completion_status_cd, n.update_lock_user_id = reqinfo->updt_id,
     n.update_lock_dt_tm = cnvtdatetime(update_lock_dt_tm), n.active_ind = 1, n.active_status_cd =
     reqdata->active_status_cd,
     n.active_status_dt_tm = cnvtdatetime(curdate,curtime3), n.active_status_prsnl_id = reqinfo->
     updt_id, n.updt_cnt = 0,
     n.updt_id = reqinfo->updt_id, n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_task =
     reqinfo->updt_task,
     n.updt_applctx = reqinfo->updt_applctx, n.entry_mode_cd = request->notes[note_index].
     entry_mode_cd
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = 1
    CALL cps_add_error(cps_insert,cps_script_fail,"Autosave - INSERTING STORY",cps_insert_msg,
     note_index,
     0,0)
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE insertautosaveblobs(storyid)
   IF (storyid=0.0)
    SET failed = 1
    CALL cps_add_error(cps_insert,cps_script_fail,"Autosave - INSERTING LONG BLOBS - StoryId=0.0",
     cps_insert_msg,curqual,
     0,0)
    RETURN
   ENDIF
   DECLARE number_blobs = i4 WITH protect, constant(size(request->notes[note_index].blobs,5))
   DELETE  FROM long_blob lb
    WHERE lb.parent_entity_id=storyid
     AND lb.parent_entity_name="SCD_STORY"
   ;end delete
   IF (number_blobs=0)
    SET failed = 1
    CALL cps_add_error(cps_insuf_data,cps_script_fail,"Autosave - No BLOBS specified",
     cps_insuf_data_msg,0,
     0,0)
    RETURN
   ENDIF
   INSERT  FROM long_blob b,
     (dummyt d  WITH seq = value(number_blobs))
    SET b.long_blob_id = cnvtreal(seq(long_data_seq,nextval)), b.parent_entity_name = "SCD_STORY", b
     .parent_entity_id = storyid,
     b.long_blob = request->notes[note_index].blobs[d.seq].chunk, b.updt_cnt = 0, b.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
     updt_applctx,
     b.active_ind = 1, b.active_status_cd = reqdata->active_status_cd, b.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     b.active_status_prsnl_id = reqinfo->updt_id
    PLAN (d)
     JOIN (b)
    WITH nocounter
   ;end insert
   IF (curqual != number_blobs)
    SET failed = 1
    CALL cps_add_error(cps_insert,cps_script_fail,"Autosave - INSERTING LONG BLOBS",cps_insert_msg,
     curqual,
     0,0)
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE insertstorypattern(patidsize,storyid)
   FOR (patidx = 1 TO patidsize)
     IF ((request->notes[note_index].scr_pattern_id[patidx].pattern_type_cd=0))
      SET request->notes[note_index].scr_pattern_id[patidx].pattern_type_cd = findcodevaluebymeaning(
       14409,nullterm(request->notes[note_index].scr_pattern_id[patidx].pattern_type_mean))
      IF (failed=1)
       CALL cps_add_error(cps_inval_data,cps_script_fail,"PATTERN TYPE",cps_inval_data_msg,note_index,
        patidx,0)
       RETURN
      ENDIF
     ENDIF
   ENDFOR
   INSERT  FROM scd_story_pattern sp,
     (dummyt d  WITH seq = value(patidsize))
    SET sp.scd_story_id = storyid, sp.scr_pattern_id = request->notes[note_index].scr_pattern_id[d
     .seq].patid, sp.scr_paragraph_type_id = request->notes[note_index].scr_pattern_id[d.seq].
     para_type_id,
     sp.pattern_type_cd = request->notes[note_index].scr_pattern_id[d.seq].pattern_type_cd
    PLAN (d)
     JOIN (sp)
    WITH nocounter
   ;end insert
   IF (curqual != patidsize)
    SET failed = 1
    CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING STORY_PATTERN RELTN",cps_insert_msg,
     note_index,
     curqual,0)
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE insertconcepts(index)
  DECLARE numberofconcepts = i4 WITH protect, noconstant(size(request->notes[index].concepts,5))
  IF (numberofconcepts != 0)
   INSERT  FROM scd_story_concept ssc,
     (dummyt d1  WITH seq = value(numberofconcepts))
    SET ssc.scd_story_concept_id = cnvtreal(seq(scd_seq,nextval)), ssc.scd_story_id = reply->notes[
     index].scd_story_id, ssc.concept_cki = request->notes[index].concepts[d1.seq].concept_cki,
     ssc.concept_display = request->notes[index].concepts[d1.seq].concept_display, ssc.updt_id =
     reqinfo->updt_id, ssc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     ssc.updt_task = reqinfo->updt_task, ssc.updt_applctx = reqinfo->updt_applctx, ssc.updt_cnt = 0,
     ssc.diagnosis_group_id = request->notes[index].concepts[d1.seq].diagnosis_group_id, ssc
     .concept_type_flag = request->notes[index].concepts[d1.seq].concept_type_flag
    PLAN (d1)
     JOIN (ssc)
    WITH nocounter
   ;end insert
   IF (curqual != numberofconcepts)
    SET failed = 1
    CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING CONCEPTS INTO SCD_STORY_CONCEPT",
     cps_insert_msg,index,
     curqual,numberofconcepts)
   ENDIF
  ENDIF
 END ;Subroutine
END GO
