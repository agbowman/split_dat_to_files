CREATE PROGRAM bed_get_iview_mar_positions:dba
 FREE SET reply
 RECORD reply(
   1 positions[*]
     2 code_value = f8
     2 display = vc
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
 SET global_ind = 0
 SELECT INTO "nl:"
  FROM view_prefs v
  PLAN (v
   WHERE v.prsnl_id=0
    AND v.position_cd=0
    AND v.application_number=600005
    AND v.frame_type="CHART"
    AND v.view_name="MAR"
    AND v.active_ind=1)
  DETAIL
   global_ind = 1
  WITH nocounter
 ;end select
 RECORD temp(
   1 positions[*]
     2 code_value = f8
     2 display = vc
     2 add_ind = i2
 )
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=88
    AND c.active_ind=1)
  ORDER BY c.display
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->positions,cnt), temp->positions[cnt].code_value = c
   .code_value,
   temp->positions[cnt].display = c.display
  WITH nocounter
 ;end select
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   view_prefs v
  PLAN (d)
   JOIN (v
   WHERE v.prsnl_id=0
    AND (v.position_cd=temp->positions[d.seq].code_value)
    AND v.application_number=600005
    AND v.frame_type="CHART"
    AND v.view_name="MAR"
    AND v.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   temp->positions[d.seq].add_ind = 1
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
   IF ((temp->positions[x].add_ind=0))
    SELECT INTO "nl:"
     FROM view_prefs v
     PLAN (v
      WHERE v.prsnl_id=0
       AND (v.position_cd=temp->positions[x].code_value)
       AND v.application_number=600005
       AND v.active_ind=1)
     DETAIL
      temp->positions[x].add_ind = 0
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET temp->positions[x].add_ind = global_ind
    ENDIF
   ENDIF
 ENDFOR
 SET rcnt = 0
 FOR (x = 1 TO cnt)
   IF ((temp->positions[x].add_ind=1))
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->positions,rcnt)
    SET reply->positions[rcnt].code_value = temp->positions[x].code_value
    SET reply->positions[rcnt].display = temp->positions[x].display
   ENDIF
 ENDFOR
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
