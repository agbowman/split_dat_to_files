CREATE PROGRAM dcp_upd_freq_id:dba
 RECORD orders(
   1 order_list[*]
     2 order_id = f8
 )
 RECORD freq(
   1 freq_list[*]
     2 order_id = f8
     2 freq_value = f8
     2 status = f8
 )
 SET count1 = 0
 SET count2 = 0
 SELECT INTO "nl:"
  o.order_id
  FROM orders o
  WHERE o.freq_type_flag > 0
   AND frequency_id=0
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(orders->order_list,5))
    stat = alterlist(orders->order_list,(count1+ 10))
   ENDIF
   orders->order_list[count1].order_id = o.order_id
  FOOT REPORT
   stat = alterlist(orders->order_list,count1)
  WITH check
 ;end select
 IF (curqual=0)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  od.oe_field_value
  FROM (dummyt d  WITH seq = value(count1)),
   order_detail od
  PLAN (d)
   JOIN (od
   WHERE (od.order_id=orders->order_list[d.seq].order_id)
    AND od.oe_field_meaning_id=2094)
  ORDER BY od.order_id, od.action_sequence DESC
  HEAD REPORT
   count2 = 0
  HEAD od.order_id
   count2 = (count2+ 1)
   IF (count2 > size(freq->freq_list,5))
    stat = alterlist(freq->freq_list,(count2+ 10))
   ENDIF
   IF (od.oe_field_value > 0)
    freq->freq_list[count2].status = 1
   ELSE
    freq->freq_list[count2].status = 0
   ENDIF
   freq->freq_list[count2].order_id = orders->order_list[d.seq].order_id, freq->freq_list[count2].
   freq_value = od.oe_field_value
  DETAIL
   col + 0
  FOOT REPORT
   stat = alterlist(freq->freq_list,count2)
  WITH check
 ;end select
 CALL echo(build("second count: ",count2))
 FOR (x = 1 TO 10)
   CALL echo(build("order id: ",freq->freq_list[x].order_id))
   CALL echo(build("freq value: ",freq->freq_list[x].freq_value))
   CALL echo(build("status: ",freq->freq_list[x].status))
 ENDFOR
 IF (curqual=0)
  GO TO exit_program
 ENDIF
 UPDATE  FROM orders o,
   (dummyt d  WITH seq = value(count2))
  SET o.frequency_id = freq->freq_list[d.seq].freq_value
  PLAN (d)
   JOIN (o
   WHERE (o.order_id=freq->freq_list[d.seq].order_id)
    AND (freq->freq_list[d.seq].status=1))
  WITH counter
 ;end update
 COMMIT
#exit_program
END GO
