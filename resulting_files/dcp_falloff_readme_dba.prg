CREATE PROGRAM dcp_falloff_readme:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 DECLARE wv_id = f8 WITH noconstant(0.0)
 DECLARE tableexistsind = i2 WITH noconstant(0)
 DECLARE sequenceexistsind = i2 WITH noconstant(0)
 DECLARE max_id = f8 WITH noconstant(0.0)
 DECLARE max_range_id = f8 WITH noconstant(0.0)
 DECLARE min_range_id = f8 WITH noconstant(0.0)
 DECLARE range_inc = f8 WITH noconstant(250000.0)
 DECLARE min_temp_id = f8 WITH noconstant(0.0)
 DECLARE max_temp_id = f8 WITH noconstant(0.0)
 DECLARE max_temp_range_id = f8 WITH noconstant(0.0)
 DECLARE temp_range_inc = f8 WITH noconstant(1000.0)
 DECLARE error_msg = vc WITH noconstant("")
 SET readme_data->status = "F"
 SET readme_data->message = fillstring(132,"Failed starting dcp_falloff_readme")
 SELECT INTO "nl:"
  FROM user_tables ut
  WHERE ut.table_name="RDM_4988_TEMP_TBL"
  DETAIL
   tableexistsind = 1
  WITH nocounter
 ;end select
 IF (error(error_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to check for existence of temp table",error_msg)
  GO TO exit_readme
 ENDIF
 IF (tableexistsind=0)
  CALL parser("rdb create global temporary table RDM_4988_TEMP_TBL")
  CALL parser("(temp_id number, encntr_id number, person_id number")
  CALL parser(") on commit preserve rows go")
  IF (error(error_msg,1) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to create schema of temp table",error_msg)
   GO TO exit_readme
  ENDIF
  EXECUTE oragen3 value("RDM_4988_TEMP_TBL")
  IF (error(error_msg,1) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to create temp table in oragen3",error_msg)
   GO TO exit_readme
  ENDIF
  CALL parser("rdb create unique index XPKRDM_4988_TEMP_TBL on RDM_4988_TEMP_TBL(temp_id) go")
  IF (error(error_msg,1) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to create index on temp table",error_msg)
   GO TO exit_readme
  ENDIF
 ELSE
  CALL parser("rdb truncate table RDM_4988_TEMP_TBL go")
  IF (error(error_msg,1) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to delete rows on already existing temp table",error_msg
    )
   GO TO exit_readme
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM user_sequences
  WHERE sequence_name="RDM_4988_SEQ"
  DETAIL
   sequenceexistsind = 1
  WITH nocounter
 ;end select
 IF (error(error_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to check for existence of RDM_4988_SEQ sequence",
   error_msg)
  GO TO exit_readme
 ENDIF
 IF (sequenceexistsind=0)
  CALL parser("rdb create sequence RDM_4988_SEQ increment by 1 start with 1 go")
  IF (error(error_msg,1) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Failed to create sequence for temp table",error_msg)
   GO TO exit_readme
  ENDIF
 ENDIF
 CALL echo("Starting dcp_falloff_readme")
 INSERT  FROM rdm_4988_temp_tbl rtt
  (rtt.temp_id, rtt.encntr_id, rtt.person_id)(SELECT
   seq(rdm_4988_seq,nextval), temp.encntr_id, temp.person_id
   FROM (
    (
    (SELECT DISTINCT
     encntr_id, person_id
     FROM encntr_event_set_io))
    temp))
  WITH nocounter
 ;end insert
 IF (error(error_msg,1) != 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to populate temp table",error_msg)
  GO TO exit_readme
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  min_val = min(wvpi.working_view_personitem_id)
  FROM working_view_personitem wvpi
  WHERE wvpi.working_view_personitem_id > 0
  DETAIL
   min_range_id = min_val
  WITH nocounter
 ;end select
 IF (error(error_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to find minimum working_view_personitem_id on working_view_personitem table",error_msg)
  GO TO exit_readme
 ENDIF
 SELECT INTO "nl:"
  max_val = max(wvpi.working_view_personitem_id)
  FROM working_view_personitem wvpi
  DETAIL
   max_id = max_val
  WITH nocounter
 ;end select
 IF (error(error_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Failed to find maximum working_view_personitem_id on working_view_personitem table",error_msg)
  GO TO exit_readme
 ENDIF
 IF (min_range_id > 1)
  SET max_range_id = (min_range_id+ range_inc)
 ELSE
  SET max_range_id = range_inc
 ENDIF
 IF (checkprg("DM2_SET_CONTEXT") > 0)
  EXECUTE dm2_set_context "FIRE_CMB_TRG", "NO"
 ENDIF
 WHILE (min_range_id <= max_id)
   UPDATE  FROM working_view_personitem wvpi
    SET wvpi.last_action_dt_tm = wvpi.updt_dt_tm, wvpi.updt_id = reqinfo->updt_id, wvpi.updt_task =
     reqinfo->updt_task,
     wvpi.updt_applctx = reqinfo->updt_applctx, wvpi.updt_cnt = (wvpi.updt_cnt+ 1)
    WHERE wvpi.working_view_personitem_id BETWEEN min_range_id AND max_range_id
    WITH nocounter
   ;end update
   IF (error(error_msg,1) != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("working_view_personitem table could not be updated",error_msg)
    GO TO exit_readme
   ELSE
    COMMIT
   ENDIF
   SET min_range_id = (max_range_id+ 1)
   SET max_range_id = (max_range_id+ range_inc)
 ENDWHILE
 SELECT INTO "nl:"
  FROM working_view wv
  WHERE wv.display_name="**IO2GRESERVED**"
  DETAIL
   wv_id = wv.working_view_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   nextseqnum = seq(carenet_seq,nextval)
   FROM dual
   DETAIL
    wv_id = nextseqnum
   WITH nocounter
  ;end select
  IF (error(error_msg,1) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Unable to generate new sequence for working_view table",
    error_msg)
   GO TO exit_readme
  ENDIF
  INSERT  FROM working_view wv
   SET wv.working_view_id = wv_id, wv.current_working_view = 0, wv.display_name = "**IO2GRESERVED**",
    wv.position_cd = 0, wv.location_cd = 0, wv.version_num = 0,
    wv.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), wv.end_effective_dt_tm = cnvtdatetime(
     "31-Dec-2100"), wv.active_ind = 1,
    wv.active_status_cd = 188, wv.active_status_dt_tm = cnvtdatetime(curdate,curtime3), wv
    .active_status_prsnl_id = 0,
    wv.updt_applctx = reqinfo->updt_applctx, wv.updt_cnt = 0, wv.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    wv.updt_id = reqinfo->updt_id, wv.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (error(error_msg,1) != 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat("Unable to insert into working_view table",error_msg)
   GO TO exit_readme
  ELSE
   COMMIT
   CALL echo("Inserted row into working_view table")
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  min_val = min(rtt.temp_id)
  FROM rdm_4988_temp_tbl rtt
  DETAIL
   min_temp_id = min_val
  WITH nocounter
 ;end select
 IF (error(error_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Unable to find minimum temp_id from RDM_4988_TEMP_TBL table",
   error_msg)
  GO TO exit_readme
 ENDIF
 SELECT INTO "nl:"
  max_val = max(rtt.temp_id)
  FROM rdm_4988_temp_tbl rtt
  DETAIL
   max_temp_id = max_val
  WITH nocounter
 ;end select
 IF (error(error_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Unable to find minimum temp_id from RDM_4988_TEMP_TBL table",
   error_msg)
  GO TO exit_readme
 ENDIF
 SET max_temp_range_id = (min_range_id+ temp_range_inc)
 WHILE (min_temp_id <= max_temp_id)
   INSERT  FROM working_view_person wvp
    (wvp.working_view_person_id, wvp.working_view_id, wvp.person_id,
    wvp.encntr_id, wvp.updt_id, wvp.updt_dt_tm,
    wvp.updt_task, wvp.updt_applctx, wvp.updt_cnt)(SELECT
     seq(carenet_seq,nextval), wv_id, rtt.person_id,
     rtt.encntr_id, reqinfo->updt_id, cnvtdatetime(curdate,curtime3),
     reqinfo->updt_task, reqinfo->updt_applctx, 0
     FROM rdm_4988_temp_tbl rtt
     WHERE rtt.temp_id BETWEEN min_temp_id AND max_temp_range_id
      AND  NOT ( EXISTS (
     (SELECT
      wvp.encntr_id
      FROM working_view_person wvp
      WHERE wvp.encntr_id=rtt.encntr_id
       AND wvp.person_id=rtt.person_id
       AND wvp.working_view_id=wv_id))))
    WITH nocounter
   ;end insert
   IF (error(error_msg,1) != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Unable to insert into working_view_person table",error_msg)
    GO TO exit_readme
   ELSE
    COMMIT
   ENDIF
   INSERT  FROM working_view_person_sect wvps
    (wvps.working_view_person_sect_id, wvps.working_view_person_id, wvps.event_set_name,
    wvps.included_ind, wvps.section_type_flag, wvps.updt_id,
    wvps.updt_dt_tm, wvps.updt_task, wvps.updt_applctx,
    wvps.updt_cnt)(SELECT
     seq(carenet_seq,nextval), wvp.working_view_person_id, "**IO2GSECTIONRESERVED**",
     1, 0, reqinfo->updt_id,
     cnvtdatetime(curdate,curtime3), reqinfo->updt_task, reqinfo->updt_applctx,
     0
     FROM rdm_4988_temp_tbl rtt,
      working_view_person wvp
     WHERE rtt.temp_id BETWEEN min_temp_id AND max_temp_range_id
      AND wvp.person_id=rtt.person_id
      AND wvp.encntr_id=rtt.encntr_id
      AND wvp.working_view_id=wv_id
      AND  NOT ( EXISTS (
     (SELECT
      wvps.working_view_person_id
      FROM working_view_person wvp,
       working_view_person_sect wvps
      WHERE wvp.encntr_id=rtt.encntr_id
       AND wvp.person_id=rtt.person_id
       AND wvp.working_view_id=wv_id
       AND wvps.working_view_person_id=wvp.working_view_person_id))))
    WITH nocounter
   ;end insert
   IF (error(error_msg,1) != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Unable to insert into working_view_person_sect table",
     error_msg)
    GO TO exit_readme
   ELSE
    COMMIT
   ENDIF
   INSERT  FROM working_view_personitem wvpi
    (wvpi.working_view_personitem_id, wvpi.working_view_person_sect_id, wvpi.primitive_event_set_name,
    wvpi.parent_event_set_name, wvpi.included_ind, wvpi.last_action_dt_tm,
    wvpi.updt_id, wvpi.updt_dt_tm, wvpi.updt_task,
    wvpi.updt_applctx, wvpi.updt_cnt)(SELECT
     seq(carenet_seq,nextval), wvps.working_view_person_sect_id, ees.event_set_name,
     "**IO2GSECTIONRESERVED**", 1, cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id, cnvtdatetime(curdate,curtime3), reqinfo->updt_task,
     reqinfo->updt_applctx, 0
     FROM rdm_4988_temp_tbl rtt,
      working_view_person_sect wvps,
      encntr_event_set_io ees
     WHERE rtt.temp_id BETWEEN min_temp_id AND max_temp_range_id
      AND ees.encntr_id=rtt.encntr_id
      AND ees.person_id=rtt.person_id
      AND wvps.working_view_person_id IN (
     (SELECT
      wvp.working_view_person_id
      FROM working_view_person wvp
      WHERE wvp.person_id=rtt.person_id
       AND wvp.encntr_id=rtt.encntr_id
       AND wvp.working_view_id=wv_id))
      AND  NOT ( EXISTS (
     (SELECT
      wvpi.working_view_person_sect_id
      FROM working_view_personitem wvpi,
       working_view_person_sect wvps,
       working_view_person wvp
      WHERE wvp.encntr_id=rtt.encntr_id
       AND wvp.person_id=rtt.person_id
       AND wvp.working_view_id=wv_id
       AND wvps.working_view_person_id=wvp.working_view_person_id
       AND wvpi.working_view_person_sect_id=wvps.working_view_person_sect_id))))
    WITH nocounter
   ;end insert
   IF (error(error_msg,1) != 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Unable to insert into working_view_personitem table",error_msg
     )
    GO TO exit_readme
   ELSE
    COMMIT
    CALL echo(
     "Inserted rows into working_view_person, working_view_person_section, working_view_personitem tables"
     )
   ENDIF
   SET min_temp_id = (max_temp_range_id+ 1)
   SET max_temp_range_id = (max_temp_range_id+ temp_range_inc)
 ENDWHILE
 CALL parser("rdb truncate table RDM_4988_TEMP_TBL go")
 IF (error(error_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Unable to truncate RDM_4988_TEMP_TBL table",error_msg)
 ENDIF
 CALL parser("rdb drop index XPKRDM_4988_TEMP_TBL go")
 IF (error(error_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Unable to drop index of RDM_4988_TEMP_TBL table",error_msg)
 ENDIF
 CALL parser("drop table RDM_4988_TEMP_TBL go")
 IF (error(error_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Unable to drop ccl definition of temp table RDM_4988_TEMP_TBL",
   error_msg)
 ENDIF
 CALL parser("rdb drop table RDM_4988_TEMP_TBL go")
 IF (error(error_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Unable to drop oracle definition of temp table RDM_4988_TEMP_TBL",error_msg)
 ENDIF
 CALL parser("rdb drop sequence RDM_4988_SEQ go")
 IF (error(error_msg,1) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Unable to drop sequence RDM_4988_SEQ",error_msg)
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Successfully executed dcp_falloff_readme"
#exit_readme
 IF (checkprg("DM2_SET_CONTEXT") > 0)
  EXECUTE dm2_set_context "FIRE_CMB_TRG", "YES"
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
