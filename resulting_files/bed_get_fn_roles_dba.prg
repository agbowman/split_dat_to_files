CREATE PROGRAM bed_get_fn_roles:dba
 FREE SET reply
 RECORD reply(
   1 alist[*]
     2 description = vc
     2 display = vc
   1 slist[*]
     2 description = vc
     2 display = vc
     2 track_event_id = f8
     2 tracking_ref_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET atot_count = 0
 SET acount = 0
 SET stot_count = 0
 SET scount = 0
 SET stat = alterlist(reply->alist,50)
 SET stat = alterlist(reply->slist,50)
 SET prv_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=16409
   AND cv.active_ind=1
   AND cv.cdf_meaning="PRVRELN"
  DETAIL
   prv_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM track_reference tr
  WHERE (tr.tracking_group_cd=request->trk_group_code_value)
   AND tr.tracking_ref_type_cd=prv_code_value
   AND tr.active_ind=1
  ORDER BY tr.display
  DETAIL
   stot_count = (stot_count+ 1), scount = (scount+ 1)
   IF (scount > 50)
    stat = alterlist(reply->slist,(stot_count+ 50)), scount = 1
   ENDIF
   reply->slist[stot_count].description = tr.description, reply->slist[stot_count].display = tr
   .display, reply->slist[stot_count].track_event_id = tr.assoc_code_value,
   reply->slist[stot_count].tracking_ref_id = tr.tracking_ref_id
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->slist,stot_count)
 SELECT DISTINCT INTO "NL:"
  FROM track_reference tr
  WHERE (tr.tracking_group_cd != request->trk_group_code_value)
   AND tr.tracking_ref_type_cd=prv_code_value
   AND tr.active_ind=1
  ORDER BY tr.display
  HEAD tr.display
   found = 0
   FOR (i = 1 TO stot_count)
     IF ((reply->slist[i].display=tr.display))
      i = stot_count, found = 1
     ENDIF
   ENDFOR
   IF (found=0)
    atot_count = (atot_count+ 1), acount = (acount+ 1)
    IF (acount > 50)
     stat = alterlist(reply->alist,(atot_count+ 50)), acount = 1
    ENDIF
    reply->alist[atot_count].description = tr.description, reply->alist[atot_count].display = tr
    .display
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->alist,atot_count)
 IF (atot_count=0
  AND stot_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 GO TO exit_script
#exit_script
 CALL echorecord(reply)
END GO
