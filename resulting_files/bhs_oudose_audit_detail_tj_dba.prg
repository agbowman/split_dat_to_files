CREATE PROGRAM bhs_oudose_audit_detail_tj:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Starting date:" = "CURDATE",
  "Ending date:" = "CURDATE",
  "Facility:" = 0,
  "Nurse unit(s):" = 0,
  "Display per:" = 2
  WITH outdev, start_date, end_date,
  facility, nurse_unit, display_type
 FREE RECORD audit_request
 RECORD audit_request(
   1 report_name = vc
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
   1 facility_cd = f8
   1 unit_cnt = i4
   1 unit[*]
     2 nurse_unit_cd = f8
   1 display_ind = i2
 )
 FREE RECORD events_reply
 RECORD events_reply(
   1 administrations = i4
   1 not_done = i4
   1 total = i4
 )
 FREE RECORD parent_order
 RECORD parent_order(
   1 dupl_cnt = i4
   1 total_orders_cnt = i4
   1 qual[*]
     2 order_id = f8
     2 template_order_id = f8
     2 action_seq = i4
     2 ordered_qual = i4
 )
 FREE RECORD ordered_ingrdnts
 RECORD ordered_ingrdnts(
   1 tot_par_order_cnt = i4
   1 dupl_cnt = i4
   1 qual[*]
     2 template_order_id = f8
     2 action_seq = i4
     2 dupl_ingr = i4
     2 dupl_cnt = i4
     2 total_ingr_cnt = i4
     2 ingr_qual[*]
       3 synonym_id = f8
       3 ordered_dose = c60
       3 catalog_disp = c60
       3 syn_mne = c60
 )
 FREE RECORD parent_admined
 RECORD parent_admined(
   1 dupl_cnt = i4
   1 total_ingr_cnt = i4
   1 qual[*]
     2 total_cnt = i4
     2 dupl_cnt = i4
     2 mame_id = f8
     2 ingr_qual[*]
       3 synonym_id = f8
       3 catalog_disp = c60
       3 dose_admin = c60
       3 syn_mne = c60
 )
 FREE RECORD audit_reply
 RECORD audit_reply(
   1 summary_qual_cnt = i4
   1 cancelled_cnt = i4
   1 continued_cnt = i4
   1 summary_qual[*]
     2 alert_type = c35
     2 date = vc
     2 patient = c60
     2 location = c60
     2 fin = c60
     2 med_ident = i4
     2 medication = c60
     2 user = c60
     2 order_id = f8
     2 event_id = f8
     2 encounter_id = f8
     2 alert_id = f8
     2 mame_id = f8
     2 admined_qual[*]
       3 synonym_id = f8
       3 syn_mne = vc
       3 dose_admin = vc
     2 ordered_qual[*]
       3 synonym_id = f8
       3 ordered_dose = vc
       3 syn_mne = vc
 )
 DECLARE ctitle = vc WITH protect, constant("Point of Care Audit Over/Underdose Report")
 DECLARE cdashline = vc WITH protect, constant(fillstring(131,"-"))
 DECLARE ctotal_line = vc WITH protect, constant(fillstring(130,"-"))
 DECLARE last_row = c20 WITH protect, noconstant("00000000000000000000")
 DECLARE last_mod = vc WITH protect, noconstant("")
 DECLARE mod_date = vc WITH protect, noconstant("")
 DECLARE smed_ident = vc WITH protect, noconstant("")
 DECLARE soutcome = vc WITH protect, noconstant("")
 DECLARE sdisplay = vc WITH protect, noconstant("")
 DECLARE snurse_units = vc WITH protect, noconstant("")
 DECLARE lcontinued = i4 WITH protect, noconstant(0)
 DECLARE lingr_cnt = i4 WITH protect, noconstant(0)
 DECLARE lingr_cnt2 = i4 WITH protect, noconstant(0)
 DECLARE lpos = i4 WITH protect, noconstant(0)
 DECLARE lpos2 = i4 WITH protect, noconstant(0)
 DECLARE lnum = i4 WITH protect, noconstant(0)
 DECLARE lnum2 = i4 WITH protect, noconstant(0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE lidx2 = i4 WITH protect, noconstant(0)
 DECLARE lidx3 = i4 WITH protect, noconstant(0)
 DECLARE lidx4 = i4 WITH protect, noconstant(0)
 DECLARE lcancelledcnt = i4 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lcnt2 = i4 WITH protect, noconstant(0)
 DECLARE nallind = i2 WITH protect, noconstant(0)
 DECLARE dlastid = f8 WITH protect, noconstant(0.00)
 DECLARE dlastid2 = f8 WITH protect, noconstant(0.00)
 DECLARE dstat = f8 WITH protect, noconstant(0.00)
 DECLARE s_nd_result_cd = f8 WITH protect, noconstant(uar_get_code_by("meaning",8,"NOT DONE"))
 DECLARE s_auth_result_cd = f8 WITH protect, noconstant(uar_get_code_by("meaning",8,"AUTH"))
 DECLARE fin_nbr_cd = f8 WITH protect, noconstant(uar_get_code_by("meaning",319,"FIN NBR"))
 DECLARE overdose_cd = f8 WITH protect, noconstant(uar_get_code_by("meaning",4000040,"OVERDOSE"))
 DECLARE underdose_cd = f8 WITH protect, noconstant(uar_get_code_by("meaning",4000040,"UNDERDOSE"))
 DECLARE any_status_ind = c1
 DECLARE indx = i4
 DECLARE nsize = i4
 DECLARE nbucketsize = i4
 DECLARE ntotal = i4
 DECLARE nstart = i4
 DECLARE nbuckets = i4
 SET audit_request->report_name = "BSC_EARLYLATE_AUDIT_DETAIL"
 SET audit_request->facility_cd =  $FACILITY
 SET audit_request->display_ind =  $DISPLAY_TYPE
 IF (( $START_DATE="curdate"))
  SET audit_request->start_dt_tm = cnvtdatetime(curdate,0)
 ELSE
  SET audit_request->start_dt_tm = cnvtdatetime(cnvtdate(cnvtalphanum( $START_DATE)),0)
 ENDIF
 IF (( $END_DATE="curdate"))
  SET audit_request->end_dt_tm = cnvtdatetime(curdate,235959)
 ELSE
  SET audit_request->end_dt_tm = cnvtdatetime(cnvtdate(cnvtalphanum( $END_DATE)),235959)
 ENDIF
 SET any_status_ind = substring(1,1,reflect(parameter(5,0)))
 IF (any_status_ind="C")
  SET nallind = 1
  SELECT INTO "nl:"
   FROM code_value cv,
    nurse_unit n,
    code_value cv1,
    code_value cv2
   PLAN (cv
    WHERE cv.code_set=220
     AND cv.cdf_meaning="BUILDING"
     AND cv.display_key IN ("BFMC", "BFMCINPTPSYCH", "BMLH", "BMC", "BMCINPTPSYCH",
    "BWH", "BWHINPTPSYCH", "BNH", "BNHINPTPSYCH")
     AND cv.active_ind=1)
    JOIN (n
    WHERE (n.loc_facility_cd=audit_request->facility_cd)
     AND n.loc_building_cd=cv.code_value
     AND n.active_ind=1)
    JOIN (cv1
    WHERE cv1.code_value=n.location_cd
     AND cv1.code_set=220
     AND cv1.active_ind=1
     AND cv1.cdf_meaning="NURSEUNIT")
    JOIN (cv2
    WHERE cv2.code_value=cv1.data_status_cd
     AND cv2.display_key="AUTHVERIFIED")
   ORDER BY cv1.display
   HEAD REPORT
    lcnt = 0
   DETAIL
    lcnt = (lcnt+ 1)
    IF (mod(lcnt,10)=1)
     dstat = alterlist(audit_request->unit,(lcnt+ 9))
    ENDIF
    audit_request->unit[lcnt].nurse_unit_cd = cv1.code_value
   FOOT REPORT
    dstat = alterlist(audit_request->unit,lcnt), audit_request->unit_cnt = lcnt
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE (cv.code_value= $NURSE_UNIT))
   ORDER BY cv.display
   HEAD REPORT
    lcnt = 0
   DETAIL
    lcnt = (lcnt+ 1)
    IF (mod(lcnt,10)=1)
     dstat = alterlist(audit_request->unit,(lcnt+ 9))
    ENDIF
    audit_request->unit[lcnt].nurse_unit_cd = cv.code_value
   FOOT REPORT
    dstat = alterlist(audit_request->unit,lcnt), audit_request->unit_cnt = lcnt
   WITH nocounter
  ;end select
 ENDIF
 SET nsize = audit_request->unit_cnt
 SET nbucketsize = 20
 SET ntotal = (ceil((cnvtreal(nsize)/ nbucketsize)) * nbucketsize)
 SET nstart = 1
 SET nbuckets = value((1+ ((ntotal - 1)/ nbucketsize)))
 SET stat = alterlist(audit_request->unit,ntotal)
 FOR (j = (nsize+ 1) TO ntotal)
   SET audit_request->unit[j].nurse_unit_cd = audit_request->unit[nsize].nurse_unit_cd
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   med_admin_event mae,
   clinical_event ce
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (mae
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),mae.nurse_unit_cd,audit_request->unit[indx].
    nurse_unit_cd)
    AND mae.updt_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
    audit_request->end_dt_tm))
   JOIN (ce
   WHERE ce.event_id=mae.event_id
    AND ce.result_status_cd IN (s_nd_result_cd, s_auth_result_cd))
  HEAD REPORT
   events_reply->administrations = 0, events_reply->not_done = 0, events_reply->total = 0,
   lidx = 0
  DETAIL
   lidx = (lidx+ 1)
   IF (ce.result_status_cd=s_nd_result_cd)
    events_reply->not_done = (events_reply->not_done+ 1)
   ELSE
    events_reply->administrations = (events_reply->administrations+ 1)
   ENDIF
  FOOT REPORT
   events_reply->total = lidx
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   med_admin_alert maa,
   med_admin_med_error mame,
   orders o
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (maa
   WHERE maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
    audit_request->end_dt_tm)
    AND maa.alert_type_cd IN (overdose_cd, underdose_cd)
    AND expand(indx,nstart,(nstart+ (nbucketsize - 1)),maa.nurse_unit_cd,audit_request->unit[indx].
    nurse_unit_cd))
   JOIN (mame
   WHERE mame.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
   JOIN (o
   WHERE o.order_id=mame.order_id)
  ORDER BY o.order_id
  HEAD REPORT
   dlastid = 0.00, parent_order->dupl_cnt = 0, parent_order->total_orders_cnt = 0,
   lidx = 0, lidx2 = 0, dstat = alterlist(parent_order->qual,10),
   parent_order->qual[1].action_seq = 0, parent_order->qual[1].order_id = 0.00, parent_order->qual[1]
   .template_order_id = 0.00
  DETAIL
   IF (dlastid=o.order_id)
    parent_order->dupl_cnt = (parent_order->dupl_cnt+ 1)
   ELSE
    dlastid = o.order_id, lidx = (lidx+ 1), lidx2 = (lidx2+ 1)
    IF (lidx2=10)
     dstat = alterlist(parent_order->qual,(lidx+ 11)), lidx2 = 0
    ENDIF
    parent_order->qual[lidx].order_id = o.order_id
    IF (o.template_order_id=0.00)
     parent_order->qual[lidx].template_order_id = o.order_id
    ELSE
     parent_order->qual[lidx].template_order_id = o.template_order_id
    ENDIF
    parent_order->qual[lidx].action_seq = mame.action_sequence
   ENDIF
  FOOT REPORT
   dstat = alterlist(parent_order->qual,lidx), parent_order->total_orders_cnt = lidx
  WITH maxcol = 1000
 ;end select
 IF (value(size(parent_order->qual,5)) > 0)
  SELECT INTO "nl:"
   template_order_id = parent_order->qual[d.seq].template_order_id
   FROM (dummyt d  WITH seq = value(size(parent_order->qual,5)))
   ORDER BY template_order_id
   HEAD REPORT
    dstat = alterlist(ordered_ingrdnts->qual,10), lidx = 0
   HEAD template_order_id
    lidx = (lidx+ 1)
    IF (mod(lidx,10)=0)
     dstat = alterlist(ordered_ingrdnts->qual,(lidx+ 10))
    ENDIF
    ordered_ingrdnts->qual[lidx].template_order_id = template_order_id, ordered_ingrdnts->qual[lidx].
    action_seq = parent_order->qual[d.seq].action_seq
   DETAIL
    ordered_ingrdnts->dupl_cnt = (ordered_ingrdnts->dupl_cnt+ 1), ordered_ingrdnts->qual[lidx].
    dupl_cnt = (ordered_ingrdnts->qual[lidx].dupl_cnt+ 1), parent_order->qual[d.seq].ordered_qual =
    lidx
   FOOT  template_order_id
    null
   FOOT REPORT
    dstat = alterlist(ordered_ingrdnts->qual,lidx), ordered_ingrdnts->tot_par_order_cnt = lidx
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM order_ingredient oi,
   order_catalog_synonym ocs
  PLAN (oi
   WHERE expand(lidx,1,size(ordered_ingrdnts->qual,5),oi.order_id,ordered_ingrdnts->qual[lidx].
    template_order_id)
    AND (oi.action_sequence=ordered_ingrdnts->qual[lidx].action_seq))
   JOIN (ocs
   WHERE ocs.synonym_id=outerjoin(oi.synonym_id))
  ORDER BY oi.order_id, oi.synonym_id, cnvtdatetime(oi.updt_dt_tm)
  HEAD oi.order_id
   dlastid = - (1.00), ordered_ingrdnts->qual[lidx].dupl_cnt = 0, lidx2 = 0,
   lidx3 = 0, lnum = 0, lidx4 = locateval(lnum,1,ordered_ingrdnts->tot_par_order_cnt,oi.order_id,
    ordered_ingrdnts->qual[lnum].template_order_id),
   dstat = alterlist(ordered_ingrdnts->qual[lidx4].ingr_qual,10)
  DETAIL
   IF (dlastid=oi.synonym_id)
    ordered_ingrdnts->qual[lidx4].dupl_ingr = (ordered_ingrdnts->qual[lidx4].dupl_ingr+ 1)
   ELSE
    dlastid = oi.synonym_id, lidx2 = (lidx2+ 1), lidx3 = (lidx3+ 1)
    IF (lidx3=10)
     dstat = alterlist(ordered_ingrdnts->qual[lidx4].ingr_qual,(lidx2+ 11)), lidx3 = 0
    ENDIF
    ordered_ingrdnts->qual[lidx4].ingr_qual[lidx2].synonym_id = oi.synonym_id, ordered_ingrdnts->
    qual[lidx4].ingr_qual[lidx2].syn_mne = ocs.mnemonic, ordered_ingrdnts->qual[lidx4].ingr_qual[
    lidx2].catalog_disp = uar_get_code_display(oi.catalog_cd)
    IF (oi.strength_unit > 0.00)
     IF (oi.volume_unit > 0.00)
      ordered_ingrdnts->qual[lidx4].ingr_qual[lidx2].ordered_dose = concat(trim(cnvtstring(oi
         .strength))," ",trim(uar_get_code_display(oi.strength_unit)),";",trim(cnvtstring(oi.volume)),
       " ",trim(uar_get_code_display(oi.volume_unit)))
     ELSE
      ordered_ingrdnts->qual[lidx4].ingr_qual[lidx2].ordered_dose = concat(trim(cnvtstring(oi
         .strength))," ",trim(uar_get_code_display(oi.strength_unit)))
     ENDIF
    ELSEIF (oi.volume_unit > 0.00)
     ordered_ingrdnts->qual[lidx4].ingr_qual[lidx2].ordered_dose = concat(trim(cnvtstring(oi.volume)),
      " ",trim(uar_get_code_display(oi.volume_unit)))
    ELSE
     ordered_ingrdnts->qual[lidx4].ingr_qual[lidx2].ordered_dose = oi.freetext_dose
    ENDIF
   ENDIF
  FOOT  oi.order_id
   dstat = alterlist(ordered_ingrdnts->qual[lidx4].ingr_qual,lidx2), ordered_ingrdnts->qual[lidx4].
   total_ingr_cnt = lidx2
  WITH orahint("index(oi XPKORDER_INDGREDIENT)")
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   med_admin_alert maa,
   med_admin_med_error mame,
   med_admin_med_event_ingrdnt mamei,
   order_catalog_synonym ocs
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (maa
   WHERE maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
    audit_request->end_dt_tm)
    AND maa.alert_type_cd IN (overdose_cd, underdose_cd)
    AND expand(indx,nstart,(nstart+ (nbucketsize - 1)),(maa.nurse_unit_cd+ 0),audit_request->unit[
    indx].nurse_unit_cd))
   JOIN (mame
   WHERE mame.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
   JOIN (mamei
   WHERE mamei.parent_entity_id=outerjoin(mame.med_admin_med_error_id))
   JOIN (ocs
   WHERE ocs.synonym_id=outerjoin(mamei.synonym_id))
  ORDER BY mame.med_admin_med_error_id, mamei.parent_entity_id, mamei.synonym_id,
   cnvtdatetime(mamei.updt_dt_tm)
  HEAD REPORT
   dlastid = - (1.00), parent_admined->dupl_cnt = 0, parent_admined->total_ingr_cnt = 1,
   lidx = 0, lidx3 = 1, lidx4 = 1,
   dstat = alterlist(parent_admined->qual,10), parent_admined->qual[1].total_cnt = 0, parent_admined
   ->qual[1].mame_id = 0.00
  DETAIL
   IF (mame.med_admin_med_error_id > 0)
    IF (dlastid != mame.med_admin_med_error_id)
     dlastid = mame.med_admin_med_error_id, lidx3 = (lidx3+ 1), lidx4 = (lidx4+ 1)
     IF (lidx4=10)
      dstat = alterlist(parent_admined->qual,(lidx3+ 11)), lidx4 = 0
     ENDIF
     parent_admined->qual[lidx3].mame_id = mame.med_admin_med_error_id, parent_admined->qual[lidx3].
     total_cnt = 0, parent_admined->qual[lidx3].dupl_cnt = 0,
     lidx = 0, lidx2 = 0, dlastid2 = - (1.00)
    ENDIF
    IF (mamei.parent_entity_id > 0)
     IF (dlastid2=mamei.synonym_id
      AND (parent_admined->qual[lidx3].total_cnt > 0))
      parent_admined->qual[lidx3].dupl_cnt = (parent_admined->qual[lidx3].dupl_cnt+ 1)
     ELSE
      parent_admined->qual[lidx3].total_cnt = (parent_admined->qual[lidx3].total_cnt+ 1), dlastid2 =
      mamei.synonym_id, lidx = (lidx+ 1),
      dstat = alterlist(parent_admined->qual[lidx3].ingr_qual,lidx), parent_admined->qual[lidx3].
      ingr_qual[lidx].synonym_id = mamei.synonym_id, parent_admined->qual[lidx3].ingr_qual[lidx].
      syn_mne = ocs.mnemonic,
      parent_admined->qual[lidx3].ingr_qual[lidx].catalog_disp = uar_get_code_display(mamei
       .catalog_cd)
      IF (mamei.strength_unit_cd > 0.00)
       IF (mamei.volume_unit_cd > 0.00)
        parent_admined->qual[lidx3].ingr_qual[lidx].dose_admin = concat(trim(cnvtstring(mamei
           .strength))," ",trim(uar_get_code_display(mamei.strength_unit_cd)),";",trim(cnvtstring(
           mamei.volume)),
         " ",trim(uar_get_code_display(mamei.volume_unit_cd)))
       ELSE
        parent_admined->qual[lidx3].ingr_qual[lidx].dose_admin = concat(trim(cnvtstring(mamei
           .strength))," ",trim(uar_get_code_display(mamei.strength_unit_cd)))
       ENDIF
      ELSEIF (mamei.volume_unit_cd > 0.00)
       parent_admined->qual[lidx3].ingr_qual[lidx].dose_admin = concat(trim(cnvtstring(mamei.volume)),
        " ",trim(uar_get_code_display(mamei.volume_unit_cd)))
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   dstat = alterlist(parent_admined->qual,lidx3), parent_admined->total_ingr_cnt = lidx3
  WITH maxcol = 1000
 ;end select
 IF ((audit_request->display_ind=1))
  SELECT INTO  $OUTDEV
   unit = uar_get_code_display(maa.nurse_unit_cd)
   FROM (dummyt d  WITH seq = nbuckets),
    med_admin_alert maa,
    prsnl p1,
    med_admin_med_error mame,
    person p2,
    encntr_alias ea,
    med_admin_event mae
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
    JOIN (maa
    WHERE maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
     audit_request->end_dt_tm)
     AND maa.alert_type_cd IN (overdose_cd, underdose_cd)
     AND expand(indx,nstart,(nstart+ (nbucketsize - 1)),(maa.nurse_unit_cd+ 0),audit_request->unit[
     indx].nurse_unit_cd))
    JOIN (p1
    WHERE p1.person_id=outerjoin(maa.prsnl_id))
    JOIN (mame
    WHERE mame.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
    JOIN (p2
    WHERE p2.person_id=outerjoin(mame.person_id))
    JOIN (ea
    WHERE ea.encntr_id=outerjoin(mame.encounter_id)
     AND ea.encntr_alias_type_cd=outerjoin(fin_nbr_cd))
    JOIN (mae
    WHERE mae.event_id=outerjoin(mame.event_id)
     AND mae.event_id > outerjoin(0.00))
   ORDER BY maa.alert_type_cd, p2.name_full_formatted, p2.person_id,
    unit, maa.event_dt_tm
   HEAD REPORT
    last_row = "00000000000000000000", lcancelledcnt = 0, lidx = 0,
    lidx2 = 0, lidx3 = 0, lidx4 = 0,
    dstat = alterlist(audit_reply->summary_qual,10)
   HEAD PAGE
    IF ( NOT (( $OUTDEV IN ("MINE"))))
     col 0, "{ps/792 0 translate 90 rotate/}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1
    ENDIF
    col 0, "Date Range: ", sdisplay = ""
    IF ((audit_request->start_dt_tm > 0))
     sdisplay = format(audit_request->start_dt_tm,"mm/dd/yyyy;;d")
    ENDIF
    IF ((audit_request->end_dt_tm > 0))
     sdisplay = build2(sdisplay," - ",format(audit_request->end_dt_tm,"mm/dd/yyyy;;d"))
    ENDIF
    IF (textlen(sdisplay) > 0)
     col 12, sdisplay
    ENDIF
    col 122, "Page:", col + 1,
    CALL print(trim(cnvtstring(curpage))), row + 1, sdisplay = concat("Facility: ",trim(
      uar_get_code_display(audit_request->facility_cd),3)),
    col 0, sdisplay, col 96,
    "Run Date: ", curdate"mm/dd/yyyy;;d", " Time: ",
    curtime"hh:mm;;s", row + 1, sdisplay = ""
    IF (nallind=1)
     sdisplay = "Nurse Units: All"
    ELSEIF ((audit_request->unit_cnt > 1))
     sdisplay = concat("Nurse Units: ",trim(uar_get_code_display(audit_request->unit[1].nurse_unit_cd
        ),3))
     FOR (lcnt = 2 TO audit_request->unit_cnt)
       sdisplay = concat(sdisplay,", ",trim(uar_get_code_display(audit_request->unit[lcnt].
          nurse_unit_cd),3))
     ENDFOR
    ELSEIF ((audit_request->unit_cnt=1))
     sdisplay = concat("Nurse Unit: ",trim(uar_get_code_display(audit_request->unit[1].nurse_unit_cd),
       3))
    ELSE
     sdisplay = "Nurse Unit: Unknown/Error"
    ENDIF
    col 0, sdisplay
    IF (nallind=0
     AND (audit_request->unit_cnt > 1))
     row + 1
    ENDIF
    CALL center(ctitle,1,131), col 111, "Display per: Patient",
    row + 1, col 0, cdashline,
    row + 1, col 50, "Ordered Med/",
    col 95, "Ordered Dose/", row + 1,
    col 0, "Date/Time", col 15,
    "Loc", col 25, "FIN",
    col 40, "Method", col 50,
    "Scanned Med", col 95, "Scanned Dose",
    col 115, "User", row + 1,
    col 0, ctotal_line, row + 1
   HEAD maa.alert_type_cd
    IF (maa.alert_type_cd=overdose_cd)
     col 0, "Overdose"
    ELSE
     col 0, "Underdose"
    ENDIF
    row + 1, col 0, cdashline,
    row + 1
   HEAD p2.name_full_formatted
    IF (row >= 46)
     BREAK
    ENDIF
    col 0, p2.name_full_formatted, row + 1
   DETAIL
    IF (row=47)
     BREAK
    ENDIF
    IF (last_row != maa.rowid)
     last_row = maa.rowid, lidx = (lidx+ 1), lidx2 = (lidx2+ 1)
     IF (lidx2=10)
      dstat = alterlist(audit_reply->summary_qual,(lidx+ 10)), lidx2 = 0
     ENDIF
     audit_reply->summary_qual[lidx].date = format(maa.event_dt_tm,"mm/dd/yy hh:mm"), audit_reply->
     summary_qual[lidx].fin = cnvtalias(ea.alias,ea.alias_pool_cd)
     IF (mae.positive_med_ident_ind=0)
      smed_ident = "Select"
     ELSE
      smed_ident = "Scan"
     ENDIF
     IF (mame.event_id=0.00)
      soutcome = "Cancelled"
     ELSE
      soutcome = "Administered"
     ENDIF
     lpos = locateval(lnum,1,parent_admined->total_ingr_cnt,mame.med_admin_med_error_id,
      parent_admined->qual[lnum].mame_id), lpos2 = locateval(lnum2,1,parent_order->total_orders_cnt,
      mame.order_id,parent_order->qual[lnum2].order_id), lpos2 = parent_order->qual[lpos2].
     ordered_qual,
     lingr_cnt = parent_admined->qual[lpos].total_cnt, dstat = alterlist(audit_reply->summary_qual[
      lidx].admined_qual,lingr_cnt), lnum = 0
     WHILE (lnum < lingr_cnt)
       lnum = (lnum+ 1), audit_reply->summary_qual[lidx].admined_qual[lnum].synonym_id =
       parent_admined->qual[lpos].ingr_qual[lnum].synonym_id, audit_reply->summary_qual[lidx].
       admined_qual[lnum].syn_mne = parent_admined->qual[lpos].ingr_qual[lnum].syn_mne,
       audit_reply->summary_qual[lidx].admined_qual[lnum].dose_admin = parent_admined->qual[lpos].
       ingr_qual[lnum].dose_admin
     ENDWHILE
     lingr_cnt2 = ordered_ingrdnts->qual[lpos2].total_ingr_cnt, dstat = alterlist(audit_reply->
      summary_qual[lidx].ordered_qual,lingr_cnt2), lnum = 0
     WHILE (lnum < lingr_cnt2)
       lnum = (lnum+ 1), audit_reply->summary_qual[lidx].ordered_qual[lnum].synonym_id =
       ordered_ingrdnts->qual[lpos2].ingr_qual[lnum].synonym_id, audit_reply->summary_qual[lidx].
       ordered_qual[lnum].ordered_dose = ordered_ingrdnts->qual[lpos2].ingr_qual[lnum].ordered_dose,
       audit_reply->summary_qual[lidx].ordered_qual[lnum].syn_mne = ordered_ingrdnts->qual[lpos2].
       ingr_qual[lnum].syn_mne
     ENDWHILE
     lnum = 1, lnum2 = 0
     IF (row >= 48)
      BREAK
     ENDIF
     col 0, audit_reply->summary_qual[lidx].date, col 15,
     unit, col 25, audit_reply->summary_qual[lidx].fin,
     col 40, smed_ident
     FOR (i = 1 TO lnum)
       col 50,
       CALL print(substring(1,43,audit_reply->summary_qual[lidx].ordered_qual[lnum].syn_mne)), col 95,
       CALL print(substring(1,18,audit_reply->summary_qual[lidx].ordered_qual[lnum].ordered_dose)),
       col 115, soutcome,
       row + 1, col 50,
       CALL print(substring(1,43,audit_reply->summary_qual[lidx].admined_qual[lnum].syn_mne)),
       col 95,
       CALL print(substring(1,18,audit_reply->summary_qual[lidx].admined_qual[lnum].dose_admin)), col
        115,
       CALL print(substring(1,16,trim(p1.name_full_formatted))), row + 1
     ENDFOR
     row + 1
    ENDIF
   FOOT REPORT
    IF (row > 45)
     BREAK
    ENDIF
    audit_reply->summary_qual_cnt = lidx, audit_reply->cancelled_cnt = lcancelledcnt, dstat =
    alterlist(audit_reply->summary_qual,lidx),
    lcontinued = (lidx - lcancelledcnt), audit_reply->continued_cnt = lcontinued, row + 2,
    col 20, "Administrations", sdisplay = format(events_reply->administrations,"#########"),
    col 40, sdisplay, col 60,
    "Total Alerts", sdisplay = format(lidx,"#########"), col 80,
    sdisplay, row + 1, col 20,
    "Not Done", sdisplay = format(events_reply->not_done,"#########"), col 40,
    sdisplay, col 60, "Administered",
    sdisplay = format(lcontinued,"#########"), col 80, sdisplay,
    row + 1, col 20, "Total",
    sdisplay = format(events_reply->total,"#########"), col 40, sdisplay,
    col 60, "Cancelled", sdisplay = format(lcancelledcnt,"#########"),
    col 80, sdisplay, row + 1
   WITH dio = postscript, maxrow = 50
  ;end select
 ENDIF
 IF ((audit_request->display_ind=2))
  SELECT INTO  $OUTDEV
   unit = uar_get_code_display(maa.nurse_unit_cd), date = format(maa.event_dt_tm,"mm/dd/yy")
   FROM (dummyt d  WITH seq = nbuckets),
    med_admin_alert maa,
    prsnl p1,
    med_admin_med_error mame,
    person p2,
    encntr_alias ea,
    med_admin_event mae
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
    JOIN (maa
    WHERE maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
     audit_request->end_dt_tm)
     AND maa.alert_type_cd IN (overdose_cd, underdose_cd)
     AND expand(indx,nstart,(nstart+ (nbucketsize - 1)),(maa.nurse_unit_cd+ 0),audit_request->unit[
     indx].nurse_unit_cd))
    JOIN (p1
    WHERE p1.person_id=outerjoin(maa.prsnl_id))
    JOIN (mame
    WHERE mame.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
    JOIN (p2
    WHERE p2.person_id=outerjoin(mame.person_id))
    JOIN (ea
    WHERE ea.encntr_id=outerjoin(mame.encounter_id)
     AND ea.encntr_alias_type_cd=outerjoin(fin_nbr_cd))
    JOIN (mae
    WHERE mae.event_id=outerjoin(mame.event_id)
     AND mae.event_id > outerjoin(0.00))
   ORDER BY maa.alert_type_cd, date, p2.name_full_formatted,
    p2.person_id, maa.event_dt_tm, unit
   HEAD REPORT
    last_row = "00000000000000000000", lcancelledcnt = 0, lidx = 0,
    lidx2 = 0, lidx3 = 0, lidx4 = 0,
    dstat = alterlist(audit_reply->summary_qual,10)
   HEAD PAGE
    IF ( NOT (( $OUTDEV IN ("MINE"))))
     col 0, "{ps/792 0 translate 90 rotate/}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1
    ENDIF
    col 0, "Date Range: ", sdisplay = ""
    IF ((audit_request->start_dt_tm > 0))
     sdisplay = format(audit_request->start_dt_tm,"mm/dd/yyyy;;d")
    ENDIF
    IF ((audit_request->end_dt_tm > 0))
     sdisplay = build2(sdisplay," - ",format(audit_request->end_dt_tm,"mm/dd/yyyy;;d"))
    ENDIF
    IF (textlen(sdisplay) > 0)
     col 12, sdisplay
    ENDIF
    col 122, "Page:", col + 1,
    CALL print(trim(cnvtstring(curpage))), row + 1, sdisplay = concat("Facility: ",trim(
      uar_get_code_display(audit_request->facility_cd),3)),
    col 0, sdisplay, col 96,
    "Run Date: ", curdate"mm/dd/yyyy;;d", " Time: ",
    curtime"hh:mm;;s", row + 1, sdisplay = ""
    IF (nallind=1)
     sdisplay = "Nurse Units: All"
    ELSEIF ((audit_request->unit_cnt > 1))
     sdisplay = concat("Nurse Units: ",trim(uar_get_code_display(audit_request->unit[1].nurse_unit_cd
        ),3))
     FOR (lcnt = 2 TO audit_request->unit_cnt)
       sdisplay = concat(sdisplay,", ",trim(uar_get_code_display(audit_request->unit[lcnt].
          nurse_unit_cd),3))
     ENDFOR
    ELSEIF ((audit_request->unit_cnt=1))
     sdisplay = concat("Nurse Unit: ",trim(uar_get_code_display(audit_request->unit[1].nurse_unit_cd),
       3))
    ELSE
     sdisplay = "Nurse Unit: Unknown/Error"
    ENDIF
    col 0, sdisplay
    IF (nallind=0
     AND (audit_request->unit_cnt > 1))
     row + 1
    ENDIF
    CALL center(ctitle,1,131), col 111, "Display per: Date",
    row + 1, col 0, cdashline,
    row + 1, col 50, "Ordered Med/",
    col 95, "Ordered Dose/", row + 1,
    col 0, "Date/Time", col 15,
    "Loc", col 25, "FIN",
    col 40, "Method", col 50,
    "Scanned Med", col 95, "Scanned Dose",
    col 115, "User", row + 1,
    col 0, ctotal_line, row + 1
   HEAD maa.alert_type_cd
    IF (maa.alert_type_cd=overdose_cd)
     col 0, "Overdose"
    ELSE
     col 0, "Underdose"
    ENDIF
    row + 1, col 0, cdashline,
    row + 1
   HEAD date
    IF (row >= 46)
     BREAK
    ENDIF
    col 0, date, row + 1
   HEAD p2.name_full_formatted
    col 0, p2.name_full_formatted, row + 1
   DETAIL
    IF (row >= 47)
     BREAK
    ENDIF
    IF (last_row != maa.rowid)
     last_row = maa.rowid, lidx = (lidx+ 1), lidx2 = (lidx2+ 1)
     IF (lidx2=10)
      dstat = alterlist(audit_reply->summary_qual,(lidx+ 10)), lidx2 = 0
     ENDIF
     audit_reply->summary_qual[lidx].date = format(maa.event_dt_tm,"mm/dd/yy hh:mm"), audit_reply->
     summary_qual[lidx].fin = cnvtalias(ea.alias,ea.alias_pool_cd)
     IF (mae.positive_med_ident_ind=0)
      smed_ident = "Select"
     ELSE
      smed_ident = "Scan"
     ENDIF
     IF (mame.event_id=0.00)
      soutcome = "Cancelled"
     ELSE
      soutcome = "Administered"
     ENDIF
     lpos = locateval(lnum,1,parent_admined->total_ingr_cnt,mame.med_admin_med_error_id,
      parent_admined->qual[lnum].mame_id), lpos2 = locateval(lnum2,1,parent_order->total_orders_cnt,
      mame.order_id,parent_order->qual[lnum2].order_id), lpos2 = parent_order->qual[lpos2].
     ordered_qual,
     lingr_cnt = parent_admined->qual[lpos].total_cnt, dstat = alterlist(audit_reply->summary_qual[
      lidx].admined_qual,lingr_cnt), lnum = 0
     WHILE (lnum < lingr_cnt)
       lnum = (lnum+ 1), audit_reply->summary_qual[lidx].admined_qual[lnum].synonym_id =
       parent_admined->qual[lpos].ingr_qual[lnum].synonym_id, audit_reply->summary_qual[lidx].
       admined_qual[lnum].syn_mne = parent_admined->qual[lpos].ingr_qual[lnum].syn_mne,
       audit_reply->summary_qual[lidx].admined_qual[lnum].dose_admin = parent_admined->qual[lpos].
       ingr_qual[lnum].dose_admin
     ENDWHILE
     lingr_cnt2 = ordered_ingrdnts->qual[lpos2].total_ingr_cnt, dstat = alterlist(audit_reply->
      summary_qual[lidx].ordered_qual,lingr_cnt2), lnum = 0
     WHILE (lnum < lingr_cnt2)
       lnum = (lnum+ 1), audit_reply->summary_qual[lidx].ordered_qual[lnum].synonym_id =
       ordered_ingrdnts->qual[lpos2].ingr_qual[lnum].synonym_id, audit_reply->summary_qual[lidx].
       ordered_qual[lnum].ordered_dose = ordered_ingrdnts->qual[lpos2].ingr_qual[lnum].ordered_dose,
       audit_reply->summary_qual[lidx].ordered_qual[lnum].syn_mne = ordered_ingrdnts->qual[lpos2].
       ingr_qual[lnum].syn_mne
     ENDWHILE
     lnum = 1, lnum2 = 0
     IF (row >= 47)
      BREAK
     ENDIF
     col 0, audit_reply->summary_qual[lidx].date, col 15,
     unit, col 25, audit_reply->summary_qual[lidx].fin,
     col 40, smed_ident
     FOR (i = 1 TO lnum)
       col 50,
       CALL print(substring(1,43,audit_reply->summary_qual[lidx].ordered_qual[lnum].syn_mne)), col 95,
       CALL print(substring(1,18,audit_reply->summary_qual[lidx].ordered_qual[lnum].ordered_dose)),
       col 115, soutcome,
       row + 1, col 50,
       CALL print(substring(1,43,audit_reply->summary_qual[lidx].admined_qual[lnum].syn_mne)),
       col 95,
       CALL print(substring(1,18,audit_reply->summary_qual[lidx].admined_qual[lnum].dose_admin)), col
        115,
       CALL print(substring(1,16,trim(p1.name_full_formatted))), row + 1
     ENDFOR
     row + 1
    ENDIF
   FOOT REPORT
    IF (row > 45)
     BREAK
    ENDIF
    audit_reply->summary_qual_cnt = lidx, audit_reply->cancelled_cnt = lcancelledcnt, dstat =
    alterlist(audit_reply->summary_qual,lidx),
    lcontinued = (lidx - lcancelledcnt), audit_reply->continued_cnt = lcontinued, row + 2,
    col 20, "Administrations", sdisplay = format(events_reply->administrations,"#########"),
    col 40, sdisplay, col 60,
    "Total Alerts", sdisplay = format(lidx,"#########"), col 80,
    sdisplay, row + 1, col 20,
    "Not Done", sdisplay = format(events_reply->not_done,"#########"), col 40,
    sdisplay, col 60, "Administered",
    sdisplay = format(lcontinued,"#########"), col 80, sdisplay,
    row + 1, col 20, "Total",
    sdisplay = format(events_reply->total,"#########"), col 40, sdisplay,
    col 60, "Cancelled", sdisplay = format(lcancelledcnt,"#########"),
    col 80, sdisplay, row + 1
   WITH dio = postscript, maxrow = 50
  ;end select
 ENDIF
 IF ((audit_request->display_ind=3))
  SELECT INTO  $OUTDEV
   unit = uar_get_code_display(maa.nurse_unit_cd)
   FROM (dummyt d  WITH seq = nbuckets),
    med_admin_alert maa,
    prsnl p1,
    med_admin_med_error mame,
    person p2,
    encntr_alias ea,
    med_admin_event mae
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
    JOIN (maa
    WHERE maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
     audit_request->end_dt_tm)
     AND maa.alert_type_cd IN (overdose_cd, underdose_cd)
     AND expand(indx,nstart,(nstart+ (nbucketsize - 1)),(maa.nurse_unit_cd+ 0),audit_request->unit[
     indx].nurse_unit_cd))
    JOIN (p1
    WHERE p1.person_id=outerjoin(maa.prsnl_id))
    JOIN (mame
    WHERE mame.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
    JOIN (p2
    WHERE p2.person_id=outerjoin(mame.person_id))
    JOIN (ea
    WHERE ea.encntr_id=outerjoin(mame.encounter_id)
     AND ea.encntr_alias_type_cd=outerjoin(fin_nbr_cd))
    JOIN (mae
    WHERE mae.event_id=outerjoin(mame.event_id)
     AND mae.event_id > outerjoin(0.00))
   ORDER BY maa.alert_type_cd, p1.name_full_formatted, p1.name_full_formatted,
    p2.person_id, unit, maa.event_dt_tm
   HEAD REPORT
    last_row = "00000000000000000000", lcancelledcnt = 0, lidx = 0,
    lidx2 = 0, lidx3 = 0, lidx4 = 0,
    dstat = alterlist(audit_reply->summary_qual,10)
   HEAD PAGE
    IF ( NOT (( $OUTDEV IN ("MINE"))))
     col 0, "{ps/792 0 translate 90 rotate/}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1
    ENDIF
    col 0, "Date Range: ", sdisplay = ""
    IF ((audit_request->start_dt_tm > 0))
     sdisplay = format(audit_request->start_dt_tm,"mm/dd/yyyy;;d")
    ENDIF
    IF ((audit_request->end_dt_tm > 0))
     sdisplay = build2(sdisplay," - ",format(audit_request->end_dt_tm,"mm/dd/yyyy;;d"))
    ENDIF
    IF (textlen(sdisplay) > 0)
     col 12, sdisplay
    ENDIF
    col 122, "Page:", col + 1,
    CALL print(trim(cnvtstring(curpage))), row + 1, sdisplay = concat("Facility: ",trim(
      uar_get_code_display(audit_request->facility_cd),3)),
    col 0, sdisplay, col 96,
    "Run Date: ", curdate"mm/dd/yyyy;;d", " Time: ",
    curtime"hh:mm;;s", row + 1, sdisplay = ""
    IF (nallind=1)
     sdisplay = "Nurse Units: All"
    ELSEIF ((audit_request->unit_cnt > 1))
     sdisplay = concat("Nurse Units: ",trim(uar_get_code_display(audit_request->unit[1].nurse_unit_cd
        ),3))
     FOR (lcnt = 2 TO audit_request->unit_cnt)
       sdisplay = concat(sdisplay,", ",trim(uar_get_code_display(audit_request->unit[lcnt].
          nurse_unit_cd),3))
     ENDFOR
    ELSEIF ((audit_request->unit_cnt=1))
     sdisplay = concat("Nurse Unit: ",trim(uar_get_code_display(audit_request->unit[1].nurse_unit_cd),
       3))
    ELSE
     sdisplay = "Nurse Unit: Unknown/Error"
    ENDIF
    col 0, sdisplay
    IF (nallind=0
     AND (audit_request->unit_cnt > 1))
     row + 1
    ENDIF
    CALL center(ctitle,1,131), col 111, "Display per: User",
    row + 1, col 0, cdashline,
    row + 1, col 50, "Ordered Med/",
    col 95, "Ordered Dose/", row + 1,
    col 0, "Date/Time", col 15,
    "Loc", col 25, "FIN",
    col 40, "Method", col 50,
    "Scanned Med", col 95, "Scanned Dose",
    col 115, "User", row + 1,
    col 0, ctotal_line, row + 1
   HEAD maa.alert_type_cd
    IF (maa.alert_type_cd=overdose_cd)
     col 0, "Overdose"
    ELSE
     col 0, "Underdose"
    ENDIF
    row + 1, col 0, cdashline,
    row + 1
   HEAD p1.name_full_formatted
    IF (row >= 46)
     BREAK
    ENDIF
    col 0, p1.name_full_formatted, row + 1
   HEAD p2.name_full_formatted
    col 0, p2.name_full_formatted, row + 1
   DETAIL
    IF (row >= 47)
     BREAK
    ENDIF
    IF (last_row != maa.rowid)
     last_row = maa.rowid, lidx = (lidx+ 1), lidx2 = (lidx2+ 1)
     IF (lidx2=10)
      dstat = alterlist(audit_reply->summary_qual,(lidx+ 10)), lidx2 = 0
     ENDIF
     audit_reply->summary_qual[lidx].date = format(maa.event_dt_tm,"mm/dd/yy hh:mm"), audit_reply->
     summary_qual[lidx].fin = cnvtalias(ea.alias,ea.alias_pool_cd)
     IF (mae.positive_med_ident_ind=0)
      smed_ident = "Select"
     ELSE
      smed_ident = "Scan"
     ENDIF
     IF (mame.event_id=0.00)
      soutcome = "Cancelled"
     ELSE
      soutcome = "Administered"
     ENDIF
     lpos = locateval(lnum,1,parent_admined->total_ingr_cnt,mame.med_admin_med_error_id,
      parent_admined->qual[lnum].mame_id), lpos2 = locateval(lnum2,1,parent_order->total_orders_cnt,
      mame.order_id,parent_order->qual[lnum2].order_id), lpos2 = parent_order->qual[lpos2].
     ordered_qual,
     lingr_cnt = parent_admined->qual[lpos].total_cnt, dstat = alterlist(audit_reply->summary_qual[
      lidx].admined_qual,lingr_cnt), lnum = 0
     WHILE (lnum < lingr_cnt)
       lnum = (lnum+ 1), audit_reply->summary_qual[lidx].admined_qual[lnum].synonym_id =
       parent_admined->qual[lpos].ingr_qual[lnum].synonym_id, audit_reply->summary_qual[lidx].
       admined_qual[lnum].syn_mne = parent_admined->qual[lpos].ingr_qual[lnum].syn_mne,
       audit_reply->summary_qual[lidx].admined_qual[lnum].dose_admin = parent_admined->qual[lpos].
       ingr_qual[lnum].dose_admin
     ENDWHILE
     lingr_cnt2 = ordered_ingrdnts->qual[lpos2].total_ingr_cnt, dstat = alterlist(audit_reply->
      summary_qual[lidx].ordered_qual,lingr_cnt2), lnum = 0
     WHILE (lnum < lingr_cnt2)
       lnum = (lnum+ 1), audit_reply->summary_qual[lidx].ordered_qual[lnum].synonym_id =
       ordered_ingrdnts->qual[lpos2].ingr_qual[lnum].synonym_id, audit_reply->summary_qual[lidx].
       ordered_qual[lnum].ordered_dose = ordered_ingrdnts->qual[lpos2].ingr_qual[lnum].ordered_dose,
       audit_reply->summary_qual[lidx].ordered_qual[lnum].syn_mne = ordered_ingrdnts->qual[lpos2].
       ingr_qual[lnum].syn_mne
     ENDWHILE
     lnum = 1, lnum2 = 0
     IF (row >= 47)
      BREAK
     ENDIF
     col 0, audit_reply->summary_qual[lidx].date, col 15,
     unit, col 25, audit_reply->summary_qual[lidx].fin,
     col 40, smed_ident
     FOR (i = 1 TO lnum)
       col 50,
       CALL print(substring(1,43,audit_reply->summary_qual[lidx].ordered_qual[lnum].syn_mne)), col 95,
       CALL print(substring(1,18,audit_reply->summary_qual[lidx].ordered_qual[lnum].ordered_dose)),
       col 115, soutcome,
       row + 1, col 50,
       CALL print(substring(1,43,audit_reply->summary_qual[lidx].admined_qual[lnum].syn_mne)),
       col 95,
       CALL print(substring(1,18,audit_reply->summary_qual[lidx].admined_qual[lnum].dose_admin)), col
        115,
       CALL print(substring(1,16,trim(p1.name_full_formatted))), row + 1
     ENDFOR
     row + 1
    ENDIF
   FOOT REPORT
    IF (row > 45)
     BREAK
    ENDIF
    audit_reply->summary_qual_cnt = lidx, audit_reply->cancelled_cnt = lcancelledcnt, dstat =
    alterlist(audit_reply->summary_qual,lidx),
    lcontinued = (lidx - lcancelledcnt), audit_reply->continued_cnt = lcontinued, row + 2,
    col 20, "Administrations", sdisplay = format(events_reply->administrations,"#########"),
    col 40, sdisplay, col 60,
    "Total Alerts", sdisplay = format(lidx,"#########"), col 80,
    sdisplay, row + 1, col 20,
    "Not Done", sdisplay = format(events_reply->not_done,"#########"), col 40,
    sdisplay, col 60, "Administered",
    sdisplay = format(lcontinued,"#########"), col 80, sdisplay,
    row + 1, col 20, "Total",
    sdisplay = format(events_reply->total,"#########"), col 40, sdisplay,
    col 60, "Cancelled", sdisplay = format(lcancelledcnt,"#########"),
    col 80, sdisplay, row + 1
   WITH dio = postscript, maxrow = 50
  ;end select
 ENDIF
 FREE RECORD audit_request
 FREE RECORD events_reply
 FREE RECORD parent_order
 FREE RECORD parent_admined
 FREE RECORD audit_reply
 FREE RECORD ordered_ingrdnts
END GO
