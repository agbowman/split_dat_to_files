CREATE PROGRAM bhs_rpt_pharm_batch_drops:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Please select the start date." = "CURDATE",
  "Please select the end date." = "CURDATE"
  WITH s_outdev, s_start_date, s_end_date
 FREE RECORD data
 RECORD data(
   1 l_cnt = i4
   1 l1[*]
     2 d_peformed_dt_tm = dq8
     2 d_dose_due_dt_tm = dq8
     2 s_patient_name = vc
     2 f_facility = f8
     2 f_nurse_unit = f8
     2 f_room = f8
     2 f_bed = f8
     2 s_ord_desc = vc
     2 s_ordered_as_mnemonic = vc
 )
 DECLARE mf_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_mrn = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4,"MRN")), protect
 DECLARE mf_bmccriticalcontinuous = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCCRITICALCONTINUOUS")), protect
 DECLARE mf_fmcpsychiatrymedicationnr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "FMCPSYCHIATRYMEDICATIONNR")), protect
 DECLARE mf_bmcmedicalcontinuous = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCMEDICALCONTINUOUS")), protect
 DECLARE mf_bmcmedicalivpb = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,"BMCMEDICALIVPB")),
 protect
 DECLARE mf_bmcmedicalmedication = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCMEDICALMEDICATION")), protect
 DECLARE mf_bmcsurgicalcontinuous = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCSURGICALCONTINUOUS")), protect
 DECLARE mf_bmcsurgicalivpb = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,"BMCSURGICALIVPB")),
 protect
 DECLARE mf_bmcsurgicalmedication = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCSURGICALMEDICATION")), protect
 DECLARE mf_fmcmedication = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,"FMCMEDICATION")),
 protect
 DECLARE mf_bmcpsychiatrymedication = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCPSYCHIATRYMEDICATION")), protect
 DECLARE mf_bmccriticalmedication = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCCRITICALMEDICATION")), protect
 DECLARE mf_bmcpsychiatrycontinuous = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCPSYCHIATRYCONTINUOUS")), protect
 DECLARE mf_bmcpsychiatryivpb = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCPSYCHIATRYIVPB")), protect
 DECLARE mf_bmcchildrensivpb = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,"BMCCHILDRENSIVPB")
  ), protect
 DECLARE mf_bmcchildrenscontinuous = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCCHILDRENSCONTINUOUS")), protect
 DECLARE mf_bmcwessoncontinuous = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCWESSONCONTINUOUS")), protect
 DECLARE mf_bmcwessonivpb = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,"BMCWESSONIVPB")),
 protect
 DECLARE mf_mlhcontinuous = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,"MLHCONTINUOUS")),
 protect
 DECLARE mf_mlhivpb = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,"MLHIVPB")), protect
 DECLARE mf_fmcpsychiatryivpb = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "FMCPSYCHIATRYIVPB")), protect
 DECLARE mf_fmcpsychiatrycontinuous = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "FMCPSYCHIATRYCONTINUOUS")), protect
 DECLARE mf_fmccontinuous = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,"FMCCONTINUOUS")),
 protect
 DECLARE mf_fmcivpb = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,"FMCIVPB")), protect
 DECLARE mf_bmccriticalivpb = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,"BMCCRITICALIVPB")),
 protect
 DECLARE mf_bmcwessonmedication = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCWESSONMEDICATION")), protect
 DECLARE mf_bmcchildrensmedication = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCCHILDRENSMEDICATION")), protect
 DECLARE mf_mlhmedication = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,"MLHMEDICATION")),
 protect
 DECLARE mf_fmcmedicationnr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,"FMCMEDICATIONNR")),
 protect
 DECLARE mf_mlhmedicationnr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,"MLHMEDICATIONNR")),
 protect
 DECLARE mf_bmcpsychiatrymedicationnr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCPSYCHIATRYMEDICATIONNR")), protect
 DECLARE mf_fmcpsychiatrymedication = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "FMCPSYCHIATRYMEDICATION")), protect
 DECLARE mf_bmcwessonmedicationnr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCWESSONMEDICATIONNR")), protect
 DECLARE mf_bmcchildrensmedicationnr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCCHILDRENSMEDICATIONNR")), protect
 DECLARE mf_bmccriticalmedicationnr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCCRITICALMEDICATIONNR")), protect
 DECLARE mf_bmcmedicalmedicationnr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCMEDICALMEDICATIONNR")), protect
 DECLARE mf_bmcsurgicalmedicationnr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCSURGICALMEDICATIONNR")), protect
 DECLARE mf_fmchbmfeeding = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,"FMCHBMFEEDING")),
 protect
 DECLARE mf_bmchbminfchfeeding = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCHBMINFCHFEEDING")), protect
 DECLARE mf_bmcchildrenspremixiv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCCHILDRENSPREMIXIV")), protect
 DECLARE mf_bmccriticalpremixiv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCCRITICALPREMIXIV")), protect
 DECLARE mf_bmcpsychiatrypremixiv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCPSYCHIATRYPREMIXIV")), protect
 DECLARE mf_bmcsurgicalpremixiv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCSURGICALPREMIXIV")), protect
 DECLARE mf_bmcwessonpremixiv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCWESSONPREMIXIV")), protect
 DECLARE mf_bmcmedicalpremixiv = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCMEDICALPREMIXIV")), protect
 DECLARE mf_bwhcontinous = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,"BWHCONTINOUS")),
 protect
 DECLARE mf_bwhivpb = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,"BWHIVPB")), protect
 DECLARE mf_bwhmedication = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,"BWHMEDICATION")),
 protect
 DECLARE mf_bwhmedicationnr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,"BWHMEDICATIONNR")),
 protect
 DECLARE mf_bwhpsychiatrycontinous = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BWHPSYCHIATRYCONTINOUS")), protect
 DECLARE mf_bwhpsychiatryivpb = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BWHPSYCHIATRYIVPB")), protect
 DECLARE mf_bwhpsychiatrymedication = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BWHPSYCHIATRYMEDICATION")), protect
 DECLARE mf_bwhpsychiatrymedicationnr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BWHPSYCHIATRYMEDICATIONNR")), protect
 DECLARE mf_bmcdoseedgelvp = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,"BMCDOSEEDGELVP")),
 protect
 DECLARE mf_bmcdoseedgemedicationnr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCDOSEEDGEMEDICATIONNR")), protect
 DECLARE mf_bmcpsychiatrydoseedgelvp = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCPSYCHIATRYDOSEEDGELVP")), protect
 DECLARE mf_bmcpsychiatrydoseedgemednr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCPSYCHIATRYDOSEEDGEMEDNR")), protect
 DECLARE mf_bmchbmnicufeedslabel = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,
   "BMCHBMNICUFEEDSLABEL")), protect
 DECLARE mf_bnhcontinuous = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,"BNHCONTINUOUS")),
 protect
 DECLARE mf_bmcivpbshortdate = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4035,"BMCIVPBSHORTDATE")
  ), protect
 DECLARE ml_cnt = i4 WITH noconstant(0), protect
 DECLARE ms_last_mod = vc WITH noconstant(""), protect
 DECLARE ms_start_date = vc WITH noconstant(""), protect
 DECLARE ms_end_date = vc WITH noconstant(""), protect
 SET ms_start_date = concat( $S_START_DATE," 00:00:00")
 SET ms_end_date = concat( $S_END_DATE," 23:59:59")
 SELECT INTO "nl:"
  FROM fill_print_hx f,
   fill_print_ord_hx fp,
   fill_batch_hx fb
  PLAN (f
   WHERE f.fill_batch_cd IN (mf_bmccriticalcontinuous, mf_fmcpsychiatrymedicationnr,
   mf_bmcmedicalcontinuous, mf_bmcmedicalivpb, mf_bmcmedicalmedication,
   mf_bmcsurgicalcontinuous, mf_bmcsurgicalivpb, mf_bmcsurgicalmedication, mf_fmcmedication,
   mf_bmcpsychiatrymedication,
   mf_bmccriticalmedication, mf_bmcpsychiatrycontinuous, mf_bmcpsychiatryivpb, mf_bmcchildrensivpb,
   mf_bmcchildrenscontinuous,
   mf_bmcwessoncontinuous, mf_bmcwessonivpb, mf_mlhcontinuous, mf_mlhivpb, mf_fmcpsychiatryivpb,
   mf_fmcpsychiatrycontinuous, mf_fmccontinuous, mf_fmcivpb, mf_bmccriticalivpb,
   mf_bmcwessonmedication,
   mf_bmcchildrensmedication, mf_mlhmedication, mf_fmcmedicationnr, mf_mlhmedicationnr,
   mf_bmcpsychiatrymedicationnr,
   mf_fmcpsychiatrymedication, mf_bmcwessonmedicationnr, mf_bmcchildrensmedicationnr,
   mf_bmccriticalmedicationnr, mf_bmcmedicalmedicationnr,
   mf_bmcsurgicalmedicationnr, mf_fmchbmfeeding, mf_bmchbminfchfeeding, mf_bmcchildrenspremixiv,
   mf_bmccriticalpremixiv,
   mf_bmcpsychiatrypremixiv, mf_bmcsurgicalpremixiv, mf_bmcwessonpremixiv, mf_bmcmedicalpremixiv,
   mf_bwhcontinous,
   mf_bwhivpb, mf_bwhmedication, mf_bwhmedicationnr, mf_bwhpsychiatrycontinous, mf_bwhpsychiatryivpb,
   mf_bwhpsychiatrymedication, mf_bwhpsychiatrymedicationnr, mf_bmcdoseedgelvp,
   mf_bmcdoseedgemedicationnr, mf_bmcpsychiatrydoseedgelvp,
   mf_bmcpsychiatrydoseedgemednr, mf_bmchbmnicufeedslabel, mf_bnhcontinuous, mf_bmcivpbshortdate))
   JOIN (fp
   WHERE fp.run_id=f.run_id
    AND fp.admin_dt_tm BETWEEN cnvtdatetime(ms_start_date) AND cnvtdatetime(ms_end_date)
    AND fp.order_id > 0.0)
   JOIN (fb
   WHERE fb.fill_hx_id=f.fill_hx_id)
  ORDER BY fb.end_dt_tm, fp.admin_dt_tm
  HEAD REPORT
   ml_cnt = 0
  DETAIL
   ml_cnt += 1, data->l_cnt = ml_cnt, stat = alterlist(data->l1,ml_cnt),
   data->l1[ml_cnt].d_peformed_dt_tm = fb.end_dt_tm, data->l1[ml_cnt].d_dose_due_dt_tm = fp
   .admin_dt_tm, data->l1[ml_cnt].s_patient_name = trim(fp.person_name_s,3),
   data->l1[ml_cnt].f_facility = fp.facility_cd, data->l1[ml_cnt].f_nurse_unit = fp.location_cd, data
   ->l1[ml_cnt].f_room = fp.room_cd,
   data->l1[ml_cnt].f_bed = fp.bed_cd, data->l1[ml_cnt].s_ord_desc = trim(fp.ord_desc,3), data->l1[
   ml_cnt].s_ordered_as_mnemonic = trim(fp.ordered_as_mnemonic,3)
  FOOT REPORT
   data->l_cnt = ml_cnt
  WITH nocounter
 ;end select
 IF (ml_cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO  $S_OUTDEV
  performed_date_time = format(data->l1[d1.seq].d_peformed_dt_tm,"dd-mmm-yyyy hh:mm;;d"),
  dose_due_date_time = format(data->l1[d1.seq].d_dose_due_dt_tm,"dd-mmm-yyyy hh:mm;;d"), patient_name
   = trim(substring(1,100,data->l1[d1.seq].s_patient_name),3),
  facility = trim(uar_get_code_display(data->l1[d1.seq].f_facility),3), nurse_unit = trim(
   uar_get_code_display(data->l1[d1.seq].f_nurse_unit),3), room = trim(uar_get_code_display(data->l1[
    d1.seq].f_room),3),
  bed = trim(uar_get_code_display(data->l1[d1.seq].f_bed),3), order_description = trim(substring(1,
    500,data->l1[d1.seq].s_ord_desc),3), ordered_as_mnemonic = trim(substring(1,500,data->l1[d1.seq].
    s_ordered_as_mnemonic),3)
  FROM (dummyt d1  WITH seq = value(data->l_cnt))
  PLAN (d1)
  WITH format, separator = " ", nocounter
 ;end select
 SET ms_last_mod = "000 - 08-Apr-2020 - Josh DeLeenheer/Matt Butler (HPG)"
#exit_script
 FREE RECORD data
END GO
