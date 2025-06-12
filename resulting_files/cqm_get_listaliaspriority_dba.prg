CREATE PROGRAM cqm_get_listaliaspriority:dba
 DECLARE program_modification = vc
 SET program_modification = "AUG-02-2007"
 CALL echo(program_modification)
 CALL echorecord(request)
 RECORD reply(
   1 list[*]
     2 trigger_id = f8
     2 queue_id = f8
     2 listener_id = f8
     2 create_dt_tm = dq8
     2 process_start_dt_tm = dq8
     2 process_stop_dt_tm = dq8
     2 schedule_dt_tm = dq8
     2 priority = i4
     2 active_ind = i2
     2 number_of_retries = i4
     2 last_retry_dt_tm = dq8
     2 process_status_flag = i2
     2 trigger_status_text = vc
     2 completion_sequence_id = f8
     2 l_r_process_status_flag = i2
     2 l_r_trigger_status_text = vc
     2 debug_ind = i2
     2 verbosity_flag = i2
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_cnt = i4
     2 updt_applctx = f8
   1 status_data
     2 status = c1
 )
 CALL echo("<===== ESO_GET_CODE.INC Begin =====>")
 CALL echo("MOD:008")
 DECLARE eso_get_code_meaning(code) = c12
 DECLARE eso_get_code_display(code) = c40
 DECLARE eso_get_meaning_by_codeset(x_code_set,x_meaning) = f8
 DECLARE eso_get_code_set(code) = i4
 DECLARE eso_get_alias_or_display(code,contrib_src_cd) = vc
 SUBROUTINE eso_get_code_meaning(code)
   CALL echo("Entering eso_get_code_meaning subroutine")
   CALL echo(build("    code=",code))
   FREE SET t_meaning
   DECLARE t_meaning = c12
   SET t_meaning = fillstring(12," ")
   IF (code > 0)
    IF (validate(readme_data,0))
     CALL echo("    A Readme is calling this script")
     CALL echo("    selecting rows from code_value table")
     SELECT INTO "nl:"
      cv.*
      FROM code_value cv
      WHERE cv.code_value=code
       AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
       AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND cv.active_ind=1
      DETAIL
       t_meaning = cv.cdf_meaning
      WITH maxqual(cv,1)
     ;end select
     IF (curqual < 1)
      CALL echo("    no rows qualified on code_value table")
     ENDIF
    ELSE
     SET t_meaning = uar_get_code_meaning(cnvtreal(code))
     IF (trim(t_meaning)="")
      CALL echo("    uar_get_code_meaning failed")
      CALL echo("    selecting row from code_value table")
      SELECT INTO "nl:"
       cv.*
       FROM code_value cv
       WHERE cv.code_value=code
        AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
        AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND cv.active_ind=1
       DETAIL
        t_meaning = cv.cdf_meaning
       WITH maxqual(cv,1)
      ;end select
      IF (curqual < 1)
       CALL echo("    no rows qualified on code_value table")
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("    t_meaning=",t_meaning))
   CALL echo("Exiting eso_get_code_meaning subroutine")
   RETURN(trim(t_meaning,3))
 END ;Subroutine
 SUBROUTINE eso_get_code_display(code)
   CALL echo("Entering eso_get_code_display subroutine")
   CALL echo(build("    code=",code))
   FREE SET t_display
   DECLARE t_display = c40
   SET t_display = fillstring(40," ")
   IF (code > 0)
    IF (validate(readme_data,0))
     CALL echo("   A Readme is calling this script")
     CALL echo("   Selecting rows from code_value table")
     SELECT INTO "nl:"
      cv.*
      FROM code_value cv
      WHERE cv.code_value=code
       AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
       AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND cv.active_ind=1
      DETAIL
       t_display = cv.display
      WITH maxqual(cv,1)
     ;end select
     IF (curqual < 1)
      CALL echo("    no rows qualified on code_value table")
     ENDIF
    ELSE
     SET t_display = uar_get_code_display(cnvtreal(code))
     IF (trim(t_display)="")
      CALL echo("    uar_get_code_display failed")
      CALL echo("    selecting row from code_value table")
      SELECT INTO "nl:"
       cv.*
       FROM code_value cv
       WHERE cv.code_value=code
        AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
        AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND cv.active_ind=1
       DETAIL
        t_display = cv.display
       WITH maxqual(cv,1)
      ;end select
      IF (curqual < 1)
       CALL echo("    no rows qualified on code_value table")
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("    t_display=",t_display))
   CALL echo("Exiting eso_get_code_display subroutine")
   RETURN(trim(t_display,3))
 END ;Subroutine
 SUBROUTINE eso_get_meaning_by_codeset(x_code_set,x_meaning)
   CALL echo("Entering eso_get_meaning_by_codeset subroutine")
   CALL echo(build("    code_set=",x_code_set))
   CALL echo(build("    meaning=",x_meaning))
   FREE SET t_code
   DECLARE t_code = f8
   SET t_code = 0.0
   IF (x_code_set > 0
    AND trim(x_meaning) > "")
    FREE SET t_meaning
    DECLARE t_meaning = c12
    SET t_meaning = fillstring(12," ")
    SET t_meaning = x_meaning
    FREE SET t_rc
    IF (validate(readme_data,0))
     CALL echo("   A Readme is calling this script")
     CALL echo("   Selecting rows from code_value table")
     SELECT INTO "nl:"
      cv.*
      FROM code_value cv
      WHERE cv.code_set=x_code_set
       AND cv.cdf_meaning=trim(x_meaning)
       AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
       AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND cv.active_ind=1
      DETAIL
       t_code = cv.code_value
      WITH maxqual(cv,1)
     ;end select
     IF (curqual < 1)
      CALL echo("    no rows qualified on code_value table")
     ENDIF
    ELSE
     SET t_rc = uar_get_meaning_by_codeset(cnvtint(x_code_set),nullterm(t_meaning),1,t_code)
     IF (t_code <= 0)
      CALL echo("    uar_get_meaning_by_codeset failed")
      CALL echo("    selecting row from code_value table")
      SELECT INTO "nl:"
       cv.*
       FROM code_value cv
       WHERE cv.code_set=x_code_set
        AND cv.cdf_meaning=trim(x_meaning)
        AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
        AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND cv.active_ind=1
       DETAIL
        t_code = cv.code_value
       WITH maxqual(cv,1)
      ;end select
      IF (curqual < 1)
       CALL echo("    no rows qualified on code_value table")
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("    t_code=",t_code))
   CALL echo("Exiting eso_get_meaning_by_codeset subroutine")
   RETURN(t_code)
 END ;Subroutine
 SUBROUTINE eso_get_code_set(code)
   CALL echo("Entering eso_get_code_set subroutine")
   CALL echo(build("    code=",code))
   DECLARE icode_set = i4 WITH private, noconstant(0)
   IF (code > 0)
    IF (validate(readme_data,0))
     CALL echo("   A Readme is calling this script")
     CALL echo("   Selecting rowS from code_value table")
     SELECT INTO "nl:"
      cv.code_set
      FROM code_value cv
      WHERE cv.code_value=code
       AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
       AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND cv.active_ind=1
      DETAIL
       icode_set = cv.code_set
      WITH maxqual(cv,1)
     ;end select
     IF (curqual < 1)
      CALL echo("    no rows qualified on code_value table")
     ENDIF
    ELSE
     SET icode_set = uar_get_code_set(cnvtreal(code))
     IF ( NOT (icode_set > 0))
      CALL echo("    uar_get_code_set failed")
      CALL echo("    selecting row from code_value table")
      SELECT INTO "nl:"
       cv.code_set
       FROM code_value cv
       WHERE cv.code_value=code
        AND cv.begin_effective_dt_tm < cnvtdatetime(sysdate)
        AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND cv.active_ind=1
       DETAIL
        icode_set = cv.code_set
       WITH maxqual(cv,1)
      ;end select
      IF (curqual < 1)
       CALL echo("    no rows qualified on code_value table")
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("    Code_set=",icode_set))
   CALL echo("Exiting eso_get_code_set subroutine")
   RETURN(icode_set)
 END ;Subroutine
 SUBROUTINE eso_get_alias_or_display(code,contrib_src_cd)
   CALL echo("Entering eso_get_alias_or_display")
   CALL echo(build("   code            = ",code))
   CALL echo(build("   contrib_src_cd = ",contrib_src_cd))
   FREE SET t_alias_or_display
   DECLARE t_alias_or_display = vc
   SET t_alias_or_display = " "
   IF ( NOT (code > 0.0))
    RETURN(t_alias_or_display)
   ENDIF
   IF (contrib_src_cd > 0.0)
    SELECT INTO "nl:"
     cvo.alias
     FROM code_value_outbound cvo
     WHERE cvo.code_value=code
      AND cvo.contributor_source_cd=contrib_src_cd
     DETAIL
      IF (cvo.alias > "")
       t_alias_or_display = cvo.alias
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (size(trim(t_alias_or_display))=0)
    CALL echo("Alias not found, checking code value display")
    SET t_alias_or_display = eso_get_code_display(code)
   ENDIF
   CALL echo("Exiting eso_get_alias_or_display")
   RETURN(t_alias_or_display)
 END ;Subroutine
 CALL echo("<===== ESO_GET_CODE.INC End =====>")
 DECLARE count = i4
 DECLARE stat = i2
 DECLARE tablename = vc
 DECLARE date1 = f8
 SET count = 0
 SET stat = 0
 SET tablename = cnvtupper(request->tablename)
 IF ((request->maxqual=0))
  SET request->maxqual = 10
 ENDIF
 IF (validate(iorderbycqmidflag,999)=999)
  DECLARE iorderbycqmidflag = i4 WITH public, noconstant(0), persist
  SET desodefault = eso_get_meaning_by_codeset(89,"ESODEFAULT")
  SET dorderbycqmid = eso_get_meaning_by_codeset(14874,"ORDERBYCQMID")
  SELECT INTO "nl:"
   ofp.process_type_cd
   FROM outbound_field_processing ofp
   WHERE ofp.process_type_cd=dorderbycqmid
    AND ofp.contributor_system_cd=desodefault
    AND ofp.active_ind=1
   DETAIL
    iorderbycqmidflag = 1
   WITH nocounter
  ;end select
  CALL echo(build2("iOrderByCQMIdFlag = ",iorderbycqmidflag))
 ENDIF
 IF (((tablename="CQM_OENINTERFACE_TR_1") OR (tablename="CQM_FSIESO_TR_1"))
  AND iorderbycqmidflag != 1)
  SELECT
   IF ((request->control=13))
    WHERE (c.process_status_flag=request->process_status_flag)
     AND (c.priority <= request->priority)
     AND (c.listener_id=request->listener_id)
     AND (c.trigger_id >= request->trigger_id)
     AND c.trigger_id > 0
    ORDER BY c.priority, c.trigger_id
   ELSE
   ENDIF
   INTO "nl:"
   FROM (value(tablename) c)
   WHERE (c.process_status_flag=request->process_status_flag)
    AND (c.priority <= request->priority)
    AND (c.listener_id=request->listener_id)
    AND (c.trigger_id >= request->trigger_id)
    AND c.trigger_id > 0
   ORDER BY c.message_sequence, c.trigger_id
   DETAIL
    count += 1, stat = alterlist(reply->list,count), reply->list[count].trigger_id = c.trigger_id,
    reply->list[count].queue_id = c.queue_id, reply->list[count].listener_id = c.listener_id, reply->
    list[count].create_dt_tm = cnvtdatetime(c.create_dt_tm),
    reply->list[count].process_start_dt_tm = cnvtdatetime(c.process_start_dt_tm), reply->list[count].
    schedule_dt_tm = cnvtdatetime(c.schedule_dt_tm), reply->list[count].priority = c.priority,
    reply->list[count].active_ind = c.active_ind, reply->list[count].number_of_retries = c
    .number_of_retries, reply->list[count].last_retry_dt_tm = cnvtdatetime(c.last_retry_dt_tm),
    reply->list[count].process_status_flag = c.process_status_flag, reply->list[count].
    trigger_status_text = c.trigger_status_text, reply->list[count].completion_sequence_id = c
    .completion_sequence_id,
    reply->list[count].l_r_process_status_flag = c.l_r_process_status_flag, reply->list[count].
    l_r_trigger_status_text = c.l_r_trigger_status_text, reply->list[count].debug_ind = c.debug_ind,
    reply->list[count].verbosity_flag = c.verbosity_flag, reply->list[count].updt_dt_tm =
    cnvtdatetime(c.updt_dt_tm), reply->list[count].updt_task = c.updt_task,
    reply->list[count].updt_id = c.updt_id, reply->list[count].updt_applctx = c.updt_applctx
   WITH nocounter, maxqual(c,value(request->maxqual))
  ;end select
 ELSE
  SELECT
   IF ((request->control=13))
    WHERE (c.process_status_flag=request->process_status_flag)
     AND (c.priority <= request->priority)
     AND (c.listener_id=request->listener_id)
     AND (c.trigger_id >= request->trigger_id)
     AND c.trigger_id > 0
    ORDER BY c.priority, c.trigger_id
   ELSE
   ENDIF
   INTO "nl:"
   FROM (value(tablename) c)
   WHERE (c.process_status_flag=request->process_status_flag)
    AND (c.priority <= request->priority)
    AND (c.listener_id=request->listener_id)
    AND (c.trigger_id >= request->trigger_id)
    AND c.trigger_id > 0
   ORDER BY c.trigger_id
   DETAIL
    count += 1, stat = alterlist(reply->list,count), reply->list[count].trigger_id = c.trigger_id,
    reply->list[count].queue_id = c.queue_id, reply->list[count].listener_id = c.listener_id, reply->
    list[count].create_dt_tm = cnvtdatetime(c.create_dt_tm),
    reply->list[count].process_start_dt_tm = cnvtdatetime(c.process_start_dt_tm), reply->list[count].
    schedule_dt_tm = cnvtdatetime(c.schedule_dt_tm), reply->list[count].priority = c.priority,
    reply->list[count].active_ind = c.active_ind, reply->list[count].number_of_retries = c
    .number_of_retries, reply->list[count].last_retry_dt_tm = cnvtdatetime(c.last_retry_dt_tm),
    reply->list[count].process_status_flag = c.process_status_flag, reply->list[count].
    trigger_status_text = c.trigger_status_text, reply->list[count].completion_sequence_id = c
    .completion_sequence_id,
    reply->list[count].l_r_process_status_flag = c.l_r_process_status_flag, reply->list[count].
    l_r_trigger_status_text = c.l_r_trigger_status_text, reply->list[count].debug_ind = c.debug_ind,
    reply->list[count].verbosity_flag = c.verbosity_flag, reply->list[count].updt_dt_tm =
    cnvtdatetime(c.updt_dt_tm), reply->list[count].updt_task = c.updt_task,
    reply->list[count].updt_id = c.updt_id, reply->list[count].updt_applctx = c.updt_applctx
   WITH nocounter, maxqual(c,value(request->maxqual))
  ;end select
 ENDIF
 CALL echo(build("count:",count))
 IF (count > 0)
  CALL echo(build("priority_id:",reply->list[1].priority))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
