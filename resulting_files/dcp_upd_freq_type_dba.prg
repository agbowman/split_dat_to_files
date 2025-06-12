CREATE PROGRAM dcp_upd_freq_type:dba
 RECORD orders(
   1 order_list[*]
     2 order_id = f8
 )
 RECORD freq(
   1 freq_list[*]
     2 order_id = f8
     2 freq_value = f8
     2 new_freq_cd = f8
     2 status = f8
 )
 RECORD new_freq(
   1 new_list[*]
     2 order_id = f8
     2 freq_type = f8
 )
 SET count1 = 0
 SET count2 = 0
 SET count3 = 0
 SELECT INTO "nl:"
  o.order_id
  FROM orders o
  WHERE ((o.freq_type_flag=0) OR (o.freq_type_flag=null))
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
    AND od.oe_field_meaning_id=2011)
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
 IF (curqual=0)
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  fs.frequency_type
  FROM (dummyt d  WITH seq = value(count2)),
   frequency_schedule fs
  PLAN (d)
   JOIN (fs
   WHERE (fs.frequency_cd=freq->freq_list[d.seq].freq_value)
    AND (freq->freq_list[d.seq].status=1)
    AND fs.freq_qualifier=14)
  HEAD REPORT
   count3 = 0
  DETAIL
   count3 = (count3+ 1)
   IF (count3 > size(new_freq->new_list,5))
    stat = alterlist(new_freq->new_list,(count3+ 10))
   ENDIF
   IF (fs.frequency_type > 0)
    new_freq->new_list[count3].freq_type = fs.frequency_type
   ELSE
    new_freq->new_list[count3].freq_type = 0
   ENDIF
   new_freq->new_list[count3].order_id = freq->freq_list[d.seq].order_id
  FOOT REPORT
   stat = alterlist(new_freq->new_list,count3)
  WITH check
 ;end select
 CALL echo(build("third count: ",count3))
 FOR (x = 1 TO count3)
  CALL echo(build("order id: ",new_freq->new_list[x].order_id))
  CALL echo(build("new freq type: ",new_freq->new_list[x].freq_type))
 ENDFOR
 IF (curqual=0)
  GO TO exit_program
 ENDIF
 UPDATE  FROM orders o,
   (dummyt d  WITH seq = value(count3))
  SET o.freq_type_flag = new_freq->new_list[d.seq].freq_type
  PLAN (d)
   JOIN (o
   WHERE (o.order_id=new_freq->new_list[d.seq].order_id)
    AND (new_freq->new_list[d.seq].freq_type != 0))
  WITH counter
 ;end update
 COMMIT
#exit_program
END GO
