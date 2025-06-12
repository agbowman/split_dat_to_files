CREATE PROGRAM bed_get_conv_field_name:dba
 FREE SET reply
 RECORD reply(
   1 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 DECLARE work_name = vc
 SET reply->status_data.status = "F"
 SET reply->name = request->field
 IF ((request->field IN ("PERSON.ENCOUNTER.LOC_BUILDING_CD", "PERSON.ENCOUNTER.LOC_NURSE_UNIT_CD",
 "PERSON.ENCOUNTER.LOC_ROOM_CD", "PERSON.ENCOUNTER.LOC_BED_CD",
 "PERSON.ENCOUNTER.TRANSFER.LOC_BUILDING_CD",
 "PERSON.ENCOUNTER.TRANSFER.LOC_NURSE_UNIT_CD", "PERSON.ENCOUNTER.TRANSFER.LOC_ROOM_CD",
 "PERSON.ENCOUNTER.TRANSFER.LOC_BED_CD")))
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
      work_name = concat(trim(pfds.description),"/",work_name), next_parent_id = pfds
      .parent_entity_id, data_source_id = pfds.data_source_id
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
 ENDIF
 SET conv_action_data_source_id = 0.0
 SELECT INTO "NL:"
  FROM pm_flx_conversation pfc,
   pm_flx_action pfa
  PLAN (pfc
   WHERE (pfc.conversation_id=request->conversation_id)
    AND pfc.active_ind=1
    AND pfc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pfc.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pfa
   WHERE pfa.action=pfc.action)
  DETAIL
   conv_action_data_source_id = pfa.data_source_id
  WITH nocounter
 ;end select
 SET pcnt = 0
 SET alterlist_pcnt = 0
 SET stat = alterlist(trees->parents,50)
 SELECT INTO "NL"
  FROM pm_flx_prompt pfp
  WHERE (pfp.field=request->field)
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
   SET work_name = " "
   SET next_parent_id = 0.0
   SET data_source_id = 0.0
   SELECT INTO "NL:"
    FROM pm_flx_data_source pfds
    WHERE (pfds.data_source_id=trees->parents[p].id)
    DETAIL
     work_name = trim(pfds.description), next_parent_id = pfds.parent_entity_id, data_source_id =
     pfds.data_source_id
    WITH nocounter
   ;end select
   IF (next_parent_id=0.0)
    IF (data_source_id=conv_action_data_source_id)
     SET reply->name = work_name
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
      IF (data_source_id=conv_action_data_source_id)
       SET reply->name = work_name
       SET p = (pcnt+ 1)
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 IF ((reply->name=" "))
  IF ((request->field IN ("PERSON.ENCOUNTER.LOC_BUILDING_CD", "PERSON.ENCOUNTER.LOC_NURSE_UNIT_CD",
  "PERSON.ENCOUNTER.LOC_ROOM_CD", "PERSON.ENCOUNTER.LOC_BED_CD",
  "PERSON.ENCOUNTER.TRANSFER.LOC_BUILDING_CD",
  "PERSON.ENCOUNTER.TRANSFER.LOC_NURSE_UNIT_CD", "PERSON.ENCOUNTER.TRANSFER.LOC_ROOM_CD",
  "PERSON.ENCOUNTER.TRANSFER.LOC_BED_CD")))
   FOR (l = 1 TO lcnt)
     IF ((loc_trees->parents[l].data_source_id=conv_action_data_source_id))
      SET reply->name = loc_trees->parents[l].name
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
