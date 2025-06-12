CREATE PROGRAM cps_ens_scd_patrn_concept:dba
 RECORD reply(
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
 DECLARE dummy_void = i4
 SET failed = 0
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET number_rels = 0
 IF ((request->query_type="CON2PAT"))
  SET number_rels = size(request->concept.patterns,5)
 ELSEIF ((request->query_type="PAT2CON"))
  SET number_rels = size(request->pattern.concepts,5)
 ELSE
  SET failed = 1
  CALL cps_add_error(cps_insuf_data,cps_script_fail,"Unrecognized concept ensure query type",
   cps_insuf_data_msg,0,
   0,0)
  GO TO exit_script
 ENDIF
 IF (number_rels=0
  AND (request->action_type="REP"))
  SET failed = 1
  CALL cps_add_error(cps_insuf_data,cps_script_fail,"No Pattern-Concept relationships specified",
   cps_insuf_data_msg,0,
   0,0)
  GO TO exit_script
 ENDIF
 IF ((request->query_type="CON2PAT"))
  IF ((request->concept.concept_source_cd=0))
   SET failed = 1
   CALL cps_add_error(cps_insuf_data,cps_script_fail,"CON2PAT: Zero concept_source_cd",
    cps_insuf_data_msg,0,
    0,0)
   GO TO exit_script
  ENDIF
  FOR (x = 1 TO number_rels)
    IF ((request->concept.patterns[x].scr_pattern_id=0)
     AND (request->action_type="REP"))
     SET failed = 1
     CALL cps_add_error(cps_insuf_data,cps_script_fail,"CON2PAT: Zero scr_pattern_id",
      cps_insuf_data_msg,x,
      0,0)
     GO TO exit_script
    ENDIF
  ENDFOR
 ENDIF
 IF ((request->query_type="PAT2CON"))
  IF ((request->pattern.scr_pattern_id=0))
   SET failed = 1
   CALL cps_add_error(cps_insuf_data,cps_script_fail,"PAT2CON: Zero scr_pattern_id",
    cps_insuf_data_msg,0,
    0,0)
   GO TO exit_script
  ENDIF
  FOR (x = 1 TO number_rels)
    IF ((request->pattern.concepts[x].concept_source_cd=0)
     AND (request->action_type="REP"))
     SET failed = 1
     CALL cps_add_error(cps_insuf_data,cps_script_fail,"PAT2CON: Zero concept_source_cd",
      cps_insuf_data_msg,x,
      0,0)
     GO TO exit_script
    ENDIF
  ENDFOR
 ENDIF
 CASE (request->action_type)
  OF "REP":
   CALL deletepatcon(dummy_void)
   CALL addpatcon(dummy_void)
  OF "DEL":
   CALL deletepatcon(dummy_void)
  ELSE
   SET failed = 1
   CALL cps_add_error(cps_inval_data,cps_script_fail,"Unrecognized concept ensure action type",
    cps_inval_data_msg,0,
    0,0)
 ENDCASE
#exit_script
 IF (failed=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echo(build("error_cnt->",reply->cps_error.cnt))
 CALL echo(build("error_text->",reply->cps_error.data[1].code,reply->cps_error.data[1].supp_err_txt,
   reply->cps_error.data[1].def_msg))
 SUBROUTINE addpatcon(dummy_var)
   IF ((request->query_type="CON2PAT"))
    IF ((request->concept.concept_source_mean="")
     AND request->concept.concept_source_cd)
     SET request->concept.concept_source_mean = uar_get_code_meaning(request->concept.
      concept_source_cd)
    ENDIF
   ELSE
    SET number_means = size(request->pattern.concepts,5)
    FOR (curmean = 1 TO number_means)
      IF ((request->pattern.concepts[curmean].concept_source_mean="")
       AND request->pattern.concepts[curmean].concept_source_cd)
       SET request->pattern.concepts[curmean].concept_source_mean = uar_get_code_meaning(request->
        pattern.concepts[curmean].concept_source_cd)
      ENDIF
    ENDFOR
   ENDIF
   INSERT  FROM scr_pattern_concept spc,
     (dummyt d  WITH seq = value(number_rels))
    SET spc.scr_pattern_id =
     IF ((request->query_type="CON2PAT")) request->concept.patterns[d.seq].scr_pattern_id
     ELSE request->pattern.scr_pattern_id
     ENDIF
     , spc.concept_source_cd =
     IF ((request->query_type="CON2PAT")) request->concept.concept_source_cd
     ELSE request->pattern.concepts[d.seq].concept_source_cd
     ENDIF
     , spc.concept_identifier =
     IF ((request->query_type="CON2PAT")) request->concept.concept_identifier
     ELSE request->pattern.concepts[d.seq].concept_identifier
     ENDIF
     ,
     spc.concept_cki =
     IF ((request->query_type="CON2PAT")) concat(trim(request->concept.concept_source_mean,3),"!",
       trim(request->concept.concept_identifier,3))
     ELSE concat(trim(request->pattern.concepts[d.seq].concept_source_mean,3),"!",trim(request->
        pattern.concepts[d.seq].concept_identifier,3))
     ENDIF
     , spc.updt_id = reqinfo->updt_id, spc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     spc.updt_task = reqinfo->updt_task, spc.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (spc)
    WITH nocounter
   ;end insert
   IF (curqual != number_rels)
    SET failed = 1
    CALL cps_add_error(cps_insert,cps_script_fail,"INSERTING SCR_PATTERN_CONCEPT RELTN",
     cps_insert_msg,0,
     0,0)
    RETURN
   ENDIF
 END ;Subroutine
 SUBROUTINE deletepatcon(dummy_var)
   IF ((request->query_type="CON2PAT"))
    DELETE  FROM scr_pattern_concept spc
     WHERE (spc.concept_source_cd=request->concept.concept_source_cd)
      AND (spc.concept_identifier=request->concept.concept_identifier)
     WITH nocounter
    ;end delete
   ELSE
    DELETE  FROM scr_pattern_concept spc
     WHERE (spc.scr_pattern_id=request->pattern.scr_pattern_id)
     WITH nocounter
    ;end delete
   ENDIF
 END ;Subroutine
END GO
