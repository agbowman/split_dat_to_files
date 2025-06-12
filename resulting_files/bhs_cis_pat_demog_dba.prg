CREATE PROGRAM bhs_cis_pat_demog:dba
 FREE RECORD pat_demog
 RECORD pat_demog(
   1 list[*]
     2 person_id = f8
     2 encntr_id = f8
     2 mrn = vc
     2 fin = vc
     2 first_name = vc
     2 last_name = vc
     2 address = vc
     2 city = vc
     2 state = vc
     2 zipcode = vc
     2 email = vc
     2 dob = vc
     2 deceased = vc
     2 height = vc
     2 weight = vc
     2 bmi = vc
     2 updt_dt_tm = vc
 )
 DECLARE ms_file_name = vc WITH protect, constant("20250216_20250315_cis_demog.txt")
 DECLARE stat = i4
 DECLARE cnt = i4
 DECLARE ndx = i4
 DECLARE ndx2 = i4
 DECLARE temp = vc
 SELECT INTO "NL:"
  FROM encounter e,
   encntr_alias ea,
   person p,
   person_alias pa,
   address a,
   phone ph
  PLAN (e
   WHERE e.disch_dt_tm BETWEEN cnvtdatetime("16-JAN-2025 00:00:00") AND cnvtdatetime(
    "15-MAR-2025 23:59:59")
    AND e.updt_dt_tm >= cnvtdatetime("16-FEB-2025 00:00:00"))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=1077
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=2
    AND pa.alias_pool_cd=674546.00
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate)
   JOIN (a
   WHERE a.parent_entity_name="PERSON"
    AND a.parent_entity_id=p.person_id
    AND a.address_type_cd=756.0
    AND a.active_ind=1)
   JOIN (ph
   WHERE ph.parent_entity_name="PERSON"
    AND ph.parent_entity_id=p.person_id
    AND ph.phone_type_cd=559574319.0
    AND ph.phone_type_seq=1
    AND ph.active_ind=1
    AND ph.phone_num > " ")
  ORDER BY e.encntr_id
  DETAIL
   IF (isnumeric(ea.alias) > 0
    AND isnumeric(a.state)=0)
    cnt += 1, stat = alterlist(pat_demog->list,cnt), pat_demog->list[cnt].person_id = p.person_id,
    pat_demog->list[cnt].encntr_id = e.encntr_id, pat_demog->list[cnt].mrn = trim(format(pa.alias,
      "#######;RP0"),3), pat_demog->list[cnt].fin = trim(ea.alias,3),
    pat_demog->list[cnt].first_name = trim(p.name_first,3), pat_demog->list[cnt].last_name = trim(p
     .name_last,3), pat_demog->list[cnt].address = trim(a.street_addr,3),
    pat_demog->list[cnt].city = trim(a.city,3), pat_demog->list[cnt].state = trim(a.state,3),
    pat_demog->list[cnt].zipcode = trim(a.zipcode,3),
    pat_demog->list[cnt].email = trim(ph.phone_num,3), pat_demog->list[cnt].dob = format(
     cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1),"mm/dd/yy;;d"), pat_demog->list[cnt].
    deceased = uar_get_code_display(p.deceased_cd),
    pat_demog->list[cnt].updt_dt_tm = format(e.disch_dt_tm,"YYYY-MM-DD")
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM clinical_event ce
  WHERE expand(ndx,1,cnt,ce.person_id,pat_demog->list[ndx].person_id,
   ce.encntr_id,pat_demog->list[ndx].encntr_id)
   AND ce.event_cd IN (680383.00, 734732.00, 762199.00)
  HEAD REPORT
   pos = 0
  DETAIL
   pos = locatevalsort(ndx2,1,cnt,ce.encntr_id,pat_demog->list[ndx2].encntr_id)
   IF (isnumeric(ce.result_val) > 0)
    IF (ce.event_cd=680383.00)
     pat_demog->list[pos].bmi = trim(ce.result_val,3)
    ELSEIF (ce.event_cd=734732.0)
     pat_demog->list[pos].height = trim(ce.result_val,3)
    ELSEIF (ce.event_cd=762199.0)
     pat_demog->list[pos].weight = trim(ce.result_val,3)
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO value(ms_file_name)
  FROM (dummyt d  WITH seq = value(cnt))
  HEAD REPORT
   col 0,
   "mrn|fin|first_name|last_name|address|city|state|zipcode|email|dob|deceased|height|weight|bmi|service_dt",
   row + 1
  DETAIL
   temp = concat(pat_demog->list[d.seq].mrn,"|",pat_demog->list[d.seq].fin,"|",pat_demog->list[d.seq]
    .first_name,
    "|",pat_demog->list[d.seq].last_name,"|",pat_demog->list[d.seq].address,"|",
    pat_demog->list[d.seq].city,"|",pat_demog->list[d.seq].state,"|",pat_demog->list[d.seq].zipcode,
    "|",pat_demog->list[d.seq].email,"|",pat_demog->list[d.seq].dob,"|",
    pat_demog->list[d.seq].deceased,"|",pat_demog->list[d.seq].height,"|",pat_demog->list[d.seq].
    weight,
    "|",pat_demog->list[d.seq].bmi,"|",pat_demog->list[d.seq].updt_dt_tm), col 0, temp,
   row + 1
  WITH format = variable, separator = " ", maxrow = 1,
   maxcol = 1000
 ;end select
 SET ms_dclcom = concat("mv /cerner/d_p627/ccluserdir/",ms_file_name," /cerner/d_p627/bhscust/hsrn")
 SET ml_stat = - (1)
 CALL echo(build("Remove Command2: ",ms_dclcom))
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
 FREE RECORD pat_demog
END GO
