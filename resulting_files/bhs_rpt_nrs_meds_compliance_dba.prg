CREATE PROGRAM bhs_rpt_nrs_meds_compliance:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Organization" = 0,
  "Select Nursing Unit /s" = 0
  WITH outdev, org, nur
 DECLARE dischargemed_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",30254,"DISCHARGEMED")),
 protect
 DECLARE durablemedicalequipment_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",30254,
   "DURABLEMEDICALEQUIPMENT")), protect
 DECLARE pharmacy_var = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY")), protect
 DECLARE suspended_var = f8 WITH constant(uar_get_code_by("MEANING",6004,"SUSPENDED")), protect
 DECLARE ordered_var = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED")), protect
 DECLARE all_unit_per_done24 = f8 WITH protect
 DECLARE allunit24hr = f8 WITH noconstant(0), protect
 DECLARE comp_24 = f8 WITH noconstant(0), protect
 DECLARE cnt_24hr = f8 WITH noconstant(0), protect
 DECLARE cnt_doc_invest = i4 WITH protect
 DECLARE cnt_doc_unable = i4 WITH protect
 DECLARE avg_wait_time = f8 WITH noconstant(0), protect
 DECLARE all_unit_avg_wait = f8 WITH noconstant(0), protect
 DECLARE all_unit_wait = f8 WITH noconstant(0), protect
 DECLARE all_units_avg_time = f8 WITH noconstant(0), protect
 DECLARE all_units_comp_avg = f8 WITH noconstant(0), protect
 DECLARE all_unit_pat = f8 WITH noconstant(0), protect
 DECLARE all_unit_time = f8 WITH noconstant(0), protect
 DECLARE total_comp_pat = f8 WITH noconstant(0), protect
 DECLARE total_wait_unit = f8 WITH noconstant(0), protect
 DECLARE comp_avg = f8 WITH noconstant(0), protect
 DECLARE patient_count = f8 WITH noconstant(0), protect
 DECLARE comp_avg_time = f8 WITH protect
 DECLARE total_unit_time = f8 WITH protect
 DECLARE count_comp = f8 WITH protect
 DECLARE time_complete = f8 WITH protect
 DECLARE y_end_of_page = f8 WITH protect
 DECLARE percent_done = f8 WITH noconstant(0), protect
 DECLARE tmp_work_room = f8 WITH noconstant(0), protect
 DECLARE p_prt = i4 WITH noconstant(0), public
 DECLARE n_prt = i4 WITH noconstant(0), public
 DECLARE temp3 = f8 WITH protect
 DECLARE temp2 = f8 WITH protect
 DECLARE temp1 = f8 WITH protect
 DECLARE emergency_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY")), protect
 DECLARE daystay_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY")), protect
 DECLARE inpatient_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT")), protect
 DECLARE observation_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")), protect
 DECLARE giveninphysicianoffice_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",30254,
   "GIVENINPHYSICIANOFFICE")), protect
 DECLARE unabletoobtain_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",30254,"UNABLETOOBTAIN")),
 protect
 DECLARE stilltakingnotasprescribed_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",30254,
   "STILLTAKINGNOTASPRESCRIBED")), protect
 DECLARE stilltakingasprescribed_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",30254,
   "STILLTAKINGASPRESCRIBED")), protect
 DECLARE nottaking_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",30254,"NOTTAKING")), protect
 DECLARE investigating_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",30254,"INVESTIGATING")),
 protect
 DECLARE becont = i4 WITH noconstant(0), protect
 FREE RECORD meds_compliance
 RECORD meds_compliance(
   1 nurse_unit[*]
     2 nurse_unit_name = vc
     2 unit_pat[*]
       3 encounter = f8
       3 patient_name = vc
       3 person_id = f8
       3 attend_dr = vc
       3 loc = vc
       3 admit_dt = vc
       3 admit_dttm = dq8
       3 admit_loc = vc
       3 admit_loc_dt = dq8
       3 admit_loc_date = vc
       3 comp_dttm = dq8
       3 comp_loc = vc
       3 fin = vc
       3 mrn = vc
       3 loc_dt = vc
       3 unable_to_obain = i4
       3 unknown = i4
       3 comp_percent_done = f8
       3 doc_ui = vc
       3 complete = c1
       3 complete24 = c1
       3 time_complete = f8
       3 num_in24hrs = f8
       3 num_doc_meds = f8
       3 num_comp_meds = f8
       3 compliance_dttm = dq8
       3 admit_to_comp = f8
       3 doc_meds[*]
         4 order_id = f8
         4 comp_status_cd = f8
         4 comp_stat_view = vc
 )
 SET mrn_cd = uar_get_code_by("DISPLAYKEY",319,"MRN")
 SET fnbr_cd = uar_get_code_by("DISPLAYKEY",319,"FINNBR")
 SET attend_cd = uar_get_code_by("DISPLAYKEY",333,"ATTENDINGPHYSICIAN")
 SET activity_cd = uar_get_code_by("DISPLAYKEY",106,"RNTORN")
 SET catalog_cd = uar_get_code_by("DISPLAYKEY",200,"COMPLETEMEDRECONCILIATIONADMIT")
 SET catalog_type_cd = uar_get_code_by("DISPLAYKEY",6000,"PATIENTCARE")
 SET status_cd = uar_get_code_by("DISPLAYKEY",6004,"COMPLETED")
 SET status_cd2 = uar_get_code_by("DISPLAYKEY",6004,"ORDERED")
 SET daystay_cd = uar_get_code_by("DISPLAYKEY",71,"DAYSTAY")
 SET inpat_cd = uar_get_code_by("DISPLAYKEY",71,"INPATIENT")
 SET observation_cd = uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")
 SET auth_ver_cd = uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED")
 SET home_med_recon_cd = uar_get_code_by("DISPLAYKEY",72,"HOMEMEDICATIONREVIEW")
 SET complete_cd = uar_get_code_by("DISPLAYKEY",6004,"COMPLETED")
 SET perform_cd = uar_get_code_by("DISPLAYKEY",21,"PERFORM")
 DECLARE unknown_ind = vc
 DECLARE obtain_ind = vc
 SET org_name = fillstring(40," ")
 SELECT INTO "nl:"
  l.location_cd, org.org_name, l.organization_id,
  org.organization_id
  FROM location l,
   organization org
  PLAN (l
   WHERE (l.location_cd= $ORG))
   JOIN (org
   WHERE org.organization_id=l.organization_id)
  DETAIL
   org_name = trim(org.org_name)
  WITH nocounter
 ;end select
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT DISTINCT INTO "nl:"
  fin = cnvtalias(ea.alias,ea.alias_pool_cd), nurse_unit = trim(uar_get_code_display(e
    .loc_nurse_unit_cd)), pat_name = trim(p.name_full_formatted,3),
  pat_name_id = concat(trim(p.name_full_formatted,3),trim(cnvtstring(cnvtint(p.person_id)),3)),
  admit_dt = format(e.reg_dt_tm,"mm/dd/yy hh:mm;;d"), mrn = cnvtalias(ea1.alias,ea1.alias_pool_cd),
  attend_dr = trim(p1.name_full_formatted), loc_dt2 = e.reg_dt_tm"mm/dd/yy hh:mm;;d", loc_dt = ed
  .updt_dt_tm"mm/dd/yy hh:mm;;d"
  FROM encntr_domain ed,
   encounter e,
   encntr_alias ea,
   encntr_alias ea1,
   person p,
   encntr_prsnl_reltn ep,
   person p1
  PLAN (ed
   WHERE (ed.loc_nurse_unit_cd= $NUR)
    AND ed.end_effective_dt_tm=cnvtdatetime(cnvtdate(12312100),0000)
    AND ed.loc_building_cd > 0
    AND ((ed.loc_facility_cd+ 0)= $ORG))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND (e.loc_nurse_unit_cd= $NUR)
    AND e.encntr_type_cd IN (daystay_var, inpatient_var, observation_var, emergency_var, 854))
   JOIN (ea
   WHERE ea.encntr_id=ed.encntr_id
    AND ((ea.encntr_alias_type_cd+ 0)=fnbr_cd))
   JOIN (ea1
   WHERE ea1.encntr_id=ed.encntr_id
    AND ((ea1.encntr_alias_type_cd+ 0)=mrn_cd))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (ep
   WHERE ep.encntr_id=ed.encntr_id
    AND ((ep.active_ind+ 0)=1)
    AND ((ep.encntr_prsnl_r_cd+ 0)=attend_cd)
    AND ((ep.expiration_ind+ 0)=0)
    AND ((ep.end_effective_dt_tm+ 0)=cnvtdatetime(cnvtdate(12312100),0000)))
   JOIN (p1
   WHERE p1.person_id=ep.prsnl_person_id)
  ORDER BY nurse_unit, pat_name_id
  HEAD REPORT
   cnt_unit = 0, stat = alterlist(meds_compliance->nurse_unit,100)
  HEAD nurse_unit
   cnt_unit = (cnt_unit+ 1)
   IF (mod(cnt_unit,10)=1
    AND cnt_unit > 100)
    stat = alterlist(meds_compliance->nurse_unit,(9+ cnt_unit))
   ENDIF
   meds_compliance->nurse_unit[cnt_unit].nurse_unit_name = nurse_unit, cnt_pat = 0, stat = alterlist(
    meds_compliance->nurse_unit[cnt_unit].unit_pat,100)
  DETAIL
   cnt_pat = (cnt_pat+ 1)
   IF (mod(cnt_pat,10)=1
    AND cnt_pat > 100)
    stat = alterlist(meds_compliance->nurse_unit[cnt_unit].unit_pat,(9+ cnt_pat))
   ENDIF
   meds_compliance->nurse_unit[cnt_unit].unit_pat[cnt_pat].encounter = e.encntr_id, meds_compliance->
   nurse_unit[cnt_unit].unit_pat[cnt_pat].person_id = e.person_id, meds_compliance->nurse_unit[
   cnt_unit].unit_pat[cnt_pat].fin = fin,
   meds_compliance->nurse_unit[cnt_unit].unit_pat[cnt_pat].mrn = mrn, meds_compliance->nurse_unit[
   cnt_unit].unit_pat[cnt_pat].loc = nurse_unit, meds_compliance->nurse_unit[cnt_unit].unit_pat[
   cnt_pat].attend_dr = attend_dr,
   meds_compliance->nurse_unit[cnt_unit].unit_pat[cnt_pat].admit_dt = admit_dt, meds_compliance->
   nurse_unit[cnt_unit].unit_pat[cnt_pat].admit_dttm = e.reg_dt_tm, meds_compliance->nurse_unit[
   cnt_unit].unit_pat[cnt_pat].attend_dr = attend_dr,
   meds_compliance->nurse_unit[cnt_unit].unit_pat[cnt_pat].patient_name = pat_name, meds_compliance->
   nurse_unit[cnt_unit].unit_pat[cnt_pat].complete = "N", meds_compliance->nurse_unit[cnt_unit].
   unit_pat[cnt_pat].comp_dttm = cnvtdatetime(curdate,curtime3),
   meds_compliance->nurse_unit[cnt_unit].unit_pat[cnt_pat].complete24 = "N", time_complete =
   datetimediff(cnvtdatetime(meds_compliance->nurse_unit[cnt_unit].unit_pat[cnt_pat].comp_dttm),
    meds_compliance->nurse_unit[cnt_unit].unit_pat[cnt_pat].admit_dttm,3), meds_compliance->
   nurse_unit[cnt_unit].unit_pat[cnt_pat].doc_ui = trim("$")
   IF (time_complete < 0)
    time_complete = 0
   ENDIF
   meds_compliance->nurse_unit[cnt_unit].unit_pat[cnt_pat].time_complete = round(time_complete,1)
  FOOT  nurse_unit
   stat = alterlist(meds_compliance->nurse_unit[cnt_unit].unit_pat,cnt_pat)
  FOOT REPORT
   stat = alterlist(meds_compliance->nurse_unit,cnt_unit)
  WITH nocounter, separator = " ", format,
   outerjoin = d1
 ;end select
 SELECT
  unit_pat_admit_loc = substring(1,30,meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].admit_loc),
  admit_locdt = format(elh.beg_effective_dt_tm,"mm/dd/yy hh:mm;;d")
  FROM (dummyt d1  WITH seq = value(size(meds_compliance->nurse_unit,5))),
   (dummyt d2  WITH seq = 1),
   encntr_loc_hist elh
  PLAN (d1
   WHERE maxrec(d2,size(meds_compliance->nurse_unit[d1.seq].unit_pat,5)))
   JOIN (d2)
   JOIN (elh
   WHERE (elh.encntr_id=meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].encounter)
    AND ((elh.encntr_type_cd+ 0) IN (daystay_var, inpatient_var, observation_var, emergency_var, 854)
   ))
  ORDER BY elh.encntr_id, elh.beg_effective_dt_tm
  HEAD elh.encntr_id
   meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].admit_loc = trim(uar_get_code_display(elh
     .loc_nurse_unit_cd)), meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].admit_loc_date =
   admit_locdt
  FOOT REPORT
   null
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(meds_compliance->nurse_unit,5))),
   (dummyt d2  WITH seq = 1),
   orders o,
   encounter e
  PLAN (d1
   WHERE maxrec(d2,size(meds_compliance->nurse_unit[d1.seq].unit_pat,5)))
   JOIN (d2)
   JOIN (e
   WHERE (e.encntr_id=meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].encounter))
   JOIN (o
   WHERE (o.person_id=meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].person_id)
    AND o.orig_ord_as_flag IN (1, 2, 3)
    AND ((o.order_status_cd+ 0) IN (ordered_var, suspended_var))
    AND o.catalog_type_cd=pharmacy_var
    AND o.template_order_flag <= 1)
  ORDER BY e.encntr_id, o.order_id
  HEAD REPORT
   null
  HEAD e.encntr_id
   cnt_meds = 0, stat = alterlist(meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].doc_meds,100)
  DETAIL
   cnt_meds = (cnt_meds+ 1)
   IF (mod(cnt_meds,10)=1
    AND cnt_meds > 100)
    stat = alterlist(meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].doc_meds,(cnt_meds+ 9))
   ENDIF
   meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].doc_meds[cnt_meds].order_id = o.order_id
  FOOT  e.encntr_id
   stat = alterlist(meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].doc_meds,cnt_meds),
   meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].num_doc_meds = cnt_meds, cnt_meds = 0
  WITH nocounter, separator = " ", format
 ;end select
 SELECT INTO "nl:"
  perform_dttm = format(o.performed_dt_tm,";;q")
  FROM (dummyt d1  WITH seq = value(size(meds_compliance->nurse_unit,5))),
   (dummyt d2  WITH seq = 1),
   order_compliance o
  PLAN (d1
   WHERE maxrec(d2,size(meds_compliance->nurse_unit[d1.seq].unit_pat,5)))
   JOIN (d2)
   JOIN (o
   WHERE (o.encntr_id=meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].encounter))
  ORDER BY o.encntr_id, o.performed_dt_tm DESC
  HEAD REPORT
   cnt_comp = 0
  HEAD o.encntr_id
   null
   IF (((o.no_known_home_meds_ind=1) OR (o.unable_to_obtain_ind=1)) )
    meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].unknown = o.no_known_home_meds_ind,
    meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].unable_to_obain = o.unable_to_obtain_ind,
    meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].comp_dttm = o.performed_dt_tm,
    meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].num_doc_meds = 1, cnt_comp = (cnt_comp+ 1)
   ENDIF
  FOOT  o.encntr_id
   meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].num_comp_meds = cnvtreal(cnt_comp),
   meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].comp_percent_done = round(((cnvtreal(cnt_comp
     )/ cnvtreal(meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].num_doc_meds)) * 100),0)
   IF ((meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].comp_percent_done=100))
    meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].complete = "Y", meds_compliance->nurse_unit[
    d1.seq].unit_pat[d2.seq].comp_dttm = o.performed_dt_tm, time_complete = datetimediff(cnvtdatetime
     (meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].comp_dttm),meds_compliance->nurse_unit[d1
     .seq].unit_pat[d2.seq].admit_dttm,3)
    IF (time_complete < 0)
     time_complete = 0
    ENDIF
    meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].time_complete = round(time_complete,1)
    IF (time_complete <= 24
     AND (meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].complete="Y"))
     meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].complete24 = "Y"
    ELSE
     meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].complete24 = "N"
    ENDIF
   ENDIF
   cnt_comp = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  order_num =
  IF (oc.order_nbr != 0.0) oc.order_nbr
  ELSE 0
  ENDIF
  , oc_compliance_status_disp = uar_get_code_display(oc.compliance_status_cd), perform_dttm = format(
   o.performed_dt_tm,";;q")
  FROM (dummyt d1  WITH seq = value(size(meds_compliance->nurse_unit,5))),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   order_compliance o,
   order_compliance_detail oc
  PLAN (d1
   WHERE maxrec(d2,size(meds_compliance->nurse_unit[d1.seq].unit_pat,5)))
   JOIN (d2
   WHERE maxrec(d3,size(meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].doc_meds,5)))
   JOIN (d3)
   JOIN (o
   WHERE outerjoin(meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].encounter)=o.encntr_id)
   JOIN (oc
   WHERE outerjoin(o.order_compliance_id)=oc.order_compliance_id
    AND outerjoin(meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].doc_meds[d3.seq].order_id)=oc
   .order_nbr)
  ORDER BY o.encntr_id, order_num, o.performed_dt_tm DESC,
   oc.compliance_capture_dt_tm DESC
  HEAD REPORT
   null, cnt_comp = 0, cnt_doc_unable = 0,
   cnt_doc_invest = 0
  HEAD o.encntr_id
   null
  HEAD order_num
   IF (oc.compliance_status_cd IN (giveninphysicianoffice_var, stilltakingnotasprescribed_var,
   stilltakingasprescribed_var, nottaking_var, unabletoobtain_var,
   investigating_var, dischargemed_var, durablemedicalequipment_var)
    AND (meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].doc_meds[d3.seq].order_id=oc.order_nbr)
   )
    cnt_comp = (cnt_comp+ 1), meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].doc_meds[d3.seq].
    comp_status_cd = oc.compliance_status_cd, meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].
    doc_meds[d3.seq].comp_stat_view = uar_get_code_display(oc.compliance_status_cd)
    IF (oc.compliance_status_cd=investigating_var
     AND cnt_doc_invest=0)
     cnt_doc_invest = 1,
     CALL echo(build("textelen = ",textlen(meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].
       doc_ui)))
     IF ((meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].doc_ui="$"))
      meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].doc_ui = trim("I",3),
      CALL echo(build("doc_ui i1 = ",meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].doc_ui))
     ELSE
      CALL echo(build("doc_ui i1 = ",meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].doc_ui)),
      meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].doc_ui = trim(concat(meds_compliance->
        nurse_unit[d1.seq].unit_pat[d2.seq].doc_ui,",I"),3)
     ENDIF
    ENDIF
    CALL echo(build("cnt_doc_unable 1 = ",cnt_doc_unable))
    IF (oc.compliance_status_cd=unabletoobtain_var
     AND cnt_doc_unable=0)
     cnt_doc_unable = 1,
     CALL echo(build("cnt_doc_unable 2 = ",cnt_doc_unable))
     IF ((meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].doc_ui="$"))
      meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].doc_ui = trim("U",3)
     ELSE
      meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].doc_ui = trim(concat(meds_compliance->
        nurse_unit[d1.seq].unit_pat[d2.seq].doc_ui,trim(",U",3)),3)
     ENDIF
    ENDIF
    IF (((cnt_comp=1) OR ((meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].comp_dttm < o
    .performed_dt_tm))) )
     meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].comp_dttm = o.performed_dt_tm,
     time_complete = datetimediff(cnvtdatetime(meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].
       comp_dttm),meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].admit_dttm,3)
     IF (time_complete < 0)
      time_complete = 0
     ENDIF
    ENDIF
   ENDIF
  FOOT  o.encntr_id
   cnt_doc_unable = 0, cnt_doc_invest = 0, meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].
   complete = "N",
   meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].num_comp_meds = cnt_comp, meds_compliance->
   nurse_unit[d1.seq].unit_pat[d2.seq].comp_percent_done = round(((cnvtreal(cnt_comp)/ cnvtreal(
     meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].num_doc_meds)) * 100),0)
   IF ((meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].comp_percent_done=100))
    meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].complete = "Y", meds_compliance->nurse_unit[
    d1.seq].unit_pat[d2.seq].time_complete = round(time_complete,1)
    IF (time_complete <= 24
     AND (meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].complete="Y"))
     meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].complete24 = "Y"
    ELSE
     meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].complete24 = "N"
    ENDIF
   ENDIF
   cnt_comp = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(meds_compliance->nurse_unit,5))),
   (dummyt d2  WITH seq = 1),
   encntr_loc_hist elh
  PLAN (d1
   WHERE maxrec(d2,size(meds_compliance->nurse_unit[d1.seq].unit_pat,5)))
   JOIN (d2
   WHERE (meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].comp_dttm > 0))
   JOIN (elh
   WHERE (elh.encntr_id=meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].encounter)
    AND cnvtdatetime(meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].comp_dttm) BETWEEN elh
   .beg_effective_dt_tm AND elh.end_effective_dt_tm)
  ORDER BY elh.encntr_id
  HEAD elh.encntr_id
   IF ((meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].comp_percent_done=100))
    meds_compliance->nurse_unit[d1.seq].unit_pat[d2.seq].comp_loc = trim(uar_get_code_display(elh
      .loc_nurse_unit_cd))
   ENDIF
  WITH nocounter
 ;end select
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE finalizereport(ssendreport=vc) = null WITH protect
 DECLARE head_comp(ncalc=i2) = f8 WITH protect
 DECLARE head_compabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE section_unit(ncalc=i2) = f8 WITH protect
 DECLARE section_unitabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE section_comp_head(ncalc=i2) = f8 WITH protect
 DECLARE section_comp_headabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE section_comp(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) = f8 WITH protect
 DECLARE section_compabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) = f8 WITH
 protect
 DECLARE section_line(ncalc=i2) = f8 WITH protect
 DECLARE section_lineabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE totals_comp(ncalc=i2) = f8 WITH protect
 DECLARE totals_compabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE page_comp(ncalc=i2) = f8 WITH protect
 DECLARE page_compabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE foot_comp(ncalc=i2) = f8 WITH protect
 DECLARE foot_compabs(ncalc=i2,offsetx=f8,offsety=f8) = f8 WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant(""), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = i4 WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _rempat_name = i4 WITH noconstant(1), protect
 DECLARE _remadmit_loc = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontsection_comp = i2 WITH noconstant(0), protect
 DECLARE _times8b0 = i4 WITH noconstant(0), protect
 DECLARE _times80 = i4 WITH noconstant(0), protect
 DECLARE _times140 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times10bu0 = i4 WITH noconstant(0), protect
 DECLARE _times120 = i4 WITH noconstant(0), protect
 DECLARE _times22b0 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _times8u0 = i4 WITH noconstant(0), protect
 DECLARE _pen50s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen20s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s2c0 = i4 WITH noconstant(0), protect
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE finalizereport(ssendreport)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptstat = uar_rptendreport(_hreport)
   DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
   DECLARE bprint = i2 WITH noconstant(0), private
   IF (textlen(sfilename) > 0)
    SET bprint = checkqueue(sfilename)
    IF (bprint)
     EXECUTE cpm_create_file_name "RPT", "PS"
     SET sfilename = cpm_cfn_info->file_name_path
    ENDIF
   ENDIF
   SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
   IF (bprint)
    SET spool value(sfilename) value(ssendreport) WITH deleted
   ENDIF
   DECLARE _errorfound = i2 WITH noconstant(0), protect
   DECLARE _errcnt = i2 WITH noconstant(0), protect
   SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
   WHILE (_errorfound=rpt_errorfound
    AND _errcnt < 512)
     SET _errcnt = (_errcnt+ 1)
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE head_comp(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = head_compabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE head_compabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.940000), private
   DECLARE __report_date = vc WITH noconstant(build2(format(cnvtdatetime(curdate,curtime),
      "@SHORTDATETIME"),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 10.063
    SET rptsd->m_height = 0.375
    SET _oldfont = uar_rptsetfont(_hreport,_times22b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Nursing Medication History Compliance",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.375
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Reported_Printed:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 1.563)
    SET rptsd->m_width = 1.635
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__report_date)
    SET _dummypen = uar_rptsetpen(_hreport,_pen50s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.839),(offsetx+ 10.000),(offsety
     + 0.839))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_unit(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_unitabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_unitabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.320000), private
   DECLARE __nurse_unit = vc WITH noconstant(build2(meds_compliance->nurse_unit[n_prt].
     nurse_unit_name,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 1.021)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.250
    SET _oldfont = uar_rptsetfont(_hreport,_times140)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__nurse_unit)
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ - (0.042))
    SET rptsd->m_width = 1.000
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Nurse Unit:",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.261),(offsetx+ 10.010),(offsety
     + 0.261))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.031)
    SET rptsd->m_x = (offsetx+ 3.458)
    SET rptsd->m_width = 1.604
    SET rptsd->m_height = 0.260
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(continued,char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_comp_head(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_comp_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_comp_headabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.270000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.323
    SET rptsd->m_height = 0.146
    SET _oldfont = uar_rptsetfont(_hreport,_times8u0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name",char(0)))
    SET rptsd->m_y = (offsety+ 0.000)
    SET rptsd->m_x = (offsetx+ 2.281)
    SET rptsd->m_width = 0.688
    SET rptsd->m_height = 0.271
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Admit Date Time",char(0)))
    SET rptsd->m_flags = 20
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 3.063)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.146
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Admit Unit",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 3.875)
    SET rptsd->m_width = 0.531
    SET rptsd->m_height = 0.146
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Comp Unit",char(0)))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 1.500)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.146
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Acct No.",char(0)))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 5.042)
    SET rptsd->m_width = 0.396
    SET rptsd->m_height = 0.146
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Comp % ",char(0)))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 7.146)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.146
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Complete",char(0)))
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 4.563)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Unable to obtain",char(0)))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 7.677)
    SET rptsd->m_width = 0.760
    SET rptsd->m_height = 0.146
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Complete 24hrs",char(0)))
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 8.500)
    SET rptsd->m_width = 0.615
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Time To Complete(hrs)",char(0)))
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 9.313)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Time Not Done(hrs)",char(0)))
    SET rptsd->m_y = (offsety+ 0.021)
    SET rptsd->m_x = (offsetx+ 6.688)
    SET rptsd->m_width = 0.354
    SET rptsd->m_height = 0.250
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Med U or I",char(0)))
    SET rptsd->m_flags = 20
    SET rptsd->m_y = (offsety+ 0.010)
    SET rptsd->m_x = (offsetx+ 5.563)
    SET rptsd->m_width = 0.938
    SET rptsd->m_height = 0.146
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Documented Meds",char(0)))
    SET rptsd->m_flags = 68
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 6.188)
    SET rptsd->m_width = 0.313
    SET rptsd->m_height = 0.146
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Total",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 5.635)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.146
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Completed",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_comp(ncalc,maxheight,bcontinue)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_compabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_compabs(ncalc,offsetx,offsety,maxheight,bcontinue)
   DECLARE sectionheight = f8 WITH noconstant(0.170000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_pat_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_admit_loc = f8 WITH noconstant(0.0), private
   DECLARE __pat_name = vc WITH noconstant(build2(meds_compliance->nurse_unit[n_prt].unit_pat[p_prt].
     patient_name,char(0))), protect
   DECLARE __admit_loc = vc WITH noconstant(build2(meds_compliance->nurse_unit[n_prt].unit_pat[p_prt]
     .admit_loc,char(0))), protect
   DECLARE __admit_date = vc WITH noconstant(build2(meds_compliance->nurse_unit[n_prt].unit_pat[p_prt
     ].admit_dt,char(0))), protect
   DECLARE __fin = vc WITH noconstant(build2(meds_compliance->nurse_unit[n_prt].unit_pat[p_prt].fin,
     char(0))), protect
   DECLARE __comp_loc = vc WITH noconstant(build2(meds_compliance->nurse_unit[n_prt].unit_pat[p_prt].
     comp_loc,char(0))), protect
   DECLARE __per_done = vc WITH noconstant(build2(format(percent_done,"####.#"),char(0))), protect
   DECLARE __complete = vc WITH noconstant(build2(meds_compliance->nurse_unit[n_prt].unit_pat[p_prt].
     complete,char(0))), protect
   DECLARE __unable_to_obtain = vc WITH noconstant(build2(evaluate(meds_compliance->nurse_unit[n_prt]
      .unit_pat[p_prt].unable_to_obain,1,"Y",0,"N"),char(0))), protect
   IF (percent_done=100)
    DECLARE __time_complete = vc WITH noconstant(build2(format(meds_compliance->nurse_unit[n_prt].
       unit_pat[p_prt].time_complete,"####.#"),char(0))), protect
   ENDIF
   DECLARE __complete24 = vc WITH noconstant(build2(meds_compliance->nurse_unit[n_prt].unit_pat[p_prt
     ].complete24,char(0))), protect
   IF (percent_done < 100)
    DECLARE __time_no_comp = vc WITH noconstant(build2(format(meds_compliance->nurse_unit[n_prt].
       unit_pat[p_prt].time_complete,"####.#"),char(0))), protect
   ENDIF
   IF ((meds_compliance->nurse_unit[n_prt].unit_pat[p_prt].doc_ui != "$"))
    DECLARE __doc_ui = vc WITH noconstant(build2(meds_compliance->nurse_unit[n_prt].unit_pat[p_prt].
      doc_ui,char(0))), protect
   ENDIF
   DECLARE __comped_meds = vc WITH noconstant(build2(cnvtint(meds_compliance->nurse_unit[n_prt].
      unit_pat[p_prt].num_comp_meds),char(0))), protect
   DECLARE __total_home_meds = vc WITH noconstant(build2(cnvtint(meds_compliance->nurse_unit[n_prt].
      unit_pat[p_prt].num_doc_meds),char(0))), protect
   IF (bcontinue=0)
    SET _rempat_name = 1
    SET _remadmit_loc = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.010)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times80)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdrempat_name = _rempat_name
   IF (_rempat_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempat_name,((size(
        __pat_name) - _rempat_name)+ 1),__pat_name)))
    SET drawheight_pat_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempat_name = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempat_name,((size(__pat_name) -
       _rempat_name)+ 1),__pat_name)))))
     SET _rempat_name = (_rempat_name+ rptsd->m_drawlength)
    ELSE
     SET _rempat_name = 0
    ENDIF
    SET growsum = (growsum+ _rempat_name)
   ENDIF
   SET rptsd->m_flags = 21
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.010)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.063)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremadmit_loc = _remadmit_loc
   IF (_remadmit_loc > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remadmit_loc,((size(
        __admit_loc) - _remadmit_loc)+ 1),__admit_loc)))
    SET drawheight_admit_loc = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remadmit_loc = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remadmit_loc,((size(__admit_loc) -
       _remadmit_loc)+ 1),__admit_loc)))))
     SET _remadmit_loc = (_remadmit_loc+ rptsd->m_drawlength)
    ELSE
     SET _remadmit_loc = 0
    ENDIF
    SET growsum = (growsum+ _remadmit_loc)
   ENDIF
   SET rptsd->m_flags = 4
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.010)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = drawheight_pat_name
   IF (ncalc=rpt_render
    AND _holdrempat_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrempat_name,((size(
        __pat_name) - _holdrempat_name)+ 1),__pat_name)))
   ELSE
    SET _rempat_name = _holdrempat_name
   ENDIF
   SET rptsd->m_flags = 20
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.010)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.063)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = drawheight_admit_loc
   IF (ncalc=rpt_render
    AND _holdremadmit_loc > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremadmit_loc,((size(
        __admit_loc) - _holdremadmit_loc)+ 1),__admit_loc)))
   ELSE
    SET _remadmit_loc = _holdremadmit_loc
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.010)
   SET rptsd->m_x = (offsetx+ 2.208)
   SET rptsd->m_width = 0.875
   SET rptsd->m_height = 0.146
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__admit_date)
   ENDIF
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety+ 0.010)
   SET rptsd->m_x = (offsetx+ 1.500)
   SET rptsd->m_width = 0.563
   SET rptsd->m_height = 0.146
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__fin)
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.010)
   SET rptsd->m_x = (offsetx+ 3.875)
   SET rptsd->m_width = 0.542
   SET rptsd->m_height = 0.146
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__comp_loc)
   ENDIF
   SET rptsd->m_flags = 64
   SET rptsd->m_y = (offsety+ 0.010)
   SET rptsd->m_x = (offsetx+ 5.000)
   SET rptsd->m_width = 0.438
   SET rptsd->m_height = 0.146
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__per_done)
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.010)
   SET rptsd->m_x = (offsetx+ 7.198)
   SET rptsd->m_width = 0.500
   SET rptsd->m_height = 0.146
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__complete)
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.010)
   SET rptsd->m_x = (offsetx+ 4.625)
   SET rptsd->m_width = 0.250
   SET rptsd->m_height = 0.146
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__unable_to_obtain)
   ENDIF
   SET rptsd->m_flags = 64
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 8.500)
   SET rptsd->m_width = 0.438
   SET rptsd->m_height = 0.146
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (percent_done=100)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__time_complete)
    ENDIF
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.010)
   SET rptsd->m_x = (offsetx+ 7.708)
   SET rptsd->m_width = 0.521
   SET rptsd->m_height = 0.146
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__complete24)
   ENDIF
   SET rptsd->m_flags = 64
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 9.333)
   SET rptsd->m_width = 0.438
   SET rptsd->m_height = 0.146
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF (percent_done < 100)
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__time_no_comp)
    ENDIF
   ENDIF
   SET rptsd->m_flags = 16
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.688)
   SET rptsd->m_width = 0.458
   SET rptsd->m_height = 0.146
   IF (ncalc=rpt_render
    AND bcontinue=0)
    IF ((meds_compliance->nurse_unit[n_prt].unit_pat[p_prt].doc_ui != "$"))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__doc_ui)
    ENDIF
   ENDIF
   SET rptsd->m_flags = 64
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 5.563)
   SET rptsd->m_width = 0.438
   SET rptsd->m_height = 0.146
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__comped_meds)
   ENDIF
   SET rptsd->m_flags = 64
   SET rptsd->m_y = (offsety+ 0.000)
   SET rptsd->m_x = (offsetx+ 6.125)
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.146
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__total_home_meds)
   ENDIF
   SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
   SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE section_line(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = section_lineabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE section_lineabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.650000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s2c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.063),(offsetx+ 10.000),(offsety
     + 0.063))
    SET rptsd->m_flags = 64
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 3.000)
    SET rptsd->m_width = 0.844
    SET rptsd->m_height = 0.146
    SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(count_comp,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.938)
    SET rptsd->m_width = 2.052
    SET rptsd->m_height = 0.146
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Number Compliance Done :",char(0)))
    SET rptsd->m_flags = 64
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 0.594
    SET rptsd->m_height = 0.146
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(comp_avg_time,char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 3.250)
    SET rptsd->m_width = 0.594
    SET rptsd->m_height = 0.146
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(comp_avg,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 0.938)
    SET rptsd->m_width = 2.000
    SET rptsd->m_height = 0.146
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Percent Compliance Done :",char(0)))
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 3.938)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.146
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("%",char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s2c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.563),(offsetx+ 10.000),(offsety
     + 0.563))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 0.938)
    SET rptsd->m_width = 2.063
    SET rptsd->m_height = 0.146
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Completed Compliance Avg. Time (Hrs) :",char(0)))
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 4.500)
    SET rptsd->m_width = 2.500
    SET rptsd->m_height = 0.146
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Compliance all Statuses Avg. Time  (hrs):",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.125)
    SET rptsd->m_x = (offsetx+ 7.313)
    SET rptsd->m_width = 1.365
    SET rptsd->m_height = 0.146
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(avg_wait_time,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 4.510)
    SET rptsd->m_width = 1.927
    SET rptsd->m_height = 0.146
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Percent Compliance Done in 24 hrs:",
      char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 7.313)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.146
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(comp_24,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.375)
    SET rptsd->m_x = (offsetx+ 7.813)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.146
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("%",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE totals_comp(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = totals_compabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE totals_compabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(1.070000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen20s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.063),(offsetx+ 10.000),(offsety
     + 0.063))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.135)
    SET rptsd->m_x = (offsetx+ 1.615)
    SET rptsd->m_width = 1.635
    SET rptsd->m_height = 0.115
    SET _oldfont = uar_rptsetfont(_hreport,_times8b0)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("All units",char(0)))
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 1.438)
    SET rptsd->m_width = 1.781
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10bu0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("All Units",char(0)))
    SET rptsd->m_flags = 68
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 0.875)
    SET rptsd->m_width = 1.875
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times8b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Completed Compliance Average Time : (Hrs) :",char(0)))
    SET rptsd->m_y = (offsety+ 0.448)
    SET rptsd->m_x = (offsetx+ 1.438)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Number Compliance Done : ",char(0)))
    SET rptsd->m_y = (offsety+ 0.646)
    SET rptsd->m_x = (offsetx+ 1.448)
    SET rptsd->m_width = 1.302
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Percent Compliance Done : ",char(0)))
    SET rptsd->m_flags = 64
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 3.000)
    SET rptsd->m_width = 0.563
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(all_units_avg_time,char(0)))
    SET rptsd->m_y = (offsety+ 0.448)
    SET rptsd->m_x = (offsetx+ 2.938)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(total_comp_pat,char(0)))
    SET rptsd->m_y = (offsety+ 0.646)
    SET rptsd->m_x = (offsetx+ 3.094)
    SET rptsd->m_width = 0.469
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(all_units_comp_avg,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.646)
    SET rptsd->m_x = (offsetx+ 3.625)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.167
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("%",char(0)))
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 4.375)
    SET rptsd->m_width = 1.938
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Compliance all Statuses Avg. Time  (hrs):",char(0)))
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.250)
    SET rptsd->m_x = (offsetx+ 6.438)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(all_unit_avg_wait,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.646)
    SET rptsd->m_x = (offsetx+ 4.333)
    SET rptsd->m_width = 1.792
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Percent Compliance Done in 24 hrs:",
      char(0)))
    SET rptsd->m_flags = 32
    SET rptsd->m_y = (offsety+ 0.646)
    SET rptsd->m_x = (offsetx+ 6.438)
    SET rptsd->m_width = 0.500
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(all_unit_per_done24,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_y = (offsety+ 0.646)
    SET rptsd->m_x = (offsetx+ 7.135)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("%",char(0)))
    SET _dummyfont = uar_rptsetfont(_hreport,_oldfont)
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE page_comp(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = page_compabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE page_compabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 16
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 10.000
    SET rptsd->m_height = 0.188
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.115),(offsetx+ 10.000),(offsety
     + 0.115))
    SET _dummypen = uar_rptsetpen(_hreport,_oldpen)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE foot_comp(ncalc)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = foot_compabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE foot_compabs(ncalc,offsetx,offsety)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 100
   SET rptreport->m_reportname = "bhs_rpt_nrs_meds_compliance"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_landscape
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.50
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.50
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 50
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 22
   SET rptfont->m_bold = rpt_on
   SET _times22b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _times120 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 14
   SET _times140 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_on
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 8
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_underline = rpt_on
   SET _times8u0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_underline = rpt_off
   SET _times80 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET _times8b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 10
   SET rptfont->m_underline = rpt_on
   SET _times10bu0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.050
   SET _pen50s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 2
   SET _pen14s2c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.020
   SET rptpen->m_penstyle = 0
   SET _pen20s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET d0 = initializereport(0)
 SET d0 = head_comp(rpt_render)
 SET tmp_work_room = (8.5 - page_comp(rpt_calcheight))
 SET tmp_height = 0.00
 SET y_page_head = 0.26
 SET y_page_foot = (7.5 - page_comp(rpt_calcheight))
 SET page_foot_buffer = 0
 SET y_end_of_page = (y_page_foot - page_foot_buffer)
 SET temp1 = 0
 SET temp2 = 0
 SET temp3 = 0
 SET becont = 0
 SET continued = "                      "
 FOR (n_prt = 1 TO size(meds_compliance->nurse_unit,5))
   SET count_comp = 0
   SET total_unit_time = 0
   SET total_wait_time = 0
   SET total_wait_unit = 0
   SET tmp_work_room = (((y_end_of_page - _yoffset) - section_unit(rpt_calcheight)) -
   section_comp_head(rpt_calcheight))
   IF (tmp_work_room < 0)
    SET _yoffset = y_page_foot
    SET d0 = page_comp(rpt_render)
    SET d0 = pagebreak(0)
    SET _yoffset = y_page_head
    SET tmp_work_room = (y_end_of_page - _yoffset)
    SET d0 = section_unit(rpt_render)
    SET d0 = section_comp_head(rpt_render)
   ELSE
    SET temp1 = section_unit(rpt_calcheight)
    SET d0 = section_unit(rpt_render)
    SET d0 = section_comp_head(rpt_render)
   ENDIF
   SET posit = 0
   SET cnt_24hr = 0
   FOR (p_prt = 1 TO size(meds_compliance->nurse_unit[n_prt].unit_pat,5))
     SET tmp_work_room = (y_end_of_page - _yoffset)
     IF ((meds_compliance->nurse_unit[n_prt].unit_pat[p_prt].comp_percent_done=100))
      SET count_comp = (count_comp+ 1)
      SET total_unit_time = (total_unit_time+ meds_compliance->nurse_unit[n_prt].unit_pat[p_prt].
      time_complete)
      IF ((meds_compliance->nurse_unit[n_prt].unit_pat[p_prt].complete24="Y"))
       SET cnt_24hr = (cnt_24hr+ 1)
      ENDIF
     ELSE
      SET total_wait_unit = (total_wait_unit+ meds_compliance->nurse_unit[n_prt].unit_pat[p_prt].
      time_complete)
     ENDIF
     SET percent_done = round(((cnvtreal(meds_compliance->nurse_unit[n_prt].unit_pat[p_prt].
       num_comp_meds)/ cnvtreal(meds_compliance->nurse_unit[n_prt].unit_pat[p_prt].num_doc_meds)) *
      100),0)
     IF (tmp_work_room < 0)
      SET d0 = page_comp(rpt_render)
      SET d0 = pagebreak(0)
      SET tmp_work_room = (y_end_of_page - _yoffset)
      SET continued = "continued"
      SET d0 = section_unit(rpt_render)
      SET tmp_work_room = (y_end_of_page - _yoffset)
      SET d0 = section_comp_head(rpt_render)
      SET d0 = section_comp(rpt_render,tmp_work_room,becont)
      SET continued = ""
     ELSE
      SET d0 = section_comp(rpt_render,tmp_work_room,becont)
     ENDIF
     WHILE (becont=1)
       SET d0 = page_comp(rpt_render)
       SET d0 = pagebreak(0)
       SET continued = "continued"
       SET d0 = section_unit(rpt_render)
       SET tmp_work_room = (y_end_of_page - _yoffset)
       IF (tmp_work_room < 0)
        SET d0 = page_comp(rpt_render)
        SET d0 = pagebreak(0)
        SET tmp_work_room = (y_end_of_page - _yoffset)
       ENDIF
       SET d0 = section_comp_head(rpt_render)
       SET d0 = section_comp(rpt_render,tmp_work_room,becont)
       SET continued = ""
     ENDWHILE
     SET temp3 = foot_comp(rpt_calcheight)
     SET patient_count = p_prt
   ENDFOR
   SET posit = 0
   SET comp_avg = round(((count_comp/ patient_count) * 100),2)
   SET comp_24 = round(((cnt_24hr/ patient_count) * 100),2)
   SET allunit24hr = (allunit24hr+ cnt_24hr)
   SET cnt_24hr = 0
   SET comp_avg_time = round((total_unit_time/ count_comp),2)
   SET tmp_work_room = (y_end_of_page - (_yoffset+ section_line(rpt_calcheight)))
   SET avg_wait_time = ((total_wait_unit+ total_unit_time)/ patient_count)
   SET total_comp_pat = (total_comp_pat+ count_comp)
   SET all_unit_time = (all_unit_time+ total_unit_time)
   SET all_unit_pat = (all_unit_pat+ patient_count)
   SET all_unit_wait = (all_unit_wait+ (total_wait_unit+ total_unit_time))
   CALL echo(build("all_unit_wait = ",all_unit_wait))
   CALL echo(build("all_unit_time = ",all_unit_time))
   CALL echo(build("all_unit_pat = ",all_unit_pat))
   IF (tmp_work_room < 0)
    SET d0 = page_comp(rpt_render)
    SET d0 = pagebreak(0)
    SET tmp_work_room = (y_end_of_page - _yoffset)
    SET continued = "continued"
    SET d0 = section_unit(rpt_render)
    SET d0 = section_line(rpt_render)
    SET continued = ""
   ELSE
    SET d0 = section_line(rpt_render)
   ENDIF
 ENDFOR
 SET all_units_comp_avg = round(((total_comp_pat/ all_unit_pat) * 100),2)
 SET all_unit_per_done24 = round(((allunit24hr/ all_unit_pat) * 100),2)
 SET all_units_avg_time = round((all_unit_time/ total_comp_pat),2)
 SET all_unit_avg_wait = round((all_unit_wait/ all_unit_pat),2)
 IF (((7.5 - _yoffset) < ((totals_comp(rpt_calcheight)+ page_comp(rpt_calcheight))+ foot_comp(
  rpt_calcheight))))
  SET d0 = page_comp(rpt_render)
  SET d0 = pagebreak(0)
 ENDIF
 SET d0 = totals_comp(rpt_render)
 SET d0 = page_comp(rpt_render)
 SET d0 = foot_comp(rpt_render)
 SET d0 = finalizereport( $OUTDEV)
 SET last_mod = "04  01/12/2018  ML012560 SR 418141000-Fixed comp percent"
END GO
