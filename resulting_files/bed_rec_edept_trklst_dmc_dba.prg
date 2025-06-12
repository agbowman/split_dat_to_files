CREATE PROGRAM bed_rec_edept_trklst_dmc:dba
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
 FREE SET temp
 RECORD temp(
   1 pos[*]
     2 position_cd = f8
 )
 FREE SET temp2
 RECORD temp2(
   1 qual[*]
     2 column_view_id = f8
     2 document_col = i2
 )
 SET tcnt = 0
 SELECT DISTINCT INTO "nl:"
  vp.position_cd
  FROM view_prefs vp,
   code_value cv
  PLAN (vp
   WHERE vp.application_number=4250111
    AND vp.view_name IN ("PowerNote ED", "CLINDOCUMENT")
    AND vp.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=vp.position_cd)
  HEAD REPORT
   tcnt = 0, cnt = 0, stat = alterlist(temp->pos,100)
  DETAIL
   tcnt = (tcnt+ 1), cnt = (cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(temp->pos,(tcnt+ 100)), cnt = 1
   ENDIF
   temp->pos[tcnt].position_cd = vp.position_cd
  FOOT REPORT
   stat = alterlist(temp->pos,tcnt)
  WITH nocounter
 ;end select
 SET vcnt = 0
 IF (tcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tcnt)),
    detail_prefs dp,
    name_value_prefs np,
    view_prefs vp,
    name_value_prefs np2
   PLAN (d)
    JOIN (dp
    WHERE ((dp.application_number+ 0)=4250111)
     AND (dp.position_cd=temp->pos[d.seq].position_cd)
     AND dp.view_name="TRKLISTVIEW"
     AND ((dp.active_ind+ 0)=1))
    JOIN (np
    WHERE np.parent_entity_name="DETAIL_PREFS"
     AND np.parent_entity_id=dp.detail_prefs_id
     AND trim(np.pvc_name)="TABINFO"
     AND np.active_ind=1)
    JOIN (vp
    WHERE ((vp.application_number+ 0)=4250111)
     AND vp.position_cd=dp.position_cd
     AND trim(vp.view_name)=dp.view_name
     AND ((vp.view_seq+ 0)=dp.view_seq)
     AND vp.active_ind=1)
    JOIN (np2
    WHERE np2.parent_entity_name="VIEW_PREFS"
     AND np2.parent_entity_id=vp.view_prefs_id
     AND trim(np2.pvc_name)="VIEW_CAPTION"
     AND np2.active_ind=1)
   ORDER BY d.seq
   HEAD REPORT
    vcnt = 0, cnt = 0, stat = alterlist(temp2->qual,100)
   DETAIL
    beg_pos = 0, end_pos = 0, str_len = 0,
    end_pos = findstring(";",np.pvc_value,beg_pos,0), list_type = substring(beg_pos,(end_pos - 1),np
     .pvc_value)
    CASE (list_type)
     OF "TRKBEDLIST":
      FOR (idx = 1 TO 8)
        beg_pos = (findstring(";",np.pvc_value,beg_pos,0)+ 1)
      ENDFOR
     OF "LOCATION":
      FOR (idx = 1 TO 8)
        beg_pos = (findstring(";",np.pvc_value,beg_pos,0)+ 1)
      ENDFOR
     OF "TRKPRVLIST":
      FOR (idx = 1 TO 4)
        beg_pos = (findstring(";",np.pvc_value,beg_pos,0)+ 1)
      ENDFOR
     OF "TRKGROUP":
      FOR (idx = 1 TO 4)
        beg_pos = (findstring(";",np.pvc_value,beg_pos,0)+ 1)
      ENDFOR
     ELSE
      beg_pos = 0
    ENDCASE
    end_pos = findstring(";",np.pvc_value,beg_pos,0), str_len = (end_pos - beg_pos)
    IF (list_type != "TRKPRVLIST")
     vcnt = (vcnt+ 1), cnt = (cnt+ 1)
     IF (cnt > 100)
      stat = alterlist(temp2->qual,(vcnt+ 100)), cnt = 1
     ENDIF
     temp2->qual[vcnt].column_view_id = cnvtreal(substring(beg_pos,str_len,np.pvc_value))
    ENDIF
   FOOT REPORT
    stat = alterlist(temp2->qual,vcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (vcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(vcnt)),
    name_value_prefs np
   PLAN (d)
    JOIN (np
    WHERE np.parent_entity_name="PREDEFINED_PREFS"
     AND (np.parent_entity_id=temp2->qual[d.seq].column_view_id)
     AND np.pvc_name="Colinfo*"
     AND np.pvc_value="TEDOCMAN*"
     AND np.active_ind=1)
   ORDER BY d.seq
   DETAIL
    temp2->qual[d.seq].document_col = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(vcnt))
   PLAN (d
    WHERE (temp2->qual[d.seq].document_col=0))
   ORDER BY d.seq
   DETAIL
    reply->run_status_flag = 3
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
