CREATE PROGRAM bed_add_conversation_fields:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD add_fields(
   1 fields[*]
     2 prompt_id = f8
     2 parent_entity_id = f8
     2 data_source_id = f8
 )
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET user_defined_field = 0
 SET user_defined_type = " "
 SET user_defined_field = findstring("USER_DEFINED",request->add_field)
 IF (user_defined_field > 0)
  SET found_ind = 0
  SET found_ind = findstring("PERSON.USER_DEFINED",request->add_field)
  IF (found_ind=1)
   SET user_defined_type = "P"
   SET field_cdf_meaning = substring(21,12,request->add_field)
  ELSE
   SET user_defined_type = "E"
   SET field_cdf_meaning = substring(31,12,request->add_field)
  ENDIF
  SET field_code_value = 0.0
  SET field_description = fillstring(60," ")
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.code_set=356
    AND cv.cdf_meaning=field_cdf_meaning
   DETAIL
    field_code_value = cv.code_value, field_description = cv.description
   WITH nocounter
  ;end select
  CALL bederrorcheck("Faild cs356 get")
  SET field_code_set = fillstring(100," ")
  SET field_length = fillstring(100," ")
  SET field_type = fillstring(100," ")
  SELECT INTO "NL:"
   FROM code_value_extension cve
   WHERE cve.code_value=field_code_value
    AND cve.code_set=356
    AND cve.field_name IN ("CODE_SET", "LENGTH", "TYPE")
   DETAIL
    IF (cve.field_name="CODE_SET")
     field_code_set = cve.field_value
    ELSEIF (cve.field_name="LENGTH")
     field_length = cve.field_value
    ELSEIF (cve.field_name="TYPE")
     field_type = cve.field_value
    ENDIF
   WITH nocounter
  ;end select
  CALL bederrorcheck("Failed Extension Query")
  IF (field_type="STRING")
   SET field_type = "TEXT"
  ELSEIF (field_type="CODE")
   SET field_type = "CODED"
  ELSEIF (field_type="NUMERIC")
   SET field_type = "NUMBER"
  ENDIF
  SET active_status_cd = 0.0
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.code_set=48
    AND cv.cdf_meaning="ACTIVE"
    AND cv.active_ind=1
   DETAIL
    active_status_cd = cv.code_value
   WITH nocounter
  ;end select
  CALL bederrorcheck("Failed cs48 get")
 ENDIF
 IF (user_defined_field=0)
  SET acnt = 0
  SET alterlist_acnt = 0
  SET stat = alterlist(add_fields->fields,50)
  SELECT INTO "NL:"
   FROM pm_flx_prompt pfp
   WHERE (pfp.field=request->add_field)
    AND pfp.parent_entity_name="PM_FLX_DATA_SOURCE"
    AND pfp.parent_entity_id > 0
    AND pfp.active_ind=1
    AND pfp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pfp.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   DETAIL
    acnt = (acnt+ 1), alterlist_acnt = (alterlist_acnt+ 1)
    IF (alterlist_acnt > 50)
     stat = alterlist(add_fields->fields,(acnt+ 50)), alterlist_acnt = 1
    ENDIF
    add_fields->fields[acnt].prompt_id = pfp.prompt_id, add_fields->fields[acnt].parent_entity_id =
    pfp.parent_entity_id
   WITH nocounter
  ;end select
  CALL bederrorcheck("Failed Getting Fields")
  SET stat = alterlist(add_fields->fields,acnt)
 ENDIF
 IF (user_defined_field=0)
  FOR (a = 1 TO acnt)
    SET next_parent_id = 0.0
    SELECT INTO "NL:"
     FROM pm_flx_data_source pfds
     WHERE (pfds.data_source_id=add_fields->fields[a].parent_entity_id)
     DETAIL
      next_parent_id = pfds.parent_entity_id, add_fields->fields[a].data_source_id = pfds
      .data_source_id
     WITH nocounter
    ;end select
    CALL bederrorcheck("Failed source get")
    IF (next_parent_id > 0.0)
     FOR (x = 1 TO 999)
      SELECT INTO "NL:"
       FROM pm_flx_data_source pfds
       WHERE pfds.data_source_id=next_parent_id
       DETAIL
        next_parent_id = pfds.parent_entity_id, add_fields->fields[a].data_source_id = pfds
        .data_source_id
       WITH nocounter
      ;end select
      IF (next_parent_id=0.0)
       SET x = 1000
      ENDIF
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
 SET fcnt = 0
 SET fcnt = size(request->fields,5)
 FOR (f = 1 TO fcnt)
   SET find_field_seq_nbr = 0
   SET find_field_conv_id = 0.0
   SET find_field_data_source_id = 0.0
   SELECT INTO "NL:"
    FROM pm_flx_prompt pfp,
     pm_flx_conversation pfc,
     pm_flx_action pfa
    PLAN (pfp
     WHERE (pfp.prompt_id=request->fields[f].find_field_id))
     JOIN (pfc
     WHERE pfc.conversation_id=pfp.parent_entity_id)
     JOIN (pfa
     WHERE pfa.action=pfc.action)
    DETAIL
     find_field_seq_nbr = pfp.sequence, find_field_conv_id = pfp.parent_entity_id,
     find_field_data_source_id = pfa.data_source_id
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed Detailed get")
   UPDATE  FROM pm_flx_prompt pfp
    SET pfp.sequence = (pfp.sequence+ 1), pfp.updt_cnt = (pfp.updt_cnt+ 1), pfp.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     pfp.updt_id = reqinfo->updt_id, pfp.updt_task = reqinfo->updt_task, pfp.updt_applctx = reqinfo->
     updt_applctx
    WHERE pfp.parent_entity_name="PM_FLX_CONVERSATION"
     AND pfp.parent_entity_id=find_field_conv_id
     AND pfp.sequence > find_field_seq_nbr
    WITH nocounter
   ;end update
   CALL bederrorcheck("Failed Sequence Update")
   IF (user_defined_field=0)
    SET add_field_id = 0.0
    FOR (a = 1 TO acnt)
      IF ((find_field_data_source_id=add_fields->fields[a].data_source_id))
       SET add_field_id = add_fields->fields[a].prompt_id
       SET a = (acnt+ 1)
      ENDIF
    ENDFOR
    IF (add_field_id=0.0)
     SET error_flag = "Y"
     SET error_msg = "Unable to find add field"
     GO TO exit_script
    ENDIF
    INSERT  FROM pm_flx_prompt
     (prompt_id, parent_entity_name, parent_entity_id,
     codeset, description, display_only_ind,
     field, format, info_long_text_id,
     label, length, message,
     options, prompt_type, required_ind,
     rule_long_text_id, sequence, static_ind,
     style, tab, user_defined_ind,
     value_type, value_cd, value_dt_tm,
     value_ind, value_nbr, value_string,
     verify_ind, active_ind, active_status_cd,
     active_status_dt_tm, active_status_prsnl_id, beg_effective_dt_tm,
     end_effective_dt_tm, updt_applctx, updt_cnt,
     updt_dt_tm, updt_id, updt_task,
     sub_type_cd, parent_data_source_nbr, hl7_description,
     sub_type_meaning)(SELECT
      seq(pm_flx_prompt_id_seq,nextval), "PM_FLX_CONVERSATION", find_field_conv_id,
      pfp.codeset, pfp.description, request->fields[f].display_only_ind,
      pfp.field, pfp.format, pfp.info_long_text_id,
      request->fields[f].label, pfp.length, pfp.message,
      pfp.options, pfp.prompt_type, request->fields[f].required_ind,
      pfp.rule_long_text_id, (find_field_seq_nbr+ 1), pfp.static_ind,
      pfp.style, pfp.tab, pfp.user_defined_ind,
      pfp.value_type, pfp.value_cd, pfp.value_dt_tm,
      pfp.value_ind, pfp.value_nbr, pfp.value_string,
      pfp.verify_ind, pfp.active_ind, pfp.active_status_cd,
      cnvtdatetime(curdate,curtime), reqinfo->updt_id, cnvtdatetime(curdate,curtime),
      cnvtdatetime("31-DEC-2100 00:00:00.00"), reqinfo->updt_applctx, 0,
      cnvtdatetime(curdate,curtime), reqinfo->updt_id, reqinfo->updt_task,
      pfp.sub_type_cd, pfp.parent_data_source_nbr, pfp.hl7_description,
      pfp.sub_type_meaning
      FROM pm_flx_prompt pfp
      WHERE pfp.prompt_id=add_field_id)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Failed prompt insert")
   ELSE
    INSERT  FROM pm_flx_prompt
     SET prompt_id = seq(pm_flx_prompt_id_seq,nextval), parent_entity_name = "PM_FLX_CONVERSATION",
      parent_entity_id = find_field_conv_id,
      codeset = cnvtint(field_code_set), description = field_description, display_only_ind = request
      ->fields[f].display_only_ind,
      field = request->add_field, format = " ", info_long_text_id = 0,
      label = request->fields[f].label, length = cnvtint(field_length), message = " ",
      options = " ", prompt_type = field_type, required_ind = request->fields[f].required_ind,
      rule_long_text_id = 0, sequence = (find_field_seq_nbr+ 1), static_ind = 0,
      style = 0, tab = 0, user_defined_ind = 1,
      value_type = " ", value_cd = 0, value_dt_tm = null,
      value_ind = 0, value_nbr = 0, value_string = " ",
      verify_ind = 0, active_ind = 1, active_status_cd = active_status_cd,
      active_status_dt_tm = cnvtdatetime(curdate,curtime), active_status_prsnl_id = reqinfo->updt_id,
      beg_effective_dt_tm = cnvtdatetime(curdate,curtime),
      end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), updt_applctx = reqinfo->
      updt_applctx, updt_cnt = 0,
      updt_dt_tm = cnvtdatetime(curdate,curtime), updt_id = reqinfo->updt_id, updt_task = reqinfo->
      updt_task,
      sub_type_cd = field_code_value, parent_data_source_nbr = null, hl7_description = " ",
      sub_type_meaning = field_cdf_meaning
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Failed flex prompt insert")
   ENDIF
 ENDFOR
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
