CREATE PROGRAM bed_ens_prsnl_phone:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 prsnl[*]
      2 prsnl_id = f8
      2 phones[*]
        3 phone_id = f8
        3 phone_type_code_value = f8
        3 sequence = i4
        3 phone_num = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET phone_add
 RECORD phone_add(
   1 phones[*]
     2 action_flag = i2
     2 org_phone_id = f8
     2 prsnl_id = f8
     2 phone_id = f8
     2 phone_type_code_value = f8
     2 phone_format_code_value = f8
     2 sequence = i4
     2 phone_num = vc
     2 description = vc
     2 contact = vc
     2 call_instruction = vc
     2 extension = vc
     2 paging_code = vc
     2 contact_method_code = f8
     2 operation_hours = vc
     2 org_id = f8
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
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET req_cnt = size(request->prsnl,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET prsnl_reltn_type = uar_get_code_by("MEANING",30300,"PHONE")
 SET active_code = uar_get_code_by("MEANING",48,"ACTIVE")
 SET auth_code = uar_get_code_by("MEANING",8,"AUTH")
 SET p_add_cnt = 0
 SET stat = alterlist(reply->prsnl,req_cnt)
 FOR (r = 1 TO req_cnt)
   SET reply->prsnl[r].prsnl_id = request->prsnl[r].prsnl_id
   SET phonesize = size(request->prsnl[r].phones,5)
   SET stat = alterlist(reply->prsnl[r].phones,phonesize)
 ENDFOR
 IF (req_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_cnt)),
    (dummyt d2  WITH seq = 1),
    phone p,
    prsnl_reltn pr,
    prsnl_reltn_child prc,
    prsnl_reltn_child prc2,
    phone p2
   PLAN (d
    WHERE maxrec(d2,size(request->prsnl[d.seq].phones,5)))
    JOIN (d2
    WHERE (request->prsnl[d.seq].phones[d2.seq].org_phone_id > 0))
    JOIN (p
    WHERE (p.phone_id=request->prsnl[d.seq].phones[d2.seq].org_phone_id))
    JOIN (pr
    WHERE pr.parent_entity_id=p.parent_entity_id
     AND (pr.person_id=request->prsnl[d.seq].prsnl_id)
     AND pr.reltn_type_cd=prsnl_reltn_type
     AND pr.parent_entity_name="ORGANIZATION"
     AND pr.active_ind=1
     AND pr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (prc
    WHERE prc.prsnl_reltn_id=pr.prsnl_reltn_id
     AND prc.parent_entity_id=p.phone_id
     AND prc.parent_entity_name="PHONE"
     AND prc.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND prc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (prc2
    WHERE prc2.prsnl_reltn_id=pr.prsnl_reltn_id
     AND prc2.parent_entity_id != p.phone_id
     AND prc2.parent_entity_name="PHONE"
     AND prc2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND prc2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (p2
    WHERE p2.phone_id=prc2.parent_entity_id
     AND p2.parent_entity_id=pr.person_id
     AND p2.parent_entity_name="PERSON"
     AND p2.active_ind=1)
   ORDER BY d.seq, d2.seq
   DETAIL
    reply->prsnl[d.seq].phones[d2.seq].phone_id = p2.phone_id, reply->prsnl[d.seq].phones[d2.seq].
    phone_num = p2.phone_num, reply->prsnl[d.seq].phones[d2.seq].phone_type_code_value = p2
    .phone_type_cd,
    reply->prsnl[d.seq].phones[d2.seq].sequence = p2.phone_type_seq
   WITH nocounter
  ;end select
 ENDIF
 FOR (r = 1 TO req_cnt)
  SET phonesize = size(request->prsnl[r].phones,5)
  FOR (p = 1 TO phonesize)
    IF ((request->prsnl[r].phones[p].action_flag=1)
     AND (reply->prsnl[r].phones[p].phone_id=0))
     SET p_add_cnt = (p_add_cnt+ 1)
     SET stat = alterlist(phone_add->phones,p_add_cnt)
     SET phone_add->phones[p_add_cnt].action_flag = 1
     SET phone_add->phones[p_add_cnt].org_phone_id = request->prsnl[r].phones[p].org_phone_id
     SET phone_add->phones[p_add_cnt].phone_type_code_value = request->prsnl[r].phones[p].
     phone_type_code_value
     SET phone_add->phones[p_add_cnt].phone_format_code_value = request->prsnl[r].phones[p].
     phone_format_code_value
     SET phone_add->phones[p_add_cnt].sequence = request->prsnl[r].phones[p].sequence
     SET phone_add->phones[p_add_cnt].phone_num = request->prsnl[r].phones[p].phone_num
     SET phone_add->phones[p_add_cnt].description = request->prsnl[r].phones[p].description
     SET phone_add->phones[p_add_cnt].contact = request->prsnl[r].phones[p].contact
     SET phone_add->phones[p_add_cnt].call_instruction = request->prsnl[r].phones[p].call_instruction
     SET phone_add->phones[p_add_cnt].extension = request->prsnl[r].phones[p].extension
     SET phone_add->phones[p_add_cnt].paging_code = request->prsnl[r].phones[p].paging_code
     SET phone_add->phones[p_add_cnt].prsnl_id = request->prsnl[r].prsnl_id
     SELECT INTO "NL:"
      j = seq(phone_seq,nextval)"##################;rp0"
      FROM dual d
      PLAN (d)
      DETAIL
       phone_add->phones[p_add_cnt].phone_id = cnvtreal(j)
      WITH format, counter
     ;end select
     SET reply->prsnl[r].phones[p].phone_id = phone_add->phones[p_add_cnt].phone_id
    ENDIF
  ENDFOR
 ENDFOR
 IF (p_add_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(p_add_cnt)),
    phone p
   PLAN (d
    WHERE (phone_add->phones[d.seq].org_phone_id > 0))
    JOIN (p
    WHERE (p.phone_id=phone_add->phones[d.seq].org_phone_id))
   ORDER BY d.seq
   HEAD d.seq
    phone_add->phones[d.seq].call_instruction = p.call_instruction, phone_add->phones[d.seq].contact
     = p.contact, phone_add->phones[d.seq].contact_method_code = p.contact_method_cd,
    phone_add->phones[d.seq].description = p.description, phone_add->phones[d.seq].extension = p
    .extension, phone_add->phones[d.seq].paging_code = p.paging_code,
    phone_add->phones[d.seq].phone_format_code_value = p.phone_format_cd, phone_add->phones[d.seq].
    phone_num = p.phone_num, phone_add->phones[d.seq].phone_type_code_value = p.phone_type_cd,
    phone_add->phones[d.seq].sequence = 1, phone_add->phones[d.seq].operation_hours = p
    .operation_hours, phone_add->phones[d.seq].org_id = p.parent_entity_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(p_add_cnt)),
    phone p
   PLAN (d)
    JOIN (p
    WHERE (p.parent_entity_id=phone_add->phones[d.seq].prsnl_id)
     AND p.parent_entity_name="PERSON"
     AND (p.phone_type_cd=phone_add->phones[d.seq].phone_type_code_value)
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY d.seq, p.phone_type_seq
   DETAIL
    phone_add->phones[d.seq].sequence = (p.phone_type_seq+ 1)
   WITH nocounter
  ;end select
  SET ierrcode = 0
  INSERT  FROM phone p,
    (dummyt d  WITH seq = value(p_add_cnt))
   SET p.phone_id = phone_add->phones[d.seq].phone_id, p.parent_entity_name = "PERSON", p
    .parent_entity_id = phone_add->phones[d.seq].prsnl_id,
    p.phone_type_cd = phone_add->phones[d.seq].phone_type_code_value, p.phone_format_cd = phone_add->
    phones[d.seq].phone_format_code_value, p.phone_num = trim(phone_add->phones[d.seq].phone_num),
    p.phone_num_key = trim(cnvtupper(cnvtalphanum(phone_add->phones[d.seq].phone_num))), p
    .phone_type_seq = phone_add->phones[d.seq].sequence, p.description = trim(phone_add->phones[d.seq
     ].description),
    p.contact = trim(phone_add->phones[d.seq].contact), p.call_instruction = trim(phone_add->phones[d
     .seq].call_instruction), p.extension = trim(phone_add->phones[d.seq].extension),
    p.paging_code = trim(phone_add->phones[d.seq].paging_code), p.contact_method_cd = phone_add->
    phones[d.seq].contact_method_code, p.operation_hours = phone_add->phones[d.seq].operation_hours,
    p.updt_id = reqinfo->updt_id, p.updt_cnt = 0, p.updt_applctx = reqinfo->updt_applctx,
    p.updt_task = reqinfo->updt_task, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.active_ind = 1,
    p.active_status_cd = active_code, p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p
    .active_status_prsnl_id = reqinfo->updt_id,
    p.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100"), p.data_status_cd = auth_code,
    p.data_status_dt_tm = cnvtdatetime(curdate,curtime3), p.data_status_prsnl_id = reqinfo->updt_id
   PLAN (d
    WHERE (phone_add->phones[d.seq].phone_id > 0))
    JOIN (p)
   WITH nocounter
  ;end insert
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Insert copied phone rows."
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  SET child_reltn_cnt = 0
  SET o_add_cnt = 0
  FOR (p = 1 TO p_add_cnt)
    IF ((phone_add->phones[p].org_phone_id > 0))
     SET o_add_cnt = (o_add_cnt+ 1)
     SET stat = alterlist(prsnl_reltn_add->prsnl_reltns,o_add_cnt)
     SET child_reltn_cnt = (child_reltn_cnt+ 2)
     SELECT INTO "NL:"
      j = seq(person_seq,nextval)"##################;rp0"
      FROM dual d
      PLAN (d)
      DETAIL
       prsnl_reltn_add->prsnl_reltns[o_add_cnt].prsnl_reltn_id = cnvtreal(j)
      WITH format, counter
     ;end select
     SET prsnl_reltn_add->prsnl_reltns[o_add_cnt].person_id = phone_add->phones[p].prsnl_id
     SET prsnl_reltn_add->prsnl_reltns[o_add_cnt].parent_entity_id = phone_add->phones[p].org_id
     SET prsnl_reltn_add->prsnl_reltns[o_add_cnt].parent_entity_name = "ORGANIZATION"
     SET prsnl_reltn_add->prsnl_reltns[o_add_cnt].type_code = prsnl_reltn_type
     SET prsnl_reltn_add->prsnl_reltns[o_add_cnt].display_seq = 1
     SET stat = alterlist(prsnl_reltn_child_add->reltns,child_reltn_cnt)
     SET prsnl_reltn_child_add->reltns[(child_reltn_cnt - 1)].display_seq = 1
     SET prsnl_reltn_child_add->reltns[(child_reltn_cnt - 1)].parent_entity_id = phone_add->phones[p]
     .phone_id
     SET prsnl_reltn_child_add->reltns[(child_reltn_cnt - 1)].parent_entity_name = "PHONE"
     SET prsnl_reltn_child_add->reltns[(child_reltn_cnt - 1)].prsnl_reltn_id = prsnl_reltn_add->
     prsnl_reltns[o_add_cnt].prsnl_reltn_id
     SET prsnl_reltn_child_add->reltns[child_reltn_cnt].display_seq = 2
     SET prsnl_reltn_child_add->reltns[child_reltn_cnt].parent_entity_id = phone_add->phones[p].
     org_phone_id
     SET prsnl_reltn_child_add->reltns[child_reltn_cnt].parent_entity_name = "PHONE"
     SET prsnl_reltn_child_add->reltns[child_reltn_cnt].prsnl_reltn_id = prsnl_reltn_add->
     prsnl_reltns[o_add_cnt].prsnl_reltn_id
    ENDIF
  ENDFOR
  SET ierrcode = 0
  IF (o_add_cnt > 0)
   INSERT  FROM prsnl_reltn p,
     (dummyt d  WITH seq = value(o_add_cnt))
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
 ENDIF
 IF (p_add_cnt > 0)
  FOR (r = 1 TO req_cnt)
   SET phonesize = size(reply->prsnl[r].phones,5)
   FOR (p = 1 TO phonesize)
     SET num = 0
     SET pos = 0
     SET pos = locateval(num,1,p_add_cnt,reply->prsnl[r].phones[p].phone_id,phone_add->phones[num].
      phone_id)
     IF (pos > 0)
      SET reply->prsnl[r].phones[p].phone_num = phone_add->phones[pos].phone_num
      SET reply->prsnl[r].phones[p].phone_type_code_value = phone_add->phones[pos].
      phone_type_code_value
      SET reply->prsnl[r].phones[p].sequence = phone_add->phones[pos].sequence
     ENDIF
   ENDFOR
  ENDFOR
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
