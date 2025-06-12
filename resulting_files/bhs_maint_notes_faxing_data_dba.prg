CREATE PROGRAM bhs_maint_notes_faxing_data:dba
 PROMPT
  "Mode" = "",
  "Action" = "",
  "Search:" = ""
  WITH s_mode, s_action, s_search
 EXECUTE ccl_prompt_api_dataset "autoset"
 FREE RECORD m_rec
 RECORD m_rec(
   1 ids[*]
     2 s_disp = vc
     2 f_id = f8
 )
 DECLARE ms_mode = vc WITH protect, constant(trim(cnvtupper( $S_MODE)))
 DECLARE ms_action = vc WITH protect, constant(trim(cnvtupper( $S_ACTION)))
 DECLARE ms_search = vc WITH protect, constant(trim(cnvtupper( $S_SEARCH)))
 IF (ms_action="ADD")
  SELECT INTO "nl:"
   FROM scr_pattern sp
   PLAN (sp
    WHERE sp.active_ind=1
     AND cnvtupper(sp.display)=patstring(cnvtupper(concat("*",ms_search,"*")))
     AND sp.scr_pattern_id > 0.0
     AND  NOT ( EXISTS (
    (SELECT
     b.event_cd
     FROM bhs_event_cd_list b
     WHERE b.event_cd=sp.scr_pattern_id
      AND b.active_ind=1
      AND b.listkey="NOTES FAXING"
      AND b.grouper=ms_mode))))
   ORDER BY sp.display
   HEAD REPORT
    pl_cnt = 0
   DETAIL
    pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->ids,pl_cnt), m_rec->ids[pl_cnt].s_disp = trim(sp
     .display),
    m_rec->ids[pl_cnt].f_id = sp.scr_pattern_id
   WITH nocounter
  ;end select
 ELSEIF (ms_action="REMOVE")
  SELECT INTO "nl:"
   FROM bhs_event_cd_list b,
    scr_pattern sp
   PLAN (b
    WHERE b.listkey="NOTES FAXING"
     AND b.grouper=ms_mode
     AND b.active_ind=1)
    JOIN (sp
    WHERE sp.scr_pattern_id=b.event_cd
     AND cnvtupper(sp.display)=patstring(cnvtupper(concat("*",ms_search,"*"))))
   ORDER BY sp.display
   HEAD REPORT
    pl_cnt = 0
   DETAIL
    pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->ids,pl_cnt), m_rec->ids[pl_cnt].s_disp = sp.display,
    m_rec->ids[pl_cnt].f_id = sp.scr_pattern_id
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  display = substring(1,50,m_rec->ids[d.seq].s_disp), id = m_rec->ids[d.seq].f_id
  FROM (dummyt d  WITH seq = value(size(m_rec->ids,5)))
  ORDER BY d.seq
  HEAD REPORT
   stat = makedataset(10)
  DETAIL
   stat = writerecord(0)
  FOOT REPORT
   stat = closedataset(0)
  WITH nocounter, reporthelp
 ;end select
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
