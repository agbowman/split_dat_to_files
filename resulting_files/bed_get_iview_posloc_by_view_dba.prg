CREATE PROGRAM bed_get_iview_posloc_by_view:dba
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 positions[*]
      2 entry_id = f8
      2 code_value = f8
      2 display = vc
      2 mean = vc
      2 context_id = vc
    1 position_locations[*]
      2 entry_id = f8
      2 position_code_value = f8
      2 position_display = vc
      2 position_mean = vc
      2 location_code_value = f8
      2 location_display = vc
      2 location_mean = vc
      2 location_desc = vc
      2 context_id = vc
      2 inactive_location_ind = i2
      2 invalid_location_ind = i2
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
   1 position_locations[*]
     2 entry_id = f8
     2 position_code_value = f8
     2 position_display = vc
     2 position_mean = vc
     2 location_code_value = f8
     2 location_display = vc
     2 location_mean = vc
     2 location_desc = vc
     2 context_id = vc
     2 inactive_location_ind = i2
     2 invalid_location_ind = i2
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
 DECLARE find_match(temp_search_exp=vc,source_exp=vc,start_pos=i4) = i4
 DECLARE logical_domain_id = i4 WITH protect, constant(bedgetlogicaldomain(0))
 SET reply->status_data.status = "F"
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE pcnt = i4 WITH protect, noconstant(0)
 DECLARE plcnt = i4 WITH protect, noconstant(0)
 DECLARE view_name = vc
 DECLARE found_str = i4 WITH protect
 SET view_name = build("prefvalue:",cnvtlower(request->view_name))
 SELECT INTO "nl:"
  FROM prefdir_entrydata p1,
   prefdir_entrydata p2,
   prefdir_entrydata p3,
   prefdir_entrydata p4,
   prefdir_entrydata p5
  PLAN (p1
   WHERE p1.dist_name_short="prefcontext=position,prefroot=prefroot")
   JOIN (p2
   WHERE p2.parent_id=p1.entry_id)
   JOIN (p3
   WHERE p3.parent_id=p2.entry_id
    AND substring(1,19,p3.dist_name)="prefgroup=component")
   JOIN (p4
   WHERE p4.parent_id=p3.entry_id
    AND substring(1,18,p4.dist_name)="prefgroup=powerdoc")
   JOIN (p5
   WHERE p5.parent_id=p4.entry_id
    AND substring(1,26,p5.dist_name)="prefentry=documentsettypes")
  HEAD REPORT
   a = 0, b = 0, z = 0
  HEAD p2.entry_id
   found_str = find_match(view_name,p5.entry_data,1)
   IF (found_str > 0)
    pcnt = (pcnt+ 1), stat = alterlist(reply->positions,pcnt), reply->positions[pcnt].entry_id = p2
    .entry_id,
    a = findstring(",",p2.dist_name), b = (a - 11), reply->positions[pcnt].context_id = substring(11,
     b,p2.dist_name),
    reply->positions[pcnt].code_value = cnvtint(substring(11,b,p2.dist_name))
   ENDIF
  WITH nocounter
 ;end select
 IF (pcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(pcnt)),
    code_value c
   PLAN (d)
    JOIN (c
    WHERE (c.code_value=reply->positions[d.seq].code_value))
   ORDER BY d.seq
   HEAD d.seq
    reply->positions[d.seq].display = c.display, reply->positions[d.seq].mean = c.cdf_meaning
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM prefdir_entrydata p1,
   prefdir_entrydata p2,
   prefdir_entrydata p3,
   prefdir_entrydata p4,
   prefdir_entrydata p5
  PLAN (p1
   WHERE p1.dist_name_short="prefcontext=position location,prefroot=prefroot")
   JOIN (p2
   WHERE p2.parent_id=p1.entry_id)
   JOIN (p3
   WHERE p3.parent_id=p2.entry_id
    AND substring(1,19,p3.dist_name)="prefgroup=component")
   JOIN (p4
   WHERE p4.parent_id=p3.entry_id
    AND substring(1,18,p4.dist_name)="prefgroup=powerdoc")
   JOIN (p5
   WHERE p5.parent_id=p4.entry_id
    AND substring(1,26,p5.dist_name)="prefentry=documentsettypes")
  HEAD REPORT
   a = 0, b = 0, c = 0,
   d = 0, z = 0
  HEAD p2.entry_id
   found_str = find_match(view_name,p5.entry_data,1)
   IF (found_str > 0)
    lcnt = (lcnt+ 1), stat = alterlist(temp->position_locations,lcnt), temp->position_locations[lcnt]
    .entry_id = p2.entry_id,
    a = findstring(",",p2.dist_name), b = findstring("^",p2.dist_name), c = (b - 11),
    d = (a - 11), temp->position_locations[lcnt].context_id = substring(11,d,p2.dist_name), temp->
    position_locations[lcnt].position_code_value = cnvtint(substring(11,c,p2.dist_name)),
    temp->position_locations[lcnt].location_code_value = cnvtint(substring((b+ 1),((d - c) - 1),p2
      .dist_name))
   ENDIF
  WITH nocounter
 ;end select
 IF (lcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(lcnt)),
    code_value c
   PLAN (d)
    JOIN (c
    WHERE (c.code_value=temp->position_locations[d.seq].position_code_value))
   ORDER BY d.seq
   HEAD d.seq
    temp->position_locations[d.seq].position_display = c.display, temp->position_locations[d.seq].
    position_mean = c.cdf_meaning
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(lcnt)),
    code_value c
   PLAN (d)
    JOIN (c
    WHERE (c.code_value=temp->position_locations[d.seq].location_code_value))
   ORDER BY d.seq
   HEAD d.seq
    temp->position_locations[d.seq].location_display = c.display, temp->position_locations[d.seq].
    location_mean = c.cdf_meaning, temp->position_locations[d.seq].location_desc = c.description
    IF (c.active_ind=0)
     temp->position_locations[d.seq].inactive_location_ind = 1
    ENDIF
    IF (c.cdf_meaning IN ("BUILDING", "FACILITY"))
     temp->position_locations[d.seq].invalid_location_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  FOR (x = 1 TO size(temp->position_locations,5))
    IF ((temp->position_locations[x].location_mean="FACILITY"))
     SELECT INTO "nl:"
      FROM code_value c,
       location l,
       organization o
      PLAN (c
       WHERE (c.code_value=temp->position_locations[x].location_code_value))
       JOIN (l
       WHERE l.location_cd=c.code_value)
       JOIN (o
       WHERE o.organization_id=l.organization_id
        AND o.logical_domain_id=logical_domain_id)
      ORDER BY c.code_value
      HEAD c.code_value
       plcnt = (plcnt+ 1), stat = alterlist(reply->position_locations,plcnt), reply->
       position_locations[plcnt].location_code_value = c.code_value,
       reply->position_locations[plcnt].location_display = c.display, reply->position_locations[plcnt
       ].location_mean = c.cdf_meaning, reply->position_locations[plcnt].location_desc = c
       .description,
       reply->position_locations[plcnt].position_code_value = temp->position_locations[x].
       position_code_value, reply->position_locations[plcnt].position_display = temp->
       position_locations[x].position_display, reply->position_locations[plcnt].position_mean = temp
       ->position_locations[x].position_mean,
       reply->position_locations[plcnt].invalid_location_ind = temp->position_locations[x].
       invalid_location_ind, reply->position_locations[plcnt].inactive_location_ind = temp->
       position_locations[x].inactive_location_ind, reply->position_locations[plcnt].entry_id = temp
       ->position_locations[x].entry_id,
       reply->position_locations[plcnt].context_id = temp->position_locations[x].context_id
      WITH nocounter
     ;end select
    ELSEIF ((temp->position_locations[x].location_mean="BUILDING"))
     SELECT INTO "nl:"
      FROM code_value c,
       location_group lg,
       location l,
       organization o
      PLAN (c
       WHERE (c.code_value=temp->position_locations[x].location_code_value))
       JOIN (lg
       WHERE lg.child_loc_cd=c.code_value
        AND lg.active_ind=1)
       JOIN (l
       WHERE l.location_cd=lg.parent_loc_cd
        AND l.organization_id > 0.0)
       JOIN (o
       WHERE o.organization_id=l.organization_id
        AND o.logical_domain_id=logical_domain_id)
      ORDER BY c.code_value
      HEAD c.code_value
       plcnt = (plcnt+ 1), stat = alterlist(reply->position_locations,plcnt), reply->
       position_locations[plcnt].location_code_value = c.code_value,
       reply->position_locations[plcnt].location_display = c.display, reply->position_locations[plcnt
       ].location_mean = c.cdf_meaning, reply->position_locations[plcnt].location_desc = c
       .description,
       reply->position_locations[plcnt].position_code_value = temp->position_locations[x].
       position_code_value, reply->position_locations[plcnt].position_display = temp->
       position_locations[x].position_display, reply->position_locations[plcnt].position_mean = temp
       ->position_locations[x].position_mean,
       reply->position_locations[plcnt].invalid_location_ind = temp->position_locations[x].
       invalid_location_ind, reply->position_locations[plcnt].inactive_location_ind = temp->
       position_locations[x].inactive_location_ind, reply->position_locations[plcnt].entry_id = temp
       ->position_locations[x].entry_id,
       reply->position_locations[plcnt].context_id = temp->position_locations[x].context_id
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM code_value c,
       location_group lg1,
       location_group lg2,
       location l,
       organization o
      PLAN (c
       WHERE (c.code_value=temp->position_locations[x].location_code_value))
       JOIN (lg1
       WHERE lg1.child_loc_cd=c.code_value
        AND lg1.active_ind=1)
       JOIN (lg2
       WHERE lg2.child_loc_cd=lg1.parent_loc_cd
        AND lg2.active_ind=1)
       JOIN (l
       WHERE l.location_cd=lg2.parent_loc_cd
        AND l.organization_id > 0.0)
       JOIN (o
       WHERE o.organization_id=l.organization_id
        AND o.logical_domain_id=logical_domain_id)
      ORDER BY c.code_value
      HEAD c.code_value
       plcnt = (plcnt+ 1), stat = alterlist(reply->position_locations,plcnt), reply->
       position_locations[plcnt].location_code_value = c.code_value,
       reply->position_locations[plcnt].location_display = c.display, reply->position_locations[plcnt
       ].location_mean = c.cdf_meaning, reply->position_locations[plcnt].location_desc = c
       .description,
       reply->position_locations[plcnt].position_code_value = temp->position_locations[x].
       position_code_value, reply->position_locations[plcnt].position_display = temp->
       position_locations[x].position_display, reply->position_locations[plcnt].position_mean = temp
       ->position_locations[x].position_mean,
       reply->position_locations[plcnt].invalid_location_ind = temp->position_locations[x].
       invalid_location_ind, reply->position_locations[plcnt].inactive_location_ind = temp->
       position_locations[x].inactive_location_ind, reply->position_locations[plcnt].entry_id = temp
       ->position_locations[x].entry_id,
       reply->position_locations[plcnt].context_id = temp->position_locations[x].context_id
      WITH nocounter
     ;end select
    ENDIF
  ENDFOR
 ENDIF
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
 SUBROUTINE find_match(temp_search_exp,source_exp,start_pos)
   DECLARE idx = i4 WITH noconstant(start_pos), protect
   DECLARE found_flag = i4 WITH protect
   DECLARE next_char = i4
   DECLARE search_exp = vc
   SET search_exp = trim(temp_search_exp)
   SET found_flag = - (9)
   SET idx = findstring(search_exp,source_exp,idx)
   IF (idx > 0)
    SET next_char = ichar(substring((idx+ textlen(search_exp)),1,source_exp))
    IF (next_char IN (10, 0))
     SET found_flag = 1
     SET idx = 0
    ENDIF
   ENDIF
   IF (idx > 0)
    SET next_char = ichar(substring((idx+ textlen(search_exp)),1,source_exp))
    IF (next_char IN (32, 13))
     SET next_char = ichar(substring(((idx+ textlen(search_exp))+ 1),1,source_exp))
     IF (next_char IN (112))
      SET found_flag = 2
      SET idx = 0
     ENDIF
    ENDIF
   ENDIF
   RETURN(found_flag)
 END ;Subroutine
END GO
