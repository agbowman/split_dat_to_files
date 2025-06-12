CREATE PROGRAM ccl_run_program_from_ops:dba
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
 SET curscope = private
 RECORD reply(
   1 ops_event = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE errmsg = c132
 DECLARE leftsinglequote = vc WITH constant(char(145))
 DECLARE rightsinglequote = vc WITH constant(char(146))
 DECLARE leftdoublequote = vc WITH constant(char(147))
 DECLARE rightdoublequote = vc WITH constant(char(148))
 IF (((findstring(leftsinglequote,request->batch_selection) > 0) OR (findstring(rightsinglequote,
  request->batch_selection) > 0)) )
  SET request->batch_selection = replace(replace(request->batch_selection,leftsinglequote,"'"),
   rightsinglequote,"'")
 ENDIF
 IF (((findstring(leftdoublequote,request->batch_selection) > 0) OR (findstring(rightdoublequote,
  request->batch_selection) > 0)) )
  SET request->batch_selection = replace(replace(request->batch_selection,leftdoublequote,'"'),
   rightdoublequote,'"')
 ENDIF
 SET com = concat("execute ",request->batch_selection," go")
 SET reply->status_data.status = "F"
 SET reply->ops_event = concat("Error Attempting: ",trim(com))
 SET curscope = public
 DECLARE _audit_flag = i2 WITH protect
 DECLARE _programname = vc WITH protect
 DECLARE _audit_type = c20 WITH protect
 SET _audit_flag = 0
 CALL echo(concat("batch_selection= ",request->batch_selection))
 SET _batch_selection = cnvtupper(trim(request->batch_selection))
 IF (substring(1,7,_batch_selection)="EXECUTE")
  SET _batch_selection = substring(8,(textlen(_batch_selection) - 7),_batch_selection)
 ENDIF
 SET _findchar = findstring(" ",_batch_selection,1)
 IF (_findchar > 0)
  SET _programname = substring(1,(_findchar - 1),_batch_selection)
  SET _params = substring((_findchar+ 1),(textlen(_batch_selection) - _findchar),_batch_selection)
 ELSE
  SET _programname = _batch_selection
  SET _params = "<NO PARAMS>"
 ENDIF
 SET _audit_flag = ccl_init_audit(_programname,"OPSREPORT")
 CALL parser(com)
 SET stat = error(errmsg,0)
 IF (stat=0)
  IF (_audit_flag=1)
   CALL ccl_write_audit(_programname,"OPSREPORT","SUCCESS",1)
  ENDIF
  SET curscope = private
  SET reply->status_data.status = "S"
  SET reply->ops_event = concat("Successful: ",trim(com))
 ELSE
  IF (_audit_flag=1)
   CALL ccl_write_audit(_programname,"OPSREPORT","FAILED",0)
  ENDIF
  SET curscope = private
  SET reply->status_data.status = "F"
  SET reply->ops_event = concat("Error Attempting: ",trim(com))
  SET cnt = 5
  CALL echo("---")
  WHILE (cnt >= 1)
    SET stat = error(errmsg,0)
    CALL echo(errmsg)
    SET cnt -= 1
  ENDWHILE
  CALL echo("---")
 ENDIF
END GO
