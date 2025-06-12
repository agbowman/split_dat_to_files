CREATE PROGRAM bed_rec_edept_trklst_refresh:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET reply->run_status_flag = 1
 SELECT INTO "nl:"
  FROM detail_prefs dp,
   name_value_prefs np1,
   view_prefs vp,
   name_value_prefs np2,
   code_value cv
  PLAN (dp
   WHERE dp.application_number=4250111
    AND dp.view_name="TRKLISTVIEW"
    AND dp.active_ind=1
    AND dp.prsnl_id=0)
   JOIN (np1
   WHERE np1.parent_entity_name="DETAIL_PREFS"
    AND np1.parent_entity_id=dp.detail_prefs_id
    AND np1.active_ind=1
    AND trim(np1.pvc_name)="TABINFO")
   JOIN (vp
   WHERE vp.prsnl_id=dp.prsnl_id
    AND vp.position_cd=dp.position_cd
    AND vp.application_number=4250111
    AND vp.view_name="TRKLISTVIEW"
    AND vp.view_seq=dp.view_seq
    AND ((vp.active_ind+ 0)=1))
   JOIN (np2
   WHERE np2.parent_entity_name="VIEW_PREFS"
    AND np2.parent_entity_id=vp.view_prefs_id
    AND trim(np2.pvc_name)="VIEW_CAPTION"
    AND np2.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=outerjoin(dp.position_cd)
    AND cv.active_ind=outerjoin(1))
  DETAIL
   beg_pos = 0, end_pos = 0, str_len = 0,
   end_pos = findstring(";",np1.pvc_value,beg_pos,0), list_type = substring(beg_pos,(end_pos - 1),np1
    .pvc_value)
   CASE (list_type)
    OF "TRKBEDLIST":
     FOR (idx = 1 TO 10)
       beg_pos = (findstring(";",np1.pvc_value,beg_pos,0)+ 1)
     ENDFOR
    OF "LOCATION":
     FOR (idx = 1 TO 10)
       beg_pos = (findstring(";",np1.pvc_value,beg_pos,0)+ 1)
     ENDFOR
    OF "TRKPRVLIST":
     FOR (idx = 1 TO 6)
       beg_pos = (findstring(";",np1.pvc_value,beg_pos,0)+ 1)
     ENDFOR
    OF "TRKGROUP":
     FOR (idx = 1 TO 6)
       beg_pos = (findstring(";",np1.pvc_value,beg_pos,0)+ 1)
     ENDFOR
    ELSE
     beg_pos = 0
   ENDCASE
   end_pos = findstring(",",np1.pvc_value,beg_pos,0), str_len = (end_pos - beg_pos), refunit =
   cnvtint(substring(beg_pos,str_len,np1.pvc_value))
   IF (refunit=1)
    beg_pos = (end_pos+ 1), end_pos = findstring(";",np1.pvc_value,beg_pos,0), str_len = (end_pos -
    beg_pos),
    reftime = substring(beg_pos,str_len,np1.pvc_value)
    IF (cnvtint(reftime) < 30)
     IF (((dp.position_cd > 0
      AND cv.code_value > 0) OR (dp.position_cd=0)) )
      reply->run_status_flag = 3
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
