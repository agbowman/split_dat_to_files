CREATE PROGRAM bed_aud_oef_flex:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
    1 oeflist[*]
      2 oef_id = f8
    1 cataloglist[*]
      2 catalog_id = f8
    1 flexlist[*]
      2 flex_type_ind = i2
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp
 RECORD temp(
   1 formats[*]
     2 format_id = f8
     2 name = vc
     2 details[*]
       3 field_id = f8
       3 action_type_cd = f8
       3 order_action = c40
       3 flex_type = i2
       3 flex_value = c40
       3 field_name = vc
       3 label_text = vc
       3 accept_flag = i2
       3 default_display = c40
       3 default = vc
       3 update_person = vc
       3 default_parent_entity_name = vc
       3 default_parent_entity_id = f8
       3 codset = vc
       3 def_code_val = vc
       3 default_accept_flag = i2
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
 DECLARE ordering_loc = i2 WITH protect, constant(0)
 DECLARE patient_loc = i2 WITH protect, constant(1)
 DECLARE application = i2 WITH protect, constant(2)
 DECLARE position = i2 WITH protect, constant(3)
 DECLARE encounter = i2 WITH protect, constant(4)
 DECLARE oef_parse = vc WITH protect
 DECLARE catalog_parse = vc WITH protect
 DECLARE parseoefandcatalogtype(dummyvar=i2) = i2
 DECLARE getflextypeapplication(dummyvar=i2) = i2
 DECLARE getflextypeencounter(dummyvar=i2) = i2
 DECLARE getflextypeorderinglocation(dummyvar=i2) = i2
 DECLARE getflextypepatientlocation(dummyvar=i2) = i2
 DECLARE getflextypeposition(dummyvar=i2) = i2
 SET stat = alterlist(reply->collist,11)
 SET reply->collist[1].header_text = "Order Entry Format Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Order Action"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Flex Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Flex Value"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Field Name"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Label Text"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Accept Value"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Default Value"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Default Code Value"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 1
 SET reply->collist[10].header_text = "Default Code Set"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 1
 SET reply->collist[11].header_text = "Last Update By"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 CALL parseoefandcatalogtypeitems(0)
 SET high_volume_cnt = 0
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM order_entry_format oef,
   accept_format_flexing aff,
   oe_format_fields oeff,
   order_entry_fields oefields,
   code_value cv1,
   code_value cv2
  PLAN (oef
   WHERE parser(oef_parse))
   JOIN (oeff
   WHERE oef.oe_format_id=oeff.oe_format_id
    AND oef.action_type_cd=oeff.action_type_cd)
   JOIN (aff
   WHERE oeff.oe_format_id=aff.oe_format_id
    AND oeff.oe_field_id=aff.oe_field_id
    AND oeff.action_type_cd=aff.action_type_cd)
   JOIN (oefields
   WHERE oeff.oe_field_id=oefields.oe_field_id)
   JOIN (cv1
   WHERE aff.action_type_cd=cv1.code_value
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE aff.flex_cd=cv2.code_value
    AND cv2.active_ind=1)
  ORDER BY oef.oe_format_name, oef.oe_format_id, aff.action_type_cd
  HEAD oef.oe_format_id
   tcnt = (tcnt+ 1), stat = alterlist(temp->formats,tcnt), temp->formats[tcnt].format_id = oef
   .oe_format_id,
   temp->formats[tcnt].name = oef.oe_format_name
  DETAIL
   high_volume_cnt = (high_volume_cnt+ 1)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error[1] Failure in getting order entry format.")
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 IF ((request->skip_volume_check_ind=0))
  IF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   SET stat = alterlist(reply->collist,0)
   GO TO exit_script
  ELSEIF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   SET stat = alterlist(reply->collist,0)
   GO TO exit_script
  ENDIF
 ENDIF
 SET build_cd = uar_get_code_by("MEANING",222,"BUILDING")
 SET facility_cd = uar_get_code_by("MEANING",222,"FACILITY")
 IF (size(request->flexlist,5) > 0)
  FOR (i = 1 TO size(request->flexlist,5))
    CASE (request->flexlist[i].flex_type_ind)
     OF ordering_loc:
      CALL getflextypeorderinglocation(0)
     OF patient_loc:
      CALL getflextypepatientlocation(0)
     OF application:
      CALL getflextypeapplication(0)
     OF position:
      CALL getflextypeposition(0)
     OF encounter:
      CALL getflextypeencounter(0)
    ENDCASE
  ENDFOR
 ELSE
  CALL getflextypeorderinglocation(0)
  CALL getflextypepatientlocation(0)
  CALL getflextypeapplication(0)
  CALL getflextypeposition(0)
  CALL getflextypeencounter(0)
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET tcnt1 = size(temp->formats[x].details,5)
   FOR (a = 1 TO tcnt1)
     IF ((temp->formats[x].details[a].default="1"))
      SET temp->formats[x].details[a].default = "Yes"
     ELSEIF ((temp->formats[x].details[a].default="0"))
      SET temp->formats[x].details[a].default = "No"
     ENDIF
   ENDFOR
   IF (tcnt1 > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(tcnt1)),
      code_value cv,
      order_entry_fields oefields
     PLAN (d
      WHERE (temp->formats[x].details[d.seq].default_parent_entity_name="CODE_VALUE"))
      JOIN (oefields
      WHERE (oefields.description=temp->formats[x].details[d.seq].field_name))
      JOIN (cv
      WHERE cv.code_set=oefields.codeset
       AND (cv.code_value=temp->formats[x].details[d.seq].default_parent_entity_id)
       AND cv.active_ind=1)
     DETAIL
      temp->formats[x].details[d.seq].default = cv.display, temp->formats[x].details[d.seq].
      def_code_val = cnvtstring(cv.code_value), temp->formats[x].details[d.seq].codset = cnvtstring(
       cv.code_set)
     WITH nocounter
    ;end select
    CALL bederrorcheck("Error[2] Failure in getting order entry format description.")
   ENDIF
   FOR (s = 1 TO tcnt1)
     SET row_nbr = (row_nbr+ 1)
     SET stat = alterlist(reply->rowlist,row_nbr)
     SET stat = alterlist(reply->rowlist[row_nbr].celllist,11)
     SET reply->rowlist[row_nbr].celllist[1].string_value = temp->formats[x].name
     SET reply->rowlist[row_nbr].celllist[2].string_value = temp->formats[x].details[s].order_action
     IF ((temp->formats[x].details[s].flex_type=0))
      SET reply->rowlist[row_nbr].celllist[3].string_value = "Order Location"
     ELSEIF ((temp->formats[x].details[s].flex_type=1))
      SET reply->rowlist[row_nbr].celllist[3].string_value = "Patient Location"
     ELSEIF ((temp->formats[x].details[s].flex_type=2))
      SET reply->rowlist[row_nbr].celllist[3].string_value = "Application"
     ELSEIF ((temp->formats[x].details[s].flex_type=3))
      SET reply->rowlist[row_nbr].celllist[3].string_value = "Position"
     ELSEIF ((temp->formats[x].details[s].flex_type=4))
      SET reply->rowlist[row_nbr].celllist[3].string_value = "Encounter Type"
     ENDIF
     SET reply->rowlist[row_nbr].celllist[4].string_value = temp->formats[x].details[s].flex_value
     SET reply->rowlist[row_nbr].celllist[5].string_value = temp->formats[x].details[s].field_name
     SET reply->rowlist[row_nbr].celllist[6].string_value = temp->formats[x].details[s].label_text
     IF ((temp->formats[x].details[s].default_accept_flag != temp->formats[x].details[s].accept_flag)
     )
      IF ((temp->formats[x].details[s].accept_flag=0))
       SET reply->rowlist[row_nbr].celllist[7].string_value = "Required"
      ELSEIF ((temp->formats[x].details[s].accept_flag=1))
       SET reply->rowlist[row_nbr].celllist[7].string_value = "Optional"
      ELSEIF ((temp->formats[x].details[s].accept_flag=3))
       SET reply->rowlist[row_nbr].celllist[7].string_value = "Display Only"
      ELSEIF ((temp->formats[x].details[s].accept_flag=2))
       SET reply->rowlist[row_nbr].celllist[7].string_value = "Do Not Display"
      ENDIF
     ENDIF
     SET reply->rowlist[row_nbr].celllist[8].string_value = temp->formats[x].details[s].default
     SET reply->rowlist[row_nbr].celllist[9].string_value = temp->formats[x].details[s].def_code_val
     SET reply->rowlist[row_nbr].celllist[10].string_value = temp->formats[x].details[s].codset
     SET reply->rowlist[row_nbr].celllist[11].string_value = temp->formats[x].details[s].
     update_person
   ENDFOR
 ENDFOR
 SUBROUTINE parseoefandcatalogtypeitems(dummyvar)
  SET oef_parse = "oef.oe_format_id > 0"
  IF (validate(request->oeflist)
   AND validate(request->cataloglist))
   SET id_count = 0
   IF (size(request->oeflist,5) > 0)
    SET oef_parse = "oef.oe_format_id in("
    FOR (i = 1 TO size(request->oeflist,5))
     IF (id_count > 999)
      SET oef_parse = replace(oef_parse,",","",2)
      SET oef_parse = build(oef_parse,") or oef.oe_format_id in(")
      SET id_count = 0
     ENDIF
     SET oef_parse = build(oef_parse,request->oeflist[i].oef_id,",")
    ENDFOR
    SET oef_parse = trim(substring(1,(size(oef_parse,1) - 1),oef_parse))
    SET oef_parse = build(oef_parse,")")
   ENDIF
   SET id_count = 0
   IF (size(request->cataloglist,5) > 0)
    SET oef_parse = build("(",oef_parse,") and (oef.catalog_type_cd in(")
    FOR (i = 1 TO size(request->cataloglist,5))
      IF (id_count > 999)
       SET oef_parse = replace(oef_parse,",","",2)
       SET oef_parse = build(oef_parse,") or oef.catalog_type_cd in(")
       SET id_count = 0
      ENDIF
      SET oef_parse = build(oef_parse,request->cataloglist[i].catalog_id,",")
      SET id_count = (id_count+ 1)
    ENDFOR
    SET oef_parse = trim(substring(1,(size(oef_parse,1) - 1),oef_parse))
    SET oef_parse = build(oef_parse,"))")
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE getflextypeposition(dummyvar)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tcnt),
    accept_format_flexing aff,
    oe_format_fields oeff,
    prsnl p,
    order_entry_fields oefields,
    code_value cv1,
    code_value cv2
   PLAN (d)
    JOIN (oeff
    WHERE (oeff.oe_format_id=temp->formats[d.seq].format_id))
    JOIN (aff
    WHERE oeff.oe_format_id=aff.oe_format_id
     AND oeff.oe_field_id=aff.oe_field_id
     AND oeff.action_type_cd=aff.action_type_cd
     AND aff.flex_type_flag=3)
    JOIN (oefields
    WHERE oeff.oe_field_id=oefields.oe_field_id)
    JOIN (cv1
    WHERE aff.action_type_cd=cv1.code_value
     AND cv1.active_ind=1)
    JOIN (cv2
    WHERE aff.flex_cd=cv2.code_value
     AND cv2.code_set=88
     AND cv2.active_ind=1)
    JOIN (p
    WHERE p.person_id=outerjoin(aff.updt_id)
     AND p.active_ind=outerjoin(1))
   ORDER BY d.seq, aff.action_type_cd, cv2.display,
    oeff.group_seq, oeff.field_seq
   HEAD d.seq
    tcnt1 = size(temp->formats[d.seq].details,5)
   DETAIL
    tcnt1 = (tcnt1+ 1), stat = alterlist(temp->formats[d.seq].details,tcnt1), temp->formats[d.seq].
    details[tcnt1].field_id = aff.oe_field_id,
    temp->formats[d.seq].details[tcnt1].action_type_cd = aff.action_type_cd, temp->formats[d.seq].
    details[tcnt1].order_action = cv1.display, temp->formats[d.seq].details[tcnt1].flex_type = aff
    .flex_type_flag,
    temp->formats[d.seq].details[tcnt1].flex_value = cv2.display, temp->formats[d.seq].details[tcnt1]
    .field_name = oefields.description, temp->formats[d.seq].details[tcnt1].label_text = oeff
    .label_text,
    temp->formats[d.seq].details[tcnt1].accept_flag = aff.accept_flag, temp->formats[d.seq].details[
    tcnt1].default_accept_flag = oeff.accept_flag, temp->formats[d.seq].details[tcnt1].default = aff
    .default_value,
    temp->formats[d.seq].details[tcnt1].update_person = p.name_full_formatted, temp->formats[d.seq].
    details[tcnt1].default_parent_entity_name = aff.default_parent_entity_name, temp->formats[d.seq].
    details[tcnt1].default_parent_entity_id = aff.default_parent_entity_id
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error[3] Failure in getting positions flex types.")
 END ;Subroutine
 SUBROUTINE getflextypeorderinglocation(dummyvar)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tcnt),
    accept_format_flexing aff,
    oe_format_fields oeff,
    prsnl p,
    order_entry_fields oefields,
    code_value cv1,
    code_value cv2,
    location_group lg,
    code_value cv3,
    location_group lg1,
    code_value cv4
   PLAN (d)
    JOIN (oeff
    WHERE (oeff.oe_format_id=temp->formats[d.seq].format_id))
    JOIN (aff
    WHERE oeff.oe_format_id=aff.oe_format_id
     AND oeff.oe_field_id=aff.oe_field_id
     AND oeff.action_type_cd=aff.action_type_cd
     AND aff.flex_type_flag=0)
    JOIN (lg
    WHERE aff.flex_cd=lg.child_loc_cd
     AND lg.location_group_type_cd=build_cd
     AND lg.root_loc_cd=0
     AND lg.active_ind=1)
    JOIN (cv3
    WHERE lg.parent_loc_cd=cv3.code_value
     AND cv3.active_ind=1)
    JOIN (lg1
    WHERE lg.parent_loc_cd=lg1.child_loc_cd
     AND lg1.location_group_type_cd=facility_cd
     AND lg1.root_loc_cd=0
     AND lg1.active_ind=1)
    JOIN (cv4
    WHERE lg1.parent_loc_cd=cv4.code_value
     AND cv4.active_ind=1)
    JOIN (oefields
    WHERE oeff.oe_field_id=oefields.oe_field_id)
    JOIN (cv1
    WHERE aff.action_type_cd=cv1.code_value
     AND cv1.active_ind=1)
    JOIN (cv2
    WHERE aff.flex_cd=cv2.code_value
     AND cv2.active_ind=1)
    JOIN (p
    WHERE p.person_id=outerjoin(aff.updt_id)
     AND p.active_ind=outerjoin(1))
   ORDER BY d.seq, aff.action_type_cd, cv2.display,
    oeff.group_seq, oeff.field_seq
   HEAD d.seq
    tcnt1 = size(temp->formats[d.seq].details,5)
   DETAIL
    tcnt1 = (tcnt1+ 1), stat = alterlist(temp->formats[d.seq].details,tcnt1), temp->formats[d.seq].
    details[tcnt1].field_id = aff.oe_field_id,
    temp->formats[d.seq].details[tcnt1].action_type_cd = aff.action_type_cd, temp->formats[d.seq].
    details[tcnt1].order_action = cv1.display, temp->formats[d.seq].details[tcnt1].flex_type = aff
    .flex_type_flag,
    temp->formats[d.seq].details[tcnt1].flex_value = concat(trim(cv4.display),"/",trim(cv3.display),
     "/",cv2.display), temp->formats[d.seq].details[tcnt1].field_name = oefields.description, temp->
    formats[d.seq].details[tcnt1].label_text = oeff.label_text,
    temp->formats[d.seq].details[tcnt1].accept_flag = aff.accept_flag, temp->formats[d.seq].details[
    tcnt1].default_accept_flag = oeff.accept_flag, temp->formats[d.seq].details[tcnt1].default = aff
    .default_value,
    temp->formats[d.seq].details[tcnt1].update_person = p.name_full_formatted, temp->formats[d.seq].
    details[tcnt1].default_parent_entity_name = aff.default_parent_entity_name, temp->formats[d.seq].
    details[tcnt1].default_parent_entity_id = aff.default_parent_entity_id
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error[4] Failure in getting ordering location flex types.")
 END ;Subroutine
 SUBROUTINE getflextypepatientlocation(dummyvar)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tcnt),
    accept_format_flexing aff,
    oe_format_fields oeff,
    prsnl p,
    order_entry_fields oefields,
    code_value cv1,
    code_value cv2,
    location_group lg,
    code_value cv3,
    location_group lg1,
    code_value cv4
   PLAN (d)
    JOIN (oeff
    WHERE (oeff.oe_format_id=temp->formats[d.seq].format_id))
    JOIN (aff
    WHERE oeff.oe_format_id=aff.oe_format_id
     AND oeff.oe_field_id=aff.oe_field_id
     AND oeff.action_type_cd=aff.action_type_cd
     AND aff.flex_type_flag=1)
    JOIN (lg
    WHERE aff.flex_cd=lg.child_loc_cd
     AND lg.location_group_type_cd=build_cd
     AND lg.root_loc_cd=0
     AND lg.active_ind=1)
    JOIN (cv3
    WHERE lg.parent_loc_cd=cv3.code_value
     AND cv3.active_ind=1)
    JOIN (lg1
    WHERE lg1.child_loc_cd=lg.parent_loc_cd
     AND lg1.location_group_type_cd=facility_cd
     AND lg1.root_loc_cd=0
     AND lg1.active_ind=1)
    JOIN (cv4
    WHERE lg1.parent_loc_cd=cv4.code_value
     AND cv4.active_ind=1)
    JOIN (oefields
    WHERE oeff.oe_field_id=oefields.oe_field_id)
    JOIN (cv1
    WHERE aff.action_type_cd=cv1.code_value
     AND cv1.active_ind=1)
    JOIN (cv2
    WHERE aff.flex_cd=cv2.code_value
     AND cv2.active_ind=1)
    JOIN (p
    WHERE p.person_id=outerjoin(aff.updt_id)
     AND p.active_ind=outerjoin(1))
   ORDER BY d.seq, aff.action_type_cd, cv2.display,
    oeff.group_seq, oeff.field_seq
   HEAD d.seq
    tcnt1 = size(temp->formats[d.seq].details,5)
   DETAIL
    tcnt1 = (tcnt1+ 1), stat = alterlist(temp->formats[d.seq].details,tcnt1), temp->formats[d.seq].
    details[tcnt1].field_id = aff.oe_field_id,
    temp->formats[d.seq].details[tcnt1].action_type_cd = aff.action_type_cd, temp->formats[d.seq].
    details[tcnt1].order_action = cv1.display, temp->formats[d.seq].details[tcnt1].flex_type = aff
    .flex_type_flag,
    temp->formats[d.seq].details[tcnt1].flex_value = concat(trim(cv4.display),"/",trim(cv3.display),
     "/",cv2.display), temp->formats[d.seq].details[tcnt1].field_name = oefields.description, temp->
    formats[d.seq].details[tcnt1].label_text = oeff.label_text,
    temp->formats[d.seq].details[tcnt1].accept_flag = aff.accept_flag, temp->formats[d.seq].details[
    tcnt1].default_accept_flag = oeff.accept_flag, temp->formats[d.seq].details[tcnt1].default = aff
    .default_value,
    temp->formats[d.seq].details[tcnt1].update_person = p.name_full_formatted, temp->formats[d.seq].
    details[tcnt1].default_parent_entity_name = aff.default_parent_entity_name, temp->formats[d.seq].
    details[tcnt1].default_parent_entity_id = aff.default_parent_entity_id
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error[5] Failure in getting patient location flex types.")
 END ;Subroutine
 SUBROUTINE getflextypeencounter(dummyvar)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tcnt),
    accept_format_flexing aff,
    oe_format_fields oeff,
    prsnl p,
    order_entry_fields oefields,
    code_value cv1,
    code_value cv2
   PLAN (d)
    JOIN (oeff
    WHERE (oeff.oe_format_id=temp->formats[d.seq].format_id))
    JOIN (aff
    WHERE oeff.oe_format_id=aff.oe_format_id
     AND oeff.oe_field_id=aff.oe_field_id
     AND oeff.action_type_cd=aff.action_type_cd
     AND aff.flex_type_flag=4)
    JOIN (oefields
    WHERE oeff.oe_field_id=oefields.oe_field_id)
    JOIN (cv1
    WHERE aff.action_type_cd=cv1.code_value
     AND cv1.active_ind=1)
    JOIN (cv2
    WHERE aff.flex_cd=cv2.code_value
     AND cv2.code_set=71
     AND cv2.active_ind=1)
    JOIN (p
    WHERE p.person_id=outerjoin(aff.updt_id)
     AND p.active_ind=outerjoin(1))
   ORDER BY d.seq, aff.action_type_cd, cv2.display,
    oeff.group_seq, oeff.field_seq
   HEAD d.seq
    tcnt1 = size(temp->formats[d.seq].details,5)
   DETAIL
    tcnt1 = (tcnt1+ 1), stat = alterlist(temp->formats[d.seq].details,tcnt1), temp->formats[d.seq].
    details[tcnt1].field_id = aff.oe_field_id,
    temp->formats[d.seq].details[tcnt1].action_type_cd = aff.action_type_cd, temp->formats[d.seq].
    details[tcnt1].order_action = cv1.display, temp->formats[d.seq].details[tcnt1].flex_type = aff
    .flex_type_flag,
    temp->formats[d.seq].details[tcnt1].flex_value = cv2.display, temp->formats[d.seq].details[tcnt1]
    .field_name = oefields.description, temp->formats[d.seq].details[tcnt1].label_text = oeff
    .label_text,
    temp->formats[d.seq].details[tcnt1].accept_flag = aff.accept_flag, temp->formats[d.seq].details[
    tcnt1].default_accept_flag = oeff.accept_flag, temp->formats[d.seq].details[tcnt1].default = aff
    .default_value,
    temp->formats[d.seq].details[tcnt1].update_person = p.name_full_formatted, temp->formats[d.seq].
    details[tcnt1].default_parent_entity_name = aff.default_parent_entity_name, temp->formats[d.seq].
    details[tcnt1].default_parent_entity_id = aff.default_parent_entity_id
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error[6] Failure in getting encounter type flex types.")
 END ;Subroutine
 SUBROUTINE getflextypeapplication(dummyvar)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tcnt),
    accept_format_flexing aff,
    oe_format_fields oeff,
    prsnl p,
    order_entry_fields oefields,
    code_value cv1,
    code_value cv2
   PLAN (d)
    JOIN (oeff
    WHERE (oeff.oe_format_id=temp->formats[d.seq].format_id))
    JOIN (aff
    WHERE oeff.oe_format_id=aff.oe_format_id
     AND oeff.oe_field_id=aff.oe_field_id
     AND oeff.action_type_cd=aff.action_type_cd
     AND aff.flex_type_flag=2)
    JOIN (oefields
    WHERE oeff.oe_field_id=oefields.oe_field_id)
    JOIN (cv1
    WHERE aff.action_type_cd=cv1.code_value
     AND cv1.active_ind=1)
    JOIN (cv2
    WHERE aff.flex_cd=cv2.code_value
     AND cv2.active_ind=1)
    JOIN (p
    WHERE p.person_id=outerjoin(aff.updt_id)
     AND p.active_ind=outerjoin(1))
   ORDER BY d.seq, aff.action_type_cd, cv2.display,
    oeff.group_seq, oeff.field_seq
   HEAD d.seq
    tcnt1 = size(temp->formats[d.seq].details,5)
   DETAIL
    tcnt1 = (tcnt1+ 1), stat = alterlist(temp->formats[d.seq].details,tcnt1), temp->formats[d.seq].
    details[tcnt1].field_id = aff.oe_field_id,
    temp->formats[d.seq].details[tcnt1].action_type_cd = aff.action_type_cd, temp->formats[d.seq].
    details[tcnt1].order_action = cv1.display, temp->formats[d.seq].details[tcnt1].flex_type = aff
    .flex_type_flag,
    temp->formats[d.seq].details[tcnt1].flex_value = cv2.display, temp->formats[d.seq].details[tcnt1]
    .field_name = oefields.description, temp->formats[d.seq].details[tcnt1].label_text = oeff
    .label_text,
    temp->formats[d.seq].details[tcnt1].accept_flag = aff.accept_flag, temp->formats[d.seq].details[
    tcnt1].default_accept_flag = oeff.accept_flag, temp->formats[d.seq].details[tcnt1].default = aff
    .default_value,
    temp->formats[d.seq].details[tcnt1].update_person = p.name_full_formatted, temp->formats[d.seq].
    details[tcnt1].default_parent_entity_name = aff.default_parent_entity_name, temp->formats[d.seq].
    details[tcnt1].default_parent_entity_id = aff.default_parent_entity_id
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error[7] Failure in getting application flex types.")
 END ;Subroutine
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("oef_flex.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL bedexitscript(0)
END GO
