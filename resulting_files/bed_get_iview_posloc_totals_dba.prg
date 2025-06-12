CREATE PROGRAM bed_get_iview_posloc_totals:dba
 FREE SET reply
 RECORD reply(
   1 positions[*]
     2 code_value = f8
     2 display = vc
     2 mean = vc
   1 position_locations[*]
     2 position_code_value = f8
     2 position_display = vc
     2 position_mean = vc
     2 nbr_of_locations = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp
 RECORD temp(
   1 position_locations[*]
     2 position_code_value = f8
     2 position_display = vc
     2 position_mean = vc
     2 location_code_value = f8
 )
 EXECUTE prefrtl
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
 DECLARE checklogicaldomainforlocation(location_cd=f8) = i2
 DECLARE logical_domain_id = f8 WITH protect, constant(bedgetlogicaldomain(0))
 SET reply->status_data.status = "F"
 DECLARE pcnt = i4 WITH noconstant(0)
 DECLARE found_ind = i2 WITH noconstant(0)
 DECLARE a = i4 WITH noconstant(0)
 DECLARE b = i4 WITH noconstant(0)
 DECLARE c = i4 WITH noconstant(0)
 DECLARE hentry = i4 WITH noconstant(0)
 DECLARE acnt = i4 WITH noconstant(0)
 DECLARE count = i4
 DECLARE pos_cd = f8
 DECLARE dnstr = c255 WITH noconstant("")
 DECLARE grpstr = c255 WITH noconstant("")
 DECLARE valid_location_ind = i2 WITH protect, noconstant(0)
 DECLARE hpref = i4 WITH noconstant(0)
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefcontext=position,prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddfilter(hpref,"prefentry=documentsettypes")
 SET stat = uar_prefperform(hpref)
 SET stat = uar_prefgetentrycount(hpref,count)
 DECLARE i = i4 WITH noconstant(0)
 SET pos_cd = 0
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,255)
   SET a = findstring("prefgroup=",dnstr,1,1)
   SET b = findstring("=",dnstr,a)
   SET c = findstring(",",dnstr,a)
   SET grpstr = substring((b+ 1),((c - b) - 1),dnstr)
   SET pos_cd = cnvtreal(grpstr)
   IF (pos_cd > 0)
    SET pcnt = (pcnt+ 1)
    SET stat = alterlist(reply->positions,pcnt)
    SET reply->positions[pcnt].code_value = pos_cd
   ENDIF
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 IF (pcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(pcnt)),
    code_value c
   PLAN (d)
    JOIN (c
    WHERE (c.code_value=reply->positions[d.seq].code_value)
     AND ((c.code_set+ 0)=88))
   ORDER BY d.seq
   HEAD d.seq
    reply->positions[d.seq].display = c.display, reply->positions[d.seq].mean = c.cdf_meaning
   WITH nocounter
  ;end select
 ENDIF
 SET pcnt = 0
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefcontext=position location,prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddfilter(hpref,"prefentry=documentsettypes")
 SET stat = uar_prefperform(hpref)
 SET count = 0
 DECLARE loc_cd = f8
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 SET dnstr = ""
 SET grpstr = ""
 SET pos_cd = 0
 SET loc_cd = 0
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,255)
   SET a = findstring("prefgroup=",dnstr,1,1)
   SET b = findstring("=",dnstr,a)
   SET c = findstring(",",dnstr,a)
   SET grpstr = substring((b+ 1),((c - b) - 1),dnstr)
   SET a = findstring("^",grpstr)
   SET pos_cd = cnvtreal(substring(1,(a - 1),grpstr))
   SET b = textlen(grpstr)
   SET loc_cd = cnvtreal(substring((a+ 1),((b - a) - 1),grpstr))
   IF (pos_cd > 0
    AND loc_cd > 0)
    SET pcnt = (pcnt+ 1)
    SET stat = alterlist(temp->position_locations,pcnt)
    SET temp->position_locations[pcnt].position_code_value = pos_cd
    SET temp->position_locations[pcnt].location_code_value = loc_cd
    SET acnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,acnt)
   ENDIF
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 IF (pcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(pcnt)),
    code_value c
   PLAN (d)
    JOIN (c
    WHERE (c.code_value=temp->position_locations[d.seq].position_code_value)
     AND ((c.code_set+ 0)=88))
   ORDER BY d.seq
   HEAD d.seq
    temp->position_locations[d.seq].position_display = c.display, temp->position_locations[d.seq].
    position_mean = c.cdf_meaning
   WITH nocounter
  ;end select
 ENDIF
 SET pcnt = 0
 FOR (x = 1 TO size(temp->position_locations,5))
   SET valid_location_ind = checklogicaldomainforlocation(temp->position_locations[x].
    location_code_value)
   SET found_ind = 0
   FOR (p = 1 TO pcnt)
     IF ((reply->position_locations[p].position_code_value=temp->position_locations[x].
     position_code_value)
      AND valid_location_ind=1)
      SET reply->position_locations[p].nbr_of_locations = (reply->position_locations[p].
      nbr_of_locations+ 1)
      SET p = (pcnt+ 1)
      SET found_ind = 1
     ENDIF
   ENDFOR
   IF (found_ind=0
    AND valid_location_ind=1)
    SET pcnt = (pcnt+ 1)
    SET stat = alterlist(reply->position_locations,pcnt)
    SET reply->position_locations[pcnt].position_code_value = temp->position_locations[x].
    position_code_value
    SET reply->position_locations[pcnt].position_display = temp->position_locations[x].
    position_display
    SET reply->position_locations[pcnt].position_mean = temp->position_locations[x].position_mean
    SET reply->position_locations[p].nbr_of_locations = 1
   ENDIF
 ENDFOR
 SUBROUTINE checklogicaldomainforlocation(location_cd)
   DECLARE location_type = vc WITH noconstant("")
   DECLARE isvalid = i2 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_value=location_cd)
    DETAIL
     location_type = c.cdf_meaning
    WITH nocounter
   ;end select
   IF (location_type="FACILITY")
    SELECT INTO "nl:"
     FROM code_value c,
      location l,
      organization o
     PLAN (c
      WHERE c.code_value=location_cd)
      JOIN (l
      WHERE l.location_cd=c.code_value)
      JOIN (o
      WHERE o.organization_id=l.organization_id
       AND o.logical_domain_id=logical_domain_id)
     DETAIL
      isvalid = 1
     WITH nocounter
    ;end select
   ELSEIF (location_type="BUILDING")
    SELECT INTO "nl:"
     FROM code_value c,
      location_group lg,
      location l,
      organization o
     PLAN (c
      WHERE c.code_value=location_cd)
      JOIN (lg
      WHERE lg.child_loc_cd=c.code_value
       AND lg.active_ind=1)
      JOIN (l
      WHERE l.location_cd=lg.parent_loc_cd
       AND l.organization_id > 0.0)
      JOIN (o
      WHERE o.organization_id=l.organization_id
       AND o.logical_domain_id=logical_domain_id)
     DETAIL
      isvalid = 1
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
      WHERE c.code_value=location_cd)
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
     DETAIL
      isvalid = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(isvalid)
 END ;Subroutine
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
