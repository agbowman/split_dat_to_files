CREATE PROGRAM bed_aud_ap_word_templates
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 show_all_templates = i2
    1 search_type_flag = vc
    1 search_string = vc
    1 is_template_type_template = i2
    1 is_template_type_letter = i2
    1 organizations[*]
      2 org_id = f8
  )
 ENDIF
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
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD templates
 RECORD templates(
   1 qual[*]
     2 template_id = f8
     2 short_desc = vc
     2 long_desc = vc
     2 template_type = vc
     2 long_text_id = f8
     2 long_text = vc
     2 orgs = vc
     2 font = vc
     2 font_size = i2
     2 person_id = f8
     2 pdisp = vc
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
 DECLARE inbuffer = vc
 DECLARE inbuflen = i4
 DECLARE outbuffer = c1000 WITH noconstant("")
 DECLARE outbuflen = i4 WITH noconstant(1000)
 DECLARE retbuflen = i4 WITH noconstant(0)
 DECLARE bflag = i4 WITH noconstant(0)
 DECLARE orgs = vc
 DECLARE templates_parse = vc WITH protect
 DECLARE num = i4
 DECLARE high_volume_cnt = i4 WITH noconstant(0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE max_reply1 = i4 WITH constant(1750)
 DECLARE max_reply2 = i4 WITH constant(2500)
 DECLARE max_org = i4 WITH constant(250)
 DECLARE activity_code_value = f8 WITH protect, noconstant(uar_get_code_by("MEANING",106,"AP"))
 DECLARE template_type_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",1303,"TEMPLATE"))
 DECLARE letter_type_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",1303,"LETTER"))
 DECLARE max_org_cnt = i4 WITH noconstant(0)
 DECLARE org_cnt = i4 WITH noconstant(size(request->organizations,5))
 DECLARE maxlist = i4 WITH noconstant(0)
 DECLARE populateparsestringbasedonrequest(dummyvar=i2) = null
 CALL bedbeginscript(0)
 CALL populateparsestringbasedonrequest(0)
 CALL echo(build("PARSER-->, ",templates_parse))
 SET stat = alterlist(reply->collist,8)
 SET reply->collist[1].header_text = "template_id"
 SET reply->collist[1].data_type = 2
 SET reply->collist[1].hide_ind = 1
 SET reply->collist[2].header_text = "Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Description"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Letter or Template"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "long_text_id"
 SET reply->collist[5].data_type = 2
 SET reply->collist[5].hide_ind = 1
 SET reply->collist[6].header_text = "Template Text"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Associated Facilities"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "User"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET cnt = 0
 IF (org_cnt > 0)
  SELECT INTO "NL:"
   wt.short_desc, org.org_name
   FROM wp_template wt,
    long_text lt,
    filter_entity_reltn fer,
    organization org
   PLAN (wt
    WHERE wt.template_type_cd IN (template_type_cd, letter_type_cd)
     AND wt.activity_type_cd=activity_code_value
     AND parser(templates_parse))
    JOIN (lt
    WHERE lt.parent_entity_id=wt.template_id
     AND lt.parent_entity_name="WP_TEMPLATE_TEXT"
     AND lt.active_ind=1)
    JOIN (fer
    WHERE fer.parent_entity_id=outerjoin(wt.template_id)
     AND ((expand(num,1,org_cnt,fer.filter_entity1_id,request->organizations[num].org_id)) OR ( NOT (
     EXISTS (
    (SELECT
     fer1.filter_entity_reltn_id
     FROM filter_entity_reltn fer1
     WHERE fer1.parent_entity_id=wt.template_id))))) )
    JOIN (org
    WHERE org.active_ind=outerjoin(1)
     AND org.organization_id=outerjoin(fer.filter_entity1_id))
   ORDER BY wt.short_desc
   HEAD wt.short_desc
    orgs = "", org_count = 0, cnt = (cnt+ 1),
    high_volume_cnt = (high_volume_cnt+ 1), stat = alterlist(templates->qual,cnt), templates->qual[
    cnt].long_text = lt.long_text,
    templates->qual[cnt].long_desc = wt.description, templates->qual[cnt].long_text_id = lt
    .long_text_id, templates->qual[cnt].short_desc = wt.short_desc,
    templates->qual[cnt].template_id = wt.template_id
    IF (wt.template_type_cd=template_type_cd)
     templates->qual[cnt].template_type = "Template"
    ELSEIF (wt.template_type_cd=letter_type_cd)
     templates->qual[cnt].template_type = "Letter"
    ENDIF
    templates->qual[cnt].person_id = wt.person_id
   DETAIL
    org_count = (org_count+ 1)
    IF (orgs="")
     orgs = org.org_name
    ELSE
     orgs = build2(orgs,", ",org.org_name)
    ENDIF
   FOOT  wt.short_desc
    templates->qual[cnt].orgs = orgs
    IF (org_count > max_org_cnt)
     max_org_cnt = org_count
    ENDIF
   WITH nocounter
  ;end select
  IF ((request->skip_volume_check_ind=0))
   IF (((max_org_cnt > max_org) OR (high_volume_cnt > max_reply2)) )
    SET reply->high_volume_flag = 2
    GO TO exit_script
   ELSEIF (high_volume_cnt > max_reply1)
    SET reply->high_volume_flag = 1
    GO TO exit_script
   ENDIF
  ENDIF
  CALL bederrorcheck("Error 003: Retreiving templates in facilities filter")
 ELSE
  SELECT INTO "NL:"
   wt.short_desc, org.org_name
   FROM wp_template wt,
    long_text lt,
    filter_entity_reltn fer,
    organization org
   PLAN (wt
    WHERE wt.template_type_cd IN (template_type_cd, letter_type_cd)
     AND wt.activity_type_cd=activity_code_value
     AND parser(templates_parse))
    JOIN (lt
    WHERE lt.parent_entity_id=wt.template_id
     AND lt.parent_entity_name="WP_TEMPLATE_TEXT"
     AND lt.active_ind=1)
    JOIN (fer
    WHERE fer.parent_entity_id=outerjoin(wt.template_id))
    JOIN (org
    WHERE org.organization_id=outerjoin(fer.filter_entity1_id)
     AND org.active_ind=outerjoin(1))
   ORDER BY wt.short_desc
   HEAD wt.short_desc
    orgs = "", org_count = 0, cnt = (cnt+ 1),
    high_volume_cnt = (high_volume_cnt+ 1), stat = alterlist(templates->qual,cnt), templates->qual[
    cnt].long_text = lt.long_text,
    templates->qual[cnt].long_desc = wt.description, templates->qual[cnt].long_text_id = lt
    .long_text_id, templates->qual[cnt].short_desc = wt.short_desc,
    templates->qual[cnt].template_id = wt.template_id
    IF (wt.template_type_cd=template_type_cd)
     templates->qual[cnt].template_type = "Template"
    ELSEIF (wt.template_type_cd=letter_type_cd)
     templates->qual[cnt].template_type = "Letter"
    ENDIF
    templates->qual[cnt].person_id = wt.person_id
   DETAIL
    org_count = (org_count+ 1)
    IF (orgs="")
     orgs = org.org_name
    ELSE
     orgs = build2(orgs,", ",org.org_name)
    ENDIF
   FOOT  wt.short_desc
    templates->qual[cnt].orgs = orgs
    IF (org_count > max_org_cnt)
     max_org_cnt = org_count
    ENDIF
   WITH nocounter
  ;end select
  IF ((request->skip_volume_check_ind=0))
   IF (((max_org_cnt > max_org) OR (high_volume_cnt > max_reply2)) )
    SET reply->high_volume_flag = 2
    GO TO exit_script
   ELSEIF (high_volume_cnt > max_reply1)
    SET reply->high_volume_flag = 1
    GO TO exit_script
   ENDIF
  ENDIF
  CALL bederrorcheck("Error 004: Retreiving templates")
 ENDIF
 IF (size(templates->qual,5) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = size(templates->qual,5)),
    prsnl p
   PLAN (d
    WHERE (templates->qual[d.seq].person_id > 0))
    JOIN (p
    WHERE (p.person_id=templates->qual[d.seq].person_id)
     AND p.active_ind=1)
   ORDER BY d.seq
   DETAIL
    templates->qual[d.seq].pdisp = concat(trim(p.name_last_key),",",trim(p.name_first_key))
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error 005: Retreiving prsnl display")
 ENDIF
 SET maxlist = size(templates->qual,5)
 SET cnt = 0
 SET stat = alterlist(reply->rowlist,maxlist)
 WHILE (cnt < maxlist)
   SET cnt = (cnt+ 1)
   SET stat = alterlist(reply->rowlist[cnt].celllist,8)
   SET outbuffer = ""
   SET retbuflen = 0
   SET bflag = 1
   SET outbuflen = 1000
   CALL uar_rtf(templates->qual[cnt].long_text,size(templates->qual[cnt].long_text),outbuffer,
    outbuflen,retbuflen,
    bflag)
   SET reply->rowlist[cnt].celllist[1].double_value = templates->qual[cnt].template_id
   SET reply->rowlist[cnt].celllist[2].string_value = templates->qual[cnt].short_desc
   SET reply->rowlist[cnt].celllist[3].string_value = templates->qual[cnt].long_desc
   SET reply->rowlist[cnt].celllist[4].string_value = templates->qual[cnt].template_type
   SET reply->rowlist[cnt].celllist[5].double_value = templates->qual[cnt].long_text_id
   SET reply->rowlist[cnt].celllist[6].string_value = outbuffer
   IF ((templates->qual[cnt].orgs=" "))
    SET reply->rowlist[cnt].celllist[7].string_value = "All Facilities"
   ELSE
    SET reply->rowlist[cnt].celllist[7].string_value = templates->qual[cnt].orgs
   ENDIF
   SET reply->rowlist[cnt].celllist[8].string_value = templates->qual[cnt].pdisp
 ENDWHILE
 SUBROUTINE populateparsestringbasedonrequest(dummyvar)
   SET templates_parse = "wt.active_ind = 1"
   IF (validate(request->search_string,"") > " ")
    IF (validate(request->search_type_flag,"") > " ")
     IF ((request->search_type_flag IN ("S", "s"))
      AND (request->search_string > " "))
      SET templates_parse = concat(templates_parse," and cnvtupper(wt.short_desc) = '",cnvtupper(trim
        (request->search_string)),"*'")
     ELSEIF ((request->search_type_flag IN ("C", "c"))
      AND (request->search_string > " "))
      SET templates_parse = concat(templates_parse," and cnvtupper(wt.short_desc) = '*",cnvtupper(
        trim(request->search_string)),"*'")
     ENDIF
    ENDIF
   ENDIF
   IF (validate(request->is_template_type_template)
    AND validate(request->is_template_type_letter))
    IF ((request->is_template_type_template=1)
     AND (request->is_template_type_letter=0))
     SET templates_parse = concat(templates_parse," and wt.template_type_cd in (template_type_cd) ")
    ELSEIF ((request->is_template_type_letter=1)
     AND (request->is_template_type_template=0))
     SET templates_parse = concat(templates_parse," and wt.template_type_cd in (letter_type_cd) ")
    ELSE
     SET templates_parse = concat(templates_parse,
      " and wt.template_type_cd in (template_type_cd, letter_type_cd) ")
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("genlab_word_templates_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL bedexitscript(0)
END GO
