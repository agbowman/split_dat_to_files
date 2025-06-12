CREATE PROGRAM bed_get_dgb_chk_prefs:dba
 FREE SET reply
 RECORD reply(
   1 applications[*]
     2 application_number = i4
     2 mc_ind = i2
     2 mc_pos_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET req_cnt = size(request->applications,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->applications,req_cnt)
 FOR (x = 1 TO req_cnt)
   SET reply->applications[x].application_number = request->applications[x].application_number
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   view_prefs a,
   code_value cv
  PLAN (d)
   JOIN (a
   WHERE (a.application_number=reply->applications[d.seq].application_number)
    AND a.prsnl_id=0
    AND a.view_name="PVINBOX"
    AND a.frame_type="ORG"
    AND a.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=outerjoin(a.position_cd)
    AND cv.active_ind=outerjoin(1))
  ORDER BY d.seq
  DETAIL
   IF (a.position_cd > 0
    AND cv.code_value > 0)
    reply->applications[d.seq].mc_pos_ind = 1
   ELSEIF (a.position_cd=0)
    reply->applications[d.seq].mc_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 FOR (x = 1 TO req_cnt)
   IF ((reply->applications[x].mc_pos_ind=0))
    SELECT INTO "nl:"
     FROM view_prefs a,
      code_value cv
     PLAN (cv
      WHERE cv.code_set=88
       AND cv.active_ind=1)
      JOIN (a
      WHERE a.position_cd=outerjoin(cv.code_value)
       AND a.application_number=outerjoin(reply->applications[x].application_number)
       AND a.prsnl_id=outerjoin(0)
       AND a.frame_type=outerjoin("ORG")
       AND a.active_ind=outerjoin(1))
     DETAIL
      IF (a.view_prefs_id=0
       AND (reply->applications[x].mc_ind=1))
       reply->applications[x].mc_pos_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
