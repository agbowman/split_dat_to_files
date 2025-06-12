CREATE PROGRAM bhs_rpt_child_pcv13:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 s_name_full_formatted = vc
     2 f_person_id = f8
     2 d_birth_dt_tm = dq8
     2 s_cmrn = vc
     2 s_pcp_name_full_formatted = vc
     2 s_addr_street = vc
     2 s_addr_city = vc
     2 s_addr_state = vc
     2 s_addr_zip = c25
     2 d_pcv7_dt_tm = dq8
     2 d_pcv13_dt_tm = dq8
 )
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE mf_pcv7_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCAL7VALENTVACCINE"))
 DECLARE mf_pcv7old_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCALCONJUGATEPCV7OLDTERM"))
 DECLARE mf_pcv13_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCAL13VALENTVACCINE"))
 DECLARE mf_person_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",302,"PERSON"))
 DECLARE mf_pcp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",331,"PCP"))
 DECLARE mn_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 SELECT INTO "nl:"
  FROM person p
  PLAN (p
   WHERE p.birth_dt_tm BETWEEN datetimeadd(sysdate,- (1826)) AND datetimeadd(sysdate,- (365))
    AND p.person_type_cd=mf_person_cd
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < sysdate
    AND p.end_effective_dt_tm > sysdate)
  HEAD REPORT
   mn_cnt = 0
  DETAIL
   mn_cnt = (mn_cnt+ 1), stat = alterlist(temp->qual,mn_cnt), temp->qual[mn_cnt].
   s_name_full_formatted = trim(p.name_full_formatted,3),
   temp->qual[mn_cnt].f_person_id = p.person_id, temp->qual[mn_cnt].d_birth_dt_tm = p.birth_dt_tm
  FOOT REPORT
   row + 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(temp->qual,5)),
   person_alias pa
  PLAN (d)
   JOIN (pa
   WHERE (pa.person_id=temp->qual[d.seq].f_person_id)
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < sysdate
    AND pa.end_effective_dt_tm > sysdate
    AND pa.person_alias_type_cd=mf_cmrn_cd)
  DETAIL
   temp->qual[d.seq].s_cmrn = trim(pa.alias,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(temp->qual,5)),
   person_prsnl_reltn ppr,
   prsnl p
  PLAN (d)
   JOIN (ppr
   WHERE (ppr.person_id=temp->qual[d.seq].f_person_id)
    AND ppr.active_ind=1
    AND ppr.beg_effective_dt_tm < sysdate
    AND ppr.end_effective_dt_tm > sysdate
    AND ppr.person_prsnl_r_cd=mf_pcp_cd)
   JOIN (p
   WHERE p.person_id=ppr.prsnl_person_id)
  DETAIL
   temp->qual[d.seq].s_pcp_name_full_formatted = trim(p.name_full_formatted,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(temp->qual,5)),
   address a
  PLAN (d)
   JOIN (a
   WHERE a.parent_entity_name="PERSON"
    AND (a.parent_entity_id=temp->qual[d.seq].f_person_id)
    AND a.active_ind=1
    AND a.beg_effective_dt_tm < sysdate
    AND a.end_effective_dt_tm > sysdate)
  DETAIL
   temp->qual[d.seq].s_addr_street = trim(a.street_addr,3)
   IF (textlen(trim(a.street_addr2,3)) > 0)
    temp->qual[d.seq].s_addr_street = concat(temp->qual[d.seq].s_addr_street,", ",trim(a.street_addr2,
      3))
   ENDIF
   IF (textlen(trim(a.street_addr3,3)) > 0)
    temp->qual[d.seq].s_addr_street = concat(temp->qual[d.seq].s_addr_street,", ",trim(a.street_addr3,
      3))
   ENDIF
   IF (textlen(trim(a.street_addr4,3)) > 0)
    temp->qual[d.seq].s_addr_street = concat(temp->qual[d.seq].s_addr_street,", ",trim(a.street_addr4,
      3))
   ENDIF
   temp->qual[d.seq].s_addr_city = trim(a.city,3), temp->qual[d.seq].s_addr_state = trim(a.state,3),
   temp->qual[d.seq].s_addr_zip = trim(a.zipcode,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(temp->qual,5)),
   clinical_event ce,
   code_value cv
  PLAN (d)
   JOIN (ce
   WHERE (ce.person_id=temp->qual[d.seq].f_person_id)
    AND ce.event_cd IN (mf_pcv7_cd, mf_pcv7old_cd, mf_pcv13_cd))
   JOIN (cv
   WHERE cv.code_value=ce.result_status_cd
    AND cv.code_set=8
    AND  NOT (cv.display_key IN ("NOTDONE", "INERROR")))
  ORDER BY ce.event_end_dt_tm
  DETAIL
   IF (ce.event_cd=mf_pcv13_cd)
    temp->qual[d.seq].d_pcv13_dt_tm = ce.event_end_dt_tm
   ELSE
    temp->qual[d.seq].d_pcv7_dt_tm = ce.event_end_dt_tm
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO value( $OUTDEV)
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   ms_line = concat("name_full_formatted,cmrn,birth_dt_tm,pcp_name_full_formatted,addr_street,",
    "addr_city,addr_state,addr_zip,pcv7_dt_tm,pcv13_dt_tm"), row 0, col 0,
   ms_line
   FOR (mn_cnt = 1 TO size(temp->qual,5))
     ms_line = build('"',temp->qual[mn_cnt].s_name_full_formatted,'"',",",'"',
      temp->qual[mn_cnt].s_cmrn,'"',",",format(temp->qual[mn_cnt].d_birth_dt_tm,
       "MM/DD/YY HH:MM:SS;;D"),",",
      '"',temp->qual[mn_cnt].s_pcp_name_full_formatted,'"',",",'"',
      temp->qual[mn_cnt].s_addr_street,'"',",",'"',temp->qual[mn_cnt].s_addr_city,
      '"',",",'"',temp->qual[mn_cnt].s_addr_state,'"',
      ",",'"',trim(temp->qual[mn_cnt].s_addr_zip,3),'"',",",
      format(temp->qual[mn_cnt].d_pcv7_dt_tm,"MM/DD/YY HH:MM:SS;;D"),",",format(temp->qual[mn_cnt].
       d_pcv13_dt_tm,"MM/DD/YY HH:MM:SS;;D")), row + 1, col 0,
     ms_line
   ENDFOR
  WITH nocounter, formfeed = none, format = variable,
   maxcol = 2000, maxrow = 1
 ;end select
END GO
