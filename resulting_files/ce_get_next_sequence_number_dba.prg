CREATE PROGRAM ce_get_next_sequence_number:dba
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 SELECT INTO "nl:"
  sequence_id = seq(parser(request->sequence_name),nextval)
  FROM dual
  DETAIL
   cnt += 1, reply->sequence_id = sequence_id
  WITH nocounter
 ;end select
 SET reply->qual = cnt
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
