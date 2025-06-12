CREATE PROGRAM bed_upd_phone_seq:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET parent_name = fillstring(40," ")
 SET parent_id = 0.0
 SET phone_cd = 0.0
 SET cnt = 0
 SET zero_found = 0
 SET first_time = "Y"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 RECORD phone(
   1 qual[*]
     2 id = f8
     2 seq = i4
 )
 SELECT INTO "nl:"
  FROM phone p
  PLAN (p
   WHERE p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY p.parent_entity_name, p.parent_entity_id, p.phone_type_cd,
   p.phone_type_seq
  DETAIL
   IF (first_time="Y")
    IF (p.phone_type_seq=0)
     cnt = (cnt+ 1), stat = alterlist(phone->qual,cnt), phone->qual[cnt].id = p.phone_id,
     phone->qual[cnt].seq = p.phone_type_seq, zero_found = 1
    ELSE
     zero_found = 0
    ENDIF
    first_time = "N", parent_name = p.parent_entity_name, parent_id = p.parent_entity_id,
    phone_cd = p.phone_type_cd
   ELSE
    IF (p.parent_entity_name=parent_name
     AND p.parent_entity_id=parent_id
     AND p.phone_type_cd=phone_cd)
     IF (zero_found=1)
      cnt = (cnt+ 1), stat = alterlist(phone->qual,cnt), phone->qual[cnt].id = p.phone_id,
      phone->qual[cnt].seq = p.phone_type_seq
     ENDIF
    ELSE
     IF (p.phone_type_seq=0)
      cnt = (cnt+ 1), stat = alterlist(phone->qual,cnt), phone->qual[cnt].id = p.phone_id,
      phone->qual[cnt].seq = p.phone_type_seq, zero_found = 1
     ELSE
      zero_found = 0
     ENDIF
     parent_name = p.parent_entity_name, parent_id = p.parent_entity_id, phone_cd = p.phone_type_cd
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (cnt > 0)
  SET ierrcode = 0
  UPDATE  FROM phone p,
    (dummyt d  WITH seq = value(cnt))
   SET p.seq = 1, p.phone_type_seq = (phone->qual[d.seq].seq+ 1), p.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    p.updt_id = 0, p.updt_cnt = (p.updt_cnt+ 1)
   PLAN (d)
    JOIN (p
    WHERE (p.phone_id=phone->qual[d.seq].id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = "Y"
   SET reply->error_msg = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (failed="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
