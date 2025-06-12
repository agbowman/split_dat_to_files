CREATE PROGRAM ce_get_dynamic_label_seq:dba
 SET error_msg = fillstring(255," ")
 SET error_code = 0
 SELECT DISTINCT INTO "nl:"
  cdl.person_id, cdl.label_seq_nbr
  FROM ce_dynamic_label cdl
  WHERE (cdl.person_id=request->person_id)
   AND cdl.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100 00:00:00")
  ORDER BY cdl.person_id, cdl.label_seq_nbr DESC
  HEAD cdl.person_id
   reply->label_seq_nbr = cdl.label_seq_nbr
  WITH nocounter
 ;end select
 SET error_code = error(error_msg,0)
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
