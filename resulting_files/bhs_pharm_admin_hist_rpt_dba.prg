CREATE PROGRAM bhs_pharm_admin_hist_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Please choose the start date" = "SYSDATE",
  "Please enter the end date (1 month maximum)" = "SYSDATE",
  "Choose a Facility" = 0,
  "Select the nursing unit(s) you wish to display" = 0,
  "Check here for IV Infusion Search:" = 0,
  "Please enter the name of the medication." = "",
  "Click in the box then choose the medication(s) from the list" = 0,
  "Enter the email address. For multiple addresses seperate with a space" = ""
  WITH outdev, start_date, end_date,
  facility, nurseunit, n_ingred_ind,
  med_str, medication, email
 FREE RECORD aunit
 RECORD aunit(
   1 l_cnt = i4
   1 list[*]
     2 s_unit_display_key = vc
 ) WITH protect
 FREE RECORD t_record
 RECORD t_record(
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 encntr_cnt = i4
   1 encntr_qual[*]
     2 encntr_id = f8
     2 person_id = f8
   1 order_cnt = i4
   1 order_qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 mnemonic = vc
   1 admn_cnt = i4
   1 admn_qual[*]
     2 f_order_id = f8
     2 name = vc
     2 fin = vc
     2 age = vc
     2 unit = vc
     2 facility = vc
     2 mnemonic = vc
     2 s_dose = vc
     2 s_dose_unit = vc
     2 s_freq = vc
     2 display = vc
     2 provider = vc
     2 admn_dt_tm = dq8
 )
 DECLARE mn_ingred_search = i2 WITH protect, constant( $N_INGRED_IND)
 DECLARE mf_dose_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"STRENGTHDOSE"))
 DECLARE mf_dose_unit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "STRENGTHDOSEUNIT"))
 DECLARE mf_freq_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"FREQUENCY"))
 DECLARE auth_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED"))
 DECLARE fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE pharm_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE mf_pharm_act_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"PHARMACY"))
 DECLARE complete_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6003,"COMPLETE"))
 DECLARE nurse_unit_ind = i2
 DECLARE n_line = vc
 DECLARE n1_line = vc
 DECLARE n_display = vc
 DECLARE m_display = vc
 DECLARE med_ind = i2
 DECLARE email_ind = i2
 DECLARE t_line = vc
 DECLARE email_list = vc
 DECLARE damour_cd = f8
 DECLARE any_status_ind = c1
 SET any_status_ind = substring(1,1,reflect(parameter(5,0)))
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=220
    AND c.display_key="CTRCACARE"
    AND c.cdf_meaning="FACILITY"
    AND c.active_ind=1)
  DETAIL
   damour_cd = c.code_value
  WITH nocounter
 ;end select
 DECLARE indx = i2 WITH protect, noconstant(0)
 DECLARE nsize = i4 WITH protect, noconstant(0)
 DECLARE nbucketsize = i4 WITH protect, noconstant(0)
 DECLARE ntotal = i4 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(0)
 DECLARE nbuckets = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 SET t_record->beg_dt_tm = cnvtdatetime( $START_DATE)
 SET t_record->end_dt_tm = cnvtdatetime( $END_DATE)
 IF ((t_record->end_dt_tm < t_record->beg_dt_tm))
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    col 0, "End date is before start date. Choose an end date after the start date."
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF (datetimediff(t_record->end_dt_tm,t_record->beg_dt_tm) > 31)
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    col 0, "Time Interval is greater than 31 days. Choose a smaller interval."
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF (any_status_ind="I")
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    col 0, "You did not choose a nursing unit. Choose a nursing unit."
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info au
  WHERE au.info_domain="BHS_AMBULATORY_UNIT"
  HEAD REPORT
   aunit->l_cnt = 0
  DETAIL
   aunit->l_cnt += 1, stat = alterlist(aunit->list,aunit->l_cnt), aunit->list[aunit->l_cnt].
   s_unit_display_key = au.info_name
  WITH nocounter
 ;end select
 IF (( $FACILITY != damour_cd))
  IF (any_status_ind="C")
   SELECT INTO "nl:"
    FROM nurse_unit n,
     code_value cv
    PLAN (n
     WHERE (n.loc_facility_cd= $FACILITY)
      AND n.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=n.location_cd
      AND cv.code_set=220
      AND cv.active_ind=1
      AND cv.data_status_cd=25
      AND ((((cv.cdf_meaning="NURSEUNIT") OR (cv.cdf_meaning="AMBULATORY"
      AND expand(ml_cnt,1,aunit->l_cnt,cv.display_key,aunit->list[ml_cnt].s_unit_display_key))) ) OR
     (((cv.cdf_meaning="AMBULATORY"
      AND cv.display_key="BFMCONCOLOGY"
      AND n.loc_facility_cd=673937) OR (cv.cdf_meaning="AMBULATORY"
      AND cv.display_key="S15MED"
      AND n.loc_facility_cd=673936)) )) )
    ORDER BY n.location_cd
    HEAD REPORT
     first = 1
    HEAD n.location_cd
     IF (first=1)
      n_line = concat("elh.loc_nurse_unit_cd in (",trim(cnvtstring(n.location_cd))), n1_line = concat
      ("l.location_cd in (",trim(cnvtstring(n.location_cd))), first = 0
     ELSE
      n_line = concat(n_line,",",trim(cnvtstring(n.location_cd))), n1_line = concat(n1_line,",",trim(
        cnvtstring(n.location_cd)))
     ENDIF
    FOOT REPORT
     n_line = concat(n_line,")"), n1_line = concat(n1_line,")"), n_display = "All Units",
     nurse_unit_ind = 1
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM nurse_unit n
    PLAN (n
     WHERE (n.location_cd= $NURSEUNIT)
      AND n.location_cd != 0)
    ORDER BY n.location_cd
    HEAD REPORT
     first = 1
    HEAD n.location_cd
     IF (first=1)
      n_line = concat("elh.loc_nurse_unit_cd in (",trim(cnvtstring(n.location_cd))), n1_line = concat
      ("l.location_cd in (",trim(cnvtstring(n.location_cd))), first = 0
     ELSE
      n_line = concat(n_line,",",trim(cnvtstring(n.location_cd))), n1_line = concat(n1_line,",",trim(
        cnvtstring(n.location_cd)))
     ENDIF
    FOOT REPORT
     n_line = concat(n_line,")"), n1_line = concat(n1_line,")"), nurse_unit_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    loc = uar_get_code_display(l.location_cd)
    FROM location l
    PLAN (l
     WHERE parser(n1_line))
    ORDER BY loc
    HEAD REPORT
     first = 1
    HEAD loc
     IF (first=1)
      n_display = loc, first = 0
     ELSE
      n_display = concat(n_display,",",loc)
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE (c.code_value= $MEDICATION)
    AND c.code_value > 0)
  ORDER BY c.display
  HEAD REPORT
   med_ind = 1, first = 1
  HEAD c.display
   IF (first=1)
    m_display = c.display, first = 0
   ELSE
    m_display = concat(m_display,",",c.display)
   ENDIF
  WITH nocounter
 ;end select
 IF (med_ind=0)
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    col 0, "You did not choose any medications. Choose a medication(s)."
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF (size( $EMAIL) > 1)
  SET email_ind = 1
  SET email_list = trim( $EMAIL)
 ENDIF
 IF (( $FACILITY=damour_cd))
  SELECT INTO "nl:"
   FROM encounter e
   PLAN (e
    WHERE e.updt_dt_tm >= cnvtdatetime(t_record->beg_dt_tm)
     AND e.loc_facility_cd=damour_cd)
   DETAIL
    t_record->encntr_cnt += 1
    IF (mod(t_record->encntr_cnt,100)=1)
     stat = alterlist(t_record->encntr_qual,(t_record->encntr_cnt+ 99))
    ENDIF
    t_record->encntr_qual[t_record->encntr_cnt].encntr_id = e.encntr_id, t_record->encntr_qual[
    t_record->encntr_cnt].person_id = e.person_id
   FOOT REPORT
    stat = alterlist(t_record->encntr_qual,t_record->encntr_cnt)
   WITH maxcol = 1000
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM encntr_loc_hist elh,
    encounter e
   PLAN (elh
    WHERE parser(n_line)
     AND elh.end_effective_dt_tm >= cnvtdatetime(t_record->beg_dt_tm))
    JOIN (e
    WHERE e.encntr_id=elh.encntr_id
     AND ((e.disch_dt_tm >= cnvtdatetime(t_record->beg_dt_tm)
     AND e.disch_dt_tm <= cnvtdatetime(t_record->end_dt_tm)) OR (e.disch_dt_tm = null
     AND e.reg_dt_tm <= cnvtdatetime(t_record->end_dt_tm))) )
   ORDER BY elh.encntr_id
   HEAD elh.encntr_id
    t_record->encntr_cnt += 1
    IF (mod(t_record->encntr_cnt,100)=1)
     stat = alterlist(t_record->encntr_qual,(t_record->encntr_cnt+ 99))
    ENDIF
    t_record->encntr_qual[t_record->encntr_cnt].encntr_id = e.encntr_id, t_record->encntr_qual[
    t_record->encntr_cnt].person_id = e.person_id
   FOOT REPORT
    stat = alterlist(t_record->encntr_qual,t_record->encntr_cnt)
   WITH nocounter
  ;end select
 ENDIF
 CALL echo("****************************************")
 CALL echo(size(t_record->encntr_qual,5))
 CALL echo(n_line)
 SET nsize = t_record->encntr_cnt
 SET nbucketsize = 100
 SET ntotal = (ceil((cnvtreal(nsize)/ nbucketsize)) * nbucketsize)
 SET nstart = 1
 SET nbuckets = value((1+ ((ntotal - 1)/ nbucketsize)))
 SET stat = alterlist(t_record->encntr_qual,ntotal)
 FOR (j = (nsize+ 1) TO ntotal)
   SET t_record->encntr_qual[j].encntr_id = t_record->encntr_qual[nsize].encntr_id
 ENDFOR
 CALL echo(build("CatCd:", $MEDICATION))
 IF (mn_ingred_search=0)
  CALL echo("straight med search")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = nbuckets),
    encounter e,
    orders o
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
    JOIN (e
    WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),e.encntr_id,t_record->encntr_qual[indx].
     encntr_id))
    JOIN (o
    WHERE o.encntr_id=e.encntr_id
     AND expand(indx,nstart,(nstart+ (nbucketsize - 1)),o.person_id,t_record->encntr_qual[indx].
     person_id)
     AND (o.catalog_cd= $MEDICATION)
     AND o.catalog_type_cd=pharm_cd
     AND o.activity_type_cd > 0)
   ORDER BY o.order_id
   HEAD o.order_id
    t_record->order_cnt += 1
    IF (mod(t_record->order_cnt,100)=1)
     stat = alterlist(t_record->order_qual,(t_record->order_cnt+ 99))
    ENDIF
    t_record->order_qual[t_record->order_cnt].order_id = o.order_id, t_record->order_qual[t_record->
    order_cnt].encntr_id = e.encntr_id, t_record->order_qual[t_record->order_cnt].mnemonic = o
    .order_mnemonic
   FOOT REPORT
    stat = alterlist(t_record->order_qual,t_record->order_cnt)
   WITH orahint("index(o XIE7ORDERS)")
  ;end select
 ELSE
  CALL echo("IV Infusion search")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(t_record->encntr_qual,5))),
    orders o,
    order_ingredient oi
   PLAN (d)
    JOIN (o
    WHERE (o.encntr_id=t_record->encntr_qual[d.seq].encntr_id)
     AND o.catalog_type_cd=pharm_cd
     AND o.activity_type_cd=mf_pharm_act_cd
     AND o.iv_ind=1)
    JOIN (oi
    WHERE oi.order_id=o.order_id
     AND (oi.catalog_cd= $MEDICATION)
     AND oi.catalog_type_cd=pharm_cd)
   ORDER BY o.order_id
   HEAD REPORT
    pl_cnt = 0
   HEAD o.order_id
    pl_cnt += 1
    IF (pl_cnt > size(t_record->order_qual,5))
     stat = alterlist(t_record->order_qual,(pl_cnt+ 10))
    ENDIF
    t_record->order_qual[pl_cnt].order_id = o.order_id, t_record->order_qual[pl_cnt].encntr_id = o
    .encntr_id, t_record->order_qual[pl_cnt].mnemonic = o.order_mnemonic
   FOOT REPORT
    stat = alterlist(t_record->order_qual,pl_cnt), t_record->order_cnt = pl_cnt
   WITH nocounter
  ;end select
 ENDIF
 CALL echo("****************************************")
 CALL echo(size(t_record->order_qual,5))
 CALL echo(n_line)
 SET nsize = t_record->order_cnt
 SET nbucketsize = 100
 SET ntotal = (ceil((cnvtreal(nsize)/ nbucketsize)) * nbucketsize)
 SET nstart = 1
 SET nbuckets = value((1+ ((ntotal - 1)/ nbucketsize)))
 SET stat = alterlist(t_record->order_qual,ntotal)
 FOR (j = (nsize+ 1) TO ntotal)
   SET t_record->order_qual[j].order_id = t_record->order_qual[nsize].order_id
 ENDFOR
 IF (( $FACILITY=damour_cd))
  SELECT INTO "nl:"
   fin_nmbr = cnvtint(ea.alias)
   FROM (dummyt d  WITH seq = nbuckets),
    order_action oa,
    orders o,
    encntr_loc_hist elh,
    encntr_alias ea,
    person p,
    person p2
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
    JOIN (o
    WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),o.order_id,t_record->order_qual[indx].
     order_id))
    JOIN (oa
    WHERE oa.order_id=o.order_id
     AND oa.action_dt_tm >= cnvtdatetime(t_record->beg_dt_tm)
     AND oa.action_dt_tm <= cnvtdatetime(t_record->end_dt_tm))
    JOIN (elh
    WHERE elh.encntr_id=o.encntr_id
     AND elh.beg_effective_dt_tm <= oa.action_dt_tm
     AND elh.end_effective_dt_tm >= oa.action_dt_tm)
    JOIN (ea
    WHERE ea.encntr_id=o.encntr_id
     AND ea.encntr_alias_type_cd=fin_cd
     AND ea.active_ind=1)
    JOIN (p
    WHERE p.person_id=o.person_id
     AND p.active_ind=1)
    JOIN (p2
    WHERE p2.person_id=oa.order_provider_id
     AND p2.active_ind=1)
   ORDER BY p.name_full_formatted, o.order_mnemonic, oa.action_dt_tm,
    o.order_id
   HEAD p.name_full_formatted
    null
   HEAD oa.clinical_display_line
    null
   HEAD o.order_id
    t_record->admn_cnt += 1
    IF (mod(t_record->admn_cnt,100)=1)
     stat = alterlist(t_record->admn_qual,(t_record->admn_cnt+ 99))
    ENDIF
    idx = t_record->admn_cnt, t_record->admn_qual[idx].f_order_id = o.order_id, t_record->admn_qual[
    idx].name = p.name_full_formatted,
    t_record->admn_qual[idx].fin = trim(ea.alias), t_record->admn_qual[idx].age = trim(cnvtage(
      cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1))), t_record->admn_qual[idx].unit =
    uar_get_code_display(elh.loc_nurse_unit_cd),
    t_record->admn_qual[idx].facility = uar_get_code_display(elh.loc_facility_cd), t_record->
    admn_qual[idx].mnemonic = o.order_mnemonic, t_record->admn_qual[idx].display = trim(oa
     .clinical_display_line),
    t_record->admn_qual[idx].provider = trim(p2.name_full_formatted), t_record->admn_qual[idx].
    admn_dt_tm = cnvtdatetime(oa.action_dt_tm)
   FOOT REPORT
    stat = alterlist(t_record->admn_qual,t_record->admn_cnt)
   WITH orahint("index(oa XPKORDER_ACTION)")
  ;end select
 ELSE
  SELECT INTO "nl:"
   fin_nmbr = cnvtint(ea.alias)
   FROM (dummyt d  WITH seq = nbuckets),
    order_action oa,
    orders o,
    encntr_loc_hist elh,
    encntr_alias ea,
    person p,
    person p2
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
    JOIN (o
    WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),o.order_id,t_record->order_qual[indx].
     order_id))
    JOIN (oa
    WHERE oa.order_id=o.order_id
     AND oa.action_dt_tm >= cnvtdatetime(t_record->beg_dt_tm)
     AND oa.action_dt_tm <= cnvtdatetime(t_record->end_dt_tm))
    JOIN (elh
    WHERE elh.encntr_id=o.encntr_id
     AND parser(n_line)
     AND elh.beg_effective_dt_tm <= oa.action_dt_tm
     AND elh.end_effective_dt_tm >= oa.action_dt_tm)
    JOIN (ea
    WHERE ea.encntr_id=o.encntr_id
     AND ea.encntr_alias_type_cd=fin_cd
     AND ea.active_ind=1)
    JOIN (p
    WHERE p.person_id=o.person_id
     AND p.active_ind=1)
    JOIN (p2
    WHERE p2.person_id=oa.order_provider_id
     AND p2.active_ind=1)
   ORDER BY p.name_full_formatted, o.order_mnemonic, oa.action_dt_tm,
    o.order_id
   HEAD p.name_full_formatted
    null
   HEAD oa.clinical_display_line
    null
   HEAD o.order_id
    t_record->admn_cnt += 1
    IF (mod(t_record->admn_cnt,100)=1)
     stat = alterlist(t_record->admn_qual,(t_record->admn_cnt+ 99))
    ENDIF
    idx = t_record->admn_cnt, t_record->admn_qual[idx].f_order_id = o.order_id, t_record->admn_qual[
    idx].name = p.name_full_formatted,
    t_record->admn_qual[idx].fin = trim(ea.alias), t_record->admn_qual[idx].age = trim(cnvtage(
      cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1))), t_record->admn_qual[idx].unit =
    uar_get_code_display(elh.loc_nurse_unit_cd),
    t_record->admn_qual[idx].facility = uar_get_code_display(elh.loc_facility_cd), t_record->
    admn_qual[idx].mnemonic = o.order_mnemonic, t_record->admn_qual[idx].display = trim(oa
     .clinical_display_line),
    t_record->admn_qual[idx].provider = trim(p2.name_full_formatted), t_record->admn_qual[idx].
    admn_dt_tm = cnvtdatetime(oa.action_dt_tm)
   FOOT REPORT
    stat = alterlist(t_record->admn_qual,t_record->admn_cnt)
   WITH orahint("index(oa XPKORDER_ACTION)")
  ;end select
 ENDIF
 IF (size(t_record->admn_qual,5)=0)
  CALL echo(n_line)
  CALL echo("no records found")
  GO TO exit_script
 ENDIF
 CALL echo("get dose and freq")
 CALL echo(build2(size(t_record->admn_qual,5)))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(t_record->admn_qual,5))),
   order_detail od
  PLAN (d)
   JOIN (od
   WHERE (od.order_id=t_record->admn_qual[d.seq].f_order_id)
    AND od.oe_field_id IN (mf_dose_cd, mf_freq_cd, mf_dose_unit_cd))
  ORDER BY od.order_id
  DETAIL
   IF (od.oe_field_id=mf_dose_cd)
    t_record->admn_qual[d.seq].s_dose = trim(od.oe_field_display_value)
   ELSEIF (od.oe_field_id=mf_dose_unit_cd)
    t_record->admn_qual[d.seq].s_dose_unit = trim(od.oe_field_display_value)
   ELSEIF (od.oe_field_id=mf_freq_cd)
    t_record->admn_qual[d.seq].s_freq = trim(od.oe_field_display_value)
   ENDIF
  FOOT  od.order_id
   t_record->admn_qual[d.seq].s_dose = concat(t_record->admn_qual[d.seq].s_dose," ",t_record->
    admn_qual[d.seq].s_dose_unit)
  WITH nocounter
 ;end select
 CALL echo("@@@@")
 CALL echo(size(t_record->admn_qual,5))
 IF (email_ind=0)
  SELECT INTO  $OUTDEV
   orderid = trim(cnvtstring(t_record->admn_qual[d.seq].f_order_id)), patient = trim(substring(1,100,
     t_record->admn_qual[d.seq].name)), fin = trim(substring(1,12,t_record->admn_qual[d.seq].fin)),
   age = trim(substring(1,10,t_record->admn_qual[d.seq].age)), nurse_unit = trim(substring(1,100,
     t_record->admn_qual[d.seq].unit)), facility = trim(substring(1,100,t_record->admn_qual[d.seq].
     facility)),
   dose = trim(substring(1,100,t_record->admn_qual[d.seq].s_dose)), frequency = trim(substring(1,100,
     t_record->admn_qual[d.seq].s_freq)), clinical_display_line = trim(substring(1,200,concat(
      t_record->admn_qual[d.seq].mnemonic," ",t_record->admn_qual[d.seq].display))),
   ordering_provider = trim(substring(1,100,t_record->admn_qual[d.seq].provider)),
   administration_date_time = trim(substring(1,100,format(t_record->admn_qual[d.seq].admn_dt_tm,
      "DD-MMM-YYYY HH:MM;;Q")))
   FROM (dummyt d  WITH seq = t_record->admn_cnt)
   PLAN (d)
   ORDER BY patient, clinical_display_line, administration_date_time
   WITH nocounter, format
  ;end select
 ELSE
  SELECT INTO "pharm_admin_hist.xls"
   patient = t_record->admn_qual[d.seq].name, fin = t_record->admn_qual[d.seq].fin, age = t_record->
   admn_qual[d.seq].age,
   dose = trim(t_record->admn_qual[d.seq].s_dose), frequency = trim(t_record->admn_qual[d.seq].s_freq
    ), clinical_display_line = concat(t_record->admn_qual[d.seq].mnemonic," ",t_record->admn_qual[d
    .seq].display),
   administration_date_time = format(t_record->admn_qual[d.seq].admn_dt_tm,"DD-MMM-YYYY HH:MM;;Q")
   FROM (dummyt d  WITH seq = t_record->admn_cnt)
   PLAN (d)
   ORDER BY patient, clinical_display_line, administration_date_time
   HEAD REPORT
    t_line = "Pharmacy Admin History", col 0, t_line,
    row + 1, t_line = trim(m_display), col 0,
    t_line, row + 1, t_line = uar_get_code_display( $FACILITY),
    col 0, t_line, row + 1,
    t_line = trim(n_display), col 0, t_line,
    row + 1, t_line = concat(format(t_record->beg_dt_tm,"DD-MMM-YYYY HH:MM;;Q")," to ",format(
      t_record->end_dt_tm,"DD-MMM-YYYY HH:MM;;Q")), col 0,
    t_line, row + 1, t_line = concat("Patient",char(9),"FIN",char(9),"Age",
     char(9),"Unit",char(9),"Facility",char(9),
     "Clinical_Display_Line",char(9),"Ordering_Provider",char(9),"Administration_Date_Time",
     char(9)),
    col 0, t_line, row + 1
   DETAIL
    t_line = concat(t_record->admn_qual[d.seq].name,char(9),t_record->admn_qual[d.seq].fin,char(9),
     t_record->admn_qual[d.seq].age,
     char(9),t_record->admn_qual[d.seq].unit,char(9),t_record->admn_qual[d.seq].facility,char(9),
     t_record->admn_qual[d.seq].mnemonic," ",t_record->admn_qual[d.seq].display,char(9),t_record->
     admn_qual[d.seq].provider,
     char(9),format(t_record->admn_qual[d.seq].admn_dt_tm,"DD-MMM-YYYY HH:MM;;Q"),char(9)), col 0,
    t_line,
    row + 1
   WITH nocounter, maxcol = 1000, formfeed = none
  ;end select
  DECLARE len = i4
  DECLARE subject_line = vc
  DECLARE dclcom = vc
  IF (findfile("pharm_admin_hist.xls")=1)
   SET subject_line = concat("Pharmacy Admin History ",format(t_record->beg_dt_tm,
     "DD-MMM-YYYY HH:MM;;Q")," to ",format(t_record->end_dt_tm,"DD-MMM-YYYY HH:MM;;Q"))
   SET dclcom = concat("(uuencode pharm_admin_hist.xls pharm_admin_hist.xls;) "," | mailx -s ",'"',
    subject_line,'" ',
    email_list)
   SET len = size(trim(dclcom))
   SET status = 0
   SET stat = dcl(dclcom,len,status)
   SET stat = remove("pharm_admin_hist.xls")
  ENDIF
 ENDIF
#exit_script
 CALL echorecord(t_record)
 FREE RECORD t_record
END GO
