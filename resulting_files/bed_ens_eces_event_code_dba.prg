CREATE PROGRAM bed_ens_eces_event_code:dba
 RECORD request_cv(
   1 cd_value_list[1]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 FREE SET reply
 RECORD reply(
   1 event_codes[*]
     2 code_value = f8
     2 display = vc
     2 event_set_code_value = f8
   1 auto_gen_dups[*]
     2 dup_code_value = f8
     2 dup_display = vc
     2 auto_display = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_code
 RECORD temp_code(
   1 codes[*]
     2 parent_cd = f8
     2 event_set_name = vc
     2 event_display = vc
     2 event_class_cd = f8
 )
 FREE SET temp_hier
 RECORD temp_hier(
   1 event_hier[*]
     2 code_value = f8
     2 level = i4
 )
 FREE SET fin_temp_hier
 RECORD fin_temp_hier(
   1 event_hier[*]
     2 code_value = f8
     2 level = i4
 )
 FREE SET temp_sets
 RECORD temp_sets(
   1 event_sets[*]
     2 code_value = f8
 )
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
 DECLARE ensureeventcodes(dummyvar=i2) = null
 DECLARE updatedtareltn(atx=i4,ecy=i4) = null
 DECLARE dtaeventcode = f8 WITH protect, noconstant(0.0)
 CALL ensureeventcodes(0)
 SUBROUTINE ensureeventcodes(dummyvar)
   CALL bedlogmessage("ensureEventCodes","Entering...")
   SET list_cnt = 0
   SET cnt = 0
   SET rep_cnt = 0
   SET rep_tcnt = 0
   SET stat = alterlist(reply->event_codes,100)
   SET dup_event_cnt = 0
   SET dup_event_tcnt = 0
   SET stat = alterlist(reply->auto_gen_dups,10)
   SET active_status_code_value = 0.0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=48
     AND cv.cdf_meaning="ACTIVE"
     AND cv.active_ind=1
    DETAIL
     active_status_code_value = cv.code_value
    WITH nocounter
   ;end select
   SET auth_code_value = 0.0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=8
     AND cv.cdf_meaning="AUTH"
     AND cv.active_ind=1
    DETAIL
     auth_code_value = cv.code_value
    WITH nocounter
   ;end select
   SET def_frmt_code_value = 0.0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=23
     AND cv.cdf_meaning="UNKNOWN"
     AND cv.active_ind=1
    DETAIL
     def_frmt_code_value = cv.code_value
    WITH nocounter
   ;end select
   SET def_store_code_value = 0.0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=25
     AND cv.cdf_meaning="UNKNOWN"
     AND cv.active_ind=1
    DETAIL
     def_store_code_value = cv.code_value
    WITH nocounter
   ;end select
   SET def_confid_lvl_code_value = 0.0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=87
     AND cv.cdf_meaning="ROUTCLINICAL"
     AND cv.active_ind=1
    DETAIL
     def_confid_lvl_code_value = cv.code_value
    WITH nocounter
   ;end select
   SET subclass_code_value = 0.0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=102
     AND cv.cdf_meaning="UNKNOWN"
     AND cv.active_ind=1
    DETAIL
     subclass_code_value = cv.code_value
    WITH nocounter
   ;end select
   FOR (x = 1 TO size(request->activity_types,5))
     FOR (y = 1 TO size(request->activity_types[x].event_codes,5))
       IF ((request->activity_types[x].event_codes[y].action_flag=1))
        SET rep_cnt = (rep_cnt+ 1)
        SET rep_tcnt = (rep_tcnt+ 1)
        IF (rep_tcnt > 100)
         SET stat = alterlist(reply->event_codes,(rep_cnt+ 100))
         SET rep_tcnt = 1
        ENDIF
        DECLARE cs53_mean = vc
        IF ((request->activity_types[x].meaning="AP"))
         IF ((request->activity_types[x].event_codes[y].dta_ind=0))
          SET cs53_mean = "DOC"
         ELSEIF ((request->activity_types[x].event_codes[y].dta_ind=1))
          SET cs53_mean = "MDOC"
         ENDIF
        ELSEIF ((((request->activity_types[x].meaning="GLB")) OR ((request->activity_types[x].meaning
        ="NURS"))) )
         SET cs53_mean = "UNKNOWN"
        ELSEIF ((request->activity_types[x].meaning="MICROBIOLOGY"))
         SET cs53_mean = "MBO"
        ELSEIF ((request->activity_types[x].meaning="RADIOLOGY"))
         IF ((request->activity_types[x].event_codes[y].dta_ind=0))
          SET cs53_mean = "RAD"
         ELSEIF ((request->activity_types[x].event_codes[y].dta_ind=1))
          SET cs53_mean = "DOC"
         ENDIF
        ENDIF
        SET cs53_code_value = 0.0
        IF (cs53_mean > " ")
         SELECT INTO "nl:"
          FROM code_value cv
          WHERE cv.code_set=53
           AND cv.cdf_meaning=cs53_mean
           AND cv.active_ind=1
          DETAIL
           cs53_code_value = cv.code_value
          WITH nocounter
         ;end select
        ENDIF
        IF (cs53_code_value <= 0)
         CALL bederror(concat("Could not retrieve event class for activity type: ",trim(request->
            activity_types[x].meaning)," from cs53"))
        ENDIF
        IF ((request->activity_types[x].event_codes[y].event_code_value=0))
         SET new_cv = 0.0
         SELECT INTO "NL:"
          j = seq(reference_seq,nextval)"##################;rp0"
          FROM dual
          DETAIL
           new_cv = cnvtreal(j)
          WITH format, counter
         ;end select
         INSERT  FROM code_value cv
          SET cv.code_value = new_cv, cv.code_set = 72, cv.cdf_meaning = null,
           cv.display = trim(substring(1,40,request->activity_types[x].event_codes[y].display)), cv
           .display_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->activity_types[x].
               event_codes[y].display)))), cv.description = trim(substring(1,60,request->
             activity_types[x].event_codes[y].display)),
           cv.definition = trim(substring(1,100,request->activity_types[x].event_codes[y].display)),
           cv.collation_seq = 1, cv.active_type_cd = active_status_code_value,
           cv.active_ind = 1, cv.active_dt_tm = cnvtdatetime(curdate,curtime3), cv.inactive_dt_tm =
           null,
           cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv
           .updt_task = reqinfo->updt_task,
           cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = 0, cv.begin_effective_dt_tm =
           cnvtdatetime(curdate,curtime3),
           cv.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), cv.data_status_cd = auth_code_value,
           cv.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
           cv.cki = null, cv.display_key_nls = null, cv.concept_cki = ""
          WITH nocounter
         ;end insert
         IF (curqual=0)
          CALL bederror(concat("Unable to insert ",trim(request->activity_types[x].event_codes[y].
             display)," into codeset 72."))
         ENDIF
         SET request->activity_types[x].event_codes[y].event_code_value = new_cv
         INSERT  FROM v500_event_code vec
          SET vec.event_cd = request->activity_types[x].event_codes[y].event_code_value, vec
           .event_cd_definition = trim(substring(1,100,request->activity_types[x].event_codes[y].
             display)), vec.event_cd_descr = trim(substring(1,60,request->activity_types[x].
             event_codes[y].display)),
           vec.event_cd_disp = trim(substring(1,40,request->activity_types[x].event_codes[y].display)
            ), vec.event_cd_disp_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->
               activity_types[x].event_codes[y].display)))), vec.code_status_cd =
           active_status_code_value,
           vec.def_docmnt_attributes = null, vec.def_docmnt_format_cd = def_frmt_code_value, vec
           .def_docmnt_storage_cd = def_store_code_value,
           vec.def_event_class_cd = cs53_code_value, vec.def_event_confid_level_cd =
           def_confid_lvl_code_value, vec.def_event_level = null,
           vec.event_add_access_ind = 0.0, vec.event_cd_subclass_cd = subclass_code_value, vec
           .event_chg_access_ind = 0,
           vec.event_set_name = trim(substring(1,40,request->activity_types[x].event_codes[y].display
             )), vec.retention_days = null, vec.updt_dt_tm = cnvtdatetime(curdate,curtime3),
           vec.updt_id = reqinfo->updt_id, vec.updt_task = reqinfo->updt_task, vec.updt_cnt = 0,
           vec.updt_applctx = reqinfo->updt_applctx, vec.event_code_status_cd = auth_code_value, vec
           .collating_seq = 0.0
          WITH nocounter
         ;end insert
         IF (curqual=0)
          CALL bederror(concat("Unable to insert ",trim(request->activity_types[x].event_codes[y].
             display)," into v500_event_code table."))
         ENDIF
         SET explode_ind = 0
        ELSE
         UPDATE  FROM v500_event_code vec
          SET vec.def_event_class_cd = cs53_code_value, vec.updt_dt_tm = cnvtdatetime(curdate,
            curtime3), vec.updt_id = reqinfo->updt_id,
           vec.updt_task = reqinfo->updt_task, vec.updt_cnt = (vec.updt_cnt+ 1), vec.updt_applctx =
           reqinfo->updt_applctx
          WHERE (vec.event_cd=request->activity_types[x].event_codes[y].event_code_value)
          WITH nocounter
         ;end update
         IF (curqual=0)
          CALL bederror(concat("Unable to update ",trim(request->activity_types[x].event_codes[y].
             display)," on the v500_event_code table."))
         ENDIF
         SET explode_ind = 0
         SELECT INTO "nl:"
          FROM v500_event_set_explode ves
          WHERE (ves.event_cd=request->activity_types[x].event_codes[y].event_code_value)
           AND ves.event_set_level=0
          DETAIL
           reply->event_codes[rep_cnt].event_set_code_value = ves.event_set_cd, explode_ind = 1
          WITH nocounter
         ;end select
        ENDIF
        SET reply->event_codes[rep_cnt].code_value = request->activity_types[x].event_codes[y].
        event_code_value
        SET reply->event_codes[rep_cnt].display = request->activity_types[x].event_codes[y].display
        INSERT  FROM code_value_event_r cr
         SET cr.event_cd = request->activity_types[x].event_codes[y].event_code_value, cr.parent_cd
           = request->activity_types[x].event_codes[y].assay_code_value, cr.flex1_cd = 0,
          cr.flex2_cd = 0, cr.flex3_cd = 0, cr.flex4_cd = 0,
          cr.flex5_cd = 0, cr.updt_dt_tm = cnvtdatetime(curdate,curtime3), cr.updt_id = reqinfo->
          updt_id,
          cr.updt_task = reqinfo->updt_task, cr.updt_cnt = 0, cr.updt_applctx = reqinfo->updt_applctx
         WITH nocounter
        ;end insert
        IF (curqual=0)
         CALL bederror(concat("Unable to insert ",trim(request->activity_types[x].event_codes[y].
            display)," into the code_value_event_r table."))
        ENDIF
        IF ((request->activity_types[x].meaning="NURS"))
         SET dtaeventcode = request->activity_types[x].event_codes[y].event_code_value
        ELSE
         SET dtaeventcode = 0.0
        ENDIF
        CALL updatedtareltn(x,y)
        IF ((reply->event_codes[rep_cnt].event_set_code_value=0))
         SELECT INTO "nl:"
          FROM v500_event_set_code ve
          WHERE ve.event_set_name_key=trim(cnvtupper(cnvtalphanum(request->activity_types[x].
             event_codes[y].display)))
           AND trim(cnvtupper(ve.event_set_name))=trim(cnvtupper(request->activity_types[x].
            event_codes[y].display))
           AND  NOT ( EXISTS (
          (SELECT
           ves.parent_event_set_cd
           FROM v500_event_set_canon ves
           WHERE ves.parent_event_set_cd=ve.event_set_cd)))
          DETAIL
           reply->event_codes[rep_cnt].event_set_code_value = ve.event_set_cd
          WITH nocounter
         ;end select
        ENDIF
        IF ((reply->event_codes[rep_cnt].event_set_code_value > 0)
         AND explode_ind=0)
         SET stat = alterlist(temp_hier->event_hier,1)
         SET level = 0
         SET temp_hier->event_hier[1].code_value = reply->event_codes[rep_cnt].event_set_code_value
         SET temp_hier->event_hier[1].level = 0
         SET stat = alterlist(temp_sets->event_sets,1)
         SET temp_sets->event_sets[1].code_value = reply->event_codes[rep_cnt].event_set_code_value
         SET parent_ind = 1
         WHILE (parent_ind=1)
           SET ts_cnt = size(temp_sets->event_sets,5)
           SET level = (level+ 1)
           SET parent_ind = 0
           SELECT INTO "nl:"
            FROM (dummyt d  WITH seq = value(ts_cnt)),
             v500_event_set_canon vec
            PLAN (d)
             JOIN (vec
             WHERE (vec.event_set_cd=temp_sets->event_sets[d.seq].code_value))
            ORDER BY d.seq
            HEAD REPORT
             ts_cnt = 0, list_cnt = size(temp_hier->event_hier,5), tot_cnt = 0,
             stat = alterlist(temp_hier->event_hier,(list_cnt+ 10)), stat = alterlist(temp_sets->
              event_sets,10)
            DETAIL
             ts_cnt = (ts_cnt+ 1), list_cnt = (list_cnt+ 1), tot_cnt = (tot_cnt+ 1)
             IF (tot_cnt > 10)
              stat = alterlist(temp_hier->event_hier,(list_cnt+ 10)), stat = alterlist(temp_sets->
               event_sets,(ts_cnt+ 10)), tot_cnt = 1
             ENDIF
             temp_hier->event_hier[list_cnt].code_value = vec.parent_event_set_cd, temp_hier->
             event_hier[list_cnt].level = level, temp_sets->event_sets[ts_cnt].code_value = vec
             .parent_event_set_cd,
             parent_ind = 1
            FOOT REPORT
             stat = alterlist(temp_hier->event_hier,list_cnt), stat = alterlist(temp_sets->event_sets,
              ts_cnt)
            WITH nocounter
           ;end select
         ENDWHILE
         IF (size(temp_hier->event_hier,5) > 0)
          SELECT INTO "nl:"
           c = temp_hier->event_hier[d.seq].code_value, l = temp_hier->event_hier[d.seq].level
           FROM (dummyt d  WITH seq = size(temp_hier->event_hier,5))
           PLAN (d)
           ORDER BY c, l DESC
           HEAD REPORT
            list_cnt = 0, tot_cnt = 0, stat = alterlist(fin_temp_hier->event_hier,10)
           HEAD c
            list_cnt = (list_cnt+ 1), tot_cnt = (tot_cnt+ 1)
            IF (tot_cnt > 10)
             stat = alterlist(fin_temp_hier->event_hier,(list_cnt+ 10)), tot_cnt = 1
            ENDIF
            fin_temp_hier->event_hier[list_cnt].code_value = c, fin_temp_hier->event_hier[list_cnt].
            level = l
           FOOT REPORT
            stat = alterlist(fin_temp_hier->event_hier,list_cnt)
           WITH nocounter
          ;end select
         ENDIF
         FOR (e = 1 TO size(fin_temp_hier->event_hier,5))
          INSERT  FROM v500_event_set_explode vee
           SET vee.event_cd = request->activity_types[x].event_codes[y].event_code_value, vee
            .event_set_cd = fin_temp_hier->event_hier[e].code_value, vee.event_set_status_cd = 0.0,
            vee.event_set_level = fin_temp_hier->event_hier[e].level, vee.updt_dt_tm = cnvtdatetime(
             curdate,curtime3), vee.updt_id = reqinfo->updt_id,
            vee.updt_task = reqinfo->updt_task, vee.updt_cnt = 0, vee.updt_applctx = reqinfo->
            updt_applctx
           WITH nocounter
          ;end insert
          IF (curqual=0)
           CALL bederror(concat("Unable to insert ",request->activity_types[x].event_codes[y].display,
             " into the v500_event_set_explode table"))
          ENDIF
         ENDFOR
        ENDIF
       ELSEIF ((request->activity_types[x].event_codes[y].action_flag=2))
        UPDATE  FROM code_value cv
         SET cv.display = trim(substring(1,40,request->activity_types[x].event_codes[y].display)), cv
          .display_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->activity_types[x].
              event_codes[y].display)))), cv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
          cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo
          ->updt_applctx,
          cv.updt_cnt = (cv.updt_cnt+ 1)
         WHERE (cv.code_value=request->activity_types[x].event_codes[y].event_code_value)
         WITH nocounter
        ;end update
        IF (curqual=0)
         CALL bederror(concat("Unable to update ",trim(request->activity_types[x].event_codes[y].
            display)," into codeset 72."))
        ENDIF
        UPDATE  FROM v500_event_code vec
         SET vec.event_cd_disp = trim(substring(1,40,request->activity_types[x].event_codes[y].
            display)), vec.event_cd_disp_key = trim(cnvtupper(cnvtalphanum(substring(1,40,request->
              activity_types[x].event_codes[y].display)))), vec.updt_dt_tm = cnvtdatetime(curdate,
           curtime3),
          vec.updt_id = reqinfo->updt_id, vec.updt_task = reqinfo->updt_task, vec.updt_cnt = (vec
          .updt_cnt+ 1),
          vec.updt_applctx = reqinfo->updt_applctx
         WHERE (vec.event_cd=request->activity_types[x].event_codes[y].event_code_value)
         WITH nocounter
        ;end update
        IF (curqual=0)
         CALL bederror(concat("Unable to update ",trim(request->activity_types[x].event_codes[y].
            display)," on v500_event_code table."))
        ENDIF
       ENDIF
     ENDFOR
     IF ((request->activity_types[x].meaning="AP"))
      SET aps01_code_value = 0.0
      SELECT INTO "nl:"
       FROM code_value cv
       WHERE cv.code_set=73
        AND cv.cdf_meaning="APS01"
        AND cv.active_ind=1
       DETAIL
        aps01_code_value = cv.code_value
       WITH nocounter
      ;end select
      SET aps02_code_value = 0.0
      SELECT INTO "nl:"
       FROM code_value cv
       WHERE cv.code_set=73
        AND cv.cdf_meaning="APS02"
        AND cv.active_ind=1
       DETAIL
        aps02_code_value = cv.code_value
       WITH nocounter
      ;end select
      SET ap_code_value = 0.0
      SELECT INTO "nl:"
       FROM code_value cv
       WHERE cv.code_set=53
        AND cv.cdf_meaning="AP"
        AND cv.active_ind=1
       DETAIL
        ap_code_value = cv.code_value
       WITH nocounter
      ;end select
      SET doc_code_value = 0.0
      SELECT INTO "nl:"
       FROM code_value cv
       WHERE cv.code_set=53
        AND cv.cdf_meaning="DOC"
        AND cv.active_ind=1
       DETAIL
        doc_code_value = cv.code_value
       WITH nocounter
      ;end select
      SET stat = alterlist(temp_code->codes,2)
      SET temp_code->codes[1].event_class_cd = ap_code_value
      SET temp_code->codes[1].event_display = "Anatomic Pathology"
      SET temp_code->codes[1].event_set_name = "ANATOMPATH"
      SET temp_code->codes[1].parent_cd = aps01_code_value
      SET temp_code->codes[2].event_class_cd = doc_code_value
      SET temp_code->codes[2].event_display = "AP Imaging"
      SET temp_code->codes[2].event_set_name = "AP IMAGING"
      SET temp_code->codes[2].parent_cd = aps02_code_value
     ELSEIF ((request->activity_types[x].meaning="GLB"))
      SET unkwn_code_value = 0.0
      SELECT INTO "nl:"
       FROM code_value cv
       WHERE cv.code_set=53
        AND cv.cdf_meaning="UNKNOWN"
        AND cv.active_ind=1
       DETAIL
        unkwn_code_value = cv.code_value
       WITH nocounter
      ;end select
      SET lab_code_value = 0.0
      SELECT INTO "nl:"
       FROM code_value cv
       WHERE cv.code_set=73
        AND cv.cdf_meaning="LAB"
        AND cv.active_ind=1
       DETAIL
        lab_code_value = cv.code_value
       WITH nocounter
      ;end select
      SET stat = alterlist(temp_code->codes,1)
      SET temp_code->codes[1].event_class_cd = unkwn_code_value
      SET temp_code->codes[1].event_display = "LAB"
      SET temp_code->codes[1].event_set_name = fillstring(40," ")
      SET temp_code->codes[1].parent_cd = lab_code_value
     ELSEIF ((request->activity_types[x].meaning="RADIOLOGY"))
      SET mdoc_code_value = 0.0
      SELECT INTO "nl:"
       FROM code_value cv
       WHERE cv.code_set=53
        AND cv.cdf_meaning="MDOC"
        AND cv.active_ind=1
       DETAIL
        mdoc_code_value = cv.code_value
       WITH nocounter
      ;end select
      SET rad01_code_value = 0.0
      SELECT INTO "nl:"
       FROM code_value cv
       WHERE cv.code_set=73
        AND cv.cdf_meaning="RAD01"
        AND cv.active_ind=1
       DETAIL
        rad01_code_value = cv.code_value
       WITH nocounter
      ;end select
      SET stat = alterlist(temp_code->codes,1)
      SET temp_code->codes[1].event_class_cd = mdoc_code_value
      SET temp_code->codes[1].event_display = "RADRPT"
      SET temp_code->codes[1].event_set_name = "RADRPT"
      SET temp_code->codes[1].parent_cd = rad01_code_value
     ENDIF
     FOR (t = 1 TO size(temp_code->codes,5))
       SET exists_ind = 0
       SELECT INTO "nl:"
        FROM code_value_event_r cvr
        WHERE (cvr.parent_cd=temp_code->codes[t].parent_cd)
         AND cvr.flex1_cd=0
         AND cvr.flex2_cd=0
         AND cvr.flex3_cd=0
         AND cvr.flex4_cd=0
         AND cvr.flex5_cd=0
        DETAIL
         exists_ind = 1
        WITH nocounter
       ;end select
       IF (exists_ind=0)
        SET event_code_value = 0
        SELECT INTO "nl:"
         FROM v500_event_code v
         WHERE (v.event_set_name=temp_code->codes[t].event_set_name)
          AND (v.event_cd_disp=temp_code->codes[t].event_display)
         DETAIL
          event_code_value = v.event_cd
         WITH nocounter
        ;end select
        IF (event_code_value=0)
         SET dup_event_code_value = 0.0
         DECLARE dup_event_code_disp = vc
         SELECT INTO "nl:"
          FROM code_value cv
          WHERE cv.code_set=72
           AND cv.display_key=trim(cnvtupper(cnvtalphanum(substring(1,40,temp_code->codes[t].
              event_display))))
           AND cv.display=trim(cnvtupper(temp_code->codes[t].event_display))
          DETAIL
           dup_event_code_value = cv.code_value, dup_event_code_disp = cv.display
          WITH nocounter
         ;end select
         IF (dup_event_code_value=0)
          SET new_cv = 0.0
          SELECT INTO "NL:"
           j = seq(reference_seq,nextval)"##################;rp0"
           FROM dual
           DETAIL
            new_cv = cnvtreal(j)
           WITH format, counter
          ;end select
          INSERT  FROM code_value cv
           SET cv.code_value = new_cv, cv.code_set = 72, cv.cdf_meaning = null,
            cv.display = trim(substring(1,40,temp_code->codes[t].event_display)), cv.display_key =
            trim(cnvtupper(cnvtalphanum(substring(1,40,temp_code->codes[t].event_display)))), cv
            .description = trim(substring(1,60,temp_code->codes[t].event_display)),
            cv.definition = trim(substring(1,100,temp_code->codes[t].event_display)), cv
            .collation_seq = 1, cv.active_type_cd = active_status_code_value,
            cv.active_ind = 1, cv.active_dt_tm = cnvtdatetime(curdate,curtime3), cv.inactive_dt_tm =
            null,
            cv.updt_dt_tm = cnvtdatetime(curdate,curtime3), cv.updt_id = reqinfo->updt_id, cv
            .updt_task = reqinfo->updt_task,
            cv.updt_applctx = reqinfo->updt_applctx, cv.updt_cnt = 0, cv.begin_effective_dt_tm =
            cnvtdatetime(curdate,curtime3),
            cv.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), cv.data_status_cd = auth_code_value,
            cv.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
            cv.cki = null, cv.display_key_nls = null, cv.concept_cki = ""
           WITH nocounter
          ;end insert
          IF (curqual=0)
           CALL bederror(concat("Unable to insert ",trim(temp_code->codes[t].event_display),
             " into codeset 72."))
          ENDIF
          SET event_code_value = new_cv
          INSERT  FROM v500_event_code vec
           SET vec.event_cd = event_code_value, vec.event_cd_definition = trim(substring(1,100,
              temp_code->codes[t].event_display)), vec.event_cd_descr = trim(substring(1,60,temp_code
              ->codes[t].event_display)),
            vec.event_cd_disp = trim(substring(1,40,temp_code->codes[t].event_display)), vec
            .event_cd_disp_key = trim(cnvtupper(cnvtalphanum(substring(1,40,temp_code->codes[t].
                event_display)))), vec.code_status_cd = active_status_code_value,
            vec.def_docmnt_attributes = null, vec.def_docmnt_format_cd = def_frmt_code_value, vec
            .def_docmnt_storage_cd = def_store_code_value,
            vec.def_event_class_cd = temp_code->codes[t].event_class_cd, vec
            .def_event_confid_level_cd = def_confid_lvl_code_value, vec.def_event_level = null,
            vec.event_add_access_ind = 0.0, vec.event_cd_subclass_cd = subclass_code_value, vec
            .event_chg_access_ind = 0,
            vec.event_set_name = trim(substring(1,40,temp_code->codes[t].event_set_name)), vec
            .retention_days = null, vec.updt_dt_tm = cnvtdatetime(curdate,curtime3),
            vec.updt_id = reqinfo->updt_id, vec.updt_task = reqinfo->updt_task, vec.updt_cnt = 0,
            vec.updt_applctx = reqinfo->updt_applctx, vec.event_code_status_cd = auth_code_value, vec
            .collating_seq = 0.0
           WITH nocounter
          ;end insert
          IF (curqual=0)
           CALL bederror(concat("Unable to insert ",trim(temp_code->codes[t].event_display),
             " into v500_event_code table."))
          ENDIF
         ELSEIF (dup_event_code_value > 0)
          SET dup_event_cnt = (dup_event_cnt+ 1)
          SET dup_event_tcnt = (dup_event_tcnt+ 1)
          IF (dup_event_tcnt > 10)
           SET stat = alterlist(reply->auto_gen_dups,(dup_event_cnt+ 10))
           SET dup_event_tcnt = 1
          ENDIF
          SET reply->auto_gen_dups[dup_event_cnt].dup_code_value = dup_event_code_value
          SET reply->auto_gen_dups[dup_event_cnt].dup_display = dup_event_code_disp
          SET reply->auto_gen_dups[dup_event_cnt].auto_display = temp_code->codes[t].event_display
         ENDIF
        ENDIF
        IF (event_code_value > 0)
         INSERT  FROM code_value_event_r cr
          SET cr.event_cd = event_code_value, cr.parent_cd = temp_code->codes[t].parent_cd, cr
           .flex1_cd = 0,
           cr.flex2_cd = 0, cr.flex3_cd = 0, cr.flex4_cd = 0,
           cr.flex5_cd = 0, cr.updt_dt_tm = cnvtdatetime(curdate,curtime3), cr.updt_id = reqinfo->
           updt_id,
           cr.updt_task = reqinfo->updt_task, cr.updt_cnt = 0, cr.updt_applctx = reqinfo->
           updt_applctx
          WITH nocounter
         ;end insert
         IF (curqual=0)
          CALL bederror(concat("Unable to insert ",trim(temp_code->codes.event_display),
            " into the code_value_event_r table."))
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   SET stat = alterlist(reply->event_codes,rep_cnt)
   SET stat = alterlist(reply->auto_gen_dups,dup_event_cnt)
   CALL bederrorcheck("Failed to ensure event codes.")
   CALL bedlogmessage("ensureEventCodes","Exiting...")
 END ;Subroutine
 SUBROUTINE updatedtareltn(atx,ecy)
   CALL bedlogmessage("updateDtaReltn","Entering...")
   IF (dtaeventcode > 0.0)
    UPDATE  FROM discrete_task_assay dta
     SET dta.event_cd = dtaeventcode, dta.updt_applctx = reqinfo->updt_applctx, dta.updt_cnt = (dta
      .updt_cnt+ 1),
      dta.updt_dt_tm = cnvtdatetime(curdate,curtime3), dta.updt_id = reqinfo->updt_id, dta.updt_task
       = reqinfo->updt_task
     WHERE (dta.task_assay_cd=request->activity_types[atx].event_codes[ecy].assay_code_value)
     WITH nocounter
    ;end update
   ENDIF
   CALL bederrorcheck("Error updating dta relations")
   CALL bedlogmessage("updateDtaReltn","Exiting...")
 END ;Subroutine
#exit_script
 CALL bedexitscript(1)
END GO
