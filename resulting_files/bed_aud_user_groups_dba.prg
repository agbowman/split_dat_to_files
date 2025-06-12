CREATE PROGRAM bed_aud_user_groups:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 user_group_type[*]
      2 type_cd = f8
    1 user_group_class[*]
      2 class_cd = f8
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
      2 qualifying_items = i8
      2 total_items = i8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD tempreply
 RECORD tempreply(
   1 user_groups[*]
     2 user_group_id = f8
     2 user_group_name = vc
     2 user_group_active_ind = i4
     2 user_group_class_disp = vc
     2 personnel[*]
       3 person_id = f8
       3 person_name = vc
       3 person_active_ind = i4
       3 prsn_end_effective_date = dq8
       3 position_display = vc
       3 logical_domain_id = f8
       3 prsn_grp_active_ind = i4
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
 DECLARE bed_is_logical_domain(dummyvar=i2) = i2
 DECLARE bed_get_logical_domain(dummyvar=i2) = f8
 SUBROUTINE bed_is_logical_domain(dummyvar)
   RETURN(checkprg("ACM_GET_CURR_LOGICAL_DOMAIN"))
 END ;Subroutine
 SUBROUTINE bed_get_logical_domain(dummyvar)
  IF (bed_is_logical_domain(null))
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
   IF ( NOT (acm_get_curr_logical_domain_rep->status_block.status_ind)
    AND checkfun("BEDERROR"))
    CALL bederror(build("Logical Domain Error: ",acm_get_curr_logical_domain_rep->status_block.
      error_code))
   ENDIF
   RETURN(acm_get_curr_logical_domain_rep->logical_domain_id)
  ENDIF
  RETURN(null)
 END ;Subroutine
 CALL bedbeginscript(0)
 DECLARE typefiltersize = i4 WITH protect, noconstant(0)
 DECLARE classfiltersize = i4 WITH protect, noconstant(0)
 DECLARE usergroupexpression = vc WITH protect, noconstant(" ")
 DECLARE num1 = i4 WITH protect, noconstant(1)
 DECLARE num2 = i4 WITH protect, noconstant(1)
 DECLARE getusergroups(dummyvar=i2) = i2
 DECLARE getpersonnelforusergroups(dummyvar=i2) = i2
 DECLARE populatereportreply(dummyvar=i2) = i2
 DECLARE ishighvolume(dummyvar=i2) = i2
 SET typefiltersize = size(request->user_group_type,5)
 SET classfiltersize = size(request->user_group_class,5)
 SET usergroupexpression = build2(usergroupexpression,"pg.prsnl_group_id > 0")
 IF (typefiltersize > 0)
  SET usergroupexpression = build2(usergroupexpression," and expand(num1, 1, value(typeFilterSize),")
  SET usergroupexpression = build2(usergroupexpression,
   "pg.prsnl_group_type_cd, request->user_group_type[num1].type_cd)")
 ENDIF
 IF (classfiltersize > 0)
  SET usergroupexpression = build2(usergroupexpression," and expand(num2, 1, value(classFilterSize),"
   )
  SET usergroupexpression = build2(usergroupexpression,
   "pg.prsnl_group_class_cd, request->user_group_class[num2].class_cd)")
 ENDIF
 IF ((request->skip_volume_check_ind=0))
  IF (ishighvolume(0))
   SET reply->status_data.status = "S"
   GO TO exit_script
  ENDIF
 ENDIF
 CALL getusergroups(0)
 CALL getpersonnelforusergroups(0)
 CALL populatereportreply(0)
#exit_script
 CALL bedexitscript(0)
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("user_group_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SUBROUTINE getusergroups(dummyvar)
   CALL bedlogmessage("getUserGroups","Entering ...")
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM prsnl_group pg,
     code_value cv,
     code_value cv1
    PLAN (pg
     WHERE parser(usergroupexpression))
     JOIN (cv
     WHERE cv.code_value=pg.prsnl_group_type_cd
      AND cv.display > " ")
     JOIN (cv1
     WHERE cv1.code_value=outerjoin(pg.prsnl_group_class_cd))
    ORDER BY pg.prsnl_group_id
    HEAD pg.prsnl_group_id
     cnt = (cnt+ 1), stat = alterlist(tempreply->user_groups,cnt), tempreply->user_groups[cnt].
     user_group_id = pg.prsnl_group_id,
     tempreply->user_groups[cnt].user_group_name = cv.display, tempreply->user_groups[cnt].
     user_group_active_ind = pg.active_ind, tempreply->user_groups[cnt].user_group_class_disp = cv1
     .display
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed to retrieve user groups.")
   CALL bedlogmessage("getUserGroups","Exiting ...")
 END ;Subroutine
 SUBROUTINE getpersonnelforusergroups(dummyvar)
   CALL bedlogmessage("getPersonnelForUserGroups","Entering ...")
   DECLARE cnt = i4 WITH protect, noconstant(0)
   IF (size(tempreply->user_groups,5) > 0)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = size(tempreply->user_groups,5)),
      prsnl_group_reltn pgr,
      prsnl p
     PLAN (d)
      JOIN (pgr
      WHERE (pgr.prsnl_group_id=tempreply->user_groups[d.seq].user_group_id))
      JOIN (p
      WHERE p.person_id=pgr.person_id)
     ORDER BY pgr.prsnl_group_id
     HEAD pgr.prsnl_group_id
      cnt = 0
     DETAIL
      cnt = (cnt+ 1), stat = alterlist(tempreply->user_groups[d.seq].personnel,cnt), tempreply->
      user_groups[d.seq].personnel[cnt].person_id = p.person_id,
      tempreply->user_groups[d.seq].personnel[cnt].person_name = p.name_full_formatted, tempreply->
      user_groups[d.seq].personnel[cnt].person_active_ind = p.active_ind, tempreply->user_groups[d
      .seq].personnel[cnt].prsn_end_effective_date = cnvtdatetime(p.end_effective_dt_tm),
      tempreply->user_groups[d.seq].personnel[cnt].position_display = uar_get_code_display(p
       .position_cd), tempreply->user_groups[d.seq].personnel[cnt].logical_domain_id = p
      .logical_domain_id, tempreply->user_groups[d.seq].personnel[cnt].prsn_grp_active_ind = pgr
      .active_ind
     WITH nocounter
    ;end select
   ENDIF
   CALL bederrorcheck("Failed to retrieve personnel.")
   CALL bedlogmessage("getPersonnelForUserGroups","Exiting ...")
 END ;Subroutine
 SUBROUTINE populatereportreply(dummyvar)
   CALL bedlogmessage("populateReportReply","Entering ...")
   DECLARE rowcount = i4 WITH protect, noconstant(0)
   DECLARE personnelcnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(reply->collist,10)
   SET reply->collist[1].header_text = "User Group"
   SET reply->collist[1].data_type = 1
   SET reply->collist[1].hide_ind = 0
   SET reply->collist[2].header_text = "Class Code"
   SET reply->collist[2].data_type = 1
   SET reply->collist[2].hide_ind = 0
   SET reply->collist[3].header_text = "Active/Inactive"
   SET reply->collist[3].data_type = 1
   SET reply->collist[3].hide_ind = 0
   SET reply->collist[4].header_text = "Person Name"
   SET reply->collist[4].data_type = 1
   SET reply->collist[4].hide_ind = 0
   SET reply->collist[5].header_text = "Person ID"
   SET reply->collist[5].data_type = 2
   SET reply->collist[5].hide_ind = 0
   SET reply->collist[6].header_text = "Person Active/Inactive"
   SET reply->collist[6].data_type = 1
   SET reply->collist[6].hide_ind = 0
   SET reply->collist[7].header_text = "Person End Effective Date"
   SET reply->collist[7].data_type = 4
   SET reply->collist[7].hide_ind = 0
   SET reply->collist[8].header_text = "Position"
   SET reply->collist[8].data_type = 1
   SET reply->collist[8].hide_ind = 0
   SET reply->collist[9].header_text = "Logical Domain ID"
   SET reply->collist[9].data_type = 2
   SET reply->collist[9].hide_ind = 0
   SET reply->collist[10].header_text = "Relationship Active/Inactive"
   SET reply->collist[10].data_type = 1
   SET reply->collist[10].hide_ind = 0
   FOR (x = 1 TO size(tempreply->user_groups,5))
     SET personnelcnt = size(tempreply->user_groups[x].personnel,5)
     FOR (y = 1 TO personnelcnt)
       SET rowcount = (rowcount+ 1)
       SET stat = alterlist(reply->rowlist,rowcount)
       SET stat = alterlist(reply->rowlist[rowcount].celllist,10)
       SET reply->rowlist[rowcount].celllist[1].string_value = tempreply->user_groups[x].
       user_group_name
       SET reply->rowlist[rowcount].celllist[2].string_value = tempreply->user_groups[x].
       user_group_class_disp
       IF ((tempreply->user_groups[x].user_group_active_ind=1))
        SET reply->rowlist[rowcount].celllist[3].string_value = "A"
       ELSE
        SET reply->rowlist[rowcount].celllist[3].string_value = "I"
       ENDIF
       SET reply->rowlist[rowcount].celllist[4].string_value = tempreply->user_groups[x].personnel[y]
       .person_name
       SET reply->rowlist[rowcount].celllist[5].double_value = tempreply->user_groups[x].personnel[y]
       .person_id
       IF ((tempreply->user_groups[x].personnel[y].person_active_ind=1))
        SET reply->rowlist[rowcount].celllist[6].string_value = "A"
       ELSE
        SET reply->rowlist[rowcount].celllist[6].string_value = "I"
       ENDIF
       SET reply->rowlist[rowcount].celllist[7].date_value = tempreply->user_groups[x].personnel[y].
       prsn_end_effective_date
       SET reply->rowlist[rowcount].celllist[8].string_value = tempreply->user_groups[x].personnel[y]
       .position_display
       SET reply->rowlist[rowcount].celllist[9].double_value = tempreply->user_groups[x].personnel[y]
       .logical_domain_id
       IF ((tempreply->user_groups[x].personnel[y].prsn_grp_active_ind=1))
        SET reply->rowlist[rowcount].celllist[10].string_value = "A"
       ELSE
        SET reply->rowlist[rowcount].celllist[10].string_value = "I"
       ENDIF
     ENDFOR
     IF (personnelcnt=0)
      SET rowcount = (rowcount+ 1)
      SET stat = alterlist(reply->rowlist,rowcount)
      SET stat = alterlist(reply->rowlist[rowcount].celllist,10)
      SET reply->rowlist[rowcount].celllist[1].string_value = tempreply->user_groups[x].
      user_group_name
      SET reply->rowlist[rowcount].celllist[2].string_value = tempreply->user_groups[x].
      user_group_class_disp
      IF ((tempreply->user_groups[x].user_group_active_ind=1))
       SET reply->rowlist[rowcount].celllist[3].string_value = "A"
      ELSE
       SET reply->rowlist[rowcount].celllist[3].string_value = "I"
      ENDIF
     ENDIF
   ENDFOR
   CALL bedlogmessage("populateReportReply","Exiting ...")
 END ;Subroutine
 SUBROUTINE ishighvolume(dummyvar)
   CALL bedlogmessage("isHighVolume","Entering ...")
   DECLARE high_volume_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM prsnl_group pg,
     code_value cv,
     prsnl_group_reltn pgr,
     prsnl p
    PLAN (pg
     WHERE parser(usergroupexpression))
     JOIN (cv
     WHERE cv.code_value=pg.prsnl_group_type_cd
      AND cv.display > " ")
     JOIN (pgr
     WHERE pgr.prsnl_group_id=outerjoin(pg.prsnl_group_id))
     JOIN (p
     WHERE p.person_id=outerjoin(pgr.person_id))
    DETAIL
     high_volume_cnt = (high_volume_cnt+ 1)
    WITH nocounter
   ;end select
   CALL bederrorcheck("Failed to determine high volume count.")
   CALL echo(build("high volume cnt: ",high_volume_cnt))
   IF (high_volume_cnt > 10000)
    SET reply->high_volume_flag = 2
   ELSEIF (high_volume_cnt > 3000)
    SET reply->high_volume_flag = 1
   ENDIF
   CALL bedlogmessage("isHighVolume","Exiting ...")
   IF ((reply->high_volume_flag IN (1, 2)))
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
END GO
