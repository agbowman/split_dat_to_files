CREATE PROGRAM bhs_bsc_get_audit_info:dba
 SET modify = predeclare
 RECORD units(
   1 qual_cnt = i4
   1 qual[*]
     2 nurse_unit_cd = f8
 )
 DECLARE ndisplayperuser = i2 WITH protect, constant(0)
 DECLARE ndisplayperday = i2 WITH protect, constant(1)
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE getalertcountdata(null) = null
 DECLARE getidenterrordata(null) = null
 DECLARE getutilizationdata(null) = null
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE lidx2 = i4 WITH protect, noconstant(0)
 DECLARE lpatmismatchcnt = i4 WITH protect, noconstant(0)
 DECLARE loverdosecnt = i4 WITH protect, noconstant(0)
 DECLARE lunderdosecnt = i4 WITH protect, noconstant(0)
 DECLARE lincdrugformcnt = i4 WITH protect, noconstant(0)
 DECLARE lincformroutecnt = i4 WITH protect, noconstant(0)
 DECLARE ltasknotfoundcnt = i4 WITH protect, noconstant(0)
 DECLARE lexpiredmedcnt = i4 WITH protect, noconstant(0)
 DECLARE lpatnotidentcnt = i4 WITH protect, noconstant(0)
 DECLARE lmednotidentcnt = i4 WITH protect, noconstant(0)
 DECLARE leventcnt = i4 WITH protect, noconstant(0)
 DECLARE lpospatcnt = i4 WITH protect, noconstant(0)
 DECLARE lposmedcnt = i4 WITH protect, noconstant(0)
 DECLARE leventalertcnt = i4 WITH protect, noconstant(0)
 SET audit_reply->status_data.status = "f"
 IF ((audit_request->unit_cnt > 0))
  SET units->qual_cnt = audit_request->unit_cnt
  SET dstat = alterlist(units->qual,units->qual_cnt)
  FOR (x = 1 TO units->qual_cnt)
    SET units->qual[x].nurse_unit_cd = audit_request->unit[x].nurse_unit_cd
  ENDFOR
 ELSE
  SET audit_reply->status_data.subeventstatus[1].targetobjectvalue =
  "no nurse unit locations were passed in"
  GO TO exit_script
 ENDIF
 IF ((audit_request->display_ind=ndisplayperuser))
  SELECT INTO "nl:"
   FROM med_admin_alert maa,
    person p
   PLAN (maa
    WHERE maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
     audit_request->end_dt_tm)
     AND expand(lidx,1,units->qual_cnt,maa.nurse_unit_cd,units->qual[lidx].nurse_unit_cd)
     AND ((maa.prsnl_id+ 0) != 1))
    JOIN (p
    WHERE p.person_id=maa.prsnl_id)
   ORDER BY maa.prsnl_id
   HEAD maa.prsnl_id
    lpatmismatchcnt = 0, loverdosecnt = 0, lunderdosecnt = 0,
    lincdrugformcnt = 0, lincformroutecnt = 0, ltasknotfoundcnt = 0,
    lexpiredmedcnt = 0
   DETAIL
    CASE (uar_get_code_meaning(maa.alert_type_cd))
     OF "PATMISMATCH":
      lpatmismatchcnt = (lpatmismatchcnt+ 1)
     OF "OVERDOSE":
      loverdosecnt = (loverdosecnt+ 1)
     OF "UNDERDOSE":
      lunderdosecnt = (lunderdosecnt+ 1)
     OF "INCDRUGFORM":
      lincdrugformcnt = (lincdrugformcnt+ 1)
     OF "INCFORMROUTE":
      lincformroutecnt = (lincformroutecnt+ 1)
     OF "TASKNOTFOUND":
      ltasknotfoundcnt = (ltasknotfoundcnt+ 1)
     OF "EXPIREDMED":
      lexpiredmedcnt = (lexpiredmedcnt+ 1)
    ENDCASE
   FOOT  maa.prsnl_id
    lidx2 = locateval(lidx,1,audit_reply->summary_qual_cnt,maa.prsnl_id,audit_reply->summary_qual[
     lidx].prsnl_id)
    IF (lidx2 > 0)
     lidx = lidx2
    ELSE
     lidx = (audit_reply->summary_qual_cnt+ 1), dstat = alterlist(audit_reply->summary_qual,lidx),
     audit_reply->summary_qual_cnt = lidx
    ENDIF
    audit_reply->summary_qual[lidx].prsnl_id = p.person_id, audit_reply->summary_qual[lidx].
    name_full_formatted = p.name_full_formatted, audit_reply->summary_qual[lidx].pat_mismatch_cnt =
    lpatmismatchcnt,
    audit_reply->summary_qual[lidx].overdose_cnt = loverdosecnt, audit_reply->summary_qual[lidx].
    underdose_cnt = lunderdosecnt, audit_reply->summary_qual[lidx].inc_drug_form_cnt =
    lincdrugformcnt,
    audit_reply->summary_qual[lidx].inc_form_route_cnt = lincformroutecnt, audit_reply->summary_qual[
    lidx].task_not_found_cnt = ltasknotfoundcnt, audit_reply->summary_qual[lidx].expired_med_cnt =
    lexpiredmedcnt
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM med_admin_ident_error ie,
    person p
   PLAN (ie
    WHERE ie.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
     audit_request->end_dt_tm)
     AND expand(lidx,1,units->qual_cnt,ie.nurse_unit_cd,units->qual[lidx].nurse_unit_cd)
     AND ((ie.prsnl_id+ 0) != 1))
    JOIN (p
    WHERE p.person_id=ie.prsnl_id)
   ORDER BY ie.prsnl_id
   HEAD ie.prsnl_id
    lpatnotidentcnt = 0, lmednotidentcnt = 0
   DETAIL
    CASE (uar_get_code_meaning(ie.alert_type_cd))
     OF "PATNOTIDENT":
      lpatnotidentcnt = (lpatnotidentcnt+ 1)
     OF "MEDNOTIDENT":
      lmednotidentcnt = (lmednotidentcnt+ 1)
    ENDCASE
   FOOT  ie.prsnl_id
    lidx2 = locateval(lidx,1,audit_reply->summary_qual_cnt,ie.prsnl_id,audit_reply->summary_qual[lidx
     ].prsnl_id)
    IF (lidx2 > 0)
     lidx = lidx2
    ELSE
     lidx = (audit_reply->summary_qual_cnt+ 1), dstat = alterlist(audit_reply->summary_qual,lidx),
     audit_reply->summary_qual_cnt = lidx
    ENDIF
    audit_reply->summary_qual[lidx].prsnl_id = p.person_id, audit_reply->summary_qual[lidx].
    name_full_formatted = p.name_full_formatted, audit_reply->summary_qual[lidx].pat_not_ident_cnt =
    lpatnotidentcnt,
    audit_reply->summary_qual[lidx].med_not_ident_cnt = lmednotidentcnt
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM med_admin_event mae,
    person p
   PLAN (mae
    WHERE mae.beg_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
     audit_request->end_dt_tm)
     AND mae.end_dt_tm=mae.beg_dt_tm
     AND expand(lidx,1,units->qual_cnt,mae.nurse_unit_cd,units->qual[lidx].nurse_unit_cd)
     AND ((mae.prsnl_id+ 0) != 1))
    JOIN (p
    WHERE p.person_id=mae.prsnl_id)
   ORDER BY p.name_full_formatted
   HEAD p.name_full_formatted
    leventcnt = 0, lpospatcnt = 0, lposmedcnt = 0,
    leventalertcnt = 0
   DETAIL
    leventcnt = (leventcnt+ 1)
    IF (mae.positive_patient_ident_ind=1)
     lpospatcnt = (lpospatcnt+ 1)
    ENDIF
    IF (mae.positive_med_ident_ind=1)
     lposmedcnt = (lposmedcnt+ 1)
    ENDIF
    IF (mae.clinical_warning_cnt > 0)
     leventalertcnt = (leventalertcnt+ 1)
    ENDIF
   FOOT  p.name_full_formatted
    lidx2 = locateval(lidx,1,audit_reply->summary_qual_cnt,mae.prsnl_id,audit_reply->summary_qual[
     lidx].prsnl_id)
    IF (lidx2 > 0)
     lidx = lidx2
    ELSE
     lidx = (audit_reply->summary_qual_cnt+ 1), dstat = alterlist(audit_reply->summary_qual,lidx),
     audit_reply->summary_qual_cnt = lidx
    ENDIF
    audit_reply->summary_qual[lidx].prsnl_id = p.person_id, audit_reply->summary_qual[lidx].
    name_full_formatted = p.name_full_formatted, audit_reply->summary_qual[lidx].med_admin_event_cnt
     = leventcnt,
    audit_reply->summary_qual[lidx].positive_pat_cnt = lpospatcnt, audit_reply->summary_qual[lidx].
    positive_med_cnt = lposmedcnt, audit_reply->summary_qual[lidx].mae_alert_cnt = leventalertcnt
   WITH nocounter
  ;end select
 ELSEIF ((audit_request->display_ind=ndisplayperday))
  SELECT INTO "nl:"
   int_date = cnvtdate(maa.event_dt_tm)
   FROM med_admin_alert maa
   PLAN (maa
    WHERE maa.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
     audit_request->end_dt_tm)
     AND expand(lidx,1,units->qual_cnt,maa.nurse_unit_cd,units->qual[lidx].nurse_unit_cd)
     AND ((maa.prsnl_id+ 0) != 1))
   ORDER BY int_date
   HEAD int_date
    lpatmismatchcnt = 0, loverdosecnt = 0, lunderdosecnt = 0,
    lincdrugformcnt = 0, lincformroutecnt = 0, ltasknotfoundcnt = 0,
    lexpiredmedcnt = 0
   DETAIL
    CASE (uar_get_code_meaning(maa.alert_type_cd))
     OF "PATMISMATCH":
      lpatmismatchcnt = (lpatmismatchcnt+ 1)
     OF "OVERDOSE":
      loverdosecnt = (loverdosecnt+ 1)
     OF "UNDERDOSE":
      lunderdosecnt = (lunderdosecnt+ 1)
     OF "INCDRUGFORM":
      lincdrugformcnt = (lincdrugformcnt+ 1)
     OF "INCFORMROUTE":
      lincformroutecnt = (lincformroutecnt+ 1)
     OF "TASKNOTFOUND":
      ltasknotfoundcnt = (ltasknotfoundcnt+ 1)
     OF "EXPIREDMED":
      lexpiredmedcnt = (lexpiredmedcnt+ 1)
    ENDCASE
   FOOT  int_date
    lidx2 = locateval(lidx,1,audit_reply->summary_qual_cnt,int_date,audit_reply->summary_qual[lidx].
     internal_date)
    IF (lidx2 > 0)
     lidx = lidx2
    ELSE
     lidx = (audit_reply->summary_qual_cnt+ 1), dstat = alterlist(audit_reply->summary_qual,lidx),
     audit_reply->summary_qual_cnt = lidx
    ENDIF
    audit_reply->summary_qual[lidx].internal_date = int_date, audit_reply->summary_qual[lidx].
    date_string = format(int_date,"mm/dd/yyyy;;d"), audit_reply->summary_qual[lidx].pat_mismatch_cnt
     = lpatmismatchcnt,
    audit_reply->summary_qual[lidx].overdose_cnt = loverdosecnt, audit_reply->summary_qual[lidx].
    underdose_cnt = lunderdosecnt, audit_reply->summary_qual[lidx].inc_drug_form_cnt =
    lincdrugformcnt,
    audit_reply->summary_qual[lidx].inc_form_route_cnt = lincformroutecnt, audit_reply->summary_qual[
    lidx].task_not_found_cnt = ltasknotfoundcnt, audit_reply->summary_qual[lidx].expired_med_cnt =
    lexpiredmedcnt
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   int_date = cnvtdate(ie.event_dt_tm)
   FROM med_admin_ident_error ie
   PLAN (ie
    WHERE ie.event_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
     audit_request->end_dt_tm)
     AND expand(lidx,1,units->qual_cnt,ie.nurse_unit_cd,units->qual[lidx].nurse_unit_cd)
     AND ((ie.prsnl_id+ 0) != 1))
   ORDER BY int_date
   HEAD int_date
    lpatnotidentcnt = 0, lmednotidentcnt = 0
   DETAIL
    CASE (uar_get_code_meaning(ie.alert_type_cd))
     OF "PATNOTIDENT":
      lpatnotidentcnt = (lpatnotidentcnt+ 1)
     OF "MEDNOTIDENT":
      lmednotidentcnt = (lmednotidentcnt+ 1)
    ENDCASE
   FOOT  int_date
    lidx2 = locateval(lidx,1,audit_reply->summary_qual_cnt,int_date,audit_reply->summary_qual[lidx].
     internal_date)
    IF (lidx2 > 0)
     lidx = lidx2
    ELSE
     lidx = (audit_reply->summary_qual_cnt+ 1), dstat = alterlist(audit_reply->summary_qual,lidx),
     audit_reply->summary_qual_cnt = lidx
    ENDIF
    audit_reply->summary_qual[lidx].internal_date = int_date, audit_reply->summary_qual[lidx].
    date_string = format(int_date,"mm/dd/yyyy;;d"), audit_reply->summary_qual[lidx].pat_not_ident_cnt
     = lpatnotidentcnt,
    audit_reply->summary_qual[lidx].med_not_ident_cnt = lmednotidentcnt
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   int_date = cnvtdate(mae.beg_dt_tm)
   FROM med_admin_event mae
   PLAN (mae
    WHERE mae.beg_dt_tm BETWEEN cnvtdatetime(audit_request->start_dt_tm) AND cnvtdatetime(
     audit_request->end_dt_tm)
     AND mae.end_dt_tm=mae.beg_dt_tm
     AND expand(lidx,1,units->qual_cnt,mae.nurse_unit_cd,units->qual[lidx].nurse_unit_cd)
     AND ((mae.prsnl_id+ 0) != 1))
   ORDER BY int_date
   HEAD int_date
    leventcnt = 0, lpospatcnt = 0, lposmedcnt = 0,
    leventalertcnt = 0
   DETAIL
    leventcnt = (leventcnt+ 1)
    IF (mae.positive_patient_ident_ind=1)
     lpospatcnt = (lpospatcnt+ 1)
    ENDIF
    IF (mae.positive_med_ident_ind=1)
     lposmedcnt = (lposmedcnt+ 1)
    ENDIF
    IF (mae.clinical_warning_cnt > 0)
     leventalertcnt = (leventalertcnt+ 1)
    ENDIF
   FOOT  int_date
    lidx2 = locateval(lidx,1,audit_reply->summary_qual_cnt,int_date,audit_reply->summary_qual[lidx].
     internal_date)
    IF (lidx2 > 0)
     lidx = lidx2
    ELSE
     lidx = (audit_reply->summary_qual_cnt+ 1), dstat = alterlist(audit_reply->summary_qual,lidx),
     audit_reply->summary_qual_cnt = lidx
    ENDIF
    audit_reply->summary_qual[lidx].internal_date = int_date, audit_reply->summary_qual[lidx].
    date_string = format(int_date,"mm/dd/yyyy;;d"), audit_reply->summary_qual[lidx].
    med_admin_event_cnt = leventcnt,
    audit_reply->summary_qual[lidx].positive_pat_cnt = lpospatcnt, audit_reply->summary_qual[lidx].
    positive_med_cnt = lposmedcnt, audit_reply->summary_qual[lidx].mae_alert_cnt = leventalertcnt
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 FREE RECORD units
 SET audit_reply->status_data.status = "z"
 IF ((audit_reply->summary_qual_cnt > 0))
  SET audit_reply->status_data.status = "s"
 ENDIF
 SET modify = nopredeclare
END GO
