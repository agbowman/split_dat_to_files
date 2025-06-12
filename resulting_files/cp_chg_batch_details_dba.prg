CREATE PROGRAM cp_chg_batch_details:dba
 RECORD reply(
   1 charting_operations_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE hsys = i4 WITH protect, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE crsl_msg_default = h WITH protect, noconstant(0)
 DECLARE crsl_msg_level = h WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle()
 SET crsl_msg_level = uar_msggetlevel(crsl_msg_default)
 DECLARE lcrslsubeventcnt = i4 WITH protect, noconstant(0)
 DECLARE icrslloggingstat = i2 WITH protect, noconstant(0)
 DECLARE lcrslsubeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE scrsllogtext = vc WITH protect, noconstant("")
 DECLARE scrsllogevent = vc WITH protect, noconstant("")
 DECLARE icrslholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE crsl_info_domain = vc WITH protect, constant("CLINRPT SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=crsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=crsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET icrslloglvloverrideind = 0
   SET scrsllogtext = ""
   SET scrsllogevent = ""
   SET scrsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET icrslholdloglevel = loglvl
   ELSE
    IF (crsl_msg_level < loglvl)
     SET icrslholdloglevel = crsl_msg_level
     SET icrslloglvloverrideind = 1
    ELSE
     SET icrslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (icrslloglvloverrideind=1)
    SET scrsllogevent = "Script_Override"
   ELSE
    CASE (icrslholdloglevel)
     OF log_level_error:
      SET scrsllogevent = "Script_Error"
     OF log_level_warning:
      SET scrsllogevent = "Script_Warning"
     OF log_level_audit:
      SET scrsllogevent = "Script_Audit"
     OF log_level_info:
      SET scrsllogevent = "Script_Info"
     OF log_level_debug:
      SET scrsllogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(crsl_msg_default,0,nullterm(scrsllogevent),
    icrslholdloglevel,nullterm(scrsllogtext))
   CALL echo(logmsg)
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     SET reply->status_data.status = "F"
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus(opname,"F",serrmsg,logmsg)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET reply->status_data.status = "Z"
    CALL populate_subeventstatus(opname,"Z","No records qualified",logmsg)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(reply->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(reply->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SET log_program_name = "CP_CHG_BATCH_DETAILS"
 DECLARE paramlist_nbr = i4 WITH noconstant(0)
 DECLARE x = i4 WITH noconstant(0)
 DECLARE y = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE locaval = i4
 DECLARE next_sequence = i4 WITH noconstant(0)
 DECLARE param_filename = i4 WITH constant(23)
 DECLARE updatefilemask(null) = null WITH protect
 DECLARE logical_domain_id = f8 WITH noconstant(0.0)
 SET reply->status_data.status = "F"
 SET failed = "F"
 IF ((request->requesting_prsnl_id > 0.0))
  SELECT INTO "NL:"
   p.logical_domain_id
   FROM prsnl p,
    logical_domain ld
   PLAN (p
    WHERE (p.person_id=request->requesting_prsnl_id))
    JOIN (ld
    WHERE ld.logical_domain_id=p.logical_domain_id)
   DETAIL
    logical_domain_id = p.logical_domain_id
   WITH nocounter
  ;end select
 ENDIF
 CALL updatefilemask(null)
 IF ((request->charting_operations_id > 0))
  DELETE  FROM charting_operations co
   SET co.seq = 1
   WHERE (co.charting_operations_id=request->charting_operations_id)
  ;end delete
  SET size_params = 0
  SET size_params = size(request->qual,5)
  INSERT  FROM charting_operations co,
    (dummyt d  WITH seq = value(size_params))
   SET co.charting_operations_id = request->charting_operations_id, co.batch_name = substring(1,100,
     request->batch_name), co.batch_name_key = cnvtupper(cnvtalphanum(substring(1,100,request->
       batch_name))),
    co.sequence = d.seq, co.param_type_flag = request->qual[d.seq].param_type_flag, co.param =
    substring(1,100,request->qual[d.seq].param),
    co.active_ind = request->qual[d.seq].active_ind, co.active_status_dt_tm = cnvtdatetime(sysdate),
    co.active_status_prsnl_id = reqinfo->updt_id,
    co.active_status_cd =
    IF ((request->qual[d.seq].active_ind=1)) reqdata->active_status_cd
    ELSE reqdata->inactive_status_cd
    ENDIF
    , co.updt_cnt = 1, co.updt_dt_tm = cnvtdatetime(sysdate),
    co.updt_id = reqinfo->updt_id, co.updt_task = reqinfo->updt_task, co.updt_applctx = reqinfo->
    updt_applctx,
    co.logical_domain_id = logical_domain_id
   PLAN (d)
    JOIN (co)
   WITH nocounter
  ;end insert
 ELSEIF ((request->charting_operations_id=0))
  SELECT INTO "nl:"
   w1 = seq(chart_db_seq,nextval)
   FROM dual
   DETAIL
    request->charting_operations_id = w1, reply->charting_operations_id = request->
    charting_operations_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL echo("unable to get new seq for charting_operations_id")
   SET failed = "T"
   GO TO exit_script
  ENDIF
  SET size_params = 0
  SET size_params = size(request->qual,5)
  INSERT  FROM charting_operations co,
    (dummyt d  WITH seq = value(size_params))
   SET co.charting_operations_id = request->charting_operations_id, co.batch_name = substring(1,100,
     request->batch_name), co.batch_name_key = cnvtupper(cnvtalphanum(substring(1,100,request->
       batch_name))),
    co.sequence = d.seq, co.param_type_flag = request->qual[d.seq].param_type_flag, co.param =
    substring(1,100,request->qual[d.seq].param),
    co.active_ind = request->qual[d.seq].active_ind, co.active_status_dt_tm = cnvtdatetime(sysdate),
    co.active_status_prsnl_id = reqinfo->updt_id,
    co.active_status_cd =
    IF ((request->qual[d.seq].active_ind=1)) reqdata->active_status_cd
    ELSE reqdata->inactive_status_cd
    ENDIF
    , co.updt_cnt = 0, co.updt_dt_tm = cnvtdatetime(sysdate),
    co.updt_id = reqinfo->updt_id, co.updt_task = reqinfo->updt_task, co.updt_applctx = reqinfo->
    updt_applctx,
    co.logical_domain_id = logical_domain_id
   PLAN (d)
    JOIN (co)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL echo("unable to get new seq for charting_operations_id")
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (x = 1 TO size_params)
   IF ((request->qual[x].param_type_flag=20))
    DELETE  FROM charting_operations_prsnl cop
     SET cop.seq = 1
     WHERE (cop.charting_operations_id=request->charting_operations_id)
    ;end delete
    SET paramlist_nbr = size(request->qual[x].param_list,5)
    IF (paramlist_nbr > 0)
     INSERT  FROM charting_operations_prsnl cop,
       (dummyt d  WITH seq = paramlist_nbr)
      SET cop.charting_operations_prsnl_id = seq(chart_db_seq,nextval), cop.charting_operations_id =
       request->charting_operations_id, cop.prsnl_id = request->qual[x].param_list[d.seq].param_id,
       cop.updt_cnt = 0, cop.updt_dt_tm = cnvtdatetime(sysdate), cop.updt_id = reqinfo->updt_id,
       cop.updt_task = reqinfo->updt_task, cop.updt_applctx = reqinfo->updt_applctx
      PLAN (d)
       JOIN (cop)
      WITH nocounter
     ;end insert
     IF (curqual=0)
      CALL echo("unable to get new seq for charting_operations_prsnl_id")
      SET failed = "T"
      GO TO exit_script
     ENDIF
    ENDIF
    SET x = (size_params+ 1)
   ENDIF
 ENDFOR
 DECLARE params[50] = i2
 SET highest_param = 0
 SET highest_param = request->max_param
 SET highest_seq = 0
 SELECT INTO "nl:"
  co.charting_operations_id, co.param_type_flag, co.param,
  co.active_ind
  FROM charting_operations co
  WHERE (co.charting_operations_id=request->charting_operations_id)
  ORDER BY co.param_type_flag, co.param, co.active_ind
  HEAD REPORT
   highest_seq = 0
  DETAIL
   IF (co.active_ind=1)
    params[co.param_type_flag] = 1
   ENDIF
   IF (co.sequence > highest_seq)
    highest_seq = co.sequence
   ENDIF
  WITH nocounter
 ;end select
 SET y = 0
 SET x = 0
 FOR (x = 1 TO highest_param)
   IF ((params[x]=1))
    SET do_nothing = 0
   ELSE
    SET y += 1
    CALL insert_param(x,y)
   ENDIF
 ENDFOR
 SUBROUTINE insert_param(param_type_flag,had_to_add_cnt)
   INSERT  FROM charting_operations c
    SET c.charting_operations_id = request->charting_operations_id, c.batch_name = request->
     batch_name, c.batch_name_key = cnvtupper(cnvtalphanum(request->batch_name)),
     c.sequence = (highest_seq+ had_to_add_cnt), c.param_type_flag = param_type_flag, c.param =
     IF ( NOT (param_type_flag IN (17, 24))) "0"
     ELSE " "
     ENDIF
     ,
     c.active_ind = 1, c.active_status_cd = reqdata->active_status_cd, c.active_status_prsnl_id =
     reqinfo->updt_id,
     c.active_status_dt_tm = cnvtdatetime(sysdate), c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(
      sysdate),
     c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->
     updt_applctx,
     c.logical_domain_id = logical_domain_id
    WITH nocounter
   ;end insert
 END ;Subroutine
 SUBROUTINE updatefilemask(null)
   CALL log_message("In UpdateFileMask()",log_level_debug)
   FREE RECORD temp_request
   RECORD temp_request(
     1 mask_template = vc
     1 mask_id = f8
     1 default_ind = i2
     1 action_type = i2
   )
   FREE RECORD temp_reply
   RECORD temp_reply(
     1 cr_mask_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET qualpos = locateval(idx,1,size(request->qual,5),param_filename,request->qual[idx].
    param_type_flag)
   IF (qualpos > 0)
    SET temp_request->mask_template = substring(1,255,request->qual[qualpos].param)
    EXECUTE cr_maintain_mask  WITH replace("REQUEST","TEMP_REQUEST"), replace("REPLY","TEMP_REPLY")
    IF ((temp_reply->status_data.status="Z"))
     CALL log_message("Unable to retrieve mask id for charting_operations_id",log_level_debug)
    ELSEIF ((temp_reply->status_data.status="F"))
     CALL log_message("Failed executing cr_maintain_mask",log_level_debug)
     SET reply->status_data.status = "F"
     GO TO exit_script
    ELSE
     SET request->qual[qualpos].param = cnvtstring(temp_reply->cr_mask_id)
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSEIF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
