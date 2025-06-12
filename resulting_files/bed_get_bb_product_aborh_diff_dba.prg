CREATE PROGRAM bed_get_bb_product_aborh_diff:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 glist[*]
      2 group_type_code_value = f8
      2 group_type_disp = vc
      2 diff_list[*]
        3 prod_list[*]
          4 product_code_value = f8
          4 product_code_disp = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD temp(
   1 glist[*]
     2 type_cd = f8
     2 plist[*]
       3 prod_cd = f8
       3 prod_disp = vc
       3 aborh_flag = i2
       3 cmd_flag = i2
       3 dis_flag = i2
       3 ad_flag = i2
       3 clist[*]
         4 ctype_cd = f8
         4 warn_flag = i2
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
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE product_cnt = i4 WITH protect, noconstant(0)
 DECLARE gcnt = i4 WITH protect, noconstant(0)
 SET product_cnt = size(request->p_list,5)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set IN (1640, 1642)
    AND cv.active_ind=1)
  ORDER BY cv.code_value
  HEAD cv.code_value
   gcnt = (gcnt+ 1), stat = alterlist(reply->glist,gcnt), stat = alterlist(temp->glist,gcnt),
   reply->glist[gcnt].group_type_code_value = cv.code_value, reply->glist[gcnt].group_type_disp = cv
   .display, temp->glist[gcnt].type_cd = cv.code_value
  WITH nocounter
 ;end select
 CALL bederrorcheck("Failed to select rows for the code_sets 1640 and 1642")
 FOR (x = 1 TO gcnt)
  SET stat = alterlist(temp->glist[x].plist,product_cnt)
  FOR (y = 1 TO product_cnt)
    SET temp->glist[x].plist[y].prod_cd = request->p_list[y].product_code_value
    SET stat = alterlist(temp->glist[x].plist[y].clist,gcnt)
    FOR (z = 1 TO gcnt)
     SET temp->glist[x].plist[y].clist[z].ctype_cd = temp->glist[z].type_cd
     SET temp->glist[x].plist[y].clist[z].warn_flag = - (1)
    ENDFOR
  ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = gcnt),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,size(temp->glist[d1.seq].plist,5)))
   JOIN (d2)
  DETAIL
   temp->glist[d1.seq].plist[d2.seq].prod_disp = uar_get_code_display(temp->glist[d1.seq].plist[d2
    .seq].prod_cd)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Failed to retrieve display values from code_value table")
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(gcnt)),
   (dummyt d2  WITH seq = 1),
   product_aborh pa
  PLAN (d1
   WHERE maxrec(d2,size(temp->glist[d1.seq].plist,5)))
   JOIN (d2)
   JOIN (pa
   WHERE (pa.product_aborh_cd=temp->glist[d1.seq].type_cd)
    AND (pa.product_cd=request->p_list[d2.seq].product_code_value)
    AND pa.active_ind=1)
  DETAIL
   temp->glist[d1.seq].plist[d2.seq].aborh_flag = pa.aborh_option_flag, temp->glist[d1.seq].plist[d2
   .seq].cmd_flag = pa.no_gt_on_prsn_flag, temp->glist[d1.seq].plist[d2.seq].dis_flag = pa
   .disp_no_curraborh_prsn_flag,
   temp->glist[d1.seq].plist[d2.seq].ad_flag = pa.no_gt_autodir_prsn_flag
  WITH nocounter
 ;end select
 CALL bederrorcheck("Failed to retrieve rows from product_aborh table")
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(gcnt)),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   product_patient_aborh ppa
  PLAN (d1
   WHERE maxrec(d2,size(temp->glist[d1.seq].plist,5)))
   JOIN (d2
   WHERE maxrec(d3,size(temp->glist[d1.seq].plist[d2.seq].clist,5)))
   JOIN (d3)
   JOIN (ppa
   WHERE (ppa.product_cd=temp->glist[d1.seq].plist[d2.seq].prod_cd)
    AND (ppa.prod_aborh_cd=temp->glist[d1.seq].type_cd)
    AND (ppa.prsn_aborh_cd=temp->glist[d1.seq].plist[d2.seq].clist[d3.seq].ctype_cd)
    AND ppa.active_ind=1)
  DETAIL
   temp->glist[d1.seq].plist[d2.seq].clist[d3.seq].warn_flag = ppa.warn_ind
  WITH nocounter
 ;end select
 CALL bederrorcheck("Failed to retrieve rows from product_patient_aborh table")
 SET add_prod_cnt = 0
 SET add_diif_cnt = 0
 FOR (x = 1 TO gcnt)
   SET stat = alterlist(reply->glist[x].diff_list,1)
   SET stat = alterlist(reply->glist[x].diff_list[1].prod_list,1)
   SET reply->glist[x].diff_list[1].prod_list[1].product_code_value = temp->glist[x].plist[1].prod_cd
   SET reply->glist[x].diff_list[1].prod_list[1].product_code_disp = temp->glist[x].plist[1].
   prod_disp
   FOR (y = 1 TO product_cnt)
     SET save_diff = 0
     SET hold_match = 0
     SET match_ind = 0
     SET save_match_ind = 0
     SET diff_cnt = size(reply->glist[x].diff_list,5)
     FOR (q = 1 TO diff_cnt)
      SET prod_cd = reply->glist[x].diff_list[q].prod_list[1].product_code_value
      FOR (a = 1 TO product_cnt)
        IF ((prod_cd=temp->glist[x].plist[a].prod_cd))
         SET save_match_ind = 1
         FOR (z = 1 TO gcnt)
          IF ((temp->glist[x].plist[y].aborh_flag=temp->glist[x].plist[a].aborh_flag)
           AND (temp->glist[x].plist[y].cmd_flag=temp->glist[x].plist[a].cmd_flag)
           AND (temp->glist[x].plist[y].dis_flag=temp->glist[x].plist[a].dis_flag)
           AND (temp->glist[x].plist[y].ad_flag=temp->glist[x].plist[a].ad_flag)
           AND (temp->glist[x].plist[y].clist[z].warn_flag=temp->glist[x].plist[a].clist[z].warn_flag
          ))
           SET match_ind = 1
          ELSE
           SET save_match_ind = 0
          ENDIF
          IF ((temp->glist[x].plist[y].prod_cd=reply->glist[x].diff_list[q].prod_list[1].
          product_code_value))
           SET match_ind = 2
          ENDIF
         ENDFOR
         IF (match_ind != 2)
          IF (save_match_ind=0
           AND hold_match != 1)
           SET match_ind = 0
          ELSE
           SET hold_match = 1
           IF (save_diff=0)
            SET save_diff = q
           ENDIF
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
     ENDFOR
     IF (match_ind=1)
      SET add_prod_cnt = (size(reply->glist[x].diff_list[save_diff].prod_list,5)+ 1)
      SET stat = alterlist(reply->glist[x].diff_list[save_diff].prod_list,add_prod_cnt)
      SET reply->glist[x].diff_list[save_diff].prod_list[add_prod_cnt].product_code_value = temp->
      glist[x].plist[y].prod_cd
      SET reply->glist[x].diff_list[save_diff].prod_list[add_prod_cnt].product_code_disp = temp->
      glist[x].plist[y].prod_disp
     ENDIF
     IF (match_ind=0)
      SET add_diff_cnt = (size(reply->glist[x].diff_list,5)+ 1)
      SET stat = alterlist(reply->glist[x].diff_list,add_diff_cnt)
      SET stat = alterlist(reply->glist[x].diff_list[add_diff_cnt].prod_list,1)
      SET reply->glist[x].diff_list[add_diff_cnt].prod_list[1].product_code_value = temp->glist[x].
      plist[y].prod_cd
      SET reply->glist[x].diff_list[add_diff_cnt].prod_list[1].product_code_disp = temp->glist[x].
      plist[y].prod_disp
     ENDIF
   ENDFOR
 ENDFOR
#exit_script
 CALL bedexitscript(0)
END GO
