CREATE PROGRAM dm_rdm_upd_taa_rem_gdpr:dba
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
 DECLARE drr_table_and_ccldef_exists(null) = i2
 IF (validate(drr_validate_table->table_name,"X")="X"
  AND validate(drr_validate_table->table_name,"Z")="Z")
  FREE RECORD drr_validate_table
  RECORD drr_validate_table(
    1 msg_returned = vc
    1 list[*]
      2 table_name = vc
      2 status = i2
  )
 ENDIF
 SUBROUTINE drr_table_and_ccldef_exists(null)
   DECLARE dtc_table_num = i4 WITH protect, noconstant(0)
   DECLARE dtc_table_cnt = i4 WITH protect, noconstant(0)
   DECLARE dtc_ccldef_cnt = i4 WITH protect, noconstant(0)
   DECLARE dtc_no_ccldef = vc WITH protect, noconstant("")
   DECLARE dtc_no_table = vc WITH protect, noconstant("")
   DECLARE dtc_errmsg = vc WITH protect, noconstant("")
   SET dtc_table_num = size(drr_validate_table->list,5)
   IF (dtc_table_num=0)
    SET drr_validate_table->msg_returned = concat(
     "No table specified in DRR_VALIDATE_TABLE record structure.")
    RETURN(- (1))
   ENDIF
   SELECT INTO "nl:"
    FROM user_tables ut,
     (dummyt d  WITH seq = value(dtc_table_num))
    PLAN (d
     WHERE d.seq > 0)
     JOIN (ut
     WHERE ut.table_name=trim(cnvtupper(drr_validate_table->list[d.seq].table_name)))
    DETAIL
     dtc_table_cnt += 1, drr_validate_table->list[d.seq].status = 1
    WITH nocounter
   ;end select
   IF (error(dtc_errmsg,0) != 0)
    SET drr_validate_table->msg_returned = concat("Select for table existence failed: ",dtc_errmsg)
    RETURN(- (1))
   ELSEIF (dtc_table_cnt=0)
    SET drr_validate_table->msg_returned = concat("No DRR tables found")
    RETURN(0)
   ENDIF
   IF (dtc_table_cnt < dtc_table_num)
    FOR (i = 1 TO dtc_table_num)
      IF ((drr_validate_table->list[i].status=0))
       SET dtc_no_table = concat(dtc_no_table," ",drr_validate_table->list[i].table_name)
      ENDIF
    ENDFOR
    SET drr_validate_table->msg_returned = concat("Missing table",dtc_no_table)
    RETURN(dtc_table_cnt)
   ENDIF
   FOR (i = 1 TO dtc_table_num)
     IF (checkdic(cnvtupper(drr_validate_table->list[i].table_name),"T",0) != 2)
      SET dtc_no_ccldef = concat(dtc_no_ccldef," ",drr_validate_table->list[i].table_name)
      SET drr_validate_table->list[i].status = 0
     ELSE
      SET dtc_ccldef_cnt += 1
     ENDIF
   ENDFOR
   IF (dtc_ccldef_cnt < dtc_table_num)
    SET drr_validate_table->msg_returned = concat("CCL definition missing for ",dtc_no_ccldef)
    RETURN(dtc_ccldef_cnt)
   ENDIF
   RETURN(dtc_table_cnt)
 END ;Subroutine
 SET readme_data->status = "F"
 SET readme_data->message = concat("FAILED STARTING README ",cnvtstring(readme_data->readme_id))
 DECLARE ms_errmsg = vc WITH protect, noconstant("")
 DECLARE nshadowtablecount = i4 WITH protect, noconstant(0)
 DECLARE notification_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE task_type_cd_reminder = f8 WITH protect, noconstant(0.0)
 DECLARE column_exists(stable,scolumn) = i4
 SET stat = alterlist(drr_validate_table->list,2)
 SET drr_validate_table->list[1].table_name = "task_activity0327drr"
 SET drr_validate_table->list[2].table_name = "task_activity_assi1371drr"
 SET nshadowtablecount = drr_table_and_ccldef_exists(null)
 IF (nshadowtablecount != 0
  AND nshadowtablecount != 2)
  SET readme_data->message = drr_validate_table->msg_returned
  GO TO exit_program
 ELSEIF (nshadowtablecount=0)
  SET readme_data->status = "S"
  SET readme_data->message = "Shadow table(s) not found"
  GO TO exit_program
 ENDIF
 IF (((column_exists("task_activity_assi1371drr","SHOWUP_DT_TM")=0) OR (column_exists(
  "task_activity_assi1371drr","NOTIFICATION_TYPE_CD")=0)) )
  SET readme_data->status = "F"
  SET readme_data->message =
  "Columns - Showup_dt_tm / Notification_type_cd not found in task_activity_assi1371drr schema"
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=3406
    AND cv.cdf_meaning="REMINDERS"
    AND cv.active_ind=1)
  DETAIL
   notification_type_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (((error(ms_errmsg,0) != 0) OR (notification_type_cd <= 0)) )
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error loading code value REMINDERS from codeset 3406: ",
   ms_errmsg)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6026
    AND cv.cdf_meaning="REMINDER"
    AND cv.active_ind=1)
  DETAIL
   task_type_cd_reminder = cv.code_value
  WITH nocounter
 ;end select
 IF (((error(ms_errmsg,0) != 0) OR (task_type_cd_reminder <= 0)) )
  SET readme_data->status = "F"
  SET readme_data->message = concat("Error loading code value REMINDER from codeset 6026: ",ms_errmsg
   )
  GO TO exit_program
 ENDIF
 UPDATE  FROM task_activity_assi1371drr taa
  SET taa.showup_dt_tm = taa.remind_dt_tm, taa.notification_type_cd = notification_type_cd, taa
   .updt_cnt = (taa.updt_cnt+ 1),
   taa.updt_dt_tm = cnvtdatetime(sysdate), taa.updt_id = reqinfo->updt_id, taa.updt_applctx = reqinfo
   ->updt_applctx,
   taa.updt_task = reqinfo->updt_task
  WHERE taa.task_id IN (
  (SELECT
   ta.task_id
   FROM task_activity0327drr ta,
    task_activity_assi1371drr taa
   WHERE ta.task_type_cd=task_type_cd_reminder
    AND taa.task_id=ta.task_id
    AND taa.showup_dt_tm=null
    AND ((taa.notification_type_cd=null) OR (taa.notification_type_cd <= 0)) ))
  WITH nocounter
 ;end update
 IF (error(ms_errmsg,0) != 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "Update to shadow table task_activity_assi1371drr was not successful:",ms_errmsg)
  GO TO exit_program
 ENDIF
 SUBROUTINE column_exists(stable,scolumn)
   DECLARE ce_flag = i4
   SET ce_flag = 0
   DECLARE ce_temp = vc WITH noconstant("")
   SET stable = cnvtupper(stable)
   SET scolumn = cnvtupper(scolumn)
   IF (((currev=8
    AND currevminor=2
    AND currevminor2 >= 4) OR (((currev=8
    AND currevminor > 2) OR (currev > 8)) )) )
    SET ce_temp = build('"',stable,".",scolumn,'"')
    SET stat = checkdic(parser(ce_temp),"A",0)
    IF (stat > 0)
     SET ce_flag = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     l.attr_name
     FROM dtableattr a,
      dtableattrl l
     WHERE a.table_name=stable
      AND l.attr_name=scolumn
      AND l.structtype="F"
      AND btest(l.stat,11)=0
     DETAIL
      ce_flag = 1
     WITH nocounter
    ;end select
    IF (error(ms_errmsg,0) != 0)
     SET readme_data->status = "F"
     SET readme_data->message = concat("Error finding column existence: ",ms_errmsg)
     GO TO exit_program
    ENDIF
   ENDIF
   RETURN(ce_flag)
 END ;Subroutine
 SET readme_data->status = "S"
 SET readme_data->message = "Readme completed successfully"
#exit_program
 IF ((readme_data->status != "S"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
