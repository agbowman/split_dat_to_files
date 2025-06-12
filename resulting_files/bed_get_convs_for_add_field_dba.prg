CREATE PROGRAM bed_get_convs_for_add_field:dba
 FREE SET reply
 RECORD reply(
   1 fields[*]
     2 id = f8
     2 name = vc
     2 label = vc
     2 required_ind = i2
     2 display_only_ind = i2
     2 conv_id = f8
     2 conv_description = vc
     2 already_on_conv_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 fields[*]
     2 id = f8
     2 description = vc
     2 field = vc
     2 label = vc
     2 required_ind = i2
     2 display_only_ind = i2
     2 name = vc
     2 conv_id = f8
     2 conv_description = vc
     2 already_on_conv_ind = i2
     2 conv_action_data_source_id = f8
     2 conv_move_to_reply_ind = i2
 )
 RECORD add_fields(
   1 fields[*]
     2 parent_entity_id = f8
     2 data_source_id = f8
 )
 RECORD trees(
   1 parents[*]
     2 id = f8
 )
 RECORD loc_trees(
   1 parents[*]
     2 id = f8
     2 data_source_id = f8
     2 name = vc
 )
 DECLARE add_field_desc = vc
 DECLARE add_field_field = vc
 DECLARE work_name = vc
 DECLARE search_field = vc
 DECLARE beg_of_field = vc
 SET reply->status_data.status = "F"
 SET user_defined_field = 0
 SET user_defined_type = " "
 SET user_defined_field = findstring("USER_DEFINED",request->add_field)
 IF (user_defined_field > 0)
  SET found_ind = 0
  SET found_ind = findstring("PERSON.USER_DEFINED",request->add_field)
  IF (found_ind > 0)
   SET user_defined_type = "P"
  ELSE
   SET user_defined_type = "E"
  ENDIF
 ENDIF
 SET lcnt = 0
 SET alterlist_lcnt = 0
 SET stat = alterlist(loc_trees->parents,50)
 SELECT INTO "NL"
  FROM pm_flx_prompt pfp
  WHERE pfp.description="Location"
   AND pfp.field IN ("PERSON.ENCOUNTER.LOCATION_CD", "PERSON.ENCOUNTER.TRANSFER.LOCATION_CD")
   AND pfp.parent_entity_name="PM_FLX_DATA_SOURCE"
   AND pfp.active_ind=1
   AND pfp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND pfp.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   lcnt = (lcnt+ 1), alterlist_lcnt = (alterlist_lcnt+ 1)
   IF (alterlist_lcnt > 50)
    stat = alterlist(loc_trees->parents,(lcnt+ 50)), alterlist_lcnt = 1
   ENDIF
   loc_trees->parents[lcnt].id = pfp.parent_entity_id
  WITH nocounter
 ;end select
 SET stat = alterlist(loc_trees->parents,lcnt)
 FOR (l = 1 TO lcnt)
   SET work_name = "Location"
   SET next_parent_id = 0.0
   SET data_source_id = 0.0
   SELECT INTO "NL:"
    FROM pm_flx_data_source pfds
    WHERE (pfds.data_source_id=loc_trees->parents[l].id)
    DETAIL
     work_name = concat(trim(pfds.description),"/",work_name), next_parent_id = pfds.parent_entity_id,
     data_source_id = pfds.data_source_id
    WITH nocounter
   ;end select
   IF (next_parent_id=0.0)
    SET loc_trees->parents[l].name = work_name
    SET loc_trees->parents[l].data_source_id = data_source_id
   ELSE
    FOR (x = 1 TO 999)
     SELECT INTO "NL:"
      FROM pm_flx_data_source pfds
      WHERE pfds.data_source_id=next_parent_id
      DETAIL
       IF (pfds.parent_entity_id > 0.0)
        work_name = concat(trim(pfds.description),"/",work_name)
       ENDIF
       next_parent_id = pfds.parent_entity_id, data_source_id = pfds.data_source_id
      WITH nocounter
     ;end select
     IF (next_parent_id=0.0)
      SET x = 1000
      SET loc_trees->parents[l].name = work_name
      SET loc_trees->parents[l].data_source_id = data_source_id
     ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 SET fcnt = 0
 SET alterlist_fcnt = 0
 SET stat = alterlist(temp->fields,50)
 SELECT INTO "NL:"
  plabel = pfp.label
  FROM pm_flx_prompt pfp,
   pm_flx_conversation pfc,
   pm_flx_action pfa
  PLAN (pfp
   WHERE pfp.parent_entity_name="PM_FLX_CONVERSATION"
    AND pfp.parent_entity_id > 0
    AND pfp.active_ind=1
    AND pfp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pfp.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pfc
   WHERE pfc.conversation_id=pfp.parent_entity_id
    AND pfc.active_ind=1
    AND pfc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pfc.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pfa
   WHERE pfa.action=pfc.action)
  DETAIL
   IF (cnvtupper(cnvtalphanum(plabel))=cnvtupper(cnvtalphanum(request->find_field)))
    fcnt = (fcnt+ 1), alterlist_fcnt = (alterlist_fcnt+ 1)
    IF (alterlist_fcnt > 50)
     stat = alterlist(temp->fields,(fcnt+ 50)), alterlist_fcnt = 1
    ENDIF
    temp->fields[fcnt].id = pfp.prompt_id, temp->fields[fcnt].description = pfp.description, temp->
    fields[fcnt].field = pfp.field,
    temp->fields[fcnt].label = pfp.label, temp->fields[fcnt].required_ind = pfp.required_ind, temp->
    fields[fcnt].display_only_ind = pfp.display_only_ind,
    temp->fields[fcnt].conv_id = pfp.parent_entity_id, temp->fields[fcnt].conv_description = pfc
    .description, temp->fields[fcnt].conv_action_data_source_id = pfa.data_source_id
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(temp->fields,fcnt)
 SET acnt = 0
 SET alterlist_acnt = 0
 SET stat = alterlist(add_fields->fields,50)
 IF (user_defined_field=0)
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
    add_fields->fields[acnt].parent_entity_id = pfp.parent_entity_id
   WITH nocounter
  ;end select
 ELSE
  IF (user_defined_type="P")
   SET search_field = "PERSON.USER_DEFINED"
  ELSE
   SET search_field = "PERSON.ENCOUNTER.USER_DEFINED"
  ENDIF
  SELECT INTO "NL:"
   FROM pm_flx_data_source pfd
   WHERE pfd.field=search_field
   DETAIL
    acnt = (acnt+ 1), alterlist_acnt = (alterlist_acnt+ 1)
    IF (alterlist_acnt > 50)
     stat = alterlist(add_fields->fields,(acnt+ 50)), alterlist_acnt = 1
    ENDIF
    add_fields->fields[acnt].parent_entity_id = pfd.parent_entity_id
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(add_fields->fields,acnt)
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
 FOR (f = 1 TO fcnt)
  SET temp->fields[f].conv_move_to_reply_ind = 0
  FOR (a = 1 TO acnt)
    IF ((temp->fields[f].conv_action_data_source_id=add_fields->fields[a].data_source_id))
     SET temp->fields[f].conv_move_to_reply_ind = 1
     SET a = (acnt+ 1)
    ENDIF
  ENDFOR
 ENDFOR
 FOR (f = 1 TO fcnt)
   IF ((temp->fields[f].conv_move_to_reply_ind=1))
    SET temp->fields[f].already_on_conv_ind = 0
    SELECT INTO "NL:"
     FROM pm_flx_prompt pfp
     WHERE (pfp.parent_entity_id=temp->fields[f].conv_id)
      AND (pfp.field=request->add_field)
     DETAIL
      temp->fields[f].already_on_conv_ind = 1
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 FOR (f = 1 TO fcnt)
   IF ((temp->fields[f].conv_move_to_reply_ind=1))
    IF ((temp->fields[f].field=" "))
     SET temp->fields[f].name = temp->fields[f].description
    ELSE
     IF ((temp->fields[f].field="PERSON.QUESTIONNAIRE_01.QUESTIONS*"))
      SET beg_of_field = substring(1,43,temp->fields[f].field)
      SET temp->fields[f].field = concat(beg_of_field,"IND")
     ENDIF
     SET pcnt = 0
     SET alterlist_pcnt = 0
     SET stat = alterlist(trees->parents,50)
     SELECT INTO "NL"
      FROM pm_flx_prompt pfp
      WHERE (pfp.description=temp->fields[f].description)
       AND (pfp.field=temp->fields[f].field)
       AND pfp.parent_entity_name="PM_FLX_DATA_SOURCE"
       AND pfp.active_ind=1
       AND pfp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND pfp.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      DETAIL
       pcnt = (pcnt+ 1), alterlist_pcnt = (alterlist_pcnt+ 1)
       IF (alterlist_pcnt > 50)
        stat = alterlist(trees->parents,(pcnt+ 50)), alterlist_pcnt = 1
       ENDIF
       trees->parents[pcnt].id = pfp.parent_entity_id
      WITH nocounter
     ;end select
     SET stat = alterlist(trees->parents,pcnt)
     FOR (p = 1 TO pcnt)
       SET work_name = trim(request->find_field)
       SET next_parent_id = 0.0
       SET data_source_id = 0.0
       SELECT INTO "NL:"
        FROM pm_flx_data_source pfds
        WHERE (pfds.data_source_id=trees->parents[p].id)
        DETAIL
         work_name = concat(trim(pfds.description),"/",work_name), next_parent_id = pfds
         .parent_entity_id, data_source_id = pfds.data_source_id
        WITH nocounter
       ;end select
       IF (next_parent_id=0.0)
        IF ((data_source_id=temp->fields[f].conv_action_data_source_id))
         SET temp->fields[f].name = work_name
         SET p = (pcnt+ 1)
        ENDIF
       ELSE
        FOR (x = 1 TO 999)
         SELECT INTO "NL:"
          FROM pm_flx_data_source pfds
          WHERE pfds.data_source_id=next_parent_id
          DETAIL
           IF (pfds.parent_entity_id > 0.0)
            work_name = concat(trim(pfds.description),"/",work_name)
           ENDIF
           next_parent_id = pfds.parent_entity_id, data_source_id = pfds.data_source_id
          WITH nocounter
         ;end select
         IF (next_parent_id=0.0)
          SET x = 1000
          IF ((data_source_id=temp->fields[f].conv_action_data_source_id))
           SET temp->fields[f].name = work_name
           SET p = (pcnt+ 1)
          ENDIF
         ENDIF
        ENDFOR
       ENDIF
     ENDFOR
     IF ((temp->fields[f].name=" "))
      IF ((temp->fields[f].field IN ("PERSON.ENCOUNTER.LOC_BUILDING_CD",
      "PERSON.ENCOUNTER.LOC_NURSE_UNIT_CD", "PERSON.ENCOUNTER.LOC_ROOM_CD",
      "PERSON.ENCOUNTER.LOC_BED_CD", "PERSON.ENCOUNTER.TRANSFER.LOC_BUILDING_CD",
      "PERSON.ENCOUNTER.TRANSFER.LOC_NURSE_UNIT_CD", "PERSON.ENCOUNTER.TRANSFER.LOC_ROOM_CD",
      "PERSON.ENCOUNTER.TRANSFER.LOC_BED_CD")))
       FOR (l = 1 TO lcnt)
         IF ((loc_trees->parents[l].data_source_id=temp->fields[f].conv_action_data_source_id))
          SET temp->fields[f].name = concat(loc_trees->parents[l].name,"/",request->find_field)
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SET r = 0
 FOR (f = 1 TO fcnt)
   IF ((temp->fields[f].conv_move_to_reply_ind=1))
    SET r = (r+ 1)
    SET stat = alterlist(reply->fields,r)
    SET reply->fields[r].id = temp->fields[f].id
    IF ((temp->fields[f].name > " "))
     SET reply->fields[r].name = temp->fields[f].name
    ELSE
     SET reply->fields[r].name = temp->fields[f].field
    ENDIF
    SET reply->fields[r].label = temp->fields[f].label
    SET reply->fields[r].required_ind = temp->fields[f].required_ind
    SET reply->fields[r].display_only_ind = temp->fields[f].display_only_ind
    SET reply->fields[r].conv_id = temp->fields[f].conv_id
    SET reply->fields[r].conv_description = temp->fields[f].conv_description
    SET reply->fields[r].already_on_conv_ind = temp->fields[f].already_on_conv_ind
   ENDIF
 ENDFOR
 IF (r=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
