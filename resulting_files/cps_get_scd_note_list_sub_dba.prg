CREATE PROGRAM cps_get_scd_note_list_sub:dba
 SET stat = alterlist(reply->notes,5)
 SET idx = 0
 DECLARE story_where_clause = vc
 DECLARE from_clause = vc WITH noconstant(" from ")
 DECLARE plan_clause = vc WITH noconstant(" plan nt ")
 DECLARE pat_where_clause = vc
 DECLARE storypattern_where_clause = vc WITH noconstant(" where ")
 DECLARE select_clause = vc WITH constant('select into "nl:"')
 DECLARE go_clause = vc WITH constant(" go")
 DECLARE detail_clause = vc
 DECLARE buildwhereclause(plan_where_string=vc) = null WITH protect
 DECLARE datestring = vc WITH constant("31-DEC-2100 00:00:00")
 SET from_clause = concat(from_clause," scd_story nt, scd_story_pattern ssp, ")
 SET from_clause = concat(from_clause,"scr_pattern pat, person p, prsnl pl1, prsnl pl2,")
 SET from_clause = concat(from_clause," prsnl pl3, clinical_event ce")
 IF ((request->pattern_id != 0))
  SET from_clause = concat(from_clause,", scd_story_pattern ssp2")
 ENDIF
 IF ((request->encounter_id != 0))
  CALL buildwhereclause(" nt.encounter_id = request->encounter_id")
 ENDIF
 IF ((request->person_id != 0))
  CALL buildwhereclause(" nt.person_id = request->person_id ")
 ENDIF
 IF ((request->type_mean="PRE")
  AND (request->shared_note_ind=1)
  AND (request->user_id != 0))
  CALL buildwhereclause(" (( nt.author_id = request->user_id) or (nt.author_id = 0)) ")
 ELSEIF ((request->user_id != 0)
  AND (request->type_mean="PRE"))
  CALL buildwhereclause(" nt.author_id = request->user_id ")
 ENDIF
 IF ((request->completion_status_cd != 0))
  CALL buildwhereclause(" nt.story_completion_status_cd = request->completion_status_cd ")
 ENDIF
 IF ((request->status_flag=0))
  CALL buildwhereclause(" nt.active_ind = 1 ")
 ELSEIF ((request->status_flag=2))
  CALL buildwhereclause(" nt.active_ind = 0 ")
 ENDIF
 IF ((request->pattern_id != 0))
  SET storypattern_where_clause = concat(storypattern_where_clause,
   " ssp2.scr_pattern_id = request->pattern_id AND"," nt.scd_story_id = ssp2.scd_story_id")
 ENDIF
 IF ((request->type_cd != 0))
  CALL buildwhereclause(" nt.story_type_cd = request->type_cd ")
 ENDIF
 IF ((request->entry_mode_filter_ind=1))
  SET pat_where_clause = "and pat.entry_mode_cd = request->entry_mode_cd"
 ELSEIF ((request->entry_mode_filter_ind=2))
  SET pat_where_clause = "and pat.entry_mode_cd = request->entry_mode_cd or pat.entry_mode_cd = 0"
 ENDIF
 SET plan_clause = concat(plan_clause," ",story_where_clause)
 IF ((request->pattern_id != 0))
  SET plan_clause = concat(plan_clause," join ssp2",storypattern_where_clause)
 ENDIF
 SET plan_clause = concat(plan_clause," join ssp where ssp.scd_story_id = nt.scd_story_id")
 SET plan_clause = concat(plan_clause," join pat where pat.scr_pattern_id = ssp.scr_pattern_id ",
  pat_where_clause)
 SET plan_clause = concat(plan_clause," join p where p.person_id = nt.person_id")
 SET plan_clause = concat(plan_clause," join pl1 where pl1.person_id = nt.author_id")
 SET plan_clause = concat(plan_clause," join pl2 where pl2.person_id = nt.update_lock_user_id")
 SET plan_clause = concat(plan_clause," join pl3 where pl3.person_id = nt.updt_id")
 SET plan_clause = concat(plan_clause," join ce where ce.event_id = nt.event_id")
 SET plan_clause = concat(plan_clause," and (ce.clinsig_updt_dt_tm = NULL or")
 SET plan_clause = concat(plan_clause," ce.clinsig_updt_dt_tm <= ce.updt_dt_tm)")
 SET plan_clause = concat(plan_clause," and (nt.event_id = 0 or")
 SET plan_clause = concat(plan_clause," ce.valid_until_dt_tm = cnvtdatetime(dateString))")
 SET detail_clause =
 " order by nt.scd_story_id, pat.scr_pattern_id, ce.clinical_event_id desc, ce.event_id"
 SET detail_clause = concat(detail_clause," head nt.scd_story_id  idx=idx+1")
 SET detail_clause = concat(detail_clause,
  " if (mod(idx, 5) = 0) stat = alterlist(reply->notes, idx + 5) endif")
 SET detail_clause = concat(detail_clause,
  " pat_idx = 0 stat = alterlist(reply->notes[idx].patterns, 5)")
 SET detail_clause = concat(detail_clause," reply->notes[idx].scd_story_id = nt.scd_story_id")
 SET detail_clause = concat(detail_clause," reply->notes[idx].encounter_id = nt.encounter_id")
 SET detail_clause = concat(detail_clause," reply->notes[idx].person_id = nt.person_id")
 SET detail_clause = concat(detail_clause," reply->notes[idx].person_name = p.name_full_formatted")
 SET detail_clause = concat(detail_clause," reply->notes[idx].story_type_cd = nt.story_type_cd")
 SET detail_clause = concat(detail_clause," reply->notes[idx].title = nt.title")
 SET detail_clause = concat(detail_clause,
  " reply->notes[idx].story_completion_status_cd = nt.story_completion_status_cd")
 SET detail_clause = concat(detail_clause," reply->notes[idx].author_id = pl1.person_id")
 SET detail_clause = concat(detail_clause," reply->notes[idx].author_name = pl1.name_full_formatted")
 SET detail_clause = concat(detail_clause," reply->notes[idx].event_id = nt.event_id")
 SET detail_clause = concat(detail_clause," reply->notes[idx].event_cd = ce.event_cd")
 SET detail_clause = concat(detail_clause," reply->notes[idx].active_ind = nt.active_ind")
 SET detail_clause = concat(detail_clause,
  " reply->notes[idx].update_lock_user_id = nt.update_lock_user_id")
 SET detail_clause = concat(detail_clause,
  " reply->notes[idx].update_lock_user_name = pl2.name_full_formatted")
 SET detail_clause = concat(detail_clause,
  " reply->notes[idx].update_lock_dt_tm = nt.update_lock_dt_tm")
 SET detail_clause = concat(detail_clause," reply->notes[idx].updt_dt_tm = nt.updt_dt_tm")
 SET detail_clause = concat(detail_clause," reply->notes[idx].updt_id = nt.updt_id")
 SET detail_clause = concat(detail_clause," reply->notes[idx].updt_name = pl3.name_full_formatted")
 SET detail_clause = concat(detail_clause," reply->notes[idx].entry_mode_cd = pat.entry_mode_cd")
 SET detail_clause = concat(detail_clause," head ce.event_id ")
 SET detail_clause = concat(detail_clause," if(nt.event_id != 0)")
 SET detail_clause = concat(detail_clause," reply->notes[idx].result_status_cd = ce.result_status_cd"
  )
 SET detail_clause = concat(detail_clause,"  reply->notes[idx].updt_dt_tm = ce.clinsig_updt_dt_tm")
 SET detail_clause = concat(detail_clause,"  reply->notes[idx].updt_id = ce.updt_id")
 SET detail_clause = concat(detail_clause," endif")
 SET detail_clause = concat(detail_clause," head ce.clinical_event_id ")
 SET detail_clause = concat(detail_clause," if(ce.clinsig_updt_dt_tm = ce.updt_dt_tm)")
 SET detail_clause = concat(detail_clause,"  reply->notes[idx].updt_id = ce.updt_id")
 SET detail_clause = concat(detail_clause," endif")
 SET detail_clause = concat(detail_clause," detail")
 SET detail_clause = concat(detail_clause," pat_idx = pat_idx + 1")
 SET detail_clause = concat(detail_clause," if (mod(pat_idx, 5) = 0)")
 SET detail_clause = concat(detail_clause,
  " stat = alterlist(reply->notes[idx].patterns, pat_idx + 5)")
 SET detail_clause = concat(detail_clause," endif")
 SET detail_clause = concat(detail_clause,
  " reply->notes[idx].patterns[pat_idx].scr_pattern_id  = pat.scr_pattern_id")
 SET detail_clause = concat(detail_clause,
  " reply->notes[idx].patterns[pat_idx].pattern_type_cd = pat.pattern_type_cd")
 SET detail_clause = concat(detail_clause,
  " reply->notes[idx].patterns[pat_idx].scr_paragraph_type_id = ")
 SET detail_clause = concat(detail_clause," ssp.scr_paragraph_type_id")
 SET detail_clause = concat(detail_clause,
  " reply->notes[idx].patterns[pat_idx].display = pat.display")
 SET detail_clause = concat(detail_clause,
  " reply->notes[idx].patterns[pat_idx].definition = pat.definition")
 SET detail_clause = concat(detail_clause," foot nt.scd_story_id")
 SET detail_clause = concat(detail_clause," stat = alterlist(reply->notes[idx].patterns,  pat_idx)")
 SET detail_clause = concat(detail_clause," with nocounter")
 CALL parser(select_clause)
 CALL parser(from_clause)
 CALL parser(plan_clause)
 CALL parser(detail_clause)
 CALL parser(go_clause)
 CALL echo(build("select_clause---->",select_clause))
 CALL echo(build("from_clause---->",from_clause))
 CALL echo(build("plan_clause---->",plan_clause))
 CALL echo(build("detail_clause---->",detail_clause))
 CALL echo(build("go_clause---->",go_clause))
 SET stat = alterlist(reply->notes,idx)
 IF (idx > 0)
  FOR (j = 1 TO idx)
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
 IF (idx=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE buildwhereclause(new_where_clause)
   IF (story_where_clause=" ")
    SET story_where_clause = concat("where ",new_where_clause)
   ELSE
    SET story_where_clause = concat(story_where_clause," and ",new_where_clause)
   ENDIF
 END ;Subroutine
END GO
