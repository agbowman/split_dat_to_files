CREATE PROGRAM bsc_oudose_audit_detail_csv:dba
 SET modify = predeclare
 DECLARE username = vc WITH protect, noconstant("")
 DECLARE username2 = vc WITH protect, noconstant("")
 DECLARE ierroridx = i4 WITH protect, noconstant(0)
 DECLARE ierrorcnt = i4 WITH protect, noconstant(0)
 DECLARE iorderidx = i4 WITH protect, noconstant(0)
 DECLARE iordingrcnt = i4 WITH protect, noconstant(0)
 DECLARE last_row = c20 WITH protect, noconstant("00000000000000000000")
 DECLARE smed_ident = vc WITH protect, noconstant("")
 DECLARE soutcome = vc WITH protect, noconstant("")
 DECLARE sdisplay = vc WITH protect, noconstant("")
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE lidx2 = i4 WITH protect, noconstant(0)
 DECLARE lidx3 = i4 WITH protect, noconstant(0)
 DECLARE lidx4 = i4 WITH protect, noconstant(0)
 DECLARE lnum = i4 WITH protect, noconstant(0)
 DECLARE lnum2 = i4 WITH protect, noconstant(0)
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
    AND ((maa.alert_type_cd=overdose_cd) OR (maa.alert_type_cd=underdose_cd))
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
  ORDER BY maa.alert_type_cd, p2.name_last_key, p2.person_id,
   maa.rowid, mame.event_id, cnvtdatetime(mae.updt_dt_tm)
  HEAD REPORT
   last_row = "00000000000000000000", lidx = 0, lidx2 = 0,
   lidx3 = 0, lidx4 = 0, audit_reply->cancelled_cnt = 0,
   audit_reply->not_given_cnt = 0, audit_reply->not_done_cnt = 0, audit_reply->administered_cnt = 0,
   dstat = alterlist(audit_reply->summary_qual,10), sdisplay = ""
   IF ((audit_request->start_dt_tm > 0))
    sdisplay = format(audit_request->start_dt_tm,"MM/DD/YYYY;;D")
   ENDIF
   "From:,", sdisplay, ",",
   ",", "Facility:,", sdisplay = uar_get_code_display(cnvtreal(audit_request->facility_cd)),
   sdisplay, row + 1
   IF ((audit_request->end_dt_tm > 0))
    sdisplay = format(audit_request->end_dt_tm,"MM/DD/YYYY;;D")
   ENDIF
   "To:,", sdisplay, ",",
   ",", "Nurse Unit(s):,", snurse_units,
   row + 1, "Alert,", "Alert date/time,",
   "Patient,", "Location,", "FIN,",
   "Medication ID method,", "Medication,", "Ordered dose,",
   "Dose Administered,", "Outcome,", "User",
   "Reason", row + 1
  DETAIL
   username = "", username2 = ""
   IF (last_row != maa.rowid)
    last_row = maa.rowid, lidx = (lidx+ 1), lidx2 = (lidx2+ 1)
    IF (lidx2=10)
     dstat = alterlist(audit_reply->summary_qual,(lidx+ 10)), lidx2 = 0
    ENDIF
    audit_reply->summary_qual[lidx].alert_type = uar_get_code_display(maa.alert_type_cd), audit_reply
    ->summary_qual[lidx].date = format(maa.event_dt_tm,"MM/DD/YY HH:MM"), audit_reply->summary_qual[
    lidx].patient = p2.name_full_formatted,
    audit_reply->summary_qual[lidx].location = uar_get_code_display(maa.nurse_unit_cd), audit_reply->
    summary_qual[lidx].fin = cnvtalias(ea.alias,ea.alias_pool_cd), audit_reply->summary_qual[lidx].
    med_ident = mae.positive_med_ident_ind,
    audit_reply->summary_qual[lidx].order_id = mame.order_id, audit_reply->summary_qual[lidx].
    event_id = mame.event_id, audit_reply->summary_qual[lidx].mame_id = mame.med_admin_med_error_id,
    audit_reply->summary_qual[lidx].encounter_id = mame.encounter_id, audit_reply->summary_qual[lidx]
    .alert_id = maa.med_admin_alert_id, audit_reply->summary_qual[lidx].user = p1.name_full_formatted,
    username = trim(replace(p1.name_full_formatted,",","-",0),3), username2 = trim(replace(p2
      .name_full_formatted,",","-",0),3)
    IF (mae.positive_med_ident_ind=0)
     smed_ident = "Select"
    ELSE
     smed_ident = "Scan"
    ENDIF
    IF (mame.event_id=0.00)
     soutcome = "Cancelled", audit_reply->cancelled_cnt = (audit_reply->cancelled_cnt+ 1)
    ELSEIF (mae.event_type_cd=notgiven_cd)
     soutcome = "Not Given", audit_reply->not_given_cnt = (audit_reply->not_given_cnt+ 1)
    ELSEIF (mae.event_type_cd=notdone_cd)
     soutcome = "Not Done", audit_reply->not_done_cnt = (audit_reply->not_done_cnt+ 1)
    ELSE
     soutcome = "Administered", audit_reply->administered_cnt = (audit_reply->administered_cnt+ 1)
    ENDIF
    audit_reply->summary_qual[lidx].alert_type, ",", audit_reply->summary_qual[lidx].date,
    ",", username2, ",",
    audit_reply->summary_qual[lidx].location, ",", audit_reply->summary_qual[lidx].fin,
    ",", smed_ident, ",",
    ierroridx = locateval(lnum,1,parent_admined->total_ingr_cnt,mame.med_admin_med_error_id,
     parent_admined->qual[lnum].mame_id), iparentorderidx = locateval(lnum2,1,parent_order->
     total_orders_cnt,mame.order_id,parent_order->qual[lnum2].order_id), iorderidx = parent_order->
    qual[iparentorderidx].ordered_qual,
    ierrorcnt = parent_admined->qual[ierroridx].total_cnt, dstat = alterlist(audit_reply->
     summary_qual[lidx].admined_qual,ierrorcnt), lnum = 0
    WHILE (lnum < ierrorcnt)
      lnum = (lnum+ 1), audit_reply->summary_qual[lidx].admined_qual[lnum].synonym_id =
      parent_admined->qual[ierroridx].ingr_qual[lnum].synonym_id, audit_reply->summary_qual[lidx].
      admined_qual[lnum].syn_mne = parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,
      audit_reply->summary_qual[lidx].admined_qual[lnum].dose_admin = parent_admined->qual[ierroridx]
      .ingr_qual[lnum].dose_admin
    ENDWHILE
    iordingrcnt = ordered_ingrdnts->qual[iorderidx].total_ingr_cnt, dstat = alterlist(audit_reply->
     summary_qual[lidx].ordered_qual,iordingrcnt), lnum = 0
    IF (size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5) > 0)
     WHILE (lnum < iordingrcnt)
       lnum = (lnum+ 1), audit_reply->summary_qual[lidx].ordered_qual[lnum].synonym_id =
       ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum].synonym_id, audit_reply->summary_qual[lidx].
       ordered_qual[lnum].ordered_dose = ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum].
       ordered_dose,
       audit_reply->summary_qual[lidx].ordered_qual[lnum].syn_mne = ordered_ingrdnts->qual[iorderidx]
       .ingr_qual[lnum].syn_mne
     ENDWHILE
    ELSE
     ldosepos = locateval(lnum,1,size(ordered_ingrdnts->qual[iorderidx].dose_qual,5),parent_order->
      qual[iparentorderidx].temp_dose_seq,ordered_ingrdnts->qual[iorderidx].dose_qual[lnum].
      temp_dose_seq), audit_reply->summary_qual[lidx].ordered_qual[1].synonym_id = ordered_ingrdnts->
     qual[iorderidx].ingr_qual[lnum].synonym_id, audit_reply->summary_qual[lidx].ordered_qual[1].
     ordered_dose = ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum].ordered_dose,
     audit_reply->summary_qual[lidx].ordered_qual[1].syn_mne = ordered_ingrdnts->qual[iorderidx].
     ingr_qual[lnum].syn_mne
    ENDIF
    lnum = 1, lnum2 = 0
    WHILE (lnum2 < iordingrcnt)
      lnum2 = (lnum2+ 1)
      IF (lnum <= ierrorcnt)
       IF (size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5) > 0)
        WHILE (lnum <= size(parent_admined->qual[ierroridx].ingr_qual,5)
         AND lnum2 <= size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5)
         AND (parent_admined->qual[ierroridx].ingr_qual[lnum].synonym_id < ordered_ingrdnts->qual[
        iorderidx].ingr_qual[lnum2].synonym_id))
          parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne, ",", ",",
          parent_admined->qual[ierroridx].ingr_qual[lnum].dose_admin, ","
          IF (lnum=1
           AND lnum2=1)
           soutcome, ",", username
          ENDIF
          lnum = (lnum+ 1), row + 1, ",",
          ",", ",", ",",
          ",", ","
        ENDWHILE
       ELSE
        WHILE (lnum <= size(parent_admined->qual[ierroridx].ingr_qual,5)
         AND lnum2 <= size(ordered_ingrdnts->qual[iorderidx].dose_qual,5)
         AND (parent_admined->qual[ierroridx].ingr_qual[lnum].synonym_id < ordered_ingrdnts->qual[
        iorderidx].dose_qual[ldosepos].synonym_id))
          parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne, ",", ",",
          parent_admined->qual[ierroridx].ingr_qual[lnum].dose_admin, ","
          IF (lnum=1
           AND lnum2=1)
           soutcome, ",", username
          ENDIF
          lnum = (lnum+ 1), row + 1, ",",
          ",", ",", ",",
          ",", ","
        ENDWHILE
       ENDIF
       IF (lnum <= ierrorcnt)
        IF (size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5) > 0)
         IF ((parent_admined->qual[ierroridx].ingr_qual[lnum].synonym_id=ordered_ingrdnts->qual[
         iorderidx].ingr_qual[lnum2].synonym_id))
          IF (textlen(trim(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,3)) > 0)
           sdisplay = ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne
          ELSEIF (textlen(trim(parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,3)) > 0)
           sdisplay = parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne
          ELSE
           sdisplay = "Unknown"
          ENDIF
          sdisplay, ",", ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].ordered_dose,
          ",", parent_admined->qual[ierroridx].ingr_qual[lnum].dose_admin, ","
          IF (lnum=1
           AND lnum2=1)
           soutcome, ",", username
          ENDIF
          lnum = (lnum+ 1)
         ELSE
          IF (textlen(trim(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,3)) > 0)
           sdisplay = ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne
          ELSE
           sdisplay = "Unknown"
          ENDIF
          sdisplay, ",", ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].ordered_dose,
          ",", ","
          IF (lnum=1
           AND lnum2=1)
           soutcome, ",", username
          ENDIF
         ENDIF
        ELSE
         IF ((parent_admined->qual[ierroridx].ingr_qual[lnum].synonym_id=ordered_ingrdnts->qual[
         iorderidx].dose_qual[ldosepos].synonym_id))
          IF (textlen(trim(ordered_ingrdnts->qual[iorderidx].dose_qual[ldosepos].syn_mne,3)) > 0)
           sdisplay = ordered_ingrdnts->qual[iorderidx].dose_qual[ldosepos].syn_mne
          ELSEIF (textlen(trim(parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne,3)) > 0)
           sdisplay = parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne
          ELSE
           sdisplay = "Unknown"
          ENDIF
          sdisplay, ",", ordered_ingrdnts->qual[iorderidx].dose_qual[ldosepos].ordered_dose,
          ",", parent_admined->qual[ierroridx].ingr_qual[lnum].dose_admin, ","
          IF (lnum=1
           AND lnum2=1)
           soutcome, ",", username
          ENDIF
          lnum = (lnum+ 1)
         ELSE
          IF (textlen(trim(ordered_ingrdnts->qual[iorderidx].dose_qual[ldosepos].syn_mne,3)) > 0)
           sdisplay = ordered_ingrdnts->qual[iorderidx].dose_qual[ldosepos].syn_mne
          ELSE
           sdisplay = "Unknown"
          ENDIF
          sdisplay, ",", ordered_ingrdnts->qual[iorderidx].dose_qual[ldosepos].ordered_dose,
          ",", ","
          IF (lnum=1
           AND lnum2=1)
           soutcome, ",", username
          ENDIF
         ENDIF
        ENDIF
       ELSE
        IF (size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5) > 0)
         IF (textlen(trim(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,3)) > 0)
          sdisplay = ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne
         ELSE
          sdisplay = "Unknown"
         ENDIF
         sdisplay, ",", ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].ordered_dose,
         ",", ","
         IF (lnum=1
          AND lnum2=1)
          soutcome, ",", username
         ENDIF
        ENDIF
       ENDIF
      ELSE
       IF (size(ordered_ingrdnts->qual[iorderidx].ingr_qual,5) > 0)
        IF (textlen(trim(ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne,3)) > 0)
         sdisplay = ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].syn_mne
        ELSE
         sdisplay = "Unknown"
        ENDIF
        sdisplay, ",", ordered_ingrdnts->qual[iorderidx].ingr_qual[lnum2].ordered_dose,
        ",", ","
        IF (lnum=1
         AND lnum2=1)
         soutcome, ",", username
        ENDIF
       ENDIF
      ENDIF
      row + 1
      IF (lnum2 < iordingrcnt)
       ",", ",", ",",
       ",", ",", ","
      ENDIF
    ENDWHILE
    WHILE (lnum <= ierrorcnt)
      IF (lnum2 != 0)
       ",", ",", ",",
       ",", ",", ","
      ENDIF
      parent_admined->qual[ierroridx].ingr_qual[lnum].syn_mne, ",", ",",
      parent_admined->qual[ierroridx].ingr_qual[lnum].dose_admin, ","
      IF (lnum=1
       AND lnum2=1)
       soutcome, ",", username
      ENDIF
      lnum = (lnum+ 1), lnum2 = 2, row + 1
    ENDWHILE
   ENDIF
  FOOT REPORT
   audit_reply->summary_qual_cnt = lidx, dstat = alterlist(audit_reply->summary_qual,lidx), row + 2,
   ",", ",", "All Events,",
   ",", ",", ",",
   "Over/Underdose Events,", ",", row + 1,
   ",", ",", "Administrations,",
   events_reply->administrations, ",", ",",
   ",", "Administered,", audit_reply->administered_cnt,
   ",", row + 1, ",",
   ",", "Not Done,", events_reply->not_done,
   ",", ",", ",",
   "Not Done,", audit_reply->not_done_cnt, ",",
   row + 1, ",", ",",
   "Not Given,", events_reply->not_given, ",",
   ",", ",", "Not Given,",
   audit_reply->not_given_cnt, ",", row + 1,
   ",", ",", "Total,",
   events_reply->total, ",", ",",
   ",", "Cancelled,", audit_reply->cancelled_cnt,
   ",", row + 1, ",",
   ",", ",", ",",
   ",", ",", "Total Alerts,",
   lidx, ",", row + 1
  WITH outerjoin = d, maxcol = value(lnurse_units_length)
 ;end select
 IF (curqual=0)
  SELECT INTO value(coutput)
   FROM (dummyt d  WITH seq = 1)
   ORDER BY d.seq
   HEAD REPORT
    dstat = alterlist(audit_reply->summary_qual,10), sdisplay = ""
    IF ((audit_request->start_dt_tm > 0))
     sdisplay = format(audit_request->start_dt_tm,"MM/DD/YYYY;;D")
    ENDIF
    "From:,", sdisplay, ",",
    ",", "Facility:,", sdisplay = uar_get_code_display(cnvtreal(audit_request->facility_cd)),
    sdisplay, row + 1
    IF ((audit_request->end_dt_tm > 0))
     sdisplay = format(audit_request->end_dt_tm,"MM/DD/YYYY;;D")
    ENDIF
    "To:,", sdisplay, ",",
    ",", "Nurse Unit(s):,", snurse_units,
    row + 1, ",", ",",
    ",", ",", ",",
    ",", "***** No Results Qualified *****"
   WITH nocounter, maxcol = value(lnurse_units_length)
  ;end select
 ENDIF
 CALL echo(build("File saved as ccluserdir:",coutput))
 SET last_mod = "005"
 SET mod_date = "04/10/2017"
 SET modify = nopredeclare
END GO
