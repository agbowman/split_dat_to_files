CREATE PROGRAM bhs_athn_note_types_v2
 RECORD orequest(
   1 role_type_cd = f8
   1 prsnl_id = f8
 )
 RECORD prequest(
   1 chk_prsnl_ind = i2
   1 prsnl_id = f8
   1 chk_psn_ind = i2
   1 position_cd = f8
   1 chk_ppr_ind = i2
   1 ppr_cd = f8
   1 plist[*]
     2 privilege_cd = f8
     2 privilege_mean = c12
 )
 RECORD t_record(
   1 notes[*]
     2 display = vc
     2 event_code_value = vc
 )
 RECORD out_rec(
   1 can_view = vc
   1 excepts[*]
     2 exception_entity_name = vc
     2 exception_type_disp = vc
     2 exception_type_desc = vc
     2 exception_type_mean = vc
     2 exception_type_value = vc
   1 notes[*]
     2 display = vc
     2 event_code_value = vc
 )
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id= $2))
  HEAD REPORT
   prequest->position_cd = p.position_cd
  WITH nocounter, time = 30
 ;end select
 SET prequest->chk_psn_ind = 1
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.cdf_meaning="ADDDOC"
    AND cv.code_set=6016
    AND cv.active_ind=1)
  HEAD REPORT
   p_cnt = 0
  HEAD cv.code_value
   p_cnt = (p_cnt+ 1), stat = alterlist(prequest->plist,p_cnt), prequest->plist[p_cnt].privilege_mean
    = cv.cdf_meaning,
   prequest->plist[p_cnt].privilege_cd = cv.code_value
  WITH nocounter, time = 30
 ;end select
 SET stat = tdbexecute(4250111,500286,500286,"REC",prequest,
  "REC",preply)
 IF ((preply->qual[1].priv_value_mean="YES"))
  SET out_rec->can_view = "Yes"
 ENDIF
 SET stat = alterlist(out_rec->excepts,preply->qual[1].except_cnt)
 FOR (i = 1 TO preply->qual[1].except_cnt)
   SET out_rec->excepts[i].exception_entity_name = preply->qual[1].excepts[i].exception_entity_name
   SET out_rec->excepts[i].exception_type_disp = preply->qual[1].excepts[i].exception_type_disp
   SET out_rec->excepts[i].exception_type_desc = preply->qual[1].excepts[i].exception_type_desc
   SET out_rec->excepts[i].exception_type_mean = preply->qual[1].excepts[i].exception_type_mean
   SET out_rec->excepts[i].exception_type_value = trim(cnvtstring(preply->qual[1].excepts[i].
     exception_type_cd))
 ENDFOR
 IF ((out_rec->can_view="No"))
  GO TO exit_script
 ENDIF
 IF (( $5=1))
  IF (( $3 > 0))
   SET orequest->prsnl_id =  $3
  ENDIF
  IF (( $4 > 0))
   SET orequest->role_type_cd =  $4
  ENDIF
  SET stat = tdbexecute(600005,600504,600520,"REC",orequest,
   "REC",oreply)
  CALL echorecord(oreply)
  IF (size(oreply->qual,5)=0)
   GO TO end_script
  ENDIF
  SET stat = alterlist(t_record->notes,size(oreply->qual,5))
  FOR (i = 1 TO size(oreply->qual,5))
   SET t_record->notes[i].display = oreply->qual[i].display
   SET t_record->notes[i].event_code_value = trim(cnvtstring(oreply->qual[i].event_cd))
  ENDFOR
  SELECT INTO "nl:"
   note = cnvtupper(t_record->notes[d.seq].display)
   FROM (dummyt d  WITH seq = size(t_record->notes,5))
   PLAN (d)
   ORDER BY note
   HEAD REPORT
    cnt = 0
   HEAD note
    cnt = (cnt+ 1), stat = alterlist(out_rec->notes,cnt), out_rec->notes[cnt].display = t_record->
    notes[d.seq].display,
    out_rec->notes[cnt].event_code_value = t_record->notes[d.seq].event_code_value
   WITH nocounter, time = 30
  ;end select
 ENDIF
 IF (( $5=2))
  SELECT INTO "nl:"
   FROM v500_event_code vec
   PLAN (vec
    WHERE vec.event_add_access_ind=1)
   ORDER BY vec.event_cd_disp
   HEAD REPORT
    cnt = 0
   HEAD vec.event_cd_disp
    cnt = (cnt+ 1), stat = alterlist(out_rec->notes,cnt), out_rec->notes[cnt].display = vec
    .event_cd_disp,
    out_rec->notes[cnt].event_code_value = trim(cnvtstring(vec.event_cd))
   WITH nocounter, time = 30
  ;end select
 ENDIF
#end_script
 CALL echojson(out_rec, $1)
END GO
