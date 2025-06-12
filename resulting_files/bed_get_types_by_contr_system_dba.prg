CREATE PROGRAM bed_get_types_by_contr_system:dba
 FREE SET reply
 RECORD reply(
   1 reply_to_reg_question = i2
   1 types[*]
     2 interface_type_id = f8
     2 interface_type = vc
     2 in_out_ind = i2
     2 segments[*]
       3 segment = vc
       3 required_ind = i2
     2 activity_types[*]
       3 code_value = f8
       3 display = vc
       3 mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->reply_to_reg_question = 2
 SELECT INTO "NL:"
  FROM br_name_value b
  WHERE b.br_nv_key1="ALIAS_REG_QUESTION"
   AND b.br_name=cnvtstring(request->contributor_system_code_value)
  DETAIL
   IF (b.br_value IN ("0", "1"))
    reply->reply_to_reg_question = cnvtint(b.br_value)
   ENDIF
  WITH nocounter
 ;end select
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM br_contr_type_r bt,
   br_contr_seg_r bs
  PLAN (bt
   WHERE (bt.contributor_system_cd=request->contributor_system_code_value))
   JOIN (bs
   WHERE bs.br_contr_type_r_id=outerjoin(bt.br_contr_type_r_id))
  ORDER BY bt.br_contr_type_r_id
  HEAD bt.br_contr_type_r_id
   tcnt = (tcnt+ 1), stat = alterlist(reply->types,tcnt), reply->types[tcnt].interface_type_id = bt
   .br_contr_type_r_id,
   reply->types[tcnt].interface_type = bt.interface_type, reply->types[tcnt].in_out_ind = bt
   .in_out_flg, scnt = 0,
   acnt = 0
  DETAIL
   IF (bs.br_contr_seg_r_id > 0)
    scnt = (scnt+ 1), stat = alterlist(reply->types[tcnt].segments,scnt), reply->types[tcnt].
    segments[scnt].segment = bs.segment_name,
    reply->types[tcnt].segments[scnt].required_ind = bs.required_ind
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = tcnt),
   br_contr_act_r ba,
   code_value cv
  PLAN (d)
   JOIN (ba
   WHERE (ba.br_contr_type_r_id=reply->types[d.seq].interface_type_id))
   JOIN (cv
   WHERE cv.code_value=ba.activity_type_cd
    AND cv.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   acnt = 0
  DETAIL
   acnt = (acnt+ 1), stat = alterlist(reply->types[d.seq].activity_types,acnt), reply->types[d.seq].
   activity_types[acnt].code_value = ba.activity_type_cd,
   reply->types[d.seq].activity_types[acnt].display = cv.display, reply->types[d.seq].activity_types[
   acnt].mean = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
