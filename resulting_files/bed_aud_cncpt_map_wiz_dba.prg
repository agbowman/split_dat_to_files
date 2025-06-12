CREATE PROGRAM bed_aud_cncpt_map_wiz:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
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
 IF ( NOT (validate(relatedcodesets,0)))
  FREE RECORD relatedcodesets
  RECORD relatedcodesets(
    1 codesets[*]
      2 codeset = i4
  ) WITH protect
 ENDIF
 IF ( NOT (validate(identtosave,0)))
  FREE RECORD identtosave
  RECORD identtosave(
    1 code_set = i4
    1 display = vc
    1 parseidentifierstring = vc
    1 identifier = vc
    1 code_value = f8
    1 definition = vc
    1 activity_type_cd = f8
  ) WITH protect
 ENDIF
 DECLARE isrelatedcodeset(codeset=i4) = i2
 DECLARE geteventcodefromeventset(request=vc(ref),eventcodesreply=vc(ref)) = null
 DECLARE geteventsetfromeventcode(request=vc(ref),eventsetreply=vc(ref)) = null
 DECLARE geteventcodefromdta(request=vc(ref),eventcodesreplyfromdta=vc(ref)) = null
 DECLARE getdtafromeventcode(request=vc(ref),dtacodesreply=vc(ref)) = null
 DECLARE getcodevaluefromdisplayandcodeset(display=vc,codeset=i4,definition=vc) = f8
 DECLARE getordersfromorderscatalog(request=vc(ref),ordersreply=vc(ref)) = null
 DECLARE getordersfromcodeset200(request=vc(ref),ordersreply=vc(ref)) = null
 DECLARE geteventsetcodefromeventsetname(eventsetname=vc) = f8
 DECLARE gettaskassaycdfrommnemonicandacvitytype(mnemonic=vc,activitytypecd=f8) = f8
 DECLARE geteventsetcdfromeventsetname(esc_parse=vc,identifiertype=vc,eventsetcodesreply=vc(ref)) =
 null
 DECLARE geteventsetcdfromidentifier(esc_parse=vc,identifiertype=vc,eventsetcodesreply=vc(ref)) =
 null
 DECLARE getdtacdfrommnemonic(dta_parse=vc,identifiertype=vc,dtacodesreply=vc(ref)) = null
 DECLARE getdtacdfromidentifier(dta_parse=vc,identifiertype=vc,dtacodesreply=vc(ref)) = null
 DECLARE getmnemonicfromtaskassaycode(taskassaycd=f8) = vc
 DECLARE getactivitytypecodefromtaskassaycode(taskassaycd=f8) = f8
 DECLARE getdisplayfromcodevalue(codevalue=f8) = vc
 DECLARE getdefinitionfromcodevalue(codevalue=f8) = vc
 DECLARE getdescriptionfromcodevalue(codevalue=f8) = vc
 DECLARE getconceptckifromcodevalue(codevalue=f8) = vc
 DECLARE getcodesetfromcodevalue(codevalue=f8) = i4
 DECLARE updatecodevalueidentifiers(identtosave=vc(ref)) = null
 DECLARE updateordercatalogidentifiers(identtosave=vc(ref)) = null
 DECLARE updatenomenclatureidentifiers(identtosave=vc(ref)) = null
 DECLARE updateordercatalogsynonymtable(identtosave=vc(ref)) = null
 DECLARE updateckiintocvtableforcodeset200(identtosave=vc(ref)) = null
 DECLARE updatedtatable(identtosave=vc(ref)) = null
 DECLARE eventsetnamecnt = i4 WITH protect, noconstant(0)
 DECLARE parseidentifierstring = vc WITH protect, noconstant("")
 DECLARE parsecodesetstring = vc WITH protect, noconstant("")
 DECLARE matchescnt = i4 WITH protect, noconstant(0)
 DECLARE principle_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",401,"ALPHA RESPON"))
 DECLARE patient_care_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",400,"PTCARE"))
 DECLARE primary_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 SUBROUTINE isrelatedcodeset(codeset)
   CALL bedlogmessage("isRelatedCodeSet","Entering ...")
   IF (codeset=72)
    SET stat = alterlist(relatedcodesets->codesets,2)
    SET relatedcodesets->codesets[1].codeset = 93
    SET relatedcodesets->codesets[2].codeset = 14003
   ELSEIF (codeset=93)
    SET stat = alterlist(relatedcodesets->codesets,2)
    SET relatedcodesets->codesets[1].codeset = 72
    SET relatedcodesets->codesets[2].codeset = 14003
   ELSEIF (codeset=14003)
    SET stat = alterlist(relatedcodesets->codesets,2)
    SET relatedcodesets->codesets[1].codeset = 72
    SET relatedcodesets->codesets[2].codeset = 93
   ENDIF
   IF (validate(debug,0)=1)
    CALL echorecord(relatedcodesets)
   ENDIF
   IF (size(relatedcodesets->codesets,5) > 0)
    RETURN(true)
   ENDIF
   CALL bedlogmessage("isRelatedCodeSet","Exiting ...")
   RETURN(false)
 END ;Subroutine
 SUBROUTINE geteventcodefromeventset(request,eventcodesreply)
   CALL bedlogmessage("getEventCodeFromEventSet","Entering ...")
   DECLARE check = i4 WITH protect, noconstant(0)
   DECLARE count = i4 WITH protect, noconstant(0)
   DECLARE eventsetnamecnt = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   FOR (eventsetnamecnt = 1 TO size(request->event_sets,5))
     IF (textlen(trim(request->event_sets[eventsetnamecnt].event_set_name))=0)
      CALL bederror("Must Provide Event Set Name.")
     ENDIF
     SELECT INTO "nl:"
      FROM v500_event_set_code es,
       v500_event_set_explode ex,
       code_value v
      PLAN (es
       WHERE cnvtupper(es.event_set_name)=cnvtupper(request->event_sets[eventsetnamecnt].
        event_set_name))
       JOIN (ex
       WHERE ex.event_set_cd=es.event_set_cd
        AND ex.event_set_level=0)
       JOIN (v
       WHERE v.code_value=ex.event_cd
        AND v.active_ind=1)
      ORDER BY v.code_value
      HEAD REPORT
       cnt = 0, tcnt = 0, stat = alterlist(eventcodesreply->eventcodereplystructure,eventsetnamecnt)
      HEAD v.code_value
       check = locateval(idx,1,size(request->event_codes,5),v.code_value,request->event_codes[idx].
        code_value)
       IF (check=0)
        count = (size(request->event_codes,5)+ 1), stat = alterlist(request->event_codes,count),
        request->event_codes[count].code_value = v.code_value,
        request->event_codes[count].concept_cki = request->event_sets[eventsetnamecnt].concept_cki,
        request->event_codes[count].display = request->event_sets[eventsetnamecnt].display, request->
        event_codes[count].requested_code = es.event_set_cd
       ENDIF
       cnt = (cnt+ 1), tcnt = (tcnt+ 1)
       IF (cnt > size(eventcodesreply->eventcodereplystructure[eventsetnamecnt].event_codes,5))
        stat = alterlist(eventcodesreply->eventcodereplystructure[eventsetnamecnt].event_codes,(tcnt
         + 100)), cnt = 1
       ENDIF
       eventcodesreply->eventcodereplystructure[eventsetnamecnt].event_set_name = es.event_set_name,
       eventcodesreply->eventcodereplystructure[eventsetnamecnt].event_codes[tcnt].code_value = v
       .code_value, eventcodesreply->eventcodereplystructure[eventsetnamecnt].event_codes[tcnt].
       description = v.description,
       eventcodesreply->eventcodereplystructure[eventsetnamecnt].event_codes[tcnt].display = v
       .display, eventcodesreply->eventcodereplystructure[eventsetnamecnt].event_codes[tcnt].
       definition = v.definition, eventcodesreply->eventcodereplystructure[eventsetnamecnt].
       event_codes[tcnt].identifier = request->event_sets[eventsetnamecnt].concept_cki
       IF (trim(v.concept_cki)=trim(request->event_sets[eventsetnamecnt].concept_cki))
        eventcodesreply->eventcodereplystructure[eventsetnamecnt].event_codes[tcnt].concept_cki_ind
         = 1
       ELSEIF (trim(v.concept_cki)="")
        eventcodesreply->eventcodereplystructure[eventsetnamecnt].event_codes[tcnt].concept_cki_ind
         = 0
       ELSE
        eventcodesreply->eventcodereplystructure[eventsetnamecnt].event_codes[tcnt].concept_cki_ind
         = 2
       ENDIF
      FOOT REPORT
       stat = alterlist(eventcodesreply->eventcodereplystructure[eventsetnamecnt].event_codes,tcnt)
      WITH nocounter
     ;end select
     CALL bederrorcheck("Error getting codes")
   ENDFOR
   IF (validate(debug,0)=1)
    CALL echorecord(eventcodesreply)
   ENDIF
   CALL bedlogmessage("getEventCodeFromEventSet","Exiting ...")
 END ;Subroutine
 SUBROUTINE geteventsetfromeventcode(request,eventsetreply)
   CALL bedlogmessage("getEventSetFromEventCode","Entering ...")
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE count = i4 WITH protect, noconstant(0)
   FOR (index = 1 TO size(request->event_codes,5))
     SELECT INTO "nl:"
      FROM v500_event_set_explode ex,
       v500_event_set_code es,
       code_value cv
      PLAN (ex
       WHERE (ex.event_cd=request->event_codes[index].code_value)
        AND ex.event_set_level=0)
       JOIN (es
       WHERE es.event_set_cd=ex.event_set_cd)
       JOIN (cv
       WHERE cv.code_value=es.event_set_cd
        AND cv.code_value > 0
        AND cv.active_ind=1)
      DETAIL
       count = (size(eventsetreply->event_set_reltns,5)+ 1), stat = alterlist(eventsetreply->
        event_set_reltns,count), eventsetreply->event_set_reltns[count].code_value = ex.event_cd,
       eventsetreply->event_set_reltns[count].display = es.event_set_name, eventsetreply->
       event_set_reltns[count].identifier = request->event_codes[index].concept_cki, eventsetreply->
       event_set_reltns[count].event_set_cd = es.event_set_cd,
       eventsetreply->event_set_reltns[count].definition = cv.definition
       IF (trim(cv.concept_cki)=trim(request->event_codes[index].concept_cki))
        eventsetreply->event_set_reltns[count].concept_cki_ind = 1
       ELSEIF (trim(cv.concept_cki)="")
        eventsetreply->event_set_reltns[count].concept_cki_ind = 0
       ELSE
        eventsetreply->event_set_reltns[count].concept_cki_ind = 2
       ENDIF
      WITH check
     ;end select
   ENDFOR
   IF (validate(debug,0)=1)
    CALL echorecord(eventsetreply)
   ENDIF
   CALL bedlogmessage("getEventSetFromEventCode","Exiting ...")
 END ;Subroutine
 SUBROUTINE geteventcodefromdta(request,eventcodesreplyfromdta)
   CALL bedlogmessage("getEventCodeFromDTA","Entering ...")
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE count = i4 WITH protect, noconstant(0)
   DECLARE check = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE event_cd = f8 WITH protect, noconstant(0.0)
   DECLARE concept_cki = vc WITH protect, noconstant("")
   DECLARE display = vc WITH protect, noconstant("")
   DECLARE definition = vc WITH protect, noconstant("")
   FOR (index = 1 TO size(request->dtas,5))
     SELECT INTO "nl:"
      FROM code_value cv,
       discrete_task_assay dta,
       code_value_event_r cver,
       code_value cv2,
       code_value cv3
      PLAN (cv
       WHERE (cv.code_value=request->dtas[index].code_value)
        AND cv.code_value > 0)
       JOIN (dta
       WHERE dta.task_assay_cd=outerjoin(cv.code_value))
       JOIN (cver
       WHERE cver.parent_cd=outerjoin(cv.code_value)
        AND cver.flex1_cd=outerjoin(0.0))
       JOIN (cv2
       WHERE cv2.code_value=outerjoin(dta.event_cd))
       JOIN (cv3
       WHERE cv3.code_value=outerjoin(cver.event_cd))
      DETAIL
       IF (dta.event_cd > 0)
        event_cd = dta.event_cd, concept_cki = cv2.concept_cki, display = cv2.display,
        definition = cv2.definition
       ELSEIF (cver.event_cd > 0)
        event_cd = cver.event_cd, concept_cki = cv3.concept_cki, display = cv3.display,
        definition = cv3.definition
       ELSE
        event_cd = 0.0, concept_cki = "", display = ""
       ENDIF
       IF (event_cd > 0.0)
        check = locateval(idx,1,size(request->event_codes,5),event_cd,request->event_codes[idx].
         code_value)
        IF (check=0)
         count = (size(request->event_codes,5)+ 1), stat = alterlist(request->event_codes,count),
         request->event_codes[count].code_value = event_cd,
         request->event_codes[count].concept_cki = request->dtas[index].concept_cki, request->
         event_codes[count].display = request->dtas[index].display, request->event_codes[count].
         requested_code = request->dtas[index].code_value
        ENDIF
        count = (size(eventcodesreplyfromdta->event_codes,5)+ 1), stat = alterlist(
         eventcodesreplyfromdta->event_codes,count), eventcodesreplyfromdta->event_codes[count].
        code_value = request->dtas[index].code_value,
        eventcodesreplyfromdta->event_codes[count].display = display, eventcodesreplyfromdta->
        event_codes[count].identifier = request->dtas[index].concept_cki, eventcodesreplyfromdta->
        event_codes[count].definition = definition,
        eventcodesreplyfromdta->event_codes[count].event_cd = event_cd
        IF (trim(concept_cki)=trim(request->dtas[index].concept_cki))
         eventcodesreplyfromdta->event_codes[count].concept_cki_ind = 1
        ELSEIF (trim(concept_cki)="")
         eventcodesreplyfromdta->event_codes[count].concept_cki_ind = 0
        ELSE
         eventcodesreplyfromdta->event_codes[count].concept_cki_ind = 2
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
   ENDFOR
   IF (validate(debug,0)=1)
    CALL echorecord(eventcodesreplyfromdta)
   ENDIF
   CALL bedlogmessage("getEventCodeFromDTA","Exiting ...")
 END ;Subroutine
 SUBROUTINE getdtafromeventcode(request,dtacodesreply)
   CALL bedlogmessage("getDTAFromEventCode","Entering ...")
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE task_assay_cd = f8 WITH protect, noconstant(0.0)
   DECLARE concept_cki = vc WITH protect, noconstant("")
   DECLARE display = vc WITH protect, noconstant("")
   DECLARE definition = vc WITH protect, noconstant("")
   FOR (index = 1 TO size(request->event_codes,5))
     SELECT INTO "nl:"
      FROM code_value cv,
       discrete_task_assay dta,
       code_value_event_r cver,
       code_value cv2,
       code_value cv3,
       discrete_task_assay dta2
      PLAN (cv
       WHERE (cv.code_value=request->event_codes[index].code_value)
        AND cv.code_value > 0)
       JOIN (dta
       WHERE dta.event_cd=outerjoin(cv.code_value))
       JOIN (cver
       WHERE cver.event_cd=outerjoin(cv.code_value)
        AND cver.flex1_cd=outerjoin(0.0))
       JOIN (cv2
       WHERE cv2.code_value=outerjoin(dta.task_assay_cd))
       JOIN (cv3
       WHERE cv3.code_value=outerjoin(cver.parent_cd)
        AND cv3.code_set=outerjoin(14003))
       JOIN (dta2
       WHERE dta2.task_assay_cd=outerjoin(cv3.code_value))
      DETAIL
       IF (dta.task_assay_cd > 0)
        task_assay_cd = dta.task_assay_cd, concept_cki = cv2.concept_cki, display = dta.mnemonic,
        definition = cv2.definition
       ELSEIF (cv3.code_value > 0)
        task_assay_cd = cv3.code_value, concept_cki = cv3.concept_cki, display = dta2.mnemonic,
        definition = cv3.definition
       ELSE
        task_assay_cd = 0.0, concept_cki = "", display = "",
        definition = ""
       ENDIF
       IF (task_assay_cd > 0)
        count = (size(dtacodesreply->dta_code_reltns,5)+ 1), stat = alterlist(dtacodesreply->
         dta_code_reltns,count), dtacodesreply->dta_code_reltns[count].code_value = request->
        event_codes[index].code_value,
        dtacodesreply->dta_code_reltns[count].display = display, dtacodesreply->dta_code_reltns[count
        ].identifier = request->event_codes[index].concept_cki, dtacodesreply->dta_code_reltns[count]
        .task_assay_cd = task_assay_cd,
        dtacodesreply->dta_code_reltns[count].definition = definition
        IF (trim(concept_cki)=trim(request->event_codes[index].concept_cki))
         dtacodesreply->dta_code_reltns[count].concept_cki_ind = 1
        ELSEIF (trim(concept_cki)="")
         dtacodesreply->dta_code_reltns[count].concept_cki_ind = 0
        ELSE
         dtacodesreply->dta_code_reltns[count].concept_cki_ind = 2
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
   ENDFOR
   IF (validate(debug,0)=1)
    CALL echorecord(dtacodesreply)
   ENDIF
   CALL bedlogmessage("getDTAFromEventCode","Exiting ...")
 END ;Subroutine
 SUBROUTINE getcodevaluefromdisplayandcodeset(display,codeset,definition)
   CALL bedlogmessage("getCodeValueFromDisplayAndCodeset","Entering ...")
   CALL logdebugmessage("Display:",display)
   CALL logdebugmessage("Codeset:",codeset)
   CALL logdebugmessage("Definition:",definition)
   DECLARE codevalue = f8 WITH protect, noconstant(0.0)
   DECLARE cvparse = vc WITH protect, noconstant(
    "cv.active_ind = 1 and cv.code_value > 0 and cv.code_set = ")
   SET cvparse = build2(cvparse,codeset)
   IF (codeset=72)
    SET cvparse = concat(cvparse,' and cv.display = "',display,'" ')
    SET cvparse = concat(cvparse,' and cv.definition = "',definition,'" ')
   ELSE
    SET cvparse = concat(cvparse,' and cv.display = "',display,'" ')
   ENDIF
   CALL logdebugmessage("cvParse:",cvparse)
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE parser(cvparse))
    DETAIL
     codevalue = cv.code_value
    WITH check
   ;end select
   CALL logdebugmessage("Code Value:",codevalue)
   CALL bedlogmessage("getCodeValueFromDisplayAndCodeset","Exiting ...")
   RETURN(codevalue)
 END ;Subroutine
 SUBROUTINE getordersfromorderscatalog(request,ordersreply)
   CALL bedlogmessage("getOrdersFromOrdersCatalog","Entering ...")
   DECLARE orderoccnt = i4 WITH protect, noconstant(0)
   DECLARE reqordersoccnt = i4 WITH protect, noconstant(0)
   FOR (orderoccnt = 1 TO size(request->order_codes,5))
     SELECT INTO "nl:"
      FROM order_catalog oc
      PLAN (oc
       WHERE oc.active_ind=1
        AND (oc.catalog_cd=request->order_codes[orderoccnt].code_value))
      DETAIL
       reqordersoccnt = (size(ordersreply->orders,5)+ 1), stat = alterlist(ordersreply->orders,
        reqordersoccnt), ordersreply->orders[reqordersoccnt].identifier = oc.concept_cki,
       ordersreply->orders[reqordersoccnt].code_value = oc.catalog_cd
       IF (trim(oc.concept_cki)=trim(request->order_codes[orderoccnt].concept_cki))
        ordersreply->orders[reqordersoccnt].concept_cki_ind = 1
       ELSEIF (trim(oc.concept_cki)="")
        ordersreply->orders[reqordersoccnt].concept_cki_ind = 0
       ELSE
        ordersreply->orders[reqordersoccnt].concept_cki_ind = 2
       ENDIF
       ordersreply->orders[reqordersoccnt].display = oc.primary_mnemonic
      WITH check
     ;end select
   ENDFOR
   IF (validate(debug,0)=1)
    CALL echorecord(ordersreply)
   ENDIF
   CALL bedlogmessage("getOrdersFromOrdersCatalog","Exiting ...")
 END ;Subroutine
 SUBROUTINE getordersfromcodeset200(request,ordersreply)
   CALL bedlogmessage("getOrdersFromCodeset200","Entering ...")
   DECLARE ordercvcnt = i4 WITH protect, noconstant(0)
   DECLARE reqorderscvcnt = i4 WITH protect, noconstant(0)
   FOR (ordercvcnt = 1 TO size(request->order_catalogs,5))
     SELECT INTO "nl:"
      FROM code_value cv
      PLAN (cv
       WHERE cv.active_ind=1
        AND cv.code_set=200
        AND (cv.code_value=request->order_catalogs[ordercvcnt].catalog_cd))
      DETAIL
       reqorderscvcnt = (size(ordersreply->orders,5)+ 1), stat = alterlist(ordersreply->orders,
        reqorderscvcnt), ordersreply->orders[reqorderscvcnt].code_value = cv.code_value,
       ordersreply->orders[reqorderscvcnt].identifier = cv.concept_cki
       IF (trim(cv.concept_cki)=trim(request->order_catalogs[ordercvcnt].concept_cki))
        ordersreply->orders[reqorderscvcnt].concept_cki_ind = 1
       ELSEIF (trim(cv.concept_cki)="")
        ordersreply->orders[reqorderscvcnt].concept_cki_ind = 0
       ELSE
        ordersreply->orders[reqorderscvcnt].concept_cki_ind = 2
       ENDIF
       ordersreply->orders[reqorderscvcnt].display = cv.display
      WITH check
     ;end select
   ENDFOR
   IF (validate(debug,0)=1)
    CALL echorecord(ordersreply)
   ENDIF
   CALL bedlogmessage("getOrdersFromCodeset200","Exiting ...")
 END ;Subroutine
 SUBROUTINE updatecodevalueidentifiers(identtosave)
   CALL bedlogmessage("updateCodeValueIdentifiers","Entering ...")
   IF ((identtosave->code_set=200)
    AND (identtosave->parseidentifierstring="concept_cki"))
    UPDATE  FROM code_value cv
     SET parser(build2("cv.",identtosave->parseidentifierstring)) = identtosave->identifier, cv
      .updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->
      updt_applctx
     WHERE (cv.code_set=identtosave->code_set)
      AND (cv.display=identtosave->display)
      AND cv.active_ind=1
      AND cv.code_value > 0
     WITH nocounter
    ;end update
    CALL echo(curqual)
    UPDATE  FROM order_catalog oc
     SET parser(build2("oc.",identtosave->parseidentifierstring)) = identtosave->identifier, oc
      .updt_cnt = (oc.updt_cnt+ 1), oc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      oc.updt_id = reqinfo->updt_id, oc.updt_task = reqinfo->updt_task, oc.updt_applctx = reqinfo->
      updt_applctx
     WHERE (oc.catalog_cd=
     (SELECT
      cv.code_value
      FROM code_value cv
      WHERE (cv.display=identtosave->display)
       AND cv.code_set=200))
      AND oc.active_ind=1
     WITH nocounter
    ;end update
    CALL echo(curqual)
    CALL updateordercatalogsynonymtable(identtosave)
   ELSE
    DECLARE cv_parse = vc WITH protect, noconstant(
     "cv.active_ind = 1 and cv.code_value > 0 and cv.code_set = ")
    SET cv_parse = build2(cv_parse,identtosave->code_set)
    IF ((identtosave->code_value > 0.0))
     SET cv_parse = build2(cv_parse," and cv.code_value = ",identtosave->code_value)
    ELSEIF ((identtosave->code_set=72))
     SET cv_parse = concat(cv_parse,' and cv.display = "',identtosave->display,'" ')
     SET cv_parse = concat(cv_parse,' and cv.definition = "',identtosave->definition,'" ')
    ELSE
     SET cv_parse = concat(cv_parse,' and cv.display = "',identtosave->display,'" ')
    ENDIF
    CALL logdebugmessage("cv_parse:",cv_parse)
    UPDATE  FROM code_value cv
     SET parser(build2("cv.",identtosave->parseidentifierstring)) = identtosave->identifier, cv
      .updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->
      updt_applctx
     WHERE parser(cv_parse)
     WITH nocounter
    ;end update
    IF ((identtosave->code_set=14003)
     AND (identtosave->parseidentifierstring="concept_cki"))
     CALL updatedtatable(identtosave)
    ENDIF
   ENDIF
   CALL bedlogmessage("updateCodeValueIdentifiers","Exiting...")
 END ;Subroutine
 SUBROUTINE updateordercatalogidentifiers(identtosave)
   CALL bedlogmessage("updateOrderCatalogIdentifiers","Entering ...")
   IF ((identtosave->parseidentifierstring="concept_cki"))
    UPDATE  FROM order_catalog oc
     SET parser(build2("oc.",identtosave->parseidentifierstring)) = identtosave->identifier, oc
      .updt_cnt = (oc.updt_cnt+ 1), oc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      oc.updt_id = reqinfo->updt_id, oc.updt_task = reqinfo->updt_task, oc.updt_applctx = reqinfo->
      updt_applctx
     WHERE (oc.primary_mnemonic=identtosave->display)
      AND oc.active_ind=1
     WITH nocounter
    ;end update
    UPDATE  FROM code_value cv
     SET parser(build2("cv.",identtosave->parseidentifierstring)) = identtosave->identifier, cv
      .updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->
      updt_applctx
     WHERE (cv.code_value=
     (SELECT
      oc.catalog_cd
      FROM order_catalog oc
      WHERE (oc.primary_mnemonic=identtosave->display)))
      AND cv.active_ind=1
      AND cv.code_value > 0
     WITH nocounter
    ;end update
   ELSE
    UPDATE  FROM order_catalog oc
     SET parser(build2("oc.",identtosave->parseidentifierstring)) = identtosave->identifier, oc
      .updt_cnt = (oc.updt_cnt+ 1), oc.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      oc.updt_id = reqinfo->updt_id, oc.updt_task = reqinfo->updt_task, oc.updt_applctx = reqinfo->
      updt_applctx
     WHERE (oc.primary_mnemonic=identtosave->display)
      AND oc.active_ind=1
     WITH nocounter
    ;end update
    CALL updateckiintocvtableforcodeset200(identtosave)
   ENDIF
   CALL updateordercatalogsynonymtable(identtosave)
   CALL bedlogmessage("updateOrderCatalogIdentifiers","Exiting ...")
 END ;Subroutine
 SUBROUTINE updatenomenclatureidentifiers(identtosave)
   CALL bedlogmessage("updateNomenclatureIdentifiers","Entering ...")
   UPDATE  FROM nomenclature n
    SET n.concept_cki = identtosave->identifier, n.updt_cnt = (n.updt_cnt+ 1), n.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->updt_task, n.updt_applctx = reqinfo->
     updt_applctx
    WHERE n.source_string_keycap=cnvtupper(identtosave->display)
     AND n.principle_type_cd=principle_type_cd
     AND n.source_vocabulary_cd=patient_care_cd
     AND n.active_ind=1
    WITH nocounter
   ;end update
   CALL bedlogmessage("updateNomenclatureIdentifiers","Exiting ...")
 END ;Subroutine
 SUBROUTINE updateordercatalogsynonymtable(identtosave)
   CALL bedlogmessage("updateOrderCatalogSynonymTable","Entering ...")
   UPDATE  FROM order_catalog_synonym ocs
    SET parser(build2("ocs.",identtosave->parseidentifierstring)) = identtosave->identifier, ocs
     .updt_dt_tm = cnvtdatetime(curdate,curtime3), ocs.updt_cnt = (ocs.updt_cnt+ 1),
     ocs.updt_id = reqinfo->updt_id, ocs.updt_task = reqinfo->updt_task, ocs.updt_applctx = reqinfo->
     updt_applctx
    WHERE (ocs.catalog_cd=
    (SELECT
     oc.catalog_cd
     FROM order_catalog oc
     WHERE (oc.primary_mnemonic=identtosave->display)
      AND oc.active_ind=1))
     AND ocs.mnemonic_type_cd=primary_cd
    WITH nocounter
   ;end update
   CALL bedlogmessage("updateOrderCatalogSynonymTable","Exiting ...")
 END ;Subroutine
 SUBROUTINE updatedtatable(identtosave)
   CALL bedlogmessage("updateDTATable","Entering ...")
   UPDATE  FROM discrete_task_assay dta
    SET parser(build2("dta.",identtosave->parseidentifierstring)) = identtosave->identifier, dta
     .updt_dt_tm = cnvtdatetime(curdate,curtime3), dta.updt_cnt = (dta.updt_cnt+ 1),
     dta.updt_id = reqinfo->updt_id, dta.updt_task = reqinfo->updt_task, dta.updt_applctx = reqinfo->
     updt_applctx
    WHERE (dta.task_assay_cd=
    (SELECT
     cv.code_value
     FROM code_value cv
     WHERE (cv.display=identtosave->display)
      AND cv.code_set=14003))
    WITH nocounter
   ;end update
   CALL bedlogmessage("updateDTATable","Exiting ...")
 END ;Subroutine
 SUBROUTINE updateckiintocvtableforcodeset200(identtosave)
   CALL bedlogmessage("updateCKIintoCVtableforCodeSet200","Entering ...")
   DECLARE skip_cv = i4 WITH protect, noconstant(0)
   SET skip_cv = 0
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE (parser(build2("cv.",identtosave->parseidentifierstring))=identtosave->identifier)
      AND ((cv.code_set=200) OR (cv.code_set IN (54, 4001, 4002, 4003, 29741))) )
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET skip_cv = 1
    CALL bedlogmessage("updateCKIintoCVtableforCodeSet200","skipping code_value update ...")
   ENDIF
   IF (skip_cv=0)
    CALL bedlogmessage("updateCKIintoCVtableforCodeSet200","updating code_value table ...")
    UPDATE  FROM code_value cv
     SET parser(build2("cv.",identtosave->parseidentifierstring)) = identtosave->identifier, cv
      .updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->
      updt_applctx
     WHERE cv.code_set=200
      AND (cv.display=identtosave->display)
      AND cv.active_ind=1
      AND cv.code_value > 0
     WITH nocounter
    ;end update
   ENDIF
   CALL bedlogmessage("updateCKIintoCVtableforCodeSet200","Exiting ...")
 END ;Subroutine
 SUBROUTINE gettaskassaycdfrommnemonicandacvitytype(mnemonic,activitytypecd)
   CALL bedlogmessage("getTaskAssayCdFromMnemonicAndAcvityType","Entering ...")
   DECLARE taskassaycd = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM discrete_task_assay dta
    PLAN (dta
     WHERE cnvtupper(dta.mnemonic)=cnvtupper(mnemonic)
      AND dta.activity_type_cd=activitytypecd)
    DETAIL
     taskassaycd = dta.task_assay_cd
    WITH nocounter
   ;end select
   CALL bedlogmessage("getTaskAssayCdFromMnemonicAndAcvityType","Exiting ...")
   RETURN(taskassaycd)
 END ;Subroutine
 SUBROUTINE geteventsetcodefromeventsetname(eventsetname)
   CALL bedlogmessage("getEventSetCodeFromEventSetName","Entering ...")
   DECLARE eventsetcd = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM v500_event_set_code es
    PLAN (es
     WHERE es.event_set_name=eventsetname)
    DETAIL
     eventsetcd = es.event_set_cd
    WITH nocounter
   ;end select
   CALL bedlogmessage("getEventSetCodeFromEventSetName","Exiting ...")
   RETURN(eventsetcd)
 END ;Subroutine
 SUBROUTINE geteventsetcdfromeventsetname(esc_parse,identifiertype,eventsetcodesreply)
   CALL bedlogmessage("getEventSetCdFromEventSetName","Entering ...")
   DECLARE eventsetcodecnt = i4 WITH protect, noconstant(0)
   IF (validate(debug,0)=1)
    CALL echo(esc_parse)
   ENDIF
   SELECT INTO "nl:"
    FROM v500_event_set_code esc,
     code_value cv
    PLAN (esc
     WHERE parser(esc_parse))
     JOIN (cv
     WHERE cv.code_value=esc.event_set_cd)
    DETAIL
     eventsetcodecnt = (size(eventsetcodesreply->eventsetcodes,5)+ 1), stat = alterlist(
      eventsetcodesreply->eventsetcodes,eventsetcodecnt), eventsetcodesreply->eventsetcodes[
     eventsetcodecnt].event_set_code = esc.event_set_cd,
     eventsetcodesreply->eventsetcodes[eventsetcodecnt].event_set_name = esc.event_set_name,
     eventsetcodesreply->eventsetcodes[eventsetcodecnt].description = cv.description,
     eventsetcodesreply->eventsetcodes[eventsetcodecnt].definition = cv.definition,
     eventsetcodesreply->eventsetcodes[eventsetcodecnt].code_set = cv.code_set
     IF (identifiertype="CONCEPTCKI")
      eventsetcodesreply->eventsetcodes[eventsetcodecnt].identifier = cv.concept_cki
     ELSEIF (identifiertype="CKI")
      eventsetcodesreply->eventsetcodes[eventsetcodecnt].identifier = cv.cki
     ELSEIF (identifiertype="CDFMEANING")
      eventsetcodesreply->eventsetcodes[eventsetcodecnt].identifier = cv.cdf_meaning
     ENDIF
    WITH check
   ;end select
   IF (validate(debug,0)=1)
    CALL echorecord(eventsetcodesreply)
   ENDIF
   CALL bedlogmessage("getEventSetCdFromEventSetName","Exiting ...")
 END ;Subroutine
 SUBROUTINE geteventsetcdfromidentifier(esc_parse,identifiertype,eventsetcodesreply)
   CALL bedlogmessage("getEventSetCdFromIdentifier","Entering ...")
   DECLARE eventsetcodecnt = i4 WITH protect, noconstant(0)
   IF (validate(debug,0)=1)
    CALL echo(esc_parse)
   ENDIF
   SELECT INTO "nl:"
    FROM code_value cv,
     v500_event_set_code esc
    PLAN (cv
     WHERE parser(esc_parse))
     JOIN (esc
     WHERE esc.event_set_cd=cv.code_value)
    ORDER BY esc.event_set_name
    DETAIL
     eventsetcodecnt = (size(eventsetcodesreply->eventsetcodes,5)+ 1), stat = alterlist(
      eventsetcodesreply->eventsetcodes,eventsetcodecnt), eventsetcodesreply->eventsetcodes[
     eventsetcodecnt].event_set_code = esc.event_set_cd,
     eventsetcodesreply->eventsetcodes[eventsetcodecnt].event_set_name = esc.event_set_name,
     eventsetcodesreply->eventsetcodes[eventsetcodecnt].description = cv.description,
     eventsetcodesreply->eventsetcodes[eventsetcodecnt].definition = cv.definition,
     eventsetcodesreply->eventsetcodes[eventsetcodecnt].code_set = cv.code_set
     IF (identifiertype="CONCEPTCKI")
      eventsetcodesreply->eventsetcodes[eventsetcodecnt].identifier = cv.concept_cki
     ELSEIF (identifiertype="CKI")
      eventsetcodesreply->eventsetcodes[eventsetcodecnt].identifier = cv.cki
     ELSEIF (identifiertype="CDFMEANING")
      eventsetcodesreply->eventsetcodes[eventsetcodecnt].identifier = cv.cdf_meaning
     ENDIF
    WITH check
   ;end select
   IF (validate(debug,0)=1)
    CALL echorecord(eventsetcodesreply)
   ENDIF
   CALL bedlogmessage("getEventSetCdFromIdentifier","Exiting ...")
 END ;Subroutine
 SUBROUTINE getdtacdfrommnemonic(dta_parse,identifiertype,dtacodesreply)
   CALL bedlogmessage("getDtaCdFromMnemonic","Entering ...")
   DECLARE dtacodecnt = i4 WITH protect, noconstant(0)
   IF (validate(debug,0)=1)
    CALL echo(dta_parse)
   ENDIF
   SELECT INTO "nl:"
    FROM discrete_task_assay dta,
     code_value cv,
     code_value cv2
    PLAN (dta
     WHERE parser(dta_parse))
     JOIN (cv
     WHERE cv.code_value=dta.task_assay_cd)
     JOIN (cv2
     WHERE cv2.code_value=dta.activity_type_cd)
    DETAIL
     dtacodecnt = (size(dtacodesreply->dtacodes,5)+ 1), stat = alterlist(dtacodesreply->dtacodes,
      dtacodecnt), dtacodesreply->dtacodes[dtacodecnt].task_assay_cd = dta.task_assay_cd,
     dtacodesreply->dtacodes[dtacodecnt].mnemonic = dta.mnemonic, dtacodesreply->dtacodes[dtacodecnt]
     .description = cv.description, dtacodesreply->dtacodes[dtacodecnt].definition = cv.definition,
     dtacodesreply->dtacodes[dtacodecnt].code_set = cv.code_set
     IF (identifiertype="CONCEPTCKI")
      dtacodesreply->dtacodes[dtacodecnt].identifier = cv.concept_cki
     ELSEIF (identifiertype="CKI")
      dtacodesreply->dtacodes[dtacodecnt].identifier = cv.cki
     ELSEIF (identifiertype="CDFMEANING")
      dtacodesreply->dtacodes[dtacodecnt].identifier = cv.cdf_meaning
     ENDIF
     dtacodesreply->dtacodes[dtacodecnt].activity_type_cd = dta.activity_type_cd, dtacodesreply->
     dtacodes[dtacodecnt].activity_type_disp = cv2.display, dtacodesreply->dtacodes[dtacodecnt].
     activity_type_def = cv2.definition
    WITH check
   ;end select
   IF (validate(debug,0)=1)
    CALL echorecord(dtacodesreply)
   ENDIF
   CALL bedlogmessage("getDtaCdFromMnemonic","Exiting ...")
 END ;Subroutine
 SUBROUTINE getdtacdfromidentifier(dta_parse,identifiertype,dtacodesreply)
   CALL bedlogmessage("getDtaCdFromIdentifier","Entering ...")
   DECLARE dtacodecnt = i4 WITH protect, noconstant(0)
   IF (validate(debug,0)=1)
    CALL echo(dta_parse)
   ENDIF
   SELECT INTO "nl:"
    FROM code_value cv,
     discrete_task_assay dta,
     code_value cv2
    PLAN (cv
     WHERE parser(dta_parse))
     JOIN (dta
     WHERE dta.task_assay_cd=cv.code_value)
     JOIN (cv2
     WHERE cv2.code_value=dta.activity_type_cd)
    DETAIL
     dtacodecnt = (size(dtacodesreply->dtacodes,5)+ 1), stat = alterlist(dtacodesreply->dtacodes,
      dtacodecnt), dtacodesreply->dtacodes[dtacodecnt].task_assay_cd = dta.task_assay_cd,
     dtacodesreply->dtacodes[dtacodecnt].mnemonic = dta.mnemonic, dtacodesreply->dtacodes[dtacodecnt]
     .description = cv.description, dtacodesreply->dtacodes[dtacodecnt].definition = cv.definition,
     dtacodesreply->dtacodes[dtacodecnt].code_set = cv.code_set
     IF (identifiertype="CONCEPTCKI")
      dtacodesreply->dtacodes[dtacodecnt].identifier = cv.concept_cki
     ELSEIF (identifiertype="CKI")
      dtacodesreply->dtacodes[dtacodecnt].identifier = cv.cki
     ELSEIF (identifiertype="CDFMEANING")
      dtacodesreply->dtacodes[dtacodecnt].identifier = cv.cdf_meaning
     ENDIF
     dtacodesreply->dtacodes[dtacodecnt].activity_type_cd = dta.activity_type_cd, dtacodesreply->
     dtacodes[dtacodecnt].activity_type_disp = cv2.display, dtacodesreply->dtacodes[dtacodecnt].
     activity_type_def = cv2.definition
    WITH check
   ;end select
   IF (validate(debug,0)=1)
    CALL echorecord(dtacodesreply)
   ENDIF
   CALL bedlogmessage("getDtaCdFromIdentifier","Exiting ...")
 END ;Subroutine
 SUBROUTINE getmnemonicfromtaskassaycode(taskassaycd)
   CALL bedlogmessage("getMnemonicFromTaskAssayCode","Entering ...")
   DECLARE mnemonic = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM discrete_task_assay dta
    PLAN (dta
     WHERE dta.task_assay_cd=taskassaycd)
    DETAIL
     mnemonic = dta.mnemonic
    WITH nocounter
   ;end select
   CALL bedlogmessage("getMnemonicFromTaskAssayCode","Exiting ...")
   RETURN(mnemonic)
 END ;Subroutine
 SUBROUTINE getactivitytypecodefromtaskassaycode(taskassaycd)
   CALL bedlogmessage("getActivityTypeCodeFromTaskAssayCode","Entering ...")
   DECLARE activitytypecd = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM discrete_task_assay dta
    PLAN (dta
     WHERE dta.task_assay_cd=taskassaycd)
    DETAIL
     activitytypecd = dta.activity_type_cd
    WITH nocounter
   ;end select
   CALL bedlogmessage("getActivityTypeCodeFromTaskAssayCode","Exiting ...")
   RETURN(activitytypecd)
 END ;Subroutine
 SUBROUTINE getdisplayfromcodevalue(codevalue)
   CALL bedlogmessage("getDisplayFromCodeValue","Entering ...")
   DECLARE display = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_value=codevalue)
    DETAIL
     display = cv.display
    WITH check
   ;end select
   CALL logdebugmessage("Code Value:",codevalue)
   CALL logdebugmessage("Display:",display)
   CALL bedlogmessage("getDisplayFromCodeValue","Exiting ...")
   RETURN(display)
 END ;Subroutine
 SUBROUTINE getdefinitionfromcodevalue(codevalue)
   CALL bedlogmessage("getDefinitionFromCodeValue","Entering ...")
   DECLARE definition = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_value=codevalue)
    DETAIL
     definition = cv.definition
    WITH check
   ;end select
   CALL logdebugmessage("Code Value:",codevalue)
   CALL logdebugmessage("Definition:",definition)
   CALL bedlogmessage("getDefinitionFromCodeValue","Exiting ...")
   RETURN(definition)
 END ;Subroutine
 SUBROUTINE getdescriptionfromcodevalue(codevalue)
   CALL bedlogmessage("getDescriptionFromCodeValue","Entering ...")
   DECLARE description = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_value=codevalue)
    DETAIL
     description = cv.description
    WITH check
   ;end select
   CALL logdebugmessage("Code Value:",codevalue)
   CALL logdebugmessage("Description",description)
   CALL bedlogmessage("getDescriptionFromCodeValue","Exiting ...")
   RETURN(description)
 END ;Subroutine
 SUBROUTINE getconceptckifromcodevalue(codevalue)
   CALL bedlogmessage("getConceptCKIFromCodeValue","Entering ...")
   DECLARE concept_cki = vc WITH protect, noconstant("")
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_value=codevalue)
    DETAIL
     concept_cki = cv.concept_cki
    WITH check
   ;end select
   CALL logdebugmessage("Code Value:",codevalue)
   CALL logdebugmessage("Concept CKI:",concept_cki)
   CALL bedlogmessage("getConceptCKIFromCodeValue","Exiting ...")
   RETURN(concept_cki)
 END ;Subroutine
 SUBROUTINE getcodesetfromcodevalue(codevalue)
   CALL bedlogmessage("getCodeSetFromCodeValue","Entering ...")
   DECLARE codeset = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_value=codevalue)
    DETAIL
     codeset = cv.code_set
    WITH check
   ;end select
   CALL logdebugmessage("Given code value:",codevalue)
   CALL logdebugmessage("Code Set of the given code value:",codeset)
   CALL bedlogmessage("getCodeSetFromCodeValue","Exiting ...")
   RETURN(codeset)
 END ;Subroutine
 CALL bedbeginscript(0)
 DECLARE populatedatafortabletypecode(binitemsdatacnt=i2) = null
 DECLARE populatedatafortabletypeorderable(binitemsdatacnt=i2) = null
 DECLARE populatedatafortabletypenomenclature(binitemsdatacnt=i2) = null
 IF (validate(debug,0)=1)
  CALL echorecord(request)
 ENDIF
 SET stat = alterlist(reply->collist,12)
 SET reply->collist[1].header_text = "BIN File Code Set/Table"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "BIN File Display"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "BIN File Description"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Code Set/Table"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Display"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Description"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Concept CKI"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "CKI"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "CDF Meaning"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Active Status"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Update Date"
 SET reply->collist[11].data_type = 4
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Update User Name"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 DECLARE binitemsdatacnt = i4 WITH protect, noconstant(0)
 DECLARE replycnt = i4 WITH protect, noconstant(0)
 FOR (binitemsdatacnt = 1 TO size(request->bin_items_data,5))
   IF ((request->bin_items_data[binitemsdatacnt].bin_item_table_type="CODE"))
    CALL populatedatafortabletypecode(binitemsdatacnt)
    IF ((request->bin_items_data[binitemsdatacnt].bin_item_code_set=200)
     AND (request->bin_items_data[binitemsdatacnt].bin_item_ident_ccki > ""))
     CALL populatedatafortabletypeorderable(binitemsdatacnt)
    ENDIF
   ELSEIF ((request->bin_items_data[binitemsdatacnt].bin_item_table_type="ORDERABLE"))
    CALL populatedatafortabletypeorderable(binitemsdatacnt)
    IF ((request->bin_items_data[binitemsdatacnt].bin_item_ident_ccki > ""))
     SET request->bin_items_data[binitemsdatacnt].bin_item_code_set = 200
     CALL populatedatafortabletypecode(binitemsdatacnt)
    ENDIF
   ELSEIF ((request->bin_items_data[binitemsdatacnt].bin_item_table_type="NOMENCLATURE"))
    CALL populatedatafortabletypenomenclature(binitemsdatacnt)
   ENDIF
 ENDFOR
 IF ((request->skip_volume_check_ind=0))
  IF (replycnt > 5000)
   SET reply->high_volume_flag = 2
  ELSEIF (replycnt > 3000)
   SET reply->high_volume_flag = 1
  ENDIF
  IF ((reply->high_volume_flag IN (1, 2)))
   SET reply->output_filename = build("concept_map_wiz_audit.csv")
  ENDIF
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL bedexitscript(0)
 SUBROUTINE populatedatafortabletypecode(binitemsdatacnt)
   CALL bedlogmessage("populateDataForTableTypeCode","Entering ...")
   DECLARE parseidentifiertype = vc WITH protect, noconstant("")
   DECLARE cv_parse = vc WITH protect, noconstant("")
   DECLARE identifier = vc WITH protect, noconstant("")
   IF ((request->bin_items_data[binitemsdatacnt].bin_item_ident_ccki > ""))
    SET parseidentifiertype = "concept_cki"
    SET identifier = cnvtupper(request->bin_items_data[binitemsdatacnt].bin_item_ident_ccki)
   ELSEIF ((request->bin_items_data[binitemsdatacnt].bin_item_ident_cki > ""))
    SET parseidentifiertype = "cki"
    SET identifier = cnvtupper(request->bin_items_data[binitemsdatacnt].bin_item_ident_cki)
   ELSEIF ((request->bin_items_data[binitemsdatacnt].bin_item_ident_cdf > ""))
    SET parseidentifiertype = "cdf_meaning"
    SET identifier = cnvtupper(request->bin_items_data[binitemsdatacnt].bin_item_ident_cdf)
   ENDIF
   SET cv_parse =
   "(cnvtupper(cv.display) = cnvtupper(request->bin_items_data[binItemsDataCnt]->bin_item_display)"
   SET cv_parse = concat(cv_parse,' or cnvtupper(parser(build2("cv.",parseIdentifierType))) = "',
    identifier,'" )')
   IF (isrelatedcodeset(request->bin_items_data[binitemsdatacnt].bin_item_code_set)
    AND parseidentifiertype="concept_cki")
    SET cv_parse = concat(cv_parse,
     " and (cv.code_set = 72 or cv.code_set = 93 or cv.code_set = 14003) ")
   ELSE
    SET cv_parse = concat(cv_parse,
     " and cv.code_set = request->bin_items_data[binItemsDataCnt]->bin_item_code_set ")
   ENDIF
   SELECT INTO "nl:"
    FROM code_value cv,
     person p
    PLAN (cv
     WHERE parser(cv_parse))
     JOIN (p
     WHERE p.person_id=outerjoin(cv.updt_id))
    DETAIL
     replycnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,replycnt), stat =
     alterlist(reply->rowlist[replycnt].celllist,12)
     IF ((request->bin_items_data[binitemsdatacnt].bin_item_table_type="ORDERABLE"))
      reply->rowlist[replycnt].celllist[1].string_value = request->bin_items_data[binitemsdatacnt].
      bin_item_table_type
     ELSE
      reply->rowlist[replycnt].celllist[1].string_value = cnvtstring(request->bin_items_data[
       binitemsdatacnt].bin_item_code_set)
     ENDIF
     reply->rowlist[replycnt].celllist[2].string_value = request->bin_items_data[binitemsdatacnt].
     bin_item_display, reply->rowlist[replycnt].celllist[3].string_value = request->bin_items_data[
     binitemsdatacnt].bin_item_description, reply->rowlist[replycnt].celllist[4].string_value =
     cnvtstring(cv.code_set),
     reply->rowlist[replycnt].celllist[5].string_value = cv.display, reply->rowlist[replycnt].
     celllist[6].string_value = cv.description, reply->rowlist[replycnt].celllist[7].string_value =
     cv.concept_cki,
     reply->rowlist[replycnt].celllist[8].string_value = cv.cki, reply->rowlist[replycnt].celllist[9]
     .string_value = cv.cdf_meaning
     IF (cv.active_ind=1)
      reply->rowlist[replycnt].celllist[10].string_value = "Active"
     ELSE
      reply->rowlist[replycnt].celllist[10].string_value = "Inactive"
     ENDIF
     reply->rowlist[replycnt].celllist[11].date_value = cv.updt_dt_tm, reply->rowlist[replycnt].
     celllist[12].string_value = p.name_full_formatted
    WITH nocounter
   ;end select
   IF (curqual > 0)
    CALL echo("found millenium matches")
   ELSE
    SET replycnt = (size(reply->rowlist,5)+ 1)
    SET stat = alterlist(reply->rowlist,replycnt)
    SET stat = alterlist(reply->rowlist[replycnt].celllist,12)
    IF ((request->bin_items_data[binitemsdatacnt].bin_item_table_type="ORDERABLE"))
     SET reply->rowlist[replycnt].celllist[1].string_value = request->bin_items_data[binitemsdatacnt]
     .bin_item_table_type
    ELSE
     SET reply->rowlist[replycnt].celllist[1].string_value = cnvtstring(request->bin_items_data[
      binitemsdatacnt].bin_item_code_set)
    ENDIF
    SET reply->rowlist[replycnt].celllist[2].string_value = request->bin_items_data[binitemsdatacnt].
    bin_item_display
    SET reply->rowlist[replycnt].celllist[3].string_value = request->bin_items_data[binitemsdatacnt].
    bin_item_description
   ENDIF
   CALL bedlogmessage("populateDataForTableTypeCode","Exiting ...")
 END ;Subroutine
 SUBROUTINE populatedatafortabletypeorderable(binitemsdatacnt)
   CALL bedlogmessage("populateDataForTableTypeOrderable","Entering ...")
   DECLARE parseidentifiertype = vc WITH protect, noconstant("")
   DECLARE oc_parse = vc WITH protect, noconstant("")
   DECLARE identifier = vc WITH protect, noconstant("")
   IF ((request->bin_items_data[binitemsdatacnt].bin_item_ident_ccki > ""))
    SET parseidentifiertype = "concept_cki"
    SET identifier = cnvtupper(request->bin_items_data[binitemsdatacnt].bin_item_ident_ccki)
   ELSEIF ((request->bin_items_data[binitemsdatacnt].bin_item_ident_cki > ""))
    SET parseidentifiertype = "cki"
    SET identifier = cnvtupper(request->bin_items_data[binitemsdatacnt].bin_item_ident_cki)
   ELSEIF ((request->bin_items_data[binitemsdatacnt].bin_item_ident_cdf > ""))
    SET parseidentifiertype = "cdf_meaning"
    SET identifier = cnvtupper(request->bin_items_data[binitemsdatacnt].bin_item_ident_cdf)
   ENDIF
   SET oc_parse =
   "(cnvtupper(oc.primary_mnemonic) = cnvtupper(request->bin_items_data[binItemsDataCnt]->bin_item_display))"
   SET oc_parse = concat(oc_parse,' or (cnvtupper(parser(build2("oc.",parseIdentifierType))) = "',
    identifier,'" )')
   SELECT INTO "nl:"
    FROM order_catalog oc,
     person p
    PLAN (oc
     WHERE parser(oc_parse))
     JOIN (p
     WHERE p.person_id=outerjoin(oc.updt_id))
    DETAIL
     replycnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,replycnt), stat =
     alterlist(reply->rowlist[replycnt].celllist,12)
     IF ((request->bin_items_data[binitemsdatacnt].bin_item_table_type="CODE"))
      reply->rowlist[replycnt].celllist[1].string_value = cnvtstring(request->bin_items_data[
       binitemsdatacnt].bin_item_code_set)
     ELSE
      reply->rowlist[replycnt].celllist[1].string_value = request->bin_items_data[binitemsdatacnt].
      bin_item_table_type
     ENDIF
     reply->rowlist[replycnt].celllist[2].string_value = request->bin_items_data[binitemsdatacnt].
     bin_item_display, reply->rowlist[replycnt].celllist[3].string_value = request->bin_items_data[
     binitemsdatacnt].bin_item_description, reply->rowlist[replycnt].celllist[4].string_value =
     "ORDERABLE",
     reply->rowlist[replycnt].celllist[5].string_value = oc.primary_mnemonic, reply->rowlist[replycnt
     ].celllist[6].string_value = oc.description, reply->rowlist[replycnt].celllist[7].string_value
      = oc.concept_cki,
     reply->rowlist[replycnt].celllist[8].string_value = oc.cki, reply->rowlist[replycnt].celllist[9]
     .string_value = ""
     IF (oc.active_ind=1)
      reply->rowlist[replycnt].celllist[10].string_value = "Active"
     ELSE
      reply->rowlist[replycnt].celllist[10].string_value = "Inactive"
     ENDIF
     reply->rowlist[replycnt].celllist[11].date_value = oc.updt_dt_tm, reply->rowlist[replycnt].
     celllist[12].string_value = p.name_full_formatted
    WITH nocounter
   ;end select
   IF (curqual > 0)
    CALL echo("found millenium matches")
   ELSE
    SET replycnt = (size(reply->rowlist,5)+ 1)
    SET stat = alterlist(reply->rowlist,replycnt)
    SET stat = alterlist(reply->rowlist[replycnt].celllist,12)
    IF ((request->bin_items_data[binitemsdatacnt].bin_item_table_type="CODE"))
     SET reply->rowlist[replycnt].celllist[1].string_value = cnvtstring(request->bin_items_data[
      binitemsdatacnt].bin_item_code_set)
    ELSE
     SET reply->rowlist[replycnt].celllist[1].string_value = request->bin_items_data[binitemsdatacnt]
     .bin_item_table_type
    ENDIF
    SET reply->rowlist[replycnt].celllist[2].string_value = request->bin_items_data[binitemsdatacnt].
    bin_item_display
    SET reply->rowlist[replycnt].celllist[3].string_value = request->bin_items_data[binitemsdatacnt].
    bin_item_description
   ENDIF
   CALL bedlogmessage("populateDataForTableTypeOrderable","Exiting ...")
 END ;Subroutine
 SUBROUTINE populatedatafortabletypenomenclature(binitemsdatacnt)
   CALL bedlogmessage("populateDataForTableTypeNomenclature","Entering ...")
   DECLARE nm_parse = vc WITH protect, noconstant("")
   DECLARE nomen_display = vc WITH protect, noconstant("")
   DECLARE nomen_ccki = vc WITH protect, noconstant("")
   SET nomen_display = cnvtupper(request->bin_items_data[binitemsdatacnt].bin_item_display)
   SET nomen_ccki = cnvtupper(request->bin_items_data[binitemsdatacnt].bin_item_ident_ccki)
   SET nm_parse = "(nm.source_vocabulary_cd = PATIENT_CARE_CD)"
   SET nm_parse = concat(nm_parse," and (nm.principle_type_cd = PRINCIPLE_TYPE_CD)")
   SET nm_parse = concat(nm_parse,' and (nm.source_string_keycap =  "',nomen_display,'" ')
   SET nm_parse = concat(nm_parse,' or cnvtupper(nm.concept_cki) =  "',nomen_ccki,'")')
   SELECT INTO "nl:"
    FROM nomenclature nm,
     person p
    PLAN (nm
     WHERE parser(nm_parse))
     JOIN (p
     WHERE p.person_id=outerjoin(nm.updt_id))
    DETAIL
     replycnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,replycnt), stat =
     alterlist(reply->rowlist[replycnt].celllist,12),
     reply->rowlist[replycnt].celllist[1].string_value = request->bin_items_data[binitemsdatacnt].
     bin_item_table_type, reply->rowlist[replycnt].celllist[2].string_value = request->
     bin_items_data[binitemsdatacnt].bin_item_display, reply->rowlist[replycnt].celllist[3].
     string_value = request->bin_items_data[binitemsdatacnt].bin_item_description,
     reply->rowlist[replycnt].celllist[4].string_value = request->bin_items_data[binitemsdatacnt].
     bin_item_table_type, reply->rowlist[replycnt].celllist[5].string_value = nm.source_string, reply
     ->rowlist[replycnt].celllist[6].string_value = "",
     reply->rowlist[replycnt].celllist[7].string_value = nm.concept_cki, reply->rowlist[replycnt].
     celllist[8].string_value = "", reply->rowlist[replycnt].celllist[9].string_value = ""
     IF (nm.active_ind=1)
      reply->rowlist[replycnt].celllist[10].string_value = "Active"
     ELSE
      reply->rowlist[replycnt].celllist[10].string_value = "Inactive"
     ENDIF
     reply->rowlist[replycnt].celllist[11].date_value = nm.updt_dt_tm, reply->rowlist[replycnt].
     celllist[12].string_value = p.name_full_formatted
    WITH nocounter
   ;end select
   IF (curqual > 0)
    CALL echo("found millenium matches")
   ELSE
    SET replycnt = (size(reply->rowlist,5)+ 1)
    SET stat = alterlist(reply->rowlist,replycnt)
    SET stat = alterlist(reply->rowlist[replycnt].celllist,12)
    SET reply->rowlist[replycnt].celllist[1].string_value = request->bin_items_data[binitemsdatacnt].
    bin_item_table_type
    SET reply->rowlist[replycnt].celllist[2].string_value = request->bin_items_data[binitemsdatacnt].
    bin_item_display
    SET reply->rowlist[replycnt].celllist[3].string_value = request->bin_items_data[binitemsdatacnt].
    bin_item_description
   ENDIF
   CALL bedlogmessage("populateDataForTableTypeNomenclature","Exiting ...")
 END ;Subroutine
END GO
