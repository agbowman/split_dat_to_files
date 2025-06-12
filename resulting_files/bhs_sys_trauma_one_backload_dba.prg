CREATE PROGRAM bhs_sys_trauma_one_backload:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE inpatient_71 = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT")), protect
 DECLARE pregnant = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PREGNANT")), protect
 DECLARE displayline = vc
 SET filename = build("t1_",format(curdate,"mmddyyyy;;d"),".csv")
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
 )
 DECLARE ind = i2
 FREE DEFINE rtl
 DEFINE rtl "bhscust:t1_backlog.dat"
 SELECT INTO "nl:"
  FROM rtlt r,
   encntr_alias ea
  PLAN (r)
   JOIN (ea
   WHERE ea.alias=r.line
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=1079)
  DETAIL
   t1->cnt = (t1->cnt+ 1), stat = alterlist(t1->qual,t1->cnt), t1->qual[t1->cnt].eid = cnvtreal(trim(
     r.line,3))
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
   cnvtdatetime(curdate,curtime3))) )
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
    AND ad.parent_entity_name="PERSON")
   JOIN (p
   WHERE p.person_id=en.person_id)
   JOIN (fn
   WHERE fn.encntr_id=outerjoin(en.encntr_id))
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
   list->qual[list->cnt].checkin_dt_tm = format(fn.checkin_dt_tm,"mm/dd/yyyy hh:mm;;d"), list->qual[
   list->cnt].checkout_dt_tm = format(fn.checkout_dt_tm,"mm/dd/yyyy hh:mm;;d"), list->qual[list->cnt]
   .admit_date = format(en.reg_dt_tm,"mm/dd/yyyy hh:mm;;d"),
   list->qual[list->cnt].disch_date = format(en.disch_dt_tm,"mm/dd/yyyy hh:mm;;d"), list->qual[list->
   cnt].inpt_loc = uar_get_code_display(en.loc_nurse_unit_cd), list->qual[list->cnt].ventilator = "0",
   list->qual[list->cnt].pregnant = "N"
   IF (en.encntr_type_cd=679658.00)
    list->qual[list->cnt].eddisch = "ED Discharge"
   ENDIF
   IF (uar_get_code_display(en.loc_nurse_unit_cd)="ICU*")
    list->qual[list->cnt].icu_days = "1"
   ELSE
    list->qual[list->cnt].icu_days = "0"
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
  ORDER BY d.seq
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
   IF (ce.event_tag IN ("Oscillator 1st day", "Mechanical vent 1st day", "Oscillator subsequent day",
   "Mechanical vent subsequent day"))
    list->qual[d.seq].ventilator = "1"
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
  ORDER BY d.seq, elh.beg_effective_dt_tm DESC
  HEAD d.seq
   cnt = 0
  DETAIL
   IF ( NOT (uar_get_code_display(elh.loc_nurse_unit_cd) IN ("ED*", "ESHLD", "PAHLD")))
    list->qual[d.seq].inpt_loc = uar_get_code_display(elh.loc_nurse_unit_cd)
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
 DECLARE display1 = vc
 DECLARE display2 = vc
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
    "ED_DISCH",'","',"DRUG_RESULT",'",'), col 1, displayline,
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
      display2 = build('","'," ",'",'), displayline = build(display1,display2), col 1,
      displayline, row + 1
     ELSE
      FOR (y = 1 TO size(list->qual[x].drug_result,5))
        display2 = " ", display2 = build('","',list->qual[x].drug_result[y].display,'",'),
        displayline = build(display1,display2),
        col 1, displayline, row + 1,
        CALL echo(build("display:",display2)),
        CALL echo(build("line:",displayline))
      ENDFOR
     ENDIF
   ENDFOR
  WITH maxcol = 10000, formfeed = none, maxrow = 1,
   format = variable
 ;end select
 DECLARE dclcom = vc
 SET dclcom = concat("$cust_script/bhs_ftp_file.ksh ",filename,
  " 172.17.10.5 'bhs\cisftp' C!sftp01 cistraumaftp")
 SET status = 0
 SET len = size(trim(dclcom))
 CALL dcl(dclcom,len,status)
 SET dclcom = concat("rm ",filename)
 SET status = 0
 SET len = size(trim(dclcom))
 CALL dcl(dclcom,len,status)
END GO
