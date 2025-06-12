CREATE PROGRAM bed_get_fn_rpt_access:dba
 FREE SET reply
 RECORD reply(
   1 reports[*]
     2 name = c256
     2 id = f8
     2 positions_not_selected[*]
       3 code_value = f8
       3 disp = c40
     2 positions_selected[*]
       3 code_value = f8
       3 disp = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE pval = f8 WITH noconstant(0.0), protect
 SET pval = request->tracking_group_code_value
 SET alterlist_rcnt = 0
 SET rcnt = 0
 SET stat = alterlist(reply->reports,20)
 SELECT INTO "NL:"
  FROM name_value_prefs nvp1,
   name_value_prefs nvp2,
   name_value_prefs nvp3
  PLAN (nvp1
   WHERE nvp1.parent_entity_name="PREDEFINED_PREFS"
    AND nvp1.parent_entity_id > 0
    AND nvp1.pvc_name="trackinggroup"
    AND cnvtreal(nvp1.pvc_value)=pval
    AND nvp1.active_ind=1)
   JOIN (nvp2
   WHERE nvp2.parent_entity_name="PREDEFINED_PREFS"
    AND nvp2.parent_entity_id=nvp1.parent_entity_id
    AND nvp2.pvc_name="reportname"
    AND nvp2.active_ind=1)
   JOIN (nvp3
   WHERE nvp3.parent_entity_name=outerjoin("PREDEFINED_PREFS")
    AND nvp3.parent_entity_id=outerjoin(nvp2.parent_entity_id)
    AND nvp3.pvc_name=outerjoin("position")
    AND nvp3.active_ind=outerjoin(1))
  ORDER BY nvp2.name_value_prefs_id, nvp3.name_value_prefs_id
  HEAD nvp2.name_value_prefs_id
   rcnt = (rcnt+ 1), alterlist_rcnt = (alterlist_rcnt+ 1)
   IF (alterlist_rcnt > 20)
    stat = alterlist(reply->reports,(rcnt+ 20)), alterlist_rcnt = 0
   ENDIF
   reply->reports[rcnt].id = nvp2.parent_entity_id, reply->reports[rcnt].name = nvp2.pvc_value
  HEAD nvp3.name_value_prefs_id
   alterlist_scnt = 0, scnt = 0, stat = alterlist(reply->reports[rcnt].positions_selected,20)
   IF (nvp3.pvc_value > " ")
    semicolon_pos = findstring(";",nvp3.pvc_value,1), len = (semicolon_pos - 1), nbr_pos = cnvtint(
     substring(1,len,nvp3.pvc_value)),
    start_pos = (semicolon_pos+ 1)
    FOR (x = 1 TO nbr_pos)
      end_pos = 0, end_pos = findstring(",",nvp3.pvc_value,start_pos)
      IF (end_pos=0)
       end_pos = findstring(" ",nvp3.pvc_value,start_pos)
      ENDIF
      len = (end_pos - start_pos), scnt = (scnt+ 1), alterlist_scnt = (alterlist_scnt+ 1)
      IF (alterlist_scnt > 20)
       stat = alterlist(reply->reports[rcnt].positions_selected,(scnt+ 20)), alterlist_scnt = 0
      ENDIF
      reply->reports[rcnt].positions_selected[scnt].code_value = cnvtreal(substring(start_pos,len,
        nvp3.pvc_value)), start_pos = (end_pos+ 1)
    ENDFOR
   ENDIF
   stat = alterlist(reply->reports[rcnt].positions_selected,scnt)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->reports,rcnt)
 FOR (r = 1 TO rcnt)
   SET scnt = 0
   SET scnt = size(reply->reports[r].positions_selected,5)
   SET alterlist_acnt = 0
   SET acnt = 0
   SET stat = alterlist(reply->reports[r].positions_not_selected,20)
   SELECT INTO "NL:"
    FROM code_value cv
    WHERE cv.code_set=88
     AND cv.active_ind=1
    DETAIL
     IF (scnt=0)
      acnt = (acnt+ 1), alterlist_acnt = (alterlist_acnt+ 1)
      IF (alterlist_acnt > 20)
       stat = alterlist(reply->reports[r].positions_not_selected,(acnt+ 20)), alterlist_acnt = 0
      ENDIF
      reply->reports[r].positions_not_selected[acnt].code_value = cv.code_value, reply->reports[r].
      positions_not_selected[acnt].disp = cv.display
     ELSE
      found_ind = 0
      FOR (s = 1 TO scnt)
        IF ((cv.code_value=reply->reports[r].positions_selected[s].code_value))
         found_ind = 1, s = (scnt+ 1)
        ENDIF
      ENDFOR
      IF (found_ind=0)
       acnt = (acnt+ 1), alterlist_acnt = (alterlist_acnt+ 1)
       IF (alterlist_acnt > 20)
        stat = alterlist(reply->reports[r].positions_not_selected,(acnt+ 20)), alterlist_acnt = 0
       ENDIF
       reply->reports[r].positions_not_selected[acnt].code_value = cv.code_value, reply->reports[r].
       positions_not_selected[acnt].disp = cv.display
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->reports[r].positions_not_selected,acnt)
 ENDFOR
 FOR (r = 1 TO rcnt)
   SET scnt = 0
   SET scnt = size(reply->reports[r].positions_selected,5)
   IF (scnt > 0)
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = scnt),
      code_value cv
     PLAN (d)
      JOIN (cv
      WHERE (cv.code_value=reply->reports[r].positions_selected[d.seq].code_value))
     DETAIL
      reply->reports[r].positions_selected[d.seq].disp = cv.display
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
