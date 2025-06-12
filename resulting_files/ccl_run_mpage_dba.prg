CREATE PROGRAM ccl_run_mpage:dba
 RECORD colrec(
   1 cols[*]
     2 columnname = vc
     2 startcol = i4
     2 collength = i4
 )
 RECORD scannerrequest(
   1 source = gvc
 )
 RECORD scannerreply(
   1 token[*]
     2 value = vc
     2 isliteral = i4
     2 iscomment = i4
 )
 IF (validate(cclmpagertl_def,999)=999)
  EXECUTE cclmpagertl:dba
 ENDIF
 IF (validate(fileio_def,999)=999)
  EXECUTE uar_fileiortl:dba
 ENDIF
 DECLARE _k_web_clientprint_with_driver_str = vc WITH constant("__CLIENTDEFAULTPRINT__"), protect
 DECLARE _k_web_clientprint_without_driver_str = vc WITH constant(
  "__WEB_CLIENTPRINT_WITHOUT_DRIVER__"), protect
 DECLARE _k_media_type_text = i2 WITH constant(0), protect
 DECLARE _k_media_type_postscript = i2 WITH constant(1), protect
 DECLARE _k_media_type_pdf = i2 WITH constant(2), protect
 DECLARE _k_media_type_rtf = i2 WITH constant(3), protect
 DECLARE _k_media_type_html = i2 WITH constant(4), protect
 DECLARE _k_media_type_xml = i2 WITH constant(5), protect
 DECLARE _k_run_type_web_clientprint_with_driver = i4 WITH constant(0), protect
 DECLARE _k_run_type_web_clientprint_without_driver = i4 WITH constant(1), protect
 DECLARE _k_run_type_querycommand = i4 WITH constant(2), protect
 DECLARE _k_run_type_report = i4 WITH constant(3), protect
 DECLARE _k_run_type_report_cclnews = i4 WITH constant(4), protect
 DECLARE _k_run_type_report_readfile = i4 WITH constant(5), protect
 DECLARE _k_run_type_report_xmloutput = i4 WITH constant(6), protect
 DECLARE max_audit_params = i2 WITH constant(32000)
 DECLARE max_filesize = i4 WITH constant(100000000)
 DECLARE max_stringvarlen = i4 WITH constant(100000000)
 DECLARE _cclrptaudit_none = i2 WITH constant(0)
 DECLARE _cclrptaudit_full = i2 WITH constant(1)
 DECLARE _cclrptaudit_minsecs = i2 WITH constant(2)
 DECLARE _cclrptaudit_cust = i2 WITH constant(3)
 DECLARE _vcdocline = vc WITH noconstant(""), protect
 DECLARE _nrecords = i4 WITH protect
 DECLARE _isodbc_orig = i2 WITH protect
 DECLARE _audit_type = c20 WITH protect
 DECLARE _audit_flag = i2 WITH protect
 DECLARE _rptterm = i2 WITH noconstant(0), public
 DECLARE _stat = i4 WITH noconstant(0), protect
 DECLARE _deletefile = i2 WITH noconstant(validate(__deletefile,1)), protect
 DECLARE _runtype = i4 WITH noconstant(_k_run_type_report), protect
 DECLARE _outfile = vc WITH protect
 DECLARE _cpcfile = vc WITH protect
 DECLARE _cpcfile_len = i2 WITH protect
 DECLARE _fileext = vc WITH noconstant("dat"), protect
 DECLARE _outputdev = vc WITH protect
 DECLARE _params = vc WITH protect
 DECLARE _programname = vc WITH protect
 DECLARE _querycommand = vc WITH protect
 DECLARE _runcmd = vc WITH protect
 DECLARE _ccldiover = i2 WITH protect
 DECLARE _canexecuteind = i4 WITH noconstant(false), protect
 DECLARE _outputreplyind = i4 WITH noconstant(true), protect
 DECLARE _filename = vc WITH noconstant(""), protect
 DECLARE _webrequestind = i4 WITH noconstant(false), protect
 DECLARE _haserror = i4 WITH noconstant(false), protect
 DECLARE _bisreport = c1 WITH noconstant("T"), protect
 DECLARE _dummyvar = vc WITH private
 DECLARE _failedflag = c1 WITH noconstant("F"), public
 DECLARE _errorcode = i2 WITH noconstant(0), protect
 DECLARE _errormsg = c256 WITH protect
 DECLARE _replyoutputasblobind = i4 WITH noconstant(false), protect
 DECLARE _index = i4 WITH noconstant(0), private
 DECLARE _xmlstylesheetpi = vc WITH protect
 DECLARE _i18nnodatafoundmsg = vc WITH protect
 DECLARE _tempdir = vc WITH protect
 DECLARE _ncclrptaudittype = i2 WITH protect
 DECLARE _bmemoryerror = i2 WITH noconstant(0)
 DECLARE _cclaudit_flag = i2 WITH protect, noconstant(1)
 DECLARE _memory_reply_string = vc WITH public
 DECLARE _zoom_level = i2 WITH protect
 DECLARE _media_type = i2 WITH protect
 IF (validate(_report_audit_id)=0)
  DECLARE _report_audit_id = f8 WITH persistscript, noconstant(0.0)
 ENDIF
 DECLARE _app = i4 WITH protect, noconstant(0)
 DECLARE _task = i4 WITH protect, noconstant(0)
 DECLARE _happ = i4 WITH protect, noconstant(0)
 DECLARE _htask = i4 WITH protect, noconstant(0)
 DECLARE _hreq = i4 WITH protect, noconstant(0)
 DECLARE _hrep = i4 WITH protect, noconstant(0)
 DECLARE _hstat = i4 WITH protect, noconstant(0)
 DECLARE _omf_object_cd = f8 WITH protect, noconstant(0.0)
 DECLARE _long_text = vc WITH protect
 DECLARE _long_text_id = f8
 DECLARE _audit_status = vc
 DECLARE _records_cnt = i4
 DECLARE _audit_begin_time = dq8 WITH protect, noconstant(0.0)
 DECLARE _audit_begin_secs = i4 WITH protect, noconstant(0)
 DECLARE _audit_end_secs = i4 WITH protect, noconstant(0)
 DECLARE _max_params_len = i4 WITH constant(2000)
 SET _loglevel = 2
 SET _omf_object_cd = 0.0
 SUBROUTINE ccl_init_audit(program_name,report_type)
   IF (_report_audit_id > 0.0)
    SET fillstr = fillstring(255," ")
    SET fillstr = concat("ccl_init_audit() failed to insert row for program= ",program_name,
     ", _report_audit_id= ",build(_report_audit_id)," (possible duplicate audit call)")
    CALL msgview_log(fillstr)
    RETURN(0)
   ENDIF
   SET _report_audit_id = 0.0
   SET _audit_type = report_type
   SET _audit_flag = 0
   IF (((validate(_report_readonly)) OR (currdbuser="V500_READ")) )
    IF ((reqinfo->updt_app > 0))
     SET _app = reqinfo->updt_app
    ELSE
     SET _app = 3070000
    ENDIF
    SET _task = 3070001
    SET crmstatus = uar_crmbeginapp(_app,_happ)
    IF (crmstatus != 0)
     SET fillstr = fillstring(255," ")
     SET fillstr = concat("Error! uar_CrmBeginApp failed with status: ",build(crmstatus))
     CALL echo(fillstr)
     CALL endapptask(0)
     RETURN
    ELSE
     CALL echo(concat("Uar_CrmBeginApp success, app: ",build(_app)))
    ENDIF
    SET crmstatus = uar_crmbegintask(_happ,_task,_htask)
    IF (crmstatus != 0)
     SET fillstr = fillstring(255," ")
     SET fillstr = concat("Error! uar_CrmBeginTask failed with status: ",build(crmstatus))
     CALL echo(fillstr)
     CALL endapptask(0)
     RETURN
    ELSE
     CALL echo(concat("Uar_CrmBeginTask success, task: ",build(_task)))
    ENDIF
    SET _reqnum = 3050003
    CALL invoke_crmperform(_reqnum,"ccl_add_rpt_audit")
   ELSE
    DECLARE _report_audit_seq = f8
    DECLARE _obj_params = vc
    DECLARE _output_device = vc
    DECLARE _temp_file = vc
    DECLARE audit_begin_dttm = dq8
    SET _obj_params = validate(_params,"<NOT SPECIFIED")
    SET _output_device = validate(_outputdev,"<NOT SPECIFIED>")
    SET _temp_file = validate(_outfile,"<NOT SPECIFIED>")
    SET _report_audit_seq = 0
    SELECT INTO "nl:"
     _reportseq = seq(ccl_seq,nextval)
     FROM dual
     DETAIL
      _report_audit_seq = _reportseq
     WITH nocounter
    ;end select
    IF (textlen(trim(_obj_params)) > _max_params_len)
     SET _obj_params = concat(substring(1,(_max_params_len - 3),trim(_obj_params)),"...")
    ENDIF
    IF (_audit_begin_time > 0.0)
     SET audit_begin_dttm = _audit_begin_time
    ELSE
     SET audit_begin_dttm = cnvtdatetime(sysdate)
    ENDIF
    INSERT  FROM ccl_report_audit c
     SET c.report_event_id = _report_audit_seq, c.object_name = trim(cnvtupper(program_name)), c
      .object_type = _audit_type,
      c.object_params = _obj_params, c.application_nbr = reqinfo->updt_app, c.begin_dt_tm =
      cnvtdatetime(audit_begin_dttm),
      c.output_device = trim(_output_device), c.tempfile = trim(_temp_file), c.records_cnt = 0,
      c.status = "ACTIVE", c.active_ind = 1, c.omf_object_cd = _omf_object_cd,
      c.long_text_id = 0.0, c.updt_dt_tm = cnvtdatetime(audit_begin_dttm), c.updt_id = reqinfo->
      updt_id,
      c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0, c.updt_task = reqinfo->updt_task,
      c.request_nbr = reqinfo->updt_req
     WITH nocounter
    ;end insert
    IF (curqual=1)
     SET _audit_flag = 1
     SET _report_audit_id = _report_audit_seq
     COMMIT
    ELSE
     SET fillstr = concat("Report= ",program_name,", failed to insert into ccl_report_audit table")
     CALL msgview_log(fillstr)
    ENDIF
   ENDIF
   RETURN(_audit_flag)
 END ;Subroutine
 SUBROUTINE ccl_write_audit(program_name,report_type,audit_status,records_cnt)
   SET _audit_type = report_type
   SET _audit_flag = 0
   SET _audit_status = audit_status
   SET _records_cnt = records_cnt
   IF (_report_audit_id=0.0)
    SET fillstr = fillstring(255," ")
    SET fillstr = concat("ccl_write_audit() failed to update row for program= ",program_name,
     ", _report_audit_id= 0; (possible duplicate audit call)")
    CALL msgview_log(fillstr)
    RETURN(_audit_flag)
   ENDIF
   IF (((validate(_report_readonly)) OR (currdbuser="V500_READ")) )
    SET _reqnum = 3050004
    CALL invoke_crmperform(_reqnum,"ccl_upd_rpt_audit")
    CALL endapptask(0)
   ELSE
    SET _errmsg = fillstring(132," ")
    UPDATE  FROM ccl_report_audit c
     SET c.object_type = report_type, c.records_cnt = records_cnt, c.status = cnvtupper(audit_status),
      c.active_ind = 0, c.end_dt_tm = cnvtdatetime(sysdate), c.updt_dt_tm = cnvtdatetime(sysdate),
      c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 1,
      c.updt_task = reqinfo->updt_task
     WHERE c.report_event_id=_report_audit_id
     WITH nocounter
    ;end update
    IF (curqual=1)
     SET _audit_flag = 1
     COMMIT
    ELSE
     SET fillstr = concat("Report= ",program_name,", failed to update ccl_report_audit table")
     CALL msgview_log(fillstr)
    ENDIF
   ENDIF
   IF ((reqinfo->updt_req != 3050002)
    AND (reqinfo->updt_req != 3050012))
    SET _report_audit_id = 0.0
   ENDIF
   RETURN(_audit_flag)
 END ;Subroutine
 SUBROUTINE invoke_crmperform(reqnum,audit_program)
   SET crmstatus = uar_crmbeginreq(_htask,0,reqnum,_hreq)
   IF (crmstatus != 0)
    SET fillstr = fillstring(255," ")
    SET fillstr = concat("Invalid CrmBeginReq return status of",build(crmstatus))
    CALL echo(fillstr)
    CALL endapptask(0)
    RETURN
   ELSE
    CALL echo("uar_CrmBeginReq success")
   ENDIF
   SET _hrequest = uar_crmgetrequest(_hreq)
   IF (_hrequest)
    IF (reqnum=3050003)
     SET stat = uar_srvsetstring(_hrequest,"object_name",nullterm(program_name))
     SET stat = uar_srvsetstring(_hrequest,"object_params",nullterm(validate(_params,
        "<NOT SPECIFIED>")))
     SET stat = uar_srvsetstring(_hrequest,"output_device",nullterm(validate(_outputdev,
        "<NOT SPECIFIED>")))
     SET stat = uar_srvsetstring(_hrequest,"temp_file",nullterm(validate(_outfile,"<NOT SPECIFIED>"))
      )
     SET stat = uar_srvsetstring(_hrequest,"report_type",nullterm(_audit_type))
     SET stat = uar_srvsetdouble(_hrequest,"person_id",reqinfo->updt_id)
     SET stat = uar_srvsetdouble(_hrequest,"omf_object_cd",_omf_object_cd)
     SET stat = uar_srvsetstring(_hrequest,"long_text",nullterm(_long_text))
     SET stat = uar_srvsetlong(_hrequest,"crm_reqnum",reqinfo->updt_req)
    ELSE
     SET stat = uar_srvsetstring(_hrequest,"object_name",nullterm(program_name))
     SET stat = uar_srvsetdouble(_hrequest,"report_audit_id",_report_audit_id)
     SET stat = uar_srvsetstring(_hrequest,"report_type",nullterm(_audit_type))
     SET stat = uar_srvsetlong(_hrequest,"records_cnt",_records_cnt)
     SET stat = uar_srvsetstring(_hrequest,"status",nullterm(cnvtupper(_audit_status)))
     SET stat = uar_srvsetdouble(_hrequest,"person_id",reqinfo->updt_id)
    ENDIF
   ELSE
    SET fillstr = fillstring(255," ")
    SET fillstr = "Invalid hRequest handle returned from CrmGetRequest"
    CALL echo(fillstr)
    CALL msgview_log(fillstr)
    CALL uar_crmendreq(_hreq)
    RETURN
   ENDIF
   CALL echo(" calling uar_CrmPerform()")
   SET crmstatus = uar_crmperform(_hreq)
   IF (crmstatus != 0)
    CALL echo(concat("uar_CrmPerform status: ",_status))
    SET fillstr = fillstring(255," ")
    SET fillstr = concat("Report= ",program_name,", uar_CrmPerform for: ",audit_program,
     " returned status= ",
     build(crmstatus))
    CALL msgview_log(fillstr)
   ELSE
    CALL echo(" uar_CrmPerform() success")
    SET _hreply = uar_crmgetreply(_hreq)
    SET _hstat = uar_srvgetstruct(_hreply,"status_data")
    SET _status = uar_srvgetstringptr(_hstat,"status")
    IF (_status="S")
     SET _audit_flag = 1
     IF (reqnum=3050003)
      SET _report_audit_id = uar_srvgetdouble(_hreply,"report_audit_id")
     ENDIF
    ELSE
     SET fillstr = fillstring(255," ")
     SET fillstr = concat("Report= ",program_name,", uar_CrmPeform for: ",audit_program,
      " returned status= ",
      build(_status))
     CALL msgview_log(fillstr)
    ENDIF
   ENDIF
   IF (_hreq > 0)
    CALL uar_crmendreq(_hreq)
    SET _hreq = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE msgview_log(_logstr)
   DECLARE _hsys = i4
   SET _sysstat = 0
   DECLARE _hsys = i4
   SET _hsys = 0
   CALL echo(_logstr)
   CALL uar_syscreatehandle(_hsys,_sysstat)
   CALL uar_sysevent(_hsys,_loglevel,"ReportAuditError",nullterm(_logstr))
   CALL uar_sysdestroyhandle(_hsys)
 END ;Subroutine
 SUBROUTINE endapptask(p1)
  IF (_htask > 0)
   CALL uar_crmendtask(_htask)
   SET _htask = 0
  ENDIF
  IF (_happ > 0)
   CALL uar_crmendapp(_happ)
   SET _happ = 0
  ENDIF
 END ;Subroutine
 SET _i18nhandle = 0
 SET _zoom_level = - (1)
 SET lretval = uar_i18nlocalizationinit(_i18nhandle,curprog,"",curcclrev)
 SET _i18nnodatafoundmsg = uar_i18ngetmessage(_i18nhandle,"datanotfound","No data found.")
 SET _tempdir = "cer_temp"
 IF (validate(_scclscratch,"ZZZ")="ZZZ")
  DECLARE _scclscratch = vc
  SET _scclscratch = logical("CCLSCRATCH")
 ENDIF
 IF (textlen(trim(_scclscratch)) > 0)
  SET _tempdir = "cclscratch"
 ENDIF
 SET _outputdev = trim(cnvtupper(request->output_device))
 SET _params = trim(request->params)
 SET _errormsg = fillstring(256," ")
 SET _querycommand = trim(request->query_command)
 SET _programname = _getprogramnameexcludedebuginfo(trim(cnvtupper(request->program_name)))
 IF (((cnvtint(request->isblob)=1) OR (cnvtint(request->isblob)=ichar("1"))) )
  SET _replyoutputasblobind = true
 ENDIF
 IF (_isoutputdevicemine(_outputdev)=false
  AND _outputdev != "NOPROMPTS")
  SET _outputreplyind = false
 ENDIF
 SET _ccldiover = 0
 IF (((curcclrev=8.2
  AND validate(currevminor2,0) >= 4) OR (curcclrev > 8.2)) )
  SET _ccldiover = 1
 ENDIF
 IF (((cnvtint(request->is_printer)=2) OR (cnvtint(request->is_printer)=ichar("2"))) )
  SET _webrequestind = true
  IF (_ccldiover=1)
   SET modify = dio(8,38,26,38,29,
    38)
   IF (checkqueue(_outputdev) != 1)
    SET modify = spoolfile
   ENDIF
  ENDIF
 ENDIF
 IF ((reqinfo->updt_req=3050012))
  SET _ncclrptaudittype = _cclrptaudit_none
  SET _cclaudit_flag = validate(request->isaudit,1)
 ELSE
  SET _ncclrptaudittype = _cclrptaudit_full
 ENDIF
 IF (validate(_ccl_rpt_audit,- (1)) >= 0)
  SET _ncclrptaudittype = _ccl_rpt_audit
 ENDIF
 IF (cnvtupper(_outputdev)=_k_web_clientprint_with_driver_str)
  SET _outputdev = "MINE"
  SET _fileext = "001"
  SET _outputreplyind = true
  SET _runtype = _k_run_type_web_clientprint_with_driver
 ELSEIF (cnvtupper(_outputdev)=_k_web_clientprint_without_driver_str)
  SET _outputdev = "MINE"
  SET _fileext = "001"
  SET _outputreplyind = true
  SET _runtype = _k_run_type_web_clientprint_without_driver
 ELSEIF (_programname="CCLNEWS")
  SET _runtype = _k_run_type_report_cclnews
 ELSEIF (_programname="CCL_READFILE"
  AND size(request->qual,5) > 1
  AND _outputreplyind
  AND validate(request->qual[2].parameter))
  SET _runtype = _k_run_type_report_readfile
 ELSEIF (textlen(_querycommand) >= 6
  AND cnvtupper(substring(1,6,_querycommand))="SELECT")
  SET _runtype = _k_run_type_querycommand
  IF (_webrequestind=false)
   SET _replyoutputasblobind = false
  ENDIF
 ENDIF
 IF (validate(reportrtl_def,0)=0)
  EXECUTE reportrtl
 ENDIF
 SET _stat = alterlist(rpterrors->errors,0)
 SET rptreport->m_reportname = ""
 SET rptreport->m_pagewidth = 8.5
 SET rptreport->m_pageheight = 11.0
 SET rptreport->m_marginleft = 0.25
 SET rptreport->m_marginright = 0.25
 SET rptreport->m_margintop = 0.25
 SET rptreport->m_marginbottom = 0.25
 SET rptreport->m_orientation = 0
 IF ("Z"=validate(omf_function->v_func[1].v_func_name,"Z"))
  CALL echo("omf_functions.inc: declaring omfsql_def")
  DECLARE omfsql_def = i2 WITH persist
  SET omfsql_def = 1
  IF ("Z"=validate(omf_function->v_func[1].v_func_name,"Z"))
   SET trace = recpersist
   DECLARE v_omfcnt = i4 WITH protect
   SET v_omfcnt = 0
   FREE SET omf_function
   RECORD omf_function(
     1 v_func[*]
       2 v_func_name = c40
       2 v_dtype = c10
   )
   SELECT INTO "nl:"
    function_name = function_name, dtype = return_dtype
    FROM omf_function
    WHERE function_name != "uar*"
     AND function_name != "cclsql*"
    ORDER BY function_name
    DETAIL
     v_omfcnt += 1
     IF (mod(v_omfcnt,100)=1)
      stat = alterlist(omf_function->v_func,(v_omfcnt+ 99))
     ENDIF
     omf_function->v_func[v_omfcnt].v_func_name = trim(function_name)
     IF (trim(dtype)="q8")
      omf_function->v_func[v_omfcnt].v_dtype = "dq8"
     ELSE
      omf_function->v_func[v_omfcnt].v_dtype = trim(dtype)
     ENDIF
    FOOT REPORT
     stat = alterlist(omf_function->v_func,v_omfcnt)
    WITH nocounter
   ;end select
   SET trace = norecpersist
  ENDIF
  DECLARE _omfcnt = i4 WITH protect
  IF (size(omf_function->v_func,5) > 0)
   FOR (_omfcnt = 1 TO size(omf_function->v_func,5))
     IF ((omf_function->v_func[_omfcnt].v_func_name > " "))
      SET v_declare = fillstring(100," ")
      SET v_declare = concat("declare ",trim(omf_function->v_func[_omfcnt].v_func_name),"() = ",trim(
        omf_function->v_func[_omfcnt].v_dtype)," WITH PERSIST GO")
      CALL parser(trim(v_declare))
     ENDIF
   ENDFOR
  ENDIF
  CALL echo("omf_functions: defined")
 ELSE
  CALL echo("omf_functions: already defined")
 ENDIF
 SET _isodbc_orig = isodbc
 IF (((cnvtint(request->is_odbc)=1) OR (cnvtint(request->is_odbc)=ichar("1"))) )
  SET isodbc = 1
 ELSE
  SET isodbc = 0
 ENDIF
 CALL echo("***** VCCL_RUN_PROGRAM *****")
 IF (_runtype=_k_run_type_report_cclnews)
  SET _outfile = "ccldir:cclnews.dat"
  IF (cursys="AIX")
   SET _outfile = _translatelogical(_outfile)
  ENDIF
  SET _deletefile = 0
 ELSEIF (_runtype=_k_run_type_report_readfile)
  SET _outfile = request->qual[2].parameter
  IF (cursys="AIX")
   SET _outfile = _translatelogical(_outfile)
   SET request->qual[2].parameter = _outfile
  ENDIF
  SET rptreport->m_reportname = request->qual[2].parameter
  IF (validate(request->qual[3].parameter))
   SET rptreport->m_orientation = cnvtint(request->qual[3].parameter)
  ENDIF
  IF (validate(request->qual[4].parameter))
   SET rptreport->m_pageheight = cnvtreal(request->qual[4].parameter)
  ENDIF
  IF (validate(request->qual[5].parameter))
   SET rptreport->m_pagewidth = cnvtreal(request->qual[5].parameter)
  ENDIF
  SET _deletefile = 0
 ELSEIF (_runtype=_k_run_type_querycommand)
  DECLARE i = i4 WITH noconstant(0), private
  DECLARE openparencount = i4 WITH noconstant(0), private
  DECLARE isinfromnode = i4 WITH noconstant(false), private
  DECLARE isinqualnode = i4 WITH noconstant(false), private
  DECLARE isfoundwithtoken = i4 WITH noconstant(false), private
  DECLARE tokenlistsize = i4 WITH noconstant(0), private
  DECLARE optionstr = vc WITH noconstant(trim(" ")), private
  DECLARE commandstr = vc WITH noconstant(trim(" ")), private
  SET _canexecuteind = true
  SET scannerrequest->source = _querycommand
  EXECUTE ccl_tokenscanner  WITH replace("REQUEST","SCANNERREQUEST"), replace("REPLY","SCANNERREPLY")
  SET tokenlistsize = size(scannerreply->token,5)
  FOR (i = 1 TO tokenlistsize)
    IF ((scannerreply->token[i].iscomment=false))
     IF ((scannerreply->token[i].isliteral=false))
      IF (cnvtupper(scannerreply->token[i].value)="FROM")
       SET isinfromnode = true
      ELSEIF (((cnvtupper(scannerreply->token[i].value)="PLAN") OR (((cnvtupper(scannerreply->token[i
       ].value)="WHERE") OR (((cnvtupper(scannerreply->token[i].value)="ORDER") OR (cnvtupper(
       scannerreply->token[i].value)="HAVING")) )) )) )
       SET isinqualnode = true
      ELSEIF (isinfromnode)
       IF ((scannerreply->token[i].value="("))
        SET openparencount += 1
       ELSEIF ((scannerreply->token[i].value=")"))
        SET openparencount -= 1
       ELSEIF (cnvtupper(scannerreply->token[i].value)="WITH"
        AND openparencount=0)
        SET isfoundwithtoken = true
       ENDIF
      ELSEIF (isinqualnode)
       IF (cnvtupper(scannerreply->token[i].value)="WITH")
        SET isfoundwithtoken = true
       ENDIF
      ENDIF
     ENDIF
     IF (isfoundwithtoken)
      SET optionstr = notrim(concat(notrim(optionstr),notrim(scannerreply->token[i].value)))
     ELSE
      SET commandstr = notrim(concat(notrim(commandstr),notrim(scannerreply->token[i].value)))
     ENDIF
    ENDIF
  ENDFOR
  IF (textlen(optionstr) > 0)
   SET optionstr = concat(optionstr,notrim(" "),notrim(", maxrow=1, reporthelp, check"))
  ELSE
   SET optionstr = concat(notrim(" with maxrow=1, reporthelp, check"))
  ENDIF
  SET _runcmd = _buildqueryexecutecommand(commandstr,optionstr)
 ELSEIF (_outputreplyind)
  DECLARE filetitle = vc WITH private
  SET _canexecuteind = true
  EXECUTE cpm_create_file_name "CCL", _fileext
  SET filetitle = substring(1,((textlen(cpm_cfn_info->file_name) - textlen(_fileext)) - 1),
   cpm_cfn_info->file_name)
  SET _filename = concat(_tempdir,":",filetitle)
  IF (cursys="AIX")
   SET _filename = _translatelogical(_filename)
  ENDIF
  SET _outfile = trim(concat(_filename,".",_fileext))
  IF (_runtype != _k_run_type_web_clientprint_with_driver)
   CALL echo(concat("..Temp output file: ",_outfile,", len: ",build(textlen(_outfile))))
   IF (validate(_create_cpc,1)=1)
    SET _cpcfile = trim(concat(_tempdir,":",filetitle,"_",trim(_fileext),
      ".cpc"))
    CALL echo(concat("..Temp CPC file: ",_cpcfile))
    SET _cpcfile = _translatelogical(_cpcfile)
    EXECUTE ccl_createcpc _cpcfile
   ELSE
    CALL echo("..skipping ccl_createcpc")
   ENDIF
  ELSE
   SET modify fileseq value(_outfile)
  ENDIF
  IF (textlen(_params) > 0)
   CALL echo(concat("..params= ",_params))
   SET _runcmd = _buildreportexecutecommand(trim(_programname),concat('"',_outfile,'"'),_params)
  ELSE
   SET _runcmd = concat("execute ",trim(_programname)," '",_outfile,"' go")
  ENDIF
 ELSE
  SET _canexecuteind = true
  SET _runcmd = concat("execute ",trim(_programname)," ",_params," go")
 ENDIF
 CALL echo(concat("..run command= ",_runcmd))
 IF (_canexecuteind
  AND _runtype != _k_run_type_querycommand)
  IF (_ncclrptaudittype=_cclrptaudit_full)
   CALL echo("_nCclRptAuditType = _CCLRPTAUDIT_FULL. invoke ccl_init_audit..")
   SET _audit_flag = ccl_init_audit(_programname,"REPORT")
  ELSEIF (validate(_min_audit_secs,- (1)) > 0)
   SET _audit_begin_time = cnvtdatetime(sysdate)
   SET _audit_begin_secs = curtime2
  ELSEIF (_ncclrptaudittype=_cclrptaudit_cust)
   IF (_isauditenabled_programoruser(reqinfo->updt_id))
    CALL echo(build("_IsAuditEnabled_ProgramOrUser= 1. _programName= ",_programname,", prsnl_id= ",
      reqinfo->updt_id))
    SET _audit_flag = ccl_init_audit(_programname,"REPORT")
   ENDIF
  ENDIF
  CALL echo(".. _canExecute= 1, invoke call parser().")
  SET modify = skipsrvmsg
  CALL parser(_runcmd)
  IF (validate(_min_audit_secs,- (1)) > 0)
   SET _audit_end_secs = curtime2
   IF (((_audit_end_secs - _audit_begin_secs) >= _min_audit_secs))
    CALL echo(build("invoke ccl_init_audit for _min_audit_secs. _audit_begin_secs= ",
      _audit_begin_secs,", _audit_end_secs= ",_audit_end_secs))
    SET _audit_flag = ccl_init_audit(_programname,"REPORT")
   ENDIF
  ENDIF
  IF (validate(keepreply,0)=0)
   CALL echo("..free reply record")
   FREE SET reply
  ENDIF
  SET modify = noskipsrvmsg
  SET modify = nopredeclare
  IF (_webrequestind
   AND _ccldiover=1)
   SET modify = dio(0,0)
   IF (checkqueue(_outputdev) != 1)
    SET modify = nospoolfile
    SET modify = nofileseq
   ENDIF
  ENDIF
  CALL echo(build("..reportinfo(1)= ",reportinfo(1)))
  IF (((reportinfo(1)="REPORT") OR (size(_memory_reply_string) > 0)) )
   SET _bisreport = "T"
   SET _audit_type = "REPORT"
  ELSEIF (reportinfo(1)="QUERY")
   IF (_webrequestind)
    SET _bisreport = "T"
    SET _audit_type = "REPORT"
    SET _outfile = _xmlquery(_outfile)
   ELSE
    SET _bisreport = "F"
    SET _audit_type = "QUERY"
    SET _replyoutputasblobind = 0
   ENDIF
   IF (_isoutputdevicemine(_outputdev))
    SET _nrecords = (curqual - 1)
   ELSE
    SET _nrecords = curqual
   ENDIF
   CALL echo(build("..record count = ",_nrecords))
  ENDIF
  IF (_haserror=false)
   SET _errorcode = error(_errormsg,0)
  ENDIF
 ENDIF
 CALL echo("..check if reply exists")
 IF (validate(reply->pgm_complete,"define")="define")
  CALL echo("..creating reply structure")
  RECORD reply(
    1 pgm_complete = vc
    1 columntitle = vc
    1 cpc_line = vc
    1 bisreport = c1
    1 nreporttype = i2
    1 norientation = i2
    1 lpdfsize = i4
    1 ltxtsize = i4
    1 ltxtlinemaxsize = i4
    1 rptreport
      2 m_reportname = c32
      2 m_pagewidth = f8
      2 m_pageheight = f8
      2 m_marginleft = f8
      2 m_marginright = f8
      2 m_margintop = f8
      2 m_marginbottom = f8
      2 m_orientation = i2
      2 m_errorsize = i4
    1 rpterrors[*]
      2 m_text = c256
      2 m_source = c64
      2 m_severity = i2
    1 qual[*]
      2 new_line = vc
    1 ntotalrecords = i4
    1 overflowpage[*]
      2 ofr_qual[*]
        3 ofr_line = vc
    1 qual2[*]
      2 pdf_line = gvc
      2 pdf_line_size = i4
    1 info_line[*]
      2 new_line = vc
    1 document = gvc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 zoom_level = i2
  )
 ENDIF
 IF (_canexecuteind
  AND _runtype=_k_run_type_querycommand)
  SET _long_text = _querycommand
  IF (_ncclrptaudittype=_cclrptaudit_full)
   SET _audit_flag = ccl_init_audit(_programname,"QUERY")
  ENDIF
  CALL parser(_runcmd)
  SET _errorcode = error(_errormsg,0)
  SET _bisreport = "F"
 ENDIF
 IF (_errorcode != 0)
  CALL echo("-- Error executing the query/report")
  SET _index = _geterrors(_index)
  SET _haserror = true
 ENDIF
 SET reply->bisreport = _bisreport
 IF (_haserror
  AND _webrequestind)
  GO TO exit_script
 ELSEIF (_outputreplyind)
  CALL echo(build(".. _outputReplyInd= ",_outputreplyind,", _replyOutputAsBlobInd= ",
    _replyoutputasblobind,", _runType= ",
    _runtype))
  IF (_replyoutputasblobind)
   IF (_runtype=_k_run_type_web_clientprint_with_driver)
    SET reply->nreporttype = _k_media_type_xml
    SET _audit_type = "FILEPDF"
    SET _deletefile = 0
    SET _nrecords = 1
    SET reply->document = _getxmlformattedprintedfilenames(_filename,false)
    SET reply->lpdfsize = textlen(reply->document)
   ELSE
    IF (findfile(_outfile) != 1
     AND size(_memory_reply_string)=0)
     IF (_runtype=_k_run_type_report_xmloutput)
      CALL _writexmlquerynodatamessage(_outfile)
     ELSE
      SET _outfile = _getoutputfile_nodata(_outfile)
      SET _deletefile = 0
     ENDIF
    ENDIF
    IF (_webrequestind
     AND _getoutputfilemediatype(_outfile)=_k_media_type_text
     AND _runtype != _k_run_type_report_xmloutput)
     EXECUTE cpm_create_file_name "CCL", _fileext
     EXECUTE ccl_text2pdf value(cpm_cfn_info->file_name_full_path), _outfile, 1
     IF (_runtype != _k_run_type_report_cclnews)
      SET _stat = remove(_outfile)
     ENDIF
     SET _outfile = cpm_cfn_info->file_name_full_path
    ENDIF
    IF (_runtype=_k_run_type_web_clientprint_without_driver)
     SET reply->nreporttype = _k_media_type_xml
     SET _audit_type = "FILEPDF"
     SET _deletefile = 0
     SET _nrecords = 1
     SET reply->document = _getxmlformattedprintedfilenames(_outfile,true)
     SET reply->lpdfsize = textlen(reply->document)
    ELSEIF (size(_memory_reply_string) > 0)
     SET reply->nreporttype = _k_media_type_text
     SET reply->lpdfsize = size(_memory_reply_string)
     SET reply->document = _memory_reply_string
     SET reply->nreporttype = _getmediatype(_memory_reply_string)
     SET _memory_reply_string = " "
     SET _nrecords = 1
     SET modify maxvarlen max_stringvarlen
    ELSE
     CALL _getoutputfile(_outfile)
     DECLARE errorssize = i4 WITH noconstant(0), private
     SET errorssize = size(rpterrors->errors,5)
     CALL echo(build("..nerrors=",errorssize))
     CALL echorecord(rpterrors)
     IF (errorssize > 0)
      SET reply->rptreport.m_errorsize = errorssize
      SET _stat = alterlist(reply->rpterrors,errorssize)
      FOR (i = 0 TO errorssize)
        SET reply->rpterrors[i].m_text = rpterrors->errors[i].m_text
        SET reply->rpterrors[i].m_source = rpterrors->errors[i].m_source
        SET reply->rpterrors[i].m_severity = rpterrors->errors[i].m_severity
      ENDFOR
     ENDIF
     SET reply->rptreport.m_reportname = rptreport->m_reportname
     SET reply->rptreport.m_pagewidth = rptreport->m_pagewidth
     SET reply->rptreport.m_pageheight = rptreport->m_pageheight
     SET reply->rptreport.m_marginleft = rptreport->m_marginleft
     SET reply->rptreport.m_marginright = rptreport->m_marginright
     SET reply->rptreport.m_margintop = rptreport->m_margintop
     SET reply->rptreport.m_marginbottom = rptreport->m_marginbottom
     SET reply->rptreport.m_orientation = rptreport->m_orientation
    ENDIF
   ENDIF
  ELSE
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE overflowpagecount = i4 WITH noconstant(1), protect
   DECLARE overflowpageline = i4 WITH noconstant(0), protect
   DECLARE linelength = i4 WITH noconstant(0), protect
   IF (_runtype=_k_run_type_querycommand)
    CALL echo("..QUERY TYPE")
    SET _nrecords = size(reply->qual,5)
    SET reply->ntotalrecords = size(reply->qual,5)
    IF ((reply->ntotalrecords > 65534))
     FOR (idx = 65535 TO reply->ntotalrecords)
       SET overflowpageline += 1
       IF (mod(overflowpagecount,2)=1)
        SET _stat = alterlist(reply->overflowpage,(overflowpagecount+ 1))
       ENDIF
       IF (mod(overflowpageline,1000)=1)
        SET _stat = alterlist(reply->overflowpage[overflowpagecount].ofr_qual,(overflowpageline+ 1000
         ))
       ENDIF
       SET reply->overflowpage[overflowpagecount].ofr_qual[overflowpageline].ofr_line = reply->qual[
       idx].new_line
       IF (mod(idx,65534)=0)
        SET _stat = alterlist(reply->overflowpage[overflowpagecount].ofr_qual,65534)
        SET overflowpagecount += 1
        SET overflowpageline = 0
       ENDIF
     ENDFOR
     SET _stat = alterlist(reply->qual,65534)
     SET _stat = alterlist(reply->overflowpage,overflowpagecount)
     IF (overflowpageline > 0)
      SET _stat = alterlist(reply->overflowpage[overflowpagecount].ofr_qual,overflowpageline)
     ENDIF
    ENDIF
   ELSE
    SET _stat = alterlist(reply->qual,10)
    SET reply->nreporttype = _getoutputfilemediatype(_outfile)
    FREE DEFINE rtl3
    FREE SET file_loc
    SET logical file_loc value(_outfile)
    DEFINE rtl3 "file_loc"
    CALL echo(build("..start load:",format(curtime3,"HH:MM:SS;;s")))
    SELECT INTO "nl:"
     r2.line
     FROM rtl3t r2
     HEAD REPORT
      idx = 0, linelength = 0, reply->lpdfsize = 0,
      reply->rptreport.m_reportname = rptreport->m_reportname, reply->rptreport.m_pagewidth =
      rptreport->m_pagewidth, reply->rptreport.m_pageheight = rptreport->m_pageheight,
      reply->rptreport.m_marginleft = rptreport->m_marginleft, reply->rptreport.m_marginright =
      rptreport->m_marginright, reply->rptreport.m_margintop = rptreport->m_margintop,
      reply->rptreport.m_marginbottom = rptreport->m_marginbottom, reply->rptreport.m_orientation =
      rptreport->m_orientation
     DETAIL
      idx += 1
      IF (idx < 65535)
       IF ((reply->nreporttype=_k_media_type_pdf))
        IF (mod(idx,1000)=1)
         _stat = alterlist(reply->qual2,(idx+ 1000))
        ENDIF
        reply->qual2[idx].pdf_line = r2.line, reply->qual2[idx].pdf_line_size = size(reply->qual2[idx
         ].pdf_line), reply->lpdfsize += reply->qual2[idx].pdf_line_size
       ELSE
        IF (mod(idx,1000)=1)
         _stat = alterlist(reply->qual,(idx+ 1000))
        ENDIF
        reply->qual[idx].new_line = r2.line, reply->qual[idx].new_line = replace(reply->qual[idx].
         new_line,""," "), linelength = size(reply->qual[idx].new_line),
        reply->ltxtsize += linelength
        IF ((linelength > reply->ltxtlinemaxsize))
         reply->ltxtlinemaxsize = linelength
        ENDIF
       ENDIF
      ELSE
       overflowpageline += 1
       IF (mod(overflowpagecount,2)=1)
        _stat = alterlist(reply->overflowpage,(overflowpagecount+ 1))
       ENDIF
       IF (mod(overflowpageline,1000)=1)
        _stat = alterlist(reply->overflowpage[overflowpagecount].ofr_qual,(overflowpageline+ 1000))
       ENDIF
       reply->overflowpage[overflowpagecount].ofr_qual[overflowpageline].ofr_line = r2.line, reply->
       overflowpage[overflowpagecount].ofr_qual[overflowpageline].ofr_line = replace(reply->
        overflowpage[overflowpagecount].ofr_qual[overflowpageline].ofr_line,""," "), linelength =
       size(reply->overflowpage[overflowpagecount].ofr_qual[overflowpageline].ofr_line),
       reply->ltxtsize += linelength
       IF ((linelength > reply->ltxtlinemaxsize))
        reply->ltxtlinemaxsize = linelength
       ENDIF
       IF (mod(idx,65534)=0)
        _stat = alterlist(reply->overflowpage[overflowpagecount].ofr_qual,65534), overflowpagecount
         += 1, overflowpageline = 0
       ENDIF
      ENDIF
      reply->ntotalrecords = idx
     FOOT REPORT
      IF (idx > 65534)
       _nrecords = 65534, _stat = alterlist(reply->overflowpage,overflowpagecount)
       IF (overflowpageline > 0)
        _stat = alterlist(reply->overflowpage[overflowpagecount].ofr_qual,overflowpageline)
       ENDIF
      ELSE
       _nrecords = idx
      ENDIF
     WITH nocounter
    ;end select
    FREE DEFINE rtl3
    SET _stat = alterlist(reply->qual,_nrecords)
    CALL echo(build("..end load:",format(curtime3,"HH:MM:SS;;s")," with :",reply->ntotalrecords,
      "records"))
   ENDIF
  ENDIF
 ENDIF
 IF (_nrecords > 0)
  IF (_deletefile)
   SET _stat = remove(_outfile)
   CALL echo(concat("..Stat on remove outFile: ",build(_stat)))
  ELSE
   CALL echo(build("..skipping delete of outfile: ",_outfile))
  ENDIF
  IF (validate(_create_cpc,1)=1)
   IF (_runtype != _k_run_type_querycommand
    AND _runtype != _k_run_type_report_xmloutput
    AND _runtype != _k_run_type_web_clientprint_with_driver
    AND _runtype != _k_run_type_report_cclnews)
    IF (textlen(_cpcfile) > 0)
     CALL echo(build("..found cpc, _cpcFile= ",_cpcfile))
     FREE DEFINE rtl2
     FREE SET file_cpc
     SET logical file_cpc value(_cpcfile)
     DEFINE rtl2 "FILE_CPC"
     SELECT INTO "nl:"
      r2.line
      FROM rtl2t r2
      DETAIL
       reply->cpc_line = trim(r2.line)
      WITH nocounter
     ;end select
     FREE DEFINE rtl2
    ENDIF
   ENDIF
  ENDIF
 ELSE
  SET _errorcode = error(_errormsg,0)
  IF (_errorcode != 0)
   CALL echo("-- error occured reading output file!")
   SET _index = _geterrors(_index)
   GO TO exit_script
  ELSE
   CALL echo("..no records qualified.")
  ENDIF
 ENDIF
 IF (_audit_flag=1
  AND _haserror=0)
  SET nrecordcnt = _nrecords
  IF (_audit_type="QUERY")
   SET nrecordcnt = (_nrecords - 1)
  ENDIF
  IF (_ncclrptaudittype=_cclrptaudit_full)
   IF (_isoutputdevicemine(_outputdev))
    CALL ccl_write_audit(_programname,_audit_type,"SUCCESS",nrecordcnt)
   ENDIF
  ELSEIF (validate(_min_audit_secs,- (1)) > 0)
   IF (((_audit_end_secs - _audit_begin_secs) >= _min_audit_secs))
    CALL echo(build("invoke ccl_write_audit for _min_audit_secs= ",_min_audit_secs))
    CALL ccl_write_audit(_programname,_audit_type,"SUCCESS",nrecordcnt)
   ENDIF
  ELSEIF (_ncclrptaudittype=_cclrptaudit_cust)
   IF (_isauditenabled_programoruser(reqinfo->updt_id))
    CALL echo(build("_IsAuditEnabled_ProgramOrUser= 1. _programName= ",_programname,", prsnl_id= ",
      reqinfo->updt_id))
    CALL ccl_write_audit(_programname,_audit_type,"SUCCESS",nrecordcnt)
   ENDIF
  ENDIF
 ENDIF
 IF (_haserror=0
  AND _cclaudit_flag=1)
  DECLARE _audit_params = vc
  DECLARE _audit_event = vc
  SET _audit_params = concat(_programname," ",_params)
  IF ((reqinfo->updt_req=3050012))
   SET _audit_event = "Run mPage"
  ELSEIF (_runtype=_k_run_type_querycommand)
   SET _audit_event = "Run Adhoc Query"
   SET _audit_params = concat("Ccl_report_audit.report_event_id= ",build(_report_audit_id),
    ", domain= ",trim(reqdata->domain))
  ELSE
   SET _audit_event = "Run Report"
  ENDIF
  IF (textlen(_audit_params) > max_audit_params
   AND _audit_event != "Run Adhoc Query")
   SET _audit_params = concat(_programname," ",substring(1,((max_audit_params - textlen(_programname)
     ) - 1),_params))
  ENDIF
  CALL echo(build2("..Invoke CCLAUDIT at: ",format(cnvtdatetime(sysdate),";;q"),", program: ",
    _programname,", request: ",
    format(reqinfo->updt_req,"########"),", updt_id: ",reqinfo->updt_id))
  EXECUTE cclaudit 0, value(_audit_event), "View",
  "4", "3", "2",
  "6", reqinfo->updt_id, value(_audit_params)
  SET _report_audit_id = 0.0
 ENDIF
#exit_script
 SET _rptterm = uar_rptterminate()
 SET _stat = alterlist(rpterrors->errors,0)
 SET _media_type = reply->nreporttype
 IF (_runtype != _k_run_type_querycommand)
  SET _cpcfile_len = textlen(trim(_cpcfile))
  IF (_cpcfile_len > 0
   AND ((_deletefile) OR (_runtype=_k_run_type_web_clientprint_without_driver)) )
   CALL echo(concat("..removing cpc file : ",_cpcfile))
   SET _stat = remove(_cpcfile)
   CALL echo(build("remove stat=",_stat))
   IF (_stat=0)
    CALL echo(concat("..failed to remove file: ",_cpcfile))
   ENDIF
  ELSE
   CALL echo(build("..skipping delete of cpcfile:",_cpcfile))
  ENDIF
 ENDIF
 SET isodbc = _isodbc_orig
 IF (_failedflag="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "run program"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "vccl_run_program"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = _errormsg
  SET reqinfo->commit_ind = 0
  SET reply->zoom_level = - (1)
 ELSEIF (curqual=0
  AND (reply->status_data.status != "S"))
  SET reply->status_data.status = "Z"
  IF (validate(_enable_custom_zoom,0)=1)
   EXECUTE ccl_outputviewer_cust_zoom
   SET reply->zoom_level = _zoom_level
  ELSEIF (_zoom_level >= 0)
   SET reply->zoom_level = _zoom_level
  ELSE
   SET reply->zoom_level = - (2)
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  IF (validate(_enable_custom_zoom,0)=1)
   EXECUTE ccl_outputviewer_cust_zoom
   SET reply->zoom_level = _zoom_level
  ELSEIF (_zoom_level >= 0)
   SET reply->zoom_level = _zoom_level
  ELSE
   SET reply->zoom_level = - (3)
  ENDIF
  CALL echo("..vccl_run_program->status = S")
 ENDIF
 SUBROUTINE (_translatelogical(filepath=vc) =vc WITH protect)
   DECLARE findindex = i4 WITH noconstant(0), private
   DECLARE logicalname = vc WITH noconstant(""), private
   DECLARE actualpath = vc WITH noconstant(""), private
   DECLARE pathlenght = i4 WITH noconstant(0), private
   DECLARE restofpath = vc WITH noconstant(""), private
   SET findindex = findstring(":",filepath,1)
   IF (findindex > 0)
    SET pathlength = textlen(filepath)
    SET logicalname = trim(substring(1,(findindex - 1),filepath))
    SET restofpath = trim(substring((findindex+ 1),(pathlength - findindex),filepath),3)
    SET actualpath = trim(cnvtlower(logical(cnvtupper(logicalname))))
    IF (cursys="AIX")
     IF (textlen(actualpath) > 0
      AND substring(textlen(actualpath),1,actualpath) != "/")
      SET actualpath = concat(actualpath,"/")
     ENDIF
    ENDIF
    SET actualpath = concat(actualpath,restofpath)
   ELSE
    SET actualpath = filepath
   ENDIF
   RETURN(actualpath)
 END ;Subroutine
 SUBROUTINE (_geterrors(index=i2) =i2 WITH protect)
   DECLARE failuretext = vc WITH private
   SET _failedflag = "T"
   SET failuretext = "FAILED"
   SET _stat = alterlist(reply->info_line,10)
   CALL echo(build("..start index=",index))
   WHILE (_errorcode != 0
    AND index <= 10)
     SET index += 1
     SET reply->info_line[index].new_line = trim(_errormsg)
     CALL echo(_errormsg)
     IF (_errorcode=296)
      SET failuretext = "TIMEOUT"
     ELSEIF (_errorcode=284
      AND validate(_report_readonly))
      SET _finderr = findstring("ORA-01031",_errormsg,1)
      IF (_finderr > 0)
       CALL echo("  Error ORA-01031 found, issuing RDB ROLLBACK")
       CALL parser("rdb rollback go")
      ENDIF
     ENDIF
     SET _errorcode = error(_errormsg,0)
   ENDWHILE
   SET _stat = alterlist(reply->info_line,index)
   IF (((_runtype=_k_run_type_web_clientprint_with_driver) OR (_runtype=
   _k_run_type_web_clientprint_without_driver)) )
    SET _audit_type = "FILEPDF"
   ENDIF
   IF (_audit_flag=1)
    CALL ccl_write_audit(_programname,_audit_type,failuretext,0)
    SET _report_audit_id = 0.0
   ENDIF
   CALL echo(build(".. _GetErrors new index= ",index))
   RETURN(index)
 END ;Subroutine
 SUBROUTINE (_buildqueryexecutecommand(querycmd=vc,withopt=vc) =vc WITH protect)
   DECLARE stmt = vc
   IF (_webrequestind)
    SET _runtype = _k_run_type_report_xmloutput
    SET _params = concat(querycmd," ",withopt)
    EXECUTE cpm_create_file_name "ccl", "dat"
    CALL echo(concat("file_name_full_path= ",cpm_cfn_info->file_name_full_path))
    SET _outfile = cpm_cfn_info->file_name_full_path
    SET stmt = concat(check(querycmd)," head report",
     '    filehandle = uar_fopen( nullterm(_outfile), "w+b")',"  ","    stat = 0, cnt = 0, colcnt=0",
     "    columnTitle = concat(reportinfo(1))","    nFind=1",'    _vcDocLine = "<querydata><header>"',
     "    stat = uar_fwrite( _vcDocLine, textlen(_vcDocLine), 1, fileHandle )","  ",
     "    while(nFind<textlen(columnTitle))","      if(nFind>=1)","         colcnt = colcnt+1",
     "         stat = alterlist(colrec->cols,colcnt)",
     "         colrec->cols[colcnt].startcol = nFind",
     '         nfind = findstring(" ",columnTitle,nFind)',"         bContinue = 1",
     "         tLen = 0","         while(bContinue)","             tLen = tLen +1",
     "             if(nFind=0)","                 tLen = textlen(columnTitle)","             endif",
     '             if(nFind+tLen>textlen(columnTitle) or substring(nFind+tLen,1,columnTitle)!=" ")',
     "                 bContinue=0",
     "                 colrec->cols[colcnt].colLength = nFind - colrec->cols[colcnt].startcol + tLen -1",
     "                 colrec->cols[colcnt].columnName =",
     "                             substring(colrec->cols[colcnt].startcol,",
     "                             colrec->cols[colcnt].colLength,columnTitle)",
     "                 nFind = nFind+tLen",
     '                 _vcDocLine = concat("<col>",',
     '                         colrec->cols[colcnt].columnName,"</col>")',
     "                 stat = uar_fwrite( _vcDocLine, textlen(_vcDocLine), 1, fileHandle )",
     "                 call echo(_vcDocLine) ","              endif",
     "         endwhile","       endif","    endwhile",'    _vcDocLine = "</header><data>"',
     "    stat = uar_fwrite( _vcDocLine, textlen(_vcDocLine), 1, fileHandle )",
     " detail","    new_line = replace(reportinfo(2),'',' ')",'    _vcDocLine = "<row>"',
     "    stat = uar_fwrite( _vcDocLine, textlen(_vcDocLine), 1, fileHandle )",
     "    for(colcnt = 1 to size(colrec->cols,5))",
     '       _vcDocLine = build("<",colrec->cols[colcnt].columnName,">",',
     "         _FormatSpecialXMLChars(trim(substring(colrec->cols[colcnt].startCol,colrec->cols[colcnt].colLength,new_Line),3)),",
     '                     "</",colrec->cols[colcnt].columnName,">")',
     "       stat = uar_fwrite( _vcDocLine, textlen(_vcDocLine), 1, fileHandle )","    endfor",
     '    _vcDocLine = "</row>"',
     "    stat = uar_fwrite( _vcDocLine, textlen(_vcDocLine), 1, fileHandle )"," foot report",
     '     _vcDocLine = "</data></querydata>"',
     "     stat = uar_fwrite( _vcDocLine, textlen(_vcDocLine), 1, fileHandle )",
     "     stat = uar_fclose( filehandle )",'     call echo(build("..close stat = ",stat)) ',withopt,
     " go")
   ELSE
    SET stmt = concat(check(querycmd)," head report"," stat = 0, cnt = 0",
     " reply->columnTitle = concat(reportinfo(1))"," detail",
     " if (mod( cnt, 50 ) = 0)","  stat = alterlist(reply->qual,cnt + 50)"," endif"," cnt = cnt + 1",
     " reply->qual[cnt].new_line = replace(reportinfo(2),'',' ')",
     " foot report"," stat = alterlist(reply->qual,cnt) ",withopt," go")
   ENDIF
   RETURN(stmt)
 END ;Subroutine
 SUBROUTINE (_buildreportexecutecommand(programtoexecute=vc,outputdestination=vc,parameters=vc) =vc
  WITH protect)
   DECLARE index = i4 WITH noconstant(0), private
   DECLARE tokenlistsize = i4 WITH noconstant(0), private
   DECLARE token = vc WITH noconstant(trim(" ")), notrim, private
   DECLARE isfoundmine = i4 WITH noconstant(false), private
   DECLARE newparams = vc WITH noconstant(trim(" ")), notrim, private
   SET scannerrequest->source = parameters
   EXECUTE ccl_tokenscanner  WITH replace("REQUEST","SCANNERREQUEST"), replace("REPLY","SCANNERREPLY"
    )
   SET tokenlistsize = size(scannerreply->token,5)
   FOR (index = 1 TO tokenlistsize)
     IF ((scannerreply->token[index].iscomment=false))
      IF (isfoundmine)
       SET newparams = notrim(concat(notrim(newparams),notrim(scannerreply->token[index].value)))
      ELSE
       IF (scannerreply->token[index].isliteral)
        SET token = scannerreply->token[index].value
        SET token = trim(substring(2,(textlen(token) - 2),token))
        IF (cnvtupper(token)="MINE")
         SET isfoundmine = true
        ENDIF
       ELSEIF (cnvtupper(scannerreply->token[index].value)="MINE")
        SET isfoundmine = true
       ENDIF
       IF (isfoundmine)
        SET newparams = notrim(concat(notrim(newparams),notrim(outputdestination)))
       ELSE
        SET newparams = notrim(concat(notrim(newparams),notrim(scannerreply->token[index].value)))
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   RETURN(concat("execute ",trim(programtoexecute),notrim(" "),newparams,notrim(" go")))
 END ;Subroutine
 SUBROUTINE (_xmlquery(vcfilein=vc) =vc WITH protect)
  IF (_runtype=_k_run_type_web_clientprint_without_driver)
   SET _errormsg = "Invalid report output format for printing. The report output format is XML"
   SET _haserror = true
   SET _failedflag = "T"
  ELSE
   DECLARE _vcholdfile = vc
   DECLARE _filehandle = i4 WITH noconstant(0), private
   EXECUTE cpm_create_file_name "ccl", "dat"
   CALL echo(cpm_cfn_info->file_name_full_path)
   SET _runtype = _k_run_type_report_xmloutput
   FREE DEFINE rtl3
   FREE SET file_loc
   SET logical file_loc value(vcfilein)
   DEFINE rtl3 "file_loc"
   SELECT INTO "nl:"
    r2.line
    FROM rtl3t r2
    HEAD REPORT
     _filehandle = uar_fopen(nullterm(cpm_cfn_info->file_name_full_path),"w+b"), stat = 0, cnt = 0,
     colcnt = 0, columntitle = r2.line, nfind = 1,
     CALL echo(columntitle), _vcdocline = "<?xml version='1.0'?>", stat = uar_fwrite(_vcdocline,
      textlen(_vcdocline),1,_filehandle),
     _vcdocline = _xmlstylesheetpi, stat = uar_fwrite(_vcdocline,textlen(_vcdocline),1,_filehandle),
     _vcdocline = "<querydata><header>",
     stat = uar_fwrite(_vcdocline,textlen(_vcdocline),1,_filehandle)
     WHILE (nfind < textlen(columntitle))
       IF (nfind >= 1)
        colcnt += 1, stat = alterlist(colrec->cols,colcnt), colrec->cols[colcnt].startcol = nfind,
        nfind = findstring(" ",columntitle,nfind), bcontinue = 1, tlen = 0
        WHILE (bcontinue)
          tlen += 1
          IF (nfind=0)
           tlen = textlen(columntitle)
          ENDIF
          IF (((((nfind+ tlen) > textlen(columntitle))) OR (substring((nfind+ tlen),1,columntitle)
           != " ")) )
           bcontinue = 0, colrec->cols[colcnt].collength = (((nfind - colrec->cols[colcnt].startcol)
           + tlen) - 1), colrec->cols[colcnt].columnname = substring(colrec->cols[colcnt].startcol,
            colrec->cols[colcnt].collength,columntitle),
           nfind += tlen, _vcdocline = concat("<col>",colrec->cols[colcnt].columnname,"</col>"), stat
            = uar_fwrite(_vcdocline,textlen(_vcdocline),1,_filehandle)
          ENDIF
        ENDWHILE
       ENDIF
     ENDWHILE
     _vcdocline = "</header><data>", stat = uar_fwrite(_vcdocline,textlen(_vcdocline),1,_filehandle),
     detailx = 0
    DETAIL
     IF (detailx=1)
      new_line = r2.line, _vcdocline = "<row>", stat = uar_fwrite(_vcdocline,textlen(_vcdocline),1,
       _filehandle)
      FOR (colcnt = 1 TO size(colrec->cols,5))
       _vcdocline = build("<",colrec->cols[colcnt].columnname,">",_formatspecialxmlchars(trim(
          substring(colrec->cols[colcnt].startcol,colrec->cols[colcnt].collength,new_line),3)),"</",
        colrec->cols[colcnt].columnname,">"),stat = uar_fwrite(_vcdocline,textlen(_vcdocline),1,
        _filehandle)
      ENDFOR
      _vcdocline = "</row>", stat = uar_fwrite(_vcdocline,textlen(_vcdocline),1,_filehandle)
     ELSE
      detailx = 1
     ENDIF
    FOOT REPORT
     _vcdocline = "</data></querydata>", stat = uar_fwrite(_vcdocline,textlen(_vcdocline),1,
      _filehandle), stat = uar_fclose(_filehandle)
    WITH maxrow = 1
   ;end select
   FREE SET file_loc
   FREE DEFINE rtl3
   SET _stat = remove(vcfilein)
   RETURN(cpm_cfn_info->file_name_full_path)
  ENDIF
  RETURN(vcfilein)
 END ;Subroutine
 SUBROUTINE (_formatspecialxmlchars(source=vc) =vc WITH protect)
   DECLARE formattedsource = vc WITH noconstant(""), private
   SET formattedsource = replace(source,"<","&#60;",0)
   SET formattedsource = replace(formattedsource,">","&#62;",0)
   SET formattedsource = replace(formattedsource,"!","&#33;",0)
   SET formattedsource = replace(formattedsource,"%","&#37;",0)
   RETURN(formattedsource)
 END ;Subroutine
 SUBROUTINE (_isoutputdevicemine(outputdevice=vc) =i4 WITH protect)
   SET outputdevice = cnvtupper(outputdevice)
   IF (((outputdevice="MINE") OR (((outputdevice='"MINE"') OR (((outputdevice="'MINE'") OR (
   outputdevice="^MINE^")) )) )) )
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
 SUBROUTINE (_getprogramnameexcludedebuginfo(programnametocheck=vc) =vc WITH protect)
   DECLARE debugindex = i4 WITH noconstant(0), private
   SET debugindex = findstring("/",programnametocheck,1,0)
   IF (debugindex)
    RETURN(substring(1,(debugindex - 1),programnametocheck))
   ENDIF
   RETURN(programnametocheck)
 END ;Subroutine
 SUBROUTINE (_getoutputfilemediatype(outputfile=vc) =i2 WITH protect)
   DECLARE mediatype = i2 WITH noconstant(_k_media_type_text), protect
   DECLARE medialine = vc WITH noconstant(""), private
   FREE DEFINE rtl3
   FREE SET file_loc
   IF (size(_memory_reply_string) > 0)
    SET mediatype = _getmediatype(_memory_reply_string)
    RETURN(mediatype)
   ENDIF
   SET logical file_loc value(outputfile)
   DEFINE rtl3 "file_loc"
   SELECT INTO "nl:"
    r2.line
    FROM rtl3t r2
    HEAD REPORT
     medialine = r2.line, mediatype = _getmediatype(medialine)
    WITH maxrec = 1
   ;end select
   CALL echo(build(".. _GetOutputFileMediaType:outputFile= ",outputfile,", mediaType= ",mediatype))
   FREE DEFINE rtl3
   FREE SET file_loc
   RETURN(mediatype)
 END ;Subroutine
 SUBROUTINE (_getoutputfile(outputfile=vc) =i2 WITH protect)
   DECLARE outputmediatype = i2 WITH noconstant(_k_media_type_text), private
   DECLARE filehandle = i4 WITH noconstant(0), private
   DECLARE doneind = i4 WITH noconstant(false), private
   IF (_runtype=_k_run_type_report_xmloutput)
    SET outputmediatype = _k_media_type_xml
   ELSE
    SET outputmediatype = _getoutputfilemediatype(_outfile)
   ENDIF
   IF (outputmediatype IN (_k_media_type_text, _k_media_type_html, _k_media_type_postscript))
    CALL echo("..Invoke uar_fopen with read access..")
    SET filehandle = uar_fopen(nullterm(_outfile),"r")
   ELSE
    CALL echo("..Invoke uar_fopen with read/write access..")
    SET filehandle = uar_fopen(nullterm(_outfile),"rb")
   ENDIF
   CALL echo(build("..GetOutputFile() _outFile= ",_outfile,", fileHandle from uar_fopen: ",filehandle
     ))
   IF (filehandle != 0)
    DECLARE filesize = i4 WITH noconstant(0), private
    DECLARE nmore = i4 WITH private
    DECLARE vcmore = vc WITH private, notrim
    SET _stat = uar_fseek(filehandle,0,2)
    CALL echo(build("..uar_fseek status : ",_stat))
    SET filesize = (uar_ftell(filehandle)+ 512)
    SET reply->lpdfsize = filesize
    CALL echo(build("..file size: ",filesize))
    SET modify maxvarlen max_filesize
    IF (trace("MEMCOST")=1
     AND (filesize > ((curmem * 0.98) * 512)))
     SET _bmemoryerror = 1
    ENDIF
    IF (filesize > max_filesize)
     SET _deletefile = false
     SET reply->document = uar_i18nbuildmessage(_i18nhandle,"KeyBuild1",nullterm(concat(
        "Failed to read file due to exceeding max size: <%1>.",char(13),char(10),
        "File location: <%2> on node: <%3>.")),"iss",filesize,
      nullterm(trim(_outfile)),nullterm(value(curnode)))
     SET reply->lpdfsize = textlen(reply->document)
    ELSEIF (_bmemoryerror=1)
     SET _deletefile = false
     SET reply->document = uar_i18nbuildmessage(_i18nhandle,"KeyBuild1",nullterm(concat(
        "Failed to access file (%2) due to process memory (file size: %1). ",char(13),char(10),
        "Node: %3, server: %4.")),"isss",filesize,
      nullterm(trim(_outfile)),nullterm(value(curnode)),nullterm(substring(1,12,curprcname)))
     SET reply->lpdfsize = textlen(reply->document)
    ELSE
     DECLARE _repdoc = vc
     CALL echo(build("C",filesize))
     SET _stat = memrealloc(_repdoc,1,build("C",filesize))
     SET _stat = uar_fseek(filehandle,0,0)
     SET reply->lpdfsize = uar_fread(_repdoc,1,reply->lpdfsize,filehandle)
     SET reply->document = notrim(_repdoc)
     FREE SET _repdoc
    ENDIF
    SET _stat = uar_fclose(filehandle)
    IF (_stat=0)
     SET reply->ntotalrecords = 1
     SET _nrecords = 1
     SET reply->status_data.status = "S"
    ELSE
     SET _failedflag = "T"
     SET _errormsg = uar_i18ngetmessage(_i18nhandle,"failedclosefile","Failed to close file: ")
     SET _errormsg = concat(_errormsg,_outfile)
    ENDIF
   ELSE
    SET _failedflag = "T"
    SET _errormsg = uar_i18ngetmessage(_i18nhandle,"failedopenfile","Failed to open file: ")
    SET _errormsg = concat(_errormsg,_outfile)
   ENDIF
   IF (outputmediatype=_k_media_type_text)
    SET reply->ltxtlinemaxsize = _getmaxlinelength(reply->document)
   ELSE
    SET reply->ltxtlinemaxsize = 0
   ENDIF
   SET reply->nreporttype = outputmediatype
   CASE (outputmediatype)
    OF _k_media_type_postscript:
     SET _audit_type = "POSTSCRIPT"
    OF _k_media_type_pdf:
     SET _audit_type = "PDF"
    OF _k_media_type_rtf:
     SET _audit_type = "RTF"
    OF _k_media_type_html:
     SET _audit_type = "HTML"
    OF _k_media_type_xml:
     SET _audit_type = "XML"
   ENDCASE
 END ;Subroutine
 SUBROUTINE _getoutputfile_cclio(outputfile)
   CALL echo(build(".. Begin _GetOutputFile_CCLIO() for outputFile= ",outputfile))
   DECLARE outputmediatype = i2 WITH noconstant(_k_media_type_text), private
   DECLARE stat = i4
   DECLARE pos = i4
   RECORD frec(
     1 file_desc = i4
     1 file_offset = i4
     1 file_dir = i4
     1 file_name = vc
     1 file_buf = vc
   )
   SET frec->file_name = outputfile
   SET frec->file_buf = "r"
   SET stat = cclio("OPEN",frec)
   SET frec->file_buf = notrim(fillstring(132," "))
   IF ((frec->file_desc != 0))
    SET stat = 1
    WHILE (stat > 0)
      CALL echo(build("..while() stat= ",stat))
      SET stat = cclio("GETS",frec)
      IF (stat > 0)
       SET pos = findstring(char(0),frec->file_buf)
       SET pos = evaluate(pos,0,size(frec->file_buf),pos)
       CALL echo(substring(1,pos,frec->file_buf))
       SET reply->document = notrim(concat(reply->document,frec->file_buf))
       CALL echo(reply->document)
      ENDIF
    ENDWHILE
    SET stat = cclio("CLOSE",frec)
    SET reply->lpdfsize = textlen(reply->document)
    SET reply->ntotalrecords = 1
    SET _nrecords = 1
    SET reply->status_data.status = "S"
    IF (outputmediatype=_k_media_type_text)
     SET reply->ltxtlinemaxsize = _getmaxlinelength(reply->document)
    ELSE
     SET reply->ltxtlinemaxsize = 0
    ENDIF
    SET reply->nreporttype = outputmediatype
    CASE (outputmediatype)
     OF _k_media_type_postscript:
      SET _audit_type = "POSTSCRIPT"
     OF _k_media_type_pdf:
      SET _audit_type = "PDF"
     OF _k_media_type_rtf:
      SET _audit_type = "RTF"
     OF _k_media_type_html:
      SET _audit_type = "HTML"
     OF _k_media_type_xml:
      SET _audit_type = "XML"
    ENDCASE
   ENDIF
   CALL echorecord(frec)
 END ;Subroutine
 SUBROUTINE (_getoutputfile_rtl(outputfile=vc) =i2 WITH protect)
   CALL echo("Test _GetOutputFile_RTL, using RTL2 to open file..")
   DECLARE outputmediatype = i2 WITH noconstant(_k_media_type_text), private
   FREE DEFINE rtl2
   SET logical file_in value(outputfile)
   DEFINE rtl2 "FILE_IN"
   SELECT INTO "nl:"
    r2.line
    FROM rtl2t r2
    DETAIL
     reply->document = notrim(concat(reply->document,r2.line))
    WITH nocounter
   ;end select
   FREE DEFINE rtl2
   SET reply->lpdfsize = textlen(reply->document)
   SET reply->ntotalrecords = 1
   SET _nrecords = 1
   SET reply->status_data.status = "S"
   IF (outputmediatype=_k_media_type_text)
    SET reply->ltxtlinemaxsize = _getmaxlinelength(reply->document)
   ELSE
    SET reply->ltxtlinemaxsize = 0
   ENDIF
   SET reply->nreporttype = outputmediatype
   CALL echorecord(reply)
 END ;Subroutine
 SUBROUTINE (_getoutputfile_nodata(outputfile=vc) =vc WITH protect)
   DECLARE _filename_nodata = vc
   SET _filename_nodata = cnvtlower(build("cer_temp:","ccl_",substring(1,7,curprcname),"_nodata.dat")
    )
   IF (findfile(_filename_nodata,4)=0)
    SELECT INTO value(_filename_nodata)
     DETAIL
      _i18nnodatafoundmsg, row + 1
     WITH dio = 38, nocounter
    ;end select
   ENDIF
   SET _filename_nodata = _translatelogical(_filename_nodata)
   CALL echo(build("_GetOutputFile_NoData: file= ",_filename_nodata))
   RETURN(_filename_nodata)
 END ;Subroutine
 SUBROUTINE (_getmediatype(source=vc(ref)) =i2 WITH protect)
   CASE (substring(1,5,source))
    OF "%!PS-":
     RETURN(_k_media_type_postscript)
    OF "%PDF-":
    OF "PNG":
    OF "":
     RETURN(_k_media_type_pdf)
    OF "{\RTF":
    OF "{\rtf":
     RETURN(_k_media_type_rtf)
    OF "<html":
    OF "<HTML":
    OF "<!DOC":
     RETURN(_k_media_type_html)
    ELSE
     IF (((findstring("<html",source,1,0) > 0) OR (findstring("<HTML",source,1,0) > 0)) )
      RETURN(_k_media_type_html)
     ELSE
      RETURN(_k_media_type_text)
     ENDIF
   ENDCASE
 END ;Subroutine
 SUBROUTINE (_getmaxlinelength(document=vc) =i4 WITH protect)
   DECLARE linelength = i4 WITH noconstant(0), private
   DECLARE maxlength = i4 WITH noconstant(0), private
   DECLARE doneind = i4 WITH noconstant(false), private
   DECLARE startpos = i4 WITH noconstant(0), private
   DECLARE endpos = i4 WITH noconstant(0), private
   SET startpos = 1
   WHILE (doneind != true)
     SET endpos = findstring(char(10),document,startpos,0)
     SET linelength = (endpos - startpos)
     IF (linelength > maxlength)
      SET maxlength = linelength
     ENDIF
     IF (((linelength <= 0) OR (endpos=0)) )
      SET doneind = true
     ELSE
      SET startpos = endpos
     ENDIF
   ENDWHILE
   RETURN(maxlength)
 END ;Subroutine
 SUBROUTINE (_getxmlformattedprintedfilenames(filename=vc,hasextension=i4) =vc WITH protect)
   DECLARE filecount = i4 WITH noconstant(0), private
   DECLARE printedfile = vc WITH noconstant(""), private
   DECLARE xmlprintedfiles = vc WITH noconstant(""), private
   DECLARE xmlerrormessages = vc WITH noconstant(""), private
   SET filecount = 1
   SET xmlprintedfiles = "<files>"
   IF (hasextension)
    SET printedfile = filename
    IF (findfile(printedfile)=1)
     SET xmlprintedfiles = concat(xmlprintedfiles,"<filename>",filename,"</filename>")
     SET filecount += 1
    ENDIF
   ELSE
    SET printedfile = concat(filename,".",format(filecount,"###;P0"))
    WHILE (findfile(printedfile)=1)
      SET xmlprintedfiles = concat(xmlprintedfiles,"<filename>",printedfile,"</filename>")
      SET filecount += 1
      SET printedfile = concat(filename,".",format(filecount,"###;P0"))
    ENDWHILE
   ENDIF
   SET xmlprintedfiles = concat(xmlprintedfiles,"</files>")
   SET xmlerrormessages = "<errors>"
   IF (filecount=1)
    SET xmlerrormessages = concat(xmlerrormessages,"<errormsg>",_i18nnodatafoundmsg,"</errormsg>")
   ENDIF
   SET xmlerrormessages = concat(xmlerrormessages,"</errors>")
   RETURN(concat("<printfiles>",xmlprintedfiles,xmlerrormessages,"</printfiles>"))
 END ;Subroutine
 SUBROUTINE (_writexmlquerynodatamessage(outputfile=vc) =null WITH protect)
   DECLARE _filehandle = i4 WITH noconstant(0), private
   SET _vcdocline = concat("<querydata><header><col>STATUS</col></header><data><row><STATUS>",
    _i18nnodatafoundmsg,"</STATUS></row></data></querydata>")
   SET _filehandle = uar_fopen(nullterm(outputfile),"w+b")
   SET stat = uar_fwrite(_vcdocline,textlen(_vcdocline),1,_filehandle)
   SET stat = uar_fclose(_filehandle)
 END ;Subroutine
 SUBROUTINE (_isauditenabled_programoruser(prsnl_id=f8) =i2 WITH protect)
   DECLARE _isauditenabled = i2 WITH noconstant(0), private
   SET prgcnt = size(cclrptaudit_rec->programs,5)
   SET usercnt = size(cclrptaudit_rec->users,5)
   FOR (_cnt = 1 TO prgcnt)
     IF (cnvtupper(cclrptaudit_rec->programs[_cnt].script_name)=_programname)
      SET _isauditenabled = 1
     ENDIF
   ENDFOR
   IF (_isauditenabled=0)
    FOR (_cnt = 1 TO usercnt)
      IF ((cclrptaudit_rec->users[_cnt].prsnl_id=prsnl_id))
       SET _isauditenabled = 1
      ENDIF
    ENDFOR
   ENDIF
   RETURN(_isauditenabled)
 END ;Subroutine
END GO
