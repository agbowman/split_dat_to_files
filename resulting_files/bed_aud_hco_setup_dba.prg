CREATE PROGRAM bed_aud_hco_setup:dba
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
 FREE RECORD hcodata
 RECORD hcodata(
   1 hco[*]
     2 hco_id = f8
     2 hco_nbr = i4
     2 hco_name = vc
     2 locations[*]
       3 code_value = f8
       3 location_name[*]
         4 full_name = vc
 )
 FREE RECORD tempreply
 RECORD tempreply(
   1 hco[*]
     2 hco_id = vc
     2 hco_name = vc
     2 location_name = vc
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
 DECLARE column_cnt = i4 WITH protect, constant(3)
 DECLARE hco_id = i4 WITH protect, constant(1)
 DECLARE hco_name = i4 WITH protect, constant(2)
 DECLARE location_name = i4 WITH protect, constant(3)
 DECLARE computedisplay(x=i2,y=i2,location_cd=f8) = null
 FREE SET bld
 RECORD bld(
   1 qual[*]
     2 cd = f8
 )
 SET data_partition_ind = 0
 RANGE OF b IS br_hco
 SET data_partition_ind = validate(b.logical_domain_id)
 FREE RANGE b
 IF (data_partition_ind=1)
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
 ENDIF
 SET bparse = "b.br_hco_id > 0"
 IF (data_partition_ind=1)
  SET bparse = build2(bparse," and b.logical_domain_id = ",acm_get_curr_logical_domain_rep->
   logical_domain_id)
 ENDIF
 IF ((request->skip_volume_check_ind=0))
  IF (ishighvolume(0))
   SET reply->status_data.status = "S"
   GO TO exit_script
  ENDIF
 ENDIF
 CALL gethcodetails(0)
 CALL gethcolocationdetails(0)
 CALL populatereportheaders(0)
 CALL populatereportdata(0)
#exit_script
 CALL bedexitscript(0)
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("hco_setup.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SUBROUTINE ishighvolume(dummyvar)
   CALL bedlogmessage("isHighVolume","Entering ...")
   DECLARE high_volume_cnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM br_hco b
    WHERE parser(bparse)
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
 SUBROUTINE gethcodetails(dummyvar)
   SELECT INTO "nl:"
    FROM br_hco b
    WHERE parser(bparse)
    ORDER BY cnvtupper(b.hco_name)
    HEAD REPORT
     hco_cnt = 0, stat = alterlist(hcodata->hco,10)
    DETAIL
     hco_cnt = (hco_cnt+ 1)
     IF (mod(hco_cnt,10)=1)
      stat = alterlist(hcodata->hco,(hco_cnt+ 9))
     ENDIF
     hcodata->hco[hco_cnt].hco_id = b.br_hco_id, hcodata->hco[hco_cnt].hco_name = b.hco_name, hcodata
     ->hco[hco_cnt].hco_nbr = b.hco_nbr
    FOOT REPORT
     stat = alterlist(hcodata->hco,hco_cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE gethcolocationdetails(dummyvar)
  SET hcnt = size(hcodata->hco,5)
  IF (hcnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(hcnt)),
     br_hco_loc_reltn b1,
     code_value cv1
    PLAN (d)
     JOIN (b1
     WHERE (b1.br_hco_id=hcodata->hco[d.seq].hco_id))
     JOIN (cv1
     WHERE cv1.code_value=b1.location_cd
      AND cv1.active_ind=1)
    HEAD d.seq
     lcnt = 0
    HEAD b1.br_hco_loc_reltn_id
     lcnt = (lcnt+ 1), stat = alterlist(hcodata->hco[d.seq].locations,lcnt), hcodata->hco[d.seq].
     locations[lcnt].code_value = b1.location_cd
    WITH nocounter
   ;end select
   FOR (x = 1 TO size(hcodata->hco,5))
     FOR (y = 1 TO size(hcodata->hco[x].locations,5))
       CALL computedisplay(x,y,hcodata->hco[x].locations[y].code_value)
     ENDFOR
   ENDFOR
  ENDIF
 END ;Subroutine
 SUBROUTINE computedisplay(x,y,location_cd)
   DECLARE bcnt = i2 WITH protect, noconstant(0)
   DECLARE lcnt = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM location_group l
    WHERE l.child_loc_cd=location_cd
     AND l.root_loc_cd=0
     AND l.active_ind=1
    DETAIL
     bcnt = (bcnt+ 1), stat = alterlist(bld->qual,bcnt), bld->qual[bcnt].cd = l.parent_loc_cd
    WITH nocounter
   ;end select
   IF (bcnt > 0)
    FOR (i = 1 TO size(bld->qual,5))
      SELECT INTO "nl:"
       FROM location_group l,
        code_value c1,
        code_value c2,
        location_group l2,
        code_value c3,
        location l3
       PLAN (l
        WHERE (l.child_loc_cd=bld->qual[i].cd)
         AND l.root_loc_cd=0
         AND l.active_ind=1)
        JOIN (c1
        WHERE c1.code_value=l.parent_loc_cd
         AND c1.active_ind=1)
        JOIN (c2
        WHERE c2.code_value=l.child_loc_cd
         AND c2.active_ind=1)
        JOIN (l2
        WHERE l2.child_loc_cd=location_cd
         AND l2.active_ind=1)
        JOIN (c3
        WHERE c3.code_value=l2.child_loc_cd
         AND c3.active_ind=1)
        JOIN (l3
        WHERE l3.location_cd=l.child_loc_cd)
       HEAD c1.display
        name = build(trim(c1.display),"/",trim(c2.display),"/",trim(c3.display))
        IF (name > " ")
         lcnt = (lcnt+ 1), stat = alterlist(hcodata->hco[x].locations[y].location_name,lcnt), hcodata
         ->hco[x].locations[y].location_name[lcnt].full_name = name
        ENDIF
       WITH nocounter
      ;end select
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE populatereportheaders(dummyvar)
   SET stat = alterlist(reply->collist,column_cnt)
   SET reply->collist[hco_id].header_text = "Healthcare Organization Identifier"
   SET reply->collist[hco_id].data_type = 1
   SET reply->collist[hco_id].hide_ind = 0
   SET reply->collist[hco_name].header_text = "Healthcare Organization Name"
   SET reply->collist[hco_name].data_type = 1
   SET reply->collist[hco_name].hide_ind = 0
   SET reply->collist[location_name].header_text = "Location"
   SET reply->collist[location_name].data_type = 1
   SET reply->collist[location_name].hide_ind = 0
 END ;Subroutine
 SUBROUTINE populatereportdata(dummyvar)
   DECLARE rowcnt = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   FOR (ccnt = 1 TO size(hcodata->hco,5))
     SET rowcnt = (rowcnt+ 1)
     SET stat = alterlist(tempreply->hco,rowcnt)
     SET tempreply->hco[rowcnt].hco_id = cnvtstring(hcodata->hco[ccnt].hco_nbr)
     SET tempreply->hco[rowcnt].hco_name = hcodata->hco[ccnt].hco_name
     FOR (cnt = 1 TO size(hcodata->hco[ccnt].locations,5))
      SELECT INTO "nl:"
       FROM (dummyt d  WITH seq = size(hcodata->hco[ccnt].locations[cnt].location_name,5))
       PLAN (d)
       DETAIL
        IF ((hcodata->hco[ccnt].locations[cnt].location_name[d.seq].full_name > " "))
         tempreply->hco[rowcnt].location_name = hcodata->hco[ccnt].locations[cnt].location_name[d.seq
         ].full_name
         IF (d.seq < size(hcodata->hco[ccnt].locations[cnt].location_name,5))
          rowcnt = (rowcnt+ 1), stat = alterlist(tempreply->hco,rowcnt), tempreply->hco[rowcnt].
          hco_id = cnvtstring(hcodata->hco[ccnt].hco_nbr),
          tempreply->hco[rowcnt].hco_name = hcodata->hco[ccnt].hco_name
         ENDIF
        ENDIF
       WITH nocounter
      ;end select
      IF (cnt < size(hcodata->hco[ccnt].locations,5))
       SET rowcnt = (rowcnt+ 1)
       SET stat = alterlist(tempreply->hco,rowcnt)
       SET tempreply->hco[rowcnt].hco_id = cnvtstring(hcodata->hco[ccnt].hco_nbr)
       SET tempreply->hco[rowcnt].hco_name = hcodata->hco[ccnt].hco_name
      ENDIF
     ENDFOR
   ENDFOR
   SET rowcnt = 0
   SET size1 = size(tempreply->hco,5)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size1)
    PLAN (d)
    ORDER BY cnvtupper(tempreply->hco[d.seq].hco_name), cnvtupper(tempreply->hco[d.seq].location_name
      )
    HEAD REPORT
     rowcnt = 0
    DETAIL
     rowcnt = (rowcnt+ 1), stat = alterlist(reply->rowlist,rowcnt), stat = alterlist(reply->rowlist[
      rowcnt].celllist,column_cnt),
     reply->rowlist[rowcnt].celllist[1].string_value = tempreply->hco[d.seq].hco_id, reply->rowlist[
     rowcnt].celllist[2].string_value = tempreply->hco[d.seq].hco_name, reply->rowlist[rowcnt].
     celllist[3].string_value = tempreply->hco[d.seq].location_name
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error005: populateReportData")
 END ;Subroutine
END GO
