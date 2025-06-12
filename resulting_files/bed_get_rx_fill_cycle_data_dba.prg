CREATE PROGRAM bed_get_rx_fill_cycle_data:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 fill_cycles[*]
      2 code_value = f8
      2 dispense_categories[*]
        3 code_value = f8
        3 display = vc
        3 description = vc
      2 units[*]
        3 code_value = f8
        3 display = vc
        3 description = vc
      2 cycle_time = i4
      2 cycle_unit_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET ccnt = 0
 SET dcnt = 0
 SET ucnt = 0
 SET ccnt = size(request->fill_cycles,5)
 IF (ccnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->fill_cycles,ccnt)
 FOR (x = 1 TO ccnt)
   SET reply->fill_cycles[x].code_value = request->fill_cycles[x].code_value
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(ccnt)),
   fill_batch f
  PLAN (d)
   JOIN (f
   WHERE (f.fill_batch_cd=request->fill_cycles[d.seq].code_value))
  ORDER BY d.seq
  HEAD d.seq
   reply->fill_cycles[d.seq].cycle_time = f.cycle_time, reply->fill_cycles[d.seq].cycle_unit_flag = f
   .cycle_unit_flag
  WITH nocounter
 ;end select
 IF ((request->load_category_ind=1))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(ccnt)),
    fill_cycle_batch f,
    code_value c,
    dispense_category dc
   PLAN (d)
    JOIN (f
    WHERE (f.fill_batch_cd=request->fill_cycles[d.seq].code_value)
     AND f.dispense_category_cd > 0
     AND f.location_cd > 0)
    JOIN (c
    WHERE c.code_value=f.dispense_category_cd
     AND c.active_ind=1)
    JOIN (dc
    WHERE (dc.order_type_flag=request->fill_cycles[d.seq].order_type_flag)
     AND dc.dispense_category_cd=c.code_value)
   ORDER BY d.seq, f.dispense_category_cd
   HEAD d.seq
    dcnt = 0
   HEAD f.dispense_category_cd
    dcnt = (dcnt+ 1), stat = alterlist(reply->fill_cycles[d.seq].dispense_categories,dcnt), reply->
    fill_cycles[d.seq].dispense_categories[dcnt].code_value = f.dispense_category_cd,
    reply->fill_cycles[d.seq].dispense_categories[dcnt].display = c.display, reply->fill_cycles[d.seq
    ].dispense_categories[dcnt].description = c.description
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->load_location_ind=1))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(ccnt)),
    fill_cycle_batch f,
    code_value c
   PLAN (d)
    JOIN (f
    WHERE (f.fill_batch_cd=request->fill_cycles[d.seq].code_value)
     AND f.dispense_category_cd > 0
     AND f.location_cd > 0)
    JOIN (c
    WHERE c.code_value=f.location_cd
     AND c.active_ind=1)
   ORDER BY d.seq, f.location_cd
   HEAD d.seq
    ucnt = 0
   HEAD f.location_cd
    ucnt = (ucnt+ 1), stat = alterlist(reply->fill_cycles[d.seq].units,ucnt), reply->fill_cycles[d
    .seq].units[ucnt].code_value = f.location_cd,
    reply->fill_cycles[d.seq].units[ucnt].display = c.display, reply->fill_cycles[d.seq].units[ucnt].
    description = c.description
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
