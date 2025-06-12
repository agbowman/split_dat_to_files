CREATE PROGRAM bed_copy_ps_search_settings:dba
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
 CALL bedbeginscript(0)
 DECLARE style_flag = i2 WITH protect, noconstant(0)
 DECLARE pos_cd = f8 WITH protect, noconstant(0)
 DECLARE setup_id = f8 WITH protect, noconstant(0)
 DECLARE max = i2 WITH protect, noconstant(0)
 DECLARE opf_ind = i2 WITH protect, noconstant(0)
 DECLARE options = vc WITH protect, noconstant("")
 DECLARE phonetic_ind = i2 WITH protect, noconstant(0)
 DECLARE threshold = f8 WITH protect, noconstant(0.0)
 DECLARE title = vc WITH protect, noconstant("")
 DECLARE wildcard_ind = i2 WITH protect, noconstant(0)
 DECLARE limit_ind = i2 WITH protect, noconstant(0)
 DECLARE max_encntr = i2 WITH protect, noconstant(0)
 DECLARE exact_match = f8 WITH protect, noconstant(0.0)
 DECLARE percent_top = f8 WITH protect, noconstant(0.0)
 DECLARE simple_percent = f8 WITH protect, noconstant(0.0)
 DECLARE cutoff_mode_flag = i2 WITH protect, noconstant(0)
 DECLARE max_mpi = i2 WITH protect, noconstant(0)
 DECLARE global_lock = i2 WITH protect, noconstant(0)
 DECLARE pos_lock = i2 WITH protect, noconstant(0)
 DECLARE field_found = i2 WITH protect, noconstant(0)
 DECLARE lock_ind = i2 WITH protect, noconstant(0)
 DECLARE acnt = i2 WITH protect, noconstant(0)
 DECLARE dcnt = i2 WITH protect, noconstant(0)
 DECLARE del_cnt = i2 WITH protect, noconstant(0)
 DECLARE ccnt = i2 WITH protect, noconstant(0)
 DECLARE app_count = i2 WITH protect, noconstant(0)
 DECLARE flag_count = i2 WITH protect, noconstant(0)
 DECLARE con_app_count = i2 WITH protect, noconstant(0)
 DECLARE limit_cnt = i2 WITH protect, noconstant(0)
 DECLARE result_cnt = i2 WITH protect, noconstant(0)
 DECLARE filter_cnt = i2 WITH protect, noconstant(0)
 DECLARE reltn_cnt = i2 WITH protect, noconstant(0)
 DECLARE conv_count = i2 WITH protect, noconstant(0)
 DECLARE appcnt = i2 WITH protect, noconstant(0)
 DECLARE pcnt = i2 WITH protect, noconstant(0)
 DECLARE pacnt = i2 WITH protect, noconstant(0)
 DECLARE pos_app_count = i2 WITH protect, noconstant(0)
 DECLARE pccnt = i2 WITH protect, noconstant(0)
 DECLARE pappcnt = i2 WITH protect, noconstant(0)
 DECLARE pos_conv_num = i2 WITH protect, noconstant(0)
 DECLARE insertsettings(application_no=i4,locked_ind=i2,task_number=i4,position_cd=f8,insert_setup_id
  =f8,
  insert_style_flag=i2) = null
 DECLARE generatesetupid(dummyvar=i2) = f8
 DECLARE deletesettings(setup_id=f8) = null
 IF ( NOT (validate(application_rec,0)))
  RECORD application_rec(
    1 application_qual[*]
      2 application_number = i4
      2 locked_ind = i2
      2 flags_for_insert[*]
        3 setup_id = f8
        3 style_flag = i2
  )
 ENDIF
 IF ( NOT (validate(conversation_rec,0)))
  RECORD conversation_rec(
    1 conversation_qual[*]
      2 task_number = i4
      2 application_qual[*]
        3 application_number = i4
        3 locked_ind = i2
        3 flags_for_insert[*]
          4 setup_id = f8
          4 style_flag = i2
  )
 ENDIF
 IF ( NOT (validate(position_rec,0)))
  RECORD position_rec(
    1 position_qual[*]
      2 position_cd = f8
      2 application_qual[*]
        3 application_number = i4
        3 locked_ind = i2
        3 flags_for_insert[*]
          4 setup_id = f8
          4 style_flag = i2
      2 conversation_qual[*]
        3 task_number = i4
        3 applications[*]
          4 application_number = i4
          4 locked_ind = i2
          4 flags_for_insert[*]
            5 setup_id = f8
            5 style_flag = i2
  )
 ENDIF
 SET stat = initrec(flags_for_application_rec)
 CALL determinestyleflag(request->from_application_number,request->from_task_number)
 IF ((flags_for_application_rec->flag_to_use_for_reads != 0))
  SET style_flag = flags_for_application_rec->flag_to_use_for_reads
 ENDIF
 IF (validate(request->from_position_code_value))
  SET pos_cd = request->from_position_code_value
 ENDIF
 IF (validate(request->lock_type_flag))
  IF ((request->lock_type_flag=1))
   SET pos_lock = 1
   SET global_lock = 0
  ELSEIF ((request->lock_type_flag=2))
   SET pos_lock = 1
   SET global_lock = 1
  ELSE
   SET pos_lock = 0
   SET global_lock = 0
  ENDIF
 ELSE
  SET pos_lock = 1
  SET global_lock = 0
 ENDIF
 RANGE OF p IS pm_sch_setup
 SET field_found = validate(p.max_mpi_results_nbr)
 FREE RANGE p
 SELECT INTO "nl:"
  FROM pm_sch_setup p
  PLAN (p
   WHERE (p.application_number=request->from_application_number)
    AND (p.task_number=request->from_task_number)
    AND p.position_cd=pos_cd
    AND p.style_flag=style_flag
    AND p.person_id=0.0)
  ORDER BY p.updt_dt_tm DESC
  DETAIL
   setup_id = p.setup_id, max = p.max, opf_ind = p.opf_ind,
   options = p.options, phonetic_ind = p.phonetic_ind, threshold = p.threshold,
   title = p.title, wildcard_ind = p.wildcard_ind, limit_ind = p.limit_ind,
   max_encntr = p.max_encntr, exact_match = p.exact_match, percent_top = p.percent_top,
   simple_percent = p.simple_percent, cutoff_mode_flag = p.cutoff_mode_flag
   IF (field_found > 0)
    max_mpi = p.max_mpi_results_nbr
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error 001: Failed to read settings from pm_sch_setup table")
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SET stat = initrec(flags_for_application_rec)
 RECORD del_apps(
   1 qual[*]
     2 setup_id = f8
 )
 RECORD del_convs(
   1 qual[*]
     2 setup_id = f8
 )
 SET acnt = size(request->to_applications,5)
 IF (acnt > 0)
  IF ((request->to_applications[1].number=0))
   SET acnt = 0
  ENDIF
  SET dcnt = 0
  SET stat = alterlist(application_rec->application_qual,acnt)
  FOR (app_count = 1 TO acnt)
    CALL determinestyleflag(request->to_applications[app_count].number,0)
    SET application_rec->application_qual[app_count].application_number = request->to_applications[
    app_count].number
    SET application_rec->application_qual[app_count].locked_ind = global_lock
    SET stat = alterlist(application_rec->application_qual[app_count].flags_for_insert,size(
      flags_for_application_rec->qual,5))
    FOR (flag_count = 1 TO size(flags_for_application_rec->qual,5))
     SET application_rec->application_qual[app_count].flags_for_insert[flag_count].setup_id =
     generatesetupid(0)
     SET application_rec->application_qual[app_count].flags_for_insert[flag_count].style_flag =
     flags_for_application_rec->qual[flag_count].style_flag
    ENDFOR
  ENDFOR
  CALL bederrorcheck("Error 002: Error in  populating  application_rec")
  CALL echorecord(application_rec)
 ENDIF
 IF (acnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(acnt)),
    pm_sch_setup p
   PLAN (d)
    JOIN (p
    WHERE (p.application_number=request->to_applications[d.seq].number)
     AND p.person_id=0
     AND p.position_cd=0
     AND p.task_number=0)
   DETAIL
    dcnt = (dcnt+ 1), stat = alterlist(del_apps->qual,dcnt), del_apps->qual[dcnt].setup_id = p
    .setup_id
   WITH nocounter
  ;end select
  CALL bederrorcheck(
   "Error 003: Failed to read old settings from pm_sch_setup at application/solution level")
  IF (dcnt > 0)
   FOR (del_cnt = 1 TO dcnt)
     CALL deletesettings(del_apps->qual[del_cnt].setup_id)
   ENDFOR
  ENDIF
 ENDIF
 SET ccnt = size(request->to_conversations,5)
 IF (ccnt > 0)
  IF ((request->to_conversations[1].task_number=0))
   SET ccnt = 0
  ENDIF
  SET dcnt = 0
  SET stat = initrec(flags_for_application_rec)
  SET stat = alterlist(conversation_rec->conversation_qual,ccnt)
  FOR (conv_count = 1 TO ccnt)
    SET conversation_rec->conversation_qual[conv_count].task_number = request->to_conversations[
    conv_count].task_number
    SET stat = alterlist(conversation_rec->conversation_qual[conv_count].application_qual,size(
      request->to_conversations[conv_count].to_applications,5))
    FOR (con_app_count = 1 TO size(request->to_conversations[conv_count].to_applications,5))
      CALL determinestyleflag(request->to_conversations[conv_count].to_applications[con_app_count].
       number,request->to_conversations[conv_count].task_number)
      SET conversation_rec->conversation_qual[conv_count].application_qual[con_app_count].
      application_number = request->to_conversations[conv_count].to_applications[con_app_count].
      number
      SET conversation_rec->conversation_qual[conv_count].application_qual[con_app_count].locked_ind
       = global_lock
      SET stat = alterlist(conversation_rec->conversation_qual[conv_count].application_qual[
       con_app_count].flags_for_insert,size(flags_for_application_rec->qual,5))
      FOR (flag_count = 1 TO size(flags_for_application_rec->qual,5))
       SET conversation_rec->conversation_qual[conv_count].application_qual[con_app_count].
       flags_for_insert[flag_count].setup_id = generatesetupid(0)
       SET conversation_rec->conversation_qual[conv_count].application_qual[con_app_count].
       flags_for_insert[flag_count].style_flag = flags_for_application_rec->qual[flag_count].
       style_flag
      ENDFOR
    ENDFOR
  ENDFOR
  CALL bederrorcheck("Error 004: Error in  populating conversation_rec")
  CALL echorecord(conversation_rec)
 ENDIF
 IF (ccnt > 0)
  SET appcnt = 0
  FOR (y = 1 TO ccnt)
   SET appcnt = size(request->to_conversations[y].to_applications,5)
   IF (appcnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(appcnt)),
      pm_sch_setup p
     PLAN (d)
      JOIN (p
      WHERE (p.application_number=request->to_conversations[y].to_applications[d.seq].number)
       AND (p.task_number=request->to_conversations[y].task_number)
       AND p.person_id=0
       AND p.position_cd=0)
     DETAIL
      dcnt = (dcnt+ 1), stat = alterlist(del_convs->qual,dcnt), del_convs->qual[dcnt].setup_id = p
      .setup_id
     WITH nocounter
    ;end select
    CALL bederrorcheck(
     "Error 005: Failed to read old settings from pm_sch_setup table at application/conversation level"
     )
   ENDIF
  ENDFOR
  IF (dcnt > 0)
   FOR (del_cnt = 1 TO dcnt)
     CALL deletesettings(del_convs->qual[del_cnt].setup_id)
   ENDFOR
  ENDIF
 ENDIF
 SET pcnt = size(request->to_positions,5)
 IF (pcnt > 0)
  IF ((request->to_positions[1].position_code_value=0))
   SET pcnt = 0
  ENDIF
  SET stat = alterlist(position_rec->position_qual,pcnt)
  SET pacnt = 0
  FOR (a = 1 TO pcnt)
    SET pacnt = size(request->to_positions[a].to_applications,5)
    SET dcnt = 0
    SET stat = initrec(flags_for_application_rec)
    IF (pacnt > 0)
     SET stat = alterlist(position_rec->position_qual[a].application_qual,pacnt)
     FOR (pos_app_count = 1 TO pacnt)
       SET position_rec->position_qual[a].application_qual[pos_app_count].application_number =
       request->to_positions[a].to_applications[pos_app_count].number
       SET position_rec->position_qual[a].position_cd = request->to_positions[a].position_code_value
       SET position_rec->position_qual[a].application_qual[pos_app_count].locked_ind = global_lock
       CALL determinestyleflag(request->to_positions[a].to_applications[pos_app_count].number,0)
       SET stat = alterlist(position_rec->position_qual[a].application_qual[pos_app_count].
        flags_for_insert,size(flags_for_application_rec->qual,5))
       FOR (flag_count = 1 TO size(flags_for_application_rec->qual,5))
        SET position_rec->position_qual[a].application_qual[pos_app_count].flags_for_insert[
        flag_count].setup_id = generatesetupid(0)
        SET position_rec->position_qual[a].application_qual[pos_app_count].flags_for_insert[
        flag_count].style_flag = flags_for_application_rec->qual[flag_count].style_flag
       ENDFOR
     ENDFOR
     CALL bederrorcheck("Error 006: Error in  populating  position_rec")
     CALL echorecord(position_rec)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(pacnt)),
       pm_sch_setup p
      PLAN (d)
       JOIN (p
       WHERE (p.application_number=request->to_positions[a].to_applications[d.seq].number)
        AND p.person_id=0
        AND p.task_number=0
        AND (p.position_cd=request->to_positions[a].position_code_value))
      DETAIL
       dcnt = (dcnt+ 1), stat = alterlist(del_apps->qual,dcnt), del_apps->qual[dcnt].setup_id = p
       .setup_id
      WITH nocounter
     ;end select
     CALL bederrorcheck(
      "Error 007: Failed to read old settings from pm_sch_setup at position/solution level")
     IF (dcnt > 0)
      FOR (del_cnt = 1 TO dcnt)
        CALL deletesettings(del_apps->qual[del_cnt].setup_id)
      ENDFOR
     ENDIF
    ENDIF
    SET pccnt = size(request->to_positions[a].to_conversations,5)
    SET dcnt = 0
    SET stat = initrec(flags_for_application_rec)
    IF (pccnt > 0)
     SET pappcnt = 0
     SET stat = alterlist(position_rec->position_qual[a].conversation_qual,pccnt)
     FOR (b = 1 TO pccnt)
      SET pappcnt = size(request->to_positions[a].to_conversations[b].to_applications,5)
      IF (pappcnt > 0)
       SET position_rec->position_qual[a].conversation_qual[b].task_number = request->to_positions[a]
       .to_conversations[b].task_number
       SET position_rec->position_qual[a].position_cd = request->to_positions[a].position_code_value
       FOR (pos_conv_num = 1 TO pappcnt)
         SET stat = alterlist(position_rec->position_qual[a].conversation_qual[b].applications,
          pappcnt)
         SET position_rec->position_qual[a].conversation_qual[b].applications[pos_conv_num].
         application_number = request->to_positions[a].to_conversations[b].to_applications[
         pos_conv_num].number
         SET position_rec->position_qual[a].conversation_qual[b].applications[pos_conv_num].
         locked_ind = global_lock
         CALL determinestyleflag(request->to_positions[a].to_conversations[b].to_applications[
          pos_conv_num].number,request->to_positions[a].to_conversations[b].task_number)
         SET stat = alterlist(position_rec->position_qual[a].conversation_qual[b].applications[
          pos_conv_num].flags_for_insert,size(flags_for_application_rec->qual,5))
         FOR (flag_count = 1 TO size(flags_for_application_rec->qual,5))
          SET position_rec->position_qual[a].conversation_qual[b].applications[pos_conv_num].
          flags_for_insert[flag_count].setup_id = generatesetupid(0)
          SET position_rec->position_qual[a].conversation_qual[b].applications[pos_conv_num].
          flags_for_insert[flag_count].style_flag = flags_for_application_rec->qual[flag_count].
          style_flag
         ENDFOR
       ENDFOR
       CALL bederrorcheck(
        "Error 008: Error in  populating  conversation (task) level settings in position_rec")
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = value(pappcnt)),
         pm_sch_setup p
        PLAN (d)
         JOIN (p
         WHERE (p.application_number=request->to_positions[a].to_conversations[b].to_applications[d
         .seq].number)
          AND (p.task_number=request->to_positions[a].to_conversations[b].task_number)
          AND p.person_id=0
          AND (p.position_cd=request->to_positions[a].position_code_value))
        DETAIL
         dcnt = (dcnt+ 1), stat = alterlist(del_convs->qual,dcnt), del_convs->qual[dcnt].setup_id = p
         .setup_id
        WITH nocounter
       ;end select
       CALL bederrorcheck(
        "Error 009: Failed to read old settings from pm_sch_setup at position/conversation level")
      ENDIF
     ENDFOR
     IF (dcnt > 0)
      FOR (del_cnt = 1 TO dcnt)
        CALL deletesettings(del_convs->qual[del_cnt].setup_id)
      ENDFOR
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 IF (acnt > 0)
  FOR (z = 1 TO size(application_rec->application_qual,5))
    SET scnt = 0
    FOR (y = 1 TO size(application_rec->application_qual[z].flags_for_insert,5))
      CALL insertsettings(application_rec->application_qual[z].application_number,application_rec->
       application_qual[z].locked_ind,0,0.0,application_rec->application_qual[z].flags_for_insert[y].
       setup_id,
       application_rec->application_qual[z].flags_for_insert[y].style_flag)
    ENDFOR
    IF ((application_rec->application_qual[z].application_number=70000))
     CALL insertsettings(application_rec->application_qual[z].application_number,application_rec->
      application_qual[z].locked_ind,70004,0.0,generatesetupid(0),
      1)
     CALL insertsettings(application_rec->application_qual[z].application_number,application_rec->
      application_qual[z].locked_ind,70006,0.0,generatesetupid(0),
      3)
     CALL insertsettings(application_rec->application_qual[z].application_number,application_rec->
      application_qual[z].locked_ind,70008,0.0,generatesetupid(0),
      1)
     CALL insertsettings(application_rec->application_qual[z].application_number,application_rec->
      application_qual[z].locked_ind,70009,0.0,generatesetupid(0),
      1)
    ENDIF
  ENDFOR
 ENDIF
 IF (ccnt > 0)
  FOR (z = 1 TO size(conversation_rec->conversation_qual,5))
    FOR (y = 1 TO size(conversation_rec->conversation_qual[z].application_qual,5))
      FOR (flag_cnt = 1 TO size(conversation_rec->conversation_qual[z].application_qual[y].
       flags_for_insert,5))
        CALL insertsettings(conversation_rec->conversation_qual[z].application_qual[y].
         application_number,conversation_rec->conversation_qual[z].application_qual[y].locked_ind,
         conversation_rec->conversation_qual[z].task_number,0.0,conversation_rec->conversation_qual[z
         ].application_qual[y].flags_for_insert[flag_cnt].setup_id,
         conversation_rec->conversation_qual[z].application_qual[y].flags_for_insert[flag_cnt].
         style_flag)
      ENDFOR
    ENDFOR
  ENDFOR
 ENDIF
 IF (size(position_rec->position_qual,5) > 0)
  SET app_cnt = 0
  FOR (x = 1 TO size(position_rec->position_qual,5))
    SET y = 0
    FOR (y = 1 TO size(position_rec->position_qual[x].application_qual,5))
      SET scnt = 0
      FOR (flag_cnt = 1 TO size(position_rec->position_qual[x].application_qual[y].flags_for_insert,5
       ))
        CALL insertsettings(position_rec->position_qual[x].application_qual[y].application_number,
         position_rec->position_qual[x].application_qual[y].locked_ind,0,position_rec->position_qual[
         x].position_cd,position_rec->position_qual[x].application_qual[y].flags_for_insert[flag_cnt]
         .setup_id,
         position_rec->position_qual[x].application_qual[y].flags_for_insert[flag_cnt].style_flag)
      ENDFOR
      IF ((position_rec->position_qual[x].application_qual[y].application_number=70000))
       CALL insertsettings(position_rec->position_qual[x].application_qual[y].application_number,
        position_rec->position_qual[x].application_qual[y].locked_ind,70004,position_rec->
        position_qual[x].position_cd,generatesetupid(0),
        1)
       CALL insertsettings(position_rec->position_qual[x].application_qual[y].application_number,
        position_rec->position_qual[x].application_qual[y].locked_ind,70006,position_rec->
        position_qual[x].position_cd,generatesetupid(0),
        3)
       CALL insertsettings(position_rec->position_qual[x].application_qual[y].application_number,
        position_rec->position_qual[x].application_qual[y].locked_ind,70008,position_rec->
        position_qual[x].position_cd,generatesetupid(0),
        1)
       CALL insertsettings(position_rec->position_qual[x].application_qual[y].application_number,
        position_rec->position_qual[x].application_qual[y].locked_ind,70009,position_rec->
        position_qual[x].position_cd,generatesetupid(0),
        1)
      ENDIF
    ENDFOR
    FOR (y = 1 TO size(position_rec->position_qual[x].conversation_qual,5))
      FOR (z = 1 TO size(position_rec->position_qual[x].conversation_qual[y].applications,5))
        FOR (flag_cnt = 1 TO size(position_rec->position_qual[x].conversation_qual[y].applications[z]
         .flags_for_insert,5))
          CALL insertsettings(position_rec->position_qual[x].conversation_qual[y].applications[z].
           application_number,position_rec->position_qual[x].conversation_qual[y].applications[z].
           locked_ind,position_rec->position_qual[x].conversation_qual[y].task_number,position_rec->
           position_qual[x].position_cd,generatesetupid(0),
           position_rec->position_qual[x].conversation_qual[y].applications[z].flags_for_insert[
           flag_cnt].style_flag)
        ENDFOR
      ENDFOR
    ENDFOR
  ENDFOR
  CALL echorecord(position_rec)
 ENDIF
 SUBROUTINE insertsettings(application_no,locked_ind,task_number,position_cd,insert_setup_id,
  insert_style_flag)
   IF (field_found > 0)
    INSERT  FROM pm_sch_setup p
     SET p.setup_id = insert_setup_id, p.application_number = application_no, p.person_id = 0,
      p.position_cd = position_cd, p.task_number = task_number, p.style_flag = insert_style_flag,
      p.locked_ind = locked_ind, p.max = max, p.opf_ind = opf_ind,
      p.options = options, p.phonetic_ind = phonetic_ind, p.threshold = threshold,
      p.title = title, p.wildcard_ind = wildcard_ind, p.limit_ind = limit_ind,
      p.max_encntr = max_encntr, p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(curdate,
       curtime),
      p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0,
      p.exact_match = exact_match, p.percent_top = percent_top, p.simple_percent = simple_percent,
      p.cutoff_mode_flag = cutoff_mode_flag, p.max_mpi_results_nbr = max_mpi
     PLAN (p)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Error 010: Failed to insert settings in pm_sch_setup table")
   ELSE
    INSERT  FROM pm_sch_setup p
     SET p.setup_id = insert_setup_id, p.application_number = application_no, p.person_id = 0,
      p.position_cd = position_cd, p.task_number = task_number, p.style_flag = insert_style_flag,
      p.locked_ind = locked_ind, p.max = max, p.opf_ind = opf_ind,
      p.options = options, p.phonetic_ind = phonetic_ind, p.threshold = threshold,
      p.title = title, p.wildcard_ind = wildcard_ind, p.limit_ind = limit_ind,
      p.max_encntr = max_encntr, p.updt_id = reqinfo->updt_id, p.updt_dt_tm = cnvtdatetime(curdate,
       curtime),
      p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0,
      p.exact_match = exact_match, p.percent_top = percent_top, p.simple_percent = simple_percent,
      p.cutoff_mode_flag = cutoff_mode_flag
     PLAN (p)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Error 011: Failed to insert settings in pm_sch_setup table")
   ENDIF
   FREE SET filters
   RECORD filters(
     1 qual[*]
       2 data_type_flag = i2
       2 sequence = i4
       2 display = vc
       2 meaning = vc
       2 required_ind = i2
       2 scenario = i4
       2 value = vc
       2 hidden_ind = i2
       2 options = vc
   )
   SET filter_cnt = 0
   SELECT INTO "nl:"
    FROM pm_sch_filter p
    PLAN (p
     WHERE p.setup_id=setup_id
      AND p.data_type_flag > 0)
    DETAIL
     filter_cnt = (filter_cnt+ 1), stat = alterlist(filters->qual,filter_cnt), filters->qual[
     filter_cnt].data_type_flag = p.data_type_flag,
     filters->qual[filter_cnt].sequence = p.sequence, filters->qual[filter_cnt].display = p.display,
     filters->qual[filter_cnt].meaning = p.meaning,
     filters->qual[filter_cnt].required_ind = p.required_ind, filters->qual[filter_cnt].hidden_ind =
     p.hidden_ind, filters->qual[filter_cnt].scenario = p.scenario,
     filters->qual[filter_cnt].value = p.value, filters->qual[filter_cnt].options = p.options
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 012: Failed to populate filters->qual[] from pm_sch_filter table")
   FREE SET results
   RECORD results(
     1 qual[*]
       2 data_type_flag = i2
       2 sequence = i4
       2 display = vc
       2 meaning = vc
   )
   SET result_cnt = 0
   SELECT INTO "nl:"
    FROM pm_sch_result p
    PLAN (p
     WHERE p.setup_id=setup_id)
    DETAIL
     result_cnt = (result_cnt+ 1), stat = alterlist(results->qual,result_cnt), results->qual[
     result_cnt].data_type_flag = p.data_type_flag,
     results->qual[result_cnt].sequence = p.sequence, results->qual[result_cnt].display = p.display,
     results->qual[result_cnt].meaning = p.meaning
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 013: Failed to populate results->qual[] from pm_sch_result table")
   FREE SET reltns
   RECORD reltns(
     1 qual[*]
       2 value = vc
   )
   SET reltn_cnt = 0
   SELECT INTO "nl:"
    FROM pm_sch_filter p
    PLAN (p
     WHERE p.setup_id=setup_id
      AND p.data_type_flag=0)
    DETAIL
     reltn_cnt = (reltn_cnt+ 1), stat = alterlist(reltns->qual,reltn_cnt), reltns->qual[reltn_cnt].
     value = p.value
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 014: Failed to populate reltns->qual[] from pm_sch_filter table")
   FREE SET limits
   RECORD limits(
     1 qual[*]
       2 class_cd = f8
       2 date_flag = i2
       2 days = i4
   )
   SET limit_cnt = 0
   SELECT INTO "nl:"
    FROM pm_sch_limit p
    PLAN (p
     WHERE p.setup_id=setup_id)
    DETAIL
     limit_cnt = (limit_cnt+ 1), stat = alterlist(limits->qual,limit_cnt), limits->qual[limit_cnt].
     class_cd = p.encntr_type_class_cd,
     limits->qual[limit_cnt].date_flag = p.date_flag, limits->qual[limit_cnt].days = p.num_days
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 015: Failed to populate limits->qual[] from pm_sch_limit table")
   IF (limit_cnt > 0)
    SET ierrcode = 0
    INSERT  FROM pm_sch_limit p,
      (dummyt d  WITH seq = value(limit_cnt))
     SET p.setup_id = insert_setup_id, p.encntr_type_class_cd = limits->qual[d.seq].class_cd, p
      .date_flag = limits->qual[d.seq].date_flag,
      p.num_days = limits->qual[d.seq].days
     PLAN (d)
      JOIN (p)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Error 016: Failed to insert settings to pm_sch_limit table")
   ENDIF
   IF (filter_cnt > 0)
    SET ierrcode = 0
    INSERT  FROM pm_sch_filter p,
      (dummyt d  WITH seq = value(filter_cnt))
     SET p.setup_id = insert_setup_id, p.data_type_flag = filters->qual[d.seq].data_type_flag, p
      .scenario = filters->qual[d.seq].scenario,
      p.sequence = filters->qual[d.seq].sequence, p.display = filters->qual[d.seq].display, p
      .hidden_ind = filters->qual[d.seq].hidden_ind,
      p.meaning = filters->qual[d.seq].meaning, p.options = filters->qual[d.seq].options, p
      .required_ind = filters->qual[d.seq].required_ind,
      p.value = filters->qual[d.seq].value
     PLAN (d)
      JOIN (p)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Error 017: Failed to insert settings to pm_sch_filter table")
   ENDIF
   IF (result_cnt > 0)
    SET ierrcode = 0
    INSERT  FROM pm_sch_result p,
      (dummyt d  WITH seq = value(result_cnt))
     SET p.setup_id = insert_setup_id, p.data_type_flag = results->qual[d.seq].data_type_flag, p
      .scenario = 0,
      p.sequence = results->qual[d.seq].sequence, p.display = results->qual[d.seq].display, p.format
       = "",
      p.meaning = results->qual[d.seq].meaning, p.options = "", p.sort_flag = 0
     PLAN (d)
      JOIN (p)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Error 018: Failed to insert settings to pm_sch_result table")
   ENDIF
   IF (reltn_cnt > 0)
    SET ierrcode = 0
    INSERT  FROM pm_sch_filter p,
      (dummyt d  WITH seq = value(reltn_cnt))
     SET p.setup_id = insert_setup_id, p.data_type_flag = 0, p.scenario = null,
      p.sequence = null, p.display = null, p.hidden_ind = null,
      p.meaning = "FAMILY_LIMIT", p.options = null, p.required_ind = null,
      p.value = reltns->qual[d.seq].value
     PLAN (d)
      JOIN (p)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Error 019: Failed to insert settings to pm_sch_filter table")
   ENDIF
 END ;Subroutine
 SUBROUTINE generatesetupid(dummyvar1)
   DECLARE app_setup_id = f8 WITH protect, noconstant(0.0)
   SET app_setup_id = 0.0
   SELECT INTO "nl:"
    j = seq(pm_sch_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     app_setup_id = cnvtreal(j)
    WITH format, counter
   ;end select
   RETURN(app_setup_id)
   CALL bederrorcheck("Error 020: Failed to generate setup_id")
 END ;Subroutine
 SUBROUTINE deletesettings(setup_id)
   DELETE  FROM pm_sch_limit l
    PLAN (l
     WHERE l.setup_id=setup_id)
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Error 021: Failed to delete old settings from pm_sch_limit table")
   DELETE  FROM pm_sch_filter f
    PLAN (f
     WHERE f.setup_id=setup_id)
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Error 022: Failed to delete old settings from pm_sch_filter table")
   DELETE  FROM pm_sch_result r
    PLAN (r
     WHERE r.setup_id=setup_id)
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Error 023: Failed to delete old settings from pm_sch_result table")
   DELETE  FROM pm_sch_setup s
    PLAN (s
     WHERE s.setup_id=setup_id)
    WITH nocounter
   ;end delete
   CALL bederrorcheck("Error 024: Failed to delete old settings from pm_sch_setup table")
 END ;Subroutine
#exit_script
 CALL bedexitscript(1)
END GO
