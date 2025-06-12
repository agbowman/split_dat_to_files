CREATE PROGRAM dm_ea_trigger_cleanup:dba
 PROMPT
  "Is Patient Keeper in use at this site (Y/N)?" = "Y"
  WITH pkanswer
 RECORD user_trigger(
   1 trigger[*]
     2 trigger_name = vc
     2 table_name = vc
     2 status = vc
     2 entity_activity_type_cd = f8
 )
 DECLARE trackingupdatecd = f8
 DECLARE trigger_count = i4
 DECLARE parser_string = vc
 IF (( $PKANSWER IN ("y", "Y", "n", "N")))
  DECLARE new_purge_flag = i2
  SET new_purge_flag = 0
  SELECT INTO "nl:"
   dpt.template_nbr
   FROM dm_purge_template dpt
   WHERE dpt.template_nbr=123
    AND dpt.feature_nbr=39453
   DETAIL
    new_purge_flag = 1
   WITH nocounter
  ;end select
  IF (new_purge_flag=1)
   UPDATE  FROM dm_purge_template dpt
    SET dpt.active_ind = 0
    WHERE dpt.template_nbr=123
     AND dpt.feature_nbr=22597
   ;end update
   COMMIT
  ENDIF
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=28620
    AND cv.cdf_meaning="TRACKINGUPDT"
   DETAIL
    trackingupdatecd = cv.code_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM user_triggers ut,
    dm_entity_activity_trigger deat
   PLAN (ut
    WHERE ut.trigger_name="TRG*_EA")
    JOIN (deat
    WHERE deat.table_name=outerjoin(ut.table_name))
   DETAIL
    trigger_count = (trigger_count+ 1), stat = alterlist(user_trigger->trigger,trigger_count),
    user_trigger->trigger[trigger_count].trigger_name = concat("v500.",ut.trigger_name),
    user_trigger->trigger[trigger_count].table_name = ut.table_name, user_trigger->trigger[
    trigger_count].status = ut.status, user_trigger->trigger[trigger_count].entity_activity_type_cd
     = nullval(deat.entity_activity_type_cd,0.0)
   WITH nocounter
  ;end select
 ENDIF
 CALL echo("")
 CALL echo("")
 CALL echo("")
 CALL echo("")
 CALL echo("")
 CALL echo("")
 CALL echo("")
 CALL echo("")
 CALL echo("")
 CALL echo("")
 CALL echo("")
 CALL echo("")
 CALL echo("")
 CALL echo("")
 CASE (cnvtupper( $PKANSWER))
  OF "Y":
   FOR (trigger_idx = 1 TO trigger_count)
     IF ((user_trigger->trigger[trigger_idx].entity_activity_type_cd IN (trackingupdatecd, 0))
      AND  NOT ((user_trigger->trigger[trigger_idx].table_name IN ("ENCNTR_ALIAS", "ENCNTR_INFO",
     "ENCNTR_PRSNL_RELTN", "ENCOUNTER", "PERSON",
     "PERSON_ALIAS", "PERSON_PRSNL_RELTN", "TRACKING_CHECKIN", "TRACKING_COMPLAINT", "TRACKING_EVENT",
     "TRACKING_ITEM", "TRACKING_LOCATOR", "TRACKING_PRV_RELN", "TRACKING_TAG", "STICKY_NOTE",
     "ALLERGY", "DIAGNOSIS"))))
      SET parser_string = concat("rdb alter trigger ",user_trigger->trigger[trigger_idx].trigger_name,
       " disable go")
      CALL echo(parser_string)
      CALL parser(parser_string)
     ENDIF
   ENDFOR
   DELETE  FROM dm_entity_activity_trigger deat
    WHERE deat.entity_activity_type_cd=trackingupdatecd
     AND  NOT (deat.table_name IN ("ENCNTR_ALIAS", "ENCNTR_INFO", "ENCNTR_PRSNL_RELTN", "ENCOUNTER",
    "PERSON",
    "PERSON_ALIAS", "PERSON_PRSNL_RELTN", "TRACKING_CHECKIN", "TRACKING_COMPLAINT", "TRACKING_EVENT",
    "TRACKING_ITEM", "TRACKING_LOCATOR", "TRACKING_PRV_RELN", "TRACKING_TAG", "STICKY_NOTE",
    "ALLERGY", "DIAGNOSIS"))
   ;end delete
   CALL echo("UNNECESARY DATABASE TRIGGERS WERE INACTIVATED")
   CALL echo("")
   CALL echo("THE PATIENT KEEPER DATABASE TRIGGERS WERE LEFT ALONE")
  OF "N":
   FOR (trigger_idx = 1 TO trigger_count)
     IF ( NOT ((user_trigger->trigger[trigger_idx].table_name IN ("ENCNTR_ALIAS", "ENCNTR_INFO",
     "ENCNTR_PRSNL_RELTN", "ENCOUNTER", "PERSON",
     "PERSON_ALIAS", "PERSON_PRSNL_RELTN", "TRACKING_CHECKIN", "TRACKING_COMPLAINT", "TRACKING_EVENT",
     "TRACKING_ITEM", "TRACKING_LOCATOR", "TRACKING_PRV_RELN", "TRACKING_TAG", "STICKY_NOTE",
     "ALLERGY", "DIAGNOSIS"))))
      SET parser_string = concat("rdb alter trigger ",user_trigger->trigger[trigger_idx].trigger_name,
       " disable go")
      CALL echo(parser_string)
      CALL parser(parser_string)
     ENDIF
   ENDFOR
   DELETE  FROM dm_entity_activity_trigger deat
    WHERE  NOT (deat.table_name IN ("ENCNTR_ALIAS", "ENCNTR_INFO", "ENCNTR_PRSNL_RELTN", "ENCOUNTER",
    "PERSON",
    "PERSON_ALIAS", "PERSON_PRSNL_RELTN", "TRACKING_CHECKIN", "TRACKING_COMPLAINT", "TRACKING_EVENT",
    "TRACKING_ITEM", "TRACKING_LOCATOR", "TRACKING_PRV_RELN", "TRACKING_TAG", "STICKY_NOTE",
    "ALLERGY", "DIAGNOSIS"))
   ;end delete
   CALL echo("UNNECESARY DATABASE TRIGGERS WERE INACTIVATED")
   CALL echo("")
   CALL echo("PATIENT KEEPER DATABASE TRIGGERS WERE REMOVED")
  ELSE
   CALL echo(build("THE VALUE ENTERED, ' ", $PKANSWER,"' IS INVALID."))
   CALL echo("")
   CALL echo(build("THE VALID VALUES ARE 'Y' AND 'N'"))
 ENDCASE
 CALL echo("")
 CALL echo("")
 CALL echo("")
 CALL echo("")
 CALL echo("")
 CALL echo("")
 CALL echo("")
 CALL echo("")
 COMMIT
END GO
