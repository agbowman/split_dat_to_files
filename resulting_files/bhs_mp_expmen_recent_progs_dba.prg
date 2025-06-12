CREATE PROGRAM bhs_mp_expmen_recent_progs:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Person Id" = ""
  WITH outdev, s_person_id
 FREE RECORD m_recent_programs
 RECORD m_recent_programs(
   1 l_cntr = i4
   1 recent_programs[*]
     2 s_descr = vc
     2 f_id = f8
     2 s_name = vc
     2 s_type = vc
     2 l_seq = i4
 )
 DECLARE ms_temp = vc WITH protect, noconstant(" ")
 DECLARE ml_place = i4 WITH protect, noconstant(0)
 DECLARE ml_start = i4 WITH protect, noconstant(0)
 DECLARE ml_end = i4 WITH protect, noconstant(0)
 DECLARE ml_item_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_jsonrecrecentprgs = vc WITH protect, noconstant(" ")
 SET mf_person_id =  $S_PERSON_ID
 SELECT INTO "nl:"
  FROM application_ini a
  WHERE a.person_id=mf_person_id
   AND a.application_number=3070000
  HEAD REPORT
   m_recent_programs->l_cntr = 0
  HEAD a.section
   ml_place = findstring("Program Setting",a.section)
   IF (ml_place > 0
    AND a.section != "Program Setting Count")
    ml_start = (findstring("MenuId=",a.parameter_data)+ 7), ml_end = (findstring("Program=",a
     .parameter_data,ml_start,0) - 1), ms_temp = substring(ml_start,(ml_end - ml_start),a
     .parameter_data)
    IF (ms_temp > " ")
     m_recent_programs->l_cntr = (m_recent_programs->l_cntr+ 1), stat = alterlist(m_recent_programs->
      recent_programs,m_recent_programs->l_cntr), m_recent_programs->recent_programs[
     m_recent_programs->l_cntr].l_seq = m_recent_programs->l_cntr,
     m_recent_programs->recent_programs[m_recent_programs->l_cntr].s_type = "R", m_recent_programs->
     recent_programs[m_recent_programs->l_cntr].f_id = cnvtreal(ms_temp), ml_start = (findstring(
      "Program=",a.parameter_data)+ 8),
     ml_end = (findstring("Description=",a.parameter_data,ml_start,0) - 1), ms_temp = substring(
      ml_start,(ml_end - ml_start),a.parameter_data), m_recent_programs->recent_programs[
     m_recent_programs->l_cntr].s_name = trim(ms_temp,3),
     ml_start = (findstring("Description=",a.parameter_data)+ 12), ml_end = (findstring("Index=",a
      .parameter_data,ml_start,0) - 1), ms_temp = substring(ml_start,(ml_end - ml_start),a
      .parameter_data),
     m_recent_programs->recent_programs[m_recent_programs->l_cntr].s_descr = trim(ms_temp,3)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET ms_jsonrecrecentprgs = cnvtrectojson(m_recent_programs)
 SET _memory_reply_string = ms_jsonrecrecentprgs
#exit_script
 FREE RECORD m_recent_programs
END GO
