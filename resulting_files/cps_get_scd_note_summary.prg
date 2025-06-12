CREATE PROGRAM cps_get_scd_note_summary
 RECORD reply(
   1 summary_item_count = i4
   1 summary_item_list[*]
     2 summary_item = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET summary_text_cd = uar_get_code_by("MEANING",15752,"SUMMARYTEXT")
 SELECT INTO "NL:"
  std.value_text
  FROM scd_term_data std,
   scd_term st,
   scd_story ss
  PLAN (ss
   WHERE (ss.scd_story_id=request->scd_story_id))
   JOIN (st
   WHERE st.scd_story_id=ss.scd_story_id)
   JOIN (std
   WHERE std.scd_term_data_id=st.scd_term_data_id
    AND std.scd_term_data_type_cd=summary_text_cd)
  ORDER BY std.scd_term_data_id
  HEAD REPORT
   replies = 0
  DETAIL
   std.scd_term_data_id, replies = (replies+ 1)
   IF (mod(replies,10)=1)
    stat = alterlist(reply->summary_item_list,(replies+ 10))
   ENDIF
   reply->summary_item_list[replies].summary_item = std.value_text
  FOOT REPORT
   reply->summary_item_count = replies, stat = alterlist(reply->summary_item_list,replies)
 ;end select
END GO
