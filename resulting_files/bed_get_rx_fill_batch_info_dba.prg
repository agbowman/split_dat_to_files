CREATE PROGRAM bed_get_rx_fill_batch_info:dba
 FREE SET reply
 RECORD reply(
   1 fill_batches[*]
     2 code_value = f8
     2 fill_cycles[*]
       3 location_code_value = f8
       3 dispense_category_code_value = f8
       3 from_dt_tm = dq8
       3 to_dt_tm = dq8
       3 last_operation_flag = i2
       3 audit_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET cnt = size(request->fill_batches,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->fill_batches,cnt)
 FOR (x = 1 TO cnt)
   SET reply->fill_batches[x].code_value = request->fill_batches[x].code_value
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   fill_cycle_batch b,
   fill_cycle c
  PLAN (d)
   JOIN (b
   WHERE (b.fill_batch_cd=reply->fill_batches[d.seq].code_value))
   JOIN (c
   WHERE c.location_cd=b.location_cd
    AND c.dispense_category_cd=b.dispense_category_cd)
  ORDER BY d.seq
  HEAD d.seq
   ccnt = 0
  DETAIL
   ccnt = (ccnt+ 1), stat = alterlist(reply->fill_batches[d.seq].fill_cycles,ccnt), reply->
   fill_batches[d.seq].fill_cycles[ccnt].location_code_value = c.location_cd,
   reply->fill_batches[d.seq].fill_cycles[ccnt].dispense_category_code_value = c.dispense_category_cd,
   reply->fill_batches[d.seq].fill_cycles[ccnt].from_dt_tm = c.from_dt_tm, reply->fill_batches[d.seq]
   .fill_cycles[ccnt].to_dt_tm = c.to_dt_tm,
   reply->fill_batches[d.seq].fill_cycles[ccnt].last_operation_flag = c.last_operation_flag, reply->
   fill_batches[d.seq].fill_cycles[ccnt].audit_flag = c.audit_flag
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   fill_batch_hx f
  PLAN (d)
   JOIN (f
   WHERE (f.fill_batch_cd=reply->fill_batches[d.seq].code_value))
  ORDER BY d.seq, f.end_dt_tm DESC
  HEAD d.seq
   ccnt = 0
  HEAD d.seq
   ccnt = size(reply->fill_batches[d.seq].fill_cycles,5)
   FOR (c = 1 TO ccnt)
     reply->fill_batches[d.seq].fill_cycles[c].audit_flag = f.fill_audit_flag
   ENDFOR
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
