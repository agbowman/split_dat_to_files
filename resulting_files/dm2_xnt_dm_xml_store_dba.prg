CREATE PROGRAM dm2_xnt_dm_xml_store:dba
 IF (validate(dmsmanagementrtl_def,999)=999)
  DECLARE dmsmanagementrtl_def = i2 WITH persist
  SET dmsmanagementrtl_def = 1
  FREE SET uar_dmsm_addxref
  DECLARE uar_dmsm_addxref(p1=i4(value),p2=vc(ref),p3=f8(ref)) = i4 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", uar = "DMSM_AddXRef",
  persist
  DECLARE uar_dmsm_createassociation(p1=vc(ref),p2=vc(ref),p2=i2(value)) = i1 WITH image_axp =
  "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_CreateAssociation", persist
  DECLARE uar_dmsm_createcopy(p1=vc(ref),p2=h(value),p3=i1(value),p4=i1(value),p5=i1(value)) = i4
  WITH image_axp = "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win
   = "dmsmanagement",
  uar = "DMSM_CreateCopy", persist
  DECLARE uar_dmsm_getcontenttypelist() = i4 WITH image_axp = "dmsmanagement", image_aix =
  "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetContentTypeList", persist
  DECLARE uar_dmsm_getcontenttype(p1=vc(ref)) = i4 WITH image_axp = "dmsmanagement", image_aix =
  "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetContentType", persist
  DECLARE uar_dmsm_getcontenttypeprops(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix
   = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetContentTypeProps", persist
  DECLARE uar_dmsm_createclassifiedmedia(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_CreateClassifiedMedia", persist
  DECLARE uar_dmsm_getclassifiedmedia(p1=vc(ref),p2=h(value)) = i4 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetClassifiedMedia", persist
  DECLARE uar_dmsm_getmediacontent(p1=i4(value),p2=i4(value),p3=h(value)) = i1 WITH image_axp =
  "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetMediaContent", persist
  DECLARE uar_dmsm_getmediaprops(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix =
  "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetMediaProps", persist
  DECLARE uar_dmsm_setmediacontent(p1=i4(value),p2=i4(value),p3=vc(ref),p4=h(value)) = i1 WITH
  image_axp = "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win =
  "dmsmanagement",
  uar = "DMSM_SetMediaContent", persist
  DECLARE uar_dmsm_storeclassifiedmedia(p1=i4(value)) = i1 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_StoreClassifiedMedia", persist
  DECLARE uar_dmsm_addmediatrackingevent(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i1(value)) = i1
  WITH image_axp = "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win
   = "dmsmanagement",
  uar = "DMSM_AddMediaTrackingEvent", persist
  DECLARE uar_dmsm_getinternalmediacontent(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetInternalMediaContent", persist
  DECLARE uar_dmsm_setmediaprops(p1=i4(value),p2=i4(value)) = i1 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_SetMediaProps", persist
  DECLARE uar_dmsm_getmediabyxref(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix =
  "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetMediaByXRef", persist
  DECLARE uar_dmsm_setmediaxref(p1=i4(value),p2=i4(value)) = i1 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_SetMediaXRef", persist
  DECLARE uar_dmsm_getmediaxref(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix =
  "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetMediaXRef", persist
  DECLARE uar_dmsm_setmetadata(p1=i4(value),p2=i4(value),p3=h(value)) = i1 WITH image_axp =
  "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_SetMetadata", persist
  DECLARE uar_dmsm_getmetadataschema(p1=i4(value),p2=h(value),p3=i4(value)) = i1 WITH image_axp =
  "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetMetadataSchema", persist
  DECLARE uar_dmsm_getmediaevents(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix =
  "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetMediaEvents", persist
  DECLARE uar_dmsm_getmediacodes(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix =
  "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetMediaCodes", persist
  DECLARE uar_dmsm_getclassifiedmedialist(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetClassifiedMediaList", persist
  DECLARE uar_dmsm_maintainmediaattributes(p1=i4(value),p2=i1(value),p3=i1(value)) = i4 WITH
  image_axp = "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win =
  "dmsmanagement",
  uar = "DMSM_MaintainMediaAttributes", persist
  DECLARE uar_dmsm_maintainmediaattributesex(p1=i4(value),p2=i1(value),p3=i1(value),p4=i1(value)) =
  i4 WITH image_axp = "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)",
  image_win = "dmsmanagement",
  uar = "DMSM_MaintainMediaAttributesEx", persist
 ENDIF
 IF ((validate(dcr_max_stack_size,- (1))=- (1))
  AND (validate(dcr_max_stack_size,- (2))=- (2)))
  DECLARE dcr_max_stack_size = i4 WITH protect, constant(30)
 ENDIF
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
 IF (validate(dm2_sys_misc->cur_os,"X")="X"
  AND validate(dm2_sys_misc->cur_os,"Y")="Y")
  FREE RECORD dm2_sys_misc
  RECORD dm2_sys_misc(
    1 cur_os = vc
    1 cur_db_os = vc
  )
  SET dm2_sys_misc->cur_os = validate(cursys2,cursys)
  SET dm2_sys_misc->cur_db_os = validate(currdbsys,cursys)
  IF (size(dm2_sys_misc->cur_db_os) != 3)
   SET dm2_sys_misc->cur_db_os = substring(1,(findstring(":",dm2_sys_misc->cur_db_os,1,1) - 1),
    dm2_sys_misc->cur_db_os)
  ENDIF
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
  IF ((dm2_sys_misc->cur_os="WIN"))
   SET dm2_install_schema->ccluserdir = build(logical("ccluserdir"),"\")
   SET dm2_install_schema->cer_install = build(logical("cer_install"),"\")
  ELSEIF ((dm2_sys_misc->cur_os="AXP"))
   SET dm2_install_schema->ccluserdir = logical("ccluserdir")
   SET dm2_install_schema->cer_install = logical("cer_install")
  ELSE
   SET dm2_install_schema->ccluserdir = build(logical("ccluserdir"),"/")
   SET dm2_install_schema->cer_install = build(logical("cer_install"),"/")
  ENDIF
 ENDIF
 IF (validate(inhouse_misc->inhouse_domain,- (1)) < 0
  AND validate(inhouse_misc->inhouse_domain,722)=722)
  FREE RECORD inhouse_misc
  RECORD inhouse_misc(
    1 inhouse_domain = i2
    1 fk_err_ind = i2
    1 nonfk_err_ind = i2
    1 fk_parent_table = vc
    1 tablespace_err_code = f8
    1 foreignkey_err_code = f8
  )
  SET inhouse_misc->inhouse_domain = - (1)
  SET inhouse_misc->fk_err_ind = 0
  SET inhouse_misc->nonfk_err_ind = 0
  SET inhouse_misc->fk_parent_table = ""
  SET inhouse_misc->tablespace_err_code = 93
  SET inhouse_misc->foreignkey_err_code = 94
 ENDIF
 IF (validate(program_stack_rs->cnt,1)=1
  AND validate(program_stack_rs->cnt,2)=2)
  FREE RECORD program_stack_rs
  RECORD program_stack_rs(
    1 cnt = i4
    1 qual[*]
      2 name = vc
  )
  SET stat = alterlist(program_stack_rs->qual,dcr_max_stack_size)
 ENDIF
 DECLARE dm2_set_inhouse_domain() = i2
 DECLARE dm2_get_program_stack(null) = vc
 SUBROUTINE (dm2_push_cmd(sbr_dpcstr=vc,sbr_cmd_end=i2) =i2)
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
 SUBROUTINE (dm2_push_dcl(sbr_dpdstr=vc) =i2)
   DECLARE dpd_stat = i4 WITH protect, noconstant(0)
   DECLARE newstr = vc WITH protect
   DECLARE strloc = i4 WITH protect, noconstant(0)
   DECLARE temp_file = vc WITH protect, noconstant(" ")
   DECLARE str2 = vc WITH protect, noconstant(" ")
   DECLARE posx = i4 WITH protect, noconstant(0)
   DECLARE sql_warn_ind = i2 WITH protect, noconstant(0)
   DECLARE dpd_disp_dcl_err_ind = i2 WITH protect, noconstant(1)
   IF ((validate(dm_err->disp_dcl_err_ind,- (1))=- (1))
    AND (validate(dm_err->disp_dcl_err_ind,- (2))=- (2)))
    SET dpd_disp_dcl_err_ind = 1
   ELSE
    SET dpd_disp_dcl_err_ind = dm_err->disp_dcl_err_ind
    SET dm_err->disp_dcl_err_ind = 1
   ENDIF
   IF ((dm_err->errfile="NONE"))
    IF (get_unique_file("dm2_",".err")=0)
     RETURN(0)
    ELSE
     SET dm_err->errfile = dm_err->unique_fname
    ENDIF
   ENDIF
   IF ((dm2_sys_misc->cur_os IN ("AXP")))
    SET strloc = findstring(">",sbr_dpdstr,1,0)
    IF (strloc > 0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Cannot support additional piping outside of push dcl subroutine"
     SET dm_err->eproc = "Check push dcl command for piping character (>)."
     RETURN(0)
    ENDIF
    SET newstr = concat("pipe ",sbr_dpdstr," > ccluserdir:",dm_err->errfile)
   ELSE
    SET strloc = findstring(">",sbr_dpdstr,1,0)
    IF (strloc > 0)
     SET strlength = size(trim(sbr_dpdstr))
     IF (findstring("2>&1",sbr_dpdstr) > 0)
      SET temp_file = build(substring((strloc+ 1),((strlength - strloc) - 4),sbr_dpdstr))
     ELSE
      SET temp_file = build(substring((strloc+ 1),(strlength - strloc),sbr_dpdstr))
     ENDIF
     SET newstr = sbr_dpdstr
    ELSE
     SET newstr = concat(sbr_dpdstr," > ",dm2_install_schema->ccluserdir,dm_err->errfile," 2>&1")
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo("*")
    CALL echo(concat("dm2_push_dcl executing: ",newstr))
    CALL echo("*")
   ENDIF
   CALL dcl(newstr,size(newstr),dpd_stat)
   IF (dpd_stat=0)
    IF (temp_file > " ")
     CASE (dm2_sys_misc->cur_os)
      OF "WIN":
       SET str2 = concat("copy ",temp_file," ",dm_err->errfile)
      ELSE
       IF ((dm2_sys_misc->cur_os != "AXP"))
        SET str2 = concat("cp ",temp_file," ",dm_err->errfile)
       ENDIF
     ENDCASE
     CALL dcl(str2,size(str2),dpd_stat)
    ENDIF
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF (sql_warn_ind=true)
     SET dm_err->user_action = "NONE"
     SET dm_err->eproc = concat("Warning Encountered:",dm_err->errtext)
     CALL disp_msg("",dm_err->logfile,0)
    ELSE
     SET dm_err->disp_msg_emsg = dm_err->errtext
     SET dm_err->emsg = dm_err->disp_msg_emsg
     IF (dpd_disp_dcl_err_ind=1)
      SET dm_err->eproc = concat("dm2_push_dcl executing: ",newstr)
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
 SUBROUTINE (get_unique_file(sbr_fprefix=vc,sbr_fext=vc) =i2)
   DECLARE guf_return_val = i4 WITH protect, noconstant(1)
   DECLARE fini = i2 WITH protect, noconstant(0)
   DECLARE fname = vc WITH protect
   DECLARE unique_tempstr = vc WITH protect
   WHILE (fini=0)
     IF ((((validate(systimestamp,- (999.00))=- (999.00))
      AND validate(systimestamp,999.00)=999.00) OR (validate(dm2_bypass_unique_file,- (1))=1)) )
      SET unique_tempstr = substring(1,6,cnvtstring((datetimediff(cnvtdatetime(sysdate),cnvtdatetime(
          curdate,000000)) * 864000)))
     ELSEIF ((validate(systimestamp,- (999.00)) != - (999.00))
      AND validate(systimestamp,999.00) != 999.00
      AND (validate(dm2_bypass_unique_file,- (1))=- (1))
      AND (validate(dm2_bypass_unique_file,- (2))=- (2)))
      SET unique_tempstr = format(systimestamp,"hhmmsscccccc;;q")
     ENDIF
     SET fname = cnvtlower(build(sbr_fprefix,unique_tempstr,sbr_fext))
     IF (findfile(fname)=0)
      SET fini = 1
     ENDIF
   ENDWHILE
   IF (check_error(concat("Getting unique file name using prefix: ",sbr_fprefix," and ext: ",sbr_fext
     ))=1)
    SET guf_return_val = 0
   ENDIF
   IF (guf_return_val=0)
    CALL echo("*")
    CALL echo("*")
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
    CALL echo("*")
    CALL echo("*")
   ELSE
    SET dm_err->unique_fname = fname
    CALL echo(concat("**Unique filename = ",dm_err->unique_fname))
   ENDIF
   RETURN(guf_return_val)
 END ;Subroutine
 SUBROUTINE (parse_errfile(sbr_errfile=vc) =i2)
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
 SUBROUTINE (check_error(sbr_ceprocess=vc) =i2)
   DECLARE return_val = i4 WITH protect, noconstant(0)
   IF ((dm_err->err_ind=1))
    SET return_val = 1
   ELSE
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF ((dm_err->ecode != 0))
     SET dm_err->eproc = sbr_ceprocess
     SET dm_err->err_ind = 1
     SET return_val = 1
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE (disp_msg(sbr_demsg=vc,sbr_dlogfile=vc,sbr_derr_ind=i2) =null)
   DECLARE dm_txt = c132 WITH protect
   DECLARE dm_ecode = i4 WITH protect
   DECLARE dm_emsg = c132 WITH protect
   DECLARE dm_full_emsg = vc WITH protect
   DECLARE dm_eproc_length = i4 WITH protect
   DECLARE dm_full_emsg_length = i4 WITH protect
   DECLARE dm_user_action_length = i4 WITH protect
   IF (sbr_demsg="dm_err->disp_msg_emsg")
    SET dm_full_emsg = dm_err->disp_msg_emsg
   ELSE
    SET dm_full_emsg = sbr_demsg
   ENDIF
   SET dm_eproc_length = textlen(dm_err->eproc)
   SET dm_full_emsg_length = textlen(dm_full_emsg)
   SET dm_user_action_length = textlen(dm_err->user_action)
   IF ( NOT (sbr_dlogfile IN ("NONE", "DM2_LOGFILE_NOTSET"))
    AND trim(sbr_dlogfile) != ""
    AND sbr_derr_ind IN (0, 1, 10))
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
      dm_txt = substring(beg_pos,end_pos,dm_err->eproc)
      WHILE (not_done=1)
        row + 1, col 0, dm_txt
        IF (end_pos > dm_eproc_length)
         not_done = 0
        ELSE
         beg_pos = (end_pos+ 1), end_pos += 132, dm_txt = substring(beg_pos,132,dm_err->eproc)
        ENDIF
      ENDWHILE
      IF (sbr_derr_ind=1)
       row + 1, "* Error Message:  ", beg_pos = 1,
       end_pos = 132, dm_txt = substring(beg_pos,132,dm_full_emsg), not_done = 1
       WHILE (not_done=1)
         row + 1, col 0, dm_txt
         IF (end_pos > dm_full_emsg_length)
          not_done = 0
         ELSE
          beg_pos = (end_pos+ 1), end_pos += 132, dm_txt = substring(beg_pos,132,dm_full_emsg)
         ENDIF
       ENDWHILE
      ENDIF
      IF ((dm_err->user_action != "NONE"))
       row + 1, "* Recommended Action(s):  ", beg_pos = 1,
       end_pos = 132, dm_txt = substring(beg_pos,132,dm_err->user_action), not_done = 1
       WHILE (not_done=1)
         row + 1, col 0, dm_txt
         IF (end_pos > dm_user_action_length)
          not_done = 0
         ELSE
          beg_pos = (end_pos+ 1), end_pos += 132, dm_txt = substring(beg_pos,132,dm_err->user_action)
         ENDIF
       ENDWHILE
      ENDIF
      row + 1
     WITH nocounter, format = variable, formfeed = none,
      maxrow = 1, maxcol = 200, append
    ;end select
    SET dm_ecode = error(dm_emsg,1)
   ELSEIF (sbr_dlogfile != "DM2_LOGFILE_NOTSET")
    SET dm_ecode = 1
    SET dm_emsg = "Message couldn't write to log file since name passed in was invalid."
   ENDIF
   IF (dm_ecode > 0)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(concat("Component Name:  ",curprog))
    CALL echo("*")
    CALL echo(concat("Process Description:  Writing message to log file."))
    CALL echo("*")
    CALL echo(concat("Error Message:  ",trim(dm_emsg)))
    CALL echo("*")
    IF ( NOT (sbr_dlogfile IN ("NONE", "DM2_LOGFILE_NOTSET")))
     CALL echo(concat("Log file is ccluserdir:",sbr_dlogfile))
     CALL echo("*")
    ENDIF
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ENDIF
   IF (sbr_derr_ind=1)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(concat("Component Name:  ",curprog))
    CALL echo("*")
    CALL echo(concat("Process Description:  ",dm_err->eproc))
    CALL echo("*")
    CALL echo(concat("Error Message:  ",trim(dm_full_emsg)))
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
    CALL echo("*")
    CALL echo("*")
   ELSEIF (sbr_derr_ind IN (0, 20))
    CALL echo("*")
    CALL echo("*")
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
    CALL echo("*")
    CALL echo("*")
   ENDIF
   SET dm_err->user_action = "NONE"
 END ;Subroutine
 SUBROUTINE (init_logfile(sbr_logfile=vc,sbr_header_msg=vc) =i2)
   DECLARE init_return_val = i4 WITH protect, noconstant(1)
   IF (sbr_logfile != "NONE"
    AND trim(sbr_logfile) != "")
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
     SET init_return_val = 0
    ELSE
     SET dm_err->eproc = concat("Log file created.  Log file name is: ",sbr_logfile)
     CALL disp_msg(" ",sbr_logfile,0)
    ENDIF
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Creating log file ",trim(sbr_logfile))
    SET dm_err->emsg = concat("Log file name passed is invalid.  Name passed in is: ",trim(
      sbr_logfile))
    SET init_return_val = 0
   ENDIF
   IF (init_return_val=0)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(concat("Error occurred in ",dm_err->eproc))
    CALL echo("*")
    CALL echo(trim(dm_err->emsg))
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ENDIF
   RETURN(init_return_val)
 END ;Subroutine
 SUBROUTINE (check_logfile(sbr_lprefix=vc,sbr_lext=vc,sbr_hmsg=vc) =i2)
   IF ((dm_err->logfile IN ("NONE", "DM2_LOGFILE_NOTSET")))
    IF ((dm_err->debug_flag > 9))
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
 SUBROUTINE (final_disp_msg(sbr_log_prefix=vc) =null)
   DECLARE plength = i2
   SET plength = textlen(sbr_log_prefix)
   IF (dm2_prg_maint("END")=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->err_ind=0))
    IF (cnvtlower(sbr_log_prefix)=substring(1,plength,dm_err->logfile))
     SET dm_err->eproc = concat(dm_err->eproc,"  Log file is ccluserdir:",dm_err->logfile)
     CALL disp_msg(" ",dm_err->logfile,0)
    ELSE
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (dm2_set_autocommit(sbr_dsa_flag=i2) =i2)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (dm2_prg_maint(sbr_maint_type=vc) =i2)
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
    IF ((program_stack_rs->cnt < dcr_max_stack_size))
     SET program_stack_rs->cnt += 1
     SET program_stack_rs->qual[program_stack_rs->cnt].name = curprog
    ENDIF
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF (dm2_set_autocommit(0)=0)
     RETURN(0)
    ENDIF
    SET dm2_install_schema->curprog = curprog
   ELSE
    FOR (i = 0 TO (program_stack_rs->cnt - 1))
      IF ((program_stack_rs->qual[(program_stack_rs->cnt - i)].name=curprog))
       FOR (j = (program_stack_rs->cnt - i) TO program_stack_rs->cnt)
         SET program_stack_rs->qual[j].name = ""
       ENDFOR
       SET program_stack_rs->cnt = ((program_stack_rs->cnt - i) - 1)
       SET i = program_stack_rs->cnt
      ENDIF
    ENDFOR
    IF (dm2_set_autocommit(0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo(dm2_get_program_stack(null))
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_set_inhouse_domain(null)
   DECLARE dsid_tbl_ind = c1 WITH protect, noconstant(" ")
   IF (validate(dm2_inhouse_flag,- (1)) > 0)
    SET dm_err->eproc = "Inhouse Domain Detected."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET inhouse_misc->inhouse_domain = 1
    RETURN(1)
   ENDIF
   IF ((inhouse_misc->inhouse_domain=- (1)))
    SET dm_err->eproc = "Determining whether table dm_info exists"
    SET dsid_tbl_ind = dm2_table_exists("DM_INFO")
    IF ((dm_err->err_ind=1))
     RETURN(0)
    ENDIF
    IF (dsid_tbl_ind="F")
     SELECT INTO "nl:"
      FROM dm_info di
      WHERE di.info_domain="DATA MANAGEMENT"
       AND di.info_name="INHOUSE DOMAIN"
      WITH nocounter
     ;end select
     IF (check_error("Determine if process running in an in-house domain")=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ELSEIF (curqual=1)
      SET inhouse_misc->inhouse_domain = 1
     ELSE
      SET inhouse_misc->inhouse_domain = 0
     ENDIF
    ENDIF
   ELSE
    RETURN(1)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (dm2_table_exists(dte_table_name=vc) =c1)
  SELECT INTO "nl:"
   FROM dm2_dba_tab_columns dutc
   WHERE dutc.table_name=trim(cnvtupper(dte_table_name))
    AND dutc.owner=value(currdbuser)
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   RETURN("E")
  ELSE
   IF (curqual > 0
    AND checkdic(cnvtupper(dte_table_name),"T",0)=2)
    RETURN("F")
   ELSE
    RETURN("N")
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE (dm2_table_and_ccldef_exists(dtace_table_name=vc,dtace_found_ind=i2(ref)) =i2)
   SET dtace_found_ind = 0
   SELECT INTO "nl:"
    FROM dba_tab_cols dtc
    WHERE dtc.table_name=trim(cnvtupper(dtace_table_name))
     AND dtc.owner=value(currdbuser)
    WITH nocounter
   ;end select
   IF (check_error(concat("Checking if ",trim(cnvtupper(dtace_table_name)),
     " table and ccl def exists"))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSE
    IF (curqual > 0
     AND checkdic(cnvtupper(dtace_table_name),"T",0)=2)
     SET dtace_found_ind = 1
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (dm2_table_column_exists(dtce_owner=vc,dtce_table_name=vc,dtce_column_name=vc,
  dtce_col_chk_ind=i2,dtce_coldef_chk_ind=i2,dtce_ccldef_mode=i2,dtce_col_fnd_ind=i2(ref),
  dtce_coldef_fnd_ind=i2(ref),dtce_data_type=vc(ref)) =i2)
   DECLARE dtce_type = vc WITH protect, noconstant("")
   DECLARE dtce_len = i4 WITH protect, noconstant(0)
   SET dtce_col_fnd_ind = 0
   SET dtce_coldef_fnd_ind = 0
   SET dtce_data_type = ""
   IF (dtce_col_chk_ind=1)
    SELECT INTO "nl:"
     FROM dba_tab_cols dtc
     WHERE dtc.owner=trim(dtce_owner)
      AND dtc.table_name=trim(dtce_table_name)
      AND dtc.column_name=trim(dtce_column_name)
     WITH nocounter
    ;end select
    IF (check_error(concat("Checking if ",trim(dtce_owner),".",trim(dtce_table_name),".",
      trim(dtce_column_name)," exists"))=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSE
     IF (curqual > 0)
      SET dtce_col_fnd_ind = 1
     ENDIF
    ENDIF
   ENDIF
   IF (dtce_coldef_chk_ind=1)
    IF (checkdic(cnvtupper(concat(dtce_table_name,".",dtce_column_name)),"A",0)=2)
     SET dtce_coldef_fnd_ind = 1
     IF (dtce_ccldef_mode=2)
      IF (((currev=8
       AND ((((currev * 10000)+ (currevminor * 100))+ currevminor2) >= 81401)) OR (currev > 8
       AND ((((currev * 10000)+ (currevminor * 100))+ currevminor2) >= 90201))) )
       CALL parser(concat(" set dtce_data_type = reflect(",dtce_table_name,".",dtce_column_name,
         ",1) go "),1)
       CALL parser(concat(" free range ",dtce_table_name," go "),1)
       SET dtce_len = cnvtint(cnvtalphanum(dtce_data_type,1))
       SET dtce_type = cnvtalphanum(dtce_data_type,2)
       IF (textlen(dtce_type)=2)
        SET dtce_type = substring(2,2,dtce_type)
       ENDIF
       SET dtce_data_type = concat(dtce_type,trim(cnvtstring(dtce_len)))
      ELSE
       SELECT INTO "nl:"
        FROM dtable t,
         dtableattr ta,
         dtableattrl tl
        WHERE t.table_name=cnvtupper(dtce_table_name)
         AND t.table_name=ta.table_name
         AND tl.attr_name=cnvtupper(dtce_column_name)
         AND tl.structtype="F"
         AND btest(tl.stat,11)=0
        DETAIL
         dtce_data_type = concat(tl.type,trim(cnvtstring(tl.len)))
        WITH nocounter
       ;end select
       IF (check_error(concat("Retrieving",trim(dtce_table_name),".",trim(dtce_column_name),
         " data type"))=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (dm2_disp_file(ddf_fname=vc,ddf_desc=vc) =i2)
   DECLARE ddf_row = i4 WITH protect, noconstant(0)
   IF ((dm2_sys_misc->cur_os="WIN"))
    SET message = window
    SET width = 132
    CALL clear(1,1)
    CALL video(n)
    SET ddf_row = 3
    CALL box(1,1,5,132)
    CALL text(ddf_row,48,"***  REPORT GENERATED  ***")
    SET ddf_row += 4
    CALL text(ddf_row,2,"The following report was generated in CCLUSERDIR... ")
    SET ddf_row += 2
    CALL text(ddf_row,5,concat("File Name:   ",trim(ddf_fname)))
    SET ddf_row += 1
    CALL text(ddf_row,5,concat("Description: ",trim(ddf_desc)))
    SET ddf_row += 2
    CALL text(ddf_row,2,"Review report in CCLUSERDIR before continuing.")
    SET ddf_row += 2
    CALL text(ddf_row,2,"Enter 'C' to continue or 'Q' to quit:  ")
    CALL accept(ddf_row,41,"A;cu","C"
     WHERE curaccept IN ("C", "Q"))
    IF (curaccept="Q")
     CALL clear(1,1)
     SET message = nowindow
     SET dm_err->emsg = "User elected to quit from report prompt."
     SET dm_err->err_ind = 1
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    CALL clear(1,1)
    SET message = nowindow
   ELSE
    SET dm_err->eproc = concat("Displaying ",ddf_desc)
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
    FREE SET file_loc
    SET logical file_loc value(ddf_fname)
    FREE DEFINE rtl2
    DEFINE rtl2 "file_loc"
    SELECT INTO mine
     t.line
     FROM rtl2t t
     HEAD REPORT
      col 30,
      CALL print(ddf_desc), row + 1
     DETAIL
      col 0, t.line, row + 1
     FOOT REPORT
      row + 0
     WITH nocounter, maxcol = 5000
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    FREE DEFINE rtl2
    FREE SET file_loc
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_program_stack(null)
   DECLARE stack = vc WITH protect, noconstant("PROGRAM STACK:")
   FOR (i = 1 TO (program_stack_rs->cnt - 1))
     SET stack = build(stack,program_stack_rs->qual[i].name,"->")
   ENDFOR
   IF (program_stack_rs->cnt)
    RETURN(build(stack,program_stack_rs->qual[program_stack_rs->cnt].name))
   ELSE
    RETURN(stack)
   ENDIF
 END ;Subroutine
 IF (check_logfile("dm2_xnt_xml_store",".log","DM2_XNT_XML_STORE LogFile...") != 1)
  SET dm_err->err_ind = 1
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (validate(dxxs_request->content_type,"-1")="-1")
  FREE RECORD dxxs_request
  RECORD dxxs_request(
    1 person_id = f8
    1 file_name = vc
    1 content_type = vc
    1 name = vc
    1 dm_xnt_log_id = f8
  ) WITH protect
  SET dxxs_request->person_id =  $1
  SET dxxs_request->file_name =  $2
  SET dxxs_request->content_type =  $3
  SET dxxs_request->name =  $4
  SET dxxs_request->dm_xnt_log_id =  $5
 ENDIF
 IF (validate(dxxs_reply->blob_handle,"-1")="-1")
  FREE RECORD dxxs_reply
  RECORD dxxs_reply(
    1 blob_handle = vc
  ) WITH protect
 ENDIF
 DECLARE dxxs_file_buffer = i4 WITH protect, noconstant(0)
 DECLARE dxxs_file_path = vc WITH protect, noconstant(" ")
 DECLARE dxxs_content_type = i4 WITH protect, noconstant(0)
 DECLARE dxxs_media_handle = i4 WITH protect, noconstant(0)
 DECLARE dxxs_media_props = i4 WITH protect, noconstant(0)
 DECLARE dxxs_cref_props = i4 WITH protect, noconstant(0)
 DECLARE dxxs_temp_ret = i4 WITH protect, noconstant(0)
 DECLARE dxxs_blob_handle = c200 WITH protect, noconstant(" ")
 IF ((dm_err->debug_flag > 0))
  CALL echorecord(dxxs_request)
  CALL echorecord(dxxs_reply)
 ENDIF
 SET dm_err->eproc = "Obtain content_type"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET dxxs_content_type = uar_dmsm_getcontenttype(nullterm(dxxs_request->content_type))
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (dxxs_content_type=0)
  SET dm_err->err_ind = 1
  CALL disp_msg(concat("invalid image content type specified - ",dxxs_request->content_type),dm_err->
   logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Create file buffer"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET dxxs_file_path = concat(trim(dm2_install_schema->ccluserdir),dxxs_request->file_name)
 SET dxxs_file_buffer = uar_srv_createfilebuffer(1,nullterm(dxxs_file_path))
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (dxxs_file_buffer=0)
  SET dm_err->err_ind = 1
  CALL disp_msg(concat("Error getting image file handle  - ",dxxs_request->file_name),dm_err->logfile,
   dm_err->err_ind)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Store image to MMF"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET dxxs_media_handle = uar_dmsm_createclassifiedmedia(dxxs_content_type)
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (dxxs_media_handle=0)
  SET dm_err->err_ind = 1
  CALL disp_msg(concat("Error obtaining media handle for content type ",cnvtstring(dxxs_content_type)
    ),dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 SET dxxs_media_props = uar_dmsm_getmediaprops(dxxs_media_handle)
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (dxxs_media_props=0)
  SET dm_err->err_ind = 1
  CALL disp_msg(concat("Error obtaining media properties for media handle ",cnvtstring(
     dxxs_media_handle)),dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 SET dxxs_temp_ret = uar_srv_setpropstring(dxxs_media_props,"name",nullterm(dxxs_request->name))
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (dxxs_temp_ret=0)
  SET dm_err->err_ind = 1
  CALL disp_msg(concat("Error setting name property for media handle ",cnvtstring(dxxs_media_handle)),
   dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 SET dxxs_temp_ret = uar_dmsm_setmediaprops(dxxs_media_handle,dxxs_media_props)
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (dxxs_temp_ret=0)
  SET dm_err->err_ind = 1
  CALL disp_msg(concat("Error saving name property for media handle ",cnvtstring(dxxs_media_handle)),
   dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 SET dxxs_temp_ret = uar_dmsm_setmediacontent(dxxs_media_handle,dxxs_file_buffer,"text/xml",0)
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (dxxs_temp_ret=0)
  SET dm_err->err_ind = 1
  CALL disp_msg(concat("Error setting file_type and file_buffer properties for media handle ",
    cnvtstring(dxxs_media_handle)),dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 SET dxxs_temp_ret = uar_dmsm_storeclassifiedmedia(dxxs_media_handle)
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (dxxs_temp_ret=0)
  SET dm_err->err_ind = 1
  CALL disp_msg(concat("Error saving media for media handle ",cnvtstring(dxxs_media_handle)),dm_err->
   logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Obtain blob handle"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET dxxs_media_props = uar_dmsm_getmediaprops(dxxs_media_handle)
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (dxxs_media_props=0)
  SET dm_err->err_ind = 1
  CALL disp_msg(concat("Error obtaining media properties for media handle ",cnvtstring(
     dxxs_media_handle)),dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 SET dxxs_temp_ret = uar_srv_getpropstring(dxxs_media_props,"uid",dxxs_blob_handle,200)
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (dxxs_temp_ret=0)
  SET dm_err->err_ind = 1
  CALL disp_msg("Error obtaining blob handle ",dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 CALL echo(concat("Got unique blob handle",dxxs_blob_handle))
 IF (trim(dxxs_blob_handle) > " ")
  SET dxxs_reply->blob_handle = dxxs_blob_handle
  SET dm_err->eproc = "Store blobl handle to dm_xnt_job_log_dtl"
  CALL disp_msg(" ",dm_err->logfile,0)
  UPDATE  FROM dm_xnt_job_log_dtl dxl
   SET dxl.file_label = dxxs_request->name, dxl.file_uuid = dxxs_blob_handle
   WHERE (dxl.dm_xnt_job_log_dtl_id=dxxs_request->dm_xnt_log_id)
   WITH nocounter
  ;end update
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   GO TO exit_program
  ENDIF
 ELSE
  SET dm_err->err_ind = 1
  CALL disp_msg("Blob handle obtained is not valid",dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 SET dm_err->eproc = "Cross reference the media to a person_id"
 CALL disp_msg(" ",dm_err->logfile,0)
 SET dxxs_cref_props = uar_srv_createproplist()
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (dxxs_cref_props=0)
  SET dm_err->err_ind = 1
  CALL disp_msg("Error creating property list ",dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 SET dxxs_temp_ret = dxxs_add_ref("PERSON",dxxs_request->person_id)
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (dxxs_temp_ret=0)
  SET dm_err->err_ind = 1
  CALL disp_msg("Error creating reference to person for current media",dm_err->logfile,dm_err->
   err_ind)
  GO TO exit_program
 ENDIF
 SET dxxs_temp_ret = uar_dmsm_setmediaxref(dxxs_media_handle,dxxs_cref_props)
 IF (check_error(dm_err->eproc)=1)
  CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
  GO TO exit_program
 ENDIF
 IF (dxxs_temp_ret=0)
  SET dm_err->err_ind = 1
  CALL disp_msg("Error storing reference to person for current media",dm_err->logfile,dm_err->err_ind
   )
  GO TO exit_program
 ENDIF
 GO TO exit_program
 SUBROUTINE (dxxs_add_ref(i_parent_name=vc,i_parent_id=f8) =i2)
   DECLARE lsubproplist = i4 WITH protect, noconstant(0)
   DECLARE s_ret = i2 WITH protect, noconstant(0)
   SET s_ret = 0
   IF (i_parent_id > 0)
    SET lsubproplist = uar_srv_createproplist()
    IF (lsubproplist != 0)
     IF (uar_srv_setpropstring(lsubproplist,"entityName",nullterm(i_parent_name))
      AND uar_srv_setpropreal(lsubproplist,"entityId",i_parent_id)
      AND uar_srv_setpropint(lsubproplist,"transaction",1))
      IF (uar_srv_setprophandle(dxxs_cref_props,"0",lsubproplist,1))
       SET s_ret = 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(s_ret)
 END ;Subroutine
#exit_program
 IF (dxxs_cref_props != 0)
  SET dxxs_temp_ret = uar_srv_closehandle(dxxs_cref_props)
 ENDIF
 IF (dxxs_media_props != 0)
  SET dxxs_temp_ret = uar_srv_closehandle(dxxs_media_props)
 ENDIF
 IF (dxxs_media_handle != 0)
  SET dxxs_temp_ret = uar_srv_closehandle(dxxs_media_handle)
 ENDIF
 IF (dxxs_content_type != 0)
  SET dxxs_temp_ret = uar_srv_closehandle(dxxs_content_type)
 ENDIF
 IF (dxxs_file_buffer != 0)
  SET dxxs_temp_ret = uar_srv_closehandle(dxxs_file_buffer)
 ENDIF
 SET dm_err->eproc = "Dm2_xnt_xml_dm_store completed"
 CALL final_disp_msg("dm2_xnt_dm_xml_store")
END GO
