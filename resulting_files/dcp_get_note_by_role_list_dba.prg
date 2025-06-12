CREATE PROGRAM dcp_get_note_by_role_list:dba
 RECORD reply(
   1 role_list[*]
     2 position_cd = f8
     2 note_type_list[*]
       3 note_type_list_id = f8
       3 note_type_id = f8
       3 note_type_description = vc
       3 event_cd = f8
       3 display = vc
       3 seq = i4
       3 updt_cnt = i4
   1 encntr_type_list[*]
     2 encntr_type_class_cd = f8
     2 note_type_list[*]
       3 note_type_list_id = f8
       3 note_type_id = f8
       3 note_type_description = vc
       3 event_cd = f8
       3 display = vc
       3 seq = i4
       3 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE role_count = i4 WITH protect, noconstant(size(request->role_list,5))
 DECLARE encntr_type_count = i4 WITH protect, noconstant(size(request->encntr_type_list,5))
 SET reply->status_data.status = "F"
 IF (role_count > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(role_count)),
    note_type_list ntl,
    note_type nt,
    v500_event_code v
   PLAN (d)
    JOIN (ntl
    WHERE (ntl.role_type_cd=request->role_list[d.seq].position_cd))
    JOIN (nt
    WHERE ntl.note_type_id=nt.note_type_id
     AND nt.data_status_ind > outerjoin(0))
    JOIN (v
    WHERE nt.event_cd=v.event_cd)
   ORDER BY d.seq, ntl.seq_num
   HEAD REPORT
    temp_role_count = 0
   HEAD d.seq
    temp_role_count = (temp_role_count+ 1)
    IF (mod(temp_role_count,10)=1)
     stat = alterlist(reply->role_list,(temp_role_count+ 9))
    ENDIF
    reply->role_list[temp_role_count].position_cd = ntl.role_type_cd, note_type_count = 0
   DETAIL
    note_type_count = (note_type_count+ 1)
    IF (mod(note_type_count,10)=1)
     stat = alterlist(reply->role_list[temp_role_count].note_type_list,(note_type_count+ 9))
    ENDIF
    reply->role_list[temp_role_count].note_type_list[note_type_count].note_type_list_id = ntl
    .note_type_list_id, reply->role_list[temp_role_count].note_type_list[note_type_count].
    note_type_id = ntl.note_type_id, reply->role_list[temp_role_count].note_type_list[note_type_count
    ].note_type_description = nt.note_type_description,
    reply->role_list[temp_role_count].note_type_list[note_type_count].display = v.event_cd_disp,
    reply->role_list[temp_role_count].note_type_list[note_type_count].event_cd = v.event_cd, reply->
    role_list[temp_role_count].note_type_list[note_type_count].seq = ntl.seq_num,
    reply->role_list[temp_role_count].note_type_list[note_type_count].updt_cnt = ntl.updt_cnt
   FOOT  d.seq
    stat = alterlist(reply->role_list[temp_role_count].note_type_list,note_type_count)
   FOOT REPORT
    stat = alterlist(reply->role_list,temp_role_count)
   WITH nocounter
  ;end select
 ENDIF
 IF (encntr_type_count > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(encntr_type_count)),
    note_type_list ntl,
    note_type nt,
    v500_event_code v
   PLAN (d)
    JOIN (ntl
    WHERE (ntl.encntr_type_class_cd=request->encntr_type_list[d.seq].encntr_type_class_cd))
    JOIN (nt
    WHERE ntl.note_type_id=nt.note_type_id
     AND nt.data_status_ind > outerjoin(0))
    JOIN (v
    WHERE nt.event_cd=v.event_cd)
   ORDER BY d.seq, ntl.seq_num
   HEAD REPORT
    temp_encntr_type_count = 0
   HEAD d.seq
    temp_encntr_type_count = (temp_encntr_type_count+ 1)
    IF (mod(temp_encntr_type_count,10)=1)
     stat = alterlist(reply->encntr_type_list,(temp_encntr_type_count+ 9))
    ENDIF
    reply->encntr_type_list[temp_encntr_type_count].encntr_type_class_cd = ntl.encntr_type_class_cd,
    note_type_count = 0
   DETAIL
    note_type_count = (note_type_count+ 1)
    IF (mod(note_type_count,10)=1)
     stat = alterlist(reply->encntr_type_list[temp_encntr_type_count].note_type_list,(note_type_count
      + 9))
    ENDIF
    reply->encntr_type_list[temp_encntr_type_count].note_type_list[note_type_count].note_type_list_id
     = ntl.note_type_list_id, reply->encntr_type_list[temp_encntr_type_count].note_type_list[
    note_type_count].note_type_id = ntl.note_type_id, reply->encntr_type_list[temp_encntr_type_count]
    .note_type_list[note_type_count].note_type_description = nt.note_type_description,
    reply->encntr_type_list[temp_encntr_type_count].note_type_list[note_type_count].display = v
    .event_cd_disp, reply->encntr_type_list[temp_encntr_type_count].note_type_list[note_type_count].
    event_cd = v.event_cd, reply->encntr_type_list[temp_encntr_type_count].note_type_list[
    note_type_count].seq = ntl.seq_num,
    reply->encntr_type_list[temp_encntr_type_count].note_type_list[note_type_count].updt_cnt = ntl
    .updt_cnt
   FOOT  d.seq
    stat = alterlist(reply->encntr_type_list[temp_encntr_type_count].note_type_list,note_type_count)
   FOOT REPORT
    stat = alterlist(reply->encntr_type_list,temp_encntr_type_count)
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
