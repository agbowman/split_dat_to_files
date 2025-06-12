CREATE PROGRAM bed_get_rx_fill_cycle_dups:dba
 FREE SET reply
 RECORD reply(
   1 duplicates[*]
     2 dispense_category
       3 code_value = f8
       3 display = vc
       3 description = vc
     2 unit
       3 code_value = f8
       3 display = vc
       3 description = vc
     2 fill_cycles[*]
       3 code_value = f8
       3 display = vc
       3 description = vc
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
 SET cnt = 0
 SET fcnt = size(request->facilities,5)
 IF (fcnt=0)
  GO TO exit_script
 ENDIF
 RECORD temp(
   1 qual[*]
     2 d_cd = f8
     2 l_cd = f8
     2 dup_ind = i2
 )
 SELECT DISTINCT INTO "nl:"
  b.dispense_category_cd, b.location_cd
  FROM (dummyt d  WITH seq = value(fcnt)),
   fill_batch f,
   fill_cycle_batch b,
   code_value c,
   code_value c2,
   code_value c3
  PLAN (d)
   JOIN (f
   WHERE (f.loc_facility_cd=request->facilities[d.seq].code_value))
   JOIN (b
   WHERE b.fill_batch_cd=f.fill_batch_cd
    AND b.dispense_category_cd > 0
    AND b.location_cd > 0)
   JOIN (c
   WHERE c.code_value=b.fill_batch_cd
    AND c.active_ind=1)
   JOIN (c2
   WHERE c2.code_value=b.dispense_category_cd
    AND c2.active_ind=1)
   JOIN (c3
   WHERE c3.code_value=b.location_cd
    AND c3.active_ind=1)
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].d_cd = b.dispense_category_cd,
   temp->qual[cnt].l_cd = b.location_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   fill_cycle_batch b,
   code_value cv
  PLAN (d)
   JOIN (b
   WHERE (b.dispense_category_cd=temp->qual[d.seq].d_cd)
    AND (b.location_cd=temp->qual[d.seq].l_cd))
   JOIN (cv
   WHERE cv.code_value=b.fill_batch_cd
    AND cv.active_ind=1)
  ORDER BY d.seq, b.fill_batch_cd
  HEAD d.seq
   dup_count = 0
  HEAD b.fill_batch_cd
   dup_count = (dup_count+ 1)
   IF (dup_count > 1)
    temp->qual[d.seq].dup_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SET dcnt = 0
 FOR (x = 1 TO cnt)
   IF ((temp->qual[x].dup_ind=1))
    SET dcnt = (dcnt+ 1)
    SET stat = alterlist(reply->duplicates,dcnt)
    SET reply->duplicates[dcnt].dispense_category.code_value = temp->qual[x].d_cd
    SET reply->duplicates[dcnt].unit.code_value = temp->qual[x].l_cd
   ENDIF
 ENDFOR
 IF (dcnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(dcnt)),
   code_value cv
  PLAN (d)
   JOIN (cv
   WHERE (cv.code_value=reply->duplicates[d.seq].dispense_category.code_value))
  ORDER BY d.seq
  HEAD d.seq
   reply->duplicates[d.seq].dispense_category.display = cv.display, reply->duplicates[d.seq].
   dispense_category.description = cv.description
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(dcnt)),
   code_value cv
  PLAN (d)
   JOIN (cv
   WHERE (cv.code_value=reply->duplicates[d.seq].unit.code_value))
  ORDER BY d.seq
  HEAD d.seq
   reply->duplicates[d.seq].unit.display = cv.display, reply->duplicates[d.seq].unit.description = cv
   .description
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(dcnt)),
   fill_cycle_batch b,
   code_value c
  PLAN (d)
   JOIN (b
   WHERE (b.dispense_category_cd=reply->duplicates[d.seq].dispense_category.code_value)
    AND (b.location_cd=reply->duplicates[d.seq].unit.code_value))
   JOIN (c
   WHERE c.code_value=b.fill_batch_cd
    AND c.active_ind=1)
  ORDER BY d.seq, b.fill_batch_cd
  HEAD d.seq
   ccnt = 0
  HEAD b.fill_batch_cd
   ccnt = (ccnt+ 1), stat = alterlist(reply->duplicates[d.seq].fill_cycles,ccnt), reply->duplicates[d
   .seq].fill_cycles[ccnt].code_value = b.fill_batch_cd,
   reply->duplicates[d.seq].fill_cycles[ccnt].display = c.display, reply->duplicates[d.seq].
   fill_cycles[ccnt].description = c.description
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
