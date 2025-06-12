CREATE PROGRAM bed_get_rx_fill_cycles:dba
 FREE SET reply
 RECORD reply(
   1 facilities[*]
     2 code_value = f8
     2 fill_cycles[*]
       3 code_value = f8
       3 display = vc
       3 order_type_flag = i2
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
 SET fcnt = size(request->facilities,5)
 IF (fcnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->facilities,fcnt)
 FOR (x = 1 TO fcnt)
   SET reply->facilities[x].code_value = request->facilities[x].code_value
   SET cnt = 0
   SELECT INTO "nl:"
    FROM fill_batch f,
     fill_cycle_batch b,
     code_value c
    PLAN (f
     WHERE (f.loc_facility_cd=request->facilities[x].code_value))
     JOIN (b
     WHERE b.fill_batch_cd=f.fill_batch_cd
      AND b.dispense_category_cd > 0
      AND b.location_cd > 0)
     JOIN (c
     WHERE c.code_value=f.fill_batch_cd
      AND c.active_ind=1)
    ORDER BY c.display
    HEAD c.display
     cnt = (cnt+ 1), stat = alterlist(reply->facilities[x].fill_cycles,cnt), reply->facilities[x].
     fill_cycles[cnt].code_value = f.fill_batch_cd,
     reply->facilities[x].fill_cycles[cnt].display = c.display, reply->facilities[x].fill_cycles[cnt]
     .order_type_flag = f.order_type_flag
    WITH nocounter
   ;end select
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(fcnt)),
   fill_batch f,
   fill_cycle_batch b,
   code_value c,
   location_group lg,
   location_group lg2
  PLAN (d)
   JOIN (f
   WHERE f.loc_facility_cd=0)
   JOIN (b
   WHERE b.fill_batch_cd=f.fill_batch_cd
    AND b.dispense_category_cd > 0
    AND b.location_cd > 0)
   JOIN (c
   WHERE c.code_value=f.fill_batch_cd
    AND c.active_ind=1)
   JOIN (lg
   WHERE lg.child_loc_cd=b.location_cd
    AND ((lg.root_loc_cd+ 0)=0)
    AND ((lg.active_ind+ 0)=1))
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg.parent_loc_cd
    AND ((lg2.parent_loc_cd+ 0)=request->facilities[d.seq].code_value)
    AND ((lg2.root_loc_cd+ 0)=0)
    AND ((lg2.active_ind+ 0)=1))
  ORDER BY d.seq, c.display
  HEAD d.seq
   cnt = size(reply->facilities[d.seq].fill_cycles,5)
  HEAD c.display
   cnt = (cnt+ 1), stat = alterlist(reply->facilities[d.seq].fill_cycles,cnt), reply->facilities[d
   .seq].fill_cycles[cnt].code_value = f.fill_batch_cd,
   reply->facilities[d.seq].fill_cycles[cnt].display = c.display, reply->facilities[d.seq].
   fill_cycles[cnt].order_type_flag = f.order_type_flag
  WITH nocounter
 ;end select
 FOR (x = 1 TO fcnt)
  SET cnt = size(reply->facilities[x].fill_cycles,5)
  FOR (y = 1 TO cnt)
    IF ((reply->facilities[x].fill_cycles[y].order_type_flag=0))
     SELECT INTO "nl:"
      FROM fill_cycle_batch b,
       dispense_category c
      PLAN (b
       WHERE (b.fill_batch_cd=reply->facilities[x].fill_cycles[y].code_value)
        AND b.dispense_category_cd > 0
        AND b.location_cd > 0)
       JOIN (c
       WHERE c.dispense_category_cd=b.dispense_category_cd)
      DETAIL
       reply->facilities[x].fill_cycles[y].order_type_flag = c.order_type_flag
      WITH nocounter
     ;end select
    ENDIF
  ENDFOR
 ENDFOR
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
