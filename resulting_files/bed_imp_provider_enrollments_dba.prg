CREATE PROGRAM bed_imp_provider_enrollments:dba
 RECORD requestin_lookup(
   1 provider_list[*]
     2 prsnl_id = f8
     2 location_cd = f8
     2 payer_org_id = f8
     2 health_plan_id = f8
     2 bill_type_found_ind = i2
     2 bill_type_flag = i2
     2 participation_status_cd = f8
 ) WITH protect
 RECORD log(
   1 provider_log[*]
     2 prsnl_name = vc
     2 facility_name = vc
     2 status = vc
     2 error = vc
 ) WITH protect
 RECORD ensure_request(
   1 action_ind = i2
   1 provider_list[1]
     2 provider_enrollment_id = f8
     2 prsnl_id = f8
     2 location_cd = f8
     2 payer_org_id = f8
     2 health_plan_id = f8
     2 bill_type_flag = i2
     2 participation_status_cd = f8
     2 comments = vc
     2 timely_filling_dt_tm = dq8
     2 process_beg_effective_dt_tm = dq8
     2 process_end_effective_dt_tm = dq8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 priority_seq = i4
     2 paperwork_submitted_dt_tm = dq8
     2 paperwork_acknowledged_dt_tm = dq8
 ) WITH protect
 RECORD ensure_reply(
   1 provider_list[*]
     2 provider_enrollment_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE validateprovider(providerindex=i4) = i2
 DECLARE validatebeginandenddates(begindate=vc(value,""),enddate=vc(value,""),allowemptyenddateind=i2
  (value,0)) = i2
 DECLARE file_name = vc WITH protect, constant("bed_provider_enrollments.csv")
 DECLARE log_name = vc WITH protect, constant(validate(log_title_set,"Provider Enrollments Log"))
 DECLARE log_file_name = vc WITH protect, constant(validate(log_name_set,
   "bed_ins_provider_enrollments.log"))
 DECLARE log_directory = vc WITH protect, constant("CCLUSERDIR:")
 DECLARE log_file_path = vc WITH protect, constant(concat(trim(log_directory),log_file_name))
 DECLARE begin_dt_tm = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE end_dt_tm = dq8 WITH protect, constant(cnvtdatetime("31-DEC-2100 00:00:00"))
 DECLARE write_mode = i2 WITH protect, constant(evaluate(validate(tempreq->insert_ind,"N"),"Y",1,0))
 DECLARE npi_alias_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",320,"NPI"))
 DECLARE num_provider_rows = i4 WITH protect, constant(size(requestin->list_0,5))
 DECLARE provider_row_idx = i4 WITH protect, noconstant(0)
 DECLARE success_cnt = i4 WITH protect, noconstant(0)
 DECLARE failure_cnt = i4 WITH protect, noconstant(0)
 DECLARE failure_flag = c1 WITH protect, noconstant("Y")
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET stat = alterlist(requestin_lookup->provider_list,num_provider_rows)
 CALL setprsnlid(num_provider_rows)
 CALL setlocationcd(num_provider_rows)
 CALL setpayerordid(num_provider_rows)
 CALL sethealthplanid(num_provider_rows)
 CALL setholdclaimtype(num_provider_rows)
 CALL setparticipationstatuscd(num_provider_rows)
 CALL logstart(log_name,log_file_path)
 SET stat = alterlist(log->provider_log,num_provider_rows)
 FOR (provider_row_idx = 1 TO num_provider_rows)
   SET log->provider_log[provider_row_idx].prsnl_name = build(requestin->list_0[provider_row_idx].
    last_name,", ",requestin->list_0[provider_row_idx].first_name)
   SET log->provider_log[provider_row_idx].facility_name = requestin->list_0[provider_row_idx].
   facility_name
   SET log->provider_log[provider_row_idx].status = "FAILED"
   IF (validateprovider(provider_row_idx)=1)
    SET stat = initrec(ensure_request)
    SET stat = initrec(ensure_reply)
    SET ensure_request->action_ind = 0
    SET ensure_request->provider_list[1].prsnl_id = requestin_lookup->provider_list[provider_row_idx]
    .prsnl_id
    SET ensure_request->provider_list[1].location_cd = requestin_lookup->provider_list[
    provider_row_idx].location_cd
    SET ensure_request->provider_list[1].payer_org_id = requestin_lookup->provider_list[
    provider_row_idx].payer_org_id
    SET ensure_request->provider_list[1].health_plan_id = requestin_lookup->provider_list[
    provider_row_idx].health_plan_id
    SET ensure_request->provider_list[1].bill_type_flag = requestin_lookup->provider_list[
    provider_row_idx].bill_type_flag
    SET ensure_request->provider_list[1].participation_status_cd = requestin_lookup->provider_list[
    provider_row_idx].participation_status_cd
    SET ensure_request->provider_list[1].process_beg_effective_dt_tm = cnvtdatetime(build(requestin->
      list_0[provider_row_idx].process_start_dt," 00:00:00"))
    SET ensure_request->provider_list[1].process_end_effective_dt_tm = cnvtdatetime(build(requestin->
      list_0[provider_row_idx].process_end_dt," 00:00:00"))
    SET ensure_request->provider_list[1].paperwork_submitted_dt_tm = cnvtdatetime(build(requestin->
      list_0[provider_row_idx].paperwork_submitted_dt," 00:00:00"))
    SET ensure_request->provider_list[1].paperwork_acknowledged_dt_tm = cnvtdatetime(build(requestin
      ->list_0[provider_row_idx].paperwork_acknowledged_dt," 00:00:00"))
    SET ensure_request->provider_list[1].beg_effective_dt_tm = cnvtdatetime(build(requestin->list_0[
      provider_row_idx].effective_start_dt," 00:00:00"))
    IF (textlen(trim(requestin->list_0[provider_row_idx].effective_end_dt)) > 0)
     SET ensure_request->provider_list[1].end_effective_dt_tm = cnvtdatetime(build(requestin->list_0[
       provider_row_idx].effective_end_dt," 23:59:59"))
    ENDIF
    SET ensure_request->provider_list[1].comments = trim(requestin->list_0[provider_row_idx].comment)
    IF (write_mode)
     EXECUTE bed_ens_provider_enrollment  WITH replace("REQUEST",ensure_request), replace("REPLY",
      ensure_reply)
     IF ((ensure_reply->status_data.status="S"))
      SET success_cnt = (success_cnt+ 1)
      SET log->provider_log[provider_row_idx].status = "SUCCESS"
      SET log->provider_log[provider_row_idx].error = "Import successful"
     ELSEIF ((ensure_reply->status_data.status="Z"))
      SET log->provider_log[provider_row_idx].error =
      "Duplicate enrollment for effective date range."
     ELSE
      SET log->provider_log[provider_row_idx].error = concat(log->provider_log[provider_row_idx].
       error," >>",trim(ensure_reply->status_data.subeventstatus[1].operationname)," >>",trim(
        ensure_reply->status_data.subeventstatus[1].operationstatus),
       " >>",trim(ensure_reply->status_data.subeventstatus[1].targetobjectname)," >>",trim(
        ensure_reply->status_data.subeventstatus[1].targetobjectvalue))
     ENDIF
    ELSE
     SET success_cnt = (success_cnt+ 1)
     SET log->provider_log[provider_row_idx].status = "SUCCESS"
     SET log->provider_log[provider_row_idx].error = "Import successful"
    ENDIF
   ENDIF
 ENDFOR
 CALL writetolog(log_file_path,num_provider_rows)
 IF (success_cnt=num_provider_rows)
  SET failure_flag = "N"
 ELSE
  SET failure_cnt = (num_provider_rows - success_cnt)
  SET error_msg = concat(error_msg,"  >> FAILED IMPORTS:",build(failure_cnt))
 ENDIF
#exit_script
 IF (failure_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_PROVIDER_ENROLLMENTS","  >> ERROR MSG: ",
   error_msg)
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "PROVIDER_ENROLLMENT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  SET reqinfo->commit_ind = 0
 ENDIF
 SUBROUTINE logstart(logtitle,logfile)
  SET logvar = 0
  SELECT INTO value(logfile)
   logvar
   HEAD REPORT
    begin_dt_tm"dd-mmm-yyyy;;d", "-", begin_dt_tm"hh:mm:ss;;m",
    col + 1, logtitle, row + 1
    IF (write_mode=0)
     col 30, "AUDIT MODE: NO CHANGES HAVE BEEN MADE TO THE DATABASE"
    ELSE
     col 30, "COMMIT MODE: CHANGES HAVE BEEN MADE TO THE DATABASE"
    ENDIF
   DETAIL
    row + 2, col 2, "ROW",
    col 10, "PROVIDER", col 50,
    "FACILITY", col 90, "STATUS",
    col 100, "ERROR"
   WITH nocounter, format = variable, noformfeed,
    maxcol = 150, maxrow = 1
  ;end select
 END ;Subroutine
 SUBROUTINE setprsnlid(providercount)
   DECLARE providerindex = i4 WITH protect, noconstant(0)
   DECLARE listindex = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM prsnl_alias pa,
     prsnl p
    PLAN (pa
     WHERE expand(listindex,1,providercount,pa.alias,requestin->list_0[listindex].npi_alias)
      AND pa.prsnl_alias_type_cd=npi_alias_type_cd
      AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND pa.active_ind=1)
     JOIN (p
     WHERE p.person_id=pa.person_id
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND p.active_ind=1)
    ORDER BY pa.alias, p.logical_domain_id
    HEAD pa.alias
     person_name_count = 0
    HEAD p.logical_domain_id
     person_name_count = 0
    DETAIL
     person_name_count = (person_name_count+ 1)
    FOOT  p.logical_domain_id
     IF (textlen(pa.alias) > 0
      AND person_name_count=1)
      providerindex = locateval(listindex,1,providercount,pa.alias,requestin->list_0[listindex].
       npi_alias,
       p.name_last_key,cnvtupper(cnvtalphanum(requestin->list_0[listindex].last_name)),p
       .name_first_key,cnvtupper(cnvtalphanum(requestin->list_0[listindex].first_name)),p
       .logical_domain_id,
       cnvtreal(requestin->list_0[listindex].logical_domain_id))
      WHILE (providerindex != 0)
       requestin_lookup->provider_list[providerindex].prsnl_id = p.person_id,providerindex =
       locateval(listindex,(providerindex+ 1),providercount,pa.alias,requestin->list_0[listindex].
        npi_alias,
        p.name_last_key,cnvtupper(cnvtalphanum(requestin->list_0[listindex].last_name)),p
        .name_first_key,cnvtupper(cnvtalphanum(requestin->list_0[listindex].first_name)),p
        .logical_domain_id,
        cnvtreal(requestin->list_0[listindex].logical_domain_id))
      ENDWHILE
     ENDIF
    FOOT  pa.alias
     row + 0
    WITH nocounter, expand = 1
   ;end select
 END ;Subroutine
 SUBROUTINE setlocationcd(providercount)
   DECLARE providerindex = i4 WITH protect, noconstant(0)
   DECLARE listindex = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM code_value cv,
     location l
    PLAN (cv
     WHERE expand(listindex,1,providercount,cv.display_key,cnvtalphanum(cnvtupper(requestin->list_0[
        listindex].facility_name)))
      AND cv.code_set=220
      AND cv.cdf_meaning="FACILITY"
      AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND cv.active_ind=1)
     JOIN (l
     WHERE l.location_cd=cv.code_value
      AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND l.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND l.active_ind=1)
    ORDER BY cv.display_key
    HEAD cv.display_key
     location_name_count = 0
    DETAIL
     location_name_count = (location_name_count+ 1)
    FOOT  cv.display_key
     IF (textlen(cv.display_key) > 0
      AND location_name_count=1)
      providerindex = locateval(listindex,1,providercount,cv.display_key,cnvtalphanum(cnvtupper(
         requestin->list_0[listindex].facility_name)))
      WHILE (providerindex != 0)
       requestin_lookup->provider_list[providerindex].location_cd = l.location_cd,providerindex =
       locateval(listindex,(providerindex+ 1),providercount,cv.display_key,cnvtalphanum(cnvtupper(
          requestin->list_0[listindex].facility_name)))
      ENDWHILE
     ENDIF
    WITH nocounter, expand = 1
   ;end select
 END ;Subroutine
 SUBROUTINE setpayerordid(providercount)
   DECLARE providerindex = i4 WITH protect, noconstant(0)
   DECLARE listindex = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM organization o
    WHERE expand(listindex,1,providercount,o.org_name_key,cnvtalphanum(cnvtupper(requestin->list_0[
       listindex].payer_org_name)),
     o.logical_domain_id,cnvtreal(requestin->list_0[listindex].logical_domain_id))
     AND o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND o.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND o.active_ind=1
    ORDER BY o.org_name_key
    HEAD o.org_name_key
     org_name_count = 0
    DETAIL
     org_name_count = (org_name_count+ 1)
    FOOT  o.org_name_key
     IF (textlen(o.org_name_key) > 0
      AND org_name_count=1)
      providerindex = locateval(listindex,1,providercount,o.org_name_key,cnvtalphanum(cnvtupper(
         requestin->list_0[listindex].payer_org_name)))
      WHILE (providerindex != 0)
       requestin_lookup->provider_list[providerindex].payer_org_id = o.organization_id,providerindex
        = locateval(listindex,(providerindex+ 1),providercount,o.org_name_key,cnvtalphanum(cnvtupper(
          requestin->list_0[listindex].payer_org_name)))
      ENDWHILE
     ENDIF
    WITH nocounter, expand = 1
   ;end select
 END ;Subroutine
 SUBROUTINE sethealthplanid(providercount)
   DECLARE providerindex = i4 WITH protect, noconstant(0)
   DECLARE listindex = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM health_plan hp
    WHERE expand(listindex,1,providercount,hp.plan_name_key,cnvtalphanum(cnvtupper(requestin->list_0[
       listindex].health_plan_name)),
     hp.logical_domain_id,cnvtreal(requestin->list_0[listindex].logical_domain_id))
     AND hp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND hp.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND hp.active_ind=1
    ORDER BY hp.plan_name_key
    HEAD hp.plan_name_key
     plan_name_count = 0
    DETAIL
     plan_name_count = (plan_name_count+ 1)
    FOOT  hp.plan_name_key
     IF (textlen(hp.plan_name_key) > 0
      AND plan_name_count=1)
      providerindex = locateval(listindex,1,providercount,hp.plan_name_key,cnvtalphanum(cnvtupper(
         requestin->list_0[listindex].health_plan_name)))
      WHILE (providerindex != 0)
       requestin_lookup->provider_list[providerindex].health_plan_id = hp.health_plan_id,
       providerindex = locateval(listindex,(providerindex+ 1),providercount,hp.plan_name_key,
        cnvtalphanum(cnvtupper(requestin->list_0[listindex].health_plan_name)))
      ENDWHILE
     ENDIF
    WITH nocounter, expand = 1
   ;end select
 END ;Subroutine
 SUBROUTINE setholdclaimtype(providercount)
  DECLARE providerindex = i4 WITH protect, noconstant(0)
  SELECT INTO "nl:"
   FROM dm_flags dm
   WHERE dm.table_name="PROVIDER_ENROLLMENT"
    AND dm.column_name="BILL_TYPE_FLAG"
   DETAIL
    FOR (providerindex = 1 TO providercount)
      IF (cnvtupper(cnvtalphanum(requestin->list_0[providerindex].hold_claims_type))=cnvtupper(
       cnvtalphanum(dm.definition)))
       requestin_lookup->provider_list[providerindex].bill_type_found_ind = 1, requestin_lookup->
       provider_list[providerindex].bill_type_flag = dm.flag_value
      ENDIF
    ENDFOR
    IF (dm.flag_value=0)
     FOR (providerindex = 1 TO providercount)
       IF (textlen(trim(requestin->list_0[providerindex].hold_claims_type))=0)
        requestin_lookup->provider_list[providerindex].bill_type_found_ind = 1, requestin_lookup->
        provider_list[providerindex].bill_type_flag = dm.flag_value
       ENDIF
     ENDFOR
    ENDIF
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE setparticipationstatuscd(providercount)
  DECLARE providerindex = i4 WITH protect, noconstant(0)
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=4312005
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND cv.active_ind=1
   DETAIL
    IF (textlen(cv.display_key) > 0)
     FOR (providerindex = 1 TO providercount)
       IF (cnvtupper(cnvtalphanum(requestin->list_0[providerindex].processing_status))=cv.display_key
       )
        requestin_lookup->provider_list[providerindex].participation_status_cd = cv.code_value
       ENDIF
     ENDFOR
     IF (cv.cdf_meaning="PROINPROGRES")
      FOR (providerindex = 1 TO providercount)
        IF (textlen(trim(requestin->list_0[providerindex].processing_status))=0)
         requestin_lookup->provider_list[providerindex].participation_status_cd = cv.code_value
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE validateprovider(providerindex)
  IF (textlen(trim(requestin->list_0[providerindex].logical_domain_id)) > 0
   AND  NOT (isnumeric(requestin->list_0[providerindex].logical_domain_id)))
   SET log->provider_log[providerindex].error = "Invalid logical domain."
  ELSEIF ((requestin_lookup->provider_list[providerindex].prsnl_id=0.0))
   SET log->provider_log[providerindex].error = "Invalid or indistinguishable provider."
  ELSEIF ((requestin_lookup->provider_list[providerindex].location_cd=0.0))
   SET log->provider_log[providerindex].error = "Invalid or indistinguishable facility."
  ELSEIF ((requestin_lookup->provider_list[providerindex].payer_org_id=0.0))
   SET log->provider_log[providerindex].error = "Invalid or indistinguishable payer organization."
  ELSEIF ((requestin_lookup->provider_list[providerindex].bill_type_found_ind=0))
   SET log->provider_log[providerindex].error = "Invalid hold claims type."
  ELSEIF ((requestin_lookup->provider_list[providerindex].participation_status_cd=0.0))
   SET log->provider_log[providerindex].error = "Invalid processing status."
  ELSEIF (textlen(trim(requestin->list_0[providerindex].health_plan_name)) > 0
   AND (requestin_lookup->provider_list[providerindex].health_plan_id=0.0))
   SET log->provider_log[providerindex].error = "Invalid or indistinguishable health plan."
  ELSEIF (validatebeginandenddates(requestin->list_0[providerindex].process_start_dt,requestin->
   list_0[providerindex].process_end_dt,1)=0)
   SET log->provider_log[providerindex].error = "Invalid processing dates."
  ELSEIF (validatebeginandenddates(requestin->list_0[providerindex].paperwork_submitted_dt,requestin
   ->list_0[providerindex].paperwork_acknowledged_dt,1)=0)
   SET log->provider_log[providerindex].error = "Invalid paperwork dates."
  ELSEIF (validatebeginandenddates(requestin->list_0[providerindex].effective_start_dt,requestin->
   list_0[providerindex].effective_end_dt,0)=0)
   SET log->provider_log[providerindex].error = "Invalid effective dates."
  ELSE
   RETURN(1)
  ENDIF
  RETURN(0)
 END ;Subroutine
 SUBROUTINE validatebeginandenddates(begindate,enddate,allowemptyenddateind)
   DECLARE beforedate = dq8 WITH protect, constant(cnvtdatetime(build(begindate," 00:00:00")))
   DECLARE afterdate = dq8 WITH protect, constant(cnvtdatetime(build(enddate," 00:00:00")))
   IF (((beforedate=0.0
    AND textlen(trim(begindate)) > 0) OR (afterdate=0.0
    AND textlen(trim(enddate)) > 0)) )
    RETURN(0)
   ELSE
    IF (beforedate=0.0
     AND afterdate != 0.0)
     RETURN(0)
    ELSEIF (allowemptyenddateind=0
     AND afterdate=0.0
     AND beforedate != 0.0)
     RETURN(0)
    ELSEIF (beforedate > afterdate
     AND afterdate != 0.0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE writetolog(logfile,providercount)
   SELECT INTO value(logfile)
    FROM (dummyt d  WITH seq = value(providercount))
    DETAIL
     col 2, "---------------------", row + 1,
     col 1, d.seq"#####", col 10,
     log->provider_log[d.seq].prsnl_name, col 50, log->provider_log[d.seq].facility_name,
     col 90, log->provider_log[d.seq].status, col 100,
     log->provider_log[d.seq].error, row + 1
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 150
   ;end select
 END ;Subroutine
END GO
