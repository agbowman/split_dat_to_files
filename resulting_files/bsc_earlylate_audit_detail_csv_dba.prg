CREATE PROGRAM bsc_earlylate_audit_detail_csv:dba
 SET modify = predeclare
 DECLARE username = vc WITH protect, noconstant("")
 DECLARE username2 = vc WITH protect, noconstant("")
 DECLARE sordereddose = vc WITH protect, noconstant("")
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE i18n_sdaterange = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_DATE_RANGE","Date Range"),3))
 DECLARE i18n_spage = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_PAGE","Page"
    ),3))
 DECLARE i18n_sfacility = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_FACILITY","Facility"),3))
 DECLARE i18n_srundatetime = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_RUN_DATE","Run Date/Time"),3))
 DECLARE i18n_snurseunit = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NURSE_UNIT","Nurse Unit"),3))
 DECLARE i18n_snurseunits = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NURSE_UNITS","Nurse Units"),3))
 DECLARE i18n_sall = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ALL","All"),3
   ))
 DECLARE i18n_sunknownerror = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_UNKNOWN_ERROR","Unknown/Error"),3))
 DECLARE i18n_stitle = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_TITLE",
    "Point of Care Audit Early/Late Report"),3))
 DECLARE i18n_sdisplayper = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_DISPLAY_PER","Display per"),3))
 DECLARE i18n_spatient = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_PATIENT",
    "Patient"),3))
 DECLARE i18n_slegend = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_LEGEND",
    "Legend"),3))
 DECLARE i18n_salerttype = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ALERT_TYPE","Alert Type"),3))
 DECLARE i18n_sa = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_A","A"),3))
 DECLARE i18n_smedicationident = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_MEDICATION_IDENT","Medication Identification"),3))
 DECLARE i18n_smedid = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_MEDID",
    "MedID"),3))
 DECLARE i18n_smedication = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_MEDICATION","Medication"),3))
 DECLARE i18n_smed = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_MED","Med"),3
   ))
 DECLARE i18n_sadministered = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ADMINISTERED","Administered"),3))
 DECLARE i18n_sadm = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ADM","ADM"),3
   ))
 DECLARE i18n_scancelled = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_CANCELLED","Cancelled"),3))
 DECLARE i18n_scx = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_CX","CX"),3))
 DECLARE i18n_sng = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_NG","NG"),3))
 DECLARE i18n_snd = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ND","ND"),3))
 DECLARE i18n_soutcome = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_OUTCOME",
    "Outcome"),3))
 DECLARE i18n_soc = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_OC","OC"),3))
 DECLARE i18n_smissingdate = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_MISSING_DATE","Missing Date"),3))
 DECLARE i18n_sm = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_M","M"),3))
 DECLARE i18n_slate = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_LATE","Late"
    ),3))
 DECLARE i18n_sl = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_L","L"),3))
 DECLARE i18n_searly = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_EARLY",
    "Early"),3))
 DECLARE i18n_se = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_E","E"),3))
 DECLARE i18n_salert = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ALERT",
    "Alert"),3))
 DECLARE i18n_sordered = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ORDERED",
    "Ordered"),3))
 DECLARE i18n_suser = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_USER","User"
    ),3))
 DECLARE i18n_sdatetime = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_DATE_TIME","Date/Time"),3))
 DECLARE i18n_sname = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_NAME","name"
    ),3))
 DECLARE i18n_slocation = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_LOCATION","Location"),3))
 DECLARE i18n_sfin = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_FIN","FIN"),3
   ))
 DECLARE i18n_smethod = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_METHOD",
    "Method"),3))
 DECLARE i18n_sdose = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_DOSE","Dose"
    ),3))
 DECLARE i18n_sselect = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_SELECT",
    "Select"),3))
 DECLARE i18n_sscan = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_SCAN","Scan"
    ),3))
 DECLARE i18n_snotfound = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NOT_FOUND","not found"),3))
 DECLARE i18n_sadministrations = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ADMINISTRATIONS","Administrations"),3))
 DECLARE i18n_stotalalerts = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_TOTAL_ALERTS","Total Alerts"),3))
 DECLARE i18n_snotdone = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_NOTDONE",
    "Not Done"),3))
 DECLARE i18n_snotgiven = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NOTGIVEN","Not Given"),3))
 DECLARE i18n_stotal = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_TOTAL",
    "Total"),3))
 DECLARE i18n_sreason = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_REASON",
    "Reason"),3))
 DECLARE i18n_snoreasongiven = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NO_REASON_GIVEN","No Reason Given"),3))
 DECLARE i18n_snoresultsqualified = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_NO_RESULTS_QUALIFIED","No Results Qualified"),3))
 DECLARE i18n_sallevents = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ALL_EVENTS","All Events"),3))
 DECLARE i18n_searlylateevents = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_EARLY/LATE_EVENTS","Early/Late Events"),3))
 DECLARE i18n_sadminevents = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ADMIN_EVENTS","Administration Events"),3))
 DECLARE i18n_salerts = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_ALERTS",
    "Alerts"),3))
 DECLARE i18n_sfrom = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_FROM","From"
    ),3))
 DECLARE i18n_sto = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,"i18n_TO","To"),3))
 DECLARE i18n_salertdatetime = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ALERT_DTTM","Alert date/time"),3))
 DECLARE i18n_smedidmethod = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_MEDID_METHOD","Medication ID method"),3))
 DECLARE i18n_sordereddose = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_ORDERED_DOSE","Ordered dose"),3))
 DECLARE i18n_smisdateearlylate = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandle,
    "i18n_MISDT_EARLYLATE","Missing Date-EarlyLate"),3))
 SELECT INTO value(coutput)
  FROM med_admin_alert maa,
   prsnl p1,
   med_admin_med_error mame,
   med_admin_pt_error mape,
   person p2,
   encntr_alias ea,
   med_admin_event mae
  PLAN (maa
   WHERE maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
    audit_request->end_dt_tm)
    AND maa.alert_type_cd=earlylate_cd
    AND maa.nurse_unit_cd > 0.00
    AND parser(snua_clause))
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
   last_row = "00000000000000000000", lidx = 0, lidx2 = 0,
   lidx3 = 0, lidx4 = 0, audit_reply->cancelled_cnt = 0,
   audit_reply->not_given_cnt = 0, audit_reply->not_done_cnt = 0, audit_reply->administered_cnt = 0,
   dstat = alterlist(audit_reply->summary_qual,10), sdisplay = ""
   IF ((audit_request->start_dt_tm > 0))
    sdisplay = format(audit_request->start_dt_tm,"@SHORTDATE;;Q")
   ENDIF
   i18n_sfrom, ":,", sdisplay,
   ",", ",", i18n_sfacility,
   ":,", sdisplay = uar_get_code_display(cnvtreal(audit_request->facility_cd)), sdisplay,
   row + 1
   IF ((audit_request->end_dt_tm > 0))
    sdisplay = format(audit_request->end_dt_tm,"@SHORTDATE;;Q")
   ENDIF
   i18n_sto, ":,", sdisplay,
   ",", ",", i18n_snurseunits,
   ":,", snurse_units, row + 1,
   i18n_salerts, ",", i18n_salertdatetime,
   ",", i18n_spatient, ",",
   i18n_slocation, ",", i18n_sfin,
   ",", i18n_smedidmethod, ",",
   i18n_smedication, ",", i18n_sordereddose,
   ",", i18n_soutcome, ",",
   i18n_suser, ",", i18n_sreason,
   ",", row + 1
  DETAIL
   username = "", username2 = ""
   IF (last_row != maa.rowid)
    last_row = maa.rowid, lidx = (lidx+ 1), lidx2 = (lidx2+ 1)
    IF (lidx2=10)
     dstat = alterlist(audit_reply->summary_qual,(lidx+ 10)), lidx2 = 0
    ENDIF
    IF (((mae.event_type_cd=notgiven_cd) OR (mae.event_type_cd=notdone_cd)) )
     IF (substring(1,4,cnvtstring(datetimediff(mae.updt_dt_tm,mame.scheduled_dt_tm,4),4,2))=patstring
     ("-*"))
      audit_reply->summary_qual[lidx].alert_type = i18n_searly
     ELSE
      audit_reply->summary_qual[lidx].alert_type = i18n_slate
     ENDIF
    ELSEIF (substring(1,4,cnvtstring(datetimediff(maa.event_dt_tm,mame.scheduled_dt_tm,4),4,2))=
    patstring("-*"))
     audit_reply->summary_qual[lidx].alert_type = i18n_searly
    ELSEIF (substring(1,4,cnvtstring(datetimediff(maa.event_dt_tm,mame.scheduled_dt_tm,4),4,2))=
    "0.00")
     audit_reply->summary_qual[lidx].alert_type = i18n_smisdateearlylate
    ELSE
     audit_reply->summary_qual[lidx].alert_type = i18n_slate
    ENDIF
    audit_reply->summary_qual[lidx].date = format(maa.event_dt_tm,"@SHORTDATE;;Q"), audit_reply->
    summary_qual[lidx].patient = p2.name_full_formatted, audit_reply->summary_qual[lidx].location =
    uar_get_code_display(maa.nurse_unit_cd),
    audit_reply->summary_qual[lidx].fin = cnvtalias(ea.alias,ea.alias_pool_cd), audit_reply->
    summary_qual[lidx].med_ident = mae.positive_med_ident_ind, audit_reply->summary_qual[lidx].
    order_id = mame.order_id,
    audit_reply->summary_qual[lidx].event_id = mame.event_id, audit_reply->summary_qual[lidx].
    encounter_id = mame.encounter_id, audit_reply->summary_qual[lidx].alert_id = maa
    .med_admin_alert_id,
    audit_reply->summary_qual[lidx].user = p1.name_full_formatted, username = trim(replace(p1
      .name_full_formatted,",","-",0),3), username2 = trim(replace(p2.name_full_formatted,",","-",0),
     3)
    IF (mame.reason_cd > 0)
     audit_reply->summary_qual[lidx].alert_reason = uar_get_code_display(mame.reason_cd)
    ELSEIF (textlen(trim(mame.freetext_reason,3)) > 0)
     audit_reply->summary_qual[lidx].alert_reason = mame.freetext_reason
    ELSE
     audit_reply->summary_qual[lidx].alert_reason = i18n_snoreasongiven
    ENDIF
    IF (mae.positive_med_ident_ind=0)
     smed_ident = i18n_sselect
    ELSE
     smed_ident = i18n_sscan
    ENDIF
    IF (mame.event_id=0.00)
     soutcome = i18n_scancelled, audit_reply->cancelled_cnt = (audit_reply->cancelled_cnt+ 1)
    ELSEIF (mae.event_type_cd=notgiven_cd)
     soutcome = i18n_snotgiven, audit_reply->not_given_cnt = (audit_reply->not_given_cnt+ 1)
    ELSEIF (mae.event_type_cd=notdone_cd)
     soutcome = i18n_snotdone, audit_reply->not_done_cnt = (audit_reply->not_done_cnt+ 1)
    ELSE
     soutcome = i18n_sadministered, audit_reply->administered_cnt = (audit_reply->administered_cnt+ 1
     )
    ENDIF
    audit_reply->summary_qual[lidx].alert_type, ",", audit_reply->summary_qual[lidx].date,
    ",", username2, ",",
    audit_reply->summary_qual[lidx].location, ",", audit_reply->summary_qual[lidx].fin,
    ",", smed_ident, ",",
    lparentordpos = locateval(lnum,1,parent_order->total_orders_cnt,mame.order_id,parent_order->qual[
     lnum].order_id), lnum = 0, lpos = parent_order->qual[lparentordpos].ordered_qual,
    lingr_cnt = ordered_ingrdnts->qual[lpos].total_ingr_cnt, dstat = alterlist(audit_reply->
     summary_qual[lidx].ordered_qual,lingr_cnt)
    IF (size(ordered_ingrdnts->qual[lpos].ingr_qual,5) > 0)
     WHILE (lnum < lingr_cnt)
       lnum = (lnum+ 1), audit_reply->summary_qual[lidx].ordered_qual[lnum].synonym_id =
       ordered_ingrdnts->qual[lpos].ingr_qual[lnum].synonym_id, sordereddose = trim(replace(
         ordered_ingrdnts->qual[lpos].ingr_qual[lnum].ordered_dose,",","-",0),3),
       audit_reply->summary_qual[lidx].ordered_qual[lnum].ordered_dose = ordered_ingrdnts->qual[lpos]
       .ingr_qual[lnum].ordered_dose, audit_reply->summary_qual[lidx].ordered_qual[lnum].syn_mne =
       ordered_ingrdnts->qual[lpos].ingr_qual[lnum].syn_mne
     ENDWHILE
     lnum = 0
     WHILE (lnum < lingr_cnt)
       lnum = (lnum+ 1)
       IF (lnum > 1)
        ",", ",", ",",
        ",", ",", ","
       ENDIF
       IF (textlen(trim(ordered_ingrdnts->qual[lpos].ingr_qual[lnum].syn_mne,3)) > 0)
        sdisplay = ordered_ingrdnts->qual[lpos].ingr_qual[lnum].syn_mne
       ELSE
        sdisplay = i18n_snotfound
       ENDIF
       sdisplay, ",", sordereddose,
       ","
       IF (lnum=1)
        soutcome, ",", username,
        ",", audit_reply->summary_qual[lidx].alert_reason
       ENDIF
       IF (lnum < lingr_cnt)
        row + 1
       ENDIF
     ENDWHILE
     IF (lnum=0)
      i18n_snotfound, ",", "",
      ",", soutcome, ",",
      username, ",", audit_reply->summary_qual[lidx].alert_reason
     ENDIF
    ELSE
     ldosepos = locateval(lnum,1,size(ordered_ingrdnts->qual[lpos].dose_qual,5),parent_order->qual[
      lparentordpos].temp_dose_seq,ordered_ingrdnts->qual[lpos].dose_qual[lnum].temp_dose_seq),
     audit_reply->summary_qual[lidx].ordered_qual[1].synonym_id = ordered_ingrdnts->qual[lpos].
     dose_qual[ldosepos].synonym_id, audit_reply->summary_qual[lidx].ordered_qual[1].ordered_dose =
     ordered_ingrdnts->qual[lpos].dose_qual[ldosepos].ordered_dose,
     audit_reply->summary_qual[lidx].ordered_qual[1].syn_mne = ordered_ingrdnts->qual[lpos].
     dose_qual[ldosepos].syn_mne, ",", ",",
     ",", ",", ",",
     ","
     IF (textlen(trim(ordered_ingrdnts->qual[lpos].dose_qual[ldosepos].syn_mne,3)) > 0)
      sdisplay = ordered_ingrdnts->qual[lpos].dose_qual[ldosepos].syn_mne
     ELSE
      sdisplay = i18n_snotfound
     ENDIF
     sdisplay, ",", ordered_ingrdnts->qual[lpos].dose_qual[ldosepos].ordered_dose,
     ",", soutcome, ",",
     username, ",", audit_reply->summary_qual[lidx].alert_reason,
     row + 1
    ENDIF
    row + 1
   ENDIF
  FOOT REPORT
   audit_reply->summary_qual_cnt = lidx, dstat = alterlist(audit_reply->summary_qual,lidx), row + 2,
   ",", ",", i18n_sallevents,
   ",", ",", ",",
   ",", i18n_searlylateevents, ",",
   ",", row + 1, ",",
   ",", i18n_sadministrations, ",",
   events_reply->administrations, ",", ",",
   ",", i18n_sadministered, ",",
   audit_reply->administered_cnt, ",", row + 1,
   ",", ",", i18n_snotdone,
   ",", events_reply->not_done, ",",
   ",", ",", i18n_snotdone,
   ",", audit_reply->not_done_cnt, ",",
   row + 1, ",", ",",
   i18n_snotgiven, ",", events_reply->not_given,
   ",", ",", ",",
   i18n_snotgiven, ",", audit_reply->not_given_cnt,
   ",", row + 1, ",",
   ",", i18n_stotal, ",",
   events_reply->total, ",", ",",
   ",", i18n_scancelled, ",",
   audit_reply->cancelled_cnt, ",", row + 1,
   ",", ",", ",",
   ",", ",", ",",
   i18n_stotalalerts, ",", lidx,
   ",", row + 1
  WITH outerjoin = d, maxcol = value(lnurse_units_length)
 ;end select
 IF (curqual=0)
  SELECT INTO value(coutput)
   FROM (dummyt d  WITH seq = 1)
   ORDER BY d.seq
   HEAD REPORT
    dstat = alterlist(audit_reply->summary_qual,10), sdisplay = ""
    IF ((audit_request->start_dt_tm > 0))
     sdisplay = format(audit_request->start_dt_tm,"@SHORTDATE;;Q")
    ENDIF
    i18n_sfrom, ":,", sdisplay,
    ",", ",", i18n_sfacility,
    ":,", sdisplay = uar_get_code_display(cnvtreal(audit_request->facility_cd)), sdisplay,
    row + 1
    IF ((audit_request->end_dt_tm > 0))
     sdisplay = format(audit_request->end_dt_tm,"@SHORTDATE;;Q")
    ENDIF
    i18n_sto, ":,", sdisplay,
    ",", ",", i18n_snurseunits,
    ":,", snurse_units, row + 1,
    ",", ",", ",",
    ",", ",", ",",
    "*****", i18n_snoresultsqualified, " *****"
   WITH nocounter, maxcol = value(lnurse_units_length)
  ;end select
 ENDIF
 CALL echo(build("File saved as ccluserdir:",coutput))
 SET last_mod = "006"
 SET mod_date = "11/27/2017"
 SET modify = nopredeclare
END GO
