CREATE PROGRAM bhs_rpt_hna_phone_email:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD m_rec
 RECORD m_rec(
   1 hna[*]
     2 f_person_id = f8
     2 s_username = vc
     2 s_name_full = vc
     2 s_bus_phone = vc
     2 s_bus_phone_frmt = vc
     2 s_bus_fax = vc
     2 s_bus_fax_frmt = vc
     2 s_extsecemail = vc
 ) WITH protect
 DECLARE mf_bus_phone_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",43,"BUSINESS"))
 DECLARE mf_bus_fax_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",43,"FAXBUSINESS"))
 DECLARE mf_extsecemail_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",43,
   "EXTERNALSECURE"))
 SELECT INTO "nl:"
  FROM prsnl pr,
   person_name pn,
   phone ph
  PLAN (pr
   WHERE pr.active_ind=1
    AND pr.end_effective_dt_tm > sysdate)
   JOIN (pn
   WHERE pn.person_id=pr.person_id
    AND pn.active_ind=1
    AND pn.end_effective_dt_tm > sysdate)
   JOIN (ph
   WHERE ph.parent_entity_id=pr.person_id
    AND ph.parent_entity_name="PERSON"
    AND ph.phone_type_cd IN (mf_bus_phone_cd, mf_bus_fax_cd, mf_extsecemail_cd)
    AND ph.active_ind=1
    AND ph.end_effective_dt_tm > sysdate
    AND ph.phone_type_seq=1)
  ORDER BY pr.name_last_key, pr.person_id
  HEAD REPORT
   pl_cnt = 0
  HEAD pr.name_last_key
   null
  HEAD pr.person_id
   pl_cnt = (pl_cnt+ 1),
   CALL alterlist(m_rec->hna,(pl_cnt+ 10)), m_rec->hna[pl_cnt].f_person_id = pr.person_id,
   m_rec->hna[pl_cnt].s_name_full = concat(trim(pn.name_last,3)," ",trim(pn.name_suffix,3),", ",trim(
     pn.name_first,3)), m_rec->hna[pl_cnt].s_username = trim(pr.username,3)
  HEAD ph.phone_type_cd
   IF (ph.phone_type_cd=mf_bus_phone_cd)
    m_rec->hna[pl_cnt].s_bus_phone = trim(ph.phone_num_key,3), m_rec->hna[pl_cnt].s_bus_phone_frmt =
    format(trim(ph.phone_num_key,3),"#-###-###-####;P*")
   ELSEIF (ph.phone_type_cd=mf_bus_fax_cd)
    m_rec->hna[pl_cnt].s_bus_fax = trim(ph.phone_num_key,3), m_rec->hna[pl_cnt].s_bus_fax_frmt =
    format(trim(ph.phone_num_key,3),"#-###-###-####;P*")
   ELSEIF (ph.phone_type_cd=mf_extsecemail_cd)
    m_rec->hna[pl_cnt].s_extsecemail = trim(ph.phone_num,3)
   ENDIF
  FOOT  pr.person_id
   CALL alterlist(m_rec->hna,pl_cnt)
  WITH nocounter
 ;end select
 SELECT INTO value( $OUTDEV)
  person_id = m_rec->hna[d.seq].f_person_id, person_name = substring(1,100,m_rec->hna[d.seq].
   s_name_full), username = m_rec->hna[d.seq].s_username,
  bus_phone_key = m_rec->hna[d.seq].s_bus_phone, bus_phone_formatted = m_rec->hna[d.seq].
  s_bus_phone_frmt, bus_fax_key = m_rec->hna[d.seq].s_bus_fax,
  bus_fax_formatted = m_rec->hna[d.seq].s_bus_fax_frmt, external_secure_email = substring(1,100,m_rec
   ->hna[d.seq].s_extsecemail)
  FROM (dummyt d  WITH seq = value(size(m_rec->hna,5)))
  ORDER BY d.seq
  WITH nocounter, format, separator = " ",
   maxrow = 1, maxcol = 500
 ;end select
#exit_script
END GO
