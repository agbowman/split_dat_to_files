CREATE PROGRAM bed_get_rx_facilities:dba
 FREE SET reply
 RECORD reply(
   1 facilities[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
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
 SELECT INTO "nl:"
  FROM fill_batch f,
   fill_cycle_batch b,
   code_value c,
   code_value c2
  PLAN (f
   WHERE f.loc_facility_cd > 0)
   JOIN (b
   WHERE b.fill_batch_cd=f.fill_batch_cd
    AND b.dispense_category_cd > 0
    AND b.location_cd > 0)
   JOIN (c
   WHERE c.code_value=f.fill_batch_cd
    AND c.active_ind=1)
   JOIN (c2
   WHERE c2.code_value=f.loc_facility_cd
    AND c2.active_ind=1)
  ORDER BY c2.display
  HEAD c2.display
   cnt = (cnt+ 1), stat = alterlist(reply->facilities,cnt), reply->facilities[cnt].code_value = c2
   .code_value,
   reply->facilities[cnt].display = c2.display, reply->facilities[cnt].description = c2.description
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM fill_batch f,
   fill_cycle_batch b,
   code_value c,
   location_group lg,
   location_group lg2,
   code_value c2
  PLAN (f
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
    AND lg.root_loc_cd=0
    AND lg.active_ind=1)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg.parent_loc_cd
    AND lg2.root_loc_cd=0
    AND lg2.active_ind=1)
   JOIN (c2
   WHERE c2.code_value=lg2.parent_loc_cd
    AND c2.active_ind=1)
  ORDER BY c2.display
  HEAD c2.display
   found = 0
   FOR (x = 1 TO size(reply->facilities,5))
     IF ((c2.code_value=reply->facilities[x].code_value))
      found = 1
     ENDIF
   ENDFOR
   IF (found=0)
    cnt = (cnt+ 1), stat = alterlist(reply->facilities,cnt), reply->facilities[cnt].code_value = c2
    .code_value,
    reply->facilities[cnt].display = c2.display, reply->facilities[cnt].description = c2.description
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
