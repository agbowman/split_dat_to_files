CREATE PROGRAM bed_get_datamart_filter_det:dba
 FREE SET reply
 RECORD reply(
   1 filter[*]
     2 br_datamart_filter_id = f8
     2 fields[*]
       3 oe_field_meaning = vc
       3 required_ind = i2
       3 oe_field_meaning_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET fcnt = 0
 SET dcnt = 0
 SET fcnt = size(request->filter,5)
 IF (fcnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->filter,fcnt)
 FOR (x = 1 TO fcnt)
   SET reply->filter[x].br_datamart_filter_id = request->filter[x].br_datamart_filter_id
 ENDFOR
 SET dcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(fcnt)),
   br_datamart_filter_detail b,
   oe_field_meaning m
  PLAN (d)
   JOIN (b
   WHERE (b.br_datamart_filter_id=reply->filter[d.seq].br_datamart_filter_id))
   JOIN (m
   WHERE m.oe_field_meaning=b.oe_field_meaning)
  ORDER BY d.seq
  HEAD d.seq
   dcnt = 0
  DETAIL
   dcnt = (dcnt+ 1), stat = alterlist(reply->filter[d.seq].fields,dcnt), reply->filter[d.seq].fields[
   dcnt].oe_field_meaning = b.oe_field_meaning,
   reply->filter[d.seq].fields[dcnt].required_ind = b.required_ind, reply->filter[d.seq].fields[dcnt]
   .oe_field_meaning_id = m.oe_field_meaning_id
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
