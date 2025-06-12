CREATE PROGRAM bed_get_rec_recommendations:dba
 FREE SET reply
 RECORD reply(
   1 categories[*]
     2 meaning = vc
     2 display = vc
     2 subcategories[*]
       3 meaning = vc
       3 display = vc
       3 recs[*]
         4 meaning = vc
         4 program_name = vc
         4 short_desc = vc
         4 long_desc = vc
         4 detail_report_name = vc
         4 override_dtls
           5 person_id = f8
           5 name_full_formatted = vc
           5 override_dt_tm = dq8
           5 reason_id = f8
           5 reason_mean = vc
           5 reason_desc = vc
           5 note_id = f8
         4 last_run_dt_tm = dq8
         4 bedrock_ind = i2
         4 notes[*]
           5 note_id = f8
           5 text = vc
           5 user_id = f8
           5 name_full_formatted = vc
           5 date_tm = dq8
         4 detail_text[*]
           5 title = vc
           5 text = vc
         4 release_date = vc
         4 release_number = vc
         4 high_impact_ind = i2
   1 detail_reports[*]
     2 display = vc
     2 program_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_dtl
 RECORD temp_dtl(
   1 detail_reports[*]
     2 display = vc
     2 program_name = vc
 )
 SET reply->status_data.status = "F"
 DECLARE high_impact_only_ind = i2
 SET high_impact_only_ind = 0
 IF (validate(request->high_impact_only_ind))
  SET high_impact_only_ind = request->high_impact_only_ind
 ENDIF
 SET ctcnt = 0
 SET max_sub_cnt = 0
 SET max_rec_cnt = 0
 DECLARE sol_parse = vc
 DECLARE top_parse = vc
 DECLARE filter_parse = vc
 DECLARE sol_size = i4
 DECLARE top_size = i4
 SET sol_size = size(request->solutions,5)
 SET top_size = size(request->topics,5)
 IF (sol_size > 0
  AND top_size > 0)
  SET sol_parse = concat(sol_parse,"brr.solution_mean in (")
  SET sol_parse = concat(sol_parse,"'",request->solutions[1].meaning,"'")
  FOR (x = 2 TO sol_size)
    SET sol_parse = concat(sol_parse,", '",request->solutions[x].meaning,"'")
  ENDFOR
  SET sol_parse = concat(sol_parse,")")
  SET top_parse = concat(top_parse,"brr2.topic_mean in (")
  SET top_parse = concat(top_parse,"'",request->topics[1].meaning,"'")
  FOR (x = 2 TO top_size)
    SET top_parse = concat(top_parse,", '",request->topics[x].meaning,"'")
  ENDFOR
  SET top_parse = concat(top_parse,")")
  SELECT INTO "nl:"
   FROM br_rec_r brr,
    br_rec_r brr2,
    br_rec br,
    br_name_value bnv1,
    br_name_value bnv2,
    prsnl p,
    br_name_value bnv3
   PLAN (brr
    WHERE parser(sol_parse))
    JOIN (brr2
    WHERE brr2.rec_id=brr.rec_id
     AND parser(top_parse))
    JOIN (br
    WHERE br.rec_id=brr2.rec_id
     AND br.active_ind=1
     AND br.client_view_ind=1
     AND ((high_impact_only_ind=0) OR (high_impact_only_ind=1
     AND br.high_impact_ind=1)) )
    JOIN (bnv1
    WHERE bnv1.br_nv_key1="DIAGNOSTICCATEGORIES"
     AND bnv1.br_name=br.category_mean)
    JOIN (bnv2
    WHERE bnv2.br_nv_key1="DIAGNOSTICSUBCATEGORIES"
     AND bnv2.br_name=br.subcategory_mean)
    JOIN (p
    WHERE p.person_id=outerjoin(br.override_prsnl_id)
     AND p.person_id > outerjoin(0))
    JOIN (bnv3
    WHERE bnv3.br_nv_key1=outerjoin("DIAGNOSTICOVREASON")
     AND bnv3.br_name=outerjoin(br.override_mean))
   ORDER BY br.category_mean, br.subcategory_mean, br.sequence
   HEAD REPORT
    ccnt = 0, ctcnt = 0, stat = alterlist(reply->categories,10)
   HEAD br.category_mean
    ccnt = (ccnt+ 1), ctcnt = (ctcnt+ 1)
    IF (ccnt > 10)
     stat = alterlist(reply->categories,(ctcnt+ 10)), ccnt = 1
    ENDIF
    reply->categories[ctcnt].display = bnv1.br_value, reply->categories[ctcnt].meaning = bnv1.br_name,
    scnt = 0,
    stcnt = 0, stat = alterlist(reply->categories[ctcnt].subcategories,10)
   HEAD br.subcategory_mean
    scnt = (scnt+ 1), stcnt = (stcnt+ 1)
    IF (scnt > 10)
     stat = alterlist(reply->categories[ctcnt].subcategories,(stcnt+ 10)), scnt = 1
    ENDIF
    reply->categories[ctcnt].subcategories[stcnt].display = bnv2.br_value, reply->categories[ctcnt].
    subcategories[stcnt].meaning = bnv2.br_name, rcnt = 0,
    rtcnt = 0, stat = alterlist(reply->categories[ctcnt].subcategories[stcnt].recs,100)
   HEAD br.sequence
    rcnt = (rcnt+ 1), rtcnt = (rtcnt+ 1)
    IF (rcnt > 100)
     stat = alterlist(reply->categories[ctcnt].subcategories[stcnt].recs,(rtcnt+ 100)), rcnt = 1
    ENDIF
    reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].meaning = br.rec_mean, reply->
    categories[ctcnt].subcategories[stcnt].recs[rtcnt].program_name = br.program_name, reply->
    categories[ctcnt].subcategories[stcnt].recs[rtcnt].bedrock_ind = br.bedrock_ind,
    reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].detail_report_name = br
    .detail_program_name, reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].long_desc = br
    .long_desc, reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].short_desc = br.short_desc
    IF (br.override_ind=1)
     reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].override_dtls.name_full_formatted = p
     .name_full_formatted, reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].override_dtls.
     person_id = p.person_id, reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].override_dtls
     .override_dt_tm = br.override_dt_tm,
     reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].override_dtls.reason_id = bnv3
     .br_name_value_id, reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].override_dtls.
     reason_mean = br.override_mean, reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].
     override_dtls.reason_desc = bnv3.br_value,
     reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].override_dtls.note_id = br
     .curr_override_note
    ENDIF
    reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].release_date = br.release_date_txt,
    reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].release_number = br.release_nbr_txt,
    reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].high_impact_ind = br.high_impact_ind
   FOOT  br.subcategory_mean
    stat = alterlist(reply->categories[ctcnt].subcategories[stcnt].recs,rtcnt), max_rec_cnt = maxval(
     max_rec_cnt,rtcnt)
   FOOT  br.category_mean
    stat = alterlist(reply->categories[ctcnt].subcategories,stcnt), max_sub_cnt = maxval(max_sub_cnt,
     stcnt)
   FOOT REPORT
    stat = alterlist(reply->categories,ctcnt)
   WITH nocounter
  ;end select
 ELSEIF (((sol_size > 0) OR (top_size > 0)) )
  IF (sol_size > 0)
   SET filter_parse = concat(filter_parse,"brr.solution_mean in (")
   SET filter_parse = concat(filter_parse,"'",request->solutions[1].meaning,"'")
   FOR (x = 2 TO sol_size)
     SET filter_parse = concat(filter_parse,", '",request->solutions[x].meaning,"'")
   ENDFOR
   SET filter_parse = concat(filter_parse,")")
  ENDIF
  IF (top_size > 0)
   SET filter_parse = concat(filter_parse,"brr.topic_mean in (")
   SET filter_parse = concat(filter_parse,"'",request->topics[1].meaning,"'")
   FOR (x = 2 TO top_size)
     SET filter_parse = concat(filter_parse,", '",request->topics[x].meaning,"'")
   ENDFOR
   SET filter_parse = concat(filter_parse,")")
  ENDIF
  SELECT INTO "nl:"
   FROM br_rec_r brr,
    br_rec br,
    br_name_value bnv1,
    br_name_value bnv2,
    prsnl p,
    br_name_value bnv3
   PLAN (brr
    WHERE parser(filter_parse))
    JOIN (br
    WHERE br.rec_id=brr.rec_id
     AND br.active_ind=1
     AND br.client_view_ind=1
     AND ((high_impact_only_ind=0) OR (high_impact_only_ind=1
     AND br.high_impact_ind=1)) )
    JOIN (bnv1
    WHERE bnv1.br_nv_key1="DIAGNOSTICCATEGORIES"
     AND bnv1.br_name=br.category_mean)
    JOIN (bnv2
    WHERE bnv2.br_nv_key1="DIAGNOSTICSUBCATEGORIES"
     AND bnv2.br_name=br.subcategory_mean)
    JOIN (p
    WHERE p.person_id=outerjoin(br.override_prsnl_id)
     AND p.person_id > outerjoin(0))
    JOIN (bnv3
    WHERE bnv3.br_nv_key1=outerjoin("DIAGNOSTICOVREASON")
     AND bnv3.br_name=outerjoin(br.override_mean))
   ORDER BY br.category_mean, br.subcategory_mean, br.sequence
   HEAD REPORT
    ccnt = 0, ctcnt = 0, stat = alterlist(reply->categories,10)
   HEAD br.category_mean
    ccnt = (ccnt+ 1), ctcnt = (ctcnt+ 1)
    IF (ccnt > 10)
     stat = alterlist(reply->categories,(ctcnt+ 10)), ccnt = 1
    ENDIF
    reply->categories[ctcnt].display = bnv1.br_value, reply->categories[ctcnt].meaning = bnv1.br_name,
    scnt = 0,
    stcnt = 0, stat = alterlist(reply->categories[ctcnt].subcategories,10)
   HEAD br.subcategory_mean
    scnt = (scnt+ 1), stcnt = (stcnt+ 1)
    IF (scnt > 10)
     stat = alterlist(reply->categories[ctcnt].subcategories,(stcnt+ 10)), scnt = 1
    ENDIF
    reply->categories[ctcnt].subcategories[stcnt].display = bnv2.br_value, reply->categories[ctcnt].
    subcategories[stcnt].meaning = bnv2.br_name, rcnt = 0,
    rtcnt = 0, stat = alterlist(reply->categories[ctcnt].subcategories[stcnt].recs,100)
   HEAD br.sequence
    rcnt = (rcnt+ 1), rtcnt = (rtcnt+ 1)
    IF (rcnt > 100)
     stat = alterlist(reply->categories[ctcnt].subcategories[stcnt].recs,(rtcnt+ 100)), rcnt = 1
    ENDIF
    reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].meaning = br.rec_mean, reply->
    categories[ctcnt].subcategories[stcnt].recs[rtcnt].program_name = br.program_name, reply->
    categories[ctcnt].subcategories[stcnt].recs[rtcnt].bedrock_ind = br.bedrock_ind,
    reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].detail_report_name = br
    .detail_program_name, reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].long_desc = br
    .long_desc, reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].short_desc = br.short_desc
    IF (br.override_ind=1)
     reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].override_dtls.name_full_formatted = p
     .name_full_formatted, reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].override_dtls.
     person_id = p.person_id, reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].override_dtls
     .override_dt_tm = br.override_dt_tm,
     reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].override_dtls.reason_id = bnv3
     .br_name_value_id, reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].override_dtls.
     reason_mean = br.override_mean, reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].
     override_dtls.reason_desc = bnv3.br_value,
     reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].override_dtls.note_id = br
     .curr_override_note
    ENDIF
    reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].release_date = br.release_date_txt,
    reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].release_number = br.release_nbr_txt,
    reply->categories[ctcnt].subcategories[stcnt].recs[rtcnt].high_impact_ind = br.high_impact_ind
   FOOT  br.subcategory_mean
    stat = alterlist(reply->categories[ctcnt].subcategories[stcnt].recs,rtcnt), max_rec_cnt = maxval(
     max_rec_cnt,rtcnt)
   FOOT  br.category_mean
    stat = alterlist(reply->categories[ctcnt].subcategories,stcnt), max_sub_cnt = maxval(max_sub_cnt,
     stcnt)
   FOOT REPORT
    stat = alterlist(reply->categories,ctcnt)
   WITH nocounter
  ;end select
 ENDIF
 FOR (x = 1 TO ctcnt)
  SET stcnt = size(reply->categories[x].subcategories,5)
  FOR (y = 1 TO stcnt)
   SET rtcnt = size(reply->categories[x].subcategories[y].recs,5)
   IF (rtcnt > 0)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(rtcnt)),
      br_rec b,
      br_long_text bl1,
      br_long_text bl2,
      br_long_text bl3,
      br_long_text bl4,
      br_long_text bl5,
      br_long_text bl6
     PLAN (d1)
      JOIN (b
      WHERE (b.rec_mean=reply->categories[x].subcategories[y].recs[d1.seq].meaning))
      JOIN (bl1
      WHERE bl1.long_text_id=b.design_decision_txt_id)
      JOIN (bl2
      WHERE bl2.long_text_id=b.rationale_txt_id)
      JOIN (bl3
      WHERE bl3.long_text_id=b.recommendation_txt_id)
      JOIN (bl4
      WHERE bl4.long_text_id=b.resolution_txt_id)
      JOIN (bl5
      WHERE bl5.long_text_id=b.code_lvl_txt_id)
      JOIN (bl6
      WHERE bl6.long_text_id=outerjoin(b.spec_cons_txt_id))
     ORDER BY d1.seq
     DETAIL
      stat = alterlist(reply->categories[x].subcategories[y].recs[d1.seq].detail_text,7), reply->
      categories[x].subcategories[y].recs[d1.seq].detail_text[1].title = "Overview:", reply->
      categories[x].subcategories[y].recs[d1.seq].detail_text[1].text = reply->categories[x].
      subcategories[y].recs[d1.seq].long_desc,
      reply->categories[x].subcategories[y].recs[d1.seq].detail_text[2].title = "Design Decision:",
      reply->categories[x].subcategories[y].recs[d1.seq].detail_text[2].text = trim(bl1.long_text),
      reply->categories[x].subcategories[y].recs[d1.seq].detail_text[3].title = "Recommendation:",
      reply->categories[x].subcategories[y].recs[d1.seq].detail_text[3].text = trim(bl3.long_text),
      reply->categories[x].subcategories[y].recs[d1.seq].detail_text[4].title = "Rationale:", reply->
      categories[x].subcategories[y].recs[d1.seq].detail_text[4].text = trim(bl2.long_text),
      reply->categories[x].subcategories[y].recs[d1.seq].detail_text[5].title = "Resolution:", reply
      ->categories[x].subcategories[y].recs[d1.seq].detail_text[5].text = trim(bl4.long_text), reply
      ->categories[x].subcategories[y].recs[d1.seq].detail_text[6].title =
      "Effective as of Code Level:",
      reply->categories[x].subcategories[y].recs[d1.seq].detail_text[6].text = trim(bl5.long_text),
      reply->categories[x].subcategories[y].recs[d1.seq].detail_text[7].title =
      "Special Considerations:", reply->categories[x].subcategories[y].recs[d1.seq].detail_text[7].
      text = trim(bl6.long_text)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(rtcnt)),
      br_name_value bnv,
      br_long_text blt,
      prsnl p
     PLAN (d1)
      JOIN (bnv
      WHERE (bnv.br_name=reply->categories[x].subcategories[y].recs[d1.seq].meaning)
       AND bnv.br_nv_key1="DIAGNOSTICNOTES")
      JOIN (blt
      WHERE blt.long_text_id=cnvtint(trim(bnv.br_value)))
      JOIN (p
      WHERE p.person_id=blt.updt_id)
     ORDER BY d1.seq
     HEAD d1.seq
      ncnt = 0, ntcnt = 0, stat = alterlist(reply->categories[x].subcategories[y].recs[d1.seq].notes,
       10)
     DETAIL
      ncnt = (ncnt+ 1), ntcnt = (ntcnt+ 1)
      IF (ncnt > 10)
       stat = alterlist(reply->categories[x].subcategories[y].recs[d1.seq].notes,(ntcnt+ 10)), ncnt
        = 1
      ENDIF
      reply->categories[x].subcategories[y].recs[d1.seq].notes[ntcnt].note_id = bnv.br_name_value_id,
      reply->categories[x].subcategories[y].recs[d1.seq].notes[ntcnt].text = trim(blt.long_text),
      reply->categories[x].subcategories[y].recs[d1.seq].notes[ntcnt].user_id = p.person_id,
      reply->categories[x].subcategories[y].recs[d1.seq].notes[ntcnt].name_full_formatted = p
      .name_full_formatted, reply->categories[x].subcategories[y].recs[d1.seq].notes[ntcnt].date_tm
       = blt.updt_dt_tm
     FOOT  d1.seq
      stat = alterlist(reply->categories[x].subcategories[y].recs[d1.seq].notes,ntcnt)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(rtcnt)),
      br_name_value b
     PLAN (d1)
      JOIN (b
      WHERE b.br_nv_key1="DIAGNOSTICDTLREPORT"
       AND (b.br_name=reply->categories[x].subcategories[y].recs[d1.seq].detail_report_name))
     ORDER BY b.br_name_value_id
     HEAD REPORT
      dcnt = 0, dtcnt = size(temp_dtl->detail_reports,5), stat = alterlist(temp_dtl->detail_reports,(
       dtcnt+ 10))
     HEAD b.br_name_value_id
      dcnt = (dcnt+ 1), dtcnt = (dtcnt+ 1)
      IF (dcnt > 10)
       stat = alterlist(temp_dtl->detail_reports,(dtcnt+ 10)), dcnt = 1
      ENDIF
      temp_dtl->detail_reports[dtcnt].program_name = b.br_name, temp_dtl->detail_reports[dtcnt].
      display = b.br_value
     FOOT REPORT
      stat = alterlist(temp_dtl->detail_reports,dtcnt)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(rtcnt)),
      br_rec br,
      br_rec_history bh
     PLAN (d1)
      JOIN (br
      WHERE (br.rec_mean=reply->categories[x].subcategories[y].recs[d1.seq].meaning))
      JOIN (bh
      WHERE bh.rec_id=br.rec_id)
     ORDER BY d1.seq
     DETAIL
      reply->categories[x].subcategories[y].recs[d1.seq].last_run_dt_tm = bh.run_dt_tm
     WITH nocounter
    ;end select
   ENDIF
  ENDFOR
 ENDFOR
 SET tdtl_cnt = size(temp_dtl->detail_reports,5)
 IF (tdtl_cnt > 0)
  SELECT INTO "nl:"
   a = temp_dtl->detail_reports[d.seq].program_name
   FROM (dummyt d  WITH seq = value(tdtl_cnt))
   PLAN (d)
   ORDER BY a
   HEAD REPORT
    dcnt = 0, dtcnt = 0, stat = alterlist(reply->detail_reports,10)
   HEAD a
    dcnt = (dcnt+ 1), dtcnt = (dtcnt+ 1)
    IF (dcnt > 10)
     stat = alterlist(reply->detail_reports,(dtcnt+ 10)), dcnt = 1
    ENDIF
    reply->detail_reports[dtcnt].program_name = temp_dtl->detail_reports[d.seq].program_name, reply->
    detail_reports[dtcnt].display = temp_dtl->detail_reports[d.seq].display
   FOOT REPORT
    stat = alterlist(reply->detail_reports,dtcnt)
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
