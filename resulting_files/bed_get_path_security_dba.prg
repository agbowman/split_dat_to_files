CREATE PROGRAM bed_get_path_security:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 personnel[*]
      2 person_id = f8
      2 wizards[*]
        3 wizard_meaning = vc
      2 paths[*]
        3 path_meaning = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD temppersonnel(
   1 personnel[*]
     2 person_id = f8
     2 allowapprovepathind = i2
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
 DECLARE reqpersonnelcount = i4 WITH protect, constant(size(request->personnel,5))
 DECLARE docdea_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",320,"DOCDEA"))
 DECLARE temppersonnelcount = i4 WITH protect, noconstant(0)
 DECLARE personnelcount = i4 WITH protect, noconstant(0)
 DECLARE reppersonnelcount = i4 WITH protect, noconstant(0)
 IF (reqpersonnelcount=0)
  SET temppersonnelcount = 0
  SET personnelcount = 0
  SELECT INTO "nl:"
   FROM br_name_value bnv
   PLAN (bnv
    WHERE bnv.br_nv_key1 IN ("WIZARDSECURITY", "PATHSECURITY"))
   ORDER BY bnv.br_name
   HEAD REPORT
    temppersonnelcount = 0, personnelcount = 0, stat = alterlist(temppersonnel->personnel,10)
   HEAD bnv.br_name
    temppersonnelcount = (temppersonnelcount+ 1), personnelcount = (personnelcount+ 1)
    IF (temppersonnelcount > 10)
     temppersonnelcount = 0, stat = alterlist(temppersonnel->personnel,(personnelcount+ 10))
    ENDIF
    temppersonnel->personnel[personnelcount].person_id = cnvtreal(bnv.br_name)
   FOOT REPORT
    stat = alterlist(temppersonnel->personnel,personnelcount)
   WITH nocounter
  ;end select
 ELSE
  SET personnelcount = reqpersonnelcount
  SET stat = alterlist(temppersonnel->personnel,reqpersonnelcount)
  FOR (i = 1 TO reqpersonnelcount)
    SET temppersonnel->personnel[i].person_id = request->personnel[i].person_id
  ENDFOR
 ENDIF
 DECLARE pparse = vc
 SET pparse = concat("p.person_id = tempPersonnel->personnel[d.seq].person_id")
 SET data_partition_ind = 0
 SET field_found = 0
 RANGE OF c IS code_value_set
 SET field_found = validate(c.br_client_id)
 FREE RANGE c
 IF (field_found=0)
  SET prg_exists_ind = 0
  SET prg_exists_ind = checkprg("ACM_GET_ACC_LOGICAL_DOMAINS")
  IF (prg_exists_ind > 0)
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
 IF (personnelcount=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = personnelcount),
   prsnl p
  PLAN (d)
   JOIN (p
   WHERE parser(pparse))
  HEAD REPORT
   reppersonnelcount = 0, stat = alterlist(reply->personnel,personnelcount)
  DETAIL
   reppersonnelcount = (reppersonnelcount+ 1), reply->personnel[reppersonnelcount].person_id =
   temppersonnel->personnel[d.seq].person_id
  FOOT REPORT
   stat = alterlist(reply->personnel,reppersonnelcount)
  WITH nocounter
 ;end select
 IF ((request->load_wizard_security=1))
  SET tempcount = 0
  SET wizardcount = 0
  SELECT INTO "nl:"
   FROM br_name_value bnv,
    (dummyt d  WITH seq = reppersonnelcount)
   PLAN (d)
    JOIN (bnv
    WHERE bnv.br_nv_key1="WIZARDSECURITY"
     AND bnv.br_name=cnvtstring(reply->personnel[d.seq].person_id))
   ORDER BY bnv.br_name
   HEAD bnv.br_name
    tempcount = 0, wizardcount = 0, stat = alterlist(reply->personnel[d.seq].wizards,10)
   DETAIL
    wizardcount = (wizardcount+ 1), tempcount = (tempcount+ 1)
    IF (tempcount > 10)
     tempcount = 0, stat = alterlist(reply->personnel[d.seq].wizards,(wizardcount+ 10))
    ENDIF
    reply->personnel[d.seq].wizards[wizardcount].wizard_meaning = bnv.br_value
   FOOT  bnv.br_name
    stat = alterlist(reply->personnel[d.seq].wizards,wizardcount)
   WITH nocounter
  ;end select
 ENDIF
 SET tempcount = 0
 SET pathcount = 0
 SET stat = initrec(temppersonnel)
 SET stat = alterlist(temppersonnel->personnel,size(reply->personnel,5))
 SELECT INTO "nl:"
  FROM br_name_value bnv
  WHERE bnv.br_client_id=0
   AND bnv.br_nv_key1="EPCSAPPROVALPATH"
   AND bnv.br_name="INDIVIDUALPROVIDERMODE"
   AND bnv.br_value="1"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = size(reply->personnel,5))
   PLAN (d)
   DETAIL
    temppersonnel->personnel[d.seq].person_id = reply->personnel[d.seq].person_id, temppersonnel->
    personnel[d.seq].allowapprovepathind = 0
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt dt  WITH seq = size(reply->personnel,5)),
    prsnl_alias pa
   PLAN (dt)
    JOIN (pa
    WHERE (pa.person_id=reply->personnel[dt.seq].person_id)
     AND pa.prsnl_alias_type_cd=docdea_cd
     AND pa.alias > ""
     AND pa.active_ind=1)
   DETAIL
    temppersonnel->personnel[dt.seq].allowapprovepathind = 1
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = size(reply->personnel,5))
   PLAN (d)
   DETAIL
    temppersonnel->personnel[d.seq].person_id = reply->personnel[d.seq].person_id, temppersonnel->
    personnel[d.seq].allowapprovepathind = 1
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM br_name_value bnv,
   (dummyt d  WITH seq = reppersonnelcount)
  PLAN (d)
   JOIN (bnv
   WHERE bnv.br_nv_key1="PATHSECURITY"
    AND bnv.br_name=cnvtstring(reply->personnel[d.seq].person_id))
  ORDER BY bnv.br_name
  HEAD bnv.br_name
   tempcount = 0, pathcount = 0, stat = alterlist(reply->personnel[d.seq].paths,10)
  DETAIL
   IF (((bnv.br_value="EPCSAPPROVAL"
    AND (temppersonnel->personnel[d.seq].allowapprovepathind=1)) OR (bnv.br_value != "EPCSAPPROVAL"
   )) )
    pathcount = (pathcount+ 1), tempcount = (tempcount+ 1)
    IF (tempcount > 10)
     tempcount = 0, stat = alterlist(reply->personnel[d.seq].paths,(pathcount+ 10))
    ENDIF
    reply->personnel[d.seq].paths[pathcount].path_meaning = bnv.br_value
   ENDIF
  FOOT  bnv.br_name
   stat = alterlist(reply->personnel[d.seq].paths,pathcount)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
