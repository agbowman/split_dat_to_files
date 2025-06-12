CREATE PROGRAM bed_get_def_sched_rooms:dba
 FREE SET reply
 RECORD reply(
   1 resources[*]
     2 sch_res_code_value = f8
     2 sch_res_mnemonic = vc
     2 sch_res_refer_text_id = f8
     2 sch_res_refer_text = vc
     2 sch_res_refer_text_updt_cnt = i4
     2 sch_res_updt_cnt = i4
     2 serv_res_code_value = f8
     2 serv_res_display = vc
     2 bedrock_res_type_id = f8
     2 bedrock_res_type_name = vc
     2 bedrock_res_type_display = vc
     2 subsect_code_value = f8
     2 subsect_display = vc
     2 sect_code_value = f8
     2 sect_display = vc
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
 FREE SET temporgs
 RECORD temporgs(
   1 orgs[*]
     2 id = f8
 )
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
     2 serv_res_code_value = f8
     2 serv_res_display = vc
     2 bedrock_res_type_id = f8
     2 bedrock_res_type_name = vc
     2 bedrock_res_type_display = vc
     2 subsect_code_value = f8
     2 subsect_display = vc
     2 sect_code_value = f8
     2 sect_display = vc
     2 org_id = f8
 )
 FREE SET valid_orgs
 RECORD valid_orgs(
   1 orgs[*]
     2 id = f8
 )
 SET inst_cd = 0.0
 SET dept_cd = 0.0
 SET sect_cd = 0.0
 SET subsect_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=223
   AND cv.cdf_meaning IN ("INSTITUTION", "DEPARTMENT", "SECTION", "SUBSECTION")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="INSTITUTION")
    inst_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="DEPARTMENT")
    dept_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="SECTION")
    sect_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="SUBSECTION")
    subsect_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET facility_cd = 0.0
 SET building_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=222
   AND cv.cdf_meaning IN ("FACILITY", "BUILDING")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="FACILITY")
    facility_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="BUILDING")
    building_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET org_cnt = size(request->facilities,5)
 SET stat = alterlist(temporgs->orgs,org_cnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = org_cnt),
   location l
  PLAN (d)
   JOIN (l
   WHERE (l.location_cd=request->facilities[d.seq].code_value)
    AND l.active_ind=1)
  DETAIL
   temporgs->orgs[d.seq].id = l.organization_id
  WITH nocounter
 ;end select
 DECLARE bedrock_room_type = f8 WITH noconstant(0.0), protect
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
 DECLARE room_res_type_id = f8 WITH noconstant(0.0), protect
 DECLARE room_res_type_name = vc WITH noconstant(""), protect
 DECLARE room_res_type_display = vc WITH noconstant(""), protect
 SELECT INTO "nl:"
  FROM br_name_value b
  WHERE b.br_nv_key1="SCHRESGROUP"
   AND b.br_name IN ("PHY", "NURSE", "THERA", "OTHER", "ROOM")
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
   ELSEIF (b.br_name="ROOM")
    room_res_type_id = b.br_name_value_id, room_res_type_name = b.br_name, room_res_type_display = b
    .br_value,
    bedrock_room_type = b.br_name_value_id
   ENDIF
  WITH nocounter
 ;end select
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
 DECLARE cv_parse = vc
 SET cv_parse = build2("cv.display_key = ",search_string)
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
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(sch_get_resource_rep->qual_cnt)),
    code_value cv1,
    code_value cv2,
    dummyt d1,
    br_name_value b
   PLAN (d
    WHERE (sch_get_resource_rep->qual[d.seq].active_ind=1)
     AND (sch_get_resource_rep->qual[d.seq].quota=0)
     AND (sch_get_resource_rep->qual[d.seq].res_type_flag=3)
     AND (sch_get_resource_rep->qual[d.seq].service_resource_cd > 0))
    JOIN (cv1
    WHERE (cv1.code_value=sch_get_resource_rep->qual[d.seq].resource_cd)
     AND cv1.active_ind=1)
    JOIN (cv2
    WHERE (cv2.code_value=sch_get_resource_rep->qual[d.seq].service_resource_cd)
     AND cv2.cdf_meaning="RADEXAMROOM"
     AND cv2.active_ind=1)
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
     refer_text_updt_cnt, temp->resources[tcnt].sch_res_updt_cnt = sch_get_resource_rep->qual[d.seq].
     updt_cnt, temp->resources[tcnt].serv_res_code_value = sch_get_resource_rep->qual[d.seq].
     service_resource_cd,
     temp->resources[tcnt].serv_res_display = sch_get_resource_rep->qual[d.seq].id_disp
    ENDIF
   WITH nocounter, outerjoin = d1
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM br_name_value b,
   sch_resource s,
   long_text_reference l,
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
   JOIN (cv
   WHERE cv.code_value=outerjoin(s.service_resource_cd)
    AND cv.active_ind=outerjoin(1))
  DETAIL
   IF (((cnvtreal(b.br_value)=bedrock_room_type) OR (s.res_type_flag=3
    AND cnvtreal(b.br_value) != bedrock_room_type)) )
    IF (s.res_type_flag != 2)
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
      sch_res_updt_cnt = s.updt_cnt, temp->resources[tcnt].serv_res_code_value = s
      .service_resource_cd,
      temp->resources[tcnt].serv_res_display = cv.display
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
      ELSEIF (cnvtreal(b.br_value)=room_res_type_id)
       temp->resources[tcnt].bedrock_res_type_id = room_res_type_id, temp->resources[tcnt].
       bedrock_res_type_name = room_res_type_name, temp->resources[tcnt].bedrock_res_type_display =
       room_res_type_display
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv,
   sch_resource sr
  PLAN (cv
   WHERE parser(cv_parse)
    AND cv.code_set=221
    AND cv.cdf_meaning="RADEXAMROOM"
    AND cv.active_ind=1)
   JOIN (sr
   WHERE sr.service_resource_cd=outerjoin(cv.code_value)
    AND sr.active_ind=outerjoin(1))
  DETAIL
   IF (sr.resource_cd=0)
    found_ind = 0, start = 1, num = 0
    IF (tcnt > 0)
     found_ind = locateval(num,start,tcnt,cv.code_value,temp->resources[num].serv_res_code_value)
    ENDIF
    IF (found_ind=0)
     tcnt = (tcnt+ 1), stat = alterlist(temp->resources,tcnt), temp->resources[tcnt].
     serv_res_code_value = cv.code_value,
     temp->resources[tcnt].serv_res_display = cv.display
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (tcnt > 0)
  SET valid_org_cnt = 0
  SELECT INTO "nl:"
   FROM br_sched_dept b,
    code_value cv,
    location l
   PLAN (b)
    JOIN (cv
    WHERE cv.code_value=b.location_cd
     AND cv.active_ind=1)
    JOIN (l
    WHERE l.location_cd=cv.code_value
     AND l.active_ind=1)
   DETAIL
    found_ind = 0, start = 1, num = 0
    IF (valid_org_cnt > 0)
     found_ind = locateval(num,start,valid_org_cnt,l.organization_id,valid_orgs->orgs[num].id)
    ENDIF
    IF (found_ind=0)
     valid_org_cnt = (valid_org_cnt+ 1), stat = alterlist(valid_orgs->orgs,valid_org_cnt), valid_orgs
     ->orgs[valid_org_cnt].id = l.organization_id
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tcnt)),
    resource_group rg1,
    resource_group rg2,
    resource_group rg3,
    resource_group rg4,
    service_resource sr,
    code_value cv1,
    code_value cv2
   PLAN (d
    WHERE (temp->resources[d.seq].serv_res_code_value > 0))
    JOIN (rg1
    WHERE (rg1.child_service_resource_cd=temp->resources[d.seq].serv_res_code_value)
     AND rg1.resource_group_type_cd=subsect_cd
     AND rg1.active_ind=1)
    JOIN (rg2
    WHERE rg2.child_service_resource_cd=rg1.parent_service_resource_cd
     AND rg2.resource_group_type_cd=sect_cd
     AND rg2.active_ind=1)
    JOIN (rg3
    WHERE rg3.child_service_resource_cd=rg2.parent_service_resource_cd
     AND rg3.resource_group_type_cd=dept_cd
     AND rg3.active_ind=1)
    JOIN (rg4
    WHERE rg4.child_service_resource_cd=rg3.parent_service_resource_cd
     AND rg4.resource_group_type_cd=inst_cd
     AND rg4.active_ind=1)
    JOIN (sr
    WHERE sr.service_resource_cd=rg4.parent_service_resource_cd
     AND sr.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=rg1.parent_service_resource_cd
     AND cv1.active_ind=1)
    JOIN (cv2
    WHERE cv2.code_value=rg2.parent_service_resource_cd
     AND cv2.active_ind=1)
   DETAIL
    temp->resources[d.seq].subsect_code_value = rg1.parent_service_resource_cd, temp->resources[d.seq
    ].subsect_display = cv1.display, temp->resources[d.seq].sect_code_value = rg2
    .parent_service_resource_cd,
    temp->resources[d.seq].sect_display = cv2.display, temp->resources[d.seq].org_id = sr
    .organization_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tcnt))
   PLAN (d)
   DETAIL
    move_ind = 1
    IF ((temp->resources[d.seq].bedrock_res_type_id != room_res_type_id))
     found_ind = 0, start = 1, num = 0
     IF (valid_org_cnt > 0)
      found_ind = locateval(num,start,valid_org_cnt,temp->resources[d.seq].org_id,valid_orgs->orgs[
       num].id)
     ENDIF
     IF (found_ind=0)
      move_ind = 0
     ENDIF
    ENDIF
    IF (move_ind=1
     AND org_cnt > 0)
     found_ind = 0, start = 1, num = 0,
     found_ind = locateval(num,start,org_cnt,temp->resources[d.seq].org_id,temporgs->orgs[num].id)
     IF (found_ind=0)
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
     sch_res_updt_cnt, reply->resources[rcnt].serv_res_code_value = temp->resources[d.seq].
     serv_res_code_value,
     reply->resources[rcnt].serv_res_display = temp->resources[d.seq].serv_res_display, reply->
     resources[rcnt].bedrock_res_type_id = temp->resources[d.seq].bedrock_res_type_id, reply->
     resources[rcnt].bedrock_res_type_name = temp->resources[d.seq].bedrock_res_type_name,
     reply->resources[rcnt].bedrock_res_type_display = temp->resources[d.seq].
     bedrock_res_type_display, reply->resources[rcnt].subsect_code_value = temp->resources[d.seq].
     subsect_code_value, reply->resources[rcnt].subsect_display = temp->resources[d.seq].
     subsect_display,
     reply->resources[rcnt].sect_code_value = temp->resources[d.seq].sect_code_value, reply->
     resources[rcnt].sect_display = temp->resources[d.seq].sect_display
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
