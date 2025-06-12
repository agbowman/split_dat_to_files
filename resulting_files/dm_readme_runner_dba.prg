CREATE PROGRAM dm_readme_runner:dba
 IF ( NOT (validate(rm_defined,0)))
  SET rm_defined = 1
  SET rm_error = 0
  SET rm_warning = 1
  SET rm_info = 2
  SET rm_debug = 4
  SET rm_readme = "README"
  SET rm_dbimport = "DBIMPORT"
  SET rm_ccl = "CCL"
  SET rm_oracle = "ORACLE"
  SET rm_oracle_ref = "ORACLEREF"
  SET rm_ccl_dbimport = "CCLDBIMPORT"
  SET rm_tbl_import = "TABLEIMPORT"
  SET rm_running = "RUNNING"
  SET rm_done = "SUCCESS"
  SET rm_failed = "FAILED"
  SET rm_reset = "RESET"
  SET rm_pre_schema_up = "PREUP"
  SET rm_post_schema_up = "POSTUP"
  SET rm_pre_schema_down = "PREDOWN"
  SET rm_post_schema_down = "POSTDOWN"
  SET rm_uptime = "UP"
  SET rm_temp_id = 0.0
  SELECT INTO "nl:"
   i.info_number
   FROM dm_info i
   WHERE i.info_domain="DATA MANAGEMENT"
    AND i.info_name="DM_ENV_ID"
    AND i.info_number > 0.0
   DETAIL
    rm_temp_id = i.info_number
   WITH nocounter
  ;end select
  IF ( NOT (rm_temp_id))
   CALL rm_log(rm_error,"No environment ID found on the DM_INFO table for this environment.")
  ENDIF
  SET rm_env_id = rm_temp_id
  FREE SET rm_temp_id
 ENDIF
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
 IF ( NOT (validate(readme_error,0)))
  FREE SET readme_error
  RECORD readme_error(
    1 readme[*]
      2 readme_id = f8
      2 instance = i4
      2 description = vc
      2 message = vc
      2 ocd = i4
      2 options = vc
  )
 ENDIF
 SUBROUTINE rm_log(l_level,l_message)
   IF (size(trim(l_message,3)))
    CALL echo("********************************************************************************")
    CASE (l_level)
     OF rm_error:
      CALL echo(concat("ERROR: ",l_message))
     OF rm_warning:
      CALL echo(concat("WARNING: ",l_message))
     ELSE
      CALL echo(l_message)
    ENDCASE
    CALL echo("********************************************************************************")
    IF (l_level=rm_error)
     ROLLBACK
     GO TO 9999_exit_program
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE rm_row_count(rc_table)
   SET rc_count = 0
   SET rc_date = 0.0
   SET rc_so_exists = 0
   SELECT INTO "nl:"
    l.attr_name
    FROM dtableattr a,
     dtableattrl l
    WHERE a.table_name="SPACE_OBJECTS"
    DETAIL
     rc_so_exists = 1
    WITH nocounter
   ;end select
   IF (rc_so_exists=1)
    SELECT INTO "nl:"
     FROM dba_synonyms s
     WHERE s.synonym_name="SPACE_OBJECTS"
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET rc_so_exists = 0
    ENDIF
   ENDIF
   IF (rc_so_exists=1)
    SELECT INTO "nl:"
     o.row_count
     FROM ref_report_log l,
      ref_report_parms_log p,
      ref_instance_id i,
      space_objects o
     PLAN (l
      WHERE l.report_cd=1
       AND l.end_date IS NOT null)
      JOIN (p
      WHERE p.report_seq=l.report_seq
       AND p.parm_cd=1)
      JOIN (i
      WHERE i.environment_id=rm_env_id
       AND cnvtstring(i.instance_cd)=p.parm_value)
      JOIN (o
      WHERE o.segment_name=rc_table
       AND o.report_seq=l.report_seq)
     ORDER BY l.begin_date
     DETAIL
      rc_count = o.row_count, rc_date = cnvtdatetime(l.end_date)
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    FROM user_tables t
    WHERE t.table_name=rc_table
    DETAIL
     IF (cnvtdatetime(t.last_analyzed) > rc_date)
      rc_count = t.num_rows
     ENDIF
    WITH nocounter
   ;end select
   RETURN(rc_count)
 END ;Subroutine
 DECLARE rd_stat = c1
 DECLARE rd_msg = c130
 DECLARE rd_stat2 = c1
 DECLARE rd_msg2 = c130
 DECLARE dm_rrc_str = c150
 SET rr_debug = 0
 IF (validate(dm2_debug_flag,- (1)) > 0)
  SET rr_debug = 1
 ENDIF
 IF (rr_debug)
  CALL echo(
   "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
   )
  CALL trace(7)
  CALL echo(
   "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
   )
 ENDIF
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_run TO 2999_run_exit
 GO TO 9999_exit_program
 SUBROUTINE rr_file(f_file)
   SET f_flag = 0
   FREE SET f_install_file
   IF (cursys="AIX")
    SET f_install_file = build("cer_install/",f_file)
   ELSE
    SET f_install_file = build("cer_install:",f_file)
   ENDIF
   IF ( NOT (findfile(f_install_file)))
    CALL rr_status("F",concat("Data file not found in CER_INSTALL directory.  File: ",f_install_file,
      "."))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE rr_kick(k_message)
   FREE SET k_temp
   SET k_temp = k_message
   CALL rm_log(rm_info,concat(k_message,"  Number: ",trim(cnvtstring(readme_data->readme_id),3),
     ".  Description: ",readme_data->description,
     "."))
 END ;Subroutine
 SUBROUTINE rr_run(r_command)
   SET r_flag = 0
   SET r_len = size(r_command)
   CALL dcl(r_command,r_len,r_flag)
   RETURN(r_flag)
 END ;Subroutine
 SUBROUTINE rr_script_exists(se_script)
   SET se_flag = 0
   SELECT INTO "nl:"
    p.object_name
    FROM dprotect p
    WHERE p.object="P"
     AND p.object_name=cnvtupper(trim(se_script,3))
    DETAIL
     se_flag = 1
    WITH nocounter
   ;end select
   RETURN(se_flag)
 END ;Subroutine
 SUBROUTINE rr_compile(rrc_ran)
   SET rrc_flag = 0
   SET dm_seq_num = 0
   SET rrc_skip = 0
   FREE SET dm_uniq_file
   FREE SET dm_uniq_output
   FREE SET dm_readme_run_logical
   DECLARE dm_uniq_file = c30 WITH private, noconstant(" ")
   DECLARE dm_uniq_output = c40 WITH private, noconstant(" ")
   DECLARE dm_readme_run_logical = c30 WITH private, noconstant(" ")
   SELECT INTO "nl:"
    y = seq(dm_clinical_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     dm_seq_num = y
    WITH format, counter
   ;end select
   IF (dm_seq_num > 0)
    SET dm_uniq_file = build(cnvtint(readme_data->readme_id),"_",readme_data->instance,"_",dm_seq_num,
     "_file.txt")
    SET dm_uniq_output = build(cnvtint(readme_data->readme_id),"_",readme_data->instance,"_",
     dm_seq_num,
     "_output.txt")
   ELSE
    SET dm_uniq_file = build(cnvtint(readme_data->readme_id),"_",readme_data->instance,"_",rand(0),
     "_file.txt")
    SET dm_uniq_output = build(cnvtint(readme_data->readme_id),"_",readme_data->instance,"_",rand(0),
     "_output.txt")
   ENDIF
   SELECT INTO value(dm_uniq_file)
    FROM dual
    HEAD REPORT
     dm_rrc_str = fillstring(150," ")
    DETAIL
     IF (rrc_ran=0)
      dm_rrc_exec_str = trim(readme_data->script,3)
      CASE (readme_data->readme_type)
       OF rm_dbimport:
        dm_rrc_str = concat("execute dm_dbimport 'cer_install:",readme_data->data_file,"','",
         readme_data->script,"',",
         cnvtstring(readme_data->blocks)," go"),col 0,dm_rrc_str
       OF rm_oracle:
        dm_rrc_str = concat("execute dm_readme_oracle_import '",readme_data->data_file,"','",
         readme_data->par_file,"',0 go"),col 0,dm_rrc_str
       OF rm_oracle_ref:
        dm_rrc_str = concat("execute dm_readme_oracle_import '",readme_data->data_file,"','",
         readme_data->par_file,"',1 go"),col 0,dm_rrc_str
       OF rm_ccl_dbimport:
        dm_rrc_str = concat("execute dm_dbimport 'cer_install:",readme_data->data_file,"','",
         readme_data->script,"',",
         cnvtstring(readme_data->blocks)," go"),col 0,dm_rrc_str
       OF rm_tbl_import:
        IF (currdb="ORACLE")
         dm_rrc_str = concat("execute dm_readme_oracle_import2 '",readme_data->data_file,"','",
          readme_data->par_file,"','",
          readme_data->driver,"' go"), col 0, dm_rrc_str
        ELSEIF (currdb="DB2UDB")
         dm_rrc_str = concat("execute dm_readme_db2_import '",readme_data->data_file,"','",
          readme_data->driver,"',",
          cnvtstring(readme_data->blocks)," go"), col 0, dm_rrc_str
        ENDIF
       ELSE
        col 0,"execute ",col + 5,
        dm_rrc_exec_str,col + 1," go"
      ENDCASE
     ELSEIF (rrc_ran=1)
      dm_rrc_exec_str = trim(readme_data->check_script,3), col 0, "execute ",
      col + 5, dm_rrc_exec_str, col + 1,
      " go"
     ENDIF
    WITH nocounter, maxrow = 1, maxcol = 250
   ;end select
   IF (rrc_skip=1)
    SET rrc_flag = 0
   ELSE
    SET dm_rrc_str = concat("call compile('",dm_uniq_file,"' , '",dm_uniq_output,"') go")
    CALL parser(dm_rrc_str,1)
    SET dm_rrc_str = trim(dm_uniq_output,3)
    SET logical dm_readme_run_logical value(dm_rrc_str)
    FREE DEFINE rtl
    DEFINE rtl "dm_readme_run_logical"
    SELECT INTO noforms
     t.*
     FROM rtlt t
     WHERE t.line > " "
     DETAIL
      IF (findstring("%CCL-E",t.line,1,0))
       rrc_flag = 1
      ENDIF
      temp_line = substring(1,128,t.line), col 0, temp_line,
      row + 1
     WITH nocounter, maxrow = 1, maxcol = 130
    ;end select
   ENDIF
   IF (rrc_flag=0)
    IF ((readme_data->status="S"))
     SET stat = remove(value(dm_uniq_output))
    ENDIF
   ELSE
    IF (rrc_ran=0)
     SET rd_stat = "F"
     SET rd_msg = build("FAIL: ccl errors found when readme script was ran. Check log for details:",
      dm_uniq_output)
    ELSE
     SET rd_stat2 = "F"
     SET rd_msg2 = build(
      "FAIL: ccl errors found when readme check script was ran. Check log for details:",
      dm_uniq_output)
    ENDIF
   ENDIF
   SET stat = remove(value(dm_uniq_file))
   RETURN(rrc_flag)
 END ;Subroutine
 SUBROUTINE rr_status(s_status,s_message)
   CALL rr_kick(s_message)
   SET readme_data->status = cnvtupper(trim(s_status,3))
   SET readme_data->message = trim(s_message,3)
   EXECUTE dm_readme_status
   SET dm_readme_finished_ind = "F"
   COMMIT
 END ;Subroutine
#1000_initialize
 IF ( NOT (validate(dm_readme_finished_ind,0)))
  DECLARE dm_readme_finished_ind = c1
 ENDIF
 SET dm_readme_finished_ind = "F"
 SET dm_rr_inhouse = 0
 IF ((validate(dm2_debug_flag,- (1))=- (1))
  AND (validate(dm2_debug_flag,- (2))=- (2)))
  DECLARE dm_rr_debug_flag = i2
  SET dm_rr_debug_flag = 0
 ELSE
  DECLARE dm_rr_debug_flag = i2
  SET dm_rr_debug_flag = dm2_debug_flag
 ENDIF
 IF (validate(rr_batch_dt_tm,0))
  SET low_batch_dt_tm = rr_batch_dt_tm
  SET high_batch_dt_tm = rr_batch_dt_tm
 ELSE
  SET low_batch_dt_tm = cnvtdatetime("01-JAN-1800")
  SET high_batch_dt_tm = cnvtdatetime("31-DEC-2100")
 ENDIF
#1999_initialize_exit
#2000_run
 SET readme_data->ocd = 0
 SET readme_data->readme_id = 0
 SET readme_data->instance = 0
 SET readme_data->readme_type = ""
 SET readme_data->description = ""
 SET readme_data->script = ""
 SET readme_data->check_script = ""
 SET readme_data->data_file = ""
 SET readme_data->par_file = ""
 SET readme_data->blocks = 0
 SET readme_data->status = ""
 SET readme_data->message = ""
 SET readme_data->options = ""
 SET readme_data->driver = ""
 SET readme_data->batch_dt_tm = 0
 CALL rm_log(rm_info,"Searching for next readme to execute.")
 SELECT INTO "nl:"
  l.project_name
  FROM dm_ocd_log l
  PLAN (l
   WHERE l.environment_id=rm_env_id
    AND l.project_type=rm_readme
    AND l.batch_dt_tm BETWEEN cnvtdatetime(low_batch_dt_tm) AND cnvtdatetime(high_batch_dt_tm)
    AND l.start_dt_tm = null
    AND l.active_ind=1
    AND  EXISTS (
   (SELECT
    r.readme_id
    FROM dm_readme r
    WHERE r.readme_id=cnvtint(l.project_name)
     AND r.instance=l.project_instance
     AND r.active_ind=1
     AND  NOT ( EXISTS (
    (SELECT
     p.readme_id
     FROM dm_readme p,
      dm_ocd_log o
     WHERE p.readme_id=r.parent_readme_id
      AND p.active_ind=1
      AND o.environment_id=rm_env_id
      AND o.project_type=rm_readme
      AND o.project_name=cnvtstring(p.readme_id)
      AND ((o.status != rm_done) OR (o.status=null))
      AND o.active_ind=1))))))
  DETAIL
   readme_data->ocd = l.ocd, readme_data->readme_id = cnvtint(l.project_name), readme_data->instance
    = l.project_instance,
   readme_data->batch_dt_tm = l.batch_dt_tm
  WITH nocounter, maxqual(l,1)
 ;end select
 IF (curqual > 0)
  SELECT INTO "nl:"
   FROM dm_ocd_log l
   WHERE l.environment_id=rm_env_id
    AND l.project_type=rm_readme
    AND (l.ocd=readme_data->ocd)
    AND l.project_name=cnvtstring(readme_data->readme_id)
    AND (l.project_instance=readme_data->instance)
    AND l.start_dt_tm=null
   WITH nocounter, forupdatewait(l)
  ;end select
  IF (curqual > 0)
   UPDATE  FROM dm_ocd_log dol
    SET dol.start_dt_tm = cnvtdatetime(curdate,curtime3)
    WHERE dol.project_type="README"
     AND dol.project_name=cnvtstring(readme_data->readme_id)
     AND dol.environment_id=rm_env_id
     AND (dol.ocd=readme_data->ocd)
     AND dol.start_dt_tm = null
    WITH nocounter
   ;end update
   COMMIT
   CALL rr_status("","Starting from DM_README_RUNNER.")
  ELSE
   ROLLBACK
   GO TO 2000_run
  ENDIF
  SELECT INTO "NL:"
   r.readme_type
   FROM dm_readme r
   WHERE (r.readme_id=readme_data->readme_id)
    AND (r.instance=readme_data->instance)
   DETAIL
    readme_data->readme_type = cnvtupper(trim(r.readme_type,3)), readme_data->description = trim(r
     .description,3), readme_data->check_script = cnvtupper(trim(r.check_script,3)),
    readme_data->data_file = cnvtlower(trim(r.data_file,3)), readme_data->blocks = r.blocks,
    readme_data->driver = cnvtupper(trim(r.driver_table,3))
    IF ((((readme_data->readme_type=rm_oracle)) OR ((((readme_data->readme_type=rm_oracle_ref)) OR ((
    readme_data->readme_type=rm_tbl_import))) )) )
     readme_data->par_file = cnvtlower(trim(r.script,3))
    ELSE
     readme_data->script = cnvtupper(trim(r.script,3))
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (readme_data->readme_id)
  CALL rr_status("","Starting from DM_README_RUNNER.")
 ELSE
  CALL rm_log(rm_info,"No available readme remains to be executed.  Exiting program.")
  GO TO 9999_exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="INHOUSE DOMAIN"
  DETAIL
   dm_rr_inhouse = 1
  WITH nocounter
 ;end select
 CALL rr_kick("Validating readme.")
 IF (size(trim(readme_data->script,3)))
  IF ( NOT (rr_script_exists(readme_data->script)))
   CALL rr_status("F",concat("Main script not found in CCL dictionary.  Script name: ",readme_data->
     script,"."))
   GO TO 2900_continue
  ENDIF
 ENDIF
 IF (size(trim(readme_data->check_script,3)))
  IF ( NOT (rr_script_exists(readme_data->check_script)))
   CALL rr_status("F",concat("Check script not found in CCL dictionary.  Script name: ",readme_data->
     check_script,"."))
   GO TO 2900_continue
  ENDIF
 ENDIF
 IF (size(trim(readme_data->data_file,3)))
  IF ( NOT (rr_file(readme_data->data_file)))
   GO TO 2900_continue
  ENDIF
 ENDIF
 IF (size(trim(readme_data->par_file,3)))
  IF ( NOT (rr_file(readme_data->par_file)))
   GO TO 2900_continue
  ENDIF
 ENDIF
 CALL rr_kick("Performing readme.")
 IF (dm_rr_debug_flag=2)
  CALL echo(fillstring(110,"*"))
  CALL echo(build("Performing readme:  OCD(",trim(cnvtstring(readme_data->ocd),3),"), readme(",trim(
     cnvtstring(readme_data->readme_id),3),"), instance(",
    trim(cnvtstring(readme_data->instance),3),")"))
  CALL echo(fillstring(110,"*"))
 ELSE
  IF (dm_rr_debug_flag > 2)
   CALL echo(fillstring(110,"*"))
   CALL echorecord(readme_data)
   CALL echo(fillstring(110,"*"))
  ENDIF
 ENDIF
 IF (dm_rr_debug_flag > 1)
  CALL echo(fillstring(110,"*"))
  CALL echo("* CCL current resource usage statistics ")
  CALL echo(fillstring(20,"*"))
  CALL trace(7)
  CALL echo(fillstring(110,"*"))
 ENDIF
 IF (dm_rr_inhouse=1)
  FREE SET rd_stat
  FREE SET rd_msg
  DECLARE rd_stat = c1
  DECLARE rd_msg = c130
  CALL rm_log(rm_info,concat("Executing ",readme_data->script," readme script..."))
  IF (rr_compile(0))
   IF (rd_stat="F")
    CALL rm_log(rm_info,readme_data->message)
    SET readme_data->status = "F"
    SET readme_data->message = rd_msg
    GO TO 2900_continue
   ENDIF
  ENDIF
 ELSE
  CASE (readme_data->readme_type)
   OF rm_dbimport:
    EXECUTE dm_dbimport concat("cer_install:",trim(readme_data->data_file,3)), readme_data->script,
    readme_data->blocks
   OF rm_oracle:
    EXECUTE dm_readme_oracle_import readme_data->data_file, readme_data->par_file, 0
   OF rm_oracle_ref:
    EXECUTE dm_readme_oracle_import readme_data->data_file, readme_data->par_file, 1
   OF rm_ccl_dbimport:
    EXECUTE dm_dbimport concat("cer_install:",trim(readme_data->data_file,3)), readme_data->script,
    readme_data->blocks
   OF rm_tbl_import:
    IF (currdb="ORACLE")
     EXECUTE dm_readme_oracle_import2 readme_data->data_file, readme_data->par_file, readme_data->
     driver
    ELSEIF (currdb="DB2UDB")
     EXECUTE dm_readme_db2_import readme_data->data_file, readme_data->driver, readme_data->blocks
    ENDIF
    IF ((readme_data->status="F"))
     GO TO 2900_continue
    ENDIF
   ELSE
    EXECUTE value(readme_data->script)
    SET trace = norecpersist
  ENDCASE
 ENDIF
 CALL rr_kick("Completed readme.")
 IF ( NOT (size(trim(readme_data->check_script,3))))
  GO TO 2900_continue
 ENDIF
 CALL rr_kick("Starting check script.")
 IF (dm_rr_inhouse=1)
  FREE SET rd_stat2
  FREE SET rd_msg2
  DECLARE rd_stat2 = c1
  DECLARE rd_msg2 = c130
  IF (rr_compile(1))
   IF (rd_stat2="F")
    CALL rm_log(rm_info,readme_data->message)
    SET readme_data->status = "F"
    SET readme_data->message = rd_msg2
    GO TO 2900_continue
   ENDIF
  ENDIF
 ELSE
  EXECUTE value(readme_data->check_script)
  SET trace = norecpersist
 ENDIF
 CALL rr_kick("Completed check script.")
#2900_continue
 IF (rr_debug)
  CALL echo(
   "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
   )
  CALL trace(7)
  CALL echo(
   "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
   )
 ENDIF
 IF ((readme_data->status != "S")
  AND (readme_data->status != "F"))
  CALL rr_status("F","Automatically failed because no overall status was logged.")
 ENDIF
 IF ((readme_data->status="F"))
  SET rr_i = (size(readme_error->readme,5)+ 1)
  SET rr_stat = alterlist(readme_error->readme,rr_i)
  SET readme_error->readme[rr_i].readme_id = readme_data->readme_id
  SET readme_error->readme[rr_i].instance = readme_data->instance
  SET readme_error->readme[rr_i].description = readme_data->description
  SET readme_error->readme[rr_i].message = readme_data->message
  SET readme_error->readme[rr_i].ocd = readme_data->ocd
 ENDIF
 SET dm_readme_finished_ind = "T"
 CALL rr_status(readme_data->status,readme_data->message)
 GO TO 2000_run
#2999_run_exit
#9999_exit_program
END GO
