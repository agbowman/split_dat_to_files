CREATE PROGRAM bed_aud_qch_security:dba
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
  ) WITH protect
 ENDIF
 FREE RECORD qchdata
 RECORD qchdata(
   1 qch[*]
     2 qch_id = f8
     2 qch_name = vc
     2 qch_username = vc
     2 email_address = vc
     2 dashboard = vc
     2 mips_portal = vc
     2 eh_portal = vc
     2 qrda_export = vc
     2 ccns[*]
       3 ccn_id = f8
       3 ccn_name = vc
     2 ep_groups[*]
       3 ep_group_id = f8
       3 ep_group_name = vc
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
 IF ( NOT (validate(cs357_group_type_cd)))
  DECLARE cs357_group_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",357,"QCHUSER"))
 ENDIF
 IF ( NOT (validate(cs19189_group_class_cd)))
  DECLARE cs19189_group_class_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",19189,"QCH"))
 ENDIF
 IF ( NOT (validate(cs212_email_cd)))
  DECLARE cs212_email_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"EMAIL"))
 ENDIF
 DECLARE user = i4 WITH protect, constant(1)
 DECLARE username = i4 WITH protect, constant(2)
 DECLARE email = i4 WITH protect, constant(3)
 DECLARE assoc_type = i4 WITH protect, constant(4)
 DECLARE ccn_or_ep_group_name = i4 WITH protect, constant(5)
 DECLARE dashboard = i4 WITH protect, constant(6)
 DECLARE mips_portal = i4 WITH protect, constant(7)
 DECLARE eh_portal = i4 WITH protect, constant(8)
 DECLARE qrda_export = i4 WITH protect, constant(9)
 DECLARE column_cnt = i4 WITH protect, constant(9)
 DECLARE total_report_rows = i4 WITH protect
 DECLARE getqchprsnl(dummyvar=i2) = null
 DECLARE getqchprsnlccnreltn(dummyvar=i2) = null
 DECLARE getqchprsnleligprovreltn(dummyvar=i2) = null
 DECLARE buildepgroupname(groupid=f8) = vc
 DECLARE settotalrowcount(dummyvar=i2) = null
 DECLARE populatereportheaders(dummyvar=i2) = null
 DECLARE populatereportdata(dummyvar=i2) = null
 CALL getqchprsnl(0)
 CALL getqchprsnlccnreltn(0)
 CALL getqchprsnleligprovreltn(0)
 CALL settotalrowcount(0)
 IF ((request->skip_volume_check_ind=0))
  IF (total_report_rows > 10000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ELSEIF (total_report_rows > 5000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ENDIF
 ENDIF
 CALL populatereportheaders(0)
 CALL populatereportdata(0)
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bed_aud_qch_security.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL bedexitscript(0)
 SUBROUTINE getqchprsnl(dummyvar)
   CALL bedlogmessage("getQCHPrsnl","Entering ...")
   DECLARE qch_prsnl_count = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM prsnl_group pg,
     prsnl_group_reltn pgr,
     qmd_portal_permission qp,
     person p,
     prsnl pr,
     address a
    PLAN (pg
     WHERE pg.prsnl_group_class_cd=cs19189_group_class_cd
      AND pg.prsnl_group_type_cd=cs357_group_type_cd
      AND pg.active_ind=1)
     JOIN (pgr
     WHERE pgr.prsnl_group_id=pg.prsnl_group_id
      AND pgr.active_ind=1
      AND pgr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (qp
     WHERE qp.prsnl_group_reltn_id=outerjoin(pgr.prsnl_group_reltn_id))
     JOIN (pr
     WHERE pr.person_id=pgr.person_id)
     JOIN (p
     WHERE p.person_id=pr.person_id)
     JOIN (a
     WHERE a.parent_entity_id=outerjoin(p.person_id)
      AND a.parent_entity_name=outerjoin("PERSON")
      AND a.address_type_cd=outerjoin(cs212_email_cd)
      AND a.active_ind=outerjoin(1))
    ORDER BY cnvtupper(p.name_full_formatted)
    HEAD REPORT
     qch_prsnl_count = 0
    DETAIL
     qch_prsnl_count = (qch_prsnl_count+ 1), stat = alterlist(qchdata->qch,qch_prsnl_count), qchdata
     ->qch[qch_prsnl_count].qch_id = p.person_id,
     qchdata->qch[qch_prsnl_count].qch_name = p.name_full_formatted, qchdata->qch[qch_prsnl_count].
     qch_username = pr.username, qchdata->qch[qch_prsnl_count].email_address = a.street_addr
     IF (qp.dashboard_ind=1)
      qchdata->qch[qch_prsnl_count].dashboard = "X"
     ENDIF
     IF (qp.client_portal_display_ind=1)
      qchdata->qch[qch_prsnl_count].mips_portal = "X"
     ENDIF
     IF (qp.mips_display_ind=1)
      qchdata->qch[qch_prsnl_count].eh_portal = "X"
     ENDIF
     IF (qp.qrda_export_ind=1)
      qchdata->qch[qch_prsnl_count].qrda_export = "X"
     ENDIF
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error001: getQCHPrsnl")
   CALL bedlogmessage("getQCHPrsnl","Exiting ...")
 END ;Subroutine
 SUBROUTINE getqchprsnlccnreltn(dummyvar)
   CALL bedlogmessage("getQCHPrsnlCCNReltn","Entering ...")
   DECLARE ccn_count = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(qchdata->qch,5)),
     prsnl_group_reltn pgr,
     br_prsnl_ccn_reltn bpcr,
     br_ccn ccn
    PLAN (d)
     JOIN (pgr
     WHERE (pgr.person_id=qchdata->qch[d.seq].qch_id)
      AND pgr.active_ind=1)
     JOIN (bpcr
     WHERE bpcr.prsnl_group_reltn_id=pgr.prsnl_group_reltn_id
      AND bpcr.active_ind=1
      AND bpcr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (ccn
     WHERE ccn.br_ccn_id=bpcr.br_ccn_id)
    HEAD d.seq
     ccn_count = 0
    DETAIL
     ccn_count = (ccn_count+ 1), stat = alterlist(qchdata->qch[d.seq].ccns,ccn_count), qchdata->qch[d
     .seq].ccns[ccn_count].ccn_id = ccn.br_ccn_id,
     qchdata->qch[d.seq].ccns[ccn_count].ccn_name = ccn.ccn_name
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error002: getQCHPrsnlCCNReltn")
   CALL bedlogmessage("getQCHPrsnlCCNReltn","Exiting ...")
 END ;Subroutine
 SUBROUTINE getqchprsnleligprovreltn(dummyvar)
   CALL bedlogmessage("getQCHPrsnlEligProvReltn","Entering ...")
   DECLARE ep_group_count = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(qchdata->qch,5)),
     prsnl_group_reltn pgr,
     br_prsnl_elig_prov_grp_r bpepgr,
     br_group bg
    PLAN (d)
     JOIN (pgr
     WHERE (pgr.person_id=qchdata->qch[d.seq].qch_id)
      AND pgr.active_ind=1)
     JOIN (bpepgr
     WHERE bpepgr.prsnl_group_reltn_id=pgr.prsnl_group_reltn_id
      AND bpepgr.active_ind=1
      AND bpepgr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (bg
     WHERE bg.br_group_id=bpepgr.br_group_id)
    HEAD d.seq
     ep_group_count = 0
    DETAIL
     ep_group_count = (ep_group_count+ 1), stat = alterlist(qchdata->qch[d.seq].ep_groups,
      ep_group_count), qchdata->qch[d.seq].ep_groups[ep_group_count].ep_group_id = bg.br_group_id
    WITH nocounter
   ;end select
   FOR (x = 1 TO size(qchdata->qch,5))
     FOR (y = 1 TO size(qchdata->qch[x].ep_groups,5))
       SET qchdata->qch[x].ep_groups[y].ep_group_name = buildepgroupname(qchdata->qch[x].ep_groups[y]
        .ep_group_id)
     ENDFOR
   ENDFOR
   CALL bederrorcheck("Error003: getQCHPrsnlEligProvReltn")
   CALL bedlogmessage("getQCHPrsnlEligProvReltn","Exiting ...")
 END ;Subroutine
 SUBROUTINE buildepgroupname(groupid)
   CALL bedlogmessage("buildEPGroupName","Entering ...")
   DECLARE ep_group_string = vc
   SELECT INTO "nl:"
    FROM br_group bg1
    WHERE bg1.br_group_id=groupid
    DETAIL
     ep_group_string = trim(bg1.group_name)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM br_group_reltn bgr,
     br_group bg2
    WHERE bgr.br_group_id=groupid
     AND bgr.parent_entity_name="BR_GROUP"
     AND bg2.br_group_id=bgr.parent_entity_id
    DETAIL
     ep_group_string = build2(trim(bg2.group_name),"/",ep_group_string)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error004: buildEPGroupName")
   CALL bedlogmessage("buildEPGroupName","Exiting ...")
   RETURN(ep_group_string)
 END ;Subroutine
 SUBROUTINE settotalrowcount(dummyvar)
  SET total_report_rows = 0
  FOR (x = 1 TO size(qchdata->qch,5))
    IF (size(qchdata->qch[x].ccns,5)=0
     AND size(qchdata->qch[x].ep_groups,5)=0)
     SET total_report_rows = (total_report_rows+ 1)
    ELSE
     IF (size(qchdata->qch[x].ccns,5) > 0)
      SET total_report_rows = (total_report_rows+ size(qchdata->qch[x].ccns,5))
     ENDIF
     IF (size(qchdata->qch[x].ep_groups,5)=0)
      SET total_report_rows = (total_report_rows+ size(qchdata->qch[x].ep_groups,5))
     ENDIF
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE populatereportheaders(dummyvar)
   CALL bedlogmessage("populateReportHeaders","Entering ...")
   SET stat = alterlist(reply->collist,column_cnt)
   SET reply->collist[user].header_text = "User"
   SET reply->collist[user].data_type = 1
   SET reply->collist[user].hide_ind = 0
   SET reply->collist[username].header_text = "Username"
   SET reply->collist[username].data_type = 1
   SET reply->collist[username].hide_ind = 0
   SET reply->collist[email].header_text = "Email"
   SET reply->collist[email].data_type = 1
   SET reply->collist[email].hide_ind = 0
   SET reply->collist[assoc_type].header_text = "Association Type"
   SET reply->collist[assoc_type].data_type = 1
   SET reply->collist[assoc_type].hide_ind = 0
   SET reply->collist[ccn_or_ep_group_name].header_text = "CCN/EP Group"
   SET reply->collist[ccn_or_ep_group_name].data_type = 1
   SET reply->collist[ccn_or_ep_group_name].hide_ind = 0
   SET reply->collist[dashboard].header_text = "Dashboard"
   SET reply->collist[dashboard].data_type = 1
   SET reply->collist[dashboard].hide_ind = 0
   SET reply->collist[mips_portal].header_text = "MIPS Portal"
   SET reply->collist[mips_portal].data_type = 1
   SET reply->collist[mips_portal].hide_ind = 0
   SET reply->collist[eh_portal].header_text = "EH Portal"
   SET reply->collist[eh_portal].data_type = 1
   SET reply->collist[eh_portal].hide_ind = 0
   SET reply->collist[qrda_export].header_text = "Export"
   SET reply->collist[qrda_export].data_type = 1
   SET reply->collist[qrda_export].hide_ind = 0
   CALL bederrorcheck("Error005: populateReportHeaders")
   CALL bedlogmessage("populateReportHeaders","Exiting ...")
 END ;Subroutine
 SUBROUTINE populatereportdata(dummyvar)
   CALL bedlogmessage("populateReportData","Entering ...")
   DECLARE pcnt = i4 WITH protect, noconstant(0)
   DECLARE rowcnt = i4 WITH protect, noconstant(0)
   DECLARE ccncnt = i4 WITH protect, noconstant(0)
   DECLARE epgcnt = i4 WITH protect, noconstant(0)
   FOR (pcnt = 1 TO size(qchdata->qch,5))
     SET rowcnt = (rowcnt+ 1)
     SET stat = alterlist(reply->rowlist,rowcnt)
     SET stat = alterlist(reply->rowlist[rowcnt].celllist,column_cnt)
     SET ccncnt = size(qchdata->qch[pcnt].ccns,5)
     SET epgcnt = size(qchdata->qch[pcnt].ep_groups,5)
     IF (ccncnt=0
      AND epgcnt=0)
      SET reply->rowlist[rowcnt].celllist[user].string_value = qchdata->qch[pcnt].qch_name
      SET reply->rowlist[rowcnt].celllist[username].string_value = qchdata->qch[pcnt].qch_username
      SET reply->rowlist[rowcnt].celllist[email].string_value = qchdata->qch[pcnt].email_address
      SET reply->rowlist[rowcnt].celllist[dashboard].string_value = qchdata->qch[pcnt].dashboard
      SET reply->rowlist[rowcnt].celllist[mips_portal].string_value = qchdata->qch[pcnt].mips_portal
      SET reply->rowlist[rowcnt].celllist[eh_portal].string_value = qchdata->qch[pcnt].eh_portal
      SET reply->rowlist[rowcnt].celllist[qrda_export].string_value = qchdata->qch[pcnt].qrda_export
     ENDIF
     IF (ccncnt > 0)
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = size(qchdata->qch[pcnt].ccns,5))
       PLAN (d)
       ORDER BY cnvtupper(qchdata->qch[pcnt].ccns[d.seq].ccn_name)
       DETAIL
        reply->rowlist[rowcnt].celllist[user].string_value = qchdata->qch[pcnt].qch_name, reply->
        rowlist[rowcnt].celllist[username].string_value = qchdata->qch[pcnt].qch_username, reply->
        rowlist[rowcnt].celllist[email].string_value = qchdata->qch[pcnt].email_address,
        reply->rowlist[rowcnt].celllist[assoc_type].string_value = "CCN", reply->rowlist[rowcnt].
        celllist[ccn_or_ep_group_name].string_value = qchdata->qch[pcnt].ccns[d.seq].ccn_name, reply
        ->rowlist[rowcnt].celllist[dashboard].string_value = qchdata->qch[pcnt].dashboard,
        reply->rowlist[rowcnt].celllist[mips_portal].string_value = qchdata->qch[pcnt].mips_portal,
        reply->rowlist[rowcnt].celllist[eh_portal].string_value = qchdata->qch[pcnt].eh_portal, reply
        ->rowlist[rowcnt].celllist[qrda_export].string_value = qchdata->qch[pcnt].qrda_export,
        ccncnt = (ccncnt - 1)
        IF (ccncnt > 0)
         rowcnt = (rowcnt+ 1), stat = alterlist(reply->rowlist,rowcnt), stat = alterlist(reply->
          rowlist[rowcnt].celllist,column_cnt)
        ENDIF
       WITH nocounter
      ;end select
      IF (epgcnt > 0)
       SET rowcnt = (rowcnt+ 1)
       SET stat = alterlist(reply->rowlist,rowcnt)
       SET stat = alterlist(reply->rowlist[rowcnt].celllist,column_cnt)
      ENDIF
     ENDIF
     IF (epgcnt > 0)
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = size(qchdata->qch[pcnt].ep_groups,5))
       PLAN (d)
       ORDER BY cnvtupper(qchdata->qch[pcnt].ep_groups[d.seq].ep_group_name)
       DETAIL
        reply->rowlist[rowcnt].celllist[user].string_value = qchdata->qch[pcnt].qch_name, reply->
        rowlist[rowcnt].celllist[username].string_value = qchdata->qch[pcnt].qch_username, reply->
        rowlist[rowcnt].celllist[email].string_value = qchdata->qch[pcnt].email_address,
        reply->rowlist[rowcnt].celllist[assoc_type].string_value = "EP Group", reply->rowlist[rowcnt]
        .celllist[ccn_or_ep_group_name].string_value = qchdata->qch[pcnt].ep_groups[d.seq].
        ep_group_name, reply->rowlist[rowcnt].celllist[dashboard].string_value = qchdata->qch[pcnt].
        dashboard,
        reply->rowlist[rowcnt].celllist[mips_portal].string_value = qchdata->qch[pcnt].mips_portal,
        reply->rowlist[rowcnt].celllist[eh_portal].string_value = qchdata->qch[pcnt].eh_portal, reply
        ->rowlist[rowcnt].celllist[qrda_export].string_value = qchdata->qch[pcnt].qrda_export,
        epgcnt = (epgcnt - 1)
        IF (epgcnt > 0)
         rowcnt = (rowcnt+ 1), stat = alterlist(reply->rowlist,rowcnt), stat = alterlist(reply->
          rowlist[rowcnt].celllist,column_cnt)
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
   CALL bederrorcheck("Error006: populateReportData")
   CALL bedlogmessage("populateReportData","Exiting ...")
 END ;Subroutine
END GO
