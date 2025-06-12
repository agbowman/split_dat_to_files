CREATE PROGRAM dm_script_analysis:dba
 IF (validate(dm_err->ecode,- (1)) < 0
  AND validate(dm_err->ecode,722)=722)
  FREE RECORD dm_err
  IF (currev >= 8)
   RECORD dm_err(
     1 logfile = vc
     1 debug_flag = i2
     1 ecode = i4
     1 emsg = vc
     1 eproc = vc
     1 err_ind = i2
     1 user_action = vc
     1 asterisk_line = c80
     1 tempstr = vc
     1 errfile = vc
     1 errtext = vc
     1 unique_fname = vc
     1 disp_msg_emsg = vc
     1 disp_dcl_err_ind = i2
   )
  ELSE
   RECORD dm_err(
     1 logfile = vc
     1 debug_flag = i2
     1 ecode = i4
     1 emsg = c132
     1 eproc = vc
     1 err_ind = i2
     1 user_action = vc
     1 asterisk_line = c80
     1 tempstr = vc
     1 errfile = vc
     1 errtext = vc
     1 unique_fname = vc
     1 disp_msg_emsg = vc
     1 disp_dcl_err_ind = i2
   )
  ENDIF
  SET dm_err->asterisk_line = fillstring(80,"*")
  SET dm_err->ecode = 0
  IF (validate(dm2_debug_flag,- (1)) > 0)
   SET dm_err->debug_flag = dm2_debug_flag
  ELSE
   SET dm_err->debug_flag = 0
  ENDIF
  SET dm_err->err_ind = 0
  SET dm_err->user_action = "NONE"
  SET dm_err->tempstr = " "
  SET dm_err->errfile = "NONE"
  SET dm_err->logfile = "NONE"
  SET dm_err->unique_fname = "NONE"
  SET dm_err->disp_dcl_err_ind = 1
 ENDIF
 IF (validate(dm2_install_schema->process_option," ")=" "
  AND validate(dm2_install_schema->process_option,"NOTTHERE")="NOTTHERE")
  FREE RECORD dm2_install_schema
  RECORD dm2_install_schema(
    1 process_option = vc
    1 file_prefix = vc
    1 schema_loc = vc
    1 schema_prefix = vc
    1 target_dbase_name = vc
    1 dbase_name = vc
    1 u_name = vc
    1 p_word = vc
    1 connect_str = vc
    1 v500_p_word = vc
    1 v500_connect_str = vc
    1 cdba_p_word = vc
    1 cdba_connect_str = vc
    1 run_id = i4
    1 menu_driver = vc
    1 oragen3_ignore_dm_columns_doc = i2
    1 last_checkpoint = vc
    1 gen_id = i4
    1 restart_method = i2
    1 appl_id = vc
    1 hostname = vc
    1 ccluserdir = vc
    1 cer_install = vc
    1 servername = vc
    1 frmt_servername = vc
    1 default_fg_name = vc
    1 curprog = vc
    1 adl_username = vc
    1 tgt_sch_cleanup = i2
    1 special_ih_process = i2
    1 dbase_type = vc
    1 data_to_move = c30
    1 percent_tspace = i4
    1 src_dbase_name = vc
    1 src_v500_p_word = vc
    1 src_v500_connect_str = vc
    1 logfile_prefix = vc
    1 src_run_id = f8
    1 src_op_id = f8
    1 target_env_name = vc
    1 dm2_updt_task_value = i2
  )
  SET dm2_install_schema->process_option = "NONE"
  SET dm2_install_schema->file_prefix = "NONE"
  SET dm2_install_schema->schema_loc = "NONE"
  SET dm2_install_schema->schema_prefix = "NONE"
  SET dm2_install_schema->target_dbase_name = "NONE"
  SET dm2_install_schema->dbase_name = "NONE"
  SET dm2_install_schema->u_name = "NONE"
  SET dm2_install_schema->p_word = "NONE"
  SET dm2_install_schema->connect_str = "NONE"
  SET dm2_install_schema->v500_p_word = "NONE"
  SET dm2_install_schema->v500_connect_str = "NONE"
  SET dm2_install_schema->cdba_p_word = "NONE"
  SET dm2_install_schema->cdba_connect_str = "NONE"
  SET dm2_install_schema->run_id = 0
  SET dm2_install_schema->menu_driver = "NONE"
  SET dm2_install_schema->oragen3_ignore_dm_columns_doc = 0
  SET dm2_install_schema->last_checkpoint = "NONE"
  SET dm2_install_schema->gen_id = 0
  SET dm2_install_schema->restart_method = 0
  SET dm2_install_schema->appl_id = "NONE"
  SET dm2_install_schema->hostname = "NONE"
  SET dm2_install_schema->servername = "NONE"
  SET dm2_install_schema->default_fg_name = "NONE"
  SET dm2_install_schema->curprog = "NONE"
  SET dm2_install_schema->adl_username = "NONE"
  SET dm2_install_schema->tgt_sch_cleanup = 0
  SET dm2_install_schema->special_ih_process = 0
  SET dm2_install_schema->dbase_type = "NONE"
  SET dm2_install_schema->data_to_move = "NONE"
  SET dm2_install_schema->percent_tspace = 0
  SET dm2_install_schema->src_dbase_name = "NONE"
  SET dm2_install_schema->src_v500_p_word = "NONE"
  SET dm2_install_schema->src_v500_connect_str = "NONE"
  SET dm2_install_schema->logfile_prefix = "NONE"
  SET dm2_install_schema->src_run_id = 0
  SET dm2_install_schema->src_op_id = 0
  SET dm2_install_schema->target_env_name = "NONE"
  SET dm2_install_schema->dm2_updt_task_value = 15301
  IF (cursys="AIX")
   SET dm2_install_schema->ccluserdir = build(logical("ccluserdir"),"/")
   SET dm2_install_schema->cer_install = build(logical("cer_install"),"/")
  ELSEIF (cursys="WIN")
   SET dm2_install_schema->ccluserdir = build(logical("ccluserdir"),"\")
   SET dm2_install_schema->cer_install = build(logical("cer_install"),"\")
  ELSE
   SET dm2_install_schema->ccluserdir = logical("ccluserdir")
   SET dm2_install_schema->cer_install = logical("cer_install")
  ENDIF
 ENDIF
 IF (validate(dm2_rdbms_version->level1,- (1)) < 0)
  FREE RECORD dm2_rdbms_version
  RECORD dm2_rdbms_version(
    1 version = vc
    1 level1 = i2
    1 level2 = i2
    1 level3 = i2
    1 level4 = i2
    1 level5 = i2
  )
  CASE (currdb)
   OF "ORACLE":
    SET dm2_rdbms_version->level1 = 0
    SET dm2_rdbms_version->level2 = 0
    SET dm2_rdbms_version->level3 = 0
    SET dm2_rdbms_version->level4 = 0
    SET dm2_rdbms_version->level5 = 0
   OF "DB2":
    SET dm2_rdbms_version->level1 = 8
    SET dm2_rdbms_version->level2 = 1
    SET dm2_rdbms_version->level3 = 2
    SET dm2_rdbms_version->level4 = 0
    SET dm2_rdbms_version->level5 = 0
   OF "SQLSRV":
    SET dm2_rdbms_version->level1 = 2000
    SET dm2_rdbms_version->level2 = 8
    SET dm2_rdbms_version->level3 = 0
    SET dm2_rdbms_version->level4 = 194
    SET dm2_rdbms_version->level5 = 0
  ENDCASE
 ENDIF
 DECLARE dm2_push_cmd(sbr_dpcstr=vc,sbr_cmd_end=i2) = i2
 DECLARE dm2_push_dcl(sbr_dpdstr=vc) = i2
 DECLARE get_unique_file(sbr_fprefix=vc,sbr_fext=vc) = i2
 DECLARE parse_errfile(sbr_errfile=vc) = i2
 DECLARE check_error(sbr_ceprocess=vc) = i2
 DECLARE disp_msg(sbr_demsg=vc,sbr_dlogfile=vc,sbr_derr_ind=i2) = null
 DECLARE init_logfile(sbr_logfile=vc,sbr_header_msg=vc) = i2
 DECLARE check_logfile(sbr_lprefix=vc,sbr_lext=vc,sbr_hmsg=vc) = i2
 DECLARE final_disp_msg(sbr_log_prefix=vc) = null
 DECLARE dm2_prg_maint(sbr_maint_type=vc) = i2
 DECLARE dm2_set_autocommit(sbr_dsa_flag=i2) = i2
 DECLARE dm2_get_rdbms_version() = i2
 SUBROUTINE dm2_push_cmd(sbr_dpcstr,sbr_cmd_end)
   IF ((dm_err->debug_flag > 0))
    CALL echo("*")
    CALL echo(concat("dm2_push_cmd executing: ",sbr_dpcstr))
    CALL echo("*")
   ENDIF
   CALL parser(sbr_dpcstr,1)
   SET dm_err->tempstr = concat(dm_err->tempstr," ",sbr_dpcstr)
   IF (sbr_cmd_end=1)
    IF ((dm_err->err_ind=0))
     IF (check_error(concat("dm2_push_cmd executing: ",dm_err->tempstr))=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->tempstr = " "
      RETURN(0)
     ENDIF
    ENDIF
    SET dm_err->tempstr = " "
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_push_dcl(sbr_dpdstr)
   DECLARE ml_dpd_stat = i4 WITH protect, noconstant(0)
   DECLARE ms_newstr = vc WITH protect
   DECLARE ml_strloc = i4 WITH protect, noconstant(0)
   DECLARE ms_temp_file = vc WITH protect, noconstant(" ")
   DECLARE ms_str2 = vc WITH protect, noconstant(" ")
   DECLARE ml_posx = i4 WITH protect, noconstant(0)
   DECLARE mn_sql_warn_ind = i2 WITH protect, noconstant(0)
   DECLARE mn_dpd_disp_dcl_err_ind = i2 WITH protect, noconstant(1)
   IF ((validate(dm_err->disp_dcl_err_ind,- (1))=- (1))
    AND (validate(dm_err->disp_dcl_err_ind,- (2))=- (2)))
    SET mn_dpd_disp_dcl_err_ind = 1
   ELSE
    SET mn_dpd_disp_dcl_err_ind = dm_err->disp_dcl_err_ind
    SET dm_err->disp_dcl_err_ind = 1
   ENDIF
   IF ((dm_err->errfile="NONE"))
    IF (get_unique_file("dm2_",".err")=0)
     RETURN(0)
    ELSE
     SET dm_err->errfile = dm_err->unique_fname
    ENDIF
   ENDIF
   IF (cursys IN ("AIX", "WIN"))
    SET ml_strloc = findstring(">",sbr_dpdstr,1,0)
    IF (ml_strloc > 0)
     SET strlength = size(trim(sbr_dpdstr))
     IF (findstring("2>&1",sbr_dpdstr) > 0)
      SET ms_temp_file = build(substring((ml_strloc+ 1),((strlength - ml_strloc) - 4),sbr_dpdstr))
     ELSE
      SET ms_temp_file = build(substring((ml_strloc+ 1),(strlength - ml_strloc),sbr_dpdstr))
     ENDIF
     SET ms_newstr = sbr_dpdstr
    ELSE
     SET ms_newstr = concat(sbr_dpdstr," > ",dm2_install_schema->ccluserdir,dm_err->errfile," 2>&1")
    ENDIF
   ELSE
    SET ml_strloc = findstring(">",sbr_dpdstr,1,0)
    IF (ml_strloc > 0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Cannot support additional piping outside of push dcl subroutine"
     SET dm_err->eproc = "Check push dcl command for piping character (>)."
     RETURN(0)
    ENDIF
    SET ms_newstr = concat("pipe ",sbr_dpdstr," > ccluserdir:",dm_err->errfile)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo("*")
    CALL echo(concat("dm2_push_dcl executing: ",ms_newstr))
    CALL echo("*")
   ENDIF
   CALL dcl(ms_newstr,size(ms_newstr),ml_dpd_stat)
   IF (ml_dpd_stat=0)
    IF (ms_temp_file > " ")
     CASE (cursys)
      OF "AIX":
       SET ms_str2 = concat("cp ",ms_temp_file," ",dm_err->errfile)
      OF "WIN":
       SET ms_str2 = concat("copy ",ms_temp_file," ",dm_err->errfile)
     ENDCASE
     CALL dcl(ms_str2,size(ms_str2),ml_dpd_stat)
    ENDIF
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF (currdb="DB2UDB")
     SET ml_posx = 1
     SET mn_sql_warn_ind = false
     WHILE (ml_posx < size(dm_err->errtext))
      SET ml_posx = findstring("SQL",dm_err->errtext,ml_posx)
      IF (ml_posx > 0)
       SET ml_posx = (ml_posx+ 7)
       IF (isnumeric(substring(ml_posx,1,dm_err->errtext)) > 0)
        SET ml_posx = (ml_posx+ 1)
        IF (isnumeric(substring(ml_posx,1,dm_err->errtext))=0)
         CASE (substring(ml_posx,1,dm_err->errtext))
          OF "W":
           SET mn_sql_warn_ind = true
           IF ((dm_err->debug_flag > 0))
            CALL echo("5 digit warning encountered")
           ENDIF
          OF "E":
           SET mn_sql_warn_ind = false
           SET ml_posx = size(dm_err->errtext)
           IF ((dm_err->debug_flag > 0))
            CALL echo("5 digit E error encountered")
           ENDIF
          OF "N":
           SET mn_sql_warn_ind = false
           SET ml_posx = size(dm_err->errtext)
           IF ((dm_err->debug_flag > 0))
            CALL echo("5 digit N error encountered")
           ENDIF
          ELSE
           IF ((dm_err->debug_flag > 0))
            CALL echo("Not W, E, N")
           ENDIF
         ENDCASE
        ENDIF
       ELSE
        CASE (substring(ml_posx,1,dm_err->errtext))
         OF "W":
          SET mn_sql_warn_ind = true
          IF ((dm_err->debug_flag > 0))
           CALL echo("4 digit warning encountered")
          ENDIF
         OF "E":
          SET mn_sql_warn_ind = false
          SET ml_posx = size(dm_err->errtext)
          IF ((dm_err->debug_flag > 0))
           CALL echo("4 digit E error encountered")
          ENDIF
         OF "N":
          SET mn_sql_warn_ind = false
          SET ml_posx = size(dm_err->errtext)
          IF ((dm_err->debug_flag > 0))
           CALL echo("4 digit N error encountered")
          ENDIF
         ELSE
          IF ((dm_err->debug_flag > 0))
           CALL echo("Not W, E, N")
          ENDIF
        ENDCASE
       ENDIF
      ELSE
       SET ml_posx = size(dm_err->errtext)
      ENDIF
     ENDWHILE
    ENDIF
    IF (mn_sql_warn_ind=true)
     SET dm_err->user_action = "NONE"
     SET dm_err->eproc = concat("Warning Encountered:",dm_err->errtext)
     CALL disp_msg("",dm_err->logfile,0)
    ELSE
     SET dm_err->disp_msg_emsg = dm_err->errtext
     SET dm_err->emsg = dm_err->disp_msg_emsg
     IF (mn_dpd_disp_dcl_err_ind=1)
      SET dm_err->eproc = concat("dm2_push_dcl executing: ",ms_newstr)
      SET dm_err->err_ind = 1
      CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
     ELSE
      IF ((dm_err->debug_flag > 1))
       CALL echo("Call dcl failed- error handling done by calling script")
      ENDIF
     ENDIF
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 2))
    CALL echo(concat("PARSING THROUGH - ",dm_err->errfile))
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE get_unique_file(sbr_fprefix,sbr_fext)
   DECLARE ml_guf_return_val = i4 WITH protect, noconstant(1)
   DECLARE mn_fini = i2 WITH protect, noconstant(0)
   DECLARE ms_fname = vc WITH protect
   DECLARE ms_unique_tempstr = vc WITH protect
   IF (textlen(concat(sbr_fprefix,sbr_fext)) > 24)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Combination of file prefix and extension exceeded length limit of 24."
    SET dm_err->eproc = concat("Getting unique file name using prefix: ",sbr_fprefix," and ext: ",
     sbr_fext)
    SET dm_err->user_action =
    "Please enter a file prefix and extension that does not exceed a length of 24."
    SET ml_guf_return_val = 0
   ENDIF
   IF (ml_guf_return_val=1)
    WHILE (mn_fini=0)
      SET ms_unique_tempstr = substring(1,6,cnvtstring((datetimediff(cnvtdatetime(curdate,curtime3),
         cnvtdatetime(curdate,000000)) * 864000)))
      SET ms_fname = cnvtlower(build(sbr_fprefix,ms_unique_tempstr,sbr_fext))
      IF (findfile(ms_fname)=0)
       SET mn_fini = 1
      ENDIF
    ENDWHILE
    IF (check_error(concat("Getting unique file name using prefix: ",sbr_fprefix," and ext: ",
      sbr_fext))=1)
     SET ml_guf_return_val = 0
    ENDIF
   ENDIF
   IF (ml_guf_return_val=0)
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(concat("Error occurred in ",dm_err->eproc))
    CALL echo("*")
    CALL echo(trim(dm_err->emsg))
    CALL echo("*")
    IF ((dm_err->user_action != "NONE"))
     CALL echo(dm_err->user_action)
     CALL echo("*")
    ENDIF
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
   ELSE
    SET dm_err->unique_fname = ms_fname
    CALL echo(concat("**Unique filename = ",dm_err->unique_fname))
   ENDIF
   RETURN(ml_guf_return_val)
 END ;Subroutine
 SUBROUTINE parse_errfile(sbr_errfile)
   SET dm_err->errtext = " "
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(sbr_errfile)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    DETAIL
     IF ((dm_err->debug_flag > 1))
      CALL echo(concat("TEXT = ",r.line))
     ENDIF
     dm_err->errtext = build(dm_err->errtext,r.line)
    WITH nocounter, maxcol = 255
   ;end select
   IF (check_error(concat("Parsing error file ",dm_err->errfile))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE check_error(sbr_ceprocess)
   DECLARE ml_return_val = i4 WITH protect, noconstant(0)
   IF ((dm_err->err_ind=1))
    SET ml_return_val = 1
   ELSE
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF ((dm_err->ecode != 0))
     SET dm_err->eproc = sbr_ceprocess
     SET dm_err->err_ind = 1
     SET ml_return_val = 1
    ENDIF
   ENDIF
   RETURN(ml_return_val)
 END ;Subroutine
 SUBROUTINE disp_msg(sbr_demsg,sbr_dlogfile,sbr_derr_ind)
   DECLARE mc_dm_txt = c132 WITH protect
   DECLARE ml_dm_ecode = i4 WITH protect
   DECLARE mc_dm_emsg = c132 WITH protect
   DECLARE ms_dm_full_emsg = vc WITH protect
   DECLARE ml_dm_eproc_length = i4 WITH protect
   DECLARE dm_full_emsg_length = i4 WITH protect
   DECLARE ml_dm_user_action_length = i4 WITH protect
   IF (sbr_demsg="dm_err->disp_msg_emsg")
    SET ms_dm_full_emsg = dm_err->disp_msg_emsg
   ELSE
    SET ms_dm_full_emsg = sbr_demsg
   ENDIF
   SET ml_dm_eproc_length = textlen(dm_err->eproc)
   SET dm_full_emsg_length = textlen(ms_dm_full_emsg)
   SET ml_dm_user_action_length = textlen(dm_err->user_action)
   IF ( NOT (sbr_dlogfile IN ("NONE", "DM2_LOGFILE_NOTSET"))
    AND trim(sbr_dlogfile) != ""
    AND textlen(sbr_dlogfile) <= 30)
    SELECT INTO value(sbr_dlogfile)
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      beg_pos = 1, end_pos = 132, not_done = 1
     DETAIL
      row + 1, curdate"mm/dd/yyyy;;d", " ",
      curtime3"hh:mm:ss;3;m"
      IF (sbr_derr_ind=1)
       row + 1, "* Component Name:  ", curprog,
       row + 1, "* Process Description:  "
      ENDIF
      mc_dm_txt = substring(beg_pos,end_pos,dm_err->eproc)
      WHILE (not_done=1)
        row + 1, col 0, mc_dm_txt
        IF (end_pos > ml_dm_eproc_length)
         not_done = 0
        ELSE
         beg_pos = (end_pos+ 1), end_pos = (end_pos+ 132), mc_dm_txt = substring(beg_pos,132,dm_err->
          eproc)
        ENDIF
      ENDWHILE
      IF (sbr_derr_ind=1)
       row + 1, "* Error Message:  ", beg_pos = 1,
       end_pos = 132, mc_dm_txt = substring(beg_pos,132,ms_dm_full_emsg), not_done = 1
       WHILE (not_done=1)
         row + 1, col 0, mc_dm_txt
         IF (end_pos > dm_full_emsg_length)
          not_done = 0
         ELSE
          beg_pos = (end_pos+ 1), end_pos = (end_pos+ 132), mc_dm_txt = substring(beg_pos,132,
           ms_dm_full_emsg)
         ENDIF
       ENDWHILE
      ENDIF
      IF ((dm_err->user_action != "NONE"))
       row + 1, "* Recommended Action(s):  ", beg_pos = 1,
       end_pos = 132, mc_dm_txt = substring(beg_pos,132,dm_err->user_action), not_done = 1
       WHILE (not_done=1)
         row + 1, col 0, mc_dm_txt
         IF (end_pos > ml_dm_user_action_length)
          not_done = 0
         ELSE
          beg_pos = (end_pos+ 1), end_pos = (end_pos+ 132), mc_dm_txt = substring(beg_pos,132,dm_err
           ->user_action)
         ENDIF
       ENDWHILE
      ENDIF
      row + 1
     WITH nocounter, format = variable, formfeed = none,
      maxrow = 1, maxcol = 200, append
    ;end select
    SET ml_dm_ecode = error(mc_dm_emsg,1)
   ELSEIF (sbr_dlogfile != "DM2_LOGFILE_NOTSET")
    SET ml_dm_ecode = 1
    SET mc_dm_emsg = "Message couldn't write to log file since name passed in was invalid."
   ENDIF
   IF (ml_dm_ecode > 0)
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(concat("Component Name:  ",curprog))
    CALL echo("*")
    CALL echo(concat("Process Description:  Writing message to log file."))
    CALL echo("*")
    CALL echo(concat("Error Message:  ",trim(mc_dm_emsg)))
    CALL echo("*")
    IF ( NOT (sbr_dlogfile IN ("NONE", "DM2_LOGFILE_NOTSET")))
     CALL echo(concat("Log file is ccluserdir:",sbr_dlogfile))
     CALL echo("*")
    ENDIF
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
   ENDIF
   IF (sbr_derr_ind=1)
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(concat("Component Name:  ",curprog))
    CALL echo("*")
    CALL echo(concat("Process Description:  ",dm_err->eproc))
    CALL echo("*")
    CALL echo(concat("Error Message:  ",trim(ms_dm_full_emsg)))
    CALL echo("*")
    IF ((dm_err->user_action != "NONE"))
     CALL echo(concat("Recommended Action(s):  ",trim(dm_err->user_action)))
     CALL echo("*")
    ENDIF
    IF ( NOT (sbr_dlogfile IN ("NONE", "DM2_LOGFILE_NOTSET")))
     CALL echo(concat("Log file is ccluserdir:",sbr_dlogfile))
     CALL echo("*")
    ENDIF
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
   ELSE
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(dm_err->eproc)
    CALL echo("*")
    IF ((dm_err->user_action != "NONE"))
     CALL echo(concat("Recommended Action(s):  ",trim(dm_err->user_action)))
     CALL echo("*")
    ENDIF
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
   ENDIF
   SET dm_err->user_action = "NONE"
 END ;Subroutine
 SUBROUTINE init_logfile(sbr_logfile,sbr_header_msg)
   DECLARE ml_init_return_val = i4 WITH protect, noconstant(1)
   IF (sbr_logfile != "NONE"
    AND trim(sbr_logfile) != ""
    AND textlen(sbr_logfile) <= 30)
    SELECT INTO value(sbr_logfile)
     FROM (dummyt d  WITH seq = 1)
     DETAIL
      row + 1, curdate"mm/dd/yyyy;;d", " ",
      curtime3"hh:mm:ss;;m", row + 1, sbr_header_msg,
      row + 1, row + 1
     WITH nocounter, format = variable, formfeed = none,
      maxrow = 1, maxcol = 512
    ;end select
    IF (check_error(concat("Creating log file ",trim(sbr_logfile)))=1)
     SET ml_init_return_val = 0
    ELSE
     SET dm_err->eproc = concat("Log file created.  Log file name is: ",sbr_logfile)
     CALL disp_msg(" ",sbr_logfile,0)
    ENDIF
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Creating log file ",trim(sbr_logfile))
    SET dm_err->emsg = concat("Log file name passed is invalid.  Name passed in is: ",trim(
      sbr_logfile))
    SET ml_init_return_val = 0
   ENDIF
   IF (ml_init_return_val=0)
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(concat("Error occurred in ",dm_err->eproc))
    CALL echo("*")
    CALL echo(trim(dm_err->emsg))
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
   ENDIF
   RETURN(ml_init_return_val)
 END ;Subroutine
 SUBROUTINE check_logfile(sbr_lprefix,sbr_lext,sbr_hmsg)
   IF ((dm_err->logfile IN ("NONE", "DM2_LOGFILE_NOTSET")))
    IF ((dm_err->debug_flag > 1))
     SET trace = echoprogsub
     IF (((currev > 8) OR (currev=8
      AND currevminor >= 1)) )
      SET trace = echosub
     ENDIF
    ENDIF
    IF (get_unique_file(sbr_lprefix,sbr_lext)=0)
     RETURN(0)
    ENDIF
    SET dm_err->logfile = dm_err->unique_fname
    IF (init_logfile(dm_err->logfile,sbr_hmsg)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dm2_prg_maint("BEGIN")=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE final_disp_msg(sbr_log_prefix)
   DECLARE pn_length = i2
   SET pn_length = textlen(sbr_log_prefix)
   IF (dm2_prg_maint("END")=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->err_ind=0))
    IF (cnvtlower(sbr_log_prefix)=substring(1,pn_length,dm_err->logfile))
     SET dm_err->eproc = concat(dm_err->eproc,"  Log file is ccluserdir:",dm_err->logfile)
     CALL disp_msg(" ",dm_err->logfile,0)
    ELSE
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_prg_maint(sbr_maint_type)
   IF ( NOT (cnvtupper(trim(sbr_maint_type,3)) IN ("BEGIN", "END")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid maintenance type"
    SET dm_err->eproc = "Performing program maintenance"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo("********************************************************")
    CALL echo("* CCL current resource usage statistics                *")
    CALL echo("********************************************************")
    CALL trace(7)
   ENDIF
   IF (cnvtupper(trim(sbr_maint_type,3))="BEGIN")
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF (dm2_set_autocommit(0)=0)
     RETURN(0)
    ENDIF
    SET dm2_install_schema->curprog = curprog
   ELSE
    IF (dm2_set_autocommit(0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_set_autocommit(sbr_dsa_flag)
   IF ( NOT (sbr_dsa_flag IN (0, 1)))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid autocommit flag"
    SET dm_err->eproc = "Setting autocommit indicator"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (currdb="SQLSRV")
    IF (currdbhandle > " ")
     IF (sbr_dsa_flag=1)
      IF (dm2_push_cmd("rdb set autocommit go",1)=0)
       RETURN(0)
      ENDIF
      IF (dm2_push_cmd("rdb set inlineparameters go",1)=0)
       RETURN(0)
      ENDIF
     ELSE
      IF (dm2_push_cmd("rdb set noautocommit go",1)=0)
       RETURN(0)
      ENDIF
      IF (dm2_push_cmd("rdb set noinlineparameters go",1)=0)
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_rdbms_version(null)
   DECLARE mn_dgrv_level = i2 WITH protect, noconstant(0)
   DECLARE mn_dgrv_loc = i2 WITH protect, noconstant(0)
   DECLARE mn_dgrv_prev_loc = i2 WITH protect, noconstant(0)
   DECLARE mn_dgrv_loop = i2 WITH protect, noconstant(0)
   DECLARE mn_dgrv_len = i2 WITH protect, noconstant(0)
   IF (currdb IN ("DB2UDB", "SQLSRV"))
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM product_component_version p
    WHERE cnvtupper(p.product)="ORACLE*"
    DETAIL
     dm2_rdbms_version->version = p.version
    WITH nocounter
   ;end select
   IF (check_error("Getting product component version")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSEIF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Product component version not found."
    SET dm_err->eproc = "Getting product component version"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   WHILE (mn_dgrv_loop=0)
     SET mn_dgrv_level = (mn_dgrv_level+ 1)
     SET mn_dgrv_prev_loc = mn_dgrv_loc
     SET mn_dgrv_loc = 0
     SET mn_dgrv_loc = findstring(".",dm2_rdbms_version->version,(mn_dgrv_prev_loc+ 1),0)
     IF (((mn_dgrv_loc > 0) OR (mn_dgrv_loc=0
      AND mn_dgrv_level > 1)) )
      IF (mn_dgrv_loc=0
       AND mn_dgrv_level > 1)
       SET mn_dgrv_len = (textlen(dm2_rdbms_version->version) - mn_dgrv_prev_loc)
       SET mn_dgrv_loop = 1
      ELSE
       SET mn_dgrv_len = ((mn_dgrv_loc - mn_dgrv_prev_loc) - 1)
      ENDIF
      CASE (mn_dgrv_level)
       OF 1:
        SET dm2_rdbms_version->level1 = cnvtint(substring(1,mn_dgrv_len,dm2_rdbms_version->version))
       OF 2:
        SET dm2_rdbms_version->level2 = cnvtint(substring((mn_dgrv_prev_loc+ 1),mn_dgrv_len,
          dm2_rdbms_version->version))
       OF 3:
        SET dm2_rdbms_version->level3 = cnvtint(substring((mn_dgrv_prev_loc+ 1),mn_dgrv_len,
          dm2_rdbms_version->version))
       OF 4:
        SET dm2_rdbms_version->level4 = cnvtint(substring((mn_dgrv_prev_loc+ 1),mn_dgrv_len,
          dm2_rdbms_version->version))
       OF 5:
        SET dm2_rdbms_version->level5 = cnvtint(substring((mn_dgrv_prev_loc+ 1),mn_dgrv_len,
          dm2_rdbms_version->version))
       ELSE
        SET mn_dgrv_loop = 1
      ENDCASE
     ELSE
      IF (mn_dgrv_level=1)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = "Product component version not in expected format."
       SET dm_err->eproc = "Getting product component version"
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       RETURN(0)
      ENDIF
      SET mn_dgrv_loop = 1
     ENDIF
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 IF (validate(ml_max_error_num)=0)
  DECLARE ml_max_error_num = i4 WITH protect, constant(15014)
  DECLARE ml_min_error_num = i4 WITH protect, constant(15000)
  DECLARE ml_errors_cnt = i4 WITH protect, constant(((ml_max_error_num - ml_min_error_num)+ 1))
 ENDIF
 IF (validate(mn_select)=0)
  DECLARE mn_select = i2 WITH protect, constant(1)
  DECLARE mn_update = i2 WITH protect, constant(2)
  DECLARE mn_insert = i2 WITH protect, constant(3)
  DECLARE mn_delete = i2 WITH protect, constant(4)
 ENDIF
 IF (validate(ms_warning)=0)
  DECLARE ms_warning = vc WITH protect, constant("WARNING")
  DECLARE ms_failed = vc WITH protect, constant("FAILED")
  DECLARE ms_passed = vc WITH protect, constant("PASSED")
  DECLARE ms_success = vc WITH protect, constant("SUCCESS")
 ENDIF
 IF (validate(ms_execute_type)=0)
  DECLARE ms_execute_type = vc WITH protect, constant("EXECUTE")
  DECLARE ms_data_type = vc WITH protect, constant("DATA")
  DECLARE ms_other_type = vc WITH protect, constant("OTHER")
  DECLARE ms_none_type = vc WITH protect, constant("NONE")
 ENDIF
 IF (validate(ms_object_name)=0)
  DECLARE ms_object_name = vc WITH protect, noconstant(" ")
 ENDIF
 IF (validate(mf_project_instance)=0)
  DECLARE mf_project_instance = f8 WITH protect, noconstant(0.0)
 ENDIF
 IF (validate(mf_cur_env_id)=0)
  DECLARE mf_cur_env_id = f8 WITH protect, noconstant(0.0)
 ENDIF
 IF (validate(realtime_flag)=0)
  DECLARE realtime_flag = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(mn_script_info_only_ind)=0)
  DECLARE mn_script_info_only_ind = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(ml_err_list_size)=0)
  DECLARE ml_err_list_size = i4 WITH protect, noconstant(0)
 ENDIF
 IF (validate(dm_script_scanner_reply->err_list)=0)
  FREE RECORD dm_script_scanner_reply
  RECORD dm_script_scanner_reply(
    1 script_name = vc
    1 fail_ind = i2
    1 err_list[*]
      2 fail_number = i4
      2 fail_message = vc
  ) WITH persistscript
 ENDIF
 IF (validate(m_exceptions->l_num_exceptions)=0)
  FREE RECORD m_exceptions
  RECORD m_exceptions(
    1 l_num_exceptions = i4
    1 exceptions[*]
      2 s_threshold_type = vc
      2 s_threshold_char = vc
      2 f_threshold_value = f8
  ) WITH protect
 ENDIF
 IF (validate(m_error_struct->error_list)=0)
  FREE RECORD m_error_struct
  RECORD m_error_struct(
    1 error_list[ml_errors_cnt]
      2 s_error_status = vc
  ) WITH protect
 ENDIF
 IF (validate(m_table_access_rec->list)=0)
  FREE RECORD m_table_access_rec
  RECORD m_table_access_rec(
    1 list[2]
      2 l_num_table = i4
      2 table_list[*]
        3 s_table_name = vc
        3 n_operation_type = i2
  ) WITH protect
 ENDIF
 IF (validate(m_ora_table_rec->tables)=0)
  FREE RECORD m_ora_table_rec
  RECORD m_ora_table_rec(
    1 l_num_table = i4
    1 tables[*]
      2 s_table_name = vc
      2 s_entity_type = vc
      2 l_select_cnt = i4
      2 l_update_cnt = i4
      2 l_insert_cnt = i4
      2 l_delete_cnt = i4
      2 n_ora_tab_ind = i2
      2 n_obs_tab_ind = i2
      2 l_num_column = i4
      2 columns[*]
        3 s_column_name = vc
  ) WITH protect
 ENDIF
 IF (validate(m_full_table_scan->table_list)=0)
  FREE RECORD m_full_table_scan
  RECORD m_full_table_scan(
    1 l_table_cnt = i4
    1 table_list[*]
      2 s_table_name = vc
  ) WITH protect
 ENDIF
 IF (validate(m_index_usage->index_list)=0)
  FREE RECORD m_index_usage
  RECORD m_index_usage(
    1 l_index_cnt = i4
    1 index_list[*]
      2 l_usage_cnt = i4
      2 s_index_name = vc
      2 s_table_name = vc
      2 s_options = vc
  ) WITH protect
 ENDIF
 IF (validate(m_sequence->seq_list)=0)
  RECORD m_sequence(
    1 l_seq_cnt = i4
    1 seq_list[*]
      2 s_seq_name = vc
      2 l_usage_cnt = i4
  ) WITH protect
 ENDIF
 IF (validate(m_dependency_rec->childs)=0)
  FREE RECORD m_dependency_rec
  RECORD m_dependency_rec(
    1 l_child_cnt = i4
    1 childs[*]
      2 s_component_name = vc
      2 s_component_type = vc
  ) WITH protect
 ENDIF
 IF (validate(m_plan_table->plan_list)=0)
  FREE RECORD m_plan_table
  RECORD m_plan_table(
    1 l_plan_list_cnt = i4
    1 plan_list[*]
      2 s_statement_id = vc
      2 f_cost = f8
      2 s_optimizer_mode = vc
      2 l_sql_piece_cnt = i4
      2 sql_piece[*]
        3 s_sql_text = vc
  ) WITH protect
 ENDIF
 DECLARE sbr_add_error(pn_error_num=i4,ps_error_text=vc) = i2
 DECLARE sbr_bt_defn_cleanup(null) = i2
 SUBROUTINE sbr_add_error(pn_error_num,ps_error_text)
  IF (mn_script_info_only_ind=0)
   DECLARE pl_num = i4 WITH private, noconstant(0)
   IF (ml_min_error_num <= pn_error_num
    AND pn_error_num <= ml_max_error_num
    AND (m_error_struct->error_list[((pn_error_num - ml_min_error_num)+ 1)].s_error_status IN (
   ms_warning, ms_failed)))
    SET dm_script_scanner_reply->fail_ind = 1
    SET ml_err_list_size = (ml_err_list_size+ 1)
    SET mn_stat = alterlist(dm_script_scanner_reply->err_list,ml_err_list_size)
    SET dm_script_scanner_reply->err_list[ml_err_list_size].fail_number = pn_error_num
    SET dm_script_scanner_reply->err_list[ml_err_list_size].fail_message = concat(m_error_struct->
     error_list[((pn_error_num - ml_min_error_num)+ 1)].s_error_status,": ",ps_error_text)
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_email_error_info(eei_script_name,ps_error_begin)
   DECLARE eei_env_id_string = vc WITH public, noconstant(" ")
   DECLARE email_error_filename = vc WITH public, constant("dm2_buildtime_err")
   SET eei_env_id_string = cnvtstring(mf_cur_env_id)
   SELECT INTO concat(email_error_filename,".log")
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    DETAIL
     error_msg = substring(1,250,dm_err->emsg), row 1, col 0,
     ps_error_begin, row 4, col 0,
     "Environment OS   : ", col 20, cursys,
     row 5, col 0, "Environment Id   : ",
     col 20, eei_env_id_string, row 6,
     col 0, "Logfile          : ", col 20,
     dm_err->logfile, row 7, col 0,
     "Object name      : ", col 20, ms_object_name
    WITH nocounter, maxcol = 300, format = variable
   ;end select
   EXECUTE email "dataaccessreview@cerner.com", " ", concat("ERROR in ",eei_script_name),
   concat(email_error_filename,".log")
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_bt_defn_cleanup(null)
   FREE RECORD dm_script_scanner_reply
   FREE RECORD m_exceptions
   FREE RECORD m_error_struct
   FREE RECORD m_table_access_rec
   FREE RECORD m_ora_table_rec
   FREE RECORD m_full_table_scan
   FREE RECORD m_index_usage
   FREE RECORD m_dependency_rec
   FREE RECORD m_plan_table
   RETURN(1)
 END ;Subroutine
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="DM_ENV_ID"
  DETAIL
   mf_cur_env_id = di.info_number
  WITH nocounter
 ;end select
 IF (check_logfile("dm_script_analysis",".log","DM_SCRIPT_ANALYSIS logfile")=0)
  SET dm_err->err_ind = 1
  SET dm_err->eproc = "Error creating log file"
  CALL disp_msg(" ",dm_err->logfile,0)
  GO TO exit_program
 ENDIF
 IF (validate(review_type_manual)=0)
  DECLARE review_type_manual = vc WITH public, constant("MANUAL SCAN")
  DECLARE review_type_sql = vc WITH public, constant("SQLAREA SCANNER")
  DECLARE review_type_rtl = vc WITH public, constant("RTL SCANNER")
  DECLARE review_type_data = vc WITH public, constant("DATA SCANNER")
  DECLARE review_type_sqltime = vc WITH public, constant("SQLTIME SCANNER")
  DECLARE review_type_code = vc WITH public, constant("CODE SCANNER")
  DECLARE criteria_exclude_script = vc WITH public, constant("EXCLUDE_SCRIPT")
  DECLARE criteria_exclude_server = vc WITH public, constant("EXCLUDE_SERVER")
  DECLARE criteria_exclude_error = vc WITH public, constant("EXCLUDE_ERROR")
  DECLARE criteria_exec_per_minute = vc WITH public, constant("EXECUTIONS_PER_MINUTE")
  DECLARE project_type_script = vc WITH public, constant("SCRIPT")
  DECLARE project_type_code = vc WITH public, constant("CODE")
  DECLARE error_type_ccl = vc WITH public, constant("CCL")
  DECLARE error_type_oracle = vc WITH public, constant("ORACLE")
  DECLARE status_fail = vc WITH public, constant("FAILED")
  DECLARE status_pass = vc WITH public, constant("PASSED")
  DECLARE status_warning = vc WITH public, constant("WARNING")
  DECLARE status_override = vc WITH public, constant("OVERRIDE")
  DECLARE status_notify = vc WITH public, constant("NOTIFY")
  DECLARE status_archived = vc WITH public, constant("ARCHIVED")
  DECLARE status_reset = vc WITH public, constant("RESET")
  DECLARE status_duplicate = vc WITH public, constant("DUPLICATE")
  DECLARE gs_pipeline = vc WITH public, constant("DM_PIPELINE")
  DECLARE gs_review_lock = vc WITH public, constant("DM_REVIEW_LOCK")
  DECLARE gs_review_off = vc WITH public, constant("DM_REVIEW_OFF")
  DECLARE gs_email_off = vc WITH public, constant("DM_REVIEW_EMAIL_OFF")
  DECLARE gs_review_report = vc WITH public, constant("DM_REVIEW_REPORT")
  DECLARE gs_env_disp = vc WITH public, constant("DM_ENV_DISP")
  DECLARE gs_script_cov_report = vc WITH public, constant("DM_SCRIPT_COVERAGE_REPORT")
  DECLARE gs_script_cov_beg_status = vc WITH public, constant("DM_SCRIPT_COVERAGE_BEGIN_STATUS")
  DECLARE gs_script_cov_end_status = vc WITH public, constant("DM_SCRIPT_COVERAGE_END_STATUS")
  DECLARE gs_data_mgmt = vc WITH public, constant("DATA MANAGEMENT")
  DECLARE gs_env_id = vc WITH public, constant("DM_ENV_ID")
  DECLARE gs_package_env_id = vc WITH public, constant("DM_PKG_ENV_ID")
  DECLARE gs_dummy_env = vc WITH public, constant("DUMMY ENVIRONMENT")
  DECLARE gf_dummy_env_id = f8 WITH public, constant(99999999.0)
  DECLARE gs_package_build = vc WITH public, constant("PACKAGE_BUILD_IND")
  DECLARE gs_package_install = vc WITH public, constant("PACKAGE_INSTALL_IND")
  DECLARE gs_app_dtl_report = vc WITH public, constant("DM_APPLICATION_DETAIL_REPORT")
  DECLARE cur_env_id = f8 WITH public, noconstant(0.0)
  DECLARE pkg_env_id = f8 WITH public, noconstant(0.0)
  DECLARE review_process_off = f8 WITH public, noconstant(0.0)
  DECLARE review_email_off = f8 WITH public, noconstant(0.0)
  DECLARE cur_env_name = vc WITH public, noconstant(" ")
  DECLARE cur_pipeline = vc WITH public, noconstant(" ")
  DECLARE review_off_found_ind = i2 WITH public, noconstant(0)
  DECLARE package_build_env = f8 WITH public, noconstant(0.0)
  DECLARE package_install_env = f8 WITH public, noconstant(0.0)
  DECLARE realtime_ind = i2 WITH public, noconstant(0)
 ENDIF
 IF (validate(dm2_review_struct->reviews)=0)
  FREE RECORD dm2_review_struct
  RECORD dm2_review_struct(
    1 reviews[*]
      2 review_id = f8
      2 environment_id = f8
      2 pipeline = vc
      2 threshold_id = f8
      2 review_type = vc
      2 review_dt_tm = dq8
      2 max_manual_reviews = i4
      2 max_review_errors = i4
      2 max_review_sqls = i4
      2 max_review_sqltimes = i4
      2 reviewobjects[*]
        3 project_type = vc
        3 object_name = vc
        3 object_id = f8
        3 object_instance_id = f8
        3 review_object_r_id = f8
        3 status = vc
        3 manualreviews[*]
          4 review_manual_id = f8
          4 reviewer = vc
          4 review_reason = vc
          4 status = vc
          4 override_approver = vc
          4 override_reason = vc
          4 orig_status = vc
          4 status_reason = vc
        3 reviewerrors[*]
          4 review_error_id = f8
          4 error_type = vc
          4 error_code = vc
          4 error_text = vc
          4 server_nbr = i2
          4 status = vc
          4 error_msg = vc
          4 unique_text = vc
          4 exists_ind = i2
        3 reviewsqls[*]
          4 review_sql_id = f8
          4 status = vc
          4 server_nbr = i2
          4 hash_value = f8
          4 first_load_time = vc
          4 disk_reads = f8
          4 buffer_gets = f8
          4 executions = f8
          4 score = f8
          4 cpu_time = f8
          4 elapsed_time = f8
          4 action = vc
          4 action_hash = f8
          4 address = vc
          4 child_latch = f8
          4 command_type = f8
          4 fetches = f8
          4 first_load_time = vc
          4 invalidations = f8
          4 is_obsolete = c1
          4 kept_versions = f8
          4 loaded_versions = f8
          4 loads = f8
          4 module = vc
          4 module_hash = f8
          4 open_versions = f8
          4 optimizer_mode = vc
          4 parse_calls = f8
          4 parsing_schema_id = f8
          4 parsing_user_id = f8
          4 persistent_mem = f8
          4 rows_processed = f8
          4 runtime_mem = f8
          4 serializable_aborts = f8
          4 sharable_mem = f8
          4 sorts = f8
          4 users_executing = f8
          4 users_opening = f8
          4 sql_text = vc
          4 error_msg = vc
          4 child_address = vc
          4 last_load_time = vc
          4 literal_hash_value = f8
          4 object_status = vc
          4 optimizer_cost = f8
          4 outline_category = vc
          4 outline_sid = f8
          4 plan_hash_value = f8
          4 remote = c1
          4 sqltype = f8
          4 type_chk_heap = vc
          4 thresholds[*]
            5 review_sql_id = f8
            5 threshold_type = vc
            5 status = vc
            5 error_msg = vc
            5 exists_ind = i2
        3 reviewsqltimes[*]
          4 review_sqltime_id = f8
          4 status = c40
          4 server_nbr = i2
          4 hash_value = f8
          4 disk_reads = f8
          4 buffer_gets = f8
          4 executions = f8
          4 score = f8
          4 percent = f8
          4 start_dt_tm = dq8
          4 end_dt_tm = dq8
          4 delta_time = f8
          4 error_msg = vc
          4 sql_text = vc
          4 thresholds[*]
            5 review_sqltime_id = f8
            5 threshold_type = vc
            5 status = vc
            5 error_msg = vc
            5 exists_ind = i2
  ) WITH public
 ENDIF
 IF (validate(dm2_thresholds->thresholds)=0)
  FREE RECORD dm2_thresholds
  RECORD dm2_thresholds(
    1 max_threshold_criterias = i4
    1 rtl_exclude_server_cnt = i4
    1 rtl_exclude_script_cnt = i4
    1 rtl_exclude_error_cnt = i4
    1 sql_exclude_server_cnt = i4
    1 sql_exclude_script_cnt = i4
    1 sqltime_exclude_server_cnt = i4
    1 sqltime_exclude_script_cnt = i4
    1 thresholds[*]
      2 chg_ind = i2
      2 add_ind = i2
      2 threshold_id = f8
      2 review_type = vc
      2 threshold_dt_tm = dq8
      2 active_ind = i2
      2 curuser = vc
      2 thresholdcriteria[*]
        3 threshold_criteria_id = f8
        3 priority_seq = i2
        3 criteria_name = vc
        3 criteria_value = f8
        3 criteria_char = vc
        3 criteria_formula = vc
        3 boundary_formula = vc
        3 action = vc
        3 os_type = vc
  ) WITH public
 ENDIF
 IF (validate(dm2_objects->objects)=0)
  FREE RECORD dm2_objects
  RECORD dm2_objects(
    1 max_object_instances = i4
    1 objects[*]
      2 add_ind = i2
      2 chg_ind = i2
      2 object_id = f8
      2 object_name = vc
      2 object_pipeline = vc
      2 project_number = i4
      2 project_type = vc
      2 project_name = vc
      2 project_owner = vc
      2 team_name = vc
      2 project_owner = vc
      2 max_overrides = i4
      2 objectinstances[*]
        3 add_ind = i2
        3 chg_ind = i2
        3 reactivate_ind = i2
        3 environment_id = f8
        3 object_instance_id = f8
        3 object_instance = i4
        3 object_version = vc
        3 build_stamp = vc
        3 compile_dt_tm = dq8
        3 status = vc
        3 active_ind = i2
        3 notify_dt_tm = dq8
        3 overrides[*]
          4 add_ind = i2
          4 object_override_id = f8
          4 orig_status = vc
          4 new_status = vc
          4 override_dt_tm = dq8
          4 override_reason = vc
          4 override_approver = vc
  ) WITH public
 ENDIF
 IF (validate(dm2_component_instances->components)=0)
  FREE RECORD dm2_component_instances
  RECORD dm2_component_instances(
    1 cnt = i4
    1 components[*]
      2 component_name = vc
      2 source_set_instance = i4
      2 project_number = i4
      2 build_stamp = vc
      2 compile_dt_tm = dq8
      2 timestamp = dq8
      2 upd_flt_ind = i2
      2 upd_llt_ind = i2
      2 object_id = f8
      2 first_load_time = dq8
      2 last_load_time = dq8
      2 object_instance_id = f8
      2 row_exists_ind = i2
      2 execution_days[*]
        3 execution_count = i2
        3 first_load_dt_tm = dq8
        3 last_load_dt_tm = dq8
        3 exists_ind = i2
  ) WITH public
 ENDIF
 IF (validate(dm2_debug_review->show_thresholds_after_load)=0)
  FREE RECORD dm2_debug_review
  RECORD dm2_debug_review(
    1 show_thresholds_after_load = i2
    1 show_extra_info = i2
    1 show_initial_data = i2
    1 show_data_after_ids = i2
    1 show_ending_data = i2
    1 show_obj_instance_input = i2
    1 show_obj_instance_output = i2
    1 show_rev_obj_initial = i2
    1 show_rev_obj_after_process = i2
    1 show_rtl_files = i2
    1 show_rtl_errors = i2
    1 show_rtl_review = i2
    1 show_sqlarea_rows = i2
    1 show_sql_review = i2
    1 do_not_call_engine = i2
    1 supress_error_email = i2
    1 ignore_process_off = i2
    1 echorecord_to_screen = i2
    1 write_to_test_env = i2
    1 email_testing = i2
  ) WITH public
  SET dm2_debug_review->show_thresholds_after_load = 0
  SET dm2_debug_review->show_extra_info = 0
  SET dm2_debug_review->show_initial_data = 0
  SET dm2_debug_review->show_data_after_ids = 0
  SET dm2_debug_review->show_ending_data = 0
  SET dm2_debug_review->show_obj_instance_input = 0
  SET dm2_debug_review->show_obj_instance_output = 0
  SET dm2_debug_review->show_rev_obj_initial = 0
  SET dm2_debug_review->show_rev_obj_after_process = 0
  SET dm2_debug_review->show_rtl_files = 0
  SET dm2_debug_review->show_rtl_errors = 0
  SET dm2_debug_review->show_rtl_review = 0
  SET dm2_debug_review->show_sqlarea_rows = 0
  SET dm2_debug_review->show_sql_review = 0
  SET dm2_debug_review->do_not_call_engine = 0
  SET dm2_debug_review->supress_error_email = 0
  SET dm2_debug_review->ignore_process_off = 0
  SET dm2_debug_review->echorecord_to_screen = 0
  SET dm2_debug_review->write_to_test_env = 0
  SET dm2_debug_review->email_testing = 0
 ENDIF
 IF (validate(dm2_environments->envlist)=0)
  FREE RECORD dm2_environments
  RECORD dm2_environments(
    1 envlist[*]
      2 environment_id = f8
      2 pipeline = vc
      2 environment_name = vc
      2 report_ind = i2
      2 process_off_ind = i2
      2 email_off_ind = i2
      2 disp_env_ind = i2
      2 package_build_ind = i2
      2 package_install_ind = i2
      2 app_exec_crash_ind = i2
      2 script_coverage_ind = i2
      2 script_cov_date = dq8
      2 script_cov_begin_status = vc
      2 script_cov_end_status = vc
  ) WITH public
 ENDIF
 IF (validate(dm2_sql_analyze_delta->queries)=0)
  FREE RECORD dm2_sql_analyze_delta
  RECORD dm2_sql_analyze_delta(
    1 queries[*]
      2 object_name = vc
      2 hash_value = f8
      2 server_nbr = i4
      2 start_dt_tm = dq8
      2 end_dt_tm = dq8
      2 delta_time = f8
      2 buffer_gets = f8
      2 disk_reads = f8
      2 percent = f8
      2 executions = f8
      2 score = f8
      2 sql_text = vc
      2 execution_days[*]
        3 execution_count = i2
        3 first_load_dt_tm = dq8
        3 last_load_dt_tm = dq8
  ) WITH public
 ENDIF
 SET dm_err->eproc = "Getting current environment information."
 CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
 SELECT INTO "nl:"
  di.info_name
  FROM dm_info di
  WHERE di.info_domain=gs_data_mgmt
   AND di.info_name IN (gs_env_id, gs_package_env_id)
  DETAIL
   CASE (di.info_name)
    OF gs_env_id:
     cur_env_id = di.info_number
    OF gs_package_env_id:
     pkg_env_id = di.info_number
   ENDCASE
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  SET dm_err->err_ind = 1
 ENDIF
 IF ((dm2_debug_review->write_to_test_env=1))
  SET cur_env_id = gf_dummy_env_id
  SET cur_env_name = gs_dummy_env
 ENDIF
 IF (size(dm2_environments->envlist,5)=0)
  SET dm_err->eproc = "Call subroutine to refresh dm2_environments."
  CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
  IF (sbr_repopulate_dm2_environments(0)=1)
   SET dm_err->eproc = "Subroutine sbr_repopulate_dm2_environments was successful."
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
  ELSE
   SET dm_err->eproc = "Subroutine sbr_repopulate_dm2_environments was not successful."
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   GO TO exit_program
  ENDIF
 ENDIF
 DECLARE dm2_load_thresholds(lt_review_type=vc) = i2
 DECLARE dm2_load_component_instances(lci_dummy=i2) = i2
 DECLARE dm2_load_component_object_ids(lci_dummy=i2) = i2
 DECLARE dm2_email_error_info(eei_script_name=vc) = i2
 DECLARE dm2_dar_lock_process(pf_environment_id=f8) = i2
 DECLARE sbr_repopulate_dm2_environments(pn_rde_dummy=i2) = i2 WITH public
 DECLARE sbr_begin_scan_stamp(ps_process_name=vc) = f8
 DECLARE sbr_end_scan_stamp(pf_scanner_log_id=f8) = i2
 SUBROUTINE dm2_load_thresholds(lt_review_type)
   SET dm_err->eproc = "Beginning 'dm2_load_thresholds'."
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SELECT
    IF (realtime_ind=1)
     PLAN (dt
      WHERE dt.review_type=lt_review_type
       AND dt.active_ind=1)
      JOIN (dtc
      WHERE dtc.threshold_id=dt.threshold_id
       AND ((dtc.os_type=cursys) OR (dtc.os_type="ALL"))
       AND  NOT (dtc.criteria_name=criteria_exclude_server
       AND dtc.criteria_value=0.0))
    ELSE
     PLAN (dt
      WHERE dt.review_type=lt_review_type
       AND dt.active_ind=1)
      JOIN (dtc
      WHERE dtc.threshold_id=dt.threshold_id
       AND ((dtc.os_type=cursys) OR (dtc.os_type="ALL")) )
    ENDIF
    INTO "nl:"
    dt.threshold_id
    FROM dm_threshold dt,
     dm_threshold_criteria dtc
    ORDER BY dtc.threshold_id, dtc.priority_seq
    HEAD REPORT
     thresh_cnt = 0, stat = alterlist(dm2_thresholds->thresholds,thresh_cnt), dm2_thresholds->
     max_threshold_criterias = 0,
     dm2_thresholds->rtl_exclude_server_cnt = 0, dm2_thresholds->rtl_exclude_script_cnt = 0,
     dm2_thresholds->rtl_exclude_error_cnt = 0,
     dm2_thresholds->sql_exclude_server_cnt = 0, dm2_thresholds->sql_exclude_script_cnt = 0,
     dm2_thresholds->sqltime_exclude_server_cnt = 0,
     dm2_thresholds->sqltime_exclude_script_cnt = 0
    HEAD dtc.threshold_id
     thresh_cnt = (thresh_cnt+ 1)
     IF (thresh_cnt > size(dm2_thresholds->thresholds,5))
      stat = alterlist(dm2_thresholds->thresholds,(thresh_cnt+ 5))
     ENDIF
     criteria_cnt = 0, dm2_thresholds->thresholds[thresh_cnt].threshold_id = dt.threshold_id,
     dm2_thresholds->thresholds[thresh_cnt].review_type = dt.review_type,
     dm2_thresholds->thresholds[thresh_cnt].threshold_dt_tm = dt.threshold_dt_tm, dm2_thresholds->
     thresholds[thresh_cnt].active_ind = dt.active_ind, dm2_thresholds->thresholds[thresh_cnt].
     curuser = dt.curuser
    DETAIL
     criteria_cnt = (criteria_cnt+ 1)
     IF (criteria_cnt > size(dm2_thresholds->thresholds[thresh_cnt].thresholdcriteria,5))
      stat = alterlist(dm2_thresholds->thresholds[thresh_cnt].thresholdcriteria,(criteria_cnt+ 5))
     ENDIF
     dm2_thresholds->thresholds[thresh_cnt].thresholdcriteria[criteria_cnt].threshold_criteria_id =
     dtc.threshold_criteria_id, dm2_thresholds->thresholds[thresh_cnt].thresholdcriteria[criteria_cnt
     ].priority_seq = dtc.priority_seq, dm2_thresholds->thresholds[thresh_cnt].thresholdcriteria[
     criteria_cnt].criteria_name = dtc.criteria_name,
     dm2_thresholds->thresholds[thresh_cnt].thresholdcriteria[criteria_cnt].criteria_value = dtc
     .criteria_value, dm2_thresholds->thresholds[thresh_cnt].thresholdcriteria[criteria_cnt].
     criteria_char = dtc.criteria_char, dm2_thresholds->thresholds[thresh_cnt].thresholdcriteria[
     criteria_cnt].criteria_formula = dtc.criteria_formula,
     dm2_thresholds->thresholds[thresh_cnt].thresholdcriteria[criteria_cnt].action = dtc.action,
     dm2_thresholds->thresholds[thresh_cnt].thresholdcriteria[criteria_cnt].os_type = dtc.os_type
     IF (lt_review_type=review_type_rtl)
      IF (dtc.criteria_name=criteria_exclude_error)
       dm2_thresholds->rtl_exclude_error_cnt = (dm2_thresholds->rtl_exclude_error_cnt+ 1)
      ELSEIF (dtc.criteria_name=criteria_exclude_script)
       dm2_thresholds->rtl_exclude_script_cnt = (dm2_thresholds->rtl_exclude_script_cnt+ 1)
      ELSEIF (dtc.criteria_name=criteria_exclude_server)
       dm2_thresholds->rtl_exclude_server_cnt = (dm2_thresholds->rtl_exclude_server_cnt+ 1)
      ENDIF
     ELSEIF (lt_review_type=review_type_sql)
      IF (dtc.criteria_name=criteria_exclude_script)
       dm2_thresholds->sql_exclude_script_cnt = (dm2_thresholds->sql_exclude_script_cnt+ 1)
      ELSEIF (dtc.criteria_name=criteria_exclude_server)
       dm2_thresholds->sql_exclude_server_cnt = (dm2_thresholds->sql_exclude_server_cnt+ 1)
      ENDIF
     ELSEIF (lt_review_type=review_type_sqltime)
      IF (dtc.criteria_name=criteria_exclude_script)
       dm2_thresholds->sqltime_exclude_script_cnt = (dm2_thresholds->sqltime_exclude_script_cnt+ 1)
      ELSEIF (dtc.criteria_name=criteria_exclude_server)
       dm2_thresholds->sqltime_exclude_server_cnt = (dm2_thresholds->sqltime_exclude_server_cnt+ 1)
      ENDIF
     ENDIF
    FOOT  dtc.threshold_id
     stat = alterlist(dm2_thresholds->thresholds[thresh_cnt].thresholdcriteria,criteria_cnt)
     IF ((criteria_cnt > dm2_thresholds->max_threshold_criterias))
      dm2_thresholds->max_threshold_criterias = criteria_cnt
     ENDIF
    FOOT REPORT
     stat = alterlist(dm2_thresholds->thresholds,thresh_cnt)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    RETURN(0)
   ENDIF
   IF ((dm2_debug_review->show_thresholds_after_load=1))
    SET dm_err->eproc = "DATA: Thresholds after load"
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    IF ((dm2_debug_review->echorecord_to_screen=1))
     CALL echorecord(dm2_thresholds)
    ELSE
     CALL echorecord(dm2_thresholds,dm_err->logfile,1)
    ENDIF
   ENDIF
   SET dm_err->eproc = "Exiting 'dm2_load_thresholds'."
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   IF (curqual=0)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_load_component_instances(lci_dummy)
   SET dm_err->eproc = "Beginning 'dm2_load_component_instances'..."
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   IF ((dm2_debug_review->show_obj_instance_input=1))
    SET dm_err->eproc = "DATA: beginning of 'dm2_load_component_instances'"
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    IF ((dm2_debug_review->echorecord_to_screen=1))
     CALL echorecord(dm2_component_instances)
    ELSE
     CALL echorecord(dm2_component_instances,dm_err->logfile,1)
    ENDIF
   ENDIF
   IF (size(dm2_component_instances->components,5) > 0)
    SET dm_err->eproc = "Getting build stamp information..."
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
    SELECT INTO "nl:"
     app_ocd_major =
     IF (dp.app_minor_version > 900000) mod(dp.app_minor_version,1000000)
     ELSE dp.app_minor_version
     ENDIF
     , app_ocd_minor =
     IF (dp.app_minor_version > 900000) cnvtint((dp.app_minor_version/ 1000000.0))
     ELSE 0
     ENDIF
     , dp.object_name
     FROM (dummyt d  WITH seq = value(size(dm2_component_instances->components,5))),
      dprotect dp
     PLAN (d
      WHERE d.seq > 0)
      JOIN (dp
      WHERE "P"=dp.object
       AND cnvtupper(dm2_component_instances->components[d.seq].component_name)=dp.object_name
       AND dp.group=0)
     ORDER BY dp.object_name
     HEAD dp.object_name
      build_stamp = build(dp.app_major_version,".",app_ocd_major,".",app_ocd_minor),
      dm2_component_instances->components[d.seq].build_stamp = build_stamp, dm2_component_instances->
      components[d.seq].compile_dt_tm = cnvtdatetime(cnvtdate2(format(dp.datestamp,"MM/DD/YY;;D"),
        "MM/DD/YY"),dp.timestamp)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
     RETURN(0)
    ENDIF
    IF ((dm2_debug_review->show_obj_instance_output=1))
     SET dm_err->eproc = "DATA: end of 'dm2_load_component_instances'"
     CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
     IF ((dm2_debug_review->echorecord_to_screen=1))
      CALL echorecord(dm2_component_instances)
     ELSE
      CALL echorecord(dm2_component_instances,dm_err->logfile,1)
     ENDIF
    ENDIF
    SET dm_err->eproc = "Ending 'dm2_load_component_instances'."
    CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_load_component_object_ids(lci_dummy)
   DECLARE ml_loop_index = i4 WITH protect, noconstant(0)
   DECLARE ml_new_list_size = i4 WITH protect, noconstant(0)
   DECLARE ml_start_pos = i4 WITH protect, noconstant(1)
   DECLARE ml_num = i4 WITH protect, noconstant(0)
   DECLARE ml_orig_list_size = i4 WITH protect, constant(size(dm2_component_instances->components,5))
   DECLARE ml_segment_size = i4 WITH protect, constant(50)
   DECLARE ml_loop_cnt = i4 WITH protect, noconstant(0)
   SET dm_err->eproc = "Beginning 'dm2_load_component_object_ids'..."
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   SET ml_loop_cnt = ceil((cnvtreal(ml_orig_list_size)/ ml_segment_size))
   SET ml_new_list_size = (ml_loop_cnt * ml_segment_size)
   SET mn_stat = alterlist(dm2_component_instances->components,ml_new_list_size)
   FOR (i = (ml_orig_list_size+ 1) TO ml_new_list_size)
     SET dm2_component_instances->components[i].component_name = dm2_component_instances->components[
     ml_orig_list_size].component_name
   ENDFOR
   IF (size(dm2_component_instances->components,5) > 0)
    SELECT INTO "nl:"
     dj.object_id
     FROM dm_object dj,
      (dummyt d  WITH seq = value(ml_loop_cnt))
     PLAN (d
      WHERE initarray(ml_start_pos,evaluate(d.seq,1,1,(ml_start_pos+ ml_segment_size))))
      JOIN (dj
      WHERE expand(ml_loop_index,ml_start_pos,((ml_start_pos+ ml_segment_size) - 1),dj.object_name,
       dm2_component_instances->components[ml_loop_index].component_name)
       AND dj.pipeline=cur_pipeline)
     HEAD REPORT
      pl_obj_index = 0
     DETAIL
      pl_obj_index = locateval(ml_num,1,ml_orig_list_size,dj.object_name,dm2_component_instances->
       components[ml_num].component_name)
      WHILE (pl_obj_index > 0)
       dm2_component_instances->components[pl_obj_index].object_id = dj.object_id,pl_obj_index =
       locateval(ml_num,(pl_obj_index+ 1),ml_orig_list_size,dj.object_name,dm2_component_instances->
        components[ml_num].component_name)
      ENDWHILE
     FOOT REPORT
      mn_stat = alterlist(dm2_component_instances->components,ml_orig_list_size)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_email_error_info(eei_script_name)
   DECLARE eei_env_id_string = vc WITH public, noconstant(" ")
   DECLARE email_error_filename = vc WITH public, constant("dm2_review_err")
   SET dm_err->eproc = "Beginning 'dm2_email_error_info'..."
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   IF ((dm2_debug_review->supress_error_email=0))
    SET eei_env_id_string = cnvtstring(cur_env_id)
    SELECT INTO concat(email_error_filename,".log")
     FROM (dummyt d  WITH seq = 1)
     PLAN (d)
     DETAIL
      error_msg = substring(1,250,dm_err->emsg), error_begin = concat("An error has occurred in the ",
       eei_script_name," script"), row 1,
      col 0, error_begin, row 3,
      col 0, "Environment Name : ", col 20,
      cur_env_name, row 4, col 0,
      "Environment OS   : ", col 20, cursys,
      row 5, col 0, "Environment Id   : ",
      col 20, eei_env_id_string, row 6,
      col 0, "Logfile          : ", col 20,
      dm_err->logfile, row 7, col 0,
      "Error Message    : ", col 20, error_msg
     WITH nocounter, maxcol = 300, format = variable
    ;end select
    EXECUTE email "dataaccessreview@cerner.com", " ", concat("ERROR in ",eei_script_name),
    concat(email_error_filename,".log")
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_dar_lock_process(pf_environment_id)
   DECLARE pn_loop_cnt = i2 WITH private, noconstant(0)
   DECLARE pn_exit_loop_ind = i2 WITH private, noconstant(0)
   DECLARE ps_error_2049 = vc WITH private, constant("ORA-02049")
   DECLARE ps_error_54 = vc WITH private, constant("ORA-00054")
   SET dm_err->eproc = concat("Initiating lock on DM_INFO to place program in wait state...")
   CALL disp_msg("",dm_err->logfile,0)
   WHILE (pn_exit_loop_ind=0)
     SET dm_err->eproc = "Trying to obtain DM_INFO lock."
     CALL disp_msg("",dm_err->logfile,0)
     SET pn_loop_cnt = (pn_loop_cnt+ 1)
     SELECT INTO "nl:"
      di.info_name
      FROM dm_info di
      PLAN (di
       WHERE di.info_name=gs_review_lock)
      WITH nocounter, forupdatewait(di)
     ;end select
     IF (check_error(dm_err->eproc)=1)
      IF (findstring(ps_error_2049,dm_err->emsg,1) > 0)
       IF (pn_loop_cnt < 5)
        SET dm_err->eproc = concat("Lock attempt ",cnvtstring(pn_loop_cnt,1),
         " failed.  Waiting 1 minute before next attempt.")
        CALL disp_msg("",dm_err->logfile,0)
        SET dm_err->err_ind = 0
        CALL pause(60)
       ELSE
        SET pn_exit_loop_ind = 1
        SET dm_err->emsg = concat("Unable to obtain lock on DM_INFO after 5 attempts.")
       ENDIF
      ELSE
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       SET pn_exit_loop_ind = 1
      ENDIF
     ELSE
      SET pn_exit_loop_ind = 1
      SET dm_err->eproc = concat("Lock obtained for environment.")
      CALL disp_msg("",dm_err->logfile,0)
     ENDIF
   ENDWHILE
   RETURN(evaluate(dm_err->err_ind,1,0,0,1))
 END ;Subroutine
 SUBROUTINE sbr_repopulate_dm2_environments(pn_rde_dummy)
  IF (initrec(dm2_environments)=0)
   SET dm_err->err_ind = 1
   SET dm_err->emsg = "Unable to re-initialize record dm2_environments."
  ELSE
   SET dm_err->eproc = "dm2_environments record has been initialized."
   CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
   IF (size(dm2_environments->envlist,5)=0)
    SET review_off_found_ind = 0
    SELECT INTO "nl:"
     doi.environment_id
     FROM dm_object_info doi
     PLAN (doi
      WHERE doi.environment_id > 0.0
       AND doi.info_name IN (gs_review_report, gs_pipeline, gs_email_off, gs_review_off, gs_env_disp,
      gs_script_cov_report, gs_script_cov_beg_status, gs_script_cov_end_status, gs_app_dtl_report))
     ORDER BY doi.environment_id
     HEAD REPORT
      doi_cnt = 0
     HEAD doi.environment_id
      doi_cnt = (doi_cnt+ 1)
      IF (doi_cnt > size(dm2_environments->envlist,5))
       stat = alterlist(dm2_environments->envlist,(doi_cnt+ 20))
      ENDIF
      dm2_environments->envlist[doi_cnt].environment_id = doi.environment_id
     DETAIL
      CASE (doi.info_name)
       OF gs_review_report:
        dm2_environments->envlist[doi_cnt].environment_name = doi.info_char,
        IF (doi.environment_id=gf_dummy_env_id
         AND (dm2_debug_review->write_to_test_env=1))
         dm2_environments->envlist[doi_cnt].report_ind = 1
        ELSE
         dm2_environments->envlist[doi_cnt].report_ind = cnvtint(doi.info_value)
        ENDIF
        ,
        IF (doi.environment_id=cur_env_id)
         cur_env_name = doi.info_char
        ENDIF
       OF gs_env_disp:
        IF (doi.environment_id=gf_dummy_env_id
         AND (dm2_debug_review->write_to_test_env=1))
         dm2_environments->envlist[doi_cnt].disp_env_ind = 1
        ELSE
         dm2_environments->envlist[doi_cnt].disp_env_ind = cnvtint(doi.info_value)
        ENDIF
       OF gs_pipeline:
        dm2_environments->envlist[doi_cnt].pipeline = doi.info_char,
        IF (doi.environment_id=cur_env_id)
         cur_pipeline = doi.info_char
        ENDIF
       OF gs_email_off:
        dm2_environments->envlist[doi_cnt].email_off_ind = cnvtint(doi.info_value),
        IF (doi.environment_id=cur_env_id)
         review_email_off = cnvtint(doi.info_value)
        ENDIF
       OF gs_review_off:
        dm2_environments->envlist[doi_cnt].process_off_ind = cnvtint(doi.info_value),
        IF (doi.environment_id=cur_env_id)
         review_process_off = cnvtint(doi.info_value), review_off_found_ind = 1
        ENDIF
       OF gs_script_cov_report:
        dm2_environments->envlist[doi_cnt].script_coverage_ind = cnvtint(doi.info_value),
        dm2_environments->envlist[doi_cnt].script_cov_date = doi.info_dt_tm
       OF gs_script_cov_beg_status:
        dm2_environments->envlist[doi_cnt].script_cov_begin_status = trim(doi.info_char,3)
       OF gs_script_cov_end_status:
        dm2_environments->envlist[doi_cnt].script_cov_end_status = trim(doi.info_char,3)
       OF gs_app_dtl_report:
        dm2_environments->envlist[doi_cnt].app_exec_crash_ind = cnvtint(doi.info_value)
      ENDCASE
     FOOT  doi.environment_id
      stat = alterlist(dm2_environments->envlist,doi_cnt)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->eproc,dm_err->logfile,0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (review_off_found_ind=0)
    SET review_process_off = 1.0
    SET review_email_off = 1.0
    SET dm_err->err_ind = 1
    SET dm_err->emsg = build("'DM_REVIEW_OFF' not found for this environment (",cur_env_id,")")
   ENDIF
  ENDIF
  IF ((dm_err->err_ind=1))
   RETURN(0)
  ELSE
   RETURN(1)
  ENDIF
 END ;Subroutine
 SUBROUTINE sbr_begin_scan_stamp(ps_process_name)
   DECLARE mf_next_id = f8 WITH protect, noconstant(0.0)
   DECLARE ms_logname = vc WITH protect, noconstant(" ")
   SELECT INTO "nl:"
    pf_next_id = seq(dm2_dar_seq,nextval)
    FROM dual d
    DETAIL
     mf_next_id = pf_next_id
    WITH counter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   ENDIF
   IF (validate(dm_err->logfile)=1)
    SET ms_logname = dm_err->logfile
   ELSE
    SET ms_logname = "No Log File"
   ENDIF
   IF (mf_next_id > 0.0)
    INSERT  FROM dm_scanner_log dsl
     SET dsl.scanner_log_id = mf_next_id, dsl.environment_id = cur_env_id, dsl.process_name =
      ps_process_name,
      dsl.beg_dt_tm_stamp = format(sysdate,";;q"), dsl.logfile_name = ms_logname
     WITH counter
    ;end insert
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    ENDIF
    COMMIT
   ENDIF
   RETURN(mf_next_id)
 END ;Subroutine
 SUBROUTINE sbr_end_scan_stamp(pf_scanner_log_id)
   DECLARE ms_begin_dt_tm = vc WITH protect, noconstant(" ")
   DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
   DECLARE mf_process_time = f8 WITH protect, noconstant(0.0)
   DECLARE ms_logname = vc WITH protect, noconstant(" ")
   DECLARE ms_process_name = vc WITH protect, noconstant(" ")
   DECLARE mf_environment_id = f8 WITH protect, noconstant(0.0)
   DECLARE ms_email_subject = vc WITH protect, noconstant(" ")
   DECLARE ms_print_str = vc WITH procect, noconstant(" ")
   UPDATE  FROM dm_scanner_log dsl
    SET dsl.end_dt_tm_stamp = format(sysdate,";;q")
    WHERE dsl.scanner_log_id=pf_scanner_log_id
    WITH counter
   ;end update
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   COMMIT
   SELECT INTO "nl:"
    FROM dm_scanner_log dsl
    WHERE dsl.scanner_log_id=pf_scanner_log_id
    DETAIL
     ms_begin_dt_tm = dsl.beg_dt_tm_stamp, ms_end_dt_tm = dsl.end_dt_tm_stamp, ms_logname = dsl
     .logfile_name,
     ms_process_name = dsl.process_name, mf_environment_id = dsl.environment_id
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   SET mf_process_time = datetimediff(cnvtdatetime(ms_end_dt_tm),cnvtdatetime(ms_begin_dt_tm),4)
   IF (mf_process_time > 60)
    SELECT INTO "dm2_dar_long_exec_email.txt"
     FROM (dummyt d  WITH seq = 1)
     PLAN (d)
     HEAD REPORT
      col 0, "This email is to notify you that", col + 1,
      ms_process_name, col + 1, "has taken",
      ms_print_str = trim(format(mf_process_time,"########.##"),3), col + 1, ms_print_str,
      col + 1, "minutes to execute.", row + 2,
      col 0, "Output from DM_SCANNER_LOG table:", row + 1,
      col 0, "=================================", row + 2,
      col 0, "SCANNER_LOG_ID", col 16,
      "ENVIRONMENT_ID", col 32, "PROCESS_NAME",
      col 46, "BEG_DT_TM_STAMP", col 71,
      "END_DT_TM_STAMP", col 96, "LOGFILE_NAME",
      row + 1, ms_print_str = trim(format(pf_scanner_log_id,"#############.#"),3), col 0,
      ms_print_str, ms_print_str = trim(format(mf_environment_id,"#############.#"),3), col 16,
      ms_print_str, col 32, ms_process_name,
      col 46, ms_begin_dt_tm, col 71,
      ms_end_dt_tm, col 96, ms_logname,
      row + 2, col 0, "SQL statement to access the above row:",
      row + 1, col 0, "======================================",
      row + 2, col 0, "select * from dm_scanner_log where scanner_log_id =",
      ms_print_str = trim(format(pf_scanner_log_id,"#############.#"),3), col + 1, ms_print_str,
      col + 1, "go"
     WITH nocounter, format = variable
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET ms_email_subject = concat("Excessive Execution Time - ",cur_env_name," - ",ms_process_name)
    EXECUTE email "DataAccessReview@cerner.com", " ", value(ms_email_subject),
    "dm2_dar_long_exec_email.txt"
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    SET stat = remove("dm2_dar_long_exec_email.txt")
    IF (stat=0)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE mn_size = i2 WITH protect, constant(10)
 DECLARE mn_explain_start = i2 WITH protect, constant(35)
 DECLARE mn_explain_size = i2 WITH protect, constant(28)
 DECLARE mf_solution_alpha_env_id = f8 WITH protect, constant(10001151.0)
 DECLARE mf_integr8_aix_env_id = f8 WITH protect, constant(20001151.0)
 DECLARE ms_analyzed_status = vc WITH protect, noconstant(" ")
 DECLARE mn_record_defined = i2 WITH protect, noconstant(0)
 DECLARE mn_edit_display = i2 WITH protect, noconstant(1)
 DECLARE mn_edit_object = i2 WITH protect, noconstant(1)
 DECLARE mc_choice = c1 WITH protect, noconstant(" ")
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_total = i4 WITH protect, noconstant(0)
 DECLARE ml_start = i4 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE mn_stat = i2 WITH protect, noconstant(0)
 DECLARE ms_old_connect_str = vc WITH protect, noconstant(" ")
 DECLARE ms_new_connect_str = vc WITH protect, noconstant(" ")
 DECLARE ms_asterisk_line = vc WITH protect, constant(fillstring(120,"*"))
 DECLARE ms_temp_filename = vc WITH protect, noconstant(" ")
 DECLARE sbr_print_report_header(no_parameters) = null
 DECLARE sbr_draw_message_box(ps_header,ps_message_text) = null
 DECLARE sbr_analysis_error(ps_error=vc) = i2
 SET dm_err->eproc = "Validating the m_script_analysis record structure"
 CALL disp_msg(" ",dm_err->logfile,0)
 IF (validate(m_script_analysis)=0)
  SET mn_record_defined = 0
  RECORD m_script_analysis(
    1 s_input_display = vc
    1 s_input_script_name = vc
    1 s_output_filename = vc
    1 s_output_error_msg = vc
    1 n_output_status = i2
  ) WITH protect
  SET m_script_analysis->s_input_display = ""
  SET m_script_analysis->s_input_script_name = ""
  SET m_script_analysis->n_output_status = 1
  SET m_script_analysis->s_output_error_msg = ""
  SET m_script_analysis->s_output_filename = ""
 ELSE
  SET mn_record_defined = 1
  SET m_script_analysis->n_output_status = 1
  SET m_script_analysis->s_output_error_msg = ""
  SET m_script_analysis->s_output_filename = ""
 ENDIF
 SET dm_err->eproc = "Checking user group"
 CALL disp_msg(" ",dm_err->logfile,0)
 IF (curgroup != 0)
  SET m_script_analysis->n_output_status = 0
  SET m_script_analysis->s_output_error_msg =
  " User group must be DBA in order to run dm_script_analysis."
  CALL disp_msg("User does not have DBA privileges.  Program exiting.",dm_err->logfile,1)
  CALL sbr_analysis_error(m_script_analysis->s_output_error_msg)
  GO TO exit_program
 ENDIF
 SET realtime_flag = 1
 IF (mn_record_defined=1)
  GO TO end_menu_ui
 ENDIF
 SET dm_err->eproc = "BEGIN build the menu"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET accept = nopatcheck
 SET message = window
 SET message = noinformation
 CALL video(l)
 CALL clear(1,1)
 CALL box(1,1,23,80)
 CALL text(2,3,cur_env_name)
 CALL text(2,30,"Data Access Review")
 CALL text(2,59,format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 CALL text(3,3,concat("EnvID: ",cnvtstring(cur_env_id)))
 CALL text(3,28,"DM Script Analysis Tool")
 CALL text(3,60,format(curuser,"###################;R"))
 CALL line(4,1,80,xhor)
 CALL text(5,3,"1)  *Display            :")
 CALL text(6,3,"2)  *Script Object Name :")
 SET dm_err->eproc = "BEGIN collect menu data"
 CALL disp_msg(" ",dm_err->logfile,0)
#input_display
 IF (mn_edit_display=1)
  CALL clear(24,2,70)
  CALL text(24,2,"Select a display type. 'MINE' or 'FILE'")
  CALL clear(5,30,40)
  CALL accept(5,30,"P(4);CU","MINE"
   WHERE curaccept IN ("MINE", "FILE"))
  SET m_script_analysis->s_input_display = curaccept
  CALL clear(5,30,34)
  CALL text(5,30,m_script_analysis->s_input_display)
 ENDIF
#input_object_name
 IF (mn_edit_object=1)
  CALL clear(24,2,70)
  CALL text(24,2,"Enter the Object Name. (Wildcards not accepted)")
  WHILE ((m_script_analysis->s_input_script_name=""))
    CALL clear(6,30,40)
    CALL accept(6,30,"P(30);CU"," ")
    SET m_script_analysis->s_input_script_name = trim(curaccept)
  ENDWHILE
  CALL clear(6,30,40)
  CALL text(6,30,m_script_analysis->s_input_script_name)
 ENDIF
 SET mn_edit_display = 0
 SET mn_edit_object = 0
 CALL clear(24,1,79)
 CALL text(24,3,"Choice-> ")
 CALL text(24,16,"(C)ancel, (E)xecute, (Line Number) To Modify")
 CALL accept(24,12,"P;CU","E"
  WHERE trim(curaccept) IN ("C", "E", "1", "2"))
 SET mc_choice = trim(curaccept)
 CASE (mc_choice)
  OF "C":
   GO TO exit_program
  OF "1":
   SET mn_edit_display = 1
   SET m_script_analysis->s_input_display = " "
   GO TO input_display
  OF "2":
   SET mn_edit_object = 1
   SET m_script_analysis->s_input_script_name = " "
   GO TO input_object_name
 ENDCASE
 SET dm_err->eproc = "END collect menu data"
 CALL disp_msg(" ",dm_err->logfile,0)
 CALL clear(24,1,79)
 CALL video(b)
 CALL text(24,3,"Processing...")
 CALL video(n)
 CALL video(l)
#end_menu_ui
 IF ((m_script_analysis->s_input_display="FILE"))
  SET dm_err->eproc = "Creating unique file for output"
  CALL disp_msg(" ",dm_err->logfile,0)
  CALL get_unique_file("dm_scr_analysis",".txt")
  SET m_script_analysis->s_output_filename = dm_err->unique_fname
 ENDIF
 IF ((m_script_analysis->s_input_display != "FILE")
  AND (m_script_analysis->s_input_display != "MINE"))
  SET m_script_analysis->n_output_status = 0
  SET m_script_analysis->s_output_error_msg = concat("Failed to validate display type, ",
   m_script_analysis->s_input_display,".  The display type must be 'MINE' or 'FILE'.")
  CALL disp_msg(m_script_analysis->s_output_error_msg,dm_err->logfile,1)
  CALL sbr_analysis_error(m_script_analysis->s_output_error_msg)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = concat("Validating the object(",m_script_analysis->s_input_script_name,")...")
 CALL disp_msg(" ",dm_err->logfile,0)
 IF (((findstring("*",patstring(m_script_analysis->s_input_script_name)) != 0) OR (findstring("?",
  patstring(m_script_analysis->s_input_script_name)) != 0)) )
  IF (mn_record_defined=0)
   CALL sbr_draw_message_box("No wildcards",
    "** Wildcards are not supported for Script Object Name. **")
   SET m_script_analysis->s_input_script_name = ""
   SET mn_edit_object = 1
   GO TO input_object_name
  ELSE
   SET m_script_analysis->n_output_status = 0
   SET m_script_analysis->s_output_error_msg = concat("Failed to validate object, ",m_script_analysis
    ->s_input_script_name,".  Wildcards are not supported for Script Object Name.")
   CALL disp_msg(m_script_analysis->s_output_error_msg,dm_err->logfile,1)
   CALL sbr_analysis_error(m_script_analysis->s_output_error_msg)
   GO TO exit_program
  ENDIF
 ELSE
  SET dm_err->eproc = "Checking if object exists on the dprotect table"
  CALL disp_msg(" ",dm_err->logfile,0)
  SELECT INTO "nl:"
   FROM dprotect d
   WHERE d.object="P"
    AND (d.object_name=m_script_analysis->s_input_script_name)
    AND d.group=0
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   SET m_script_analysis->n_output_status = 0
   SET m_script_analysis->s_output_error_msg = concat(
    " DM_SCRIPT_ANALYSIS encountered an error and will exit.  ",
    "Contact the Data Access Review team for further assistance and reference ","log file: ",dm_err->
    logfile)
   CALL disp_msg("Error encountered while selecting from DPROTECT.",dm_err->logfile,1)
   CALL sbr_analysis_error(m_script_analysis->s_output_error_msg)
   GO TO exit_program
  ENDIF
  IF (curqual=0)
   IF (mn_record_defined=0)
    CALL sbr_draw_message_box("Invalid Object Name",concat(" Script Object Name must be a valid ",
      "object in the data dictionary having Group 0 (DBA)."))
    SET m_script_analysis->s_input_script_name = ""
    SET mn_edit_object = 1
    GO TO input_object_name
   ELSE
    SET m_script_analysis->n_output_status = 0
    SET m_script_analysis->s_output_error_msg = concat("Failed to validate object, ",
     m_script_analysis->s_input_script_name,".   Script Object Name must be a valid ",
     "object in the data dictionary having Group 0 (DBA).")
    CALL disp_msg(m_script_analysis->s_output_error_msg,dm_err->logfile,1)
    CALL sbr_analysis_error(m_script_analysis->s_output_error_msg)
    GO TO exit_program
   ENDIF
  ENDIF
 ENDIF
 SET dm_err->eproc = "Retrieving environment information..."
 CALL disp_msg(" ",dm_err->logfile,0)
 IF (((((currev * 10000)+ (currevminor * 100))+ currevminor2) < 080300))
  SET m_script_analysis->n_output_status = 0
  SET m_script_analysis->s_output_error_msg = concat(" CCL version is ",build(curcclrev,
    ".  DM_SCRIPT_ANAYLSIS"),
   " can only be run on CCL version 8.3 or greater.  Contact the Data Access Review team",
   " for further assistance and reference log file: ",dm_err->logfile,
   ".")
  CALL disp_msg(m_script_analysis->s_output_error_msg,dm_err->logfile,1)
  CALL sbr_analysis_error(m_script_analysis->s_output_error_msg)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Retrieve DB_LINK from dba_db_links"
 CALL disp_msg(" ",dm_err->logfile,0)
 IF ( NOT (mf_cur_env_id IN (mf_solution_alpha_env_id, mf_integr8_aix_env_id)))
  SELECT INTO "nl:"
   FROM dba_db_links ddl
   WHERE ddl.db_link="SOLT1.WORLD"
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   SET m_script_analysis->n_output_status = 0
   SET m_script_analysis->s_output_error_msg = concat(
    " DM_SCRIPT_ANALYSIS encountered an error and will exit.  ",
    "Contact the Data Access Review team for further assistance and reference ","log file: ",dm_err->
    logfile)
   CALL disp_msg("Error encountered while retrieving information from DBA_DB_LINKS.",dm_err->logfile,
    1)
   CALL sbr_analysis_error(m_script_analysis->s_output_error_msg)
   GO TO exit_program
  ENDIF
  IF (curqual=0)
   SET m_script_analysis->n_output_status = 0
   SET m_script_analysis->s_output_error_msg = concat(
    " DM_SCRIPT_ANALYSIS encountered an error and will exit.  ",
    "Unable to obtain connection to remote database.  ",
    "Contact the Data Access Review team for further assistance and reference ","log file: ",dm_err->
    logfile)
   CALL disp_msg("No DB_LINK to SOLUTION_ALPHA could be retrieved.",dm_err->logfile,1)
   CALL sbr_analysis_error(m_script_analysis->s_output_error_msg)
   GO TO exit_program
  ENDIF
  SET dm_err->eproc = "Retrieve current connect string"
  CALL disp_msg(" ",dm_err->logfile,0)
  SELECT INTO "nl:"
   FROM dm_environment d
   WHERE d.environment_id=mf_cur_env_id
   DETAIL
    ms_old_connect_str = trim(d.v500_connect_string)
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   SET m_script_analysis->n_output_status = 0
   SET m_script_analysis->s_output_error_msg = concat(
    " DM_SCRIPT_ANALYSIS encountered an error and will exit.  ",
    "Contact the Data Access Review team for further assistance and reference ","log file: ",dm_err->
    logfile)
   CALL disp_msg("Error encountered while retrieving information from DM_ENVIRONMENT.",dm_err->
    logfile,1)
   CALL sbr_analysis_error(m_script_analysis->s_output_error_msg)
   GO TO exit_program
  ENDIF
  IF (ms_old_connect_str=" ")
   SET m_script_analysis->n_output_status = 0
   SET m_script_analysis->s_output_error_msg = concat(
    " Unable to obtain connection to remote database.  ",
    "Contact the Data Access Review team for further assistance and reference ","log file: ",dm_err->
    logfile)
   CALL disp_msg("Unable to retrieve the connect string for the current environment.",dm_err->logfile,
    1)
   CALL sbr_analysis_error(m_script_analysis->s_output_error_msg)
   GO TO exit_program
  ENDIF
  SELECT INTO "nl:"
   FROM dm_environment d
   WHERE d.environment_id=mf_solution_alpha_env_id
   DETAIL
    ms_new_connect_str = trim(d.v500_connect_string)
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   SET m_script_analysis->n_output_status = 0
   SET m_script_analysis->s_output_error_msg = concat(
    " DM_SCRIPT_ANALYSIS encountered an error and will exit.  ",
    "Contact the Data Access Review team for further assistance and reference ","log file: ",dm_err->
    logfile)
   CALL disp_msg("Error encountered while retrieving information from DM_ENVIRONMENT 2.",dm_err->
    logfile,1)
   CALL sbr_analysis_error(m_script_analysis->s_output_error_msg)
   GO TO exit_program
  ENDIF
  IF (ms_new_connect_str=" ")
   SET m_script_analysis->n_output_status = 0
   SET m_script_analysis->s_output_error_msg = concat(
    " Unable to obtain connection to remote database.  ",
    "Contact the Data Access Review team for further assistance and reference ","log file: ",dm_err->
    logfile)
   CALL disp_msg("Unable to retrieve the connect string for SOLUTION_ALPHA.",dm_err->logfile,1)
   CALL sbr_analysis_error(m_script_analysis->s_output_error_msg)
   GO TO exit_program
  ENDIF
  SET dm_err->eproc = "Attempting to connect to database"
  CALL disp_msg(" ",dm_err->logfile,0)
  FREE DEFINE oraclesystem
  IF (dm2_push_cmd(concat('define oraclesystem "',ms_new_connect_str,'" go'),1)=0)
   SET m_script_analysis->n_output_status = 0
   SET m_script_analysis->s_output_error_msg = concat(
    " DM_SCRIPT_ANALYSIS encountered an error and will exit.  ",
    "Contact the Data Access Review team for further assistance and reference ","log file: ",dm_err->
    logfile)
   CALL disp_msg("An error was encountered while attempting to connect to database.",dm_err->logfile,
    1)
   CALL sbr_analysis_error(m_script_analysis->s_output_error_msg)
   GO TO exit_program
  ENDIF
 ENDIF
 SET dm_err->eproc = "Executing DM_SCRIPT_SCANNER..."
 CALL disp_msg(" ",dm_err->logfile,0)
 EXECUTE dm_script_scanner value(m_script_analysis->s_input_script_name), 0
 IF (check_error(dm_err->eproc)=1)
  SET m_script_analysis->n_output_status = 0
  SET m_script_analysis->s_output_error_msg = concat(
   " DM_SCRIPT_ANALYSIS encountered an error and will exit.  ",
   "Contact the Data Access Review team for further assistance and reference ","log file: ",dm_err->
   logfile)
  CALL disp_msg("Error encountered while executing dm_script_scanner.",dm_err->logfile,1)
  CALL sbr_analysis_error(m_script_analysis->s_output_error_msg)
  GO TO exit_program
 ENDIF
 IF ((m_plan_table->l_plan_list_cnt > 0))
  SET dm_err->eproc = "Retrieving SQL text for the explain plans..."
  CALL disp_msg(" ",dm_err->logfile,0)
  SET ml_total = (ceil((cnvtreal(m_plan_table->l_plan_list_cnt)/ mn_size)) * mn_size)
  SET mn_stat = alterlist(m_plan_table->plan_list,ml_total)
  SET ml_start = 1
  FOR (ml_idx = (m_plan_table->l_plan_list_cnt+ 1) TO ml_total)
    SET m_plan_table->plan_list[ml_idx].s_statement_id = m_plan_table->plan_list[m_plan_table->
    l_plan_list_cnt].s_statement_id
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value((1+ ((ml_total - 1)/ mn_size)))),
    v$sql vs,
    v$sqltext vst
   PLAN (d1
    WHERE initarray(ml_start,evaluate(d1.seq,1,1,(ml_start+ mn_size))))
    JOIN (vs
    WHERE expand(ml_num,ml_start,(ml_start+ (mn_size - 1)),substring(mn_explain_start,mn_explain_size,
      vs.sql_text),m_plan_table->plan_list[ml_num].s_statement_id,
     mn_size))
    JOIN (vst
    WHERE vst.hash_value=vs.hash_value
     AND vst.address=vs.address)
   ORDER BY vs.hash_value, vs.first_load_time, vst.piece
   HEAD REPORT
    pl_plan_idx = 0
   DETAIL
    pl_plan_idx = locateval(ml_num,1,m_plan_table->l_plan_list_cnt,substring(mn_explain_start,
      mn_explain_size,vs.sql_text),m_plan_table->plan_list[ml_num].s_statement_id), m_plan_table->
    plan_list[pl_plan_idx].l_sql_piece_cnt = (m_plan_table->plan_list[pl_plan_idx].l_sql_piece_cnt+ 1
    ), mn_stat = alterlist(m_plan_table->plan_list[pl_plan_idx].sql_piece,m_plan_table->plan_list[
     pl_plan_idx].l_sql_piece_cnt),
    m_plan_table->plan_list[pl_plan_idx].sql_piece[m_plan_table->plan_list[pl_plan_idx].
    l_sql_piece_cnt].s_sql_text = vst.sql_text
   WITH nocounter
  ;end select
  SET mn_stat = alterlist(m_plan_table->plan_list,m_plan_table->l_plan_list_cnt)
  IF (check_error(dm_err->eproc)=1)
   SET m_script_analysis->n_output_status = 0
   SET m_script_analysis->s_output_error_msg = concat(
    " DM_SCRIPT_ANALYSIS encountered an error and will exit.  ",
    "Contact the Data Access Review team for further assistance and reference ","log file: ",dm_err->
    logfile)
   CALL disp_msg("Error encountered while selecting from V$SQL.",dm_err->logfile,1)
   CALL sbr_analysis_error(m_script_analysis->s_output_error_msg)
   GO TO exit_program
  ENDIF
 ENDIF
 SET dm_err->eproc = "Printing report..."
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT
  IF ((m_script_analysis->s_input_display="FILE"))INTO build("ccluserdir:",m_script_analysis->
    s_output_filename)
  ELSE
  ENDIF
  FROM dummyt
  HEAD REPORT
   CALL sbr_print_report_header(0)
   IF ((dm_script_scanner_reply->fail_ind=1))
    ms_analyzed_status = ms_warning
    FOR (pl_cur_error = 1 TO ml_err_list_size)
     pl_cur_status = ((dm_script_scanner_reply->err_list[pl_cur_error].fail_number - ml_min_error_num
     )+ 1),
     IF ((m_error_struct->error_list[pl_cur_status].s_error_status=ms_failed))
      ms_analyzed_status = ms_failed
     ENDIF
    ENDFOR
   ELSE
    ms_analyzed_status = ms_success
   ENDIF
  DETAIL
   row + 1, col 0, "  Script Scanner Results:",
   row + 1, col 0, "  STATUS:",
   col + 1, ms_analyzed_status, row + 2
   IF (ms_analyzed_status="SUCCESS")
    col 0, "  No errors reported for this script."
   ELSE
    FOR (pl_cur_err = 1 TO ml_err_list_size)
      col 2, dm_script_scanner_reply->err_list[pl_cur_err].fail_message, row + 1
    ENDFOR
   ENDIF
   row + 2, col 0, ms_asterisk_line
   IF (((m_table_access_rec->list[1].l_num_table+ m_table_access_rec->list[2].l_num_table) > 0))
    row + 1, col 0, "Insert Tables: ",
    row + 1
    FOR (pl_cur_insert_tab = 1 TO m_table_access_rec->list[2].l_num_table)
      IF ((m_table_access_rec->list[2].table_list[pl_cur_insert_tab].n_operation_type=mn_insert))
       col 2, m_table_access_rec->list[2].table_list[pl_cur_insert_tab].s_table_name, row + 1
      ENDIF
    ENDFOR
    row + 1, col 0, "Update Tables: ",
    row + 1
    FOR (pl_cur_update_tab = 1 TO m_table_access_rec->list[2].l_num_table)
      IF ((m_table_access_rec->list[2].table_list[pl_cur_update_tab].n_operation_type=mn_update))
       col 2, m_table_access_rec->list[2].table_list[pl_cur_update_tab].s_table_name, row + 1
      ENDIF
    ENDFOR
    row + 1, col 0, "Delete Tables: ",
    row + 1
    FOR (pl_cur_delete_tab = 1 TO m_table_access_rec->list[2].l_num_table)
      IF ((m_table_access_rec->list[2].table_list[pl_cur_delete_tab].n_operation_type=mn_delete))
       col 2, m_table_access_rec->list[2].table_list[pl_cur_delete_tab].s_table_name, row + 1
      ENDIF
    ENDFOR
    row + 1, col 0, "Select Tables: ",
    row + 1
    FOR (pl_cur_select_tab = 1 TO m_table_access_rec->list[1].l_num_table)
      col 2, m_table_access_rec->list[1].table_list[pl_cur_select_tab].s_table_name, row + 1
    ENDFOR
   ENDIF
   IF ((m_index_usage->l_index_cnt > 0))
    row + 1, col 0, "Indexes Utilized: ",
    row + 1, col 0, "Table Name: ",
    col 30, "Index Name: ", row + 1
    FOR (pl_cur_index = 1 TO m_index_usage->l_index_cnt)
      col 0, m_index_usage->index_list[pl_cur_index].s_table_name, col 30,
      m_index_usage->index_list[pl_cur_index].s_index_name, row + 1
    ENDFOR
   ENDIF
   IF ((m_plan_table->l_plan_list_cnt > 0))
    row + 1, col 0, ms_asterisk_line,
    row + 1, col 0, "SQL Statements: ",
    row + 1, col 0, "-----------------------"
    FOR (pl_cur_plan = 1 TO m_plan_table->l_plan_list_cnt)
      row + 1, col 0, "Optimizer: ",
      col + 1, m_plan_table->plan_list[pl_cur_plan].s_optimizer_mode, row + 1,
      col 0, "Cost: ", col + 1,
      m_plan_table->plan_list[pl_cur_plan].f_cost
      FOR (pl_cur_sql = 1 TO m_plan_table->plan_list[pl_cur_plan].l_sql_piece_cnt)
        IF (mod(pl_cur_sql,2)=1)
         row + 1, col 0, m_plan_table->plan_list[pl_cur_plan].sql_piece[pl_cur_sql].s_sql_text
        ELSE
         col + 1, m_plan_table->plan_list[pl_cur_plan].sql_piece[pl_cur_sql].s_sql_text
        ENDIF
      ENDFOR
      row + 1
    ENDFOR
   ENDIF
  FOOT REPORT
   col 0, ms_asterisk_line, row + 1,
   col 2, "END OF REPORT", row + 1,
   col 0, ms_asterisk_line
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  SET m_script_analysis->n_output_status = 0
  SET m_script_analysis->s_output_error_msg = concat(
   " DM_SCRIPT_ANALYSIS encountered an error and will exit.  ",
   "Contact the Data Access Review team for further assistance and reference ","log file: ",dm_err->
   logfile)
  CALL disp_msg("Error encountered while generating report.",dm_err->logfile,1)
  CALL sbr_analysis_error(m_script_analysis->s_output_error_msg)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Finished printing report"
 CALL disp_msg(" ",dm_err->logfile,0)
 IF ((m_script_analysis->s_input_display="FILE"))
  SET dm_err->eproc = "Updating the output file`s permissions"
  CALL disp_msg(" ",dm_err->logfile,0)
  IF (cursys="AXP")
   IF (findfile(m_script_analysis->s_output_filename)=1)
    CALL dm2_push_dcl(concat("set file/prot=(s:RWED,o:RWED,g:RWED,w:RWED) ccluserdir:",
      m_script_analysis->s_output_filename,";*"))
   ENDIF
  ELSE
   IF (findfile(m_script_analysis->s_output_filename)=1)
    CALL dm2_push_dcl(concat("chmod 777 $CCLUSERDIR/",m_script_analysis->s_output_filename))
   ENDIF
  ENDIF
  IF (check_error(dm_err->eproc)=1)
   SET m_script_analysis->n_output_status = 0
   SET m_script_analysis->s_output_error_msg = concat(
    " DM_SCRIPT_ANALYSIS encountered an error and will exit.  ",
    "Contact the Data Access Review team for further assistance and reference ","log file: ",dm_err->
    logfile)
   CALL disp_msg("Error encountered while updating the output file`s permissions.",dm_err->logfile,1)
   CALL sbr_analysis_error(m_script_analysis->s_output_error_msg)
   GO TO exit_program
  ENDIF
  SET dm_err->eproc = concat("REPORT FILENAME : ",m_script_analysis->s_output_filename)
  CALL disp_msg(" ",dm_err->logfile,0)
 ENDIF
 SUBROUTINE sbr_print_report_header(no_parameters)
   CALL print(ms_asterisk_line)
   CALL reportmove("R",1,1)
   CALL print(cur_env_name)
   CALL reportmove("C",50,0)
   CALL print("Data Access Review")
   CALL reportmove("C",100,0)
   CALL print(format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
   CALL reportmove("R",1,1)
   CALL print(build("EnvID:",concat(" ",cnvtstring(cur_env_id))))
   CALL reportmove("C",48,0)
   CALL print("Script Analysis Report")
   CALL reportmove("C",101,0)
   CALL print(format(curuser,"###################;R"))
   CALL reportmove("R",1,1)
   CALL print(ms_asterisk_line)
   CALL reportmove("R",2,1)
   CALL print(concat("Script Name: ",m_script_analysis->s_input_script_name))
   CALL reportmove("R",1,1)
 END ;Subroutine
 SUBROUTINE sbr_draw_message_box(ps_header,ps_message_text)
   DECLARE ps_message_trimmed = vc WITH private, constant(trim(ps_message_text,3))
   DECLARE pl_message_segment_size = i4 WITH private, constant(57)
   DECLARE pn_message_start_col = i2 WITH private, constant(12)
   DECLARE pn_message_start_row = i2 WITH private, constant(12)
   DECLARE pn_message_end_row = i2 WITH private, constant(15)
   DECLARE pn_pos_screen_center = i2 WITH private, constant(40)
   DECLARE pn_loop_num = i2 WITH private, noconstant(0)
   DECLARE pn_finished_printing_ind = i2 WITH private, noconstant(0)
   DECLARE pl_start_pos = i4 WITH private, noconstant(1)
   DECLARE pl_end_pos = i4 WITH private, noconstant(0)
   DECLARE mn_clear_box = i2 WITH protect, noconstant(1)
   SET pn_loop_num = 9
   WHILE (pn_loop_num <= 19)
    CALL clear(pn_loop_num,10,61)
    SET pn_loop_num = (pn_loop_num+ 1)
   ENDWHILE
   CALL box(9,10,19,70)
   CALL text(10,(pn_pos_screen_center - (textlen(ps_header)/ 2)),ps_header)
   SET pn_loop_num = pn_message_start_row
   WHILE (pn_loop_num <= pn_message_end_row
    AND pn_finished_printing_ind=0)
     SET pl_start_pos = (pl_end_pos+ 1)
     SET pl_end_pos = ((pl_start_pos+ pl_message_segment_size) - 1)
     WHILE (substring(pl_start_pos,1,ps_message_trimmed)=" ")
       SET pl_start_pos = (pl_start_pos+ 1)
     ENDWHILE
     IF (((((textlen(ps_message_trimmed) - pl_start_pos) < pl_message_segment_size)) OR (pn_loop_num=
     pn_message_end_row)) )
      SET pl_end_pos = ((pl_start_pos+ pl_message_segment_size) - 1)
      SET pn_finished_printing_ind = 1
     ELSE
      IF (substring((pl_start_pos+ pl_message_segment_size),1,ps_message_trimmed)=" ")
       SET pl_end_pos = ((pl_start_pos+ pl_message_segment_size) - 1)
      ELSE
       SET pl_end_pos = findstring(" ",substring(pl_start_pos,pl_message_segment_size,
         ps_message_trimmed),1,1)
       IF (pl_end_pos=0)
        SET pl_end_pos = ((pl_start_pos+ pl_message_segment_size) - 1)
       ELSE
        SET pl_end_pos = ((pl_start_pos+ pl_end_pos) - 1)
       ENDIF
      ENDIF
     ENDIF
     CALL text(pn_loop_num,pn_message_start_col,substring(pl_start_pos,((pl_end_pos - pl_start_pos)+
       1),ps_message_trimmed))
     SET pn_loop_num = (pn_loop_num+ 1)
   ENDWHILE
   IF (pl_end_pos < textlen(ps_message_trimmed))
    CALL text(15,((pn_message_start_col+ pl_message_segment_size) - 3),"...")
   ENDIF
   CALL text(17,pn_message_start_col,"Press Enter to Continue")
   CALL accept(17,38,"P"," ")
   SET num = 9
   WHILE (num <= 20)
    CALL clear(num,10,64)
    SET num = (num+ 1)
   ENDWHILE
 END ;Subroutine
 SUBROUTINE sbr_analysis_error(ps_error)
   DECLARE ml_error_length = i4 WITH protect, constant(textlen(ps_error))
   SET dm_err->err_ind = 0
   SELECT
    IF ((m_script_analysis->s_input_display="FILE"))INTO build("ccluserdir:",m_script_analysis->
      s_output_filename)
    ELSE
    ENDIF
    FROM dummyt
    HEAD REPORT
     col 0, "ERROR found while processing", row + 1
    DETAIL
     IF (ml_error_length > 120)
      ps_error_1 = substring(1,119,ps_error), ps_error_2 = substring(120,119,ps_error)
     ENDIF
     col 0, ms_asterisk_line, row + 1
     IF (ml_error_length > 120)
      col 0, ps_error_1, row + 1,
      col 0, ps_error_2
     ELSE
      col 0, ps_error
     ENDIF
     row + 1, col 0, ms_asterisk_line
    WITH nocounter, maxcol = 121
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET m_script_analysis->n_output_status = 0
    SET m_script_analysis->s_output_error_msg = concat(
     " DM_SCRIPT_ANALYSIS encountered an error and will exit.  ",
     "Contact the Data Access Review team for further assistance and reference ","log file: ",dm_err
     ->logfile)
    CALL disp_msg("Error encountered while generating display for error message.",dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SET dm_err->err_ind = 1
 END ;Subroutine
#exit_program
 IF (ms_old_connect_str != " ")
  FREE DEFINE oraclesystem
  IF (dm2_push_cmd(concat('define oraclesystem "',ms_old_connect_str,'" go'),1)=0)
   SET m_script_analysis->n_output_status = 0
   SET m_script_analysis->s_output_error_msg = concat(
    " DM_SCRIPT_ANALYSIS encountered an error and will exit.  ",
    "Contact the Data Access Review team for further assistance and reference ","log file: ",dm_err->
    logfile)
   CALL disp_msg("An error was encountered while attempting to connect to database.",dm_err->logfile,
    1)
   CALL sbr_analysis_error(m_script_analysis->s_output_error_msg)
  ENDIF
 ENDIF
 SET mn_stat = sbr_bt_defn_cleanup(null)
 SET message = nowindow
 SET message = information
 CALL text(24,1," ")
 IF ((dm_err->err_ind=1))
  SET dm_err->eproc = concat(" Error encountered. ","Reference log file: ",dm_err->logfile)
  CALL disp_msg(" ",dm_err->logfile,0)
 ELSE
  IF ((m_script_analysis->s_input_display="FILE"))
   SET dm_err->eproc = concat("The report can be found at ccluserdir:",m_script_analysis->
    s_output_filename)
   CALL disp_msg(" ",dm_err->logfile,0)
  ENDIF
  SET dm_err->eproc = " DM_SCRIPT_ANALYSIS completed successfully."
  CALL disp_msg(" ",dm_err->logfile,0)
  SET mn_stat = remove(dm_err->logfile)
 ENDIF
END GO
