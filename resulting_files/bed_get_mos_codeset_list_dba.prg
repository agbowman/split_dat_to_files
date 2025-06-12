CREATE PROGRAM bed_get_mos_codeset_list:dba
 FREE SET reply
 RECORD reply(
   1 code_sets[*]
     2 codeset = i4
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET temp_rep
 RECORD temp_rep(
   1 code_sets[*]
     2 meaning = vc
 )
 SET reply->status_data.status = "F"
 SET tot_cnt = 0
 SELECT DISTINCT INTO "nl:"
  m.oe_field_meaning
  FROM mltm_order_sent_detail m
  PLAN (m
   WHERE m.oe_field_meaning > " ")
  ORDER BY m.oe_field_meaning
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(temp_rep->code_sets,100)
  HEAD m.oe_field_meaning
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(temp_rep->code_sets,(tot_cnt+ 100)), cnt = 1
   ENDIF
   temp_rep->code_sets[tot_cnt].meaning = m.oe_field_meaning
  FOOT REPORT
   stat = alterlist(temp_rep->code_sets,tot_cnt)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  m.oe_field_meaning
  FROM br_ordsent_detail b
  PLAN (b
   WHERE b.oe_field_meaning > " ")
  ORDER BY b.oe_field_meaning
  HEAD REPORT
   cnt = 0, tot_cnt = size(temp_rep->code_sets,5), stat = alterlist(temp_rep->code_sets,(tot_cnt+ 100
    ))
  HEAD b.oe_field_meaning
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(temp_rep->code_sets,(tot_cnt+ 100)), cnt = 1
   ENDIF
   temp_rep->code_sets[tot_cnt].meaning = b.oe_field_meaning
  FOOT REPORT
   stat = alterlist(temp_rep->code_sets,tot_cnt)
  WITH nocounter
 ;end select
 IF (tot_cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(tot_cnt)),
   oe_field_meaning ofm,
   order_entry_fields oef,
   code_value_set cvs
  PLAN (d)
   JOIN (ofm
   WHERE (ofm.oe_field_meaning=temp_rep->code_sets[d.seq].meaning))
   JOIN (oef
   WHERE oef.oe_field_meaning_id=ofm.oe_field_meaning_id
    AND oef.codeset > 0)
   JOIN (cvs
   WHERE cvs.code_set=oef.codeset)
  ORDER BY cvs.code_set
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->code_sets,100)
  HEAD cvs.code_set
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->code_sets,(tcnt+ 100)), cnt = 1
   ENDIF
   reply->code_sets[tcnt].codeset = cvs.code_set, reply->code_sets[tcnt].display = cvs.display
  FOOT REPORT
   stat = alterlist(reply->code_sets,tcnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
