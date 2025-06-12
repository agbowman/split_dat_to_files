CREATE PROGRAM cps_get_scd_macro_list:dba
 SET stat = alterlist(reply->notes,10)
 SET story_idx = 0
 SELECT INTO "nl:"
  FROM scd_story s,
   scd_paragraph sp,
   scd_sentence ss,
   prsnl pl1,
   prsnl pl2
  PLAN (s
   WHERE s.story_type_cd IN (pre_para_cd, pre_sent_cd, pre_term_cd)
    AND  $1
    AND  $2
    AND  $3
    AND  $4)
   JOIN (pl1
   WHERE pl1.person_id=s.author_id)
   JOIN (pl2
   WHERE pl2.person_id=s.updt_id)
   JOIN (ss
   WHERE ss.scd_story_id=s.scd_story_id)
   JOIN (sp
   WHERE sp.scd_paragraph_id=ss.scd_paragraph_id)
  ORDER BY s.scd_story_id
  HEAD REPORT
   story_idx = 0
  HEAD s.scd_story_id
   story_idx = (story_idx+ 1)
   IF (mod(story_idx,10)=0)
    stat = alterlist(reply->notes,(story_idx+ 10))
   ENDIF
   reply->notes[story_idx].scd_story_id = s.scd_story_id, reply->notes[story_idx].encounter_id = 0.0,
   reply->notes[story_idx].person_id = 0.0,
   reply->notes[story_idx].story_type_cd = s.story_type_cd, reply->notes[story_idx].title = s.title,
   reply->notes[story_idx].story_completion_status_cd = s.story_completion_status_cd,
   reply->notes[story_idx].author_id = s.author_id, reply->notes[story_idx].author_name = pl1
   .name_full_formatted, reply->notes[story_idx].event_id = s.event_id,
   reply->notes[story_idx].active_ind = s.active_ind, reply->notes[story_idx].update_lock_user_id = s
   .update_lock_user_id, reply->notes[story_idx].update_lock_dt_tm = s.update_lock_dt_tm,
   reply->notes[story_idx].updt_id = s.updt_id, reply->notes[story_idx].updt_name = pl2
   .name_full_formatted, reply->notes[story_idx].updt_dt_tm = s.updt_dt_tm,
   reply->notes[story_idx].entry_mode_cd = s.entry_mode_cd, stat = alterlist(reply->notes[story_idx].
    paragraphs,10), para_idx = 0
  HEAD sp.scd_paragraph_id
   para_idx = (para_idx+ 1)
   IF (mod(para_idx,10)=0)
    stat = alterlist(reply->notes[story_idx].paragraphs,(para_idx+ 10))
   ENDIF
   reply->notes[story_idx].paragraphs[para_idx].scr_paragraph_type_id = sp.scr_paragraph_type_id,
   stat = alterlist(reply->notes[story_idx].paragraphs[para_idx].sentences,10), sent_idx = 0
  DETAIL
   sent_idx = (sent_idx+ 1)
   IF (mod(sent_idx,10)=0)
    stat = alterlist(reply->notes[story_idx].paragraphs[para_idx].sentences,(sent_idx+ 10))
   ENDIF
   reply->notes[story_idx].paragraphs[para_idx].sentences[sent_idx].scd_sentence_id = ss
   .scd_sentence_id, reply->notes[story_idx].paragraphs[para_idx].sentences[sent_idx].
   canonical_sentence_pattern_id = ss.canonical_sentence_pattern_id, reply->notes[story_idx].
   paragraphs[para_idx].sentences[sent_idx].scr_term_hier_id = ss.scr_term_hier_id
  FOOT  sp.scd_paragraph_id
   stat = alterlist(reply->notes[story_idx].paragraphs[para_idx].sentences,sent_idx)
  FOOT  ss.scd_story_id
   stat = alterlist(reply->notes[story_idx].paragraphs,para_idx)
  FOOT REPORT
   stat = alterlist(reply->notes,story_idx)
   IF (story_idx=0)
    reply->status_data.status = "Z"
   ELSE
    reply->status_data.status = "S"
   ENDIF
  WITH nocounter
 ;end select
 IF (story_idx > 0)
  FOR (j = 1 TO story_idx)
    SELECT INTO "nl:"
     FROM scd_story_concept ssc
     WHERE (ssc.scd_story_id=reply->notes[j].scd_story_id)
     HEAD REPORT
      concept_idx = 0, stat = alterlist(reply->notes[j].concepts,5)
     DETAIL
      concept_idx = (concept_idx+ 1)
      IF (mod(concept_idx,5)=0)
       stat = alterlist(reply->notes[j].concepts,(concept_idx+ 5))
      ENDIF
      reply->notes[j].concepts[concept_idx].concept_cki = ssc.concept_cki
     FOOT REPORT
      stat = alterlist(reply->notes[j].concepts,concept_idx)
     WITH nocounter
    ;end select
  ENDFOR
 ENDIF
END GO
