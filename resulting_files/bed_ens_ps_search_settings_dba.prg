CREATE PROGRAM bed_ens_ps_search_settings:dba
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 error_msg = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE determinestyleflag(application_number=i4,task_number=i4) = null
 IF ( NOT (validate(flags_for_application_rec,0)))
  RECORD flags_for_application_rec(
    1 flag_to_use_for_reads = i4
    1 qual[*]
      2 style_flag = i4
  )
 ENDIF
 SUBROUTINE determinestyleflag(application_number,task_number)
   DECLARE unique_style_flags_cnt = i2 WITH protect, noconstant(0)
   DECLARE person_search_style_flag_cnt = i2 WITH protect, noconstant(0)
   DECLARE search_index = i4 WITH protect, noconstant(0)
   DECLARE has_style_flag = i4 WITH protect, noconstant(0)
   DECLARE max_cnt = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   CALL echo("before select in subroutine")
   CALL echorecord(flags_for_application_rec)
   CALL echo(build("application_number:",application_number))
   CALL echo(build("task_number:",task_number))
   SELECT INTO "nl:"
    FROM pm_sch_setup p
    WHERE p.application_number=application_number
     AND p.task_number=task_number
    ORDER BY p.style_flag
    HEAD p.style_flag
     CALL echo("in head"), unique_style_flags_cnt = (unique_style_flags_cnt+ 1), stat = alterlist(
      flags_for_application_rec->qual,unique_style_flags_cnt),
     flags_for_application_rec->qual[unique_style_flags_cnt].style_flag = p.style_flag
    WITH nocounter
   ;end select
   CALL bederrorcheck(
    "Error 001: Failed to read from pm_sch_setup table at the application/position/user level")
   IF (size(flags_for_application_rec->qual,5)=1)
    SET flags_for_application_rec->flag_to_use_for_reads = flags_for_application_rec->qual[1].
    style_flag
   ENDIF
   CALL echorecord(flags_for_application_rec)
   IF (size(flags_for_application_rec->qual,5) > 1)
    SELECT INTO "nl:"
     FROM pm_sch_setup p
     WHERE p.application_number=application_number
      AND p.task_number=task_number
      AND p.person_id > 0
     ORDER BY p.updt_dt_tm DESC
     DETAIL
      IF ((flags_for_application_rec->flag_to_use_for_reads=0))
       flags_for_application_rec->flag_to_use_for_reads = p.style_flag
      ENDIF
      has_style_flag = locateval(search_index,1,size(flags_for_application_rec->qual,5),p.style_flag,
       flags_for_application_rec->qual[search_index].style_flag)
      IF (has_style_flag=0)
       unique_style_flags_cnt = (unique_style_flags_cnt+ 1), stat = alterlist(
        flags_for_application_rec->qual,unique_style_flags_cnt), flags_for_application_rec->qual[
       unique_style_flags_cnt].style_flag = p.style_flag
      ENDIF
     WITH maxqual(p,1)
    ;end select
    CALL bederrorcheck("Error 002: Failed to read from pm_sch_setup table at the user level")
   ENDIF
   CALL echorecord(flags_for_application_rec)
   IF (task_number > 0)
    DECLARE conv_action = i4 WITH protect, noconstant(0)
    DECLARE flag_from_br_value = i4 WITH protect, noconstant(0)
    SELECT INTO "nl:"
     FROM pm_flx_conversation p
     PLAN (p
      WHERE p.task=task_number)
     DETAIL
      conv_action = p.action
     WITH nocounter
    ;end select
    CALL bederrorcheck("Error 003: Failed to read from pm_flx_conversation table")
    SELECT INTO "nl:"
     FROM br_name_value b
     PLAN (b
      WHERE b.br_nv_key1="PERSON_SEARCH_CONVERSATION_FLAG"
       AND b.br_name=cnvtstring(conv_action))
     DETAIL
      flag_from_br_value = cnvtint(trim(b.br_value))
      IF ((flags_for_application_rec->flag_to_use_for_reads=0))
       flags_for_application_rec->flag_to_use_for_reads = flag_from_br_value
      ENDIF
      search_index = 0, has_style_flag = locateval(search_index,1,size(flags_for_application_rec->
        qual,5),flag_from_br_value,flags_for_application_rec->qual[search_index].style_flag)
      IF (has_style_flag=0)
       unique_style_flags_cnt = (unique_style_flags_cnt+ 1), stat = alterlist(
        flags_for_application_rec->qual,unique_style_flags_cnt), flags_for_application_rec->qual[
       unique_style_flags_cnt].style_flag = flag_from_br_value
      ENDIF
     WITH nocounter
    ;end select
    CALL bederrorcheck("Error 004: Failed to read from br_name_value table at the CONVERSATION level"
     )
   ELSEIF (task_number=0)
    SELECT INTO "nl:"
     FROM br_name_value b
     PLAN (b
      WHERE b.br_nv_key1="PERSON_SEARCH_APPLICATION_FLAG"
       AND b.br_name=cnvtstring(application_number))
     DETAIL
      flag_from_br_value = cnvtint(trim(b.br_value))
      IF ((flags_for_application_rec->flag_to_use_for_reads=0))
       flags_for_application_rec->flag_to_use_for_reads = flag_from_br_value
      ENDIF
      search_index = 0, has_style_flag = locateval(search_index,1,size(flags_for_application_rec->
        qual,5),flag_from_br_value,flags_for_application_rec->qual[search_index].style_flag)
      IF (has_style_flag=0)
       unique_style_flags_cnt = (unique_style_flags_cnt+ 1), stat = alterlist(
        flags_for_application_rec->qual,unique_style_flags_cnt), flags_for_application_rec->qual[
       unique_style_flags_cnt].style_flag = flag_from_br_value
      ENDIF
     WITH nocounter
    ;end select
    CALL bederrorcheck("Error 005: Failed to read from br_name_value table at the SOLUTION level")
   ENDIF
   CALL echorecord(flags_for_application_rec)
 END ;Subroutine
 IF ( NOT (validate(error_flag)))
  DECLARE error_flag = vc WITH protect, noconstant("N")
 ENDIF
 IF ( NOT (validate(ierrcode)))
  DECLARE ierrcode = i4 WITH protect, noconstant(0)
 ENDIF
 IF ( NOT (validate(serrmsg)))
  DECLARE serrmsg = vc WITH protect, noconstant("")
 ENDIF
 IF ( NOT (validate(discerncurrentversion)))
  DECLARE discerncurrentversion = i4 WITH constant(cnvtint(build(format(currev,"##;P0"),format(
      currevminor,"##;P0"),format(currevminor2,"##;P0"))))
 ENDIF
 IF (validate(bedbeginscript,char(128))=char(128))
  DECLARE bedbeginscript(dummyvar=i2) = null
  SUBROUTINE bedbeginscript(dummyvar)
    SET reply->status_data.status = "F"
    SET serrmsg = fillstring(132," ")
    SET ierrcode = error(serrmsg,1)
    SET error_flag = "N"
  END ;Subroutine
 ENDIF
 IF (validate(bederror,char(128))=char(128))
  DECLARE bederror(errordescription=vc) = null
  SUBROUTINE bederror(errordescription)
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
    GO TO exit_script
  END ;Subroutine
 ENDIF
 IF (validate(bedexitsuccess,char(128))=char(128))
  DECLARE bedexitsuccess(dummyvar=i2) = null
  SUBROUTINE bedexitsuccess(dummyvar)
   SET error_flag = "N"
   GO TO exit_script
  END ;Subroutine
 ENDIF
 IF (validate(bederrorcheck,char(128))=char(128))
  DECLARE bederrorcheck(errordescription=vc) = null
  SUBROUTINE bederrorcheck(errordescription)
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    CALL bederror(errordescription)
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(bedexitscript,char(128))=char(128))
  DECLARE bedexitscript(commitind=i2) = null
  SUBROUTINE bedexitscript(commitind)
   CALL bederrorcheck("Descriptive error message not provided.")
   IF (error_flag="N")
    SET reply->status_data.status = "S"
    IF (commitind)
     SET reqinfo->commit_ind = 1
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    IF (commitind)
     SET reqinfo->commit_ind = 0
    ENDIF
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(bedlogmessage,char(128))=char(128))
  DECLARE bedlogmessage(subroutinename=vc,message=vc) = null
  SUBROUTINE bedlogmessage(subroutinename,message)
    CALL echo("==================================================================")
    CALL echo(build2(curprog," : ",subroutinename,"() :",message))
    CALL echo("==================================================================")
  END ;Subroutine
 ENDIF
 IF (validate(bedgetlogicaldomain,char(128))=char(128))
  DECLARE bedgetlogicaldomain(dummyvar=i2) = f8
  SUBROUTINE bedgetlogicaldomain(dummyvar)
    DECLARE logicaldomainid = f8 WITH protect, noconstant(0)
    IF (validate(ld_concept_person)=0)
     DECLARE ld_concept_person = i2 WITH public, constant(1)
    ENDIF
    IF (validate(ld_concept_prsnl)=0)
     DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
    ENDIF
    IF (validate(ld_concept_organization)=0)
     DECLARE ld_concept_organization = i2 WITH public, constant(3)
    ENDIF
    IF (validate(ld_concept_healthplan)=0)
     DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
    ENDIF
    IF (validate(ld_concept_alias_pool)=0)
     DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
    ENDIF
    IF (validate(ld_concept_minvalue)=0)
     DECLARE ld_concept_minvalue = i2 WITH public, constant(1)
    ENDIF
    IF (validate(ld_concept_maxvalue)=0)
     DECLARE ld_concept_maxvalue = i2 WITH public, constant(5)
    ENDIF
    RECORD acm_get_curr_logical_domain_req(
      1 concept = i4
    )
    RECORD acm_get_curr_logical_domain_rep(
      1 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    SET acm_get_curr_logical_domain_req->concept = ld_concept_prsnl
    EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
    replace("REPLY",acm_get_curr_logical_domain_rep)
    SET logicaldomainid = acm_get_curr_logical_domain_rep->logical_domain_id
    RETURN(logicaldomainid)
  END ;Subroutine
 ENDIF
 SUBROUTINE logdebugmessage(message_header,message)
  IF (validate(debug,0)=1)
   CALL bedlogmessage(message_header,message)
  ENDIF
  RETURN(true)
 END ;Subroutine
 IF (validate(bedgetexpandind,char(128))=char(128))
  DECLARE bedgetexpandind(_reccnt=i4(value),_bindcnt=i4(value,200)) = i2
  SUBROUTINE bedgetexpandind(_reccnt,_bindcnt)
    DECLARE nexpandval = i4 WITH noconstant(1)
    IF (discerncurrentversion >= 81002)
     SET nexpandval = 2
    ENDIF
    RETURN(evaluate(floor(((_reccnt - 1)/ _bindcnt)),0,0,nexpandval))
  END ;Subroutine
 ENDIF
 IF (validate(getfeaturetoggle,char(128))=char(128))
  DECLARE getfeaturetoggle(pfeaturetogglekey=vc,psystemidentifier=vc) = i2
  SUBROUTINE getfeaturetoggle(pfeaturetogglekey,psystemidentifier)
    DECLARE isfeatureenabled = i2 WITH noconstant(false)
    DECLARE syscheckfeaturetoggleexistind = i4 WITH noconstant(0)
    DECLARE pftgetdminfoexistind = i4 WITH noconstant(0)
    SET syscheckfeaturetoggleexistind = checkprg("SYS_CHECK_FEATURE_TOGGLE")
    SET pftgetdminfoexistind = checkprg("PFT_GET_DM_INFO")
    IF (syscheckfeaturetoggleexistind > 0
     AND pftgetdminfoexistind > 0)
     RECORD featuretogglerequest(
       1 togglename = vc
       1 username = vc
       1 positioncd = f8
       1 systemidentifier = vc
       1 solutionname = vc
     ) WITH protect
     RECORD featuretogglereply(
       1 togglename = vc
       1 isenabled = i2
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
     ) WITH protect
     SET featuretogglerequest->togglename = pfeaturetogglekey
     SET featuretogglerequest->systemidentifier = psystemidentifier
     EXECUTE sys_check_feature_toggle  WITH replace("REQUEST",featuretogglerequest), replace("REPLY",
      featuretogglereply)
     IF (validate(debug,false))
      CALL echorecord(featuretogglerequest)
      CALL echorecord(featuretogglereply)
     ENDIF
     IF ((featuretogglereply->status_data.status="S"))
      SET isfeatureenabled = featuretogglereply->isenabled
      CALL logdebugmessage("getFeatureToggle",build("Feature Toggle for Key - ",pfeaturetogglekey,
        " : ",isfeatureenabled))
     ELSE
      CALL logdebugmessage("getFeatureToggle","Call to sys_check_feature_toggle failed")
     ENDIF
    ELSE
     CALL logdebugmessage("getFeatureToggle",build2("sys_check_feature_toggle.prg and / or ",
       " pft_get_dm_info.prg do not exist in domain.",
       " Contact Patient Accounting Team for assistance."))
    ENDIF
    RETURN(isfeatureenabled)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(isfeaturetoggleenabled)))
  DECLARE isfeaturetoggleenabled(pparentfeaturekey=vc,pchildfeaturekey=vc,psystemidentifier=vc) = i2
  SUBROUTINE isfeaturetoggleenabled(pparentfeaturekey,pchildfeaturekey,psystemidentifier)
    DECLARE isparentfeatureenabled = i2 WITH noconstant(false)
    DECLARE ischildfeatureenabled = i2 WITH noconstant(false)
    SET isparentfeatureenabled = getfeaturetoggle(pparentfeaturekey,psystemidentifier)
    IF (isparentfeatureenabled)
     SET ischildfeatureenabled = getfeaturetoggle(pchildfeaturekey,psystemidentifier)
    ENDIF
    CALL logdebugmessage("isFeatureToggleEnabled",build2(" Parent Feature Toggle - ",
      pparentfeaturekey," value is = ",isparentfeatureenabled," and Child Feature Toggle - ",
      pchildfeaturekey," value is = ",ischildfeatureenabled))
    RETURN(ischildfeatureenabled)
  END ;Subroutine
 ENDIF
 CALL determinestyleflag(request->application_number,request->task_number)
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET name = fillstring(1," ")
 SET reltn = fillstring(1," ")
 SET combine = fillstring(1," ")
 IF ((request->name_search_ind=1))
  SET name = "1"
 ELSE
  SET name = "0"
 ENDIF
 IF ((request->relationship_ind=1))
  SET reltn = "1"
 ELSE
  SET reltn = "0"
 ENDIF
 IF (validate(request->launch_combine_ind))
  IF ((request->launch_combine_ind=1))
   SET combine = "1"
  ELSE
   SET combine = "0"
  ENDIF
 ELSE
  SET combine = "0"
 ENDIF
 IF (validate(request->mpi_ind))
  SET options = fillstring(14," ")
  SET options = concat(name,combine,"0",reltn,"000",
   trim(cnvtstring(request->mpi_ind)),trim(cnvtstring(request->mpi_auto_ind)),trim(cnvtstring(request
     ->mpi_phonetic_ind)),trim(cnvtstring(request->mpi_wildcard_ind)),trim(cnvtstring(request->
     mpi_always_allow_ind)),
   "0",trim(cnvtstring(request->search_quality_ind)))
 ELSE
  SET options = fillstring(7," ")
  SET options = concat(name,combine,"0",reltn,"000")
 ENDIF
 SET global_lock = 0
 SET pos_lock = 0
 IF (validate(request->lock_type_flag))
  IF ((request->lock_type_flag=1))
   SET pos_lock = 1
   SET global_lock = 0
  ELSEIF ((request->lock_type_flag=2))
   SET pos_lock = 1
   SET global_lock = 1
  ELSE
   SET pos_loc = 0
   SET global_loc = 0
  ENDIF
 ELSE
  SET pos_lock = 1
  SET global_lock = 0
 ENDIF
 SET filter_cnt = 0
 RECORD filters(
   1 qual[*]
     2 data_type_flag = i2
     2 sequence = i4
     2 display = vc
     2 meaning = vc
     2 required_ind = i2
     2 name = vc
     2 value = f8
     2 load_ind = i2
 )
 SET fcnt = size(request->filters,5)
 IF (fcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(fcnt)),
    br_person_search_settings b
   PLAN (d)
    JOIN (b
    WHERE b.setting_mean="SEARCH_FILTERS"
     AND (b.description=request->filters[d.seq].name))
   ORDER BY request->filters[d.seq].sequence
   DETAIL
    filter_cnt = (filter_cnt+ 1), stat = alterlist(filters->qual,filter_cnt), filters->qual[
    filter_cnt].data_type_flag = b.data_type_flag,
    filters->qual[filter_cnt].sequence = filter_cnt, filters->qual[filter_cnt].name = request->
    filters[d.seq].name, filters->qual[filter_cnt].value = - (1)
    IF ((b.description != request->filters[d.seq].display))
     filters->qual[filter_cnt].display = request->filters[d.seq].display
    ENDIF
    IF (b.meaning > " ")
     filters->qual[filter_cnt].meaning = b.meaning
    ENDIF
    filters->qual[filter_cnt].required_ind = request->filters[d.seq].required_ind
   WITH nocounter
  ;end select
 ENDIF
 SET def_filter_cnt = 0
 RECORD default_filters(
   1 qual[*]
     2 data_type_flag = i2
     2 sequence = i4
     2 meaning = vc
     2 name = vc
     2 value = f8
 )
 SET dfcnt = 0
 IF (validate(request->default_filters))
  SET dfcnt = size(request->default_filters,5)
 ENDIF
 IF (dfcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(dfcnt)),
    br_person_search_settings b
   PLAN (d)
    JOIN (b
    WHERE b.setting_mean="DEFAULT_FILTERS"
     AND (b.description=request->default_filters[d.seq].name))
   ORDER BY request->default_filters[d.seq].name
   DETAIL
    def_filter_cnt = (def_filter_cnt+ 1), stat = alterlist(default_filters->qual,def_filter_cnt),
    default_filters->qual[def_filter_cnt].data_type_flag = b.data_type_flag,
    default_filters->qual[def_filter_cnt].name = request->default_filters[d.seq].name
    IF (b.meaning > " ")
     default_filters->qual[def_filter_cnt].meaning = b.meaning
    ENDIF
    default_filters->qual[def_filter_cnt].value = request->default_filters[d.seq].value
   WITH nocounter
  ;end select
 ENDIF
 SET all_fltr_cnt = 0
 RECORD all_filters(
   1 qual[*]
     2 data_type_flag = i2
     2 sequence = i4
     2 meaning = vc
     2 display = vc
     2 required_ind = i2
     2 hidden_ind = i2
     2 value = vc
 )
 IF (filter_cnt > 0
  AND def_filter_cnt > 0)
  FOR (d = 1 TO def_filter_cnt)
    SET f = 0
    SET tindex = 0
    SET tindex = locateval(f,1,filter_cnt,default_filters->qual[d].name,filters->qual[f].name)
    IF (tindex=0)
     SET all_fltr_cnt = (all_fltr_cnt+ 1)
     SET stat = alterlist(all_filters->qual,all_fltr_cnt)
     SET all_filters->qual[all_fltr_cnt].data_type_flag = default_filters->qual[d].data_type_flag
     SET all_filters->qual[all_fltr_cnt].sequence = all_fltr_cnt
     SET all_filters->qual[all_fltr_cnt].display = " "
     SET all_filters->qual[all_fltr_cnt].meaning = default_filters->qual[d].meaning
     SET all_filters->qual[all_fltr_cnt].hidden_ind = 1
     SET all_filters->qual[all_fltr_cnt].value = cnvtstring(default_filters->qual[d].value)
    ENDIF
  ENDFOR
  FOR (f = 1 TO filter_cnt)
    SET d = 0
    SET tindex = 0
    SET tindex = locateval(d,1,def_filter_cnt,filters->qual[f].name,default_filters->qual[d].name)
    CALL echo(build("TINDEX: ",tindex))
    CALL echo(build("NAME: ",filters->qual[f].name))
    IF (tindex > 0)
     SET filters->qual[f].load_ind = 1
     SET filters->qual[f].value = default_filters->qual[tindex].value
    ENDIF
  ENDFOR
  SET all_fltr_cnt = size(all_filters->qual,5)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(filter_cnt))
   PLAN (d)
   ORDER BY filters->qual[d.seq].sequence
   DETAIL
    all_fltr_cnt = (all_fltr_cnt+ 1), stat = alterlist(all_filters->qual,all_fltr_cnt), all_filters->
    qual[all_fltr_cnt].data_type_flag = filters->qual[d.seq].data_type_flag,
    all_filters->qual[all_fltr_cnt].sequence = all_fltr_cnt, all_filters->qual[all_fltr_cnt].display
     = filters->qual[d.seq].display, all_filters->qual[all_fltr_cnt].meaning = filters->qual[d.seq].
    meaning,
    all_filters->qual[all_fltr_cnt].hidden_ind = 0, all_filters->qual[all_fltr_cnt].required_ind =
    filters->qual[d.seq].required_ind
    IF ((filters->qual[d.seq].value >= 0))
     all_filters->qual[all_fltr_cnt].value = cnvtstring(filters->qual[d.seq].value)
    ELSE
     all_filters->qual[all_fltr_cnt].value = ""
    ENDIF
   WITH nocounter
  ;end select
 ELSEIF (filter_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(filter_cnt))
   PLAN (d)
   ORDER BY filters->qual[d.seq].sequence
   DETAIL
    all_fltr_cnt = (all_fltr_cnt+ 1), stat = alterlist(all_filters->qual,all_fltr_cnt), all_filters->
    qual[all_fltr_cnt].data_type_flag = filters->qual[d.seq].data_type_flag,
    all_filters->qual[all_fltr_cnt].sequence = all_fltr_cnt, all_filters->qual[all_fltr_cnt].display
     = filters->qual[d.seq].display, all_filters->qual[all_fltr_cnt].meaning = filters->qual[d.seq].
    meaning,
    all_filters->qual[all_fltr_cnt].hidden_ind = 0, all_filters->qual[all_fltr_cnt].required_ind =
    filters->qual[d.seq].required_ind, all_filters->qual[all_fltr_cnt].value = ""
   WITH nocounter
  ;end select
 ENDIF
 SET result_cnt = 0
 RECORD results(
   1 qual[*]
     2 data_type_flag = i2
     2 sequence = i4
     2 display = vc
     2 meaning = vc
 )
 SET pcnt = size(request->person_results,5)
 IF (pcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(pcnt)),
    br_person_search_settings b
   PLAN (d)
    JOIN (b
    WHERE b.setting_mean="PERSON_RESULTS"
     AND (b.description=request->person_results[d.seq].name))
   ORDER BY request->person_results[d.seq].sequence
   DETAIL
    result_cnt = (result_cnt+ 1), stat = alterlist(results->qual,result_cnt), results->qual[
    result_cnt].data_type_flag = b.data_type_flag,
    results->qual[result_cnt].sequence = result_cnt
    IF ((b.description != request->person_results[d.seq].display))
     results->qual[result_cnt].display = request->person_results[d.seq].display
    ENDIF
    IF (b.meaning > " ")
     results->qual[result_cnt].meaning = b.meaning
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET ecnt = size(request->encntr_results,5)
 IF (ecnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(ecnt)),
    br_person_search_settings b
   PLAN (d)
    JOIN (b
    WHERE b.setting_mean="ENCOUNTER_RESULTS"
     AND (b.description=request->encntr_results[d.seq].name))
   ORDER BY request->encntr_results[d.seq].sequence
   DETAIL
    result_cnt = (result_cnt+ 1), stat = alterlist(results->qual,result_cnt), results->qual[
    result_cnt].data_type_flag = b.data_type_flag,
    results->qual[result_cnt].sequence = result_cnt
    IF ((b.description != request->encntr_results[d.seq].display))
     results->qual[result_cnt].display = request->encntr_results[d.seq].display
    ENDIF
    IF (b.meaning > " ")
     results->qual[result_cnt].meaning = b.meaning
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET rcnt = size(request->reltn_results,5)
 IF (rcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(rcnt)),
    br_person_search_settings b
   PLAN (d)
    JOIN (b
    WHERE b.setting_mean="RELTN_RESULTS"
     AND (b.description=request->reltn_results[d.seq].name))
   ORDER BY request->reltn_results[d.seq].sequence
   DETAIL
    result_cnt = (result_cnt+ 1), stat = alterlist(results->qual,result_cnt), results->qual[
    result_cnt].data_type_flag = b.data_type_flag,
    results->qual[result_cnt].sequence = result_cnt
    IF ((b.description != request->reltn_results[d.seq].display))
     results->qual[result_cnt].display = request->reltn_results[d.seq].display
    ENDIF
    IF (b.meaning > " ")
     results->qual[result_cnt].meaning = b.meaning
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 RECORD app(
   1 qual[*]
     2 setup_id = f8
     2 application_number = i4
     2 task_number = i4
     2 position_cd = f8
     2 locked_ind = i2
     2 style_flag = i2
 )
 FREE SET del_temp
 RECORD del_temp(
   1 qual[*]
     2 setup_id = f8
 )
 SET del_temp_cnt = 0
 SET pos_cnt = size(request->positions,5)
 IF ((request->task_number=0))
  SET scnt = 0
  SET acnt = 0
  FOR (y = 1 TO size(flags_for_application_rec->qual,5))
    SELECT INTO "nl:"
     FROM pm_sch_setup p
     WHERE (p.application_number=request->application_number)
      AND p.task_number=0
      AND p.person_id=0
      AND (p.style_flag=flags_for_application_rec->qual[y].style_flag)
     DETAIL
      IF (pos_cnt=0
       AND p.position_cd=0)
       del_temp_cnt = (del_temp_cnt+ 1), stat = alterlist(del_temp->qual,del_temp_cnt), del_temp->
       qual[del_temp_cnt].setup_id = p.setup_id
      ENDIF
      IF (pos_cnt > 0
       AND p.position_cd > 0)
       FOR (z = 1 TO pos_cnt)
         IF ((request->positions[z].code_value=p.position_cd))
          del_temp_cnt = (del_temp_cnt+ 1), stat = alterlist(del_temp->qual,del_temp_cnt), del_temp->
          qual[del_temp_cnt].setup_id = p.setup_id
         ENDIF
       ENDFOR
      ENDIF
     WITH nocounter
    ;end select
    IF (pos_cnt=0)
     SET acnt = (acnt+ 1)
     SET stat = alterlist(app->qual,acnt)
     SET pss_id = 0.0
     SELECT INTO "nl:"
      j = seq(pm_sch_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       pss_id = cnvtreal(j)
      WITH format, counter
     ;end select
     SET app->qual[acnt].setup_id = pss_id
     SET app->qual[acnt].application_number = request->application_number
     SET app->qual[acnt].task_number = 0
     SET app->qual[acnt].position_cd = 0
     SET app->qual[acnt].locked_ind = global_lock
     SET app->qual[acnt].style_flag = flags_for_application_rec->qual[y].style_flag
    ENDIF
    FOR (x = 1 TO pos_cnt)
      SET acnt = (acnt+ 1)
      SET stat = alterlist(app->qual,acnt)
      SET pss_id = 0.0
      SELECT INTO "nl:"
       j = seq(pm_sch_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        pss_id = cnvtreal(j)
       WITH format, counter
      ;end select
      SET app->qual[acnt].setup_id = pss_id
      SET app->qual[acnt].application_number = request->application_number
      SET app->qual[acnt].task_number = 0
      SET app->qual[acnt].position_cd = request->positions[x].code_value
      SET app->qual[acnt].locked_ind = global_lock
      SET app->qual[acnt].style_flag = flags_for_application_rec->qual[y].style_flag
    ENDFOR
  ENDFOR
  IF ((request->application_number=70000))
   SELECT INTO "nl:"
    FROM pm_sch_setup p
    WHERE (p.application_number=request->application_number)
     AND p.task_number=70004
     AND p.person_id=0
     AND p.style_flag=1
    DETAIL
     IF (pos_cnt=0
      AND p.position_cd=0)
      del_temp_cnt = (del_temp_cnt+ 1), stat = alterlist(del_temp->qual,del_temp_cnt), del_temp->
      qual[del_temp_cnt].setup_id = p.setup_id
     ENDIF
     IF (pos_cnt > 0
      AND p.position_cd > 0)
      FOR (z = 1 TO pos_cnt)
        IF ((request->positions[z].code_value=p.position_cd))
         del_temp_cnt = (del_temp_cnt+ 1), stat = alterlist(del_temp->qual,del_temp_cnt), del_temp->
         qual[del_temp_cnt].setup_id = p.setup_id
        ENDIF
      ENDFOR
     ENDIF
    WITH nocounter
   ;end select
   IF (pos_cnt=0)
    SET acnt = (acnt+ 1)
    SET stat = alterlist(app->qual,acnt)
    SET pss_id = 0.0
    SELECT INTO "nl:"
     j = seq(pm_sch_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      pss_id = cnvtreal(j)
     WITH format, counter
    ;end select
    SET app->qual[acnt].setup_id = pss_id
    SET app->qual[acnt].application_number = request->application_number
    SET app->qual[acnt].task_number = 70004
    SET app->qual[acnt].position_cd = 0
    SET app->qual[acnt].locked_ind = global_lock
    SET app->qual[acnt].style_flag = 1
   ENDIF
   FOR (x = 1 TO pos_cnt)
     SET acnt = (acnt+ 1)
     SET stat = alterlist(app->qual,acnt)
     SET pss_id = 0.0
     SELECT INTO "nl:"
      j = seq(pm_sch_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       pss_id = cnvtreal(j)
      WITH format, counter
     ;end select
     SET app->qual[acnt].setup_id = pss_id
     SET app->qual[acnt].application_number = request->application_number
     SET app->qual[acnt].task_number = 70004
     SET app->qual[acnt].position_cd = request->positions[x].code_value
     SET app->qual[acnt].locked_ind = global_lock
     SET app->qual[acnt].style_flag = 1
   ENDFOR
   SELECT INTO "nl:"
    FROM pm_sch_setup p
    WHERE (p.application_number=request->application_number)
     AND p.task_number=70006
     AND p.person_id=0
     AND p.style_flag=3
    DETAIL
     IF (pos_cnt=0
      AND p.position_cd=0)
      del_temp_cnt = (del_temp_cnt+ 1), stat = alterlist(del_temp->qual,del_temp_cnt), del_temp->
      qual[del_temp_cnt].setup_id = p.setup_id
     ENDIF
     IF (pos_cnt > 0
      AND p.position_cd > 0)
      FOR (z = 1 TO pos_cnt)
        IF ((request->positions[z].code_value=p.position_cd))
         del_temp_cnt = (del_temp_cnt+ 1), stat = alterlist(del_temp->qual,del_temp_cnt), del_temp->
         qual[del_temp_cnt].setup_id = p.setup_id
        ENDIF
      ENDFOR
     ENDIF
    WITH nocounter
   ;end select
   IF (pos_cnt=0)
    SET acnt = (acnt+ 1)
    SET stat = alterlist(app->qual,acnt)
    SET pss_id = 0.0
    SELECT INTO "nl:"
     j = seq(pm_sch_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      pss_id = cnvtreal(j)
     WITH format, counter
    ;end select
    SET app->qual[acnt].setup_id = pss_id
    SET app->qual[acnt].application_number = request->application_number
    SET app->qual[acnt].task_number = 70006
    SET app->qual[acnt].position_cd = 0
    SET app->qual[acnt].locked_ind = global_lock
    SET app->qual[acnt].style_flag = 3
   ENDIF
   FOR (x = 1 TO pos_cnt)
     SET acnt = (acnt+ 1)
     SET stat = alterlist(app->qual,acnt)
     SET pss_id = 0.0
     SELECT INTO "nl:"
      j = seq(pm_sch_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       pss_id = cnvtreal(j)
      WITH format, counter
     ;end select
     SET app->qual[acnt].setup_id = pss_id
     SET app->qual[acnt].application_number = request->application_number
     SET app->qual[acnt].task_number = 70006
     SET app->qual[acnt].position_cd = request->positions[x].code_value
     SET app->qual[acnt].locked_ind = global_lock
     SET app->qual[acnt].style_flag = 3
   ENDFOR
   SELECT INTO "nl:"
    FROM pm_sch_setup p
    WHERE (p.application_number=request->application_number)
     AND p.task_number=70008
     AND p.person_id=0
     AND p.style_flag=1
    DETAIL
     IF (pos_cnt=0
      AND p.position_cd=0)
      del_temp_cnt = (del_temp_cnt+ 1), stat = alterlist(del_temp->qual,del_temp_cnt), del_temp->
      qual[del_temp_cnt].setup_id = p.setup_id
     ENDIF
     IF (pos_cnt > 0
      AND p.position_cd > 0)
      FOR (z = 1 TO pos_cnt)
        IF ((request->positions[z].code_value=p.position_cd))
         del_temp_cnt = (del_temp_cnt+ 1), stat = alterlist(del_temp->qual,del_temp_cnt), del_temp->
         qual[del_temp_cnt].setup_id = p.setup_id
        ENDIF
      ENDFOR
     ENDIF
    WITH nocounter
   ;end select
   IF (pos_cnt=0)
    SET acnt = (acnt+ 1)
    SET stat = alterlist(app->qual,acnt)
    SET pss_id = 0.0
    SELECT INTO "nl:"
     j = seq(pm_sch_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      pss_id = cnvtreal(j)
     WITH format, counter
    ;end select
    SET app->qual[acnt].setup_id = pss_id
    SET app->qual[acnt].application_number = request->application_number
    SET app->qual[acnt].task_number = 70008
    SET app->qual[acnt].position_cd = 0
    SET app->qual[acnt].locked_ind = global_lock
    SET app->qual[acnt].style_flag = 1
   ENDIF
   FOR (x = 1 TO pos_cnt)
     SET acnt = (acnt+ 1)
     SET stat = alterlist(app->qual,acnt)
     SET pss_id = 0.0
     SELECT INTO "nl:"
      j = seq(pm_sch_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       pss_id = cnvtreal(j)
      WITH format, counter
     ;end select
     SET app->qual[acnt].setup_id = pss_id
     SET app->qual[acnt].application_number = request->application_number
     SET app->qual[acnt].task_number = 70008
     SET app->qual[acnt].position_cd = request->positions[x].code_value
     SET app->qual[acnt].locked_ind = global_lock
     SET app->qual[acnt].style_flag = 1
   ENDFOR
   SELECT INTO "nl:"
    FROM pm_sch_setup p
    WHERE (p.application_number=request->application_number)
     AND p.task_number=70009
     AND p.person_id=0
     AND p.style_flag=1
    DETAIL
     IF (pos_cnt=0
      AND p.position_cd=0)
      del_temp_cnt = (del_temp_cnt+ 1), stat = alterlist(del_temp->qual,del_temp_cnt), del_temp->
      qual[del_temp_cnt].setup_id = p.setup_id
     ENDIF
     IF (pos_cnt > 0
      AND p.position_cd > 0)
      FOR (z = 1 TO pos_cnt)
        IF ((request->positions[z].code_value=p.position_cd))
         del_temp_cnt = (del_temp_cnt+ 1), stat = alterlist(del_temp->qual,del_temp_cnt), del_temp->
         qual[del_temp_cnt].setup_id = p.setup_id
        ENDIF
      ENDFOR
     ENDIF
    WITH nocounter
   ;end select
   IF (pos_cnt=0)
    SET acnt = (acnt+ 1)
    SET stat = alterlist(app->qual,acnt)
    SET pss_id = 0.0
    SELECT INTO "nl:"
     j = seq(pm_sch_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      pss_id = cnvtreal(j)
     WITH format, counter
    ;end select
    SET app->qual[acnt].setup_id = pss_id
    SET app->qual[acnt].application_number = request->application_number
    SET app->qual[acnt].task_number = 70009
    SET app->qual[acnt].position_cd = 0
    SET app->qual[acnt].locked_ind = global_lock
    SET app->qual[acnt].style_flag = 1
   ENDIF
   FOR (x = 1 TO pos_cnt)
     SET acnt = (acnt+ 1)
     SET stat = alterlist(app->qual,acnt)
     SET pss_id = 0.0
     SELECT INTO "nl:"
      j = seq(pm_sch_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       pss_id = cnvtreal(j)
      WITH format, counter
     ;end select
     SET app->qual[acnt].setup_id = pss_id
     SET app->qual[acnt].application_number = request->application_number
     SET app->qual[acnt].task_number = 70009
     SET app->qual[acnt].position_cd = request->positions[x].code_value
     SET app->qual[acnt].locked_ind = global_lock
     SET app->qual[acnt].style_flag = 1
   ENDFOR
  ENDIF
 ELSEIF ((request->task_number > 0))
  SET conv_action = 0
  SELECT INTO "nl:"
   FROM pm_flx_conversation p
   PLAN (p
    WHERE (p.task=request->task_number))
   DETAIL
    conv_action = p.action
   WITH nocounter
  ;end select
  RECORD temp(
    1 qual[*]
      2 app_number = i4
  )
  SET cnt = 1
  SET stat = alterlist(temp->qual,cnt)
  SET temp->qual[1].app_number = request->application_number
  SET acnt = 0
  FOR (y = 1 TO size(flags_for_application_rec->qual,5))
    SELECT INTO "nl:"
     FROM pm_sch_setup p
     WHERE (p.application_number=request->application_number)
      AND (p.task_number=request->task_number)
      AND p.person_id=0
      AND (p.style_flag=flags_for_application_rec->qual[y].style_flag)
     DETAIL
      IF (pos_cnt=0
       AND p.position_cd=0)
       del_temp_cnt = (del_temp_cnt+ 1), stat = alterlist(del_temp->qual,del_temp_cnt), del_temp->
       qual[del_temp_cnt].setup_id = p.setup_id
      ENDIF
      IF (pos_cnt > 0
       AND p.position_cd > 0)
       del_temp_cnt = (del_temp_cnt+ 1), stat = alterlist(del_temp->qual,del_temp_cnt), del_temp->
       qual[del_temp_cnt].setup_id = p.setup_id
      ENDIF
     WITH nocounter
    ;end select
    SET pos_cnt = size(request->positions,5)
    IF (pos_cnt=0)
     SET acnt = (acnt+ 1)
     SET stat = alterlist(app->qual,acnt)
     SET pss_id = 0.0
     SELECT INTO "nl:"
      j = seq(pm_sch_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       pss_id = cnvtreal(j)
      WITH format, counter
     ;end select
     SET app->qual[acnt].setup_id = pss_id
     SET app->qual[acnt].application_number = request->application_number
     SET app->qual[acnt].task_number = request->task_number
     SET app->qual[acnt].position_cd = 0
     SET app->qual[acnt].locked_ind = global_lock
     SET app->qual[acnt].style_flag = flags_for_application_rec->qual[y].style_flag
    ENDIF
    FOR (x = 1 TO pos_cnt)
      SET acnt = (acnt+ 1)
      SET stat = alterlist(app->qual,acnt)
      SET pss_id = 0.0
      SELECT INTO "nl:"
       j = seq(pm_sch_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        pss_id = cnvtreal(j)
       WITH format, counter
      ;end select
      SET app->qual[acnt].setup_id = pss_id
      SET app->qual[acnt].application_number = request->application_number
      SET app->qual[acnt].task_number = request->task_number
      SET app->qual[acnt].position_cd = request->positions[x].code_value
      SET app->qual[acnt].locked_ind = global_lock
      SET app->qual[acnt].style_flag = flags_for_application_rec->qual[y].style_flag
    ENDFOR
  ENDFOR
 ENDIF
 IF (del_temp_cnt > 0)
  DELETE  FROM pm_sch_limit l,
    (dummyt d  WITH seq = value(del_temp_cnt))
   SET l.seq = 1
   PLAN (d)
    JOIN (l
    WHERE (l.setup_id=del_temp->qual[d.seq].setup_id))
   WITH nocounter
  ;end delete
  DELETE  FROM pm_sch_filter f,
    (dummyt d  WITH seq = value(del_temp_cnt))
   SET f.seq = 1
   PLAN (d)
    JOIN (f
    WHERE (f.setup_id=del_temp->qual[d.seq].setup_id))
   WITH nocounter
  ;end delete
  DELETE  FROM pm_sch_result r,
    (dummyt d  WITH seq = value(del_temp_cnt))
   SET r.seq = 1
   PLAN (d)
    JOIN (r
    WHERE (r.setup_id=del_temp->qual[d.seq].setup_id))
   WITH nocounter
  ;end delete
  DELETE  FROM pm_sch_setup s,
    (dummyt d  WITH seq = value(del_temp_cnt))
   SET s.seq = 1
   PLAN (d)
    JOIN (s
    WHERE (s.setup_id=del_temp->qual[d.seq].setup_id))
   WITH nocounter
  ;end delete
 ENDIF
 SET field_found = 0
 RANGE OF p IS pm_sch_setup
 SET field_found = validate(p.max_mpi_results_nbr)
 FREE RANGE p
 FOR (x = 1 TO acnt)
   IF (validate(request->mpi_ind))
    IF (field_found > 0)
     SET ierrcode = 0
     INSERT  FROM pm_sch_setup p
      SET p.setup_id = app->qual[x].setup_id, p.application_number = app->qual[x].application_number,
       p.person_id = 0,
       p.position_cd = app->qual[x].position_cd, p.task_number = app->qual[x].task_number, p
       .style_flag = app->qual[x].style_flag,
       p.locked_ind = app->qual[x].locked_ind, p.max = request->max, p.opf_ind = request->empi_ind,
       p.options = options, p.phonetic_ind = request->phonetic_ind, p.threshold =
       IF ((request->empi_threshold > 0)) request->empi_threshold
       ELSE 75
       ENDIF
       ,
       p.title = "", p.wildcard_ind = request->wildcard_ind, p.limit_ind = request->limit_encntr_ind,
       p.max_encntr = request->max_encntr, p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(
        curdate,curtime),
       p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0,
       p.exact_match =
       IF ((request->empi_cutoff_flag=1)) request->empi_cutoff_value
       ELSE 20
       ENDIF
       , p.percent_top =
       IF ((request->empi_cutoff_flag=2)) request->empi_cutoff_value
       ELSE 50
       ENDIF
       , p.simple_percent =
       IF ((request->empi_cutoff_flag=3)) request->empi_cutoff_value
       ELSE 30
       ENDIF
       ,
       p.cutoff_mode_flag = request->empi_cutoff_flag, p.max_mpi_results_nbr =
       IF ((request->mpi_max > 0)) request->mpi_max
       ELSE 200
       ENDIF
      PLAN (p)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = "Y"
      SET reply->error_msg = serrmsg
      GO TO exit_script
     ENDIF
    ELSE
     SET ierrcode = 0
     INSERT  FROM pm_sch_setup p
      SET p.setup_id = app->qual[x].setup_id, p.application_number = app->qual[x].application_number,
       p.person_id = 0,
       p.position_cd = app->qual[x].position_cd, p.task_number = app->qual[x].task_number, p
       .style_flag = app->qual[x].style_flag,
       p.locked_ind = app->qual[x].locked_ind, p.max = request->max, p.opf_ind = request->empi_ind,
       p.options = options, p.phonetic_ind = request->phonetic_ind, p.threshold =
       IF ((request->empi_threshold > 0)) request->empi_threshold
       ELSE 75
       ENDIF
       ,
       p.title = "", p.wildcard_ind = request->wildcard_ind, p.limit_ind = request->limit_encntr_ind,
       p.max_encntr = request->max_encntr, p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(
        curdate,curtime),
       p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0,
       p.exact_match =
       IF ((request->empi_cutoff_flag=1)) request->empi_cutoff_value
       ELSE 20
       ENDIF
       , p.percent_top =
       IF ((request->empi_cutoff_flag=2)) request->empi_cutoff_value
       ELSE 50
       ENDIF
       , p.simple_percent =
       IF ((request->empi_cutoff_flag=3)) request->empi_cutoff_value
       ELSE 30
       ENDIF
       ,
       p.cutoff_mode_flag = request->empi_cutoff_flag
      PLAN (p)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = "Y"
      SET reply->error_msg = serrmsg
      GO TO exit_script
     ENDIF
    ENDIF
   ELSE
    SET ierrcode = 0
    INSERT  FROM pm_sch_setup p
     SET p.setup_id = app->qual[x].setup_id, p.application_number = app->qual[x].application_number,
      p.person_id = 0,
      p.position_cd = app->qual[x].position_cd, p.task_number = app->qual[x].task_number, p
      .style_flag = app->qual[x].style_flag,
      p.locked_ind = app->qual[x].locked_ind, p.max = request->max, p.opf_ind = request->empi_ind,
      p.options = options, p.phonetic_ind = request->phonetic_ind, p.threshold = 75,
      p.title = "", p.wildcard_ind = request->wildcard_ind, p.limit_ind = request->limit_encntr_ind,
      p.max_encntr = request->max_encntr, p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(
       curdate,curtime),
      p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0,
      p.exact_match = 20, p.percent_top = 50, p.simple_percent = 30,
      p.cutoff_mode_flag = 0
     PLAN (p)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   IF ((((request->discharge_ind=1)) OR ((request->departure_ind=1))) )
    SET ierrcode = 0
    INSERT  FROM pm_sch_limit p
     SET p.setup_id = app->qual[x].setup_id, p.encntr_type_class_cd = - (1), p.date_flag =
      IF ((request->discharge_ind=1)) 1
      ELSEIF ((request->departure_ind=1)) 2
      ENDIF
      ,
      p.num_days = request->days
     PLAN (p)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   IF (all_fltr_cnt > 0)
    SET ierrcode = 0
    INSERT  FROM pm_sch_filter p,
      (dummyt d  WITH seq = value(all_fltr_cnt))
     SET p.setup_id = app->qual[x].setup_id, p.data_type_flag = all_filters->qual[d.seq].
      data_type_flag, p.scenario = 0,
      p.sequence = all_filters->qual[d.seq].sequence, p.display = all_filters->qual[d.seq].display, p
      .hidden_ind = all_filters->qual[d.seq].hidden_ind,
      p.meaning = all_filters->qual[d.seq].meaning, p.options = "", p.required_ind = all_filters->
      qual[d.seq].required_ind,
      p.value = cnvtstring(all_filters->qual[d.seq].value)
     PLAN (d)
      JOIN (p)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   IF (result_cnt > 0)
    SET ierrcode = 0
    INSERT  FROM pm_sch_result p,
      (dummyt d  WITH seq = value(result_cnt))
     SET p.setup_id = app->qual[x].setup_id, p.data_type_flag = results->qual[d.seq].data_type_flag,
      p.scenario = 0,
      p.sequence = results->qual[d.seq].sequence, p.display = results->qual[d.seq].display, p.format
       = "",
      p.meaning = results->qual[d.seq].meaning, p.options = "", p.sort_flag = 0
     PLAN (d)
      JOIN (p)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
   SET rcnt = size(request->reltns,5)
   IF (rcnt > 0)
    SET ierrcode = 0
    INSERT  FROM pm_sch_filter p,
      (dummyt d  WITH seq = value(rcnt))
     SET p.setup_id = app->qual[x].setup_id, p.data_type_flag = 0, p.scenario = null,
      p.sequence = null, p.display = null, p.hidden_ind = null,
      p.meaning = "FAMILY_LIMIT", p.options = null, p.required_ind = null,
      p.value = request->reltns[d.seq].value
     PLAN (d)
      JOIN (p)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = "Y"
     SET reply->error_msg = serrmsg
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
