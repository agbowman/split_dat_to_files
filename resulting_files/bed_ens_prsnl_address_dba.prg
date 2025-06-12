CREATE PROGRAM bed_ens_prsnl_address:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 prsnl[*]
      2 prsnl_id = f8
      2 address[*]
        3 address_id = f8
        3 address_type_code_value = f8
        3 address_type_seq = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp_add
 RECORD temp_add(
   1 address[*]
     2 prsnl_id = f8
     2 org_address_id = f8
     2 address_id = f8
     2 address_type_code_value = f8
     2 address_type_seq = i4
     2 street_addr = vc
     2 street_addr2 = vc
     2 street_addr3 = vc
     2 street_addr4 = vc
     2 city = vc
     2 state_code_value = f8
     2 zipcode = vc
     2 country_code_value = f8
     2 county_code_value = f8
     2 contact_name = vc
     2 residence_type_code_value = f8
     2 comment_txt = vc
     2 postal_barcode_info = vc
     2 operation_hours = vc
     2 country = vc
     2 county = vc
     2 state = vc
     2 address_info_status_code = f8
     2 district_health_code = f8
     2 mail_stop = vc
     2 operation_hours = vc
     2 address_format_code = f8
     2 address_info_status_code = f8
     2 city_code = f8
     2 district_health_code = f8
     2 postal_barcode_info = vc
     2 postal_identifier = vc
     2 postal_identifier_key = vc
     2 primary_care_code = f8
     2 residence_code = f8
     2 zip_code_group_code = f8
     2 org_id = f8
     2 mod_seq_flag = i2
 )
 FREE SET prsnl_reltn_add
 RECORD prsnl_reltn_add(
   1 prsnl_reltns[*]
     2 prsnl_reltn_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 person_id = f8
     2 type_code = f8
     2 display_seq = i4
 )
 FREE SET prsnl_reltn_child_add
 RECORD prsnl_reltn_child_add(
   1 reltns[*]
     2 prsnl_reltn_id = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 display_seq = i4
 )
 SET reply->status_data.status = "F"
 DECLARE prsnl_reltn_type = f8 WITH constant(uar_get_code_by("MEANING",30300,"ADDRESS"))
 DECLARE active_code = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE auth_code = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE error_flag = vc WITH noconstant("N")
 DECLARE serrmsg = vc WITH noconstant(fillstring(132," "))
 DECLARE ierrcode = i4 WITH noconstant(error(serrmsg,1))
 DECLARE temp_add_cnt = i4 WITH noconstant(0)
 DECLARE new_address_seq = i4 WITH noconstant(1)
 DECLARE num = i4
 DECLARE pos = i4
 DECLARE address_size = i4
 DECLARE pr_cnt = i4
 DECLARE child_reltn_cnt = i4
 DECLARE addsize = i4
 DECLARE req_cnt = i4 WITH constant(size(request->prsnl,5))
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->prsnl,req_cnt)
 FOR (x = 1 TO req_cnt)
   SET reply->prsnl[x].prsnl_id = request->prsnl[x].prsnl_id
   SET address_size = size(request->prsnl[x].address,5)
   SET stat = alterlist(reply->prsnl[x].address,address_size)
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   (dummyt d2  WITH seq = 1),
   address a,
   prsnl_reltn pr,
   prsnl_reltn_child prc,
   prsnl_reltn_child prc2,
   address a2
  PLAN (d
   WHERE maxrec(d2,size(request->prsnl[d.seq].address,5)) > 0)
   JOIN (d2
   WHERE (request->prsnl[d.seq].address[d2.seq].org_address_id > 0)
    AND (request->prsnl[d.seq].address[d2.seq].action_flag=1))
   JOIN (a
   WHERE (a.address_id=request->prsnl[d.seq].address[d2.seq].org_address_id))
   JOIN (pr
   WHERE pr.parent_entity_id=a.parent_entity_id
    AND (pr.person_id=request->prsnl[d.seq].prsnl_id)
    AND pr.reltn_type_cd=prsnl_reltn_type
    AND pr.parent_entity_name="ORGANIZATION"
    AND pr.active_ind=1
    AND pr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (prc
   WHERE prc.prsnl_reltn_id=pr.prsnl_reltn_id
    AND prc.parent_entity_name="ADDRESS"
    AND prc.parent_entity_id=a.address_id
    AND prc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND prc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (prc2
   WHERE prc2.prsnl_reltn_id=pr.prsnl_reltn_id
    AND prc2.parent_entity_name="ADDRESS"
    AND prc2.parent_entity_id != a.address_id
    AND prc2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND prc2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (a2
   WHERE a2.address_id=prc2.parent_entity_id
    AND a2.parent_entity_id=pr.person_id
    AND a2.parent_entity_name="PERSON"
    AND a2.active_ind=1)
  ORDER BY d.seq, d2.seq
  DETAIL
   request->prsnl[d.seq].address[d2.seq].action_flag = 4, reply->prsnl[d.seq].address[d2.seq].
   address_id = a2.address_id, reply->prsnl[d.seq].address[d2.seq].address_type_code_value = a2
   .address_type_cd,
   reply->prsnl[d.seq].address[d2.seq].address_type_seq = a2.address_type_seq
  WITH nocounter
 ;end select
 SET temp_add_cnt = 0
 FOR (x = 1 TO req_cnt)
  SET address_size = size(request->prsnl[x].address,5)
  FOR (y = 1 TO address_size)
   IF ((request->prsnl[x].address[y].action_flag=1))
    SELECT INTO "NL:"
     j = seq(address_seq,nextval)"##################;rp0"
     FROM dual d
     PLAN (d)
     DETAIL
      request->prsnl[x].address[y].address_id = cnvtreal(j)
     WITH format, counter
    ;end select
    SET temp_add_cnt = (temp_add_cnt+ 1)
    SET stat = alterlist(temp_add->address,temp_add_cnt)
    SET temp_add->address[temp_add_cnt].org_address_id = request->prsnl[x].address[y].org_address_id
    SELECT INTO "NL:"
     max_seq = max(a.address_type_seq)
     FROM address a
     PLAN (a
      WHERE a.parent_entity_name="PERSON"
       AND (a.parent_entity_id=request->prsnl[x].prsnl_id)
       AND (a.address_type_cd=request->prsnl[x].address[y].address_type_code_value)
       AND a.active_ind=1)
     DETAIL
      new_address_seq = (max_seq+ 1)
     WITH nocounter
    ;end select
    IF ((request->prsnl[x].address[y].org_address_id > 0))
     SET temp_add->address[temp_add_cnt].address_type_seq = new_address_seq
    ELSEIF ((request->prsnl[x].address[y].address_type_seq >= 0))
     SET temp_add->address[temp_add_cnt].address_type_seq = request->prsnl[x].address[y].
     address_type_seq
    ELSE
     SET temp_add->address[temp_add_cnt].address_type_seq = new_address_seq
     SET temp_add->address[temp_add_cnt].mod_seq_flag = 1
    ENDIF
    SET temp_add->address[temp_add_cnt].address_id = request->prsnl[x].address[y].address_id
    SET temp_add->address[temp_add_cnt].prsnl_id = request->prsnl[x].prsnl_id
    SET temp_add->address[temp_add_cnt].address_type_code_value = request->prsnl[x].address[y].
    address_type_code_value
    SET temp_add->address[temp_add_cnt].street_addr = request->prsnl[x].address[y].street_addr
    SET temp_add->address[temp_add_cnt].street_addr2 = request->prsnl[x].address[y].street_addr2
    SET temp_add->address[temp_add_cnt].street_addr3 = request->prsnl[x].address[y].street_addr3
    SET temp_add->address[temp_add_cnt].street_addr4 = request->prsnl[x].address[y].street_addr4
    SET temp_add->address[temp_add_cnt].city = request->prsnl[x].address[y].city
    SET temp_add->address[temp_add_cnt].state_code_value = request->prsnl[x].address[y].
    state_code_value
    SET temp_add->address[temp_add_cnt].zipcode = request->prsnl[x].address[y].zipcode
    SET temp_add->address[temp_add_cnt].country_code_value = request->prsnl[x].address[y].
    country_code_value
    SET temp_add->address[temp_add_cnt].county_code_value = request->prsnl[x].address[y].
    county_code_value
    SET temp_add->address[temp_add_cnt].contact_name = request->prsnl[x].address[y].contact_name
    SET temp_add->address[temp_add_cnt].residence_type_code_value = request->prsnl[x].address[y].
    residence_type_code_value
    SET temp_add->address[temp_add_cnt].comment_txt = request->prsnl[x].address[y].comment_txt
    SET temp_add->address[temp_add_cnt].postal_barcode_info = " "
    SET temp_add->address[temp_add_cnt].operation_hours = " "
    SET temp_add->address[temp_add_cnt].country = " "
    SET temp_add->address[temp_add_cnt].county = " "
    SET temp_add->address[temp_add_cnt].state = " "
    SET temp_add->address[temp_add_cnt].postal_identifier = " "
    SET temp_add->address[temp_add_cnt].postal_identifier_key = " "
   ENDIF
   IF ((request->prsnl[x].address[y].action_flag != 4))
    SET reply->prsnl[x].address[y].address_id = request->prsnl[x].address[y].address_id
    SET reply->prsnl[x].address[y].address_type_code_value = request->prsnl[x].address[y].
    address_type_code_value
    SET reply->prsnl[x].address[y].address_type_seq = request->prsnl[x].address[y].address_type_seq
   ENDIF
  ENDFOR
 ENDFOR
 IF (temp_add_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(temp_add_cnt)),
    address a
   PLAN (d
    WHERE (temp_add->address[d.seq].org_address_id=0)
     AND (temp_add->address[d.seq].address_type_seq=- (1)))
    JOIN (a
    WHERE a.parent_entity_name=outerjoin("PERSON")
     AND a.parent_entity_id=outerjoin(temp_add->address[d.seq].prsnl_id)
     AND a.address_type_cd=outerjoin(temp_add->address[d.seq].address_type_code_value)
     AND a.active_ind=outerjoin(1)
     AND a.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
     AND a.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   ORDER BY d.seq, a.address_type_seq
   DETAIL
    temp_add->address[d.seq].address_type_seq = 0
    IF (a.address_id != 0)
     temp_add->address[d.seq].address_type_seq = (a.address_type_seq+ 1)
    ENDIF
    temp_add->address[d.seq].mod_seq_flag = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(temp_add_cnt)),
    address a,
    address a2
   PLAN (d
    WHERE (temp_add->address[d.seq].org_address_id > 0))
    JOIN (a
    WHERE (a.address_id=temp_add->address[d.seq].org_address_id))
    JOIN (a2
    WHERE a2.parent_entity_name=outerjoin("PERSON")
     AND a2.parent_entity_id=outerjoin(temp_add->address[d.seq].prsnl_id)
     AND a2.address_type_cd=outerjoin(a.address_type_cd)
     AND a2.active_ind=outerjoin(1)
     AND a2.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
     AND a2.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   ORDER BY d.seq, a2.address_type_seq
   DETAIL
    temp_add->address[d.seq].address_type_code_value = a.address_type_cd, temp_add->address[d.seq].
    street_addr = a.street_addr, temp_add->address[d.seq].street_addr2 = a.street_addr2,
    temp_add->address[d.seq].street_addr3 = a.street_addr3, temp_add->address[d.seq].street_addr4 = a
    .street_addr4, temp_add->address[d.seq].city = a.city,
    temp_add->address[d.seq].state_code_value = a.state_cd, temp_add->address[d.seq].zipcode = a
    .zipcode, temp_add->address[d.seq].country_code_value = a.country_cd,
    temp_add->address[d.seq].county_code_value = a.county_cd, temp_add->address[d.seq].contact_name
     = a.contact_name, temp_add->address[d.seq].residence_type_code_value = a.residence_type_cd,
    temp_add->address[d.seq].comment_txt = a.comment_txt, temp_add->address[d.seq].
    postal_barcode_info = a.postal_barcode_info, temp_add->address[d.seq].operation_hours = a
    .operation_hours,
    temp_add->address[d.seq].country = a.country, temp_add->address[d.seq].county = a.county,
    temp_add->address[d.seq].state = a.state,
    temp_add->address[d.seq].address_format_code = a.address_format_cd, temp_add->address[d.seq].
    address_info_status_code = a.address_info_status_cd, temp_add->address[d.seq].city_code = a
    .city_cd,
    temp_add->address[d.seq].district_health_code = a.district_health_cd, temp_add->address[d.seq].
    postal_identifier = a.postal_identifier, temp_add->address[d.seq].postal_identifier_key = a
    .postal_identifier_key,
    temp_add->address[d.seq].primary_care_code = a.primary_care_cd, temp_add->address[d.seq].
    residence_code = a.residence_cd, temp_add->address[d.seq].zip_code_group_code = a
    .zip_code_group_cd
    IF (a2.address_id != 0)
     temp_add->address[d.seq].address_type_seq = (a2.address_type_seq+ 1)
    ENDIF
    temp_add->address[d.seq].org_id = a.parent_entity_id, temp_add->address[d.seq].mod_seq_flag = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(temp_add_cnt))
   PLAN (d)
   ORDER BY temp_add->address[d.seq].prsnl_id, temp_add->address[d.seq].org_address_id, temp_add->
    address[d.seq].address_type_code_value,
    temp_add->address[d.seq].mod_seq_flag, temp_add->address[d.seq].address_type_seq
   HEAD REPORT
    prev_prsnl_id = 0.0, prev_org_add_id = 0.0, prev_add_type = 0.0,
    prev_add_seq = 0
   DETAIL
    IF ((prev_prsnl_id=temp_add->address[d.seq].prsnl_id)
     AND (prev_add_type=temp_add->address[d.seq].address_type_code_value)
     AND (prev_add_seq=temp_add->address[d.seq].address_type_seq)
     AND (temp_add->address[d.seq].mod_seq_flag=1))
     temp_add->address[d.seq].address_type_seq = (prev_add_seq+ 1)
    ENDIF
    prev_prsnl_id = temp_add->address[d.seq].prsnl_id, prev_org_add_id = temp_add->address[d.seq].
    org_address_id, prev_add_type = temp_add->address[d.seq].address_type_code_value,
    prev_add_seq = temp_add->address[d.seq].address_type_seq
   WITH nocounter
  ;end select
  SET ierrcode = 0
  INSERT  FROM address a,
    (dummyt d  WITH seq = value(temp_add_cnt))
   SET a.address_id = temp_add->address[d.seq].address_id, a.parent_entity_name = "PERSON", a
    .parent_entity_id = temp_add->address[d.seq].prsnl_id,
    a.address_type_cd = temp_add->address[d.seq].address_type_code_value, a.address_type_seq =
    temp_add->address[d.seq].address_type_seq, a.updt_id = reqinfo->updt_id,
    a.updt_cnt = 0, a.updt_applctx = reqinfo->updt_applctx, a.updt_task = reqinfo->updt_task,
    a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.active_ind = 1, a.active_status_cd = active_code,
    a.active_status_dt_tm = cnvtdatetime(curdate,curtime3), a.active_status_prsnl_id = reqinfo->
    updt_id, a.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
    a.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), a.street_addr = temp_add->address[d.seq].
    street_addr, a.street_addr2 = temp_add->address[d.seq].street_addr2,
    a.street_addr3 = temp_add->address[d.seq].street_addr3, a.street_addr4 = temp_add->address[d.seq]
    .street_addr4, a.city = temp_add->address[d.seq].city,
    a.state = temp_add->address[d.seq].state, a.state_cd = temp_add->address[d.seq].state_code_value,
    a.zipcode = temp_add->address[d.seq].zipcode,
    a.county = temp_add->address[d.seq].county, a.county_cd = temp_add->address[d.seq].
    county_code_value, a.country = temp_add->address[d.seq].country,
    a.country_cd = temp_add->address[d.seq].country_code_value, a.contact_name = temp_add->address[d
    .seq].contact_name, a.residence_type_cd = temp_add->address[d.seq].residence_type_code_value,
    a.comment_txt = temp_add->address[d.seq].comment_txt, a.postal_barcode_info = temp_add->address[d
    .seq].postal_barcode_info, a.operation_hours = temp_add->address[d.seq].operation_hours,
    a.zipcode_key = cnvtalphanum(temp_add->address[d.seq].zipcode), a.data_status_cd = auth_code, a
    .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
    a.data_status_prsnl_id = reqinfo->updt_id, a.address_format_cd = temp_add->address[d.seq].
    address_format_code, a.address_info_status_cd = temp_add->address[d.seq].address_info_status_code,
    a.city_cd = temp_add->address[d.seq].city_code, a.district_health_cd = temp_add->address[d.seq].
    district_health_code, a.postal_identifier = temp_add->address[d.seq].postal_identifier,
    a.postal_identifier_key = temp_add->address[d.seq].postal_identifier_key, a.primary_care_cd =
    temp_add->address[d.seq].primary_care_code, a.residence_cd = temp_add->address[d.seq].
    residence_code,
    a.zip_code_group_cd = temp_add->address[d.seq].zip_code_group_code
   PLAN (d)
    JOIN (a)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Add address rows."
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  SET pr_cnt = 0
  SET child_reltn_cnt = 0
  FOR (x = 1 TO temp_add_cnt)
    IF ((temp_add->address[x].org_address_id > 0))
     SET pr_cnt = (pr_cnt+ 1)
     SET stat = alterlist(prsnl_reltn_add->prsnl_reltns,pr_cnt)
     SET child_reltn_cnt = (child_reltn_cnt+ 2)
     SELECT INTO "NL:"
      j = seq(person_seq,nextval)"##################;rp0"
      FROM dual d
      PLAN (d)
      DETAIL
       prsnl_reltn_add->prsnl_reltns[pr_cnt].prsnl_reltn_id = cnvtreal(j)
      WITH format, counter
     ;end select
     SET prsnl_reltn_add->prsnl_reltns[pr_cnt].person_id = temp_add->address[x].prsnl_id
     SET prsnl_reltn_add->prsnl_reltns[pr_cnt].parent_entity_id = temp_add->address[x].org_id
     SET prsnl_reltn_add->prsnl_reltns[pr_cnt].parent_entity_name = "ORGANIZATION"
     SET prsnl_reltn_add->prsnl_reltns[pr_cnt].type_code = prsnl_reltn_type
     SET prsnl_reltn_add->prsnl_reltns[pr_cnt].display_seq = 1
     SET stat = alterlist(prsnl_reltn_child_add->reltns,child_reltn_cnt)
     SET prsnl_reltn_child_add->reltns[(child_reltn_cnt - 1)].display_seq = 1
     SET prsnl_reltn_child_add->reltns[(child_reltn_cnt - 1)].parent_entity_id = temp_add->address[x]
     .address_id
     SET prsnl_reltn_child_add->reltns[(child_reltn_cnt - 1)].parent_entity_name = "ADDRESS"
     SET prsnl_reltn_child_add->reltns[(child_reltn_cnt - 1)].prsnl_reltn_id = prsnl_reltn_add->
     prsnl_reltns[pr_cnt].prsnl_reltn_id
     SET prsnl_reltn_child_add->reltns[child_reltn_cnt].display_seq = 2
     SET prsnl_reltn_child_add->reltns[child_reltn_cnt].parent_entity_id = temp_add->address[x].
     org_address_id
     SET prsnl_reltn_child_add->reltns[child_reltn_cnt].parent_entity_name = "ADDRESS"
     SET prsnl_reltn_child_add->reltns[child_reltn_cnt].prsnl_reltn_id = prsnl_reltn_add->
     prsnl_reltns[pr_cnt].prsnl_reltn_id
    ENDIF
  ENDFOR
  IF (pr_cnt > 0)
   SET ierrcode = 0
   INSERT  FROM prsnl_reltn p,
     (dummyt d  WITH seq = value(pr_cnt))
    SET p.active_ind = 1, p.active_status_cd = active_code, p.active_status_dt_tm = cnvtdatetime(
      curdate,curtime3),
     p.active_status_prsnl_id = reqinfo->updt_id, p.beg_effective_dt_tm = cnvtdatetime(curdate,
      curtime3), p.display_seq = prsnl_reltn_add->prsnl_reltns[d.seq].display_seq,
     p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), p.parent_entity_id = prsnl_reltn_add->
     prsnl_reltns[d.seq].parent_entity_id, p.parent_entity_name = prsnl_reltn_add->prsnl_reltns[d.seq
     ].parent_entity_name,
     p.person_id = prsnl_reltn_add->prsnl_reltns[d.seq].person_id, p.prsnl_reltn_id = prsnl_reltn_add
     ->prsnl_reltns[d.seq].prsnl_reltn_id, p.reltn_type_cd = prsnl_reltn_add->prsnl_reltns[d.seq].
     type_code,
     p.updt_id = reqinfo->updt_id, p.updt_cnt = 0, p.updt_applctx = reqinfo->updt_applctx,
     p.updt_task = reqinfo->updt_task, p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (d)
     JOIN (p)
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Insert prsnl_reltn rows."
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
  ENDIF
  IF (child_reltn_cnt > 0)
   SET ierrcode = 0
   INSERT  FROM prsnl_reltn_child p,
     (dummyt d  WITH seq = value(child_reltn_cnt))
    SET p.prsnl_reltn_child_id = seq(person_only_seq,nextval), p.prsnl_reltn_id =
     prsnl_reltn_child_add->reltns[d.seq].prsnl_reltn_id, p.beg_effective_dt_tm = cnvtdatetime(
      curdate,curtime3),
     p.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), p.display_seq = prsnl_reltn_child_add->
     reltns[d.seq].display_seq, p.parent_entity_id = prsnl_reltn_child_add->reltns[d.seq].
     parent_entity_id,
     p.parent_entity_name = prsnl_reltn_child_add->reltns[d.seq].parent_entity_name, p.updt_id =
     reqinfo->updt_id, p.updt_cnt = 0,
     p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->updt_task, p.updt_dt_tm =
     cnvtdatetime(curdate,curtime3)
    PLAN (d)
     JOIN (p)
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET error_flag = "Y"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Add prsnl_reltn_child rows."
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exit_script
   ENDIF
  ENDIF
  IF (temp_add_cnt > 0)
   FOR (r = 1 TO req_cnt)
    SET addsize = size(reply->prsnl[r].address,5)
    FOR (a = 1 TO addsize)
      SET num = 0
      SET pos = 0
      SET pos = locateval(num,1,temp_add_cnt,reply->prsnl[r].address[a].address_id,temp_add->address[
       num].address_id)
      IF (pos > 0)
       SET reply->prsnl[r].address[a].address_type_code_value = temp_add->address[pos].
       address_type_code_value
       SET reply->prsnl[r].address[a].address_type_seq = temp_add->address[pos].address_type_seq
      ENDIF
    ENDFOR
   ENDFOR
  ENDIF
 ENDIF
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
