CREATE PROGRAM bed_aud_cn_emar_addl_element
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 tasks[*]
      2 id = f8
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
 DECLARE med_task_list = vc
 SET med_task_list = " "
 SELECT INTO "NL:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=6026
   AND cv.cdf_meaning="MED"
  DETAIL
   IF (med_task_list=" ")
    med_task_list = build(" ot.task_type_cd in (",cv.code_value)
   ELSE
    med_task_list = build(med_task_list,",",cv.code_value)
   ENDIF
  WITH nocounter, noheading
 ;end select
 CALL bederrorcheck("Error001: Eror retrieving task_type_cd from the code_value table")
 SET med_task_list = concat(med_task_list,")")
 SET ackresultmin_offset_type_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4002164
   AND cv.cdf_meaning="ACKRESULTMIN"
   AND cv.active_ind=1
  DETAIL
   ackresultmin_offset_type_cd = cv.code_value
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error002: Eror retrieving ackresultmin_offset_type_cd from the code_value table"
  )
 SET tcnt = 0
 IF (validate(request->tasks[1].id))
  SET tcnt = size(request->tasks,5)
 ENDIF
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  IF (tcnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(tcnt)),
     task_discrete_r tdr,
     order_task ot
    PLAN (d)
     JOIN (tdr
     WHERE (tdr.reference_task_id=request->tasks[d.seq].id))
     JOIN (ot
     WHERE ot.reference_task_id=tdr.reference_task_id
      AND parser(med_task_list)
      AND ot.active_ind=1)
    DETAIL
     high_volume_cnt = (high_volume_cnt+ 1)
    WITH nocounter
   ;end select
   CALL bederrorcheck(
    "Error003:Eror retrieving total rows count from the task_discrete_r and order_task table for a specific task"
    )
  ELSE
   SELECT INTO "nl:"
    hv_cnt = count(*)
    FROM task_discrete_r tdr,
     order_task ot
    PLAN (tdr)
     JOIN (ot
     WHERE ot.reference_task_id=tdr.reference_task_id
      AND parser(med_task_list)
      AND ot.active_ind=1)
    DETAIL
     high_volume_cnt = hv_cnt
    WITH nocounter
   ;end select
   CALL bederrorcheck(
    "Error004: Eror retrieving total rows count from the task_discrete_r and order_task table")
  ENDIF
  IF (high_volume_cnt > 1500)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 1000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,8)
 SET reply->collist[1].header_text = "Medication Task"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Assay Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Activity Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Required"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Document"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Acknowledge"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "View Only"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Lookback Minutes"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 IF (tcnt > 0)
  SELECT INTO "nl:"
   ot.task_description, cv.display, tdr.required_ind
   FROM (dummyt d  WITH seq = value(tcnt)),
    task_discrete_r tdr,
    order_task ot,
    code_value cv,
    discrete_task_assay dta,
    code_value cv1,
    dta_offset_min dom
   PLAN (d)
    JOIN (tdr
    WHERE (tdr.reference_task_id=request->tasks[d.seq].id))
    JOIN (ot
    WHERE ot.reference_task_id=tdr.reference_task_id
     AND parser(med_task_list)
     AND ot.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=tdr.task_assay_cd)
    JOIN (dta
    WHERE dta.task_assay_cd=tdr.task_assay_cd
     AND dta.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=dta.activity_type_cd
     AND cv1.active_ind=1)
    JOIN (dom
    WHERE dom.task_assay_cd=outerjoin(tdr.task_assay_cd)
     AND dom.offset_min_type_cd=outerjoin(ackresultmin_offset_type_cd)
     AND dom.active_ind=outerjoin(1))
   ORDER BY ot.task_description, tdr.sequence
   HEAD REPORT
    cnt = 0, stat = alterlist(reply->rowlist,50)
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,50)=0)
     stat = alterlist(reply->rowlist,(50+ cnt))
    ENDIF
    stat = alterlist(reply->rowlist[cnt].celllist,8), reply->rowlist[cnt].celllist[1].string_value =
    ot.task_description, reply->rowlist[cnt].celllist[2].string_value = cv.display,
    reply->rowlist[cnt].celllist[3].string_value = cv1.display
    CASE (tdr.required_ind)
     OF 0:
      reply->rowlist[cnt].celllist[4].string_value = " "
     OF 1:
      reply->rowlist[cnt].celllist[4].string_value = "X"
    ENDCASE
    CASE (tdr.document_ind)
     OF 0:
      reply->rowlist[cnt].celllist[5].string_value = " "
     OF 1:
      reply->rowlist[cnt].celllist[5].string_value = "X"
    ENDCASE
    CASE (tdr.acknowledge_ind)
     OF 0:
      reply->rowlist[cnt].celllist[6].string_value = " "
     OF 1:
      reply->rowlist[cnt].celllist[6].string_value = "X"
    ENDCASE
    CASE (tdr.view_only_ind)
     OF 0:
      reply->rowlist[cnt].celllist[7].string_value = " "
     OF 1:
      reply->rowlist[cnt].celllist[7].string_value = "X"
    ENDCASE
    IF (dom.offset_min_nbr > 0)
     reply->rowlist[cnt].celllist[8].string_value = cnvtstring(dom.offset_min_nbr)
    ELSE
     reply->rowlist[cnt].celllist[8].string_value = " "
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->rowlist,cnt)
   WITH nocounter, noheading
  ;end select
  CALL bederrorcheck("Error005: Eror retrieving tasks for a specific task_id")
 ELSE
  SELECT INTO "nl:"
   ot.task_description, cv.display, tdr.required_ind
   FROM task_discrete_r tdr,
    order_task ot,
    code_value cv,
    discrete_task_assay dta,
    code_value cv1,
    dta_offset_min dom
   PLAN (tdr)
    JOIN (ot
    WHERE ot.reference_task_id=tdr.reference_task_id
     AND parser(med_task_list)
     AND ot.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=tdr.task_assay_cd)
    JOIN (dta
    WHERE dta.task_assay_cd=tdr.task_assay_cd
     AND dta.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=dta.activity_type_cd
     AND cv1.active_ind=1)
    JOIN (dom
    WHERE dom.task_assay_cd=outerjoin(tdr.task_assay_cd)
     AND dom.offset_min_type_cd=outerjoin(ackresultmin_offset_type_cd)
     AND dom.active_ind=outerjoin(1))
   ORDER BY ot.task_description, tdr.sequence
   HEAD REPORT
    cnt = 0, stat = alterlist(reply->rowlist,50)
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,50)=0)
     stat = alterlist(reply->rowlist,(50+ cnt))
    ENDIF
    stat = alterlist(reply->rowlist[cnt].celllist,8), reply->rowlist[cnt].celllist[1].string_value =
    ot.task_description, reply->rowlist[cnt].celllist[2].string_value = cv.display,
    reply->rowlist[cnt].celllist[3].string_value = cv1.display
    CASE (tdr.required_ind)
     OF 0:
      reply->rowlist[cnt].celllist[4].string_value = " "
     OF 1:
      reply->rowlist[cnt].celllist[4].string_value = "X"
    ENDCASE
    CASE (tdr.document_ind)
     OF 0:
      reply->rowlist[cnt].celllist[5].string_value = " "
     OF 1:
      reply->rowlist[cnt].celllist[5].string_value = "X"
    ENDCASE
    CASE (tdr.acknowledge_ind)
     OF 0:
      reply->rowlist[cnt].celllist[6].string_value = " "
     OF 1:
      reply->rowlist[cnt].celllist[6].string_value = "X"
    ENDCASE
    CASE (tdr.view_only_ind)
     OF 0:
      reply->rowlist[cnt].celllist[7].string_value = " "
     OF 1:
      reply->rowlist[cnt].celllist[7].string_value = "X"
    ENDCASE
    IF (dom.offset_min_nbr > 0)
     reply->rowlist[cnt].celllist[8].string_value = cnvtstring(dom.offset_min_nbr)
    ELSE
     reply->rowlist[cnt].celllist[8].string_value = " "
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->rowlist,cnt)
   WITH nocounter, noheading
  ;end select
  CALL bederrorcheck("Error006: Eror retrieving tasks")
 ENDIF
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("carenet_emar_addl_element.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL bedexitscript(0)
END GO
