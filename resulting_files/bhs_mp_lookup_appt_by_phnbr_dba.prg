CREATE PROGRAM bhs_mp_lookup_appt_by_phnbr:dba
 DECLARE mf_cs4_cmrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
 DECLARE mf_cs212_home_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4018"))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ms_jason_str = vc WITH protect, noconstant("")
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_person_id = f8
     2 s_pat_name = vc
     2 s_cmrn = vc
     2 s_dob = vc
     2 s_zip = vc
     2 l_acnt = i4
     2 aqual[*]
       3 f_sch_appt_id = f8
       3 s_sch_event_id = vc
       3 s_appt_date = vc
       3 s_appt_time = vc
       3 s_appt_loc = vc
 ) WITH protect
 FREE RECORD m_temp
 RECORD m_temp(
   1 s_phone = vc
   1 s_patient = vc
   1 l_acnt = i4
   1 aqual[*]
     2 s_field = vc
     2 s_appt_nbr = vc
     2 s_appt_dt = vc
     2 s_appt_tm = vc
     2 s_appt_loc = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM phone ph,
   person p,
   person_alias pa
  PLAN (ph
   WHERE ph.phone_num_key=replace(replace(replace(trim( $1,3),"-",""),"(",""),")","")
    AND ph.parent_entity_name="PERSON"
    AND ph.active_ind=1
    AND ph.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (p
   WHERE p.person_id=ph.parent_entity_id
    AND p.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND pa.person_alias_type_cd=mf_cs4_cmrn_cd)
  ORDER BY p.person_id, pa.beg_effective_dt_tm
  HEAD p.person_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_person_id = p.person_id,
   m_rec->qual[m_rec->l_cnt].s_cmrn = trim(pa.alias,3), m_rec->qual[m_rec->l_cnt].s_dob = trim(format
    (cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),"MM/DD/YYYY;;q"),3), m_rec->qual[m_rec
   ->l_cnt].s_pat_name = trim(p.name_full_formatted,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM address a
  PLAN (a
   WHERE expand(ml_idx1,1,m_rec->l_cnt,a.parent_entity_id,m_rec->qual[ml_idx1].f_person_id)
    AND a.parent_entity_name="PERSON"
    AND a.active_ind=1
    AND a.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND a.address_type_cd=mf_cs212_home_cd)
  ORDER BY a.parent_entity_id, a.address_type_seq
  HEAD a.parent_entity_id
   ml_idx2 = locatevalsort(ml_idx1,1,m_rec->l_cnt,a.parent_entity_id,m_rec->qual[ml_idx1].f_person_id
    )
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].s_zip = trim(substring(1,5,a.zipcode_key),3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM sch_appt sa,
   sch_event se,
   encounter e
  PLAN (sa
   WHERE sa.beg_dt_tm > cnvtdatetime(sysdate)
    AND sa.role_meaning="PATIENT"
    AND sa.active_ind=1
    AND sa.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND expand(ml_idx1,1,m_rec->l_cnt,sa.person_id,m_rec->qual[ml_idx1].f_person_id)
    AND sa.state_meaning IN ("CONFIRMED"))
   JOIN (se
   WHERE se.sch_event_id=sa.sch_event_id
    AND se.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=sa.encntr_id
    AND e.active_ind=1)
  ORDER BY sa.person_id, sa.sch_event_id, sa.beg_dt_tm DESC
  HEAD sa.person_id
   ml_idx2 = locatevalsort(ml_idx1,1,m_rec->l_cnt,sa.person_id,m_rec->qual[ml_idx1].f_person_id)
  HEAD sa.sch_event_id
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].l_acnt += 1, stat = alterlist(m_rec->qual[ml_idx2].aqual,m_rec->qual[ml_idx2
     ].l_acnt), m_rec->qual[ml_idx2].aqual[m_rec->qual[ml_idx2].l_acnt].f_sch_appt_id = sa
    .sch_appt_id,
    m_rec->qual[ml_idx2].aqual[m_rec->qual[ml_idx2].l_acnt].s_sch_event_id = trim(cnvtstring(sa
      .sch_event_id,20,0),3), m_rec->qual[ml_idx2].aqual[m_rec->qual[ml_idx2].l_acnt].s_appt_date =
    trim(format(sa.beg_dt_tm,"MM/DD/YYYY;;q"),3), m_rec->qual[ml_idx2].aqual[m_rec->qual[ml_idx2].
    l_acnt].s_appt_time = trim(format(sa.beg_dt_tm,"HH:mm;;q"),3),
    m_rec->qual[ml_idx2].aqual[m_rec->qual[ml_idx2].l_acnt].s_appt_loc = trim(
     uar_get_code_description(sa.appt_location_cd),3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SET m_temp->s_phone = concat('{"PhoneNumber":["',trim( $1,3),",",trim(cnvtstring(m_rec->l_cnt,20,0),
   3),'"], ')
 SET m_temp->s_patient = '"PatientList":['
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   IF ((ml_idx1=m_rec->l_cnt))
    SET m_temp->s_patient = concat(m_temp->s_patient,'"',m_rec->qual[ml_idx1].s_cmrn,"|",m_rec->qual[
     ml_idx1].s_dob,
     "|",m_rec->qual[ml_idx1].s_zip,"|",m_rec->qual[ml_idx1].s_pat_name,'"')
   ELSE
    SET m_temp->s_patient = concat(m_temp->s_patient,'"',m_rec->qual[ml_idx1].s_cmrn,"|",m_rec->qual[
     ml_idx1].s_dob,
     "|",m_rec->qual[ml_idx1].s_zip,"|",m_rec->qual[ml_idx1].s_pat_name,'",')
   ENDIF
   SET stat = alterlist(m_temp->aqual,ml_idx1)
   SET m_temp->aqual[ml_idx1].s_field = concat('"',m_rec->qual[ml_idx1].s_cmrn,'ApptData":{')
   FOR (ml_idx2 = 1 TO m_rec->qual[ml_idx1].l_acnt)
     IF (size(trim(m_temp->aqual[ml_idx1].s_appt_nbr,3))=0)
      SET m_temp->aqual[ml_idx1].s_appt_nbr = concat('"',m_rec->qual[ml_idx1].aqual[ml_idx2].
       s_sch_event_id,'"')
     ELSE
      SET m_temp->aqual[ml_idx1].s_appt_nbr = concat(m_temp->aqual[ml_idx1].s_appt_nbr,',"',m_rec->
       qual[ml_idx1].aqual[ml_idx2].s_sch_event_id,'"')
     ENDIF
     IF (size(trim(m_temp->aqual[ml_idx1].s_appt_dt,3))=0)
      SET m_temp->aqual[ml_idx1].s_appt_dt = concat('"',m_rec->qual[ml_idx1].aqual[ml_idx2].
       s_appt_date,'"')
     ELSE
      SET m_temp->aqual[ml_idx1].s_appt_dt = concat(m_temp->aqual[ml_idx1].s_appt_dt,',"',m_rec->
       qual[ml_idx1].aqual[ml_idx2].s_appt_date,'"')
     ENDIF
     IF (size(trim(m_temp->aqual[ml_idx1].s_appt_tm,3))=0)
      SET m_temp->aqual[ml_idx1].s_appt_tm = concat('"',m_rec->qual[ml_idx1].aqual[ml_idx2].
       s_appt_time,'"')
     ELSE
      SET m_temp->aqual[ml_idx1].s_appt_tm = concat(m_temp->aqual[ml_idx1].s_appt_tm,',"',m_rec->
       qual[ml_idx1].aqual[ml_idx2].s_appt_time,'"')
     ENDIF
     IF (size(trim(m_temp->aqual[ml_idx1].s_appt_loc,3))=0)
      SET m_temp->aqual[ml_idx1].s_appt_loc = concat('"',m_rec->qual[ml_idx1].aqual[ml_idx2].
       s_appt_loc,'"')
     ELSE
      SET m_temp->aqual[ml_idx1].s_appt_loc = concat(m_temp->aqual[ml_idx1].s_appt_loc,',"',m_rec->
       qual[ml_idx1].aqual[ml_idx2].s_appt_loc,'"')
     ENDIF
   ENDFOR
 ENDFOR
 CALL echorecord(m_temp)
 SET ms_jason_str = concat(m_temp->s_phone,m_temp->s_patient,'], "AppointmentData":[{')
 FOR (ml_idx1 = 1 TO size(m_temp->aqual,5))
  SET ms_jason_str = concat(ms_jason_str,m_temp->aqual[ml_idx1].s_field,'"ApptNumbers":[',m_temp->
   aqual[ml_idx1].s_appt_nbr,"],",
   '"ApptDates":[',m_temp->aqual[ml_idx1].s_appt_dt,"],",'"ApptTimes":[',m_temp->aqual[ml_idx1].
   s_appt_tm,
   "],",'"ApptPractices":[',m_temp->aqual[ml_idx1].s_appt_loc,"]")
  IF (ml_idx1=size(m_temp->aqual,5))
   SET ms_jason_str = concat(ms_jason_str,"}")
  ELSE
   SET ms_jason_str = concat(ms_jason_str,"},")
  ENDIF
 ENDFOR
 SET ms_jason_str = concat(ms_jason_str,"}]}")
 CALL echo(ms_jason_str)
 SET _memory_reply_string = ms_jason_str
 CALL echo(_memory_reply_string)
#exit_script
END GO
