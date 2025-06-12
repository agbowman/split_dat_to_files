CREATE PROGRAM dcp_pw_summary_rpt:dba
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET location = fillstring(20," ")
 SET room = fillstring(20," ")
 SET bed = fillstring(20," ")
 SET service = fillstring(40," ")
 SET admit_doc = fillstring(30," ")
 SET attend_doc = fillstring(30," ")
 SET mrn = fillstring(20," ")
 SET pat_name = fillstring(30," ")
 SET age = fillstring(20," ")
 SET sex = fillstring(10," ")
 SET visit = fillstring(2," ")
 SET adm_date = fillstring(20," ")
 SET ycol = 0
 SET xcol = 0
 SET yyy = fillstring(40," ")
 SET xxx = fillstring(40," ")
 SET footer = fillstring(10," ")
 SET encounter_id = 0.0
 SET formnum = 1
 SET cur_date = cnvtdatetime(curdate,curtime)
 SET u_line = fillstring(92," ")
 SET page_cnt = 0
 SET cur_y = 0
 SET test_y = 0
 RECORD temp(
   1 count = i2
   1 pw[*]
     2 pw_description = vc
     2 pw_start_dt_tm = vc
     2 pw_initiated_by_name = vc
     2 tf_count = i2
     2 tf[*]
       3 tf_description = vc
       3 tf_start_dt_tm = vc
       3 tf_end_dt_tm = vc
       3 tf_initiated_by_name = vc
     2 pw_end_dt_tm = vc
     2 pw_disc_by_name = vc
     2 pw_status = vc
 )
 SET code_set = 16789
 SET cdf_meaning = "ACTIVATED"
 EXECUTE cpm_get_cd_for_cdf
 SET tf_act_status_cd = code_value
 SET code_set = 16769
 SET cdf_meaning = "STARTED"
 EXECUTE cpm_get_cd_for_cdf
 SET pw_act_status_cd = code_value
 SET code_set = 16769
 SET cdf_meaning = "COMPLETED"
 EXECUTE cpm_get_cd_for_cdf
 SET pw_comp_status_cd = code_value
 SET code_set = 16769
 SET cdf_meaning = "DISCONTINUED"
 EXECUTE cpm_get_cd_for_cdf
 SET pw_disc_status_cd = code_value
 SET code_set = 16769
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET pw_ord_status_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ADMITDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET admit_doc_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ATTENDDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET attend_doc_cd = code_value
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_cd = code_value
 SELECT INTO "nl:"
  pw.pathway_id, pw.description, pw.start_dt_tm,
  pw.actual_end_dt_tm, pw_status = uar_get_code_display(pw.pw_status_cd), pwa.pw_status_cd,
  pwa.pw_action_seq, name = trim(pr.name_full_formatted)
  FROM pathway pw,
   pathway_action pwa,
   prsnl pr,
   (dummyt d  WITH seq = value(request->pw_cnt)),
   (dummyt d1  WITH seq = 1)
  PLAN (d)
   JOIN (pw
   WHERE (pw.pathway_id=request->qual_pw[d.seq].pathway_id))
   JOIN (d1)
   JOIN (pwa
   WHERE pw.pathway_id=pwa.pathway_id)
   JOIN (pr
   WHERE pwa.action_prsnl_id=pr.person_id)
  ORDER BY pw.pathway_id, pwa.pw_status_cd DESC, pwa.pw_action_seq
  HEAD REPORT
   temp->count = 0
  HEAD pw.pathway_id
   temp->count = (temp->count+ 1), stat = alterlist(temp->pw,temp->count), temp->pw[temp->count].
   pw_description = pw.description,
   temp->pw[temp->count].pw_status = pw_status
   IF ( NOT (pw.pw_status_cd=pw_disc_status_cd)
    AND  NOT (pw.pw_status_cd=pw_comp_status_cd))
    temp->pw[temp->count].pw_end_dt_tm = " "
   ELSE
    temp->pw[temp->count].pw_end_dt_tm = concat(trim(format(pw.actual_end_dt_tm,"@SHORTDATE;;Q"))," ",
     trim(format(pw.actual_end_dt_tm,"HH:MM;;S")))
   ENDIF
  HEAD pwa.pw_status_cd
   IF (pwa.pw_status_cd=pw_act_status_cd)
    temp->pw[temp->count].pw_start_dt_tm = concat(trim(format(pwa.action_dt_tm,"@SHORTDATE;;Q"))," ",
     trim(format(pwa.action_dt_tm,"HH:MM;;S"))), temp->pw[temp->count].pw_initiated_by_name = name
   ELSEIF (((pwa.pw_status_cd=pw_disc_status_cd) OR (pwa.pw_status_cd=pw_comp_status_cd)) )
    temp->pw[temp->count].pw_disc_by_name = name
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 SELECT INTO "nl:"
  pw.pathway_id, atf.act_time_frame_id, atf.description,
  atf.start_ind, tm_start = concat(trim(format(atf.calc_start_dt_tm,"@SHORTDATE;;Q"))," ",trim(format
    (atf.calc_start_dt_tm,"HH:MM;;S"))), tm_end = concat(trim(format(atf.calc_end_dt_tm,
     "@SHORTDATE;;Q"))," ",trim(format(atf.calc_end_dt_tm,"HH:MM;;S"))),
  apc.activated_ind, tm_active = concat(trim(format(apc.activated_dt_tm,"@SHORTDATE;;Q"))," ",trim(
    format(apc.activated_dt_tm,"HH:MM;;S"))), name = trim(pr.name_full_formatted)
  FROM pathway pw,
   act_time_frame atf,
   act_pw_comp apc,
   prsnl pr,
   (dummyt d2  WITH seq = value(request->pw_cnt)),
   (dummyt d3  WITH seq = 1)
  PLAN (d2)
   JOIN (pw
   WHERE (pw.pathway_id=request->qual_pw[d2.seq].pathway_id))
   JOIN (d3)
   JOIN (atf
   WHERE pw.pathway_id=atf.pathway_id)
   JOIN (apc
   WHERE atf.act_time_frame_id=apc.act_time_frame_id)
   JOIN (pr
   WHERE apc.activated_prsnl_id=pr.person_id)
  ORDER BY pw.pathway_id, atf.sequence, apc.activated_ind DESC,
   apc.activated_dt_tm
  HEAD REPORT
   temp->count = 0
  HEAD pw.pathway_id
   temp->count = (temp->count+ 1), temp->pw[temp->count].tf_count = 0
  HEAD atf.sequence
   temp->pw[temp->count].tf_count = (temp->pw[temp->count].tf_count+ 1), stat = alterlist(temp->pw[
    temp->count].tf,temp->pw[temp->count].tf_count), temp->pw[temp->count].tf[temp->pw[temp->count].
   tf_count].tf_description = trim(atf.description)
   IF (apc.activated_ind)
    temp->pw[temp->count].tf[temp->pw[temp->count].tf_count].tf_start_dt_tm = tm_start, temp->pw[temp
    ->count].tf[temp->pw[temp->count].tf_count].tf_end_dt_tm = tm_end, temp->pw[temp->count].tf[temp
    ->pw[temp->count].tf_count].tf_initiated_by_name = name
   ELSE
    temp->pw[temp->count].tf[temp->pw[temp->count].tf_count].tf_start_dt_tm = " ", temp->pw[temp->
    count].tf[temp->pw[temp->count].tf_count].tf_end_dt_tm = " ", temp->pw[temp->count].tf[temp->pw[
    temp->count].tf_count].tf_initiated_by_name = " "
   ENDIF
  WITH nocounter, outerjoin = d3
 ;end select
 SELECT INTO "nl:"
  pw.pathway_id, apc.act_pw_comp_id, apc.encntr_id
  FROM pathway pw,
   act_pw_comp apc,
   (dummyt d4  WITH seq = value(request->pw_cnt))
  PLAN (d4)
   JOIN (pw
   WHERE (pw.pathway_id=request->qual_pw[d4.seq].pathway_id)
    AND pw.pw_status_cd != pw_ord_status_cd)
   JOIN (apc
   WHERE pw.pathway_id=apc.pathway_id
    AND apc.encntr_id > 0)
  ORDER BY pw.pathway_id, apc.act_pw_comp_id
  HEAD REPORT
   encounter_id = apc.encntr_id
  WITH maxqual(apc,1)
 ;end select
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   person_alias pa,
   prsnl pr,
   encntr_prsnl_reltn epr,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1)
  PLAN (p
   WHERE (p.person_id=request->person_id))
   JOIN (e
   WHERE p.person_id=e.person_id
    AND e.encntr_id=encounter_id)
   JOIN (d1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mrn_alias_cd
    AND pa.active_ind=1
    AND pa.alias != null)
   JOIN (d2)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd IN (admit_doc_cd, attend_doc_cd)
    AND epr.active_ind=1
    AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null)) )
   JOIN (pr
   WHERE pr.person_id=epr.prsnl_person_id)
  HEAD REPORT
   adm_date = format(e.reg_dt_tm,"@SHORTDATE;;Q"), location = substring(1,20,uar_get_code_display(e
     .loc_nurse_unit_cd)), room = substring(1,20,uar_get_code_display(e.loc_room_cd)),
   bed = substring(1,20,uar_get_code_display(e.loc_bed_cd)), service = substring(1,40,
    uar_get_code_display(e.med_service_cd)), pat_name = substring(1,30,p.name_full_formatted),
   age = trim(cnvtage(cnvtdate(p.birth_dt_tm),curdate)), sex = substring(1,10,uar_get_code_display(p
     .sex_cd))
  HEAD epr.encntr_prsnl_r_cd
   IF (epr.encntr_prsnl_r_cd=admit_doc_cd)
    admit_doc = substring(1,30,pr.name_full_formatted)
   ELSEIF (epr.encntr_prsnl_r_cd=attend_doc_cd)
    attend_doc = substring(1,30,pr.name_full_formatted)
   ENDIF
  DETAIL
   IF (pa.person_alias_type_cd=mrn_alias_cd)
    IF (pa.alias_pool_cd > 0)
     mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
    ELSE
     mrn = pa.alias
    ENDIF
   ENDIF
   visit = trim(cnvtstring(pa.visit_seq_nbr))
  WITH nocounter, outerjoin = d1, dontcare = pa,
   outerjoin = d2, dontcare = epr
 ;end select
 SELECT INTO value(request->output_device)
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   "{f/8}", "{cpi/12}", "{ipc}"
  HEAD PAGE
   "{b}{pos/250/48}Plan of Care Summary{endb}", row + 1,
   "{b}{pos/50/72}____________________________________________________________________________________________{endb}",
   row + 1, "{pos/51/84}Patient Name{pos/139/84}:  ", pat_name,
   "{pos/340/84}Age{pos/397/84}: ", age, row + 1,
   "{pos/51/96}MRN{pos/139/96}:  ", mrn, "{pos/340/96}Gender{pos/397/96}:  ",
   sex, row + 1, "{pos/51/108}Admission Date{pos/139/108}:  ",
   adm_date, "{pos/340/108}Location{pos/397/108}:  ", location,
   row + 1, "{pos/51/120}Admitting Physician{pos/139/120}:  ", admit_doc
   IF (trim(bed) != " "
    AND trim(room) != " ")
    yyy = concat(trim(room)," ; ",trim(bed)), "{pos/340/120}Room & Bed{pos/397/120}:  ", yyy,
    row + 1
   ELSE
    "{pos/340/120}Room & Bed{pos/397/120}:  ", row + 1
   ENDIF
   "{pos/51/132}Attending Physician{pos/139/132}:  ", attend_doc,
   "{pos/340/132}Service{pos/397/132}:  ",
   service, row + 1, "{pos/51/144}Visit Number{pos/139/144}:  ",
   visit, row + 1,
   "{b}{pos/50/147}____________________________________________________________________________________________{endb}",
   row + 1
  DETAIL
   FOR (i = 1 TO temp->count)
     IF (i=1)
      x = 51, y = 180, test_y = y
     ENDIF
     CALL print(calcpos(x,y)), "Description: ", temp->pw[i].pw_description,
     row + 2, y = (y+ 24),
     CALL print(calcpos(x,y)),
     "Status: ", temp->pw[i].pw_status, row + 2,
     y = (y+ 24),
     CALL print(calcpos(x,y)), "Date/Time Started: ",
     temp->pw[i].pw_start_dt_tm, row + 2, y = (y+ 24),
     CALL print(calcpos(x,y)), "Initiated By: ", temp->pw[i].pw_initiated_by_name,
     row + 2, y1 = (y+ 24), x1 = 51,
     x2 = 190, x3 = 350, x4 = 500,
     CALL print(calcpos(x1,y1)), "{u}{b}Time Frame{endu}",
     CALL print(calcpos(x2,y1)),
     "{u}Start Date/Time{endu}",
     CALL print(calcpos(x3,y1)), "{u}Stop Date/Time{endu}",
     CALL print(calcpos(x4,y1)), "{u}Initiated By{endu}", row + 1
     FOR (j = 1 TO temp->pw[i].tf_count)
       IF (((y1+ 12) > 700))
        BREAK, y1 = (test_y - 24)
       ENDIF
       y1 = (y1+ 12),
       CALL print(calcpos(x1,y1)), temp->pw[i].tf[j].tf_description,
       CALL print(calcpos(x2,y1)), temp->pw[i].tf[j].tf_start_dt_tm,
       CALL print(calcpos(x3,y1)),
       temp->pw[i].tf[j].tf_end_dt_tm,
       CALL print(calcpos(x4,y1)), temp->pw[i].tf[j].tf_initiated_by_name,
       row + 1
     ENDFOR
     IF (((y1+ 48) > 700))
      BREAK, y1 = test_y
     ENDIF
     y = (y1+ 24),
     CALL print(calcpos(x,y)), "Date/Time Stopped: ",
     temp->pw[i].pw_end_dt_tm, row + 2, y = (y+ 24),
     CALL print(calcpos(x,y)), "Discontinued By: ", temp->pw[i].pw_disc_by_name,
     row + 2, cur_y = mod(y,700)
     IF ((i != temp->count))
      IF ((((cur_y+ 204)+ (temp->pw[(i+ 1)].tf_count * 12)) > 716))
       BREAK, y = test_y
      ELSE
       y = (y+ 48)
      ENDIF
     ENDIF
   ENDFOR
  FOOT PAGE
   mrn_foot = concat("MR Form # ",cnvtstring(formnum)), footer = concat("Page ",cnvtstring(curpage)),
   "{pos/51/740}",
   mrn_foot, "{pos/270/740}", footer,
   "{pos/490/740}", cur_date"mm/dd/yy hh:mm;;d", row + 1
  WITH nocounter, dio = postscript, maxcol = 792,
   maxrow = 600
 ;end select
END GO
