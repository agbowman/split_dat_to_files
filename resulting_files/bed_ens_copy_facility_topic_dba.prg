CREATE PROGRAM bed_ens_copy_facility_topic:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 RECORD scenarios(
   1 scenariolist[*]
     2 topicscenarioid = f8
     2 scenariomean = vc
     2 categories[*]
       3 ndetailid = f8
       3 categoryid = f8
       3 notetxt = vc
       3 selectind = i2
       3 options[*]
         4 noptionid = f8
         4 preselectind = i2
         4 optionseq = i4
         4 notetxt = vc
         4 orders[*]
           5 norderid = f8
           5 synonymid = f8
           5 sentenceid = f8
           5 synonymseq = i4
       3 category_seq = i4
 ) WITH protect
 RECORD datatodelete(
   1 details[*]
     2 detailid = f8
     2 options[*]
       3 optionid = f8
       3 orders[*]
         4 orderid = f8
 ) WITH protect
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
 DECLARE validaterequest(dummyt=i2) = i2
 DECLARE getscenariodetailsforfacility(fromfacilityid=f8) = i2
 DECLARE getfacilitydefinedscenarios(tofacilityid=f8,scenarios=vc(ref)) = i2
 DECLARE deletedetailsforfacilities(datatodelete=vc(ref)) = i2
 DECLARE ensurescenarios(dummyvar=i2) = i2
 DECLARE getgeneratedid(dummyvar=i2) = f8
 IF ( NOT (validaterequest(0)))
  CALL bederror("Invalid request structure.")
 ENDIF
 IF ( NOT (getscenariodetailsforfacility(request->copyfromfacilityid)))
  CALL bederror("Failed to retrieve all information it needed to copy.")
 ENDIF
 IF (size(scenarios->scenariolist,5) <= 0)
  CALL bederror("Did not find defined scenarios for from facility")
 ENDIF
 FOR (ii = 1 TO size(request->copytofacilitylist,5))
   CALL getfacilitydefinedscenarios(request->copytofacilitylist[ii].facilityid,scenarios)
 ENDFOR
 IF (size(datatodelete->details,5) > 0)
  CALL deletedetailsforfacilities(datatodelete)
 ENDIF
 IF ( NOT (ensurescenarios(0)))
  CALL bederror("Failed to ensure all scenarios.")
 ENDIF
#exit_script
 CALL bedexitscript(1)
 SUBROUTINE getgeneratedid(dummyvar)
   DECLARE pkid = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    temp = seq(bedrock_seq,nextval)
    FROM dual
    DETAIL
     pkid = cnvtreal(temp)
    WITH nocounter
   ;end select
   RETURN(pkid)
 END ;Subroutine
 SUBROUTINE validaterequest(dummyt)
   CALL bedlogmessage("validateRequest","Entering ...")
   IF ((request->copyfromfacilityid=0.0))
    RETURN(false)
   ENDIF
   IF (size(request->copytofacilitylist,5) <= 0)
    RETURN(false)
   ENDIF
   IF (size(request->topicscenariolist,5) <= 0)
    RETURN(false)
   ENDIF
   CALL bedlogmessage("validateRequest","Exiting ...")
   RETURN(true)
 END ;Subroutine
 SUBROUTINE getscenariodetailsforfacility(fromfacilityid)
   CALL bedlogmessage("getScenarioDetailsForFacility","Entering ...")
   DECLARE scenariocnt = i4 WITH protect, noconstant(0)
   DECLARE categorycnt = i4 WITH protect, noconstant(0)
   DECLARE optioncnt = i4 WITH protect, noconstant(0)
   DECLARE ordercnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(request->topicscenariolist,5)),
     br_ado_topic_scenario bats,
     br_ado_detail bad,
     br_ado_option bao,
     br_ado_ord_list baol
    PLAN (d)
     JOIN (bats
     WHERE (bats.br_ado_topic_scenario_id=request->topicscenariolist[d.seq].topicscenarioid))
     JOIN (bad
     WHERE bad.scenario_mean=bats.scenario_mean
      AND bad.facility_cd=fromfacilityid)
     JOIN (bao
     WHERE bao.br_ado_detail_id=bad.br_ado_detail_id)
     JOIN (baol
     WHERE baol.br_ado_option_id=bao.br_ado_option_id)
    ORDER BY bats.br_ado_topic_scenario_id, bad.br_ado_detail_id, bao.br_ado_option_id
    HEAD bats.br_ado_topic_scenario_id
     scenariocnt = (scenariocnt+ 1), stat = alterlist(scenarios->scenariolist,scenariocnt), scenarios
     ->scenariolist[scenariocnt].topicscenarioid = bats.br_ado_topic_scenario_id,
     scenarios->scenariolist[scenariocnt].scenariomean = bats.scenario_mean, categorycnt = 0
    HEAD bad.br_ado_detail_id
     categorycnt = (categorycnt+ 1), stat = alterlist(scenarios->scenariolist[scenariocnt].categories,
      categorycnt), scenarios->scenariolist[scenariocnt].categories[categorycnt].categoryid = bad
     .br_ado_category_id,
     scenarios->scenariolist[scenariocnt].categories[categorycnt].notetxt = bad.note_txt, scenarios->
     scenariolist[scenariocnt].categories[categorycnt].selectind = bad.select_ind, scenarios->
     scenariolist[scenariocnt].categories[categorycnt].category_seq = bad.scenario_category_seq,
     optioncnt = 0
    HEAD bao.br_ado_option_id
     optioncnt = (optioncnt+ 1), stat = alterlist(scenarios->scenariolist[scenariocnt].categories[
      categorycnt].options,optioncnt), scenarios->scenariolist[scenariocnt].categories[categorycnt].
     options[optioncnt].preselectind = bao.preselect_ind,
     scenarios->scenariolist[scenariocnt].categories[categorycnt].options[optioncnt].optionseq = bao
     .option_seq, scenarios->scenariolist[scenariocnt].categories[categorycnt].options[optioncnt].
     notetxt = bao.note_txt, ordercnt = 0
    DETAIL
     ordercnt = (ordercnt+ 1), stat = alterlist(scenarios->scenariolist[scenariocnt].categories[
      categorycnt].options[optioncnt].orders,ordercnt), scenarios->scenariolist[scenariocnt].
     categories[categorycnt].options[optioncnt].orders[ordercnt].synonymid = baol.synonym_id,
     scenarios->scenariolist[scenariocnt].categories[categorycnt].options[optioncnt].orders[ordercnt]
     .sentenceid = baol.sentence_id, scenarios->scenariolist[scenariocnt].categories[categorycnt].
     options[optioncnt].orders[ordercnt].synonymseq = baol.synonym_seq
    WITH nocounter
   ;end select
   CALL bedlogmessage("getScenarioDetailsForFacility","Exiting ...")
   RETURN(true)
 END ;Subroutine
 SUBROUTINE getfacilitydefinedscenarios(tofacilityid,scenarios)
   CALL bedlogmessage("getFacilityDefinedScenarios","Entering ...")
   DECLARE detailcnt = i4 WITH protect, noconstant(0)
   DECLARE optioncnt = i4 WITH protect, noconstant(0)
   DECLARE ordercnt = i4 WITH protect, noconstant(0)
   SET detailcnt = size(datatodelete->details,5)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(scenarios->scenariolist,5)),
     br_ado_topic_scenario bats,
     br_ado_detail bad,
     br_ado_option bao,
     br_ado_ord_list baol
    PLAN (d)
     JOIN (bats
     WHERE (bats.br_ado_topic_scenario_id=scenarios->scenariolist[d.seq].topicscenarioid))
     JOIN (bad
     WHERE bad.scenario_mean=bats.scenario_mean
      AND bad.facility_cd=tofacilityid)
     JOIN (bao
     WHERE bao.br_ado_detail_id=bad.br_ado_detail_id)
     JOIN (baol
     WHERE baol.br_ado_option_id=bao.br_ado_option_id
      AND baol.br_ado_detail_id=bao.br_ado_detail_id)
    ORDER BY bad.br_ado_detail_id, bao.br_ado_option_id, baol.br_ado_ord_list_id
    HEAD bad.br_ado_detail_id
     detailcnt = (detailcnt+ 1), stat = alterlist(datatodelete->details,detailcnt), datatodelete->
     details[detailcnt].detailid = bad.br_ado_detail_id,
     optioncnt = 0
    HEAD bao.br_ado_option_id
     optioncnt = (optioncnt+ 1), stat = alterlist(datatodelete->details[detailcnt].options,optioncnt),
     datatodelete->details[detailcnt].options[optioncnt].optionid = bao.br_ado_option_id,
     ordercnt = 0
    HEAD baol.br_ado_ord_list_id
     ordercnt = (ordercnt+ 1), stat = alterlist(datatodelete->details[detailcnt].options[optioncnt].
      orders,ordercnt), datatodelete->details[detailcnt].options[optioncnt].orders[ordercnt].orderid
      = baol.br_ado_ord_list_id
    WITH nocounter
   ;end select
   CALL bedlogmessage("getFacilityDefinedScenarios","Exiting ...")
   RETURN(true)
 END ;Subroutine
 SUBROUTINE deletedetailsforfacilities(datatodelete)
   CALL bedlogmessage("deleteDetailsForFacilities","Entering ...")
   FOR (didx = 1 TO size(datatodelete->details,5))
     FOR (oidx = 1 TO size(datatodelete->details[didx].options,5))
       FOR (oridx = 1 TO size(datatodelete->details[didx].options[oidx].orders,5))
        DELETE  FROM br_ado_ord_list baol
         WHERE (baol.br_ado_ord_list_id=datatodelete->details[didx].options[oidx].orders[oridx].
         orderid)
         WITH nocounter
        ;end delete
        CALL bederrorcheck(build2("Failed to delete from br_ado_ord_list for br_ado_ord_list_id:",
          datatodelete->details[didx].options[oidx].orders[oridx].orderid))
       ENDFOR
       DELETE  FROM br_ado_option bao
        WHERE (bao.br_ado_option_id=datatodelete->details[didx].options[oidx].optionid)
        WITH nocounter
       ;end delete
       CALL bederrorcheck(build2("Failed to delete from br_ado_option for br_ado_option_id:",
         datatodelete->details[didx].options[oidx].optionid))
     ENDFOR
     DELETE  FROM br_ado_detail bad
      WHERE (bad.br_ado_detail_id=datatodelete->details[didx].detailid)
      WITH nocounter
     ;end delete
     CALL bederrorcheck(build2("Failed to delete from br_ado_detail for br_ado_detail_id:",
       datatodelete->details[didx].detailid))
   ENDFOR
   CALL bedlogmessage("deleteDetailsForFacilities","Exiting ...")
 END ;Subroutine
 SUBROUTINE ensurescenarios(dummyvar)
   CALL bedlogmessage("ensureScenarios","Entering ...")
   DECLARE adddetailcnt = i4 WITH protect, noconstant(0)
   DECLARE addoptioncnt = i4 WITH protect, noconstant(0)
   DECLARE addordercnt = i4 WITH protect, noconstant(0)
   RECORD adddetailrequest(
     1 objarray[*]
       2 br_ado_detail_id = f8
       2 br_ado_category_id = f8
       2 facility_cd = f8
       2 note_txt = vc
       2 scenario_mean = vc
       2 select_ind = i2
       2 category_seq = i4
   ) WITH protect
   RECORD adddetailreply(
     1 objarray[*]
       2 primaryid = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   RECORD addoptionrequest(
     1 objarray[*]
       2 br_ado_option_id = f8
       2 br_ado_detail_id = f8
       2 note_txt = vc
       2 option_seq = i2
       2 preselect_ind = i2
   ) WITH protect
   RECORD addoptionreply(
     1 objarray[*]
       2 primaryid = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   RECORD addorderrequest(
     1 objarray[*]
       2 br_ado_ord_list_id = f8
       2 br_ado_option_id = f8
       2 br_ado_detail_id = f8
       2 sentence_id = f8
       2 synonym_id = f8
       2 synonym_seq = i2
   ) WITH protect
   RECORD addorderreply(
     1 objarray[*]
       2 primaryid = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   FOR (facidx = 1 TO size(request->copytofacilitylist,5))
     FOR (i = 1 TO size(scenarios->scenariolist,5))
      SET stat = alterlist(adddetailrequest->objarray,(size(adddetailrequest->objarray,5)+ size(
        scenarios->scenariolist[i].categories,5)))
      FOR (catidx = 1 TO size(scenarios->scenariolist[i].categories,5))
        SET scenarios->scenariolist[i].categories[catidx].ndetailid = getgeneratedid(0)
        SET adddetailcnt = (adddetailcnt+ 1)
        SET adddetailrequest->objarray[adddetailcnt].br_ado_detail_id = scenarios->scenariolist[i].
        categories[catidx].ndetailid
        SET adddetailrequest->objarray[adddetailcnt].br_ado_category_id = scenarios->scenariolist[i].
        categories[catidx].categoryid
        SET adddetailrequest->objarray[adddetailcnt].facility_cd = request->copytofacilitylist[facidx
        ].facilityid
        SET adddetailrequest->objarray[adddetailcnt].note_txt = scenarios->scenariolist[i].
        categories[catidx].notetxt
        SET adddetailrequest->objarray[adddetailcnt].scenario_mean = scenarios->scenariolist[i].
        scenariomean
        SET adddetailrequest->objarray[adddetailcnt].select_ind = scenarios->scenariolist[i].
        categories[catidx].selectind
        SET adddetailrequest->objarray[adddetailcnt].category_seq = scenarios->scenariolist[i].
        categories[catidx].category_seq
        SET stat = alterlist(addoptionrequest->objarray,(size(addoptionrequest->objarray,5)+ size(
          scenarios->scenariolist[i].categories[catidx].options,5)))
        FOR (optidx = 1 TO size(scenarios->scenariolist[i].categories[catidx].options,5))
          SET scenarios->scenariolist[i].categories[catidx].options[optidx].noptionid =
          getgeneratedid(0)
          SET addoptioncnt = (addoptioncnt+ 1)
          SET addoptionrequest->objarray[addoptioncnt].br_ado_option_id = scenarios->scenariolist[i].
          categories[catidx].options[optidx].noptionid
          SET addoptionrequest->objarray[addoptioncnt].br_ado_detail_id = scenarios->scenariolist[i].
          categories[catidx].ndetailid
          SET addoptionrequest->objarray[addoptioncnt].note_txt = scenarios->scenariolist[i].
          categories[catidx].options[optidx].notetxt
          SET addoptionrequest->objarray[addoptioncnt].option_seq = scenarios->scenariolist[i].
          categories[catidx].options[optidx].optionseq
          SET addoptionrequest->objarray[addoptioncnt].preselect_ind = scenarios->scenariolist[i].
          categories[catidx].options[optidx].preselectind
          SET stat = alterlist(addorderrequest->objarray,(size(addorderrequest->objarray,5)+ size(
            scenarios->scenariolist[i].categories[catidx].options[optidx].orders,5)))
          FOR (ordidx = 1 TO size(scenarios->scenariolist[i].categories[catidx].options[optidx].
           orders,5))
            SET scenarios->scenariolist[i].categories[catidx].options[optidx].orders[ordidx].norderid
             = getgeneratedid(0)
            SET addordercnt = (addordercnt+ 1)
            SET addorderrequest->objarray[addordercnt].br_ado_ord_list_id = scenarios->scenariolist[i
            ].categories[catidx].options[optidx].orders[ordidx].norderid
            SET addorderrequest->objarray[addordercnt].br_ado_option_id = scenarios->scenariolist[i].
            categories[catidx].options[optidx].noptionid
            SET addorderrequest->objarray[addordercnt].br_ado_detail_id = scenarios->scenariolist[i].
            categories[catidx].ndetailid
            SET addorderrequest->objarray[addordercnt].sentence_id = scenarios->scenariolist[i].
            categories[catidx].options[optidx].orders[ordidx].sentenceid
            SET addorderrequest->objarray[addordercnt].synonym_id = scenarios->scenariolist[i].
            categories[catidx].options[optidx].orders[ordidx].synonymid
            SET addorderrequest->objarray[addordercnt].synonym_seq = scenarios->scenariolist[i].
            categories[catidx].options[optidx].orders[ordidx].synonymseq
          ENDFOR
        ENDFOR
      ENDFOR
     ENDFOR
   ENDFOR
   IF (size(adddetailrequest->objarray,5) > 0)
    EXECUTE bed_da_add_ado_detail  WITH replace("REQUEST",adddetailrequest), replace("REPLY",
     adddetailreply)
    IF ((adddetailreply->status_data.status != "S"))
     CALL bedlogmessage("ensureScenarios","bed_da_add_ado_detail did not return success.")
     RETURN(false)
    ENDIF
    IF (size(addoptionrequest->objarray,5) > 0)
     EXECUTE bed_da_add_ado_option  WITH replace("REQUEST",addoptionrequest), replace("REPLY",
      addoptionreply)
     IF ((addoptionreply->status_data.status != "S"))
      CALL bedlogmessage("ensureScenarios","bed_da_add_ado_option did not return success.")
      RETURN(false)
     ENDIF
     IF (size(addorderrequest->objarray,5) > 0)
      EXECUTE bed_da_add_ado_ord_list  WITH replace("REQUEST",addorderrequest), replace("REPLY",
       addorderreply)
      IF ((addorderreply->status_data.status != "S"))
       CALL bedlogmessage("ensureScenarios","bed_da_add_ado_ord_list did not return success.")
       RETURN(false)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   CALL bedlogmessage("ensureScenarios","Exiting ...")
   RETURN(true)
 END ;Subroutine
END GO
