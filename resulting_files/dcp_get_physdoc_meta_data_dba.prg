CREATE PROGRAM dcp_get_physdoc_meta_data:dba
 DECLARE g_failure = c1 WITH public, noconstant("F")
 DECLARE cerner_end_of_time = vc WITH constant("31-DEC-2100 00:00:00")
 DECLARE cur_notes_size = i4 WITH protect, constant(size(request->notes,5))
 DECLARE reply_itr = i4 WITH protect, noconstant(0)
 IF (validate(reply)=0)
  RECORD reply(
    1 notes[*]
      2 event_id = f8
      2 author_id = f8
      2 encntr_id = f8
      2 entry_mode_cd = f8
      2 event_cd = f8
      2 event_end_dt_tm = dq8
      2 event_end_tz = i4
      2 event_title_text = vc
      2 patient_id = f8
      2 result_status_cd = f8
      2 result_status_mean = vc
      2 result_status_disp = vc
      2 scd_story_id = f8
      2 story_completion_status_cd = f8
      2 story_completion_status_mean = vc
      2 story_completion_status_disp = vc
      2 story_type_cd = f8
      2 story_type_mean = vc
      2 child_doc_rows = i4
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 IF (cur_notes_size=0)
  SET g_failure = "T"
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->notes,cur_notes_size)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cur_notes_size)),
   clinical_event ce,
   scd_story s
  PLAN (d)
   JOIN (ce
   WHERE (ce.event_id=request->notes[d.seq].event_id)
    AND ce.valid_until_dt_tm=cnvtdatetime(cerner_end_of_time))
   JOIN (s
   WHERE (s.event_id= Outerjoin(ce.event_id)) )
  DETAIL
   IF (ce.event_id != 0.0)
    reply_itr += 1, reply->notes[reply_itr].event_id = ce.event_id, reply->notes[reply_itr].author_id
     = ce.performed_prsnl_id,
    reply->notes[reply_itr].encntr_id = ce.encntr_id, reply->notes[reply_itr].entry_mode_cd = ce
    .entry_mode_cd, reply->notes[reply_itr].event_cd = ce.event_cd,
    reply->notes[reply_itr].event_end_dt_tm = ce.event_end_dt_tm, reply->notes[reply_itr].
    event_end_tz = ce.event_end_tz, reply->notes[reply_itr].event_title_text = ce.event_title_text,
    reply->notes[reply_itr].patient_id = ce.person_id, reply->notes[reply_itr].result_status_cd = ce
    .result_status_cd, reply->notes[reply_itr].result_status_mean = uar_get_code_meaning(ce
     .result_status_cd),
    reply->notes[reply_itr].result_status_disp = uar_get_code_display(ce.result_status_cd), reply->
    notes[reply_itr].scd_story_id = s.scd_story_id, reply->notes[reply_itr].
    story_completion_status_cd = s.story_completion_status_cd,
    reply->notes[reply_itr].story_completion_status_mean = uar_get_code_meaning(s
     .story_completion_status_cd), reply->notes[reply_itr].story_completion_status_disp =
    uar_get_code_display(s.story_completion_status_cd), reply->notes[reply_itr].story_type_cd = s
    .story_type_cd,
    reply->notes[reply_itr].story_type_mean = uar_get_code_meaning(s.story_type_cd)
   ENDIF
  WITH nocounter
 ;end select
 IF (((curqual=0) OR (reply_itr != cur_notes_size)) )
  SET g_failure = "T"
 ENDIF
 DECLARE ddoceventclasscd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"DOC"))
 DECLARE number_notes = i4 WITH protect, constant(size(reply->notes,5))
 FOR (note_index = 1 TO number_notes)
   DECLARE cnt = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM clinical_event c
    PLAN (c
     WHERE (c.parent_event_id=reply->notes[note_index].event_id)
      AND c.event_class_cd=ddoceventclasscd
      AND c.valid_until_dt_tm=cnvtdatetime(cerner_end_of_time))
    DETAIL
     cnt += 1
    WITH nocounter
   ;end select
   SET reply->notes[note_index].child_doc_rows = cnt
 ENDFOR
#exit_script
 IF (g_failure="T")
  SET reply->status_data.status = "F"
  CALL echorecord(request,"DCP_GET_PHYSDOC_META_DATA_log",1)
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
