CREATE PROGRAM bed_get_ps_search_settings:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 max = i4
    1 phonetic_ind = i2
    1 wildcard_ind = i2
    1 name_search_ind = i2
    1 reltn_avail_ind = i2
    1 relationship_ind = i2
    1 empi_ind = i2
    1 empi_threshold = f8
    1 empi_cutoff_flag = i2
    1 empi_cutoff_value = f8
    1 mpi_ind = i2
    1 mpi_auto_ind = i2
    1 mpi_phonetic_ind = i2
    1 mpi_wildcard_ind = i2
    1 mpi_max = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 lock_ind = i2
    1 mpi_always_allow_ind = i2
    1 launch_combine_ind = i2
    1 search_quality_ind = i2
  )
 ENDIF
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
 CALL bedbeginscript(0)
 DECLARE cur_rev = i4 WITH protect, noconstant(0)
 DECLARE cur_rev_minor = i4 WITH protect, noconstant(0)
 DECLARE cur_rev_minor2 = i4 WITH protect, noconstant(0)
 DECLARE millennium_version = f8 WITH protect, noconstant(0.0)
 DECLARE style_flag = i2 WITH protect, noconstant(0)
 DECLARE pos_cd = f8 WITH protect, noconstant(0.0)
 CALL determinestyleflag(request->application_number,request->task_number)
 IF ((flags_for_application_rec->flag_to_use_for_reads != 0))
  SET style_flag = flags_for_application_rec->flag_to_use_for_reads
 ENDIF
 SET stat = initrec(flags_for_application_rec)
 SET field_found = 0
 RANGE OF p IS pm_sch_setup
 SET field_found = validate(p.max_mpi_results_nbr)
 FREE RANGE p
 IF (validate(request->position_code_value))
  SET pos_cd = request->position_code_value
 ENDIF
 SELECT INTO "nl:"
  FROM pm_sch_setup p
  PLAN (p
   WHERE (p.application_number=request->application_number)
    AND (p.task_number=request->task_number)
    AND p.style_flag=style_flag
    AND p.position_cd=pos_cd
    AND p.person_id=0.0)
  ORDER BY p.updt_dt_tm DESC
  DETAIL
   reply->max = p.max, reply->phonetic_ind = p.phonetic_ind, reply->wildcard_ind = p.wildcard_ind
   IF (textlen(p.options) >= 1)
    IF (substring(1,1,p.options)="1")
     reply->name_search_ind = 1
    ENDIF
   ENDIF
   IF (textlen(p.options) >= 2)
    IF (substring(2,1,p.options)="1")
     reply->launch_combine_ind = 1
    ENDIF
   ENDIF
   IF (textlen(p.options) >= 4)
    IF (substring(4,1,p.options)="1")
     reply->relationship_ind = 1
    ENDIF
   ENDIF
   cur_rev = currev, cur_rev_minor = currevminor, cur_rev_minor2 = currevminor2,
   millennium_version = cnvtreal(build(cur_rev,cur_rev_minor,cur_rev_minor2))
   IF (millennium_version >= 825)
    reply->reltn_avail_ind = 1
   ENDIF
   reply->lock_ind = p.locked_ind, reply->empi_ind = p.opf_ind, reply->empi_threshold = p.threshold,
   reply->empi_cutoff_flag = p.cutoff_mode_flag
   IF (p.cutoff_mode_flag=1)
    reply->empi_cutoff_value = p.exact_match
   ELSEIF (p.cutoff_mode_flag=2)
    reply->empi_cutoff_value = p.percent_top
   ELSEIF (p.cutoff_mode_flag=3)
    reply->empi_cutoff_value = p.simple_percent
   ENDIF
   IF (field_found > 0)
    reply->mpi_max = p.max_mpi_results_nbr
   ENDIF
   IF (textlen(p.options) >= 8)
    IF (substring(8,1,p.options)="1")
     reply->mpi_ind = 1
    ENDIF
   ENDIF
   IF (textlen(p.options) >= 9)
    IF (substring(9,1,p.options)="1")
     reply->mpi_auto_ind = 1
    ENDIF
   ENDIF
   IF (textlen(p.options) >= 10)
    IF (substring(10,1,p.options)="1")
     reply->mpi_phonetic_ind = 1
    ENDIF
   ENDIF
   IF (textlen(p.options) >= 11)
    IF (substring(11,1,p.options)="1")
     reply->mpi_wildcard_ind = 1
    ENDIF
   ENDIF
   IF (textlen(p.options) >= 12)
    IF (substring(12,1,p.options)="1")
     reply->mpi_always_allow_ind = 1
    ENDIF
   ENDIF
   IF (textlen(p.options) >= 14)
    IF (substring(14,1,p.options)="1")
     reply->search_quality_ind = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error 001: Failed to read from pm_sch_setup table")
#exit_script
 CALL bedexitscript(0)
END GO
