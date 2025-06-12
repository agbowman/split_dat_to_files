CREATE PROGRAM bed_get_bedrock_user:dba
 FREE SET reply
 RECORD reply(
   01 userlist[*]
     02 username = vc
     02 name_full_formatted = vc
     02 position_cd = f8
     02 position_disp = vc
     02 design_build_ind = i2
     02 lighthouse_ind = i2
     02 person_id = f8
     02 diagnostic_center_ind = i2
     02 millennium_tools_ind = i2
     02 non_dba_wizard_security_ind = i2
     02 report_security_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 FREE SET temp
 RECORD temp(
   1 userlist[*]
     2 person_id = f8
 )
 FREE SET temp2
 RECORD temp2(
   1 userlist[*]
     2 person_id = f8
     2 org_ind = i2
     2 org_group_ind = i2
     2 username = vc
     2 name_full_formatted = vc
     2 position_cd = f8
     2 position_disp = vc
 )
 SET reply->status_data.status = "F"
 SET ucnt = 0
 SET max_reply = 0
 IF (validate(request->max_reply))
  SET max_reply = request->max_reply
 ENDIF
 SET org_cnt = 0
 IF (validate(request->organizations))
  SET org_cnt = size(request->organizations,5)
 ENDIF
 SET org_group_cnt = 0
 IF (validate(request->organization_groups))
  SET org_group_cnt = size(request->organization_groups,5)
 ENDIF
 SET pos_cnt = 0
 IF (validate(request->positions))
  SET pos_cnt = size(request->positions,5)
 ENDIF
 SELECT DISTINCT INTO "nl:"
  bnv.br_name
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1 IN ("WIZARDSECURITY", "REPORTSECURITY")
    AND bnv.br_client_id=0)
  DETAIL
   ucnt = (ucnt+ 1), stat = alterlist(temp->userlist,ucnt), temp->userlist[ucnt].person_id = cnvtreal
   (bnv.br_name)
  WITH nocounter
 ;end select
 IF (ucnt=0)
  GO TO exit_script
 ENDIF
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
 DECLARE prsnl_parse = vc
 SET prsnl_parse = "p.person_id = temp->userlist[d.seq].person_id"
 IF (data_partition_ind=1)
  IF ((acm_get_acc_logical_domains_rep->logical_domains_cnt > 0))
   SET prsnl_parse = concat(prsnl_parse," and p.logical_domain_id in (")
   FOR (d = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
     IF ((d=acm_get_acc_logical_domains_rep->logical_domains_cnt))
      SET prsnl_parse = build(prsnl_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,")")
     ELSE
      SET prsnl_parse = build(prsnl_parse,acm_get_acc_logical_domains_rep->logical_domains[d].
       logical_domain_id,",")
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF (validate(request->first_name))
  IF ((request->first_name > " "))
   SET prsnl_parse = concat(prsnl_parse," and trim(p.name_first_key) = '",trim(cnvtupper(cnvtalphanum
      (request->first_name))),"*' ")
  ENDIF
 ENDIF
 IF (validate(request->last_name))
  IF ((request->last_name > " "))
   SET prsnl_parse = concat(prsnl_parse," and trim(p.name_last_key) = '",trim(cnvtupper(cnvtalphanum(
       request->last_name))),"*' ")
  ENDIF
 ENDIF
 IF (validate(request->username))
  IF ((request->username > " "))
   SET prsnl_parse = concat(prsnl_parse," and trim(cnvtupper(p.username)) = '",trim(cnvtupper(request
      ->username)),"*' ")
  ENDIF
 ENDIF
 SET position_cnt = 0
 IF (validate(request->positions))
  SET org_cnt = size(request->positions,5)
 ENDIF
 SET uidx = 0
 SET temp_uidx = 0
 DECLARE num = i4
 DECLARE start = i4
 SET start = 1
 SET pos = 0
 SELECT INTO "nl:"
  nff = cnvtupper(p.name_full_formatted)
  FROM (dummyt d  WITH seq = ucnt),
   prsnl p,
   code_value c
  PLAN (d)
   JOIN (p
   WHERE parser(prsnl_parse))
   JOIN (c
   WHERE c.code_value=p.position_cd
    AND c.active_ind=1)
  ORDER BY nff
  HEAD REPORT
   stat = alterlist(temp2->userlist,ucnt), temp_uidx = 0
  DETAIL
   load_ind = 0, pos = 0, start = 1,
   num = 0
   IF (position_cnt > 0)
    pos = locateval(num,start,position_cnt,p.position_cd,request->positions[num].position_code_value)
    IF (pos > 0)
     load_ind = 1
    ENDIF
   ELSE
    load_ind = 1
   ENDIF
   IF (load_ind=1)
    temp_uidx = (temp_uidx+ 1), temp2->userlist[temp_uidx].username = p.username, temp2->userlist[
    temp_uidx].name_full_formatted = p.name_full_formatted,
    temp2->userlist[temp_uidx].position_cd = p.position_cd, temp2->userlist[temp_uidx].person_id = p
    .person_id, temp2->userlist[temp_uidx].position_disp = c.display
   ENDIF
  FOOT REPORT
   stat = alterlist(temp2->userlist,temp_uidx)
  WITH nocounter
 ;end select
 IF (temp_uidx=0)
  GO TO exit_script
 ENDIF
 SET org_cnt = 0
 IF (validate(request->organizations))
  SET org_cnt = size(request->organizations,5)
 ENDIF
 IF (org_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(temp_uidx)),
    (dummyt d2  WITH seq = 1),
    prsnl_org_reltn por
   PLAN (d
    WHERE maxrec(d2,size(request->organizations,5)))
    JOIN (d2)
    JOIN (por
    WHERE (por.person_id=temp2->userlist[d.seq].person_id)
     AND (por.organization_id=request->organizations[d2.seq].organization_id)
     AND por.active_ind=1
     AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ((por.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (por.end_effective_dt_tm=null
    )) )
   ORDER BY d.seq
   HEAD d.seq
    temp2->userlist[d.seq].org_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 SET org_grp_cnt = 0
 IF (validate(request->organization_groups))
  SET org_grp_cnt = size(request->organization_groups,5)
 ENDIF
 IF (org_grp_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(temp_uidx)),
    (dummyt d2  WITH seq = 1),
    org_set_prsnl_r os
   PLAN (d
    WHERE maxrec(d2,size(request->organization_groups,5)))
    JOIN (d2)
    JOIN (os
    WHERE (os.prsnl_id=temp2->userlist[d.seq].person_id)
     AND (os.org_set_id=request->organization_groups[d2.seq].org_group_id)
     AND os.active_ind=1
     AND os.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ((os.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (os.end_effective_dt_tm=null
    )) )
   ORDER BY d.seq
   HEAD d.seq
    temp2->userlist[d.seq].org_group_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 SET uidx = 0
 SET stat = alterlist(reply->userlist,temp_uidx)
 FOR (x = 1 TO temp_uidx)
   IF (((org_cnt > 0
    AND (temp2->userlist[x].org_ind != 0)) OR (org_cnt=0))
    AND ((org_grp_cnt > 0
    AND (temp2->userlist[x].org_group_ind != 0)) OR (org_grp_cnt=0)) )
    SET uidx = (uidx+ 1)
    SET reply->userlist[uidx].name_full_formatted = temp2->userlist[x].name_full_formatted
    SET reply->userlist[uidx].person_id = temp2->userlist[x].person_id
    SET reply->userlist[uidx].position_cd = temp2->userlist[x].position_cd
    SET reply->userlist[uidx].username = temp2->userlist[x].username
    SET reply->userlist[uidx].position_disp = temp2->userlist[x].position_disp
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->userlist,uidx)
 IF (uidx=0)
  GO TO exit_script
 ENDIF
 IF (max_reply > 0
  AND uidx > max_reply)
  SET stat = alterlist(reply->userlist,0)
  SET reply->too_many_results_ind = 1
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(uidx)),
   br_name_value v,
   br_client_item_reltn r
  PLAN (d)
   JOIN (v
   WHERE v.br_nv_key1="WIZARDSECURITY"
    AND v.br_name=cnvtstring(reply->userlist[d.seq].person_id)
    AND v.br_client_id=0)
   JOIN (r
   WHERE r.item_mean=v.br_value)
  ORDER BY d.seq
  DETAIL
   IF (r.solution_type_flag=0)
    reply->userlist[d.seq].design_build_ind = 1
   ELSEIF (r.solution_type_flag=1)
    reply->userlist[d.seq].lighthouse_ind = 1
   ELSEIF (r.solution_type_flag=2)
    reply->userlist[d.seq].diagnostic_center_ind = 1
   ELSEIF (r.solution_type_flag=3)
    reply->userlist[d.seq].millennium_tools_ind = 1
   ELSEIF (r.solution_type_flag=4)
    reply->userlist[d.seq].non_dba_wizard_security_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(uidx)),
   br_name_value v
  PLAN (d)
   JOIN (v
   WHERE v.br_nv_key1="REPORTSECURITY"
    AND v.br_name=cnvtstring(reply->userlist[d.seq].person_id)
    AND v.br_client_id=0)
  ORDER BY d.seq
  DETAIL
   reply->userlist[d.seq].report_security_ind = 1
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
