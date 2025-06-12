CREATE PROGRAM dm_script_scanner:dba
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
 IF (validate(ml_trap_state)=0)
  DECLARE ml_trap_state = i2 WITH protect, constant(999)
  DECLARE ms_select_tag = vc WITH protect, constant("Z_SELECT.")
  DECLARE ms_close_select_tag = vc WITH protect, constant("/Z_SELECT.")
  DECLARE ms_update_tag = vc WITH protect, constant("Z_UPDATE.")
  DECLARE ms_close_update_tag = vc WITH protect, constant("/Z_UPDATE.")
  DECLARE ms_insert_tag = vc WITH protect, constant("Z_INSERT.")
  DECLARE ms_close_insert_tag = vc WITH protect, constant("/Z_INSERT.")
  DECLARE ms_delete_tag = vc WITH protect, constant("Z_DELETE.")
  DECLARE ms_close_delete_tag = vc WITH protect, constant("/Z_DELETE.")
  DECLARE ms_name_tag = vc WITH protect, constant("NAME")
  DECLARE ms_close_name_tag = vc WITH protect, constant("/NAME")
  DECLARE ms_option_tag = vc WITH protect, constant("OPTION.")
  DECLARE ms_close_option_tag = vc WITH protect, constant("/OPTION.")
  DECLARE ms_is_tag = vc WITH protect, constant("IS.")
  DECLARE ms_close_is_tag = vc WITH protect, constant("/IS.")
  DECLARE ms_call_tag = vc WITH protect, constant("CALL.")
  DECLARE ms_close_call_tag = vc WITH protect, constant("/CALL.")
  DECLARE ms_table_tag = vc WITH protect, constant("TABLE.")
  DECLARE ms_close_table_tag = vc WITH protect, constant("/TABLE.")
  DECLARE ms_plan_tag = vc WITH protect, constant("PLAN.")
  DECLARE ms_close_plan_tag = vc WITH protect, constant("/PLAN.")
  DECLARE ms_for_tag = vc WITH protect, constant("FOR.")
  DECLARE ms_close_for_tag = vc WITH protect, constant("/FOR.")
  DECLARE ms_while_tag = vc WITH protect, constant("WHILE.")
  DECLARE ms_close_while_tag = vc WITH protect, constant("/WHILE.")
  DECLARE ms_qual_tag = vc WITH protect, constant("QUAL.")
  DECLARE ms_close_qual_tag = vc WITH protect, constant("/QUAL.")
  DECLARE ms_execute_tag = vc WITH protect, constant("Z_EXECUTE.")
  DECLARE ms_close_execute_tag = vc WITH protect, constant("/Z_EXECUTE.")
  DECLARE ms_user_tag = vc WITH protect, constant("USER.")
  DECLARE ms_close_user_tag = vc WITH protect, constant("/USER.")
  DECLARE ms_string_tag = vc WITH protect, constant("STRING")
  DECLARE ms_close_string_tag = vc WITH protect, constant("/STRING")
  DECLARE ms_or_tag = vc WITH protect, constant("OR.")
  DECLARE ms_close_or_tag = vc WITH protect, constant("/OR.")
  DECLARE ms_and_tag = vc WITH protect, constant("AND.")
  DECLARE ms_close_and_tag = vc WITH protect, constant("/AND.")
  DECLARE ms_comma_tag = vc WITH protect, constant("COMMA.")
  DECLARE ms_close_comma_tag = vc WITH protect, constant("/COMMA.")
  DECLARE ms_seq_text = vc WITH protect, constant("SEQ")
  DECLARE ms_dual_text = vc WITH protect, constant("DUAL")
  DECLARE ms_expand_text = vc WITH protect, constant("EXPAND")
  DECLARE ms_dummyt_text = vc WITH protect, constant("DUMMYT")
  DECLARE ms_outerjoin_text = vc WITH protect, constant("OUTERJOIN")
  DECLARE ms_orahint_text = vc WITH protect, constant("ORAHINT")
  DECLARE ms_cclaudit_text = vc WITH protect, constant("CCLAUDIT")
  DECLARE ms_dontcare_text = vc WITH protect, constant("DONTCARE")
  DECLARE ms_dm_dbimport_text = vc WITH protect, constant("DM_DBIMPORT")
 ENDIF
 IF (validate(ms_tag)=0)
  DECLARE ms_tag = vc WITH protect, noconstant(" ")
  DECLARE ms_element_name = vc WITH protect, noconstant(" ")
 ENDIF
 IF (validate(m_outerjoin_rec->levels)=0)
  FREE RECORD m_outerjoin_rec
  RECORD m_outerjoin_rec(
    1 n_level = i2
    1 levels[*]
      2 n_outerjoin_state = i2
  ) WITH protect
 ENDIF
 IF (validate(m_cclaudit_rec->name_types)=0)
  DECLARE mn_cclaudit_state = i2 WITH protect, noconstant(1)
  FREE RECORD m_cclaudit_rec
  RECORD m_cclaudit_rec(
    1 l_name_type_cnt = i4
    1 name_types[*]
      2 s_name = vc
      2 l_name_nbr = i4
      2 s_type = vc
      2 l_type_nbr = i4
      2 n_event_exists_ind = i2
  ) WITH protect
 ENDIF
 IF (validate(m_orahint_rec->levels)=0)
  FREE RECORD m_orahint_rec
  RECORD m_orahint_rec(
    1 n_level = i2
    1 levels[*]
      2 n_orahint_state = i2
  ) WITH protect
 ENDIF
 IF (validate(m_for_sequence_rec->levels)=0)
  FREE RECORD m_for_sequence_rec
  RECORD m_for_sequence_rec(
    1 n_level = i2
    1 levels[*]
      2 n_for_sequence_state = i2
  ) WITH protect
 ENDIF
 IF (validate(m_multi_expand_rec->levels)=0)
  FREE RECORD m_multi_expand_rec
  RECORD m_multi_expand_rec(
    1 n_level = i2
    1 levels[*]
      2 n_multi_expand_state = i2
  ) WITH protect
 ENDIF
 IF (validate(m_orjoin_rec->levels)=0)
  FREE RECORD m_orjoin_rec
  RECORD m_orjoin_rec(
    1 n_level = i2
    1 levels[*]
      2 n_orjoin_state = i2
      2 l_select_level = i4
      2 n_num_dummyt_alias = i4
      2 dummyts[*]
        3 s_dummyt_alias = vc
  ) WITH protect
 ENDIF
 IF (validate(m_dontcare_rec->levels)=0)
  FREE RECORD m_dontcare_rec
  RECORD m_dontcare_rec(
    1 n_level = i2
    1 levels[*]
      2 n_dontcare_state = i2
  ) WITH protect
 ENDIF
 IF (validate(m_table_access_check_rec->levels)=0)
  FREE RECORD m_table_access_check_rec
  RECORD m_table_access_check_rec(
    1 n_level = i2
    1 levels[*]
      2 s_operation_type = vc
      2 n_table_access_state = i2
  ) WITH protect
 ENDIF
 IF (validate(mn_execute_state)=0)
  DECLARE mn_execute_state = i2 WITH protect, noconstant(1)
  DECLARE mn_dm_dbimport_state = i2 WITH protect, noconstant(1)
 ENDIF
 IF (validate(m_seq_rec->levels)=0)
  RECORD m_seq_rec(
    1 n_seq_state = i2
  ) WITH protect
 ENDIF
 DECLARE sbr_parse_xml(ps_xml_filename=vc) = i2
 DECLARE sbr_parse_table_exec_dependency(ps_xml_filename=vc) = i2
 DECLARE sbr_check_ccl_rule(null) = i2
 DECLARE sbr_check_outerjoin(null) = i2
 DECLARE sbr_check_orahint(null) = i2
 DECLARE sbr_check_for_sequence(null) = i2
 DECLARE sbr_check_multi_expand(null) = i2
 DECLARE sbr_check_orjoin(null) = i2
 DECLARE sbr_check_dontcare(null) = i2
 DECLARE sbr_store_table_access(null) = i2
 DECLARE sbr_add_table_access(ps_operation_type=vc,ps_table_name=vc) = i2
 DECLARE sbr_store_cclaudit_param(null) = i2
 DECLARE sbr_add_cclaudit_param(ps_type=vc,ps_parameter_text=vc) = i2
 DECLARE sbr_store_sequence(null) = i2
 DECLARE sbr_add_sequence(ps_seq_name=vc) = i2
 DECLARE sbr_store_dependency(null) = i2
 DECLARE sbr_add_dependency(ps_component_name=vc,ps_component_type=vc) = i2
 DECLARE sbr_store_execute(null) = i2
 DECLARE sbr_store_dm_dbimport(null) = i2
 DECLARE sbr_get_attribute_value(ps_attribute_name=vc) = vc
 DECLARE sbr_bt_state_machine_cleanup(null) = i2
 SUBROUTINE sbr_parse_xml(ps_xml_filename)
   FREE DEFINE rtl2
   DEFINE rtl2 value(ps_xml_filename)
   SELECT INTO "nl:"
    t.line
    FROM rtl2t t
    WHERE t.line > " "
    DETAIL
     ms_tag = trim(t.line,3)
     IF (findstring(" ",ms_tag) > 0)
      ms_element_name = trim(substring(2,(findstring(" ",ms_tag) - 2),ms_tag),1)
     ELSE
      ms_element_name = trim(substring(2,(findstring(">",ms_tag) - 2),ms_tag),1)
     ENDIF
     mn_stat = sbr_check_ccl_rule(null), mn_stat = sbr_store_table_access(null), mn_stat =
     sbr_store_dependency(null),
     mn_stat = sbr_store_cclaudit_param(null), mn_stat = sbr_store_sequence(null)
     IF (substring((size(ms_tag,1) - 1),1,ms_tag)="/")
      ms_tag = concat("</",ms_element_name,">"), ms_element_name = concat("/",ms_element_name),
      mn_stat = sbr_check_ccl_rule(null),
      mn_stat = sbr_store_table_access(null), mn_stat = sbr_store_dependency(null), mn_stat =
      sbr_store_cclaudit_param(null)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_parse_table_exec_dependency(ps_xml_filename)
   FREE DEFINE rtl2
   DEFINE rtl2 value(ps_xml_filename)
   SELECT INTO "nl:"
    t.line
    FROM rtl2t t
    WHERE t.line > " "
    DETAIL
     ms_tag = trim(t.line,3)
     IF (findstring(" ",ms_tag) > 0)
      ms_element_name = trim(substring(2,(findstring(" ",ms_tag) - 2),ms_tag),1)
     ELSE
      ms_element_name = trim(substring(2,(findstring(">",ms_tag) - 2),ms_tag),1)
     ENDIF
     mn_stat = sbr_store_table_access(null), mn_stat = sbr_store_dependency(null), mn_stat =
     sbr_store_sequence(null)
     IF (substring((size(ms_tag,1) - 1),1,ms_tag)="/")
      ms_tag = concat("</",ms_element_name,">"), ms_element_name = concat("/",ms_element_name),
      mn_stat = sbr_store_table_access(null),
      mn_stat = sbr_store_dependency(null)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_check_ccl_rule(null)
   SET mn_stat = sbr_check_outerjoin(null)
   SET mn_stat = sbr_check_orahint(null)
   SET mn_stat = sbr_check_multi_expand(null)
   SET mn_stat = sbr_check_for_sequence(null)
   SET mn_stat = sbr_check_orjoin(null)
   SET mn_stat = sbr_check_dontcare(null)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_store_dependency(null)
   SET mn_stat = sbr_store_execute(null)
   SET mn_stat = sbr_store_dm_dbimport(null)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_check_outerjoin(null)
  IF (ms_element_name=ms_select_tag
   AND (((m_outerjoin_rec->n_level=0)) OR ((m_outerjoin_rec->levels[m_outerjoin_rec->n_level].
  n_outerjoin_state != ml_trap_state))) )
   SET m_outerjoin_rec->n_level = (m_outerjoin_rec->n_level+ 1)
   SET stat = alterlist(m_outerjoin_rec->levels,m_outerjoin_rec->n_level)
   SET m_outerjoin_rec->levels[m_outerjoin_rec->n_level].n_outerjoin_state = 2
  ELSEIF ((m_outerjoin_rec->n_level > 0))
   CASE (m_outerjoin_rec->levels[m_outerjoin_rec->n_level].n_outerjoin_state)
    OF 2:
     IF (ms_element_name=ms_table_tag)
      SET m_outerjoin_rec->levels[m_outerjoin_rec->n_level].n_outerjoin_state = 3
     ELSEIF (ms_element_name=ms_close_select_tag)
      SET m_outerjoin_rec->n_level = (m_outerjoin_rec->n_level - 1)
     ENDIF
    OF 3:
     IF (ms_element_name=ms_name_tag
      AND sbr_get_attribute_value("text")=ms_dummyt_text)
      SET m_outerjoin_rec->levels[m_outerjoin_rec->n_level].n_outerjoin_state = 4
     ELSEIF (ms_element_name=ms_close_table_tag)
      SET m_outerjoin_rec->levels[m_outerjoin_rec->n_level].n_outerjoin_state = 2
     ENDIF
    OF 4:
     IF (ms_element_name=ms_option_tag)
      SET m_outerjoin_rec->levels[m_outerjoin_rec->n_level].n_outerjoin_state = 5
     ELSEIF (ms_element_name=ms_close_select_tag)
      SET m_outerjoin_rec->n_level = (m_outerjoin_rec->n_level - 1)
     ENDIF
    OF 5:
     IF (ms_element_name IN (ms_is_tag, ms_call_tag))
      SET m_outerjoin_rec->levels[m_outerjoin_rec->n_level].n_outerjoin_state = 6
     ELSEIF (ms_element_name=ms_close_option_tag)
      SET m_outerjoin_rec->levels[m_outerjoin_rec->n_level].n_outerjoin_state = 4
     ENDIF
    OF 6:
     IF (ms_element_name=ms_name_tag
      AND sbr_get_attribute_value("text")=ms_outerjoin_text)
      SET m_outerjoin_rec->levels[m_outerjoin_rec->n_level].n_outerjoin_state = ml_trap_state
      SET mn_stat = sbr_add_error(15002,"DUMMYT Outerjoin control option is used in a CCL statement."
       )
     ELSE
      SET m_outerjoin_rec->levels[m_outerjoin_rec->n_level].n_outerjoin_state = 5
     ENDIF
   ENDCASE
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_check_orahint(null)
  IF (ms_element_name=ms_select_tag
   AND (((m_orahint_rec->n_level=0)) OR ((m_orahint_rec->levels[m_orahint_rec->n_level].
  n_orahint_state != ml_trap_state))) )
   SET m_orahint_rec->n_level = (m_orahint_rec->n_level+ 1)
   SET stat = alterlist(m_orahint_rec->levels,m_orahint_rec->n_level)
   SET m_orahint_rec->levels[m_orahint_rec->n_level].n_orahint_state = 2
  ELSEIF ((m_orahint_rec->n_level > 0))
   CASE (m_orahint_rec->levels[m_orahint_rec->n_level].n_orahint_state)
    OF 2:
     IF (ms_element_name=ms_option_tag)
      SET m_orahint_rec->levels[m_orahint_rec->n_level].n_orahint_state = 3
     ELSEIF (ms_element_name=ms_close_select_tag)
      SET m_orahint_rec->n_level = (m_orahint_rec->n_level - 1)
     ENDIF
    OF 3:
     IF (ms_element_name IN (ms_is_tag, ms_call_tag))
      SET m_orahint_rec->levels[m_orahint_rec->n_level].n_orahint_state = 4
     ELSEIF (ms_element_name=ms_close_option_tag)
      SET m_orahint_rec->levels[m_orahint_rec->n_level].n_orahint_state = 2
     ENDIF
    OF 4:
     IF (ms_element_name=ms_name_tag
      AND sbr_get_attribute_value("text")=ms_orahint_text)
      SET m_orahint_rec->levels[m_orahint_rec->n_level].n_orahint_state = ml_trap_state
      SET mn_stat = sbr_add_error(15007,"ORAHINT is used in a CCL statement.")
     ELSE
      SET m_orahint_rec->levels[m_orahint_rec->n_level].n_orahint_state = 3
     ENDIF
   ENDCASE
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_check_for_sequence(null)
  IF (ms_element_name IN (ms_for_tag, ms_while_tag)
   AND (((m_for_sequence_rec->n_level=0)) OR ((m_for_sequence_rec->levels[m_for_sequence_rec->n_level
  ].n_for_sequence_state != ml_trap_state))) )
   SET m_for_sequence_rec->n_level = (m_for_sequence_rec->n_level+ 1)
   SET stat = alterlist(m_for_sequence_rec->levels,m_for_sequence_rec->n_level)
   SET m_for_sequence_rec->levels[m_for_sequence_rec->n_level].n_for_sequence_state = 2
  ELSEIF ((m_for_sequence_rec->n_level > 0))
   CASE (m_for_sequence_rec->levels[m_for_sequence_rec->n_level].n_for_sequence_state)
    OF 2:
     IF (ms_element_name=ms_select_tag)
      SET m_for_sequence_rec->levels[m_for_sequence_rec->n_level].n_for_sequence_state = 3
     ELSEIF (ms_element_name IN (ms_close_for_tag, ms_close_while_tag))
      SET m_for_sequence_rec->n_level = (m_for_sequence_rec->n_level - 1)
     ENDIF
    OF 3:
     IF (ms_element_name=ms_call_tag)
      SET m_for_sequence_rec->levels[m_for_sequence_rec->n_level].n_for_sequence_state = 4
     ELSEIF (ms_element_name=ms_close_select_tag)
      SET m_for_sequence_rec->levels[m_for_sequence_rec->n_level].n_for_sequence_state = 2
     ENDIF
    OF 4:
     IF (ms_element_name=ms_name_tag
      AND sbr_get_attribute_value("text")=ms_seq_text)
      SET m_for_sequence_rec->levels[m_for_sequence_rec->n_level].n_for_sequence_state = 5
     ELSE
      SET m_for_sequence_rec->levels[m_for_sequence_rec->n_level].n_for_sequence_state = 3
     ENDIF
    OF 5:
     IF (ms_element_name=ms_table_tag)
      SET m_for_sequence_rec->levels[m_for_sequence_rec->n_level].n_for_sequence_state = 6
     ENDIF
    OF 6:
     IF (ms_element_name=ms_name_tag
      AND sbr_get_attribute_value("text")=ms_dual_text)
      SET m_for_sequence_rec->levels[m_for_sequence_rec->n_level].n_for_sequence_state =
      ml_trap_state
      SET mn_stat = sbr_add_error(15008,
       "Select sequence from dual inside a for or while loop is found.")
     ELSEIF (ms_element_name=ms_close_table_tag)
      SET m_for_sequence_rec->levels[m_for_sequence_rec->n_level].n_for_sequence_state = 5
     ENDIF
   ENDCASE
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_check_multi_expand(null)
  IF (ms_element_name=ms_select_tag
   AND (((m_multi_expand_rec->n_level=0)) OR ((m_multi_expand_rec->levels[m_multi_expand_rec->n_level
  ].n_multi_expand_state != ml_trap_state))) )
   SET m_multi_expand_rec->n_level = (m_multi_expand_rec->n_level+ 1)
   SET stat = alterlist(m_multi_expand_rec->levels,m_multi_expand_rec->n_level)
   SET m_multi_expand_rec->levels[m_multi_expand_rec->n_level].n_multi_expand_state = 2
  ELSEIF ((m_multi_expand_rec->n_level > 0))
   CASE (m_multi_expand_rec->levels[m_multi_expand_rec->n_level].n_multi_expand_state)
    OF 2:
     IF (ms_element_name=ms_qual_tag)
      SET m_multi_expand_rec->levels[m_multi_expand_rec->n_level].n_multi_expand_state = 3
     ELSEIF (ms_element_name=ms_close_select_tag)
      SET m_multi_expand_rec->n_level = (m_multi_expand_rec->n_level - 1)
     ENDIF
    OF 3:
     IF (ms_element_name=ms_call_tag)
      SET m_multi_expand_rec->levels[m_multi_expand_rec->n_level].n_multi_expand_state = 4
     ELSEIF (ms_element_name=ms_close_qual_tag)
      SET m_multi_expand_rec->levels[m_multi_expand_rec->n_level].n_multi_expand_state = 2
     ENDIF
    OF 4:
     IF (ms_element_name=ms_name_tag
      AND sbr_get_attribute_value("text")=ms_expand_text)
      SET m_multi_expand_rec->levels[m_multi_expand_rec->n_level].n_multi_expand_state = 5
     ELSE
      SET m_multi_expand_rec->levels[m_multi_expand_rec->n_level].n_multi_expand_state = 3
     ENDIF
    OF 5:
     IF (ms_element_name=ms_call_tag)
      SET m_multi_expand_rec->levels[m_multi_expand_rec->n_level].n_multi_expand_state = 6
     ELSEIF (ms_element_name=ms_close_qual_tag)
      SET m_multi_expand_rec->levels[m_multi_expand_rec->n_level].n_multi_expand_state = 2
     ENDIF
    OF 6:
     IF (ms_element_name=ms_name_tag
      AND sbr_get_attribute_value("text")=ms_expand_text)
      SET m_multi_expand_rec->levels[m_multi_expand_rec->n_level].n_multi_expand_state =
      ml_trap_state
      SET mn_stat = sbr_add_error(15009,"Multiple expands is used in a CCL statement.")
     ELSE
      SET m_multi_expand_rec->levels[m_multi_expand_rec->n_level].n_multi_expand_state = 5
     ENDIF
   ENDCASE
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_check_orjoin(null)
  IF (ms_element_name=ms_select_tag
   AND (((m_orjoin_rec->n_level=0)) OR ((m_orjoin_rec->levels[m_orjoin_rec->n_level].n_orjoin_state
   != ml_trap_state))) )
   SET m_orjoin_rec->n_level = (m_orjoin_rec->n_level+ 1)
   SET stat = alterlist(m_orjoin_rec->levels,m_orjoin_rec->n_level)
   SET m_orjoin_rec->levels[m_orjoin_rec->n_level].n_orjoin_state = 2
   SET m_orjoin_rec->levels[m_orjoin_rec->n_level].l_select_level = cnvtint(sbr_get_attribute_value(
     "lev"))
  ELSEIF ((m_orjoin_rec->n_level > 0))
   CASE (m_orjoin_rec->levels[m_orjoin_rec->n_level].n_orjoin_state)
    OF 2:
     IF (ms_element_name=ms_table_tag)
      SET m_orjoin_rec->levels[m_orjoin_rec->n_level].n_orjoin_state = 3
     ELSEIF (ms_element_name=ms_close_select_tag)
      SET m_orjoin_rec->n_level = (m_orjoin_rec->n_level - 1)
     ELSEIF (ms_element_name=ms_plan_tag
      AND (m_orjoin_rec->levels[m_orjoin_rec->n_level].n_num_dummyt_alias > 1))
      SET m_orjoin_rec->levels[m_orjoin_rec->n_level].n_orjoin_state = 6
     ENDIF
    OF 3:
     IF (ms_element_name=ms_name_tag
      AND sbr_get_attribute_value("text")=ms_dummyt_text)
      SET m_orjoin_rec->levels[m_orjoin_rec->n_level].n_orjoin_state = 4
     ELSEIF (ms_element_name=ms_close_table_tag)
      SET m_orjoin_rec->levels[m_orjoin_rec->n_level].n_orjoin_state = 2
     ENDIF
    OF 4:
     IF (ms_element_name=ms_close_name_tag)
      SET m_orjoin_rec->levels[m_orjoin_rec->n_level].n_orjoin_state = 5
     ENDIF
    OF 5:
     IF (ms_element_name=ms_name_tag)
      SET pn_cur_dummyt_alias = (m_orjoin_rec->levels[m_orjoin_rec->n_level].n_num_dummyt_alias+ 1)
      SET mn_stat = alterlist(m_orjoin_rec->levels[m_orjoin_rec->n_level].dummyts,pn_cur_dummyt_alias
       )
      SET m_orjoin_rec->levels[m_orjoin_rec->n_level].dummyts[pn_cur_dummyt_alias].s_dummyt_alias =
      sbr_get_attribute_value("text")
      SET m_orjoin_rec->levels[m_orjoin_rec->n_level].n_num_dummyt_alias = pn_cur_dummyt_alias
     ENDIF
     SET m_orjoin_rec->levels[m_orjoin_rec->n_level].n_orjoin_state = 2
    OF 6:
     IF (ms_element_name=ms_or_tag
      AND (cnvtint(sbr_get_attribute_value("lev"))=(m_orjoin_rec->levels[m_orjoin_rec->n_level].
     l_select_level+ 4))
      AND sbr_get_attribute_value("kid")="2")
      SET m_orjoin_rec->levels[m_orjoin_rec->n_level].n_orjoin_state = 7
     ELSEIF (ms_element_name=ms_close_select_tag)
      SET m_orjoin_rec->n_level = (m_orjoin_rec->n_level - 1)
     ENDIF
    OF 7:
     IF (ms_element_name=ms_and_tag)
      SET m_orjoin_rec->levels[m_orjoin_rec->n_level].n_orjoin_state = 8
     ELSE
      SET m_orjoin_rec->levels[m_orjoin_rec->n_level].n_orjoin_state = 6
     ENDIF
    OF 8:
     IF (ms_element_name=ms_comma_tag)
      SET m_orjoin_rec->levels[m_orjoin_rec->n_level].n_orjoin_state = 9
     ELSE
      SET m_orjoin_rec->levels[m_orjoin_rec->n_level].n_orjoin_state = 6
     ENDIF
    OF 9:
     IF (ms_element_name=ms_name_tag
      AND locateval(ml_num,1,m_orjoin_rec->levels[m_orjoin_rec->n_level].n_num_dummyt_alias,
      sbr_get_attribute_value("text"),m_orjoin_rec->levels[m_orjoin_rec->n_level].dummyts[ml_num].
      s_dummyt_alias) > 0)
      SET m_orjoin_rec->levels[m_orjoin_rec->n_level].n_orjoin_state = 10
     ELSE
      SET m_orjoin_rec->levels[m_orjoin_rec->n_level].n_orjoin_state = 6
     ENDIF
    OF 10:
     IF ((cnvtint(sbr_get_attribute_value("lev"))=(m_orjoin_rec->levels[m_orjoin_rec->n_level].
     l_select_level+ 5)))
      IF (ms_element_name=ms_and_tag)
       SET m_orjoin_rec->levels[m_orjoin_rec->n_level].n_orjoin_state = 11
      ELSE
       SET m_orjoin_rec->levels[m_orjoin_rec->n_level].n_orjoin_state = 6
      ENDIF
     ENDIF
    OF 11:
     IF (ms_element_name=ms_comma_tag)
      SET m_orjoin_rec->levels[m_orjoin_rec->n_level].n_orjoin_state = 12
     ELSE
      SET m_orjoin_rec->levels[m_orjoin_rec->n_level].n_orjoin_state = 6
     ENDIF
    OF 12:
     IF (ms_element_name=ms_name_tag
      AND locateval(ml_num,1,m_orjoin_rec->levels[m_orjoin_rec->n_level].n_num_dummyt_alias,
      sbr_get_attribute_value("text"),m_orjoin_rec->levels[m_orjoin_rec->n_level].dummyts[ml_num].
      s_dummyt_alias) > 0)
      SET m_orjoin_rec->levels[m_orjoin_rec->n_level].n_orjoin_state = ml_trap_state
      SET mn_stat = sbr_add_error(15012,"Orjoin control option is used in a CCL statement.")
     ELSE
      SET m_orjoin_rec->levels[m_orjoin_rec->n_level].n_orjoin_state = 6
     ENDIF
   ENDCASE
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_check_dontcare(null)
  IF (ms_element_name=ms_select_tag
   AND (((m_dontcare_rec->n_level=0)) OR ((m_dontcare_rec->levels[m_dontcare_rec->n_level].
  n_dontcare_state != ml_trap_state))) )
   SET m_dontcare_rec->n_level = (m_dontcare_rec->n_level+ 1)
   SET stat = alterlist(m_dontcare_rec->levels,m_dontcare_rec->n_level)
   SET m_dontcare_rec->levels[m_dontcare_rec->n_level].n_dontcare_state = 2
  ELSEIF ((m_dontcare_rec->n_level > 0))
   CASE (m_dontcare_rec->levels[m_dontcare_rec->n_level].n_dontcare_state)
    OF 2:
     IF (ms_element_name=ms_option_tag)
      SET m_dontcare_rec->levels[m_dontcare_rec->n_level].n_dontcare_state = 3
     ELSEIF (ms_element_name=ms_close_select_tag)
      SET m_dontcare_rec->n_level = (m_dontcare_rec->n_level - 1)
     ENDIF
    OF 3:
     IF (ms_element_name IN (ms_is_tag, ms_call_tag))
      SET m_dontcare_rec->levels[m_dontcare_rec->n_level].n_dontcare_state = 4
     ELSEIF (ms_element_name=ms_close_option_tag)
      SET m_dontcare_rec->levels[m_dontcare_rec->n_level].n_dontcare_state = 2
     ENDIF
    OF 4:
     IF (ms_element_name=ms_name_tag
      AND sbr_get_attribute_value("text")=ms_dontcare_text)
      SET m_dontcare_rec->levels[m_dontcare_rec->n_level].n_dontcare_state = ml_trap_state
      SET mn_stat = sbr_add_error(15013,"Dontcare control option is used in a CCL statement.")
     ELSE
      SET m_dontcare_rec->levels[m_dontcare_rec->n_level].n_dontcare_state = 3
     ENDIF
   ENDCASE
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_store_table_access(null)
   DECLARE ps_table_name = vc WITH private, noconstant(" ")
   IF (ms_element_name IN (ms_select_tag, ms_update_tag, ms_insert_tag, ms_delete_tag))
    SET m_table_access_check_rec->n_level = (m_table_access_check_rec->n_level+ 1)
    SET stat = alterlist(m_table_access_check_rec->levels,m_table_access_check_rec->n_level)
    SET m_table_access_check_rec->levels[m_table_access_check_rec->n_level].s_operation_type =
    ms_element_name
    SET m_table_access_check_rec->levels[m_table_access_check_rec->n_level].n_table_access_state = 2
   ELSEIF ((m_table_access_check_rec->n_level > 0))
    CASE (m_table_access_check_rec->levels[m_table_access_check_rec->n_level].n_table_access_state)
     OF 2:
      IF (ms_element_name=ms_table_tag)
       SET m_table_access_check_rec->levels[m_table_access_check_rec->n_level].n_table_access_state
        = 3
      ELSEIF (ms_element_name IN (ms_close_select_tag, ms_close_update_tag, ms_close_insert_tag,
      ms_close_delete_tag))
       SET m_table_access_check_rec->n_level = (m_table_access_check_rec->n_level - 1)
      ENDIF
     OF 3:
      IF (ms_element_name=ms_name_tag)
       SET ps_table_name = sbr_get_attribute_value("text")
       SET pi_at_index = findstring("@",ps_table_name,0)
       IF (pi_at_index > 0)
        SET ps_table_name = substring(1,(pi_at_index - 1),ps_table_name)
       ENDIF
       SET mn_stat = sbr_add_table_access(m_table_access_check_rec->levels[m_table_access_check_rec->
        n_level].s_operation_type,ps_table_name)
      ENDIF
      SET m_table_access_check_rec->levels[m_table_access_check_rec->n_level].n_table_access_state =
      2
    ENDCASE
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_add_table_access(ps_operation_type,ps_table_name)
   DECLARE pn_list_num = i2 WITH private, constant(evaluate(ps_operation_type,ms_select_tag,1,
     ms_update_tag,2,
     ms_insert_tag,2,ms_delete_tag,2))
   DECLARE pn_operation_type = i2 WITH private, constant(evaluate(ps_operation_type,ms_select_tag,
     mn_select,ms_update_tag,mn_update,
     ms_insert_tag,mn_insert,ms_delete_tag,mn_delete))
   DECLARE pl_cur_num_table = i4 WITH private, noconstant(0)
   DECLARE pl_cur_table_index = i4 WITH private, noconstant(0)
   IF (locateval(ml_num,1,m_table_access_rec->list[pn_list_num].l_num_table,ps_table_name,
    m_table_access_rec->list[pn_list_num].table_list[ml_num].s_table_name,
    pn_operation_type,m_table_access_rec->list[pn_list_num].table_list[ml_num].n_operation_type)=0)
    SET pl_cur_num_table = (m_table_access_rec->list[pn_list_num].l_num_table+ 1)
    SET mn_stat = alterlist(m_table_access_rec->list[pn_list_num].table_list,pl_cur_num_table)
    SET m_table_access_rec->list[pn_list_num].table_list[pl_cur_num_table].s_table_name =
    ps_table_name
    SET m_table_access_rec->list[pn_list_num].table_list[pl_cur_num_table].n_operation_type =
    pn_operation_type
    SET m_table_access_rec->list[pn_list_num].l_num_table = pl_cur_num_table
   ENDIF
   SET pl_cur_table_index = locateval(ml_num,1,m_ora_table_rec->l_num_table,ps_table_name,
    m_ora_table_rec->tables[ml_num].s_table_name)
   IF (pl_cur_table_index=0)
    SET pl_cur_table_index = (m_ora_table_rec->l_num_table+ 1)
    SET mn_stat = alterlist(m_ora_table_rec->tables,pl_cur_table_index)
    SET m_ora_table_rec->tables[pl_cur_table_index].s_table_name = ps_table_name
    SET m_ora_table_rec->l_num_table = pl_cur_table_index
   ENDIF
   CASE (pn_operation_type)
    OF mn_select:
     SET m_ora_table_rec->tables[pl_cur_table_index].l_select_cnt = (m_ora_table_rec->tables[
     pl_cur_table_index].l_select_cnt+ 1)
    OF mn_update:
     SET m_ora_table_rec->tables[pl_cur_table_index].l_update_cnt = (m_ora_table_rec->tables[
     pl_cur_table_index].l_update_cnt+ 1)
    OF mn_insert:
     SET m_ora_table_rec->tables[pl_cur_table_index].l_insert_cnt = (m_ora_table_rec->tables[
     pl_cur_table_index].l_insert_cnt+ 1)
    OF mn_delete:
     SET m_ora_table_rec->tables[pl_cur_table_index].l_delete_cnt = (m_ora_table_rec->tables[
     pl_cur_table_index].l_delete_cnt+ 1)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_store_cclaudit_param(null)
   DECLARE ps_parameter_text = vc WITH private, noconstant(" ")
   CASE (mn_cclaudit_state)
    OF 1:
     IF (ms_element_name=ms_execute_tag)
      SET mn_cclaudit_state = 2
     ENDIF
    OF 2:
     IF (ms_element_name=ms_user_tag)
      SET mn_cclaudit_state = 3
     ELSEIF (ms_element_name=ms_close_execute_tag)
      SET mn_cclaudit_state = 1
     ENDIF
    OF 3:
     IF (ms_element_name=ms_name_tag
      AND sbr_get_attribute_value("text")=ms_cclaudit_text)
      SET mn_cclaudit_state = 4
     ELSEIF (ms_element_name=ms_close_user_tag)
      SET mn_cclaudit_state = 2
     ENDIF
    OF 4:
     IF (ms_element_name=ms_is_tag)
      SET mn_cclaudit_state = 5
     ELSEIF (ms_element_name=ms_close_execute_tag)
      SET mn_cclaudit_state = 1
     ENDIF
    OF 5:
     IF (ms_element_name=ms_is_tag)
      SET mn_cclaudit_state = 6
     ELSEIF (ms_element_name=ms_close_execute_tag)
      SET mn_cclaudit_state = 1
     ENDIF
    OF 6:
     IF (ms_element_name=ms_string_tag)
      SET ps_parameter_text = sbr_get_attribute_value("text")
      SET mn_stat = sbr_add_cclaudit_param("NAME",ps_parameter_text)
     ENDIF
     IF (ms_element_name=ms_close_execute_tag)
      SET mn_cclaudit_state = 1
     ELSE
      SET mn_cclaudit_state = 7
     ENDIF
    OF 7:
     IF (ms_element_name=ms_is_tag)
      SET mn_cclaudit_state = 8
     ELSEIF (ms_element_name=ms_close_execute_tag)
      SET mn_cclaudit_state = 1
     ENDIF
    OF 8:
     IF (ms_element_name=ms_string_tag)
      SET ps_parameter_text = sbr_get_attribute_value("text")
      SET mn_stat = sbr_add_cclaudit_param("TYPE",ps_parameter_text)
     ENDIF
     SET mn_cclaudit_state = 1
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_add_cclaudit_param(ps_type,ps_parameter_text)
  IF (trim(ps_parameter_text,3) != "")
   IF (ps_type="NAME")
    SET m_cclaudit_rec->l_name_type_cnt = (m_cclaudit_rec->l_name_type_cnt+ 1)
    SET mn_stat = alterlist(m_cclaudit_rec->name_types,m_cclaudit_rec->l_name_type_cnt)
    SET m_cclaudit_rec->name_types[m_cclaudit_rec->l_name_type_cnt].s_name = replace(
     ps_parameter_text,"&amp","&",0)
   ELSE
    SET m_cclaudit_rec->name_types[m_cclaudit_rec->l_name_type_cnt].s_type = replace(
     ps_parameter_text,"&amp","&",0)
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_store_sequence(null)
  CASE (m_seq_rec->n_seq_state)
   OF 0:
    IF (ms_element_name=ms_call_tag)
     SET m_seq_rec->n_seq_state = 1
    ENDIF
   OF 1:
    IF (ms_element_name=ms_name_tag
     AND sbr_get_attribute_value("text")=ms_seq_text)
     SET m_seq_rec->n_seq_state = 2
    ELSE
     SET m_seq_rec->n_seq_state = 0
    ENDIF
   OF 2:
    IF (ms_element_name=ms_name_tag)
     SET mn_stat = sbr_add_sequence(sbr_get_attribute_value("text"))
    ENDIF
    SET m_seq_rec->n_seq_state = 0
  ENDCASE
  RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_add_sequence(ps_seq_name)
   DECLARE pl_cur_seq_index = i4 WITH private, noconstant(0)
   IF ( NOT (ps_seq_name IN ("", " ", null)))
    SET pl_cur_seq_index = locateval(ml_num,1,m_sequence->l_seq_cnt,ps_seq_name,m_sequence->seq_list[
     ml_num].s_seq_name)
    IF (pl_cur_seq_index=0)
     SET m_sequence->l_seq_cnt = (m_sequence->l_seq_cnt+ 1)
     SET mn_stat = alterlist(m_sequence->seq_list,m_sequence->l_seq_cnt)
     SET pl_cur_seq_index = m_sequence->l_seq_cnt
     SET m_sequence->seq_list[pl_cur_seq_index].s_seq_name = ps_seq_name
    ENDIF
    SET m_sequence->seq_list[pl_cur_seq_index].l_usage_cnt = (m_sequence->seq_list[pl_cur_seq_index].
    l_usage_cnt+ 1)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_store_execute(null)
   DECLARE ps_object_name = vc WITH private, noconstant(" ")
   CASE (mn_execute_state)
    OF 1:
     IF (ms_element_name=ms_execute_tag)
      SET mn_execute_state = 2
     ENDIF
    OF 2:
     IF (ms_element_name=ms_user_tag)
      SET mn_execute_state = 3
     ELSEIF (ms_element_name=ms_close_execute_tag)
      SET mn_execute_state = 1
     ENDIF
    OF 3:
     IF (ms_element_name=ms_name_tag)
      SET ps_object_name = sbr_get_attribute_value("text")
      SET mn_stat = sbr_add_dependency(ps_object_name,ms_execute_type)
     ENDIF
     SET mn_execute_state = 1
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_store_dm_dbimport(null)
   DECLARE ps_parameter_text = vc WITH private, noconstant(" ")
   CASE (mn_dm_dbimport_state)
    OF 1:
     IF (ms_element_name=ms_execute_tag)
      SET mn_dm_dbimport_state = 2
     ENDIF
    OF 2:
     IF (ms_element_name=ms_user_tag)
      SET mn_dm_dbimport_state = 3
     ELSEIF (ms_element_name=ms_close_execute_tag)
      SET mn_dm_dbimport_state = 1
     ENDIF
    OF 3:
     IF (ms_element_name=ms_name_tag
      AND sbr_get_attribute_value("text")=ms_dm_dbimport_text)
      SET mn_dm_dbimport_state = 4
     ELSEIF (ms_element_name=ms_close_user_tag)
      SET mn_dm_dbimport_state = 2
     ENDIF
    OF 4:
     IF (ms_element_name=ms_is_tag)
      SET mn_dm_dbimport_state = 5
     ELSEIF (ms_element_name=ms_close_execute_tag)
      SET mn_dm_dbimport_state = 1
     ENDIF
    OF 5:
     IF (ms_element_name=ms_string_tag)
      SET ps_parameter_text = sbr_get_attribute_value("text")
      SET ps_parameter_text = trim(cnvtupper(ps_parameter_text),3)
      SET mn_stat = sbr_add_dependency(ps_parameter_text,ms_data_type)
     ENDIF
     IF (ms_element_name=ms_close_execute_tag)
      SET mn_dm_dbimport_state = 1
     ELSE
      SET mn_dm_dbimport_state = 6
     ENDIF
    OF 6:
     IF (ms_element_name=ms_is_tag)
      SET mn_dm_dbimport_state = 7
     ELSEIF (ms_element_name=ms_close_execute_tag)
      SET mn_dm_dbimport_state = 1
     ENDIF
    OF 7:
     IF (ms_element_name=ms_string_tag)
      SET ps_parameter_text = sbr_get_attribute_value("text")
      SET ps_parameter_text = trim(cnvtupper(ps_parameter_text),3)
      SET mn_stat = sbr_add_dependency(ps_parameter_text,ms_execute_type)
     ENDIF
     SET mn_dm_dbimport_state = 1
   ENDCASE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_add_dependency(ps_component_name,ps_component_type)
  IF (locateval(ml_num,1,m_dependency_rec->l_child_cnt,ps_component_name,m_dependency_rec->childs[
   ml_num].s_component_name,
   ps_component_type,m_dependency_rec->childs[ml_num].s_component_type)=0)
   SET m_dependency_rec->l_child_cnt = (m_dependency_rec->l_child_cnt+ 1)
   SET mn_stat = alterlist(m_dependency_rec->childs,m_dependency_rec->l_child_cnt)
   SET m_dependency_rec->childs[m_dependency_rec->l_child_cnt].s_component_name = ps_component_name
   SET m_dependency_rec->childs[m_dependency_rec->l_child_cnt].s_component_type = ps_component_type
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_get_attribute_value(ps_attribute_name)
  DECLARE pn_attr_index = i2 WITH private, constant(findstring(ps_attribute_name,ms_tag))
  IF (pn_attr_index > 0)
   DECLARE pn_first_quote = i2 WITH private, constant(findstring('"',ms_tag,(pn_attr_index+ size(
      ps_attribute_name,1))))
   DECLARE pn_second_quote = i2 WITH private, constant(findstring('"',ms_tag,(pn_first_quote+ 1)))
   RETURN(substring((pn_first_quote+ 1),((pn_second_quote - pn_first_quote) - 1),ms_tag))
  ELSE
   RETURN("-1")
  ENDIF
 END ;Subroutine
 SUBROUTINE sbr_bt_state_machine_cleanup(null)
   FREE RECORD m_outerjoin_rec
   FREE RECORD m_cclaudit_rec
   FREE RECORD m_orahint_rec
   FREE RECORD m_for_sequence_rec
   FREE RECORD m_multi_expand_rec
   FREE RECORD m_orjoin_rec
   FREE RECORD m_dontcare_rec
   FREE RECORD m_table_access_check_rec
   RETURN(1)
 END ;Subroutine
 DECLARE mn_size = i2 WITH protect, constant(10)
 DECLARE ms_temp_tran_file = vc WITH protect, constant(concat(trim(curprcname,3),"_temp.dat"))
 DECLARE ms_optimizer_mode = vc WITH protect, noconstant(" ")
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_total = i4 WITH protect, noconstant(0)
 DECLARE ml_start = i4 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH protect, noconstant(0)
 DECLARE mn_stat = i2 WITH protect, noconstant(0)
 DECLARE mf_threshold_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_exception_text = vc WITH protect, noconstant(" ")
 DECLARE ms_message = vc WITH protect, noconstant(" ")
 DECLARE ms_query_operation = vc WITH protect, noconstant(" ")
 DECLARE ms_query_object_name = vc WITH protect, noconstant(" ")
 DECLARE ms_query_options = vc WITH protect, noconstant(" ")
 DECLARE mf_query_cost = f8 WITH protect, noconstant(0.0)
 DECLARE ms_query_table_name = vc WITH protect, noconstant(" ")
 DECLARE mf_script_total_cost = f8 WITH protect, noconstant(0.0)
 DECLARE mf_max_script_cost = f8 WITH protect, noconstant(- (1.0))
 DECLARE mf_max_binary_size = f8 WITH protect, noconstant(- (1.0))
 DECLARE ms_opt_mode_setting = vc WITH protect, noconstant("")
 DECLARE ms_alter_session = vc WITH protect, noconstant("")
 FREE RECORD m_gm_struct
 RECORD m_gm_struct(
   1 l_gm_locked_list_size = i4
   1 gm_locked_list[*]
     2 s_table_name = vc
     2 n_operation_type = i2
     2 l_valid_script_list_size = i4
     2 valid_script_list[*]
       3 s_valid_script_name = vc
 ) WITH protect
 DECLARE sbr_parse_query(null) = i2
 DECLARE sbr_parse_index_only(null) = i2
 DECLARE sbr_parse_check(ps_check_filename=vc) = i2
 DECLARE sbr_check_cclaudit_rule(null) = i2
 DECLARE sbr_check_cclaudit_name(null) = i2
 DECLARE sbr_check_cclaudit_type(null) = i2
 DECLARE sbr_check_cclaudit_event(null) = i2
 DECLARE sbr_check_obsolete_table(null) = i2
 DECLARE sbr_check_code_value(null) = i2
 DECLARE sbr_check_gold_master(null) = i2
 DECLARE sbr_check_binary_size(null) = i2
 DECLARE sbr_add_full_table_scan(ps_table_name=vc) = i2
 DECLARE sbr_add_index_usage(ps_index_name=vc,ps_options=vc) = i2
 DECLARE sbr_add_gm_locked_table(ps_table_name=vc,pn_operation_type=i2) = i4
 DECLARE sbr_add_gm_valid_script(pl_gm_list_idx=i4,ps_script_name=vc) = i2
 IF (check_logfile("dm_script_scanner",".log","DM_SCRIPT_SCANNER logfile")=0)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Validating object name..."
 CALL disp_msg(" ",dm_err->logfile,0)
 SET ms_object_name = cnvtupper(trim( $1,3))
 SET dm_script_scanner_reply->script_name = ms_object_name
 SET ml_err_list_size = 0
 SET dm_script_scanner_reply->fail_ind = 0
 SET mn_stat = alterlist(dm_script_scanner_reply->err_list,0)
 SET mf_project_instance =  $2
 IF (((findstring("*",patstring(ms_object_name)) != 0) OR (findstring("?",patstring(ms_object_name))
  != 0)) )
  SET dm_err->eproc = "Wildcards are not allowed in an object name... Exiting"
  CALL disp_msg(" ",dm_err->logfile,0)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM dprotect d
  WHERE d.object="P"
   AND d.object_name=ms_object_name
   AND d.group=0
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(concat("Error while selecting from DPROTECT: ",dm_err->emsg),dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (curqual=0)
  SET dm_err->eproc = "Object does not exist... Exiting"
  CALL disp_msg(" ",dm_err->logfile,0)
  GO TO exit_program
 ENDIF
 IF (((((currev * 10000)+ (currevminor * 100))+ currevminor2) < 080300))
  SET dm_err->err_ind = 1
  CALL disp_msg(
   "DM_SCRIPT_SCANNER cannot be executed from environment with CCL version less than 8.3.0.",dm_err->
   logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Populating exceptions list..."
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM dm_threshold d
  PLAN (d
   WHERE d.review_type="BUILDTIME SCANNER"
    AND d.active_ind=1)
  DETAIL
   mf_threshold_id = d.threshold_id
  WITH nocounter, maxqual(d,1)
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(concat("Error while selecting from DM_THRESHOLD: ",dm_err->emsg),dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM dm_threshold_criteria d
  PLAN (d
   WHERE d.threshold_id=mf_threshold_id
    AND ((d.criteria_name="RULE_EXCEPTION_PATTERN") OR (d.criteria_name IN ("RULE_EXCEPTION",
   "TRANSLATE_EXCEPTION")
    AND d.criteria_char=ms_object_name)) )
  HEAD REPORT
   m_exceptions->l_num_exceptions = 0
  DETAIL
   m_exceptions->l_num_exceptions = (m_exceptions->l_num_exceptions+ 1)
   IF (mod(m_exceptions->l_num_exceptions,10)=1)
    mn_stat = alterlist(m_exceptions->exceptions,(m_exceptions->l_num_exceptions+ 9))
   ENDIF
   m_exceptions->exceptions[m_exceptions->l_num_exceptions].s_threshold_type = d.criteria_name
   CASE (d.criteria_name)
    OF "RULE_EXCEPTION":
     m_exceptions->exceptions[m_exceptions->l_num_exceptions].f_threshold_value = d.criteria_value
    OF "RULE_EXCEPTION_PATTERN":
     m_exceptions->exceptions[m_exceptions->l_num_exceptions].f_threshold_value = d.criteria_value,
     m_exceptions->exceptions[m_exceptions->l_num_exceptions].s_threshold_char = d.criteria_char
    OF "TRANSLATE_EXCEPTION":
     m_exceptions->exceptions[m_exceptions->l_num_exceptions].s_threshold_char = d.criteria_formula
   ENDCASE
  FOOT REPORT
   mn_stat = alterlist(m_exceptions->exceptions,m_exceptions->l_num_exceptions)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(concat("Error while selecting from DM_THRESHOLD_CRITERIA: ",dm_err->emsg),dm_err->
   logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Checking for script exceptions..."
 CALL disp_msg(" ",dm_err->logfile,0)
 IF (locateval(ml_num,1,m_exceptions->l_num_exceptions,"RULE_EXCEPTION",m_exceptions->exceptions[
  ml_num].s_threshold_type,
  0.0,m_exceptions->exceptions[ml_num].f_threshold_value) > 0)
  IF (realtime_flag != 0)
   GO TO exit_program
  ENDIF
  SET mn_script_info_only_ind = 1
  SET dm_err->eproc = "Only retrieving script information for this script..."
  CALL disp_msg(" ",dm_err->logfile,0)
 ENDIF
 IF (mn_script_info_only_ind=0)
  FOR (pl_exception_cnt = 1 TO m_exceptions->l_num_exceptions)
    IF ((m_exceptions->exceptions[pl_exception_cnt].s_threshold_type="RULE_EXCEPTION_PATTERN")
     AND (m_exceptions->exceptions[pl_exception_cnt].f_threshold_value=0)
     AND patstring(m_exceptions->exceptions[pl_exception_cnt].s_threshold_char)=ms_object_name)
     IF (realtime_flag != 0)
      GO TO exit_program
     ENDIF
     SET dm_err->eproc = "Matching rule exception pattern found.  Inserting new rule exception 0..."
     CALL disp_msg(" ",dm_err->logfile,0)
     INSERT  FROM dm_threshold_criteria d
      SET d.threshold_criteria_id = seq(dm2_dar_seq,nextval), d.threshold_id = mf_threshold_id, d
       .criteria_char = ms_object_name,
       d.criteria_name = "RULE_EXCEPTION", d.criteria_value = 0, d.criteria_formula = "AUTO",
       d.boundary_formula = m_exceptions->exceptions[pl_exception_cnt].s_threshold_char, d.action =
       "PASSED", d.os_type = "ALL"
      WITH nocounter
     ;end insert
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(concat("Error while inserting to DM_THRESHOLD_CRITERIA: ",dm_err->emsg),dm_err->
       logfile,1)
      ROLLBACK
      GO TO exit_program
     ENDIF
     COMMIT
     SET mn_script_info_only_ind = 1
     SET dm_err->eproc = "Only retrieving script information for this script..."
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
  ENDFOR
 ENDIF
 IF (mn_script_info_only_ind=0)
  SET dm_err->eproc = "Populating scanner rules and thresholds..."
  CALL disp_msg(" ",dm_err->logfile,0)
  FOR (l_cur_error = 1 TO ml_errors_cnt)
    SET m_error_struct->error_list[l_cur_error].s_error_status = "WARNING"
  ENDFOR
  SET mf_max_script_cost = 0.0
  SET mf_max_binary_size = 0.0
  SELECT INTO "nl:"
   FROM dm_threshold_criteria dtc
   PLAN (dtc
    WHERE dtc.threshold_id=mf_threshold_id
     AND dtc.criteria_name="INCLUDE_ERROR")
   DETAIL
    IF (ml_min_error_num <= dtc.criteria_value
     AND dtc.criteria_value <= ml_max_error_num)
     m_error_struct->error_list[((dtc.criteria_value - ml_min_error_num)+ 1)].s_error_status = dtc
     .action
    ENDIF
    IF (dtc.criteria_value=15001)
     mf_max_script_cost = cnvtreal(dtc.criteria_formula)
    ELSEIF (dtc.criteria_value=15014)
     mf_max_binary_size = cnvtreal(dtc.criteria_formula)
    ENDIF
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(concat("Error while selecting from DM_THRESHOLD_CRITERIA: ",dm_err->emsg),dm_err->
    logfile,1)
   GO TO exit_program
  ENDIF
  IF (mf_max_script_cost=0)
   CALL disp_msg(
    "The threshold for MAX SCRIPT COST is not found.  Only retrieving script information...",dm_err->
    logfile,1)
   SET mn_script_info_only_ind = 1
  ENDIF
  IF (mf_max_binary_size=0)
   CALL disp_msg(
    "The threshold for MAX BINARY SIZE is not found.  Only retrieving script information...",dm_err->
    logfile,1)
   SET mn_script_info_only_ind = 1
  ENDIF
 ENDIF
 IF (mn_script_info_only_ind=0)
  SET dm_err->eproc = "Checking for rule exceptions..."
  CALL disp_msg(" ",dm_err->logfile,0)
  FOR (pl_rule_loop = ml_min_error_num TO ml_max_error_num)
   IF (locateval(ml_idx,1,m_exceptions->l_num_exceptions,"RULE_EXCEPTION",m_exceptions->exceptions[
    ml_idx].s_threshold_type,
    cnvtreal(pl_rule_loop),m_exceptions->exceptions[ml_idx].f_threshold_value) > 0)
    SET m_error_struct->error_list[((pl_rule_loop - ml_min_error_num)+ 1)].s_error_status = ms_passed
   ENDIF
   IF ((m_error_struct->error_list[((pl_rule_loop - ml_min_error_num)+ 1)].s_error_status !=
   ms_passed))
    FOR (pl_exception_cnt = 1 TO m_exceptions->l_num_exceptions)
      IF ((m_exceptions->exceptions[pl_exception_cnt].s_threshold_type="RULE_EXCEPTION_PATTERN")
       AND (m_exceptions->exceptions[pl_exception_cnt].f_threshold_value=cnvtreal(pl_rule_loop))
       AND patstring(m_exceptions->exceptions[pl_exception_cnt].s_threshold_char)=ms_object_name)
       SET dm_err->eproc = concat(
        "Matching rule exception pattern found.  Inserting new rule exception ",trim(cnvtstring(
          pl_rule_loop),3),"...")
       CALL disp_msg(" ",dm_err->logfile,0)
       INSERT  FROM dm_threshold_criteria d
        SET d.threshold_criteria_id = seq(dm2_dar_seq,nextval), d.threshold_id = mf_threshold_id, d
         .criteria_char = ms_object_name,
         d.criteria_name = "RULE_EXCEPTION", d.criteria_value = pl_rule_loop, d.criteria_formula =
         "AUTO",
         d.boundary_formula = m_exceptions->exceptions[pl_exception_cnt].s_threshold_char, d.action
          = "PASSED", d.os_type = "ALL"
        WITH nocounter
       ;end insert
       IF (check_error(dm_err->eproc)=1)
        CALL disp_msg(concat("Error while inserting to DM_THRESHOLD_CRITERIA: ",dm_err->emsg),dm_err
         ->logfile,1)
        ROLLBACK
        GO TO exit_program
       ENDIF
       COMMIT
       SET m_error_struct->error_list[((pl_rule_loop - ml_min_error_num)+ 1)].s_error_status =
       ms_passed
      ENDIF
    ENDFOR
   ENDIF
  ENDFOR
 ENDIF
 SET dm_err->eproc = "Retrieving optimizer information..."
 CALL disp_msg(" ",dm_err->logfile,0)
 SELECT INTO "nl:"
  FROM v$parameter v
  WHERE v.name="optimizer_mode"
  DETAIL
   ms_optimizer_mode = trim(v.value,3)
  WITH nocounter
 ;end select
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(concat("Error while retrieving optimizer information from v$parameter: ",dm_err->emsg
    ),dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (ms_optimizer_mode="RULE")
  SET dm_err->eproc = "Current optimizer mode is RULE...determining new optimizer mode to use"
  CALL disp_msg(" ",dm_err->logfile,0)
  SELECT INTO "nl:"
   FROM dm_info di
   PLAN (di
    WHERE di.info_domain="DM_SET_SESSION_PARAMETERS"
     AND di.info_name="OPTIMIZER_MODE")
   DETAIL
    ms_opt_mode_setting = di.info_char
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(concat("Error while retrieving DM_SET_SESSION_PARAMETERS from dm_info: ",dm_err->
     emsg),dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  IF (ms_opt_mode_setting="")
   SET dm_err->eproc = "Optimizer mode setting not found."
   CALL disp_msg(" ",dm_err->logfile,0)
   SET ms_opt_mode_setting = "alter session set optimizer_mode = CHOOSE"
  ENDIF
  SET dm_err->eproc = concat("Setting optimizer mode: ",ms_opt_mode_setting)
  CALL disp_msg(" ",dm_err->logfile,0)
  SET ms_alter_session = concat("rdb ",ms_opt_mode_setting," go")
  IF (dm2_push_cmd(ms_alter_session,1)=0)
   GO TO exit_program
  ENDIF
 ELSE
  SET dm_err->eproc = concat("Current optimizer mode is ",ms_optimizer_mode,
   ".  Do not alter optimizer mode.")
  CALL disp_msg(" ",dm_err->logfile,0)
 ENDIF
 IF (locateval(ml_num,1,m_exceptions->l_num_exceptions,"TRANSLATE_EXCEPTION",m_exceptions->
  exceptions[ml_num].s_threshold_type,
  "QUERY",m_exceptions->exceptions[ml_num].s_threshold_char) > 0)
  SET dm_err->eproc = "Translate with Query exception found.  Skipping Translate with Query..."
  CALL disp_msg(" ",dm_err->logfile,0)
  GO TO xml_check
 ENDIF
 SET dm_err->eproc = "Translating and executing the object with query..."
 CALL disp_msg(" ",dm_err->logfile,0)
 DELETE  FROM plan_table pt
  WHERE pt.statement_id=patstring(concat(curuser,":*"))
  WITH nocounter
 ;end delete
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(concat("Error while deleting from PLAN_TABLE: ",dm_err->emsg),dm_err->logfile,1)
  ROLLBACK
  GO TO exit_program
 ENDIF
 COMMIT
 DELETE  FROM dm_threshold_criteria d
  WHERE d.threshold_id=mf_threshold_id
   AND d.criteria_name="TRANSLATE_ERROR"
   AND d.criteria_char=ms_object_name
   AND d.criteria_formula="QUERY"
  WITH nocounter
 ;end delete
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(concat("Error while deleting from DM_THRESHOLD_CRITERIA: ",dm_err->emsg),dm_err->
   logfile,1)
  ROLLBACK
  GO TO exit_program
 ENDIF
 COMMIT
 IF (dm2_push_cmd(concat("translate into '",ms_temp_tran_file,"' ",ms_object_name,
   ":DBA with query go"),1)=0)
  SET dm_err->err_ind = 0
  SET dm_err->eproc = "Ignore any error generated during translation"
  CALL disp_msg(" ",dm_err->logfile,0)
  INSERT  FROM dm_threshold_criteria d
   SET d.threshold_criteria_id = seq(dm2_dar_seq,nextval), d.threshold_id = mf_threshold_id, d
    .criteria_name = "TRANSLATE_ERROR",
    d.criteria_char = ms_object_name, d.criteria_formula = "QUERY", d.boundary_formula = dm_err->emsg,
    d.action = "PASSED", d.os_type = "ALL"
   WITH nocounter
  ;end insert
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(concat("Error while inserting into DM_THRESHOLD_CRITERIA: ",dm_err->emsg),dm_err->
    logfile,1)
   ROLLBACK
   GO TO exit_program
  ENDIF
  COMMIT
 ENDIF
 IF (findfile(ms_temp_tran_file)=0)
  SET dm_err->err_ind = 1
  CALL disp_msg("Output file from Translate with Query not found.  Exiting...",dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 CALL compile(ms_temp_tran_file)
 IF (check_error(dm_err->eproc)=1)
  SET dm_err->err_ind = 0
  SET dm_err->eproc = concat("Ignore the error while compiling the file with query: ",dm_err->emsg,
   "Continue to check XML Rules.")
  CALL disp_msg(" ",dm_err->logfile,0)
  GO TO xml_check
 ENDIF
 IF (dm2_push_cmd(concat("execute _",ms_object_name,":GROUP99 go"),1)=0)
  SET dm_err->err_ind = 0
  SET dm_err->eproc = "Ignore any error generated from the execution of the translated object"
  CALL disp_msg(" ",dm_err->logfile,0)
 ENDIF
 IF (mn_script_info_only_ind=0)
  IF (sbr_parse_query(null)=0)
   CALL disp_msg(concat("Error while selecting from PLAN_TABLE 1: ",dm_err->emsg),dm_err->logfile,1)
   GO TO exit_program
  ENDIF
 ELSE
  IF (sbr_parse_index_only(null)=0)
   CALL disp_msg(concat("Error while selecting from PLAN_TABLE 2: ",dm_err->emsg),dm_err->logfile,1)
   GO TO exit_program
  ENDIF
 ENDIF
 IF ((m_index_usage->l_index_cnt > 0))
  SET dm_err->eproc = "Retrieving table names for the index usage..."
  CALL disp_msg(" ",dm_err->logfile,0)
  SET ml_total = (ceil((cnvtreal(m_index_usage->l_index_cnt)/ mn_size)) * mn_size)
  SET mn_stat = alterlist(m_index_usage->index_list,ml_total)
  SET ml_start = 1
  FOR (ml_idx = (m_index_usage->l_index_cnt+ 1) TO ml_total)
    SET m_index_usage->index_list[ml_idx].s_index_name = m_index_usage->index_list[m_index_usage->
    l_index_cnt].s_index_name
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value((1+ ((ml_total - 1)/ mn_size)))),
    dm2_user_indexes di
   PLAN (d1
    WHERE initarray(ml_start,evaluate(d1.seq,1,1,(ml_start+ mn_size))))
    JOIN (di
    WHERE expand(ml_idx,ml_start,(ml_start+ (mn_size - 1)),di.index_name,m_index_usage->index_list[
     ml_idx].s_index_name))
   HEAD REPORT
    pl_cur_index_idx = 0
   DETAIL
    pl_cur_index_idx = locateval(ml_num,1,m_index_usage->l_index_cnt,di.index_name,m_index_usage->
     index_list[ml_num].s_index_name), m_index_usage->index_list[pl_cur_index_idx].s_table_name =
    trim(di.table_name,3)
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(concat("Error while selecting from DBA_INDEXES: ",dm_err->emsg),dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  SET ml_start = 1
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value((1+ ((ml_total - 1)/ mn_size)))),
    dm2_user_indexes@rvadm1 di
   PLAN (d1
    WHERE initarray(ml_start,evaluate(d1.seq,1,1,(ml_start+ mn_size))))
    JOIN (di
    WHERE expand(ml_idx,ml_start,(ml_start+ (mn_size - 1)),di.index_name,m_index_usage->index_list[
     ml_idx].s_index_name))
   HEAD REPORT
    pl_cur_index_idx = 0
   DETAIL
    pl_cur_index_idx = locateval(ml_num,1,m_index_usage->l_index_cnt,di.index_name,m_index_usage->
     index_list[ml_num].s_index_name), m_index_usage->index_list[pl_cur_index_idx].s_table_name =
    trim(di.table_name,3)
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(concat("Error while selecting from DBA_INDEXES@RVADM1: ",dm_err->emsg),dm_err->
    logfile,1)
   GO TO exit_program
  ENDIF
  SET mn_stat = alterlist(m_index_usage->index_list,m_index_usage->l_index_cnt)
 ENDIF
 SET dm_err->eproc = "Clean up the object with query..."
 CALL disp_msg(" ",dm_err->logfile,0)
 SET mn_stat = remove(ms_temp_tran_file)
 IF (dm2_push_cmd(concat("drop program _",ms_object_name,":GROUP99 go"),1)=0)
  CALL disp_msg("Ignore any error generated from the dropping of the translated program",dm_err->
   logfile,0)
  SET dm_err->err_ind = 0
 ENDIF
 SUBROUTINE sbr_parse_query(null)
   SET dm_err->eproc = "Gathering statistics from the PLAN_TABLE..."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM plan_table pt
    WHERE pt.statement_id=patstring(concat(curuser,":*"))
    HEAD REPORT
     pl_plan_idx = 0
    DETAIL
     ms_query_operation = trim(pt.operation,3), ms_query_object_name = trim(pt.object_name,3),
     ms_query_options = trim(pt.options,3),
     mf_query_cost = pt.cost, pl_plan_idx = locateval(ml_num,1,m_plan_table->l_plan_list_cnt,pt
      .statement_id,m_plan_table->plan_list[ml_num].s_statement_id)
     IF (pl_plan_idx=0)
      m_plan_table->l_plan_list_cnt = (m_plan_table->l_plan_list_cnt+ 1)
      IF (mod(m_plan_table->l_plan_list_cnt,10)=1)
       mn_stat = alterlist(m_plan_table->plan_list,(m_plan_table->l_plan_list_cnt+ 9))
      ENDIF
      m_plan_table->plan_list[m_plan_table->l_plan_list_cnt].s_statement_id = trim(pt.statement_id,3),
      m_plan_table->plan_list[m_plan_table->l_plan_list_cnt].s_optimizer_mode = pt.optimizer,
      m_plan_table->plan_list[m_plan_table->l_plan_list_cnt].f_cost = pt.cost
     ELSE
      m_plan_table->plan_list[pl_plan_idx].f_cost = (m_plan_table->plan_list[pl_plan_idx].f_cost+ pt
      .cost)
     ENDIF
     IF (ms_query_options="FULL"
      AND ms_query_object_name != "DUAL")
      mn_stat = sbr_add_full_table_scan(ms_query_object_name)
     ELSEIF (ms_query_operation="INDEX")
      mn_stat = sbr_add_index_usage(ms_query_object_name,ms_query_options)
     ENDIF
     mf_script_total_cost = (mf_script_total_cost+ pt.cost)
    FOOT REPORT
     mn_stat = alterlist(m_plan_table->plan_list,m_plan_table->l_plan_list_cnt)
     IF (mf_script_total_cost > mf_max_script_cost)
      mn_stat = sbr_add_error(15001,
       "The cost for all the queries in this script is above the maximum level allowed.")
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE sbr_parse_index_only(null)
   SET dm_err->eproc = "Gathering index usage from the PLAN_TABLE..."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM plan_table pt
    WHERE pt.statement_id=patstring(concat(curuser,":*"))
    DETAIL
     ms_query_operation = trim(pt.operation,3), ms_query_object_name = trim(pt.object_name,3),
     ms_query_options = trim(pt.options,3)
     IF (ms_query_operation="INDEX")
      mn_stat = sbr_add_index_usage(ms_query_object_name,ms_query_options)
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE sbr_add_full_table_scan(ps_table_name)
  IF (locateval(ml_num,1,m_full_table_scan->l_table_cnt,ps_table_name,m_full_table_scan->table_list[
   ml_num].s_table_name)=0)
   SET m_full_table_scan->l_table_cnt = (m_full_table_scan->l_table_cnt+ 1)
   SET mn_stat = alterlist(m_full_table_scan->table_list,m_full_table_scan->l_table_cnt)
   SET m_full_table_scan->table_list[m_full_table_scan->l_table_cnt].s_table_name = ps_table_name
   SET ms_message = concat("Full table scan found on ",ps_table_name,".")
   SET mn_stat = sbr_add_error(15003,ms_message)
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_add_index_usage(ps_index_name,ps_options)
   DECLARE pl_index = i4 WITH private, noconstant(0)
   SET pl_index = locateval(ml_num,1,m_index_usage->l_index_cnt,ps_index_name,m_index_usage->
    index_list[ml_num].s_index_name)
   IF (pl_index=0)
    SET m_index_usage->l_index_cnt = (m_index_usage->l_index_cnt+ 1)
    SET mn_stat = alterlist(m_index_usage->index_list,m_index_usage->l_index_cnt)
    SET pl_index = m_index_usage->l_index_cnt
    SET m_index_usage->index_list[pl_index].s_index_name = ps_index_name
    SET m_index_usage->index_list[pl_index].s_options = ps_options
    IF (ps_options="FULL SCAN")
     SET ms_message = concat("Fast full index scan found on ",ps_index_name,".")
     SET mn_stat = sbr_add_error(15010,ms_message)
    ENDIF
   ENDIF
   SET m_index_usage->index_list[pl_index].l_usage_cnt = (m_index_usage->index_list[pl_index].
   l_usage_cnt+ 1)
   RETURN(1)
 END ;Subroutine
#xml_check
 IF (locateval(ml_num,1,m_exceptions->l_num_exceptions,"TRANSLATE_EXCEPTION",m_exceptions->
  exceptions[ml_num].s_threshold_type,
  "XML",m_exceptions->exceptions[ml_num].s_threshold_char) > 0)
  SET dm_err->eproc = "Translate with XML exception found.  Skipping Translate with XML..."
  CALL disp_msg(" ",dm_err->logfile,0)
  GO TO check_check
 ENDIF
 SET dm_err->eproc = "Parsing the object with XML..."
 CALL disp_msg(" ",dm_err->logfile,0)
 DELETE  FROM dm_threshold_criteria d
  WHERE d.threshold_id=mf_threshold_id
   AND d.criteria_name="TRANSLATE_ERROR"
   AND d.criteria_char=ms_object_name
   AND d.criteria_formula="XML"
  WITH nocounter
 ;end delete
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(concat("Error while deleting from DM_THRESHOLD_CRITERIA: ",dm_err->emsg),dm_err->
   logfile,1)
  ROLLBACK
  GO TO exit_program
 ENDIF
 COMMIT
 IF (dm2_push_cmd(concat("translate into '",ms_temp_tran_file,"' ",ms_object_name,":DBA with xml go"),
  1)=0)
  SET dm_err->err_ind = 0
  SET dm_err->eproc = "Ignore any error generated during translation"
  CALL disp_msg(" ",dm_err->logfile,0)
  INSERT  FROM dm_threshold_criteria d
   SET d.threshold_criteria_id = seq(dm2_dar_seq,nextval), d.threshold_id = mf_threshold_id, d
    .criteria_name = "TRANSLATE_ERROR",
    d.criteria_char = ms_object_name, d.criteria_formula = "XML", d.boundary_formula = dm_err->emsg,
    d.action = "PASSED", d.os_type = "ALL"
   WITH nocounter
  ;end insert
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(concat("Error while inserting into DM_THRESHOLD_CRITERIA: ",dm_err->emsg),dm_err->
    logfile,1)
   ROLLBACK
   GO TO exit_program
  ENDIF
  COMMIT
 ENDIF
 IF (findfile(ms_temp_tran_file)=0)
  SET dm_err->err_ind = 1
  CALL disp_msg("Output file from Translate with XML not found.  Exiting...",dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (mn_script_info_only_ind=0)
  IF (sbr_parse_xml(ms_temp_tran_file)=0)
   CALL disp_msg(concat("Error while reading the XML translate 1: ",dm_err->emsg),dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  SET mn_stat = sbr_check_cclaudit_rule(null)
  SET mn_stat = sbr_check_oracle_table(null)
  SET mn_stat = sbr_check_obsolete_table(null)
  SET mn_stat = sbr_check_code_value(null)
  SET mn_stat = sbr_check_gold_master(null)
 ELSE
  IF (sbr_parse_table_exec_dependency(ms_temp_tran_file)=0)
   CALL disp_msg(concat("Error while reading the XML translate 2: ",dm_err->emsg),dm_err->logfile,1)
   GO TO exit_program
  ENDIF
  SET mn_stat = sbr_check_oracle_table(null)
 ENDIF
 SET dm_err->eproc = "Clean up the object with XML..."
 CALL disp_msg(" ",dm_err->logfile,0)
 SET mn_stat = remove(ms_temp_tran_file)
 SUBROUTINE sbr_check_cclaudit_rule(null)
  IF ((m_cclaudit_rec->l_name_type_cnt > 0))
   SET ml_total = (ceil((cnvtreal(m_cclaudit_rec->l_name_type_cnt)/ mn_size)) * mn_size)
   SET mn_stat = alterlist(m_cclaudit_rec->name_types,ml_total)
   SET ml_start = 1
   FOR (ml_idx = (m_cclaudit_rec->l_name_type_cnt+ 1) TO ml_total)
    SET m_cclaudit_rec->name_types[ml_idx].s_name = m_cclaudit_rec->name_types[m_cclaudit_rec->
    l_name_type_cnt].s_name
    SET m_cclaudit_rec->name_types[ml_idx].s_type = m_cclaudit_rec->name_types[m_cclaudit_rec->
    l_name_type_cnt].s_type
   ENDFOR
   SET mn_stat = sbr_check_cclaudit_name(null)
   SET mn_stat = sbr_check_cclaudit_type(null)
   SET mn_stat = sbr_check_cclaudit_event(null)
   SET mn_stat = alterlist(m_cclaudit_rec->name_types,m_cclaudit_rec->l_name_type_cnt)
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_check_cclaudit_name(null)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ml_total - 1)/ mn_size)))),
     audit_name_def a
    PLAN (d1
     WHERE initarray(ml_start,evaluate(d1.seq,1,1,(ml_start+ mn_size))))
     JOIN (a
     WHERE expand(ml_idx,ml_start,(ml_start+ (mn_size - 1)),a.audit_name,m_cclaudit_rec->name_types[
      ml_idx].s_name,
      mn_size))
    DETAIL
     pl_found_idx = locateval(ml_num,1,m_cclaudit_rec->l_name_type_cnt,a.audit_name,m_cclaudit_rec->
      name_types[ml_num].s_name), m_cclaudit_rec->name_types[pl_found_idx].l_name_nbr = a
     .audit_name_def_nbr
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(concat("Error while selecting from AUDIT_NAME_DEF: ",dm_err->emsg),dm_err->logfile,
     1)
    GO TO exit_program
   ENDIF
   FOR (pl_cur_name = 1 TO m_cclaudit_rec->l_name_type_cnt)
     IF ((m_cclaudit_rec->name_types[pl_cur_name].l_name_nbr=0))
      SET ms_message = concat("An invalid NAME parameter ",m_cclaudit_rec->name_types[pl_cur_name].
       s_name," is used for CCLAUDIT.")
      SET mn_stat = sbr_add_error(15005,ms_message)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_check_cclaudit_type(null)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ml_total - 1)/ mn_size)))),
     audit_type_def a
    PLAN (d1
     WHERE initarray(ml_start,evaluate(d1.seq,1,1,(ml_start+ mn_size))))
     JOIN (a
     WHERE expand(ml_idx,ml_start,(ml_start+ (mn_size - 1)),a.audit_type,m_cclaudit_rec->name_types[
      ml_idx].s_type,
      mn_size))
    DETAIL
     pl_found_idx = locateval(ml_num,1,m_cclaudit_rec->l_name_type_cnt,a.audit_type,m_cclaudit_rec->
      name_types[ml_num].s_type), m_cclaudit_rec->name_types[pl_found_idx].l_type_nbr = a
     .audit_type_def_nbr
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(concat("Error while selecting from AUDIT_TYPE_DEF: ",dm_err->emsg),dm_err->logfile,
     1)
    GO TO exit_program
   ENDIF
   FOR (pl_cur_type = 1 TO m_cclaudit_rec->l_name_type_cnt)
     IF ((m_cclaudit_rec->name_types[pl_cur_type].s_type != " ")
      AND (m_cclaudit_rec->name_types[pl_cur_type].l_type_nbr=0))
      SET ms_message = concat("An invalid TYPE parameter ",m_cclaudit_rec->name_types[pl_cur_type].
       s_type," is used for CCLAUDIT.")
      SET mn_stat = sbr_add_error(15005,ms_message)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_check_cclaudit_event(null)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ml_total - 1)/ mn_size)))),
     audit_event a
    PLAN (d1
     WHERE initarray(ml_start,evaluate(d1.seq,1,1,(ml_start+ mn_size))))
     JOIN (a
     WHERE expand(ml_idx,ml_start,(ml_start+ (mn_size - 1)),a.audit_name_def_nbr,m_cclaudit_rec->
      name_types[ml_idx].l_name_nbr,
      a.audit_type_def_nbr,m_cclaudit_rec->name_types[ml_idx].l_type_nbr,mn_size))
    DETAIL
     pl_found_idx = locateval(ml_num,1,m_cclaudit_rec->l_name_type_cnt,a.audit_name_def_nbr,
      m_cclaudit_rec->name_types[ml_num].l_name_nbr,
      a.audit_type_def_nbr,m_cclaudit_rec->name_types[ml_num].l_type_nbr), m_cclaudit_rec->
     name_types[pl_found_idx].n_event_exists_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(concat("Error while selecting from AUDIT_EVENT: ",dm_err->emsg),dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   FOR (pl_cur_event = 1 TO m_cclaudit_rec->l_name_type_cnt)
     IF ((m_cclaudit_rec->name_types[pl_cur_event].l_name_nbr > 0)
      AND (m_cclaudit_rec->name_types[pl_cur_event].l_type_nbr > 0)
      AND (m_cclaudit_rec->name_types[pl_cur_event].n_event_exists_ind=0))
      SET ms_message = concat("An invalid NAME and TYPE parameter ",m_cclaudit_rec->name_types[
       pl_cur_event].s_name," and ",m_cclaudit_rec->name_types[pl_cur_event].s_type,
       " is used for CCLAUDIT.")
      SET mn_stat = sbr_add_error(15005,ms_message)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_check_oracle_table(null)
  IF ((m_ora_table_rec->l_num_table > 0))
   SET ml_total = (ceil((cnvtreal(m_ora_table_rec->l_num_table)/ mn_size)) * mn_size)
   SET mn_stat = alterlist(m_ora_table_rec->tables,ml_total)
   SET ml_start = 1
   FOR (ml_idx = (m_ora_table_rec->l_num_table+ 1) TO ml_total)
     SET m_ora_table_rec->tables[ml_idx].s_table_name = m_ora_table_rec->tables[m_ora_table_rec->
     l_num_table].s_table_name
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ml_total - 1)/ mn_size)))),
     dba_objects do
    PLAN (d1
     WHERE initarray(ml_start,evaluate(d1.seq,1,1,(ml_start+ mn_size))))
     JOIN (do
     WHERE do.object_type IN ("TABLE", "VIEW")
      AND expand(ml_idx,ml_start,(ml_start+ (mn_size - 1)),do.object_name,m_ora_table_rec->tables[
      ml_idx].s_table_name,
      mn_size))
    DETAIL
     pl_found_idx = locateval(ml_num,1,m_ora_table_rec->l_num_table,do.object_name,m_ora_table_rec->
      tables[ml_num].s_table_name), m_ora_table_rec->tables[pl_found_idx].s_entity_type = do
     .object_type, m_ora_table_rec->tables[pl_found_idx].n_ora_tab_ind = 1
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    SET mn_stat = alterlist(m_ora_table_rec->tables,m_ora_table_rec->l_num_table)
    CALL disp_msg(concat("Error while selecting from DBA_OBJECTS: ",dm_err->emsg),dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ml_total - 1)/ mn_size)))),
     dba_objects@rvadm1 do
    PLAN (d1
     WHERE initarray(ml_start,evaluate(d1.seq,1,1,(ml_start+ mn_size))))
     JOIN (do
     WHERE do.object_type IN ("TABLE", "VIEW", "SYNONYM")
      AND expand(ml_idx,ml_start,(ml_start+ (mn_size - 1)),do.object_name,m_ora_table_rec->tables[
      ml_idx].s_table_name,
      0,m_ora_table_rec->tables[ml_idx].n_ora_tab_ind,mn_size))
    DETAIL
     pl_found_idx = locateval(ml_num,1,m_ora_table_rec->l_num_table,do.object_name,m_ora_table_rec->
      tables[ml_num].s_table_name)
     IF (do.object_type="TABLE")
      m_ora_table_rec->tables[pl_found_idx].s_entity_type = "TABLE"
     ELSEIF ((m_ora_table_rec->tables[pl_found_idx].s_entity_type != "TABLE"))
      m_ora_table_rec->tables[pl_found_idx].s_entity_type = "VIEW"
     ENDIF
     m_ora_table_rec->tables[pl_found_idx].n_ora_tab_ind = 1
    WITH nocounter
   ;end select
   SET mn_stat = alterlist(m_ora_table_rec->tables,m_ora_table_rec->l_num_table)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(concat("Error while selecting from DBA_OBJECTS@RVADM1: ",dm_err->emsg),dm_err->
     logfile,1)
    GO TO exit_program
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_check_obsolete_table(null)
  IF ((m_ora_table_rec->l_num_table > 0))
   SET ml_total = (ceil((cnvtreal(m_ora_table_rec->l_num_table)/ mn_size)) * mn_size)
   SET mn_stat = alterlist(m_ora_table_rec->tables,ml_total)
   SET ml_start = 1
   FOR (ml_idx = (m_ora_table_rec->l_num_table+ 1) TO ml_total)
     SET m_ora_table_rec->tables[ml_idx].s_table_name = m_ora_table_rec->tables[m_ora_table_rec->
     l_num_table].s_table_name
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ml_total - 1)/ mn_size)))),
     dm_info di
    PLAN (d1
     WHERE initarray(ml_start,evaluate(d1.seq,1,1,(ml_start+ mn_size))))
     JOIN (di
     WHERE di.info_domain="OBSOLETE_OBJECT"
      AND expand(ml_idx,ml_start,(ml_start+ (mn_size - 1)),di.info_name,m_ora_table_rec->tables[
      ml_idx].s_table_name,
      "TABLE",m_ora_table_rec->tables[ml_idx].s_entity_type,mn_size)
      AND di.info_char="TABLE")
    DETAIL
     pl_found_idx = locateval(ml_num,1,m_ora_table_rec->l_num_table,di.info_name,m_ora_table_rec->
      tables[ml_num].s_table_name,
      "TABLE",m_ora_table_rec->tables[ml_idx].s_entity_type), m_ora_table_rec->tables[ml_num].
     n_obs_tab_ind = 1
    WITH nocounter
   ;end select
   SET mn_stat = alterlist(m_ora_table_rec->tables,m_ora_table_rec->l_num_table)
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(concat("Error while selecting from DM_INFO: ",dm_err->emsg),dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   FOR (pl_cur_table = 1 TO m_ora_table_rec->l_num_table)
     IF ((m_ora_table_rec->tables[pl_cur_table].n_obs_tab_ind=1))
      SET ms_message = concat("An obsolete table ",m_ora_table_rec->tables[pl_cur_table].s_table_name,
       " is used in a CCL statement.")
      SET mn_stat = sbr_add_error(15011,ms_message)
     ENDIF
   ENDFOR
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_check_code_value(null)
  IF (locateval(ml_num,1,m_table_access_rec->list[1].l_num_table,"CODE_VALUE",m_table_access_rec->
   list[1].table_list[ml_num].s_table_name))
   SET mn_stat = sbr_add_error(15006,
    "A select from the CODE_VALUE table is used. A UAR call may be possible.")
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_check_gold_master(null)
   IF ((m_table_access_rec->list[2].l_num_table=0))
    RETURN(1)
   ENDIF
   SET ml_total = (ceil((cnvtreal(m_table_access_rec->list[2].l_num_table)/ mn_size)) * mn_size)
   SET mn_stat = alterlist(m_table_access_rec->list[2].table_list,ml_total)
   SET ml_start = 1
   FOR (ml_idx = (m_table_access_rec->list[2].l_num_table+ 1) TO ml_total)
     SET m_table_access_rec->list[2].table_list[ml_idx].s_table_name = m_table_access_rec->list[2].
     table_list[m_table_access_rec->list[2].l_num_table].s_table_name
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ml_total - 1)/ mn_size)))),
     dm_script_info_tbl_master dsitm
    PLAN (d1
     WHERE initarray(ml_start,evaluate(d1.seq,1,1,(ml_start+ mn_size))))
     JOIN (dsitm
     WHERE expand(ml_idx,ml_start,(ml_start+ (mn_size - 1)),dsitm.table_name,m_table_access_rec->
      list[2].table_list[ml_idx].s_table_name,
      mn_size))
    HEAD REPORT
     pl_cur_gm_list_idx = 0, pl_cur_valid_script_list_idx = 0
    DETAIL
     IF (dsitm.insert_ind=1)
      pl_cur_gm_list_idx = sbr_add_gm_locked_table(dsitm.table_name,mn_insert), mn_stat =
      sbr_add_gm_valid_script(pl_cur_gm_list_idx,dsitm.script_name)
     ENDIF
     IF (dsitm.update_ind=1)
      pl_cur_gm_list_idx = sbr_add_gm_locked_table(dsitm.table_name,mn_update), mn_stat =
      sbr_add_gm_valid_script(pl_cur_gm_list_idx,dsitm.script_name)
     ENDIF
     IF (dsitm.delete_ind=1)
      pl_cur_gm_list_idx = sbr_add_gm_locked_table(dsitm.table_name,mn_delete), mn_stat =
      sbr_add_gm_valid_script(pl_cur_gm_list_idx,dsitm.script_name)
     ENDIF
    FOOT REPORT
     FOR (pl_cur_gm_list_idx = 1 TO m_gm_struct->l_gm_locked_list_size)
       pl_found_idx = locateval(ml_num,1,m_table_access_rec->list[2].l_num_table,m_gm_struct->
        gm_locked_list[pl_cur_gm_list_idx].s_table_name,m_table_access_rec->list[2].table_list[ml_num
        ].s_table_name,
        m_gm_struct->gm_locked_list[pl_cur_gm_list_idx].n_operation_type,m_table_access_rec->list[2].
        table_list[ml_num].n_operation_type), ms_query_operation = evaluate(m_table_access_rec->list[
        2].table_list[pl_found_idx].n_operation_type,mn_update,"UPDATE",mn_insert,"INSERT",
        mn_delete,"DELETE")
       IF (pl_found_idx > 0)
        pl_found_idx = locateval(ml_num,1,m_gm_struct->gm_locked_list[pl_cur_gm_list_idx].
         l_valid_script_list_size,ms_object_name,m_gm_struct->gm_locked_list[pl_cur_gm_list_idx].
         valid_script_list[ml_num].s_valid_script_name)
        IF (pl_found_idx=0)
         ms_message = concat("Gold master ",ms_query_operation," script is not used for table ",
          m_gm_struct->gm_locked_list[pl_cur_gm_list_idx].s_table_name), mn_stat = sbr_add_error(
          15000,ms_message)
        ENDIF
       ENDIF
     ENDFOR
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(concat("Error while selecting from DM_SCRIPT_INFO_TBL_MASTER: ",dm_err->emsg),
     dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE sbr_add_gm_locked_table(ps_table_name,pn_operation_type)
   DECLARE pl_gm_list_idx = i4 WITH private, noconstant(0)
   SET pl_gm_list_idx = locateval(ml_num,1,m_gm_struct->l_gm_locked_list_size,ps_table_name,
    m_gm_struct->gm_locked_list[ml_num].s_table_name,
    pn_operation_type,m_gm_struct->gm_locked_list[ml_num].n_operation_type)
   IF (pl_gm_list_idx=0)
    SET pl_gm_list_idx = (m_gm_struct->l_gm_locked_list_size+ 1)
    SET mn_stat = alterlist(m_gm_struct->gm_locked_list,pl_gm_list_idx)
    SET m_gm_struct->gm_locked_list[pl_gm_list_idx].s_table_name = ps_table_name
    SET m_gm_struct->gm_locked_list[pl_gm_list_idx].n_operation_type = pn_operation_type
    SET m_gm_struct->l_gm_locked_list_size = (m_gm_struct->l_gm_locked_list_size+ 1)
   ENDIF
   RETURN(pl_gm_list_idx)
 END ;Subroutine
 SUBROUTINE sbr_add_gm_valid_script(pl_gm_list_idx,ps_script_name)
   DECLARE pl_valid_script_list_idx = i4 WITH private, noconstant(0)
   SET pl_valid_script_list_idx = (m_gm_struct->gm_locked_list[pl_gm_list_idx].
   l_valid_script_list_size+ 1)
   SET mn_stat = alterlist(m_gm_struct->gm_locked_list[pl_gm_list_idx].valid_script_list,
    pl_valid_script_list_idx)
   SET m_gm_struct->gm_locked_list[pl_gm_list_idx].valid_script_list[pl_valid_script_list_idx].
   s_valid_script_name = ps_script_name
   SET m_gm_struct->gm_locked_list[pl_gm_list_idx].l_valid_script_list_size =
   pl_valid_script_list_idx
   RETURN(1)
 END ;Subroutine
#check_check
 IF (locateval(ml_num,1,m_exceptions->l_num_exceptions,"TRANSLATE_EXCEPTION",m_exceptions->
  exceptions[ml_num].s_threshold_type,
  "CHECK",m_exceptions->exceptions[ml_num].s_threshold_char) > 0)
  SET dm_err->eproc = "Translate with Check exception found.  Skipping Translate with Check..."
  CALL disp_msg(" ",dm_err->logfile,0)
  GO TO non_translate_check
 ENDIF
 SET dm_err->eproc = "Parsing the object with Check..."
 CALL disp_msg(" ",dm_err->logfile,0)
 DELETE  FROM dm_threshold_criteria d
  WHERE d.threshold_id=mf_threshold_id
   AND d.criteria_name="TRANSLATE_ERROR"
   AND d.criteria_char=ms_object_name
   AND d.criteria_formula="CHECK"
  WITH nocounter
 ;end delete
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(concat("Error while deleting from DM_THRESHOLD_CRITERIA: ",dm_err->emsg),dm_err->
   logfile,1)
  ROLLBACK
  GO TO exit_program
 ENDIF
 COMMIT
 IF (dm2_push_cmd(concat("translate into '",ms_temp_tran_file,"' ",ms_object_name,
   ":DBA with check go"),1)=0)
  SET dm_err->err_ind = 0
  SET dm_err->eproc = "Ignore any error generated during translation"
  CALL disp_msg(" ",dm_err->logfile,0)
  INSERT  FROM dm_threshold_criteria d
   SET d.threshold_criteria_id = seq(dm2_dar_seq,nextval), d.threshold_id = mf_threshold_id, d
    .criteria_name = "TRANSLATE_ERROR",
    d.criteria_char = ms_object_name, d.criteria_formula = "CHECK", d.boundary_formula = dm_err->emsg,
    d.action = "PASSED", d.os_type = "ALL"
   WITH nocounter
  ;end insert
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(concat("Error while inserting into DM_THRESHOLD_CRITERIA: ",dm_err->emsg),dm_err->
    logfile,1)
   ROLLBACK
   GO TO exit_program
  ENDIF
  COMMIT
 ENDIF
 IF (findfile(ms_temp_tran_file)=0)
  SET dm_err->err_ind = 1
  CALL disp_msg("Output file from Translate with Check not found.  Exiting...",dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 IF (sbr_parse_check(ms_temp_tran_file)=0)
  CALL disp_msg(concat("Error while reading the CHECK translate: ",dm_err->emsg),dm_err->logfile,1)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Clean up the object with CHECK..."
 CALL disp_msg(" ",dm_err->logfile,0)
 SET mn_stat = remove(ms_temp_tran_file)
 SUBROUTINE sbr_parse_check(ps_check_filename)
   DECLARE ml_colon_pos = i4 WITH protect, noconstant(0)
   DECLARE ml_carrot_pos = i4 WITH protect, noconstant(0)
   DECLARE ml_table_ndx = i4 WITH protect, noconstant(0)
   DECLARE ml_column_ndx = i4 WITH protect, noconstant(0)
   DECLARE ms_table_name = vc WITH protect, noconstant(" ")
   DECLARE ms_column_name = vc WITH protect, noconstant(" ")
   FREE DEFINE rtl2
   DEFINE rtl2 value(ps_check_filename)
   SELECT INTO "nl:"
    t.line
    FROM rtl2t t
    WHERE t.line > " "
    DETAIL
     ml_colon_pos = findstring(":",t.line), ml_period_pos = findstring(".",t.line,(ml_colon_pos+ 1)),
     ml_carrot_pos = findstring("^",t.line,(ml_period_pos+ 1))
     IF (ml_colon_pos > 0
      AND ml_period_pos > 0
      AND ml_carrot_pos > 0)
      ms_table_name = trim(substring((ml_colon_pos+ 1),((ml_period_pos - ml_colon_pos) - 1),t.line),3
       ), ms_column_name = trim(substring((ml_period_pos+ 1),((ml_carrot_pos - ml_period_pos) - 1),t
        .line),3)
      IF ( NOT (ms_table_name IN ("", " ", null))
       AND  NOT (ms_column_name IN ("", " ", null)))
       ml_table_ndx = locateval(ml_num,1,m_ora_table_rec->l_num_table,ms_table_name,m_ora_table_rec->
        tables[ml_num].s_table_name,
        1,m_ora_table_rec->tables[ml_num].n_ora_tab_ind)
       IF (ml_table_ndx > 0)
        ml_column_ndx = locateval(ml_num,1,m_ora_table_rec->tables[ml_table_ndx].l_num_column,
         ms_column_name,m_ora_table_rec->tables[ml_table_ndx].columns[ml_num].s_column_name)
        IF (ml_column_ndx=0)
         m_ora_table_rec->tables[ml_table_ndx].l_num_column = (m_ora_table_rec->tables[ml_table_ndx].
         l_num_column+ 1), stat = alterlist(m_ora_table_rec->tables[ml_table_ndx].columns,
          m_ora_table_rec->tables[ml_table_ndx].l_num_column), m_ora_table_rec->tables[ml_table_ndx].
         columns[m_ora_table_rec->tables[ml_table_ndx].l_num_column].s_column_name = ms_column_name
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#non_translate_check
 IF (mn_script_info_only_ind=0)
  SET mn_stat = sbr_check_binary_size(null)
 ENDIF
 SUBROUTINE sbr_check_binary_size(null)
   DECLARE mf_binary_size = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM dprotect d
    PLAN (d
     WHERE d.object="P"
      AND d.object_name=ms_object_name
      AND d.group=0)
    DETAIL
     mf_binary_size = d.binary_cnt
    WITH nocounter, maxqual(d,1)
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(concat("Error while selecting from DPROTECT: ",dm_err->emsg),dm_err->logfile,1)
    GO TO exit_program
   ENDIF
   IF (mf_binary_size > mf_max_binary_size)
    SET ms_message = concat("The ccl script binary size ",trim(cnvtstring(mf_binary_size),3),
     " exceeds the optimal limit of ",trim(cnvtstring(mf_max_binary_size),3),".")
    SET mn_stat = sbr_add_error(15014,ms_message)
   ENDIF
   RETURN(1)
 END ;Subroutine
 IF (realtime_flag=0)
  SET dm_err->eproc = "Updating script information tables..."
  CALL disp_msg(" ",dm_err->logfile,0)
  DELETE  FROM dm_script_failure dsf
   WHERE dsf.environ_id=mf_cur_env_id
    AND dsf.script_name=ms_object_name
    AND dsf.project_instance=mf_project_instance
   WITH nocounter
  ;end delete
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(concat("Error while deleting from DM_SCRIPT_FAILURE: ",dm_err->emsg),dm_err->logfile,
    1)
   ROLLBACK
   GO TO exit_program
  ENDIF
  IF (ml_err_list_size > 0)
   INSERT  FROM dm_script_failure dsf,
     (dummyt d  WITH seq = ml_err_list_size)
    SET dsf.environ_id = mf_cur_env_id, dsf.script_name = ms_object_name, dsf.project_instance =
     mf_project_instance,
     dsf.error_cd = dm_script_scanner_reply->err_list[d.seq].fail_number, dsf.error_text =
     dm_script_scanner_reply->err_list[d.seq].fail_message, dsf.failed_dt_tm = sysdate
    PLAN (d)
     JOIN (dsf)
    WITH nocounter
   ;end insert
  ENDIF
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(concat("Error while inserting into DM_SCRIPT_FAILURE: ",dm_err->emsg),dm_err->
    logfile,1)
   ROLLBACK
   GO TO exit_program
  ENDIF
  COMMIT
  DELETE  FROM dm_script_info_ndx_env dne
   WHERE dne.script_name=ms_object_name
    AND dne.environment_id=mf_cur_env_id
   WITH nocounter
  ;end delete
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(concat("Error while deleting from DM_SCRIPT_INFO_NDX_ENV: ",dm_err->emsg),dm_err->
    logfile,1)
   ROLLBACK
   GO TO exit_program
  ENDIF
  IF ((m_index_usage->l_index_cnt > 0))
   INSERT  FROM dm_script_info_ndx_env dne,
     (dummyt d  WITH seq = m_index_usage->l_index_cnt)
    SET dne.script_name = ms_object_name, dne.environment_id = mf_cur_env_id, dne.index_name =
     m_index_usage->index_list[d.seq].s_index_name,
     dne.table_name = m_index_usage->index_list[d.seq].s_table_name, dne.index_cnt = m_index_usage->
     index_list[d.seq].l_usage_cnt, dne.updt_dt_tm = sysdate
    PLAN (d)
     JOIN (dne)
    WITH nocounter
   ;end insert
  ENDIF
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(concat("Error while inserting into DM_SCRIPT_INFO_NDX_ENV: ",dm_err->emsg),dm_err->
    logfile,1)
   ROLLBACK
   GO TO exit_program
  ENDIF
  COMMIT
  DELETE  FROM dm_script_info_tbl_env dte
   WHERE dte.script_name=ms_object_name
    AND dte.environment_id=mf_cur_env_id
   WITH nocounter
  ;end delete
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(concat("Error while deleting from DM_SCRIPT_INFO_TBL_ENV: ",dm_err->emsg),dm_err->
    logfile,1)
   ROLLBACK
   GO TO exit_program
  ENDIF
  IF ((m_ora_table_rec->l_num_table > 0))
   INSERT  FROM dm_script_info_tbl_env dte,
     (dummyt d  WITH seq = m_ora_table_rec->l_num_table)
    SET dte.script_name = ms_object_name, dte.environment_id = mf_cur_env_id, dte.table_name =
     m_ora_table_rec->tables[d.seq].s_table_name,
     dte.entity_type = m_ora_table_rec->tables[d.seq].s_entity_type, dte.select_ind = m_ora_table_rec
     ->tables[d.seq].l_select_cnt, dte.update_ind = m_ora_table_rec->tables[d.seq].l_update_cnt,
     dte.insert_ind = m_ora_table_rec->tables[d.seq].l_insert_cnt, dte.delete_ind = m_ora_table_rec->
     tables[d.seq].l_delete_cnt, dte.updt_dt_tm = sysdate
    PLAN (d
     WHERE (m_ora_table_rec->tables[d.seq].n_ora_tab_ind=1))
     JOIN (dte)
    WITH nocounter
   ;end insert
  ENDIF
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(concat("Error while inserting into DM_SCRIPT_INFO_TBL_ENV: ",dm_err->emsg),dm_err->
    logfile,1)
   ROLLBACK
   GO TO exit_program
  ENDIF
  COMMIT
  DELETE  FROM dm_script_info_col_env dce
   WHERE dce.script_name=ms_object_name
    AND dce.environment_id=mf_cur_env_id
   WITH nocounter
  ;end delete
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(concat("Error while deleting from DM_SCRIPT_INFO_COL_ENV: ",dm_err->emsg),dm_err->
    logfile,1)
   ROLLBACK
   GO TO exit_program
  ENDIF
  IF ((m_ora_table_rec->l_num_table > 0))
   INSERT  FROM dm_script_info_col_env dce,
     (dummyt d  WITH seq = m_ora_table_rec->l_num_table),
     (dummyt d2  WITH seq = 1)
    SET dce.script_name = ms_object_name, dce.environment_id = mf_cur_env_id, dce.table_name =
     m_ora_table_rec->tables[d.seq].s_table_name,
     dce.column_name = m_ora_table_rec->tables[d.seq].columns[d2.seq].s_column_name, dce.updt_dt_tm
      = sysdate
    PLAN (d
     WHERE maxrec(d2,m_ora_table_rec->tables[d.seq].l_num_column))
     JOIN (d2)
     JOIN (dce)
    WITH nocounter
   ;end insert
  ENDIF
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(concat("Error while inserting into DM_SCRIPT_INFO_COL_ENV: ",dm_err->emsg),dm_err->
    logfile,1)
   ROLLBACK
   GO TO exit_program
  ENDIF
  COMMIT
  DELETE  FROM dm_script_info_seq_env dce
   WHERE dce.script_name=ms_object_name
    AND dce.environment_id=mf_cur_env_id
   WITH nocounter
  ;end delete
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(concat("Error while deleting from DM_SCRIPT_INFO_SEQ_ENV: ",dm_err->emsg),dm_err->
    logfile,1)
   ROLLBACK
   GO TO exit_program
  ENDIF
  IF ((m_sequence->l_seq_cnt > 0))
   INSERT  FROM dm_script_info_seq_env dse,
     (dummyt d  WITH seq = m_sequence->l_seq_cnt)
    SET dse.script_name = ms_object_name, dse.environment_id = mf_cur_env_id, dse.sequence_name =
     m_sequence->seq_list[d.seq].s_seq_name,
     dse.sequence_cnt = m_sequence->seq_list[d.seq].l_usage_cnt, dse.updt_dt_tm = sysdate
    PLAN (d)
     JOIN (dse)
    WITH nocounter
   ;end insert
  ENDIF
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(concat("Error while inserting into DM_SCRIPT_INFO_SEQ_ENV: ",dm_err->emsg),dm_err->
    logfile,1)
   ROLLBACK
   GO TO exit_program
  ENDIF
  COMMIT
  DELETE  FROM dm_script_info_dependency dd
   WHERE dd.parent_script_name=ms_object_name
    AND dd.environment_id=mf_cur_env_id
   WITH nocounter
  ;end delete
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(concat("Error while deleting from DM_SCRIPT_INFO_DEPENDENCY: ",dm_err->emsg),dm_err
    ->logfile,1)
   ROLLBACK
   GO TO exit_program
  ENDIF
  IF ((m_dependency_rec->l_child_cnt > 0))
   INSERT  FROM dm_script_info_dependency dd,
     (dummyt d  WITH seq = m_dependency_rec->l_child_cnt)
    SET dd.parent_script_name = ms_object_name, dd.environment_id = mf_cur_env_id, dd
     .child_component_name = m_dependency_rec->childs[d.seq].s_component_name,
     dd.dependency_type = m_dependency_rec->childs[d.seq].s_component_type, dd.description =
     "BUILDTIME", dd.updt_dt_tm = sysdate
    PLAN (d)
     JOIN (dd)
    WITH nocounter
   ;end insert
  ELSE
   INSERT  FROM dm_script_info_dependency dd
    SET dd.parent_script_name = ms_object_name, dd.environment_id = mf_cur_env_id, dd
     .child_component_name = ms_object_name,
     dd.dependency_type = ms_none_type, dd.description = "BUILDTIME", dd.updt_dt_tm = sysdate
    WITH nocounter
   ;end insert
  ENDIF
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(concat("Error while inserting into DM_SCRIPT_INFO_DEPENDENCY: ",dm_err->emsg),dm_err
    ->logfile,1)
   ROLLBACK
   GO TO exit_program
  ENDIF
  COMMIT
 ENDIF
#exit_program
 IF (ms_optimizer_mode != " ")
  SET mn_stat = dm2_push_cmd(concat("rdb alter session set optimizer_mode = ",ms_optimizer_mode," go"
    ),1)
 ENDIF
 SET mn_stat = sbr_bt_state_machine_cleanup(null)
 FREE RECORD m_gm_struct
 IF (mf_max_script_cost=0
  AND mn_script_info_only_ind=0)
  CALL dm2_email_error_info("dm_script_scanner","The MAX SCRIPT COST threshold could not be found.")
 ENDIF
 IF (mf_max_binary_size=0
  AND mn_script_info_only_ind=0)
  CALL dm2_email_error_info("dm_script_scanner","The MAX BINARY SIZE threshold could not be found.")
 ENDIF
 IF ((dm_err->err_ind=1))
  CALL dm2_email_error_info("dm_script_scanner",
   "An error has occurred in the dm_script_scanner script")
 ELSE
  SET dm_err->eproc = "Ending dm_script_scanner."
  CALL final_disp_msg("dm_script_scanner")
 ENDIF
 IF (curprog(1)="DM_SCRIPT_SCANNER")
  SET mn_stat = sbr_bt_defn_cleanup(null)
  IF ((dm_err->err_ind=0))
   SET mn_stat = remove(dm_err->logfile)
  ENDIF
 ENDIF
END GO
