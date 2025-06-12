CREATE PROGRAM bed_get_def_sched_resources:dba
 FREE SET reply
 RECORD reply(
   1 resources[*]
     2 sch_res_code_value = f8
     2 sch_res_mnemonic = vc
     2 sch_res_refer_text_id = f8
     2 sch_res_refer_text = vc
     2 sch_res_refer_text_updt_cnt = i4
     2 sch_res_updt_cnt = i4
     2 person_id = f8
     2 person_name = vc
     2 position_code_value = f8
     2 position_display = vc
     2 bedrock_res_type_id = f8
     2 bedrock_res_type_name = vc
     2 bedrock_res_type_display = vc
   1 too_many_results_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 FREE SET sch_get_resource_req
 RECORD sch_get_resource_req(
   1 security_ind = i2
   1 case_sensitive_ind = i2
   1 mnem = vc
   1 active_ind = i2
 )
 FREE SET sch_get_resource_rep
 RECORD sch_get_resource_rep(
   1 qual_cnt = i4
   1 qual[*]
     2 resource_cd = f8
     2 quota = i4
     2 person_id = f8
     2 service_resource_cd = f8
     2 res_type_flag = i2
     2 item_id = f8
     2 item_location_cd = f8
     2 mnem = vc
     2 desc = vc
     2 id_disp = vc
     2 refer_text_id = f8
     2 refer_text = vc
     2 refer_text_updt_cnt = i4
     2 updt_cnt = i4
     2 active_ind = i2
     2 date_link_r_qual_cnt = i4
     2 date_link_r_qual[*]
       3 date_set_seq_nbr = i4
       3 parent_entity_id = f8
       3 parent_entity_name = c30
       3 sch_date_link_r_id = f8
       3 sch_date_set_id = f8
       3 updt_cnt = i4
       3 sch_date_set_mnem = vc
       3 sch_date_set_desc = vc
       3 sch_date_set_active_ind = i2
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
   1 resources[*]
     2 sch_res_code_value = f8
     2 sch_res_mnemonic = vc
     2 sch_res_refer_text_id = f8
     2 sch_res_refer_text = vc
     2 sch_res_refer_text_updt_cnt = i4
     2 sch_res_updt_cnt = i4
     2 person_id = f8
     2 person_name = vc
     2 position_code_value = f8
     2 position_display = vc
     2 username = vc
     2 first_name = vc
     2 last_name = vc
     2 physician_ind = i2
     2 bedrock_res_type_id = f8
     2 bedrock_res_type_name = vc
     2 bedrock_res_type_display = vc
 )
 DECLARE phy_res_type_id = f8 WITH noconstant(0.0), protect
 DECLARE phy_res_type_name = vc WITH noconstant(""), protect
 DECLARE phy_res_type_display = vc WITH noconstant(""), protect
 DECLARE nurse_res_type_id = f8 WITH noconstant(0.0), protect
 DECLARE nurse_res_type_name = vc WITH noconstant(""), protect
 DECLARE nurse_res_type_display = vc WITH noconstant(""), protect
 DECLARE thera_res_type_id = f8 WITH noconstant(0.0), protect
 DECLARE thera_res_type_name = vc WITH noconstant(""), protect
 DECLARE thera_res_type_display = vc WITH noconstant(""), protect
 DECLARE other_res_type_id = f8 WITH noconstant(0.0), protect
 DECLARE other_res_type_name = vc WITH noconstant(""), protect
 DECLARE other_res_type_display = vc WITH noconstant(""), protect
 SELECT INTO "nl:"
  FROM br_name_value b
  WHERE b.br_nv_key1="SCHRESGROUP"
   AND b.br_name IN ("PHY", "NURSE", "THERA", "OTHER")
  DETAIL
   IF (b.br_name="PHY")
    phy_res_type_id = b.br_name_value_id, phy_res_type_name = b.br_name, phy_res_type_display = b
    .br_value
   ELSEIF (b.br_name="NURSE")
    nurse_res_type_id = b.br_name_value_id, nurse_res_type_name = b.br_name, nurse_res_type_display
     = b.br_value
   ELSEIF (b.br_name="THERA")
    thera_res_type_id = b.br_name_value_id, thera_res_type_name = b.br_name, thera_res_type_display
     = b.br_value
   ELSEIF (b.br_name="OTHER")
    other_res_type_id = b.br_name_value_id, other_res_type_name = b.br_name, other_res_type_display
     = b.br_value
   ENDIF
  WITH nocounter
 ;end select
 DECLARE bedrock_search_res_type = vc WITH noconstant(""), protect
 IF ((request->bedrock_res_type_flag=1))
  SET bedrock_search_res_type = trim(cnvtstring(phy_res_type_id,20,0))
 ELSEIF ((request->bedrock_res_type_flag=2))
  SET bedrock_search_res_type = trim(cnvtstring(nurse_res_type_id,20,0))
 ELSEIF ((request->bedrock_res_type_flag=3))
  SET bedrock_search_res_type = trim(cnvtstring(thera_res_type_id,20,0))
 ELSEIF ((request->bedrock_res_type_flag=4))
  SET bedrock_search_res_type = trim(cnvtstring(other_res_type_id,20,0))
 ENDIF
 IF ((request->search_string=null))
  SET request->search_string = " "
 ENDIF
 IF ((request->search_type_flag=null))
  SET request->search_type_flag = "S"
 ENDIF
 DECLARE search_string = vc
 IF ((request->search_type_flag="S"))
  SET search_string = build('"',trim(cnvtupper(request->search_string)),'*"')
 ELSEIF ((request->search_type_flag="C"))
  SET search_string = build('"*',trim(cnvtupper(request->search_string)),'*"')
 ENDIF
 DECLARE sch_parse = vc
 SET sch_parse = build2("s.mnemonic_key = ",search_string)
 DECLARE prsnl_parse = vc
 SET prsnl_parse = build2("cnvtupper(p.name_full_formatted) = ",search_string)
 SET tcnt = 0
 SET rcnt = 0
 SET sch_get_resource_req->security_ind = 1
 SET sch_get_resource_req->case_sensitive_ind = 0
 SET sch_get_resource_req->active_ind = 1
 IF ((request->search_type_flag="S"))
  SET sch_get_resource_req->mnem = request->search_string
 ELSE
  SET sch_get_resource_req->mnem = build("*",request->search_string)
 ENDIF
 EXECUTE sch_get_resource  WITH replace("REQUEST",sch_get_resource_req), replace("REPLY",
  sch_get_resource_rep)
 IF ((sch_get_resource_rep->qual_cnt > 0))
  IF ((request->bedrock_res_type_flag IN (1, 2, 3)))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(sch_get_resource_rep->qual_cnt)),
     prsnl p,
     code_value cv,
     dummyt d1,
     br_name_value b
    PLAN (d
     WHERE (sch_get_resource_rep->qual[d.seq].active_ind=1)
      AND (sch_get_resource_rep->qual[d.seq].quota=0)
      AND (sch_get_resource_rep->qual[d.seq].res_type_flag=2)
      AND (sch_get_resource_rep->qual[d.seq].person_id > 0))
     JOIN (p
     WHERE (p.person_id=sch_get_resource_rep->qual[d.seq].person_id)
      AND p.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=p.position_cd
      AND cv.active_ind=1)
     JOIN (d1)
     JOIN (b
     WHERE b.br_nv_key1="SCHRESGROUPRES"
      AND (cnvtreal(b.br_name)=sch_get_resource_rep->qual[d.seq].resource_cd))
    DETAIL
     IF (b.br_name_value_id=0)
      tcnt = (tcnt+ 1), stat = alterlist(temp->resources,tcnt), temp->resources[tcnt].
      sch_res_code_value = sch_get_resource_rep->qual[d.seq].resource_cd,
      temp->resources[tcnt].sch_res_mnemonic = sch_get_resource_rep->qual[d.seq].mnem, temp->
      resources[tcnt].sch_res_refer_text_id = sch_get_resource_rep->qual[d.seq].refer_text_id, temp->
      resources[tcnt].sch_res_refer_text = sch_get_resource_rep->qual[d.seq].refer_text,
      temp->resources[tcnt].sch_res_refer_text_updt_cnt = sch_get_resource_rep->qual[d.seq].
      refer_text_updt_cnt, temp->resources[tcnt].sch_res_updt_cnt = sch_get_resource_rep->qual[d.seq]
      .updt_cnt, temp->resources[tcnt].person_id = sch_get_resource_rep->qual[d.seq].person_id,
      temp->resources[tcnt].person_name = sch_get_resource_rep->qual[d.seq].id_disp, temp->resources[
      tcnt].position_code_value = cv.code_value, temp->resources[tcnt].position_display = cv.display,
      temp->resources[tcnt].username = p.username, temp->resources[tcnt].first_name = p.name_first,
      temp->resources[tcnt].last_name = p.name_last,
      temp->resources[tcnt].physician_ind = p.physician_ind
     ENDIF
    WITH nocounter, outerjoin = d1
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(sch_get_resource_rep->qual_cnt)),
     dummyt d1,
     br_name_value b
    PLAN (d
     WHERE (sch_get_resource_rep->qual[d.seq].active_ind=1)
      AND (sch_get_resource_rep->qual[d.seq].quota=0)
      AND (sch_get_resource_rep->qual[d.seq].res_type_flag=1)
      AND (sch_get_resource_rep->qual[d.seq].person_id=0))
     JOIN (d1)
     JOIN (b
     WHERE b.br_nv_key1="SCHRESGROUPRES"
      AND (cnvtreal(b.br_name)=sch_get_resource_rep->qual[d.seq].resource_cd))
    DETAIL
     IF (b.br_name_value_id=0)
      tcnt = (tcnt+ 1), stat = alterlist(temp->resources,tcnt), temp->resources[tcnt].
      sch_res_code_value = sch_get_resource_rep->qual[d.seq].resource_cd,
      temp->resources[tcnt].sch_res_mnemonic = sch_get_resource_rep->qual[d.seq].mnem, temp->
      resources[tcnt].sch_res_refer_text_id = sch_get_resource_rep->qual[d.seq].refer_text_id, temp->
      resources[tcnt].sch_res_refer_text = sch_get_resource_rep->qual[d.seq].refer_text,
      temp->resources[tcnt].sch_res_refer_text_updt_cnt = sch_get_resource_rep->qual[d.seq].
      refer_text_updt_cnt, temp->resources[tcnt].sch_res_updt_cnt = sch_get_resource_rep->qual[d.seq]
      .updt_cnt
     ENDIF
    WITH nocounter, outerjoin = d1
   ;end select
  ENDIF
 ENDIF
 IF ((request->bedrock_res_type_flag IN (1, 2, 3)))
  SELECT INTO "nl:"
   FROM br_name_value b,
    sch_resource s,
    long_text_reference l,
    prsnl p,
    code_value cv
   PLAN (b
    WHERE b.br_nv_key1="SCHRESGROUPRES")
    JOIN (s
    WHERE s.resource_cd=cnvtreal(b.br_name)
     AND parser(sch_parse)
     AND s.quota=0
     AND s.active_ind=1)
    JOIN (l
    WHERE l.long_text_id=outerjoin(s.info_sch_text_id)
     AND l.active_ind=outerjoin(1))
    JOIN (p
    WHERE p.person_id=outerjoin(s.person_id)
     AND p.active_ind=outerjoin(1))
    JOIN (cv
    WHERE cv.code_value=outerjoin(p.position_cd)
     AND cv.active_ind=outerjoin(1))
   DETAIL
    IF (((b.br_value=bedrock_search_res_type) OR (s.res_type_flag=2
     AND cnvtreal(b.br_value) != phy_res_type_id
     AND cnvtreal(b.br_value) != nurse_res_type_id
     AND cnvtreal(b.br_value) != thera_res_type_id)) )
     found_ind = 0, start = 1, num = 0
     IF (tcnt > 0)
      found_ind = locateval(num,start,tcnt,s.resource_cd,temp->resources[num].sch_res_code_value)
     ENDIF
     IF (found_ind=0)
      tcnt = (tcnt+ 1), stat = alterlist(temp->resources,tcnt), temp->resources[tcnt].
      sch_res_code_value = s.resource_cd,
      temp->resources[tcnt].sch_res_mnemonic = s.mnemonic, temp->resources[tcnt].
      sch_res_refer_text_id = l.long_text_id, temp->resources[tcnt].sch_res_refer_text = l.long_text,
      temp->resources[tcnt].sch_res_refer_text_updt_cnt = l.updt_cnt, temp->resources[tcnt].
      sch_res_updt_cnt = s.updt_cnt, temp->resources[tcnt].person_id = p.person_id,
      temp->resources[tcnt].person_name = p.name_full_formatted, temp->resources[tcnt].
      position_code_value = cv.code_value, temp->resources[tcnt].position_display = cv.display,
      temp->resources[tcnt].username = p.username, temp->resources[tcnt].first_name = p.name_first,
      temp->resources[tcnt].last_name = p.name_last,
      temp->resources[tcnt].physician_ind = p.physician_ind
      IF (cnvtreal(b.br_value)=phy_res_type_id)
       temp->resources[tcnt].bedrock_res_type_id = phy_res_type_id, temp->resources[tcnt].
       bedrock_res_type_name = phy_res_type_name, temp->resources[tcnt].bedrock_res_type_display =
       phy_res_type_display
      ELSEIF (cnvtreal(b.br_value)=nurse_res_type_id)
       temp->resources[tcnt].bedrock_res_type_id = nurse_res_type_id, temp->resources[tcnt].
       bedrock_res_type_name = nurse_res_type_name, temp->resources[tcnt].bedrock_res_type_display =
       nurse_res_type_display
      ELSEIF (cnvtreal(b.br_value)=thera_res_type_id)
       temp->resources[tcnt].bedrock_res_type_id = thera_res_type_id, temp->resources[tcnt].
       bedrock_res_type_name = thera_res_type_name, temp->resources[tcnt].bedrock_res_type_display =
       thera_res_type_display
      ELSEIF (cnvtreal(b.br_value)=other_res_type_id)
       temp->resources[tcnt].bedrock_res_type_id = other_res_type_id, temp->resources[tcnt].
       bedrock_res_type_name = other_res_type_name, temp->resources[tcnt].bedrock_res_type_display =
       other_res_type_display
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM br_name_value b,
    sch_resource s,
    long_text_reference l
   PLAN (b
    WHERE b.br_nv_key1="SCHRESGROUPRES"
     AND b.br_value=bedrock_search_res_type)
    JOIN (s
    WHERE s.resource_cd=cnvtreal(b.br_name)
     AND parser(sch_parse)
     AND s.quota=0
     AND s.active_ind=1
     AND s.res_type_flag=1)
    JOIN (l
    WHERE l.long_text_id=outerjoin(s.info_sch_text_id)
     AND l.active_ind=outerjoin(1))
   DETAIL
    found_ind = 0, start = 1, num = 0
    IF (tcnt > 0)
     found_ind = locateval(num,start,tcnt,s.resource_cd,temp->resources[num].sch_res_code_value)
    ENDIF
    IF (found_ind=0)
     tcnt = (tcnt+ 1), stat = alterlist(temp->resources,tcnt), temp->resources[tcnt].
     sch_res_code_value = s.resource_cd,
     temp->resources[tcnt].sch_res_mnemonic = s.mnemonic, temp->resources[tcnt].sch_res_refer_text_id
      = l.long_text_id, temp->resources[tcnt].sch_res_refer_text = l.long_text,
     temp->resources[tcnt].sch_res_refer_text_updt_cnt = l.updt_cnt, temp->resources[tcnt].
     sch_res_updt_cnt = s.updt_cnt
     IF (cnvtreal(b.br_value)=phy_res_type_id)
      temp->resources[tcnt].bedrock_res_type_id = phy_res_type_id, temp->resources[tcnt].
      bedrock_res_type_name = phy_res_type_name, temp->resources[tcnt].bedrock_res_type_display =
      phy_res_type_display
     ELSEIF (cnvtreal(b.br_value)=nurse_res_type_id)
      temp->resources[tcnt].bedrock_res_type_id = nurse_res_type_id, temp->resources[tcnt].
      bedrock_res_type_name = nurse_res_type_name, temp->resources[tcnt].bedrock_res_type_display =
      nurse_res_type_display
     ELSEIF (cnvtreal(b.br_value)=thera_res_type_id)
      temp->resources[tcnt].bedrock_res_type_id = thera_res_type_id, temp->resources[tcnt].
      bedrock_res_type_name = thera_res_type_name, temp->resources[tcnt].bedrock_res_type_display =
      thera_res_type_display
     ELSEIF (cnvtreal(b.br_value)=other_res_type_id)
      temp->resources[tcnt].bedrock_res_type_id = other_res_type_id, temp->resources[tcnt].
      bedrock_res_type_name = other_res_type_name, temp->resources[tcnt].bedrock_res_type_display =
      other_res_type_display
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->bedrock_res_type_flag IN (1, 2, 3)))
  SELECT INTO "nl:"
   FROM prsnl p,
    code_value cv,
    sch_resource sr
   PLAN (p
    WHERE parser(prsnl_parse)
     AND p.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=outerjoin(p.position_cd)
     AND cv.active_ind=outerjoin(1))
    JOIN (sr
    WHERE sr.person_id=outerjoin(p.person_id)
     AND sr.active_ind=outerjoin(1))
   DETAIL
    IF (sr.resource_cd=0)
     found_ind = 0, start = 1, num = 0
     IF (tcnt > 0)
      found_ind = locateval(num,start,tcnt,p.person_id,temp->resources[num].person_id)
     ENDIF
     IF (found_ind=0)
      tcnt = (tcnt+ 1), stat = alterlist(temp->resources,tcnt), temp->resources[tcnt].person_id = p
      .person_id,
      temp->resources[tcnt].person_name = p.name_full_formatted, temp->resources[tcnt].
      position_code_value = cv.code_value, temp->resources[tcnt].position_display = cv.display,
      temp->resources[tcnt].username = p.username, temp->resources[tcnt].first_name = p.name_first,
      temp->resources[tcnt].last_name = p.name_last,
      temp->resources[tcnt].physician_ind = p.physician_ind
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 DECLARE search_username = vc
 DECLARE search_first_name = vc
 DECLARE search_last_name = vc
 DECLARE username_size = i4
 DECLARE first_name_size = i4
 DECLARE last_name_size = i4
 IF (tcnt > 0)
  IF ((request->bedrock_res_type_flag IN (1, 2, 3)))
   IF ((request->username > " "))
    SET username_size = size(request->username,1)
   ENDIF
   IF ((request->first_name > " "))
    SET first_name_size = size(request->first_name,1)
   ENDIF
   IF ((request->last_name > " "))
    SET last_name_size = size(request->last_name,1)
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tcnt))
   PLAN (d)
   DETAIL
    move_ind = 1
    IF ((request->bedrock_res_type_flag IN (1, 2, 3)))
     IF ((request->username > " "))
      search_username = cnvtupper(temp->resources[d.seq].username)
     ENDIF
     IF ((request->first_name > " "))
      search_first_name = cnvtupper(temp->resources[d.seq].first_name)
     ENDIF
     IF ((request->last_name > " "))
      search_last_name = cnvtupper(temp->resources[d.seq].last_name)
     ENDIF
     IF ((((request->username > " ")
      AND substring(1,username_size,search_username) != cnvtupper(request->username)) OR ((((request
     ->first_name > " ")
      AND substring(1,first_name_size,search_first_name) != cnvtupper(request->first_name)) OR ((((
     request->last_name > " ")
      AND substring(1,last_name_size,search_last_name) != cnvtupper(request->last_name)) OR ((((
     request->position_code_value > 0)
      AND (temp->resources[d.seq].position_code_value != request->position_code_value)) OR ((request
     ->physicians_only_ind=1)
      AND (temp->resources[d.seq].physician_ind != 1))) )) )) )) )
      move_ind = 0
     ENDIF
    ENDIF
    IF (move_ind=1)
     rcnt = (rcnt+ 1), stat = alterlist(reply->resources,rcnt), reply->resources[rcnt].
     sch_res_code_value = temp->resources[d.seq].sch_res_code_value,
     reply->resources[rcnt].sch_res_mnemonic = temp->resources[d.seq].sch_res_mnemonic, reply->
     resources[rcnt].sch_res_refer_text_id = temp->resources[d.seq].sch_res_refer_text_id, reply->
     resources[rcnt].sch_res_refer_text = temp->resources[d.seq].sch_res_refer_text,
     reply->resources[rcnt].sch_res_refer_text_updt_cnt = temp->resources[d.seq].
     sch_res_refer_text_updt_cnt, reply->resources[rcnt].sch_res_updt_cnt = temp->resources[d.seq].
     sch_res_updt_cnt, reply->resources[rcnt].person_id = temp->resources[d.seq].person_id,
     reply->resources[rcnt].person_name = temp->resources[d.seq].person_name, reply->resources[rcnt].
     position_code_value = temp->resources[d.seq].position_code_value, reply->resources[rcnt].
     position_display = temp->resources[d.seq].position_display,
     reply->resources[rcnt].bedrock_res_type_id = temp->resources[d.seq].bedrock_res_type_id, reply->
     resources[rcnt].bedrock_res_type_name = temp->resources[d.seq].bedrock_res_type_name, reply->
     resources[rcnt].bedrock_res_type_display = temp->resources[d.seq].bedrock_res_type_display
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF ((request->max_reply > 0)
  AND (rcnt > request->max_reply))
  SET stat = alterlist(reply->resources,0)
  SET reply->too_many_results_ind = 1
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
