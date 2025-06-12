CREATE PROGRAM al_bhs_sys_trauma_one:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD t1
 RECORD t1(
   1 cnt = i2
   1 qual[*]
     2 eid = f8
 )
 FREE RECORD tdx
 RECORD tdx(
   1 cnt = i2
   1 qual[*]
     2 event_cd = f8
 )
 FREE RECORD list
 RECORD list(
   1 cnt = i2
   1 qual[*]
     2 eid = f8
     2 acct = vc
     2 mrn = vc
     2 last_name = vc
     2 first_name = vc
     2 race = vc
     2 dob = vc
     2 sex = vc
     2 address = vc
     2 city = vc
     2 state = vc
     2 zip = vc
     2 country = vc
     2 checkin_dt_tm = vc
     2 checkout_dt_tm = vc
     2 admit_date = vc
     2 disch_date = vc
     2 inpt_loc = vc
     2 drug_result[*]
       3 display = vc
     2 pregnant = vc
     2 ventilator = vc
     2 icu_days = vc
     2 primary_payor = vc
     2 secindary_payor = vc
     2 eddisch = vc
     2 mf_person_id = f8
     2 ms_hispanic = vc
     2 mf_tot_icu_min = f8
     2 ms_height = vc
     2 ms_weight = vc
 )
 DECLARE inpatient_71 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE pregnant = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"PREGNANT"))
 DECLARE displayline = vc
 DECLARE ind = i2
 DECLARE filename = vc WITH protect, noconstant(" ")
 DECLARE dclcom = vc
 DECLARE display1 = vc
 DECLARE display2 = vc
 DECLARE mf_home_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",212,"HOME"))
 DECLARE mf_bmced_trk_grp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16370,
   "BMCEDHOFTRACKINGGROUP"))
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE mf_mode_of_delivery_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "MODEOFDELIVERYOXYGEN"))
 DECLARE mf_height_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"HEIGHT"))
 DECLARE mf_weight_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"WEIGHT"))
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ACTIVE"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_final_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",8,"FINAL"))
 SET filename = build("al_t1_",format(curdate,"mmddyyyy;;d"),".csv")
 SELECT INTO "nl:"
  eid = cnvtstring(e.encntr_id)
  FROM fn_omf_encntr fn,
   encounter e
  PLAN (fn
   WHERE (fn.checkout_dt_tm > (sysdate - 180))
    AND fn.tracking_group_cd=mf_bmced_trk_grp_cd
    AND  EXISTS (
   (SELECT
    ea.encntr_id
    FROM encntr_alias ea
    WHERE ea.encntr_id=fn.encntr_id
     AND ea.encntr_alias_type_cd=1079
     AND ea.end_effective_dt_tm > sysdate
     AND trim(ea.alias)="992????"
     AND ea.active_ind=1
     AND  EXISTS (
    (SELECT
     ea2.encntr_id
     FROM encntr_alias ea2
     WHERE ea2.encntr_id=ea.encntr_id
      AND ea2.encntr_alias_type_cd=1077
      AND ea2.end_effective_dt_tm > sysdate
      AND trim(ea2.alias)="66???????"
      AND ea2.active_ind=1)))))
   JOIN (e
   WHERE e.encntr_id=fn.encntr_id
    AND e.loc_facility_cd=673936
    AND  NOT (e.encntr_type_cd IN (309310.00))
    AND ((e.disch_dt_tm = null) OR (e.disch_dt_tm BETWEEN cnvtdatetime((curdate - 1),0) AND
   cnvtdatetime((curdate - 1),235959))) )
  DETAIL
   t1->cnt = (t1->cnt+ 1), stat = alterlist(t1->qual,t1->cnt), t1->qual[t1->cnt].eid = e.encntr_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   encounter e
  PLAN (o
   WHERE ((o.catalog_cd=value(uar_get_code_by("displaykey",200,"CONSULTTRAUMAEDONLY"))) OR (o
   .catalog_cd=value(uar_get_code_by("displaykey",200,"TRAUMAREGISTRYCONSULTNURSING")))) )
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.loc_facility_cd=673936
    AND  NOT (e.encntr_type_cd IN (679658.00, 309310.00))
    AND ((e.disch_dt_tm = null) OR (e.disch_dt_tm BETWEEN cnvtdatetime((curdate - 1),0) AND
   cnvtdatetime((curdate - 1),235959))) )
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = 0, cnt = locateval(ind,1,t1->cnt,o.encntr_id,t1->qual[ind].eid)
   IF (cnt=0)
    t1->cnt = (t1->cnt+ 1), stat = alterlist(t1->qual,t1->cnt), t1->qual[t1->cnt].eid = o.encntr_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(t1->cnt)),
   fn_omf_encntr fn,
   encntr_alias e,
   encntr_alias e2,
   person p,
   encounter en,
   address ad
  PLAN (d)
   JOIN (en
   WHERE (en.encntr_id=t1->qual[d.seq].eid))
   JOIN (e
   WHERE e.encntr_id=en.encntr_id
    AND e.end_effective_dt_tm > sysdate
    AND e.encntr_alias_type_cd=1077)
   JOIN (e2
   WHERE e2.encntr_id=en.encntr_id
    AND e2.end_effective_dt_tm > sysdate
    AND e2.encntr_alias_type_cd=1079)
   JOIN (ad
   WHERE ad.parent_entity_id=en.person_id
    AND ad.parent_entity_name="PERSON"
    AND ad.address_type_cd=mf_home_cd
    AND ad.active_ind=1)
   JOIN (p
   WHERE p.person_id=en.person_id)
   JOIN (fn
   WHERE fn.encntr_id=outerjoin(en.encntr_id)
    AND fn.tracking_group_cd=outerjoin(mf_bmced_trk_grp_cd))
  ORDER BY en.encntr_id
  HEAD en.encntr_id
   list->cnt = (list->cnt+ 1), stat = alterlist(list->qual,list->cnt), list->qual[list->cnt].eid = en
   .encntr_id,
   list->qual[list->cnt].acct = e.alias, list->qual[list->cnt].mrn = e2.alias, list->qual[list->cnt].
   last_name = p.name_last_key,
   list->qual[list->cnt].first_name = p.name_first_key, list->qual[list->cnt].race =
   uar_get_code_display(p.race_cd), list->qual[list->cnt].dob = format(p.birth_dt_tm,
    "mm/dd/yyyy hh:mm;;d"),
   list->qual[list->cnt].sex = uar_get_code_display(p.sex_cd), list->qual[list->cnt].address = concat
   (trim(ad.street_addr,3),trim(ad.street_addr2,3)), list->qual[list->cnt].city = ad.city,
   list->qual[list->cnt].state = ad.state, list->qual[list->cnt].zip = ad.zipcode, list->qual[list->
   cnt].country = "USA",
   list->qual[list->cnt].checkout_dt_tm = format(fn.checkout_dt_tm,"mm/dd/yyyy hh:mm;;d"), list->
   qual[list->cnt].admit_date = concat(format(en.reg_dt_tm,"mm/dd/yyyy")," 00:00"), list->qual[list->
   cnt].checkin_dt_tm = list->qual[list->cnt].admit_date,
   list->qual[list->cnt].disch_date = format(en.disch_dt_tm,"mm/dd/yyyy hh:mm;;d"), list->qual[list->
   cnt].inpt_loc = " ", list->qual[list->cnt].ventilator = "0",
   list->qual[list->cnt].pregnant = "N", list->qual[list->cnt].eddisch = " ", list->qual[list->cnt].
   mf_person_id = p.person_id,
   list->qual[list->cnt].ms_hispanic = "U", list->qual[list->cnt].mf_tot_icu_min = 0.0
   IF (uar_get_code_display(en.loc_nurse_unit_cd) IN ("ICU", "ICU-A", "ICU-B", "ICU-C", "CICU",
   "MICU", "PICU", "SICU", "HVCC"))
    list->qual[list->cnt].icu_days = "1"
   ELSE
    list->qual[list->cnt].icu_days = "0"
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(list)
 SELECT INTO "nl:"
  FROM bhs_demographics bd
  WHERE expand(ml_idx1,1,list->cnt,bd.person_id,list->qual[ml_idx1].mf_person_id)
   AND bd.description IN ("hispanic ind")
  ORDER BY bd.person_id
  DETAIL
   ml_idx2 = locateval(ml_idx1,1,list->cnt,bd.person_id,list->qual[ml_idx1].mf_person_id)
   IF (trim(bd.display) IN ("REFUSED", "R"))
    list->qual[ml_idx2].ms_hispanic = "R"
   ELSEIF (trim(bd.display)="Y")
    list->qual[ml_idx2].ms_hispanic = "Y"
   ELSEIF (trim(bd.display)="N")
    list->qual[ml_idx2].ms_hispanic = "N"
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  vese1_event_set_disp = uar_get_code_display(vese1.event_set_cd), vese1_event_disp =
  uar_get_code_display(vese1.event_cd)
  FROM v500_event_set_explode vese1,
   v500_event_set_code vesc1
  PLAN (vese1)
   JOIN (vesc1
   WHERE vese1.event_set_cd=vesc1.event_set_cd
    AND vesc1.event_set_name="TOXICOLOGY/TDM")
  DETAIL
   tdx->cnt = (tdx->cnt+ 1), stat = alterlist(tdx->qual,tdx->cnt), tdx->qual[tdx->cnt].event_cd =
   vese1.event_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(list->cnt)),
   clinical_event ce
  PLAN (d
   WHERE d.seq > 0)
   JOIN (ce
   WHERE (ce.encntr_id=list->qual[d.seq].eid)
    AND ce.valid_until_dt_tm > sysdate
    AND ce.view_level=1)
  ORDER BY d.seq, ce.event_end_dt_tm
  HEAD d.seq
   cnt = 0
  DETAIL
   IF (expand(ind,1,tdx->cnt,ce.event_cd,tdx->qual[ind].event_cd))
    cnt = (cnt+ 1), stat = alterlist(list->qual[d.seq].drug_result,cnt), list->qual[d.seq].
    drug_result[cnt].display = concat(format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d")," ",trim(
      uar_get_code_display(ce.event_cd),3)," ",trim(ce.result_val,3))
   ENDIF
   IF (ce.event_cd=pregnant)
    list->qual[d.seq].pregnant = trim(ce.result_val,3)
   ENDIF
   IF (ce.result_status_cd IN (mf_active_cd, mf_auth_cd, mf_altered_cd, mf_modified_cd, mf_final_cd))
    IF (ce.event_cd=mf_height_cd)
     list->qual[d.seq].ms_height = trim(ce.result_val)
    ENDIF
    IF (ce.event_cd=mf_weight_cd)
     list->qual[d.seq].ms_weight = trim(ce.result_val)
    ENDIF
    IF (ce.event_cd=mf_mode_of_delivery_cd
     AND trim(ce.result_val)="Ventilator"
     AND ce.event_end_dt_tm BETWEEN cnvtdatetime((curdate - 1),0) AND cnvtdatetime((curdate - 1),
     235959))
     list->qual[d.seq].ventilator = "1"
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(list->cnt)),
   encntr_loc_hist elh
  PLAN (d
   WHERE d.seq > 0)
   JOIN (elh
   WHERE (elh.encntr_id=list->qual[d.seq].eid))
  ORDER BY d.seq, elh.beg_effective_dt_tm
  HEAD d.seq
   cnt = 0
  DETAIL
   IF (uar_get_code_display(elh.loc_nurse_unit_cd)="ESW")
    list->qual[d.seq].admit_date = concat(format(elh.beg_effective_dt_tm,"mm/dd/yyyy")," 00:00"),
    list->qual[d.seq].checkin_dt_tm = list->qual[d.seq].admit_date
   ENDIF
   IF ( NOT (uar_get_code_display(elh.loc_nurse_unit_cd) IN ("ED*", "ESHLD", "PAHLD", "ESA", "ESB",
   "ESC", "ESD", "ESE", "ESP", "ESW")))
    list->qual[d.seq].inpt_loc = uar_get_code_display(elh.loc_nurse_unit_cd)
   ENDIF
   IF (uar_get_code_display(elh.loc_nurse_unit_cd) IN ("ICU", "ICU-A", "ICU-B", "ICU-C", "CICU",
   "MICU", "PICU", "SICU", "HVCC"))
    IF (elh.end_effective_dt_tm BETWEEN cnvtdatetime((curdate - 1),0) AND cnvtdatetime((curdate - 1),
     235959))
     IF ((list->qual[d.seq].icu_days="0"))
      list->qual[d.seq].icu_days = "1"
     ENDIF
    ENDIF
    IF (elh.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     list->qual[d.seq].mf_tot_icu_min = (list->qual[d.seq].mf_tot_icu_min+ datetimediff(cnvtdatetime(
       curdate,curtime3),elh.beg_effective_dt_tm,4))
    ELSE
     list->qual[d.seq].mf_tot_icu_min = (list->qual[d.seq].mf_tot_icu_min+ datetimediff(elh
      .end_effective_dt_tm,elh.beg_effective_dt_tm,4))
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(list->cnt)),
   encntr_plan_reltn epr,
   health_plan hp
  PLAN (d
   WHERE d.seq > 0)
   JOIN (epr
   WHERE (epr.encntr_id=list->qual[d.seq].eid)
    AND epr.priority_seq IN (1, 2)
    AND epr.end_effective_dt_tm > sysdate)
   JOIN (hp
   WHERE hp.health_plan_id=epr.health_plan_id
    AND hp.end_effective_dt_tm > sysdate)
  ORDER BY d.seq
  DETAIL
   IF (epr.priority_seq=1)
    list->qual[d.seq].primary_payor = trim(hp.plan_name)
   ELSEIF (epr.priority_seq=2)
    list->qual[d.seq].secindary_payor = trim(hp.plan_name)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO value(filename)
  FROM dummyt d
  HEAD REPORT
   displayline = " ", display1 = " ", display2 = " ",
   displayline = build(',"',"ACCT",'","',"MRN",'","',
    "LAST_NAME",'","',"FIRST_NAME",'","',"RACE",
    '","',"DOB",'","',"SEX",'","',
    "ADDRESS",'","',"CITY",'","',"STATE",
    '","',"ZIP",'","',"COUNTRY",'","',
    "CHECKIN_DT_TM",'","',"CHECKOUT_DT_TM",'","',"ADMIT_DT_TM",
    '","',"DISCH_DT_TM",'","',"INP_LOC",'","',
    "PREGNANT",'","',"ICU_DAYS",'","',"PRIMARY_PAYOR",
    '","',"SECONDARY_PAYOR",'","',"VENT_DAYS",'","',
    "ED_DISCH",'","',"DRUG_RESULT",'","',"HISPANIC_IND",
    '","',"TOT_ICU_MIN",'","',"HEIGHT",'","',
    "WEIGHT",'",'), col 1, displayline,
   row + 1
  HEAD d.seq
   FOR (x = 1 TO list->cnt)
     display1 = " ", display2 = " ", displayline = " ",
     display1 = build(',"',list->qual[x].acct,'","',list->qual[x].mrn,'","',
      list->qual[x].last_name,'","',list->qual[x].first_name,'","',list->qual[x].race,
      '","',list->qual[x].dob,'","',list->qual[x].sex,'","',
      list->qual[x].address,'","',list->qual[x].city,'","',list->qual[x].state,
      '","',list->qual[x].zip,'","',list->qual[x].country,'","',
      list->qual[x].checkin_dt_tm,'","',list->qual[x].checkout_dt_tm,'","',list->qual[x].admit_date,
      '","',list->qual[x].disch_date,'","',list->qual[x].inpt_loc,'","',
      list->qual[x].pregnant,'","',list->qual[x].icu_days,'","',list->qual[x].primary_payor,
      '","',list->qual[x].secindary_payor,'","',list->qual[x].ventilator,'","',
      list->qual[x].eddisch)
     IF (size(list->qual[x].drug_result,5)=0)
      display2 = build('","'," ",'","',list->qual[x].ms_hispanic,'","',
       ceil(list->qual[x].mf_tot_icu_min),'","',list->qual[x].ms_height,'","',list->qual[x].ms_weight,
       '",'), displayline = build(display1,display2), col 1,
      displayline, row + 1
     ELSE
      FOR (y = 1 TO size(list->qual[x].drug_result,5))
        display2 = " ", display2 = build('","',list->qual[x].drug_result[y].display,'","',list->qual[
         x].ms_hispanic,'","',
         ceil(list->qual[x].mf_tot_icu_min),'","',list->qual[x].ms_height,'","',list->qual[x].
         ms_weight,
         '",'), displayline = build(display1,display2),
        col 1, displayline, row + 1,
        CALL echo(build("display:",display2)),
        CALL echo(build("line:",displayline))
      ENDFOR
     ENDIF
   ENDFOR
  WITH maxcol = 10000, formfeed = none, maxrow = 1,
   format = variable
 ;end select
#exit_script
END GO
