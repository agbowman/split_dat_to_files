CREATE PROGRAM bhs_earlylate_audit_detail:dba
 PROMPT
  "Output to File/Printer/MINE:" = "MINE",
  "Starting date:" = "CURDATE",
  "Ending date:" = "CURDATE",
  "Facility:" = 0,
  "Nurse unit(s):" = 0,
  "Display per:" = 2
  WITH out_dev, start_date, end_date,
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
     2 ordered_qual[*]
       3 synonym_id = f8
       3 ordered_dose = c60
       3 syn_mne = c60
 )
 DECLARE ctitle = vc WITH protect, constant("Point of Care Audit Early/Late Report")
 DECLARE cdashline = vc WITH protect, constant(fillstring(131,"-"))
 DECLARE ctotal_line = vc WITH protect, constant(fillstring(130,"-"))
 DECLARE last_row = c20 WITH protect, noconstant("00000000000000000000")
 DECLARE last_mod = vc WITH protect, noconstant("")
 DECLARE mod_date = vc WITH protect, noconstant("")
 DECLARE smed_ident = vc WITH protect, noconstant("")
 DECLARE soutcome = vc WITH protect, noconstant("")
 DECLARE sdisplay = vc WITH protect, noconstant("")
 DECLARE snua_clause = vc WITH protect, noconstant("1=1")
 DECLARE snue_clause = vc WITH protect, noconstant("1=1")
 DECLARE snurse_units = vc WITH protect, noconstant("")
 DECLARE lcontinued = i4 WITH protect, noconstant(0)
 DECLARE lingr_cnt = i4 WITH protect, noconstant(0)
 DECLARE lpos = i4 WITH protect, noconstant(0)
 DECLARE lnum = i4 WITH protect, noconstant(0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE lidx2 = i4 WITH protect, noconstant(0)
 DECLARE lidx3 = i4 WITH protect, noconstant(0)
 DECLARE lidx4 = i4 WITH protect, noconstant(0)
 DECLARE lcancelledcnt = i4 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lcnt2 = i4 WITH protect, noconstant(0)
 DECLARE nallind = i2 WITH protect, noconstant(0)
 DECLARE dlastid = f8 WITH protect, noconstant(0.00)
 DECLARE dstat = f8 WITH protect, noconstant(0.00)
 DECLARE s_nd_result_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE s_auth_result_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE fin_nbr_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE earlylate_cd = f8 WITH protect, noconstant(uar_get_code_by("DISPLAY_KEY",4000040,
   "EARLYLATEREASON"))
 DECLARE coutput = vc WITH protect, noconstant(concat("earlylateaudit",cnvtstring(cnvtdatetime(
     curdate,curtime3)),".csv"))
 DECLARE any_status_ind = c1
 DECLARE indx = i4
 DECLARE nsize = i4
 DECLARE nbucketsize = i4
 DECLARE ntotal = i4
 DECLARE nstart = i4
 DECLARE nbuckets = i4
 SET audit_request->display_ind =  $DISPLAY_TYPE
 SET audit_request->report_name = "BSC_EARLYLATE_AUDIT_DETAIL"
 SET audit_request->facility_cd =  $FACILITY
 IF (( $START_DATE="CURDATE"))
  SET audit_request->start_dt_tm = cnvtdatetime(curdate,0)
 ELSE
  SET audit_request->start_dt_tm = cnvtdatetime(cnvtdate(cnvtalphanum( $START_DATE)),0)
 ENDIF
 IF (( $END_DATE="CURDATE"))
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
    "BWH", "BWHINPTPSYCH")
     AND cv.active_ind=1)
    JOIN (n
    WHERE (n.loc_facility_cd= $FACILITY)
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
    AND maa.alert_type_cd=earlylate_cd
    AND expand(indx,nstart,(nstart+ (nbucketsize - 1)),(maa.nurse_unit_cd+ 0),audit_request->unit[
    indx].nurse_unit_cd))
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
  WITH nocounter
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
 IF ((audit_request->display_ind=2))
  SELECT INTO  $OUT_DEV
   FROM (dummyt d  WITH seq = nbuckets),
    med_admin_alert maa,
    prsnl p1,
    med_admin_med_error mame,
    med_admin_pt_error mape,
    person p2,
    encntr_alias ea,
    med_admin_event mae
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
    JOIN (maa
    WHERE maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
     audit_request->end_dt_tm)
     AND maa.alert_type_cd=earlylate_cd
     AND expand(indx,nstart,(nstart+ (nbucketsize - 1)),(maa.nurse_unit_cd+ 0),audit_request->unit[
     indx].nurse_unit_cd))
    JOIN (p1
    WHERE p1.person_id=outerjoin(maa.prsnl_id))
    JOIN (mame
    WHERE mame.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
    JOIN (mape
    WHERE mape.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
    JOIN (p2
    WHERE p2.person_id=outerjoin(mame.person_id))
    JOIN (ea
    WHERE ea.encntr_id=outerjoin(mame.encounter_id)
     AND ea.encntr_alias_type_cd=outerjoin(fin_nbr_cd))
    JOIN (mae
    WHERE mae.event_id=outerjoin(mame.event_id)
     AND mae.event_id > outerjoin(0.00))
   ORDER BY p2.name_last_key, p2.person_id, maa.rowid,
    mame.event_id, cnvtdatetime(mae.updt_dt_tm)
   HEAD REPORT
    last_row = "00000000000000000000", lcancelledcnt = 0, lidx = 0,
    lidx2 = 0, lidx3 = 0, lidx4 = 0,
    dstat = alterlist(audit_reply->summary_qual,10)
   HEAD PAGE
    IF ( NOT (( $OUT_DEV IN ("MINE"))))
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
    col 122, "Page: ", curpage"###",
    row + 1, sdisplay = concat("Facility: ",trim(uar_get_code_display( $FACILITY),3)), col 0,
    sdisplay, col 96, "Run Date: ",
    curdate"mm/dd/yyyy;;d", " Time: ", curtime"hh:mm;;s",
    row + 1, sdisplay = ""
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
    row + 1, col 0, "Legend",
    col 07,
    "(A = Alert Type, MedID = Medication Identification, Med = Medication, ADM = Administered", col
     + 0,
    ", CX = Cancelled, OC = Outcome,", row + 1, col 07,
    "M = Missing Date, L = Late, E = Early)", row + 1, col 02,
    "Alert", col 17, "Patient",
    col 74, "MedID", col 97,
    "Ordered", col 112, "User",
    row + 1, col 0, "A",
    col 02, "Date/Time", col 17,
    "name", col 36, "Location",
    col 58, "FIN", col 74,
    "Method", col 81, "Med",
    col 97, "Dose", col 108,
    "OC", col 112, "name",
    row + 1, col 0, ctotal_line,
    row + 1
   DETAIL
    IF (row=42)
     BREAK
    ENDIF
    IF (last_row != maa.rowid)
     last_row = maa.rowid, lidx = (lidx+ 1), lidx2 = (lidx2+ 1)
     IF (lidx2=10)
      dstat = alterlist(audit_reply->summary_qual,(lidx+ 10)), lidx2 = 0
     ENDIF
     IF (substring(1,4,cnvtstring(datetimediff(maa.event_dt_tm,mame.scheduled_dt_tm),4,2))=patstring(
      "-*"))
      audit_reply->summary_qual[lidx].alert_type = "Early"
     ELSEIF (substring(1,4,cnvtstring(datetimediff(maa.event_dt_tm,mame.scheduled_dt_tm),4,2))="0.00"
     )
      audit_reply->summary_qual[lidx].alert_type = "Missing Date-EarlyLate"
     ELSE
      audit_reply->summary_qual[lidx].alert_type = "Late"
     ENDIF
     audit_reply->summary_qual[lidx].date = format(maa.event_dt_tm,"mm/dd/yy hh:mm"), audit_reply->
     summary_qual[lidx].patient = p2.name_full_formatted, audit_reply->summary_qual[lidx].location =
     uar_get_code_display(maa.nurse_unit_cd),
     audit_reply->summary_qual[lidx].fin = cnvtalias(ea.alias,ea.alias_pool_cd), audit_reply->
     summary_qual[lidx].med_ident = mae.positive_med_ident_ind, audit_reply->summary_qual[lidx].
     order_id = mame.order_id,
     audit_reply->summary_qual[lidx].event_id = mame.event_id, audit_reply->summary_qual[lidx].
     encounter_id = mame.encounter_id, audit_reply->summary_qual[lidx].alert_id = maa
     .med_admin_alert_id,
     audit_reply->summary_qual[lidx].user = p1.name_full_formatted
     IF (mae.positive_med_ident_ind=0)
      smed_ident = "Select"
     ELSE
      smed_ident = "Scan"
     ENDIF
     IF (mame.event_id=0.00)
      soutcome = "CX"
     ELSE
      soutcome = "ADM"
     ENDIF
     sdisplay = substring(1,1,audit_reply->summary_qual[lidx].alert_type), col 0, sdisplay,
     sdisplay = substring(1,14,audit_reply->summary_qual[lidx].date), col 2, sdisplay,
     sdisplay = substring(1,18,audit_reply->summary_qual[lidx].patient), col 17, sdisplay,
     sdisplay = substring(1,21,audit_reply->summary_qual[lidx].location), col 36, sdisplay,
     sdisplay = substring(1,15,audit_reply->summary_qual[lidx].fin), col 58, sdisplay,
     sdisplay = substring(1,6,smed_ident), col 74, sdisplay,
     lpos = locateval(lnum,1,parent_order->total_orders_cnt,mame.order_id,parent_order->qual[lnum].
      order_id), lnum = 0, lpos = parent_order->qual[lpos].ordered_qual,
     lingr_cnt = ordered_ingrdnts->qual[lpos].total_ingr_cnt, dstat = alterlist(audit_reply->
      summary_qual[lidx].ordered_qual,lingr_cnt)
     WHILE (lnum < lingr_cnt)
       lnum = (lnum+ 1), audit_reply->summary_qual[lidx].ordered_qual[lnum].synonym_id =
       ordered_ingrdnts->qual[lpos].ingr_qual[lnum].synonym_id, audit_reply->summary_qual[lidx].
       ordered_qual[lnum].ordered_dose = ordered_ingrdnts->qual[lpos].ingr_qual[lnum].ordered_dose,
       audit_reply->summary_qual[lidx].ordered_qual[lnum].syn_mne = ordered_ingrdnts->qual[lpos].
       ingr_qual[lnum].syn_mne
     ENDWHILE
     lnum = 0
     WHILE (lnum < lingr_cnt)
       lnum = (lnum+ 1)
       IF (textlen(trim(ordered_ingrdnts->qual[lpos].ingr_qual[lnum].syn_mne,3)) > 0)
        sdisplay = substring(1,15,ordered_ingrdnts->qual[lpos].ingr_qual[lnum].syn_mne)
       ELSE
        sdisplay = "not found"
       ENDIF
       col 81, sdisplay, sdisplay = substring(1,10,ordered_ingrdnts->qual[lpos].ingr_qual[lnum].
        ordered_dose),
       col 97, sdisplay
       IF (lnum=1)
        sdisplay = substring(1,3,soutcome), col 108, sdisplay,
        sdisplay = substring(1,18,audit_reply->summary_qual[lidx].user), col 112, sdisplay
       ENDIF
       IF (lnum < lingr_cnt)
        row + 1
       ENDIF
     ENDWHILE
     IF (lnum=0)
      sdisplay = "not found", col 81, sdisplay,
      sdisplay = substring(1,3,soutcome), col 108, sdisplay,
      sdisplay = substring(1,18,audit_reply->summary_qual[lidx].user), col 112, sdisplay
     ENDIF
     row + 1
     IF (mame.event_id=0.00)
      lcancelledcnt = (lcancelledcnt+ 1)
     ENDIF
    ENDIF
   FOOT PAGE
    col 0, "Page:", col + 2,
    curpage
   FOOT REPORT
    audit_reply->summary_qual_cnt = lidx, audit_reply->summary_qual_cnt = lcancelledcnt, dstat =
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
   WITH dio = postscript, maxrow = 45
  ;end select
 ELSEIF ((audit_request->display_ind=0))
  SELECT INTO  $OUT_DEV
   FROM (dummyt d  WITH seq = nbuckets),
    med_admin_alert maa,
    prsnl p1,
    med_admin_med_error mame,
    med_admin_pt_error mape,
    person p2,
    encntr_alias ea,
    med_admin_event mae
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
    JOIN (maa
    WHERE maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
     audit_request->end_dt_tm)
     AND maa.alert_type_cd=earlylate_cd
     AND expand(indx,nstart,(nstart+ (nbucketsize - 1)),(maa.nurse_unit_cd+ 0),audit_request->unit[
     indx].nurse_unit_cd))
    JOIN (p1
    WHERE p1.person_id=outerjoin(maa.prsnl_id))
    JOIN (mame
    WHERE mame.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
    JOIN (mape
    WHERE mape.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
    JOIN (p2
    WHERE p2.person_id=outerjoin(mame.person_id))
    JOIN (ea
    WHERE ea.encntr_id=outerjoin(mame.encounter_id)
     AND ea.encntr_alias_type_cd=outerjoin(fin_nbr_cd))
    JOIN (mae
    WHERE mae.event_id=outerjoin(mame.event_id)
     AND mae.event_id > outerjoin(0.00))
   ORDER BY p1.name_last_key, p1.person_id, maa.rowid,
    mame.event_id, cnvtdatetime(mae.updt_dt_tm)
   HEAD REPORT
    last_row = "00000000000000000000", lcancelledcnt = 0, lidx = 0,
    lidx2 = 0, lidx3 = 0, lidx4 = 0,
    line = fillstring(30,"-"), today = format(curdate,"mm/dd/yyyy;;d"), now = format(curtime,
     "hh:mm:ss;;s"),
    dstat = alterlist(audit_reply->summary_qual,10)
   HEAD PAGE
    IF ( NOT (( $OUT_DEV IN ("MINE"))))
     col 00, "{ps/792 0 translate 90 rotate/}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1
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
    col 122, "Page: ", curpage"###",
    row + 1, sdisplay = concat("Facility: ",trim(uar_get_code_display( $FACILITY),3)), col 0,
    sdisplay, col 96, "Run Date: ",
    curdate"mm/dd/yyyy;;d", " Time: ", curtime"hh:mm;;s",
    row + 1, sdisplay = ""
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
     sdisplay = "Nurse Unit:"
    ENDIF
    col 0, sdisplay
    IF (nallind=0
     AND (audit_request->unit_cnt > 1))
     row + 1
    ENDIF
    CALL center(ctitle,1,131), col 114, "Display per: User",
    row + 1, col 00, cdashline,
    row + 1, col 0, "Legend",
    col 07,
    "(A = Alert Type, MedID = Medication Identification, Med = Medication, ADM = Administered", col
     + 0,
    ", CX = Cancelled, OC = Outcome,", row + 1, col 07,
    "M = Missing Date, L = Late, E = Early)", row + 1, col 0,
    "User", col 21, "Alert",
    col 36, "Patient", col 93,
    "MedID", col 116, "Ordered",
    row + 1, col 0, "name",
    col 19, "A", col 21,
    "Date/Time", col 36, "name",
    col 55, "Location", col 77,
    "FIN", col 93, "Method",
    col 100, "Med", col 116,
    "Dose", col 127, "OC",
    row + 1, col 0, ctotal_line,
    row + 1
   DETAIL
    IF (row=42)
     BREAK
    ENDIF
    IF (last_row != maa.rowid)
     last_row = maa.rowid, lidx = (lidx+ 1), lidx2 = (lidx2+ 1)
     IF (lidx2=10)
      dstat = alterlist(audit_reply->summary_qual,(lidx+ 10)), lidx2 = 0
     ENDIF
     IF (substring(1,4,cnvtstring(datetimediff(maa.event_dt_tm,mame.scheduled_dt_tm),4,2))=patstring(
      "-*"))
      audit_reply->summary_qual[lidx].alert_type = "Early"
     ELSEIF (substring(1,4,cnvtstring(datetimediff(maa.event_dt_tm,mame.scheduled_dt_tm),4,2))="0.00"
     )
      audit_reply->summary_qual[lidx].alert_type = "Missing Date-EarlyLate"
     ELSE
      audit_reply->summary_qual[lidx].alert_type = "Late"
     ENDIF
     audit_reply->summary_qual[lidx].date = format(maa.event_dt_tm,"mm/dd/yy hh:mm"), audit_reply->
     summary_qual[lidx].patient = p2.name_full_formatted, audit_reply->summary_qual[lidx].location =
     uar_get_code_display(maa.nurse_unit_cd),
     audit_reply->summary_qual[lidx].fin = cnvtalias(ea.alias,ea.alias_pool_cd), audit_reply->
     summary_qual[lidx].med_ident = mae.positive_med_ident_ind, audit_reply->summary_qual[lidx].
     order_id = mame.order_id,
     audit_reply->summary_qual[lidx].event_id = mame.event_id, audit_reply->summary_qual[lidx].
     encounter_id = mame.encounter_id, audit_reply->summary_qual[lidx].alert_id = maa
     .med_admin_alert_id,
     audit_reply->summary_qual[lidx].user = p1.name_full_formatted
     IF (mae.positive_med_ident_ind=0)
      smed_ident = "Select"
     ELSE
      smed_ident = "Scan"
     ENDIF
     IF (mame.event_id=0.00)
      soutcome = "CX"
     ELSE
      soutcome = "ADM"
     ENDIF
     sdisplay = substring(1,18,audit_reply->summary_qual[lidx].user), col 0, sdisplay,
     sdisplay = substring(1,1,audit_reply->summary_qual[lidx].alert_type), col 19, sdisplay,
     sdisplay = substring(1,14,audit_reply->summary_qual[lidx].date), col 21, sdisplay,
     sdisplay = substring(1,18,audit_reply->summary_qual[lidx].patient), col 36, sdisplay,
     sdisplay = substring(1,21,audit_reply->summary_qual[lidx].location), col 55, sdisplay,
     sdisplay = substring(1,15,audit_reply->summary_qual[lidx].fin), col 77, sdisplay,
     sdisplay = substring(1,6,smed_ident), col 93, sdisplay,
     lpos = locateval(lnum,1,parent_order->total_orders_cnt,mame.order_id,parent_order->qual[lnum].
      order_id), lnum = 0, lpos = parent_order->qual[lpos].ordered_qual,
     lingr_cnt = ordered_ingrdnts->qual[lpos].total_ingr_cnt, dstat = alterlist(audit_reply->
      summary_qual[lidx].ordered_qual,lingr_cnt)
     WHILE (lnum < lingr_cnt)
       lnum = (lnum+ 1), audit_reply->summary_qual[lidx].ordered_qual[lnum].synonym_id =
       ordered_ingrdnts->qual[lpos].ingr_qual[lnum].synonym_id, audit_reply->summary_qual[lidx].
       ordered_qual[lnum].ordered_dose = ordered_ingrdnts->qual[lpos].ingr_qual[lnum].ordered_dose,
       audit_reply->summary_qual[lidx].ordered_qual[lnum].syn_mne = ordered_ingrdnts->qual[lpos].
       ingr_qual[lnum].syn_mne
     ENDWHILE
     lnum = 0
     WHILE (lnum < lingr_cnt)
       lnum = (lnum+ 1)
       IF (textlen(trim(ordered_ingrdnts->qual[lpos].ingr_qual[lnum].syn_mne,3)) > 0)
        sdisplay = substring(1,15,ordered_ingrdnts->qual[lpos].ingr_qual[lnum].syn_mne)
       ELSE
        sdisplay = "not found"
       ENDIF
       col 100, sdisplay, sdisplay = substring(1,10,ordered_ingrdnts->qual[lpos].ingr_qual[lnum].
        ordered_dose),
       col 116, sdisplay
       IF (lnum=1)
        sdisplay = substring(1,3,soutcome), col 127, sdisplay
       ENDIF
       IF (lnum < lingr_cnt)
        row + 1
       ENDIF
     ENDWHILE
     IF (lnum=0)
      sdisplay = substring(1,3,soutcome), col 127, sdisplay
     ENDIF
     row + 1
     IF (mame.event_id=0.00)
      lcancelledcnt = (lcancelledcnt+ 1)
     ENDIF
    ENDIF
   FOOT PAGE
    col 0, "Page:", col + 2,
    curpage
   FOOT REPORT
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
   WITH dio = postscript, maxrow = 45
  ;end select
 ELSEIF ((audit_request->display_ind=1))
  SELECT INTO  $OUT_DEV
   FROM (dummyt d  WITH seq = nbuckets),
    med_admin_alert maa,
    prsnl p1,
    med_admin_med_error mame,
    med_admin_pt_error mape,
    person p2,
    encntr_alias ea,
    med_admin_event mae
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
    JOIN (maa
    WHERE maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
     audit_request->end_dt_tm)
     AND maa.alert_type_cd=earlylate_cd
     AND expand(indx,nstart,(nstart+ (nbucketsize - 1)),(maa.nurse_unit_cd+ 0),audit_request->unit[
     indx].nurse_unit_cd))
    JOIN (p1
    WHERE p1.person_id=outerjoin(maa.prsnl_id))
    JOIN (mame
    WHERE mame.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
    JOIN (mape
    WHERE mape.med_admin_alert_id=outerjoin(maa.med_admin_alert_id))
    JOIN (p2
    WHERE p2.person_id=outerjoin(mame.person_id))
    JOIN (ea
    WHERE ea.encntr_id=outerjoin(mame.encounter_id)
     AND ea.encntr_alias_type_cd=outerjoin(fin_nbr_cd))
    JOIN (mae
    WHERE mae.event_id=outerjoin(mame.event_id)
     AND mae.event_id > outerjoin(0.00))
   ORDER BY cnvtdatetime(maa.event_dt_tm), maa.rowid, mame.event_id,
    cnvtdatetime(mae.updt_dt_tm)
   HEAD REPORT
    last_row = "00000000000000000000", lcancelledcnt = 0, lidx = 0,
    lidx2 = 0, lidx3 = 0, lidx4 = 0,
    line = fillstring(30,"-"), today = format(curdate,"mm/dd/yyyy;;d"), now = format(curtime,
     "hh:mm:ss;;s"),
    dstat = alterlist(audit_reply->summary_qual,10)
   HEAD PAGE
    IF ( NOT (( $OUT_DEV IN ("MINE"))))
     col 00, "{ps/792 0 translate 90 rotate/}{pos/000/000}{f/1/0}{lpi/6}{cpi/13}", row + 1
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
    col 122, "Page: ", curpage"###",
    row + 1, sdisplay = concat("Facility: ",trim(uar_get_code_display( $FACILITY),3)), col 0,
    sdisplay, col 96, "Run Date: ",
    curdate"mm/dd/yyyy;;d", " Time: ", curtime"hh:mm;;s",
    row + 1, sdisplay = ""
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
     sdisplay = "Nurse Unit:"
    ENDIF
    col 0, sdisplay
    IF (nallind=0
     AND (audit_request->unit_cnt > 1))
     row + 1
    ENDIF
    CALL center(ctitle,1,131), col 109, "Display per: Date/Time",
    row + 1, col 0, cdashline,
    row + 1, col 0, "Legend",
    col 07,
    "(A = Alert Type, MedID = Medication Identification, Med = Medication, ADM = Administered", col
     + 0,
    ", CX = Cancelled, OC = Outcome,", row + 1, col 07,
    "M = Missing Date, L = Late, E = Early)", row + 1, col 02,
    "Alert", col 17, "Patient",
    col 74, "MedID", col 97,
    "Ordered", col 112, "User",
    row + 1, col 0, "A",
    col 02, "Date/Time", col 17,
    "name", col 36, "Location",
    col 58, "FIN", col 74,
    "Method", col 81, "Med",
    col 97, "Dose", col 108,
    "OC", col 112, "name",
    row + 1, col 0, ctotal_line,
    row + 1
   DETAIL
    IF (row=42)
     BREAK
    ENDIF
    IF (last_row != maa.rowid)
     last_row = maa.rowid, lidx = (lidx+ 1), lidx2 = (lidx2+ 1)
     IF (lidx2=10)
      dstat = alterlist(audit_reply->summary_qual,(lidx+ 10)), lidx2 = 0
     ENDIF
     IF (substring(1,4,cnvtstring(datetimediff(maa.event_dt_tm,mame.scheduled_dt_tm),4,2))=patstring(
      "-*"))
      audit_reply->summary_qual[lidx].alert_type = "Early"
     ELSEIF (substring(1,4,cnvtstring(datetimediff(maa.event_dt_tm,mame.scheduled_dt_tm),4,2))="0.00"
     )
      audit_reply->summary_qual[lidx].alert_type = "Missing Date-EarlyLate"
     ELSE
      audit_reply->summary_qual[lidx].alert_type = "Late"
     ENDIF
     audit_reply->summary_qual[lidx].date = format(maa.event_dt_tm,"mm/dd/yy hh:mm"), audit_reply->
     summary_qual[lidx].patient = p2.name_full_formatted, audit_reply->summary_qual[lidx].location =
     uar_get_code_display(maa.nurse_unit_cd),
     audit_reply->summary_qual[lidx].fin = cnvtalias(ea.alias,ea.alias_pool_cd), audit_reply->
     summary_qual[lidx].med_ident = mae.positive_med_ident_ind, audit_reply->summary_qual[lidx].
     order_id = mame.order_id,
     audit_reply->summary_qual[lidx].event_id = mame.event_id, audit_reply->summary_qual[lidx].
     encounter_id = mame.encounter_id, audit_reply->summary_qual[lidx].alert_id = maa
     .med_admin_alert_id,
     audit_reply->summary_qual[lidx].user = p1.name_full_formatted
     IF (mae.positive_med_ident_ind=0)
      smed_ident = "Select"
     ELSE
      smed_ident = "Scan"
     ENDIF
     IF (mame.event_id=0.00)
      soutcome = "CX"
     ELSE
      soutcome = "ADM"
     ENDIF
     sdisplay = substring(1,1,audit_reply->summary_qual[lidx].alert_type), col 0, sdisplay,
     sdisplay = substring(1,14,audit_reply->summary_qual[lidx].date), col 2, sdisplay,
     sdisplay = substring(1,18,audit_reply->summary_qual[lidx].patient), col 17, sdisplay,
     sdisplay = substring(1,21,audit_reply->summary_qual[lidx].location), col 36, sdisplay,
     sdisplay = substring(1,15,audit_reply->summary_qual[lidx].fin), col 58, sdisplay,
     sdisplay = substring(1,6,smed_ident), col 74, sdisplay,
     lpos = locateval(lnum,1,parent_order->total_orders_cnt,mame.order_id,parent_order->qual[lnum].
      order_id), lnum = 0, lpos = parent_order->qual[lpos].ordered_qual,
     lingr_cnt = ordered_ingrdnts->qual[lpos].total_ingr_cnt, dstat = alterlist(audit_reply->
      summary_qual[lidx].ordered_qual,lingr_cnt)
     WHILE (lnum < lingr_cnt)
       lnum = (lnum+ 1), audit_reply->summary_qual[lidx].ordered_qual[lnum].synonym_id =
       ordered_ingrdnts->qual[lpos].ingr_qual[lnum].synonym_id, audit_reply->summary_qual[lidx].
       ordered_qual[lnum].ordered_dose = ordered_ingrdnts->qual[lpos].ingr_qual[lnum].ordered_dose,
       audit_reply->summary_qual[lidx].ordered_qual[lnum].syn_mne = ordered_ingrdnts->qual[lpos].
       ingr_qual[lnum].syn_mne
     ENDWHILE
     lnum = 0
     WHILE (lnum < lingr_cnt)
       lnum = (lnum+ 1)
       IF (textlen(trim(ordered_ingrdnts->qual[lpos].ingr_qual[lnum].syn_mne,3)) > 0)
        sdisplay = substring(1,15,ordered_ingrdnts->qual[lpos].ingr_qual[lnum].syn_mne)
       ELSE
        sdisplay = "not found"
       ENDIF
       col 81, sdisplay, sdisplay = substring(1,10,ordered_ingrdnts->qual[lpos].ingr_qual[lnum].
        ordered_dose),
       col 97, sdisplay
       IF (lnum=1)
        sdisplay = substring(1,3,soutcome), col 108, sdisplay,
        sdisplay = substring(1,18,audit_reply->summary_qual[lidx].user), col 112, sdisplay
       ENDIF
       IF (lnum < lingr_cnt)
        row + 1
       ENDIF
     ENDWHILE
     IF (lnum=0)
      sdisplay = substring(1,3,soutcome), col 108, sdisplay,
      sdisplay = substring(1,18,audit_reply->summary_qual[lidx].user), col 112, sdisplay
     ENDIF
     row + 1
     IF (mame.event_id=0.00)
      lcancelledcnt = (lcancelledcnt+ 1)
     ENDIF
    ENDIF
   FOOT PAGE
    col 0, "Page:", col + 2,
    curpage
   FOOT REPORT
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
   WITH dio = postscript, maxrow = 45
  ;end select
 ENDIF
 FREE RECORD audit_request
 FREE RECORD events_reply
 FREE RECORD parent_order
 FREE RECORD audit_reply
 FREE RECORD ordered_ingrdnts
END GO
