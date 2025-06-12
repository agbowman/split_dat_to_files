CREATE PROGRAM bed_get_epcs_details:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 details[*]
      2 detail_id = f8
      2 detail_nominator_id = f8
      2 provider
        3 provider_id = f8
        3 provider_name_full_formatted = vc
        3 provider_first_name = vc
        3 provider_last_name = vc
        3 provider_username = vc
      2 location
        3 location_code_value = f8
        3 location_display = vc
        3 location_description = vc
        3 location_type_meaning = vc
      2 access_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 high_volume_flag = i2
  )
 ENDIF
 RECORD tempreply(
   1 details[*]
     2 detail_id = f8
     2 detail_nominator_id = f8
     2 provider
       3 provider_id = f8
       3 provider_name_full_formatted = vc
       3 provider_first_name = vc
       3 provider_last_name = vc
       3 provider_username = vc
     2 location
       3 location_code_value = f8
       3 location_display = vc
       3 location_description = vc
       3 location_type_meaning = vc
     2 access_ind = i2
 )
 RECORD temporgpersonnel(
   1 personnel[*]
     2 person_id = f8
     2 access_ind = i2
 )
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE getcountfordetails(detailparse=vc,pparse=vc,facility_filter=vc) = i4
 DECLARE deliveredcodevalue = f8 WITH protect, constant(uar_get_code_by("MEANING",3401,"DELIVERED"))
 DECLARE activestatuscodevalue = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE al3cid_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",320,"AL3CID"))
 DECLARE too_many_records_65535 = i4 WITH protect, constant(65535)
 DECLARE facilitycodevalue = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE ambulatorycodevalue = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"AMBULATORY"))
 DECLARE nurseunitcodevalue = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"NURSEUNIT"))
 DECLARE orgsecurityind = i4 WITH protect, noconstant(0)
 DECLARE detailcount = i4 WITH protect, noconstant(0)
 DECLARE orgcount = i4 WITH protect, noconstant(0)
 DECLARE orgpersonnelcount = i4 WITH protect, noconstant(0)
 DECLARE tempcount = i4 WITH protect, noconstant(0)
 DECLARE ipmmode = i2 WITH protect, noconstant(0)
 DECLARE detailparse = vc
 DECLARE pparse = vc
 DECLARE facility_filter = vc
 DECLARE field_found = i2 WITH protect, noconstant(0)
 DECLARE data_partition_ind = i2 WITH protect, noconstant(0)
 SET reply->high_volume_flag = 0
 SET detailparse = "ed.error_cd = 0"
 SET detailparse = build(detailparse," and ed.status_cd=",deliveredcodevalue)
 SET detailparse = concat(detailparse," and band(ed.service_level_nbr, 2048) > 0")
 SET detailparse = concat(detailparse," and ed.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)"
  )
 SET detailparse = concat(detailparse," and ed.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)")
 IF ((request->mode=1))
  SET detailparse = concat(detailparse," and ed.cs_approver_sig_txt <= ' ' ")
  SET detailparse = concat(detailparse," and ed.cs_nominator_id = 0")
 ELSEIF ((request->mode=2))
  SET detailparse = concat(detailparse," and ed.cs_approver_sig_txt <= ' ' ")
  SET detailparse = concat(detailparse," and ed.cs_nominator_id > 0")
  SELECT INTO "nl:"
   FROM br_name_value bnv
   WHERE bnv.br_client_id=0
    AND bnv.br_nv_key1="EPCSAPPROVALPATH"
    AND bnv.br_name="INDIVIDUALPROVIDERMODE"
    AND bnv.br_value="1"
   WITH nocounter
  ;end select
  CALL bederrorcheck("Error 003 : Error selecting ipm mode.")
  IF (curqual > 0)
   SET ipmmode = 1
  ENDIF
 ELSEIF ((request->mode=3))
  SET detailparse = concat(detailparse," and ed.cs_approver_sig_txt > ' '")
  SET detailparse = concat(detailparse," and ed.cs_nominator_id > 0")
 ENDIF
 SET facility_filter = "cv1.code_value = l.location_cd"
 IF (size(trim(request->facility_name)) > 0)
  SET facility_filter = concat(facility_filter," and cnvtupper(trim(cv1.description)) = ")
  IF ((request->startswith=1))
   SET facility_filter = concat(facility_filter,'"',cnvtupper(trim(request->facility_name)),'*"')
  ELSE
   SET facility_filter = concat(facility_filter,'"*',cnvtupper(trim(request->facility_name)),'*"')
  ENDIF
 ENDIF
 SET pparse = concat("p.person_id = pr.person_id"," and pr.active_ind = 1",
  " and pr.active_status_cd = activeStatusCodeValue",
  " and pr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)",
  " and pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)")
 IF (size(trim(request->last_name)) > 0)
  SET pparse = concat(pparse," and p.name_last_key = '",nullterm(cnvtalphanum(cnvtupper(trim(request
       ->last_name)))),"*'")
 ENDIF
 IF (size(trim(request->first_name)) > 0)
  SET pparse = concat(pparse," and p.name_first_key = '",nullterm(cnvtalphanum(cnvtupper(trim(request
       ->first_name)))),"*'")
 ENDIF
 IF (size(trim(request->username)) > 0)
  SET pparse = concat(pparse,' and cnvtupper(p.username) = "',nullterm(cnvtupper(trim(request->
      username))),'*"')
 ENDIF
 IF ((request->position_cd > 0))
  SET pparse = build(pparse," and p.position_cd = ",request->position_cd)
 ENDIF
 SET data_partition_ind = 0
 SET field_found = 0
 RANGE OF c IS code_value_set
 SET field_found = validate(c.br_client_id)
 FREE RANGE c
 IF (field_found=0)
  IF (checkprg("ACM_GET_ACC_LOGICAL_DOMAINS") > 0)
   SET field_found = 0
   RANGE OF p IS prsnl
   SET field_found = validate(p.logical_domain_id)
   FREE RANGE p
   IF (field_found=1)
    SET data_partition_ind = 1
    FREE SET acm_get_acc_logical_domains_req
    RECORD acm_get_acc_logical_domains_req(
      1 write_mode_ind = i2
      1 concept = i4
    )
    FREE SET acm_get_acc_logical_domains_rep
    RECORD acm_get_acc_logical_domains_rep(
      1 logical_domain_grp_id = f8
      1 logical_domains_cnt = i4
      1 logical_domains[*]
        2 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    SET acm_get_acc_logical_domains_req->write_mode_ind = 0
    SET acm_get_acc_logical_domains_req->concept = 2
    EXECUTE acm_get_acc_logical_domains  WITH replace("REQUEST",acm_get_acc_logical_domains_req),
    replace("REPLY",acm_get_acc_logical_domains_rep)
   ENDIF
  ENDIF
 ENDIF
 IF (data_partition_ind=1)
  IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
   SET pparse = concat(pparse," and p.logical_domain_id in (")
   FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
     IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
      SET pparse = build(pparse,acm_get_acc_logical_domains_rep->logical_domains[d].logical_domain_id,
       ")")
     ELSE
      SET pparse = build(pparse,acm_get_acc_logical_domains_rep->logical_domains[d].logical_domain_id,
       ",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info d
  PLAN (d
   WHERE d.info_domain="SECURITY"
    AND d.info_name="SEC_ORG_RELTN")
  DETAIL
   IF (d.info_number != 0)
    orgsecurityind = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error 002 : Error checking if org security is on or off.")
 IF (orgsecurityind > 0)
  SET emptystring = '""'
  SET pparse = build(pparse," and exists (select 'x' from prsnl_org_reltn por, prsnl_org_reltn ",
   " por2 "," where por.person_id = p.person_id ",
   " and por.beg_effective_dt_tm < cnvtdatetime(curdate, curtime3) ",
   " and por.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3) "," and por.active_ind = 1 ",
   " and por2.organization_id = por.organization_id "," and por2.person_id = reqinfo->updt_id ",
   " and por2.beg_effective_dt_tm < cnvtdatetime(curdate, curtime3) ",
   " and por2.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3) "," and por2.active_ind = 1)")
  IF (ipmmode=1)
   SET pparse = build(pparse," and exists (select 'x' from prsnl_alias pa ",
    " where pa.person_id = p.person_id "," and pa.prsnl_alias_type_cd = AL3CID_CD ",
    " and pa.alias > ",
    emptystring," and pa.active_ind = 1)")
  ENDIF
  SET detailcount = getcountfordetails(detailparse,pparse,facility_filter)
  IF (detailcount < too_many_records_65535)
   SELECT INTO "nl:"
    FROM eprescribe_detail ed,
     prsnl_reltn pr,
     prsnl p,
     location l,
     code_value cv1,
     code_value cv2
    PLAN (ed
     WHERE parser(detailparse))
     JOIN (pr
     WHERE pr.prsnl_reltn_id=ed.prsnl_reltn_id
      AND pr.active_ind=1
      AND pr.active_status_cd=activestatuscodevalue
      AND pr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (p
     WHERE parser(pparse))
     JOIN (l
     WHERE l.active_ind=1
      AND l.active_status_cd=activestatuscodevalue
      AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND l.location_cd=pr.parent_entity_id)
     JOIN (cv1
     WHERE parser(facility_filter))
     JOIN (cv2
     WHERE cv2.code_value=l.location_type_cd)
    HEAD REPORT
     detailcount = 0, tempcount = 0, stat = alterlist(reply->details,10)
    DETAIL
     detailcount = (detailcount+ 1), tempcount = (tempcount+ 1)
     IF (tempcount > 10)
      tempcount = 0, stat = alterlist(reply->details,(detailcount+ 10))
     ENDIF
     reply->details[detailcount].detail_id = ed.eprescribe_detail_id, reply->details[detailcount].
     detail_nominator_id = ed.cs_nominator_id, reply->details[detailcount].location.
     location_code_value = l.location_cd,
     reply->details[detailcount].location.location_description = cv1.description, reply->details[
     detailcount].location.location_display = cv1.display, reply->details[detailcount].location.
     location_type_meaning = cv2.cdf_meaning,
     reply->details[detailcount].provider.provider_id = p.person_id, reply->details[detailcount].
     provider.provider_name_full_formatted = p.name_full_formatted, reply->details[detailcount].
     provider.provider_first_name = p.name_first,
     reply->details[detailcount].provider.provider_last_name = p.name_last, reply->details[
     detailcount].provider.provider_username = p.username
    FOOT REPORT
     stat = alterlist(reply->details,detailcount), reply->high_volume_flag = 0
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 004 : Error selecting details.")
  ELSE
   SET reply->high_volume_flag = 1
  ENDIF
 ELSE
  SET detailcount = getcountfordetails(detailparse,pparse,facility_filter)
  IF (detailcount < too_many_records_65535)
   SELECT INTO "nl:"
    FROM eprescribe_detail ed,
     prsnl_reltn pr,
     prsnl p,
     location l,
     code_value cv1,
     code_value cv2
    PLAN (ed
     WHERE parser(detailparse))
     JOIN (pr
     WHERE pr.prsnl_reltn_id=ed.prsnl_reltn_id
      AND pr.active_ind=1
      AND pr.active_status_cd=activestatuscodevalue
      AND pr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (p
     WHERE parser(pparse))
     JOIN (l
     WHERE l.active_ind=1
      AND l.active_status_cd=activestatuscodevalue
      AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND l.location_cd=pr.parent_entity_id)
     JOIN (cv1
     WHERE parser(facility_filter))
     JOIN (cv2
     WHERE cv2.code_value=l.location_type_cd)
    HEAD REPORT
     detailcount = 0, tempcount = 0, stat = alterlist(tempreply->details,10)
    DETAIL
     detailcount = (detailcount+ 1), tempcount = (tempcount+ 1)
     IF (tempcount > 10)
      tempcount = 0, stat = alterlist(tempreply->details,(detailcount+ 10))
     ENDIF
     tempreply->details[detailcount].detail_id = ed.eprescribe_detail_id, tempreply->details[
     detailcount].detail_nominator_id = ed.cs_nominator_id, tempreply->details[detailcount].location.
     location_code_value = l.location_cd,
     tempreply->details[detailcount].location.location_description = cv1.description, tempreply->
     details[detailcount].location.location_display = cv1.display, tempreply->details[detailcount].
     location.location_type_meaning = cv2.cdf_meaning,
     tempreply->details[detailcount].provider.provider_id = p.person_id, tempreply->details[
     detailcount].provider.provider_name_full_formatted = p.name_full_formatted, tempreply->details[
     detailcount].provider.provider_first_name = p.name_first,
     tempreply->details[detailcount].provider.provider_last_name = p.name_last, tempreply->details[
     detailcount].provider.provider_username = p.username
    FOOT REPORT
     stat = alterlist(tempreply->details,detailcount), reply->high_volume_flag = 0
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 005 : Error selecting details.")
  ELSE
   SET detailcount = 0
   SET reply->high_volume_flag = 1
  ENDIF
  IF (detailcount > 0)
   IF (ipmmode=1)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = detailcount),
      prsnl_alias pa
     PLAN (d)
      JOIN (pa
      WHERE (pa.person_id=tempreply->details[d.seq].provider.provider_id)
       AND pa.prsnl_alias_type_cd=al3cid_cd
       AND pa.alias > ""
       AND pa.active_ind=1)
     DETAIL
      tempreply->details[d.seq].access_ind = 1
     WITH nocounter
    ;end select
    CALL bederrorcheck("Error 006 : Error getting alias.")
   ELSE
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = detailcount)
     PLAN (d)
     DETAIL
      tempreply->details[d.seq].access_ind = 1
     WITH nocounter
    ;end select
   ENDIF
   SET tempcount = 0
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = detailcount)
    PLAN (d
     WHERE (tempreply->details[d.seq].access_ind=1))
    DETAIL
     tempcount = (tempcount+ 1), stat = alterlist(reply->details,tempcount), reply->details[tempcount
     ].detail_id = tempreply->details[d.seq].detail_id,
     reply->details[tempcount].detail_nominator_id = tempreply->details[d.seq].detail_nominator_id,
     reply->details[tempcount].location.location_code_value = tempreply->details[d.seq].location.
     location_code_value, reply->details[tempcount].location.location_description = tempreply->
     details[d.seq].location.location_description,
     reply->details[tempcount].location.location_display = tempreply->details[d.seq].location.
     location_display, reply->details[tempcount].location.location_type_meaning = tempreply->details[
     d.seq].location.location_type_meaning, reply->details[tempcount].provider.provider_id =
     tempreply->details[d.seq].provider.provider_id,
     reply->details[tempcount].provider.provider_name_full_formatted = tempreply->details[d.seq].
     provider.provider_name_full_formatted, reply->details[tempcount].provider.provider_first_name =
     tempreply->details[d.seq].provider.provider_first_name, reply->details[tempcount].provider.
     provider_last_name = tempreply->details[d.seq].provider.provider_last_name,
     reply->details[tempcount].provider.provider_username = tempreply->details[d.seq].provider.
     provider_username
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 007 : Error populating reply.")
  ENDIF
 ENDIF
 SUBROUTINE getcountfordetails(detailparse,pparse,facility_filter)
   DECLARE counttoreturn = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    total_count = count(*)
    FROM eprescribe_detail ed,
     prsnl_reltn pr,
     prsnl p,
     location l,
     code_value cv1,
     code_value cv2
    PLAN (ed
     WHERE parser(detailparse))
     JOIN (pr
     WHERE pr.prsnl_reltn_id=ed.prsnl_reltn_id
      AND pr.active_ind=1
      AND pr.active_status_cd=activestatuscodevalue
      AND pr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (p
     WHERE parser(pparse))
     JOIN (l
     WHERE l.active_ind=1
      AND l.active_status_cd=activestatuscodevalue
      AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND l.location_cd=pr.parent_entity_id)
     JOIN (cv1
     WHERE parser(facility_filter))
     JOIN (cv2
     WHERE cv2.code_value=l.location_type_cd)
    DETAIL
     counttoreturn = total_count
    WITH nocounter
   ;end select
   CALL bederrorcheck("Error 001: Error while counting number of details.")
   RETURN(counttoreturn)
 END ;Subroutine
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
