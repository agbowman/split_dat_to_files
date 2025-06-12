CREATE PROGRAM bhs_miis_hl7_transfer:dba
 PROMPT
  "Provider ID:" = - (1),
  "Person ID:" = - (1),
  "Locations:" = - (1),
  "x_cnt:" = 0
  WITH provnum, person_id, locations,
  x_cnt
 EXECUTE bhs_check_domain:dba
 CALL echo(build("Declaring variables from tranfer program"))
 DECLARE tline = vc WITH protect, noconstant(" ")
 DECLARE provnum = vc WITH protect, noconstant(" ")
 DECLARE locations = vc WITH protect, noconstant(" ")
 DECLARE race_cd = vc WITH protect, noconstant(" ")
 DECLARE batch_trl_cnt = i4 WITH protect, noconstant(0)
 DECLARE file_trl_cnt = i4 WITH protect, noconstant(0)
 DECLARE m_cnt = i4 WITH protect, noconstant(0)
 DECLARE m_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE p_cnt = i4 WITH protect, noconstant(0)
 DECLARE cs_pneumococcal7valentvccine = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCAL7VALENTVACCINE")), protect
 DECLARE cs_pneumococcal3valentvccine = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCAL13VALENTVACCINE")), protect
 DECLARE cs_pneumococcavaccoldterm = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCAL23VALENTVACCINE")), protect
 DECLARE cs_pneumococcalvaccoldterm = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCALVACCOLDTERM")), protect
 DECLARE cs_pneumococcapolyppv23oldterm = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCALPOLYPPV23OLDTERM")), protect
 DECLARE cs_pneumococcalvaccineoldterm = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCALVACCINEOLDTERM")), protect
 DECLARE cs_pneumovax23oldterm = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOVAX23OLDTERM")), protect
 DECLARE cs_prevnarinjoldterm = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PREVNARINJOLDTERM")
  ), protect
 DECLARE cs_prevnaroldterm = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PREVNAROLDTERM")),
 protect
 DECLARE cs_pneumoccalconjugatepcv7oldterm = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCALCONJUGATEPCV7OLDTERM")), protect
 DECLARE cs319_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE cs_primary_phone = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"PHOME"))
 DECLARE cs_primary_home = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"HOME"))
 DECLARE cs_phone_alternate = f8 WITH protect, constant(uar_get_code_by("MEANING",43,"ALTERNATE"))
 DECLARE cs_male = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,"MALE"))
 DECLARE cs_female = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",57,"FEMALE"))
 DECLARE cs_race1 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",282,
   "AMERICANINDIANORALASKANATIVE"))
 DECLARE cs_race2 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",282,
   "ASIANORPACIFICISLANDER"))
 DECLARE cs_race3 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",282,"BLACK"))
 DECLARE cs_race4 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",282,"OTHER"))
 DECLARE cs_race5 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",282,
   "PACIFICISLNATHAWAIIAN"))
 DECLARE cs_race6 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",282,"WHITE"))
 FREE RECORD work
 RECORD work(
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 pers[*]
     2 person_id = f8
     2 firstname = vc
     2 middlename = vc
     2 lastname = vc
     2 dob = vc
     2 mrn = vc
     2 sex = vc
     2 race = vc
     2 ethnic_grp = vc
     2 pat_phone = vc
     2 pat_sec_phone = vc
     2 pat_address = vc
     2 events[*]
       3 ce_id = f8
       3 ce_event_id = f8
       3 ce_encntr_id = f8
       3 ce_event_cd = f8
       3 ce_event_disp = vc
       3 ce_dt_tm = vc
       3 ce_vac_cvx_cd = vc
       3 ce_vac_cvx_name = vc
       3 ce_active_cd = vc
       3 ce_dose = vc
       3 ce_dose_unit = vc
       3 medev[*]
         4 info_src = vc
         4 info_desc = vc
         4 dose = f8
         4 dose_unit = vc
         4 lot_num = vc
         4 adm_prov_id = f8
         4 adm_prov_name = vc
         4 med_dt_tm = vc
         4 admin_note = vc
         4 vac_cd = vc
         4 vac_manfnm = vc
         4 vac_active = vc
         4 admin_status = vc
 )
 CALL echo(build("Querying encounters..."))
 SELECT INTO "nl:"
  FROM person p,
   encounter e,
   clinical_event ce,
   (dummyt d1  WITH seq = size(work->pers,5))
  PLAN (p
   WHERE (p.person_id= $PERSON_ID)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < sysdate
    AND p.end_effective_dt_tm > sysdate)
   JOIN (d1)
   JOIN (e
   WHERE e.person_id=p.person_id
    AND e.active_ind=1
    AND e.beg_effective_dt_tm < sysdate
    AND e.end_effective_dt_tm > sysdate)
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ((ce.valid_until_dt_tm+ 0) >= cnvtdatetime(curdate,curtime))
    AND  NOT (ce.result_status_cd IN (26.00, 28.00, 29.00, 30.00, 31.00))
    AND ce.event_cd IN (cs_pneumococcal7valentvccine, cs_pneumococcal3valentvccine,
   cs_pneumococcavaccoldterm, cs_pneumococcalvaccoldterm, cs_pneumococcapolyppv23oldterm,
   cs_pneumococcalvaccineoldterm, cs_pneumovax23oldterm, cs_prevnarinjoldterm,
   cs_pneumoccalconjugatepcv7oldterm, cs_prevnaroldterm))
  ORDER BY p.person_id, ce.clinical_event_id
  HEAD REPORT
   m_cnt = 0
  HEAD p.person_id
   m_cnt += 1, m_cnt2 = 0, stat = alterlist(work->pers,m_cnt),
   work->pers[m_cnt].person_id = p.person_id, work->pers[m_cnt].firstname = p.name_first, work->pers[
   m_cnt].middlename = p.name_middle,
   work->pers[m_cnt].lastname = p.name_last, work->pers[m_cnt].dob = format(cnvtdatetimeutc(
     datetimezone(p.birth_dt_tm,p.birth_tz),1),"YYYYMMDDHHMMSS;;q")
   IF (p.sex_cd=cs_male)
    work->pers[m_cnt].sex = "M"
   ELSEIF (p.sex_cd=cs_female)
    work->pers[m_cnt].sex = "F"
   ELSE
    work->pers[m_cnt].sex = "U"
   ENDIF
   IF (p.race_cd=cs_race1)
    race_cd = "1002-5"
   ELSEIF (p.race_cd=cs_race2)
    race_cd = "2028-9"
   ELSEIF (p.race_cd=cs_race3)
    race_cd = "2054-5"
   ELSEIF (p.race_cd=cs_race4)
    race_cd = "2131-1"
   ELSEIF (p.race_cd=cs_race5)
    race_cd = "2076-8"
   ELSEIF (p.race_cd=cs_race6)
    race_cd = "2106-3"
   ELSE
    race_cd = ""
   ENDIF
   work->pers[m_cnt].race = build(race_cd,"^",trim(uar_get_code_display(p.race_cd),3)), work->pers[
   m_cnt].ethnic_grp = " "
  HEAD ce.clinical_event_id
   m_cnt2 += 1, stat = alterlist(work->pers[m_cnt].events,m_cnt2), work->pers[m_cnt].events[m_cnt2].
   ce_id = ce.clinical_event_id,
   work->pers[m_cnt].events[m_cnt2].ce_event_id = ce.event_id, work->pers[m_cnt].events[m_cnt2].
   ce_encntr_id = e.encntr_id, work->pers[m_cnt].events[m_cnt2].ce_event_cd = ce.event_cd,
   work->pers[m_cnt].events[m_cnt2].ce_dt_tm = format(ce.event_end_dt_tm,"YYYYMMDDHHMMSS;;q"), work->
   pers[m_cnt].events[m_cnt2].ce_event_disp = uar_get_code_display(ce.event_cd), work->pers[m_cnt].
   events[m_cnt2].ce_dose = ce.result_val,
   work->pers[m_cnt].events[m_cnt2].ce_dose_unit = uar_get_code_display(ce.result_units_cd)
   IF (ce.event_cd IN (cs_pneumoccalconjugatepcv7oldterm, cs_pneumococcal7valentvccine,
   cs_prevnarinjoldterm, cs_prevnaroldterm))
    work->pers[m_cnt].events[m_cnt2].ce_vac_cvx_cd = "100", work->pers[m_cnt].events[m_cnt2].
    ce_vac_cvx_name = "PCV7", work->pers[m_cnt].events[m_cnt2].ce_active_cd = "Y"
   ELSEIF (ce.event_cd IN (cs_pneumococcal3valentvccine))
    work->pers[m_cnt].events[m_cnt2].ce_vac_cvx_cd = "133", work->pers[m_cnt].events[m_cnt2].
    ce_vac_cvx_name = "PCV13", work->pers[m_cnt].events[m_cnt2].ce_active_cd = "Y"
   ELSEIF (ce.event_cd IN (cs_pneumococcapolyppv23oldterm, cs_pneumovax23oldterm,
   cs_pneumococcavaccoldterm))
    work->pers[m_cnt].events[m_cnt2].ce_vac_cvx_cd = "33", work->pers[m_cnt].events[m_cnt2].
    ce_vac_cvx_name = "PPV23", work->pers[m_cnt].events[m_cnt2].ce_active_cd = "Y"
   ELSEIF (ce.event_cd IN (cs_pneumococcal3valentvccine))
    work->pers[m_cnt].events[m_cnt2].ce_vac_cvx_cd = "109", work->pers[m_cnt].events[m_cnt2].
    ce_vac_cvx_name = "Pneumococcal, unspecified formulation", work->pers[m_cnt].events[m_cnt2].
    ce_active_cd = "Y"
   ENDIF
   IF ((work->pers[m_cnt].events[m_cnt2].ce_active_cd != "Y"))
    work->pers[m_cnt].events[m_cnt2].ce_active_cd = ""
   ENDIF
  FOOT  ce.clinical_event_id
   row + 0
  FOOT  e.person_id
   row + 0
  WITH nocounter, outerjoin = d1
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(work->pers,5)),
   address a
  PLAN (d)
   JOIN (a
   WHERE (a.parent_entity_id=work->pers[d.seq].person_id)
    AND a.parent_entity_name="PERSON"
    AND a.active_ind=1
    AND a.beg_effective_dt_tm < sysdate
    AND a.end_effective_dt_tm > sysdate)
  ORDER BY a.parent_entity_id, a.beg_effective_dt_tm DESC
  HEAD a.parent_entity_id
   work->pers[d.seq].pat_address = build(trim(a.street_addr,3),"^",trim(a.street_addr2,3),"^",trim(a
     .street_addr3,3),
    "^",trim(a.state,3),"^",trim(a.zipcode,3))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(work->pers,5)),
   person p,
   encounter e,
   encntr_alias ea
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=work->pers[d.seq].person_id))
   JOIN (e
   WHERE e.person_id=p.person_id)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=cs319_mrn_cd)
  ORDER BY ea.encntr_id
  HEAD ea.encntr_id
   work->pers[d.seq].mrn = ea.alias
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(work->pers,5)),
   phone ph
  PLAN (d)
   JOIN (ph
   WHERE (ph.parent_entity_id=work->pers[d.seq].person_id)
    AND ph.parent_entity_name="PERSON"
    AND ph.active_ind=1
    AND ph.beg_effective_dt_tm < sysdate
    AND ph.end_effective_dt_tm > sysdate)
  ORDER BY ph.parent_entity_id, ph.phone_type_cd, ph.beg_effective_dt_tm DESC
  HEAD ph.parent_entity_id
   IF (ph.phone_type_cd=cs_primary_phone)
    work->pers[d.seq].pat_phone = ph.phone_num
   ELSEIF (ph.phone_type_cd=cs_primary_home)
    work->pers[d.seq].pat_phone = ph.phone_num
   ELSEIF (ph.phone_type_cd=cs_phone_alternate)
    work->pers[d.seq].pat_sec_phone = ph.phone_num
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  CALL echo("No vaccinations found....")
 ENDIF
 CALL echo("Querying med results...")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(work->pers,5)),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   ce_med_result cem,
   prsnl p
  PLAN (d
   WHERE maxrec(d2,size(work->pers[d.seq].events,5)))
   JOIN (d2
   WHERE maxrec(d3,size(work->pers[d.seq].events[d2.seq],5)))
   JOIN (cem
   WHERE (cem.event_id=work->pers[d.seq].events[d2.seq].ce_event_id)
    AND cem.valid_from_dt_tm < sysdate
    AND cem.valid_until_dt_tm > sysdate)
   JOIN (d3)
   JOIN (p
   WHERE p.person_id=cem.admin_prov_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < sysdate
    AND p.end_effective_dt_tm > sysdate)
  ORDER BY cem.admin_start_dt_tm
  HEAD cem.admin_start_dt_tm
   m_cnt = size(work->pers[d.seq].events[d2.seq].medev,5), m_cnt += 1, stat = alterlist(work->pers[d
    .seq].events[d2.seq].medev,m_cnt),
   work->pers[d.seq].events[d2.seq].medev[m_cnt].dose = cem.admin_dosage, work->pers[d.seq].events[d2
   .seq].medev[m_cnt].dose_unit = uar_get_code_display(cem.dosage_unit_cd), work->pers[d.seq].events[
   d2.seq].medev[m_cnt].med_dt_tm = format(cnvtdatetime(cem.admin_start_dt_tm),"YYYYMMDDHHMMSS;;q"),
   work->pers[d.seq].events[d2.seq].medev[m_cnt].lot_num = cem.substance_lot_number, work->pers[d.seq
   ].events[d2.seq].medev[m_cnt].adm_prov_id = cem.admin_prov_id, work->pers[d.seq].events[d2.seq].
   medev[m_cnt].adm_prov_name = p.name_full_formatted,
   work->pers[d.seq].events[d2.seq].medev[m_cnt].admin_note = cem.admin_note, work->pers[d.seq].
   events[d2.seq].medev[m_cnt].vac_cd = "UNK", work->pers[d.seq].events[d2.seq].medev[m_cnt].
   vac_manfnm = "UNKNOWN",
   work->pers[d.seq].events[d2.seq].medev[m_cnt].info_src = "01", work->pers[d.seq].events[d2.seq].
   medev[m_cnt].info_desc = "Historical Information - Source Unspecified", work->pers[d.seq].events[
   d2.seq].medev[m_cnt].vac_active = "HL70227"
   IF (cem.refusal_cd > 0)
    work->pers[d.seq].events[d2.seq].medev[m_cnt].admin_status = "RE"
   ELSE
    work->pers[d.seq].events[d2.seq].medev[m_cnt].admin_status = "CP"
   ENDIF
  WITH nocounter, outerjoin = d3
 ;end select
 IF (curqual <= 0)
  CALL echo("No med results found...")
 ENDIF
 CALL echo("Generating output file ")
 SET locations = replace( $LOCATIONS,'"'," ",0)
 SET site_cnt = x_cnt
 SELECT INTO build(site_cnt,"_","miis_hl7_transfer.dat")
  msgdttime = format(cnvtdatetime(sysdate),"YYYYMMDDHHMM;;q"), domain =
  IF (gl_bhs_prod_flag=1) "P"
  ELSE "T"
  ENDIF
  FROM (dummyt d  WITH seq = size(work->pers,5)),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1)
  PLAN (d
   WHERE maxrec(d2,size(work->pers[d.seq].events,5)))
   JOIN (d2
   WHERE maxrec(d3,size(work->pers[d.seq].events[d2.seq].medev,5)))
   JOIN (d3
   WHERE maxrec(d3,size(work->pers[d.seq].events[d2.seq].medev[d3.seq],5)))
  HEAD REPORT
   file_trl_cnt += 1, tline = build("FHS|^~\&","|",locations,"|MIIS","|99990",
    "|",msgdttime,"|||||"), row + 0,
   col 0, tline, tline = build("BHS|^~\&","|",locations,"|MIIS","|99990",
    "|",msgdttime,"|||||"),
   row + 1, col 0, tline
  DETAIL
   batch_trl_cnt += 1, tline = build("MSH|^~\&|CERNER","|12345_", $X_CNT,"|MIIS","|99990",
    "|",msgdttime,"|","|VXU^V04^VXU_V04","|",
    cnvtstring(work->pers[1].person_id),"|",domain,"|2.5.1"), row + 1,
   col 0, tline, tline = build("PID|1","|","|",work->pers[d.seq].mrn,"^^^^MR",
    "|","|",work->pers[d.seq].lastname,"^",work->pers[d.seq].firstname,
    "^^^^^L","||",work->pers[d.seq].dob,"|",work->pers[d.seq].sex,
    "||",work->pers[d.seq].race,"|",work->pers[d.seq].pat_address,"||",
    work->pers[d.seq].pat_phone," ",work->pers[d.seq].pat_sec_phone,"||||||||","|",
    work->pers[d.seq].ethnic_grp,"||||||||"),
   row + 1, col 0, tline,
   tline = build("ORC|RE|","|",evaluate(work->pers[d.seq].events[d2.seq].ce_event_id,0.0,"9999",
     cnvtstring(work->pers[d.seq].events[d2.seq].ce_event_id)),"|||||||||||||"), row + 1, col 0,
   tline
   IF (size(work->pers[d.seq].events[m_cnt2].medev,5)=0)
    tline = build("RXA|0|1|||998^No vaccine administered^CVX|999")
   ELSE
    tline = build("RXA","|0","|1","|",work->pers[d.seq].events[d2.seq].ce_dt_tm,
     "|","|",work->pers[d.seq].events[d2.seq].ce_vac_cvx_cd,"^",work->pers[d.seq].events[d2.seq].
     ce_vac_cvx_name,
     "^",work->pers[d.seq].events[d2.seq].ce_active_cd,"|",work->pers[d.seq].events[d2.seq].ce_dose,
     "|",
     work->pers[d.seq].events[d2.seq].ce_dose_unit,"|","|",work->pers[d.seq].events[d2.seq].medev[d3
     .seq].info_src,"^",
     work->pers[d.seq].events[d2.seq].medev[d3.seq].info_desc,"^HL7","|",cnvtstring(work->pers[d.seq]
      .events[d2.seq].medev[d3.seq].adm_prov_id),"^",
     work->pers[d.seq].events[d2.seq].medev[d3.seq].adm_prov_name,"||||","|",work->pers[d.seq].
     events[d2.seq].medev[d3.seq].lot_num,"||",
     work->pers[d.seq].events[d2.seq].medev[d3.seq].vac_cd,"^",work->pers[d.seq].events[d2.seq].
     medev[d3.seq].vac_manfnm,"^",work->pers[d.seq].events[d2.seq].medev[d3.seq].vac_active,
     "||","|",work->pers[d.seq].events[d2.seq].medev[d3.seq].admin_status,"|","|",
     msgdttime,"|||")
   ENDIF
   row + 1, col 0, tline
  FOOT REPORT
   tline = build("BTS|",batch_trl_cnt,"|"), row + 1, col 0,
   tline, tline = build("FTS|",file_trl_cnt,"|"), row + 1,
   col 0, tline
  WITH nocounter, outerjoin = d2, format(date,"YYYYMMDDHHMMSS;;q"),
   maxcol = 1500, formfeed = none, format = variable
 ;end select
#exit_program
 CALL echo(build2("Exiting script ",curprog))
END GO
