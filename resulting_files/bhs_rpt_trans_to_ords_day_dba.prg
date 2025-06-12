CREATE PROGRAM bhs_rpt_trans_to_ords_day:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "END date (00:00:00)" = "CURDATE",
  "Go back X days:" = "1"
  WITH outdev, s_end_dt, s_days
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD m_rec
 RECORD m_rec(
   1 accts[*]
     2 f_order_id = f8
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_fin = c30
     2 s_mrn = c30
     2 s_pat_name = c50
     2 s_encntr_type = c30
     2 s_facility = c20
     2 s_admit_dt_tm = c20
     2 s_disch_dt_tm = c20
     2 s_ord_mnem = c50
     2 s_orig_ord_dt_tm = c20
     2 s_ord_by = c50
     2 s_location = c30
     2 s_transfer_to = c50
     2 f_long_text_id = f8
     2 s_order_comment = c60
     2 s_order_status = c20
 ) WITH protect
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 )
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE mf_inpt_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_disch_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHIP"))
 DECLARE mf_expired_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDIP"))
 DECLARE mf_obs_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION"))
 DECLARE mf_disch_obs_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHOBV"))
 DECLARE mf_exp_obs_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDOBV"))
 DECLARE mf_daystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE mf_disch_day_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHDAYSTAY"))
 DECLARE mf_exp_day_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDDAYSTAY"))
 DECLARE mf_admitmd_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,
   "ADMITTINGPHYSICIAN"))
 DECLARE mf_attendmd_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,
   "ATTENDINGPHYSICIAN"))
 DECLARE mf_level_chg_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,"LEVELCHANGE"
   ))
 DECLARE mf_cat1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"TRANSFERTO"))
 DECLARE mf_cattype_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,
   "ADMITTRANSFERDISCHARGE"))
 DECLARE mf_acttype_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,
   "ADMITTRANSFERDISCHARGE"))
 DECLARE mf_ord_com_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",14,"ORDERCOMMENT"))
 CALL echo(concat("mf_cat1_cd: ",trim(cnvtstring(mf_cat1_cd))))
 CALL echo(concat("mf_cattype_cd: ",trim(cnvtstring(mf_cattype_cd))))
 CALL echo(concat("mf_acttype_cd: ",trim(cnvtstring(mf_acttype_cd))))
 CALL echo(concat("ord comment: ",trim(cnvtstring(mf_ord_com_cd))))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ms_filename = vc WITH protect, noconstant(build(logical("bhscust"),
   "/ftp/bhs_rpt_trans_to_ords_day/cis_transfer_orders.dat"))
 DECLARE ms_days = vc WITH protect, noconstant(concat( $S_DAYS,",D"))
 IF (validate(request->batch_selection))
  SET ms_end_dt_tm = trim(format(sysdate,"dd-mmm-yyyy;;d"))
  SET ms_end_dt_tm = concat(ms_end_dt_tm," 00:00:00")
 ELSE
  SET ms_end_dt_tm = concat( $S_END_DT," 00:00:00")
 ENDIF
 SET ms_beg_dt_tm = trim(format(cnvtlookbehind(value(ms_days),cnvtdatetime(ms_end_dt_tm)),
   "dd-mmm-yyyy hh:mm:ss;;d"))
 CALL echo(build2("beg: ",ms_beg_dt_tm))
 CALL echo(build2("end: ",ms_end_dt_tm))
 CALL echo("get new patients")
 SELECT INTO "nl:"
  FROM dummyt d,
   encntr_domain ed,
   encounter e,
   orders o,
   order_comment oc,
   order_detail od,
   order_action oa,
   prsnl pr1
  PLAN (ed
   WHERE ed.active_ind=1
    AND ed.active_status_cd=mf_active_cd)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.active_ind=1
    AND cnvtdatetime(ms_beg_dt_tm) <= e.reg_dt_tm
    AND e.reg_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND e.encntr_type_cd IN (mf_inpt_cd, mf_disch_cd, mf_expired_cd, mf_obs_cd, mf_disch_obs_cd,
   mf_exp_obs_cd))
   JOIN (o
   WHERE o.encntr_id=e.encntr_id
    AND o.person_id=e.person_id
    AND o.catalog_cd=mf_cat1_cd
    AND o.catalog_type_cd=mf_cattype_cd
    AND o.activity_type_cd=mf_acttype_cd)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=1)
   JOIN (pr1
   WHERE (pr1.person_id= Outerjoin(oa.action_personnel_id)) )
   JOIN (oc
   WHERE (oc.order_id= Outerjoin(o.order_id))
    AND (oc.comment_type_cd= Outerjoin(mf_ord_com_cd)) )
   JOIN (d)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id IN (777972, 777973, 777988, 12663)
    AND od.oe_field_display_value > " ")
  ORDER BY e.encntr_id, o.order_id
  HEAD REPORT
   pl_cnt = 0
  HEAD o.order_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->accts,5))
    stat = alterlist(m_rec->accts,(pl_cnt+ 20))
   ENDIF
   m_rec->accts[pl_cnt].f_order_id = o.order_id, m_rec->accts[pl_cnt].f_encntr_id = e.encntr_id,
   m_rec->accts[pl_cnt].f_person_id = e.person_id,
   m_rec->accts[pl_cnt].s_encntr_type = trim(uar_get_code_display(e.encntr_type_cd)), m_rec->accts[
   pl_cnt].s_facility = trim(uar_get_code_display(e.loc_facility_cd)), m_rec->accts[pl_cnt].
   s_admit_dt_tm = format(e.reg_dt_tm,"mm/dd/yyyy hh:mm;;d"),
   m_rec->accts[pl_cnt].s_disch_dt_tm = format(e.disch_dt_tm,"mm/dd/yyyy hh:mm;;d"), m_rec->accts[
   pl_cnt].s_ord_mnem = trim(o.order_mnemonic), m_rec->accts[pl_cnt].s_orig_ord_dt_tm = format(o
    .orig_order_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"),
   m_rec->accts[pl_cnt].s_ord_by = substring(1,30,pr1.name_full_formatted), m_rec->accts[pl_cnt].
   s_location = concat(trim(uar_get_code_display(e.loc_nurse_unit_cd))," ",trim(uar_get_code_display(
      e.loc_room_cd)),trim(uar_get_code_display(e.loc_bed_cd))), m_rec->accts[pl_cnt].s_transfer_to
    = trim(od.oe_field_display_value),
   m_rec->accts[pl_cnt].s_order_status = trim(uar_get_code_display(o.order_status_cd))
   IF (o.order_comment_ind > 0)
    m_rec->accts[pl_cnt].f_long_text_id = oc.long_text_id
   ELSE
    m_rec->accts[pl_cnt].s_order_comment = fillstring(60," ")
   ENDIF
  FOOT REPORT
   stat = alterlist(m_rec->accts,pl_cnt),
   CALL echo(build2("pat cnt: ",pl_cnt))
  WITH nocounter, outerjoin = d
 ;end select
 CALL echo("get encntr_type changes")
 SELECT INTO "nl:"
  FROM dummyt d,
   encounter e,
   orders o,
   order_comment oc,
   order_detail od,
   order_action oa,
   prsnl pr1
  PLAN (e
   WHERE cnvtdatetime(ms_beg_dt_tm) <= e.updt_dt_tm
    AND e.updt_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND e.reg_dt_tm < cnvtdatetime(ms_beg_dt_tm)
    AND e.active_ind=1
    AND e.encntr_type_cd IN (mf_inpt_cd, mf_disch_cd, mf_expired_cd, mf_obs_cd, mf_disch_obs_cd,
   mf_exp_obs_cd)
    AND  EXISTS (
   (SELECT
    elh.encntr_id
    FROM encntr_loc_hist elh
    WHERE elh.encntr_id=e.encntr_id
     AND elh.end_effective_dt_tm > cnvtdatetime(ms_beg_dt_tm)
     AND elh.encntr_type_cd != e.encntr_type_cd)))
   JOIN (o
   WHERE o.encntr_id=e.encntr_id
    AND o.person_id=e.person_id
    AND o.catalog_cd=mf_cat1_cd
    AND o.catalog_type_cd=mf_cattype_cd
    AND o.activity_type_cd=mf_acttype_cd)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=1)
   JOIN (pr1
   WHERE (pr1.person_id= Outerjoin(oa.action_personnel_id)) )
   JOIN (oc
   WHERE (oc.order_id= Outerjoin(o.order_id))
    AND (oc.comment_type_cd= Outerjoin(mf_ord_com_cd)) )
   JOIN (d)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id IN (777972, 777973, 777988, 12663)
    AND od.oe_field_display_value > " ")
  ORDER BY e.encntr_id, o.order_id
  HEAD REPORT
   pl_cnt = size(m_rec->accts,5)
  HEAD e.encntr_id
   null
  HEAD o.order_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->accts,5))
    stat = alterlist(m_rec->accts,(pl_cnt+ 10))
   ENDIF
   m_rec->accts[pl_cnt].f_order_id = o.order_id, m_rec->accts[pl_cnt].f_encntr_id = e.encntr_id,
   m_rec->accts[pl_cnt].f_person_id = e.person_id,
   m_rec->accts[pl_cnt].s_encntr_type = trim(uar_get_code_display(e.encntr_type_cd)), m_rec->accts[
   pl_cnt].s_facility = trim(uar_get_code_display(e.loc_facility_cd)), m_rec->accts[pl_cnt].
   s_admit_dt_tm = format(e.reg_dt_tm,"mm/dd/yyyy hh:mm;;d"),
   m_rec->accts[pl_cnt].s_disch_dt_tm = format(e.disch_dt_tm,"mm/dd/yyyy hh:mm;;d"), m_rec->accts[
   pl_cnt].s_ord_mnem = trim(o.order_mnemonic), m_rec->accts[pl_cnt].s_orig_ord_dt_tm = format(o
    .orig_order_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"),
   m_rec->accts[pl_cnt].s_ord_by = substring(1,30,pr1.name_full_formatted), m_rec->accts[pl_cnt].
   s_location = concat(trim(uar_get_code_display(e.loc_nurse_unit_cd))," ",trim(uar_get_code_display(
      e.loc_room_cd)),trim(uar_get_code_display(e.loc_bed_cd))), m_rec->accts[pl_cnt].s_transfer_to
    = trim(od.oe_field_display_value),
   m_rec->accts[pl_cnt].s_order_status = trim(uar_get_code_display(o.order_status_cd))
   IF (o.order_comment_ind > 0)
    m_rec->accts[pl_cnt].f_long_text_id = oc.long_text_id
   ELSE
    m_rec->accts[pl_cnt].s_order_comment = fillstring(60," ")
   ENDIF
  FOOT REPORT
   stat = alterlist(m_rec->accts,pl_cnt)
  WITH nocounter, outerjoin = d
 ;end select
 CALL echo("get new orders")
 SELECT INTO "nl:"
  FROM dummyt d,
   orders o,
   encounter e,
   order_comment oc,
   order_detail od,
   order_action oa,
   prsnl pr1
  PLAN (o
   WHERE cnvtdatetime(ms_beg_dt_tm) <= o.orig_order_dt_tm
    AND o.orig_order_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND o.catalog_cd=mf_cat1_cd
    AND o.catalog_type_cd=mf_cattype_cd
    AND o.activity_type_cd=mf_acttype_cd
    AND o.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.reg_dt_tm < cnvtdatetime(ms_beg_dt_tm)
    AND e.encntr_type_cd IN (mf_inpt_cd, mf_disch_cd, mf_expired_cd, mf_obs_cd, mf_disch_obs_cd,
   mf_exp_obs_cd)
    AND e.active_ind=1)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=1)
   JOIN (pr1
   WHERE (pr1.person_id= Outerjoin(oa.action_personnel_id)) )
   JOIN (oc
   WHERE (oc.order_id= Outerjoin(o.order_id))
    AND (oc.comment_type_cd= Outerjoin(mf_ord_com_cd)) )
   JOIN (d)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_id IN (777972, 777973, 777988, 12663)
    AND od.oe_field_display_value > " ")
  ORDER BY e.encntr_id, o.order_id
  HEAD REPORT
   pl_cnt = size(m_rec->accts,5)
  HEAD o.order_id
   IF (locateval(ml_idx,1,size(m_rec->accts,5),e.encntr_id,m_rec->accts[ml_idx].f_encntr_id)=0)
    pl_cnt += 1
    IF (pl_cnt > size(m_rec->accts,5))
     stat = alterlist(m_rec->accts,(pl_cnt+ 10))
    ENDIF
    m_rec->accts[pl_cnt].f_order_id = o.order_id, m_rec->accts[pl_cnt].f_encntr_id = e.encntr_id,
    m_rec->accts[pl_cnt].f_person_id = e.person_id,
    m_rec->accts[pl_cnt].s_encntr_type = trim(uar_get_code_display(e.encntr_type_cd)), m_rec->accts[
    pl_cnt].s_facility = trim(uar_get_code_display(e.loc_facility_cd)), m_rec->accts[pl_cnt].
    s_admit_dt_tm = format(e.reg_dt_tm,"mm/dd/yyyy hh:mm;;d"),
    m_rec->accts[pl_cnt].s_disch_dt_tm = format(e.disch_dt_tm,"mm/dd/yyyy hh:mm;;d"), m_rec->accts[
    pl_cnt].s_ord_mnem = trim(o.order_mnemonic), m_rec->accts[pl_cnt].s_orig_ord_dt_tm = format(o
     .orig_order_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"),
    m_rec->accts[pl_cnt].s_ord_by = substring(1,30,pr1.name_full_formatted), m_rec->accts[pl_cnt].
    s_location = concat(trim(uar_get_code_display(e.loc_nurse_unit_cd))," ",trim(uar_get_code_display
      (e.loc_room_cd)),trim(uar_get_code_display(e.loc_bed_cd))), m_rec->accts[pl_cnt].s_transfer_to
     = trim(od.oe_field_display_value),
    m_rec->accts[pl_cnt].s_order_status = trim(uar_get_code_display(o.order_status_cd))
    IF (o.order_comment_ind > 0)
     m_rec->accts[pl_cnt].f_long_text_id = oc.long_text_id
    ELSE
     m_rec->accts[pl_cnt].s_order_comment = fillstring(60," ")
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(m_rec->accts,pl_cnt)
  WITH nocounter
 ;end select
 CALL echo(build("size: ",size(m_rec->accts,5)))
 IF (size(m_rec->accts,5)=0)
  SELECT INTO value( $OUTDEV)
   HEAD REPORT
    "no data found"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->accts,5))),
   encntr_alias ea1,
   encntr_alias ea2,
   person p
  PLAN (d)
   JOIN (ea1
   WHERE (ea1.encntr_id=m_rec->accts[d.seq].f_encntr_id)
    AND ea1.active_ind=1
    AND ea1.encntr_alias_type_cd=mf_fin_cd)
   JOIN (ea2
   WHERE (ea2.encntr_id=m_rec->accts[d.seq].f_encntr_id)
    AND ea2.active_ind=1
    AND ea2.encntr_alias_type_cd=mf_mrn_cd)
   JOIN (p
   WHERE (p.person_id=m_rec->accts[d.seq].f_person_id)
    AND p.active_ind=1)
  HEAD d.seq
   m_rec->accts[d.seq].s_fin = trim(ea1.alias), m_rec->accts[d.seq].s_mrn = trim(ea2.alias), m_rec->
   accts[d.seq].s_pat_name = trim(p.name_full_formatted)
  WITH nocounter
 ;end select
 SELECT INTO value(ms_filename)
  order_id = m_rec->accts[d.seq].f_order_id, account = m_rec->accts[d.seq].s_fin, mrn = m_rec->accts[
  d.seq].s_mrn,
  name = m_rec->accts[d.seq].s_pat_name, type = m_rec->accts[d.seq].s_encntr_type, facility = m_rec->
  accts[d.seq].s_facility,
  admit_date = m_rec->accts[d.seq].s_admit_dt_tm, disch_date = m_rec->accts[d.seq].s_disch_dt_tm,
  order_menmonic = m_rec->accts[d.seq].s_ord_mnem,
  transfer_to = m_rec->accts[d.seq].s_transfer_to, order_comment = m_rec->accts[d.seq].
  s_order_comment, status = m_rec->accts[d.seq].s_order_status,
  order_dt_tm = m_rec->accts[d.seq].s_orig_ord_dt_tm, ordered_by = m_rec->accts[d.seq].s_ord_by,
  location = m_rec->accts[d.seq].s_location
  FROM (dummyt d  WITH seq = value(size(m_rec->accts,5)))
  PLAN (d)
  WITH nocounter, separator = "|", format
 ;end select
#exit_script
 IF (size(m_rec->accts,5)=0)
  SET dclcom = concat('"no data" | mailx -s "NO DATA FOUND - Transfer To Ord Daily ',trim(format(
     sysdate,"dd-mmm-yyyy hh:mm;;d")),'" ',"CISCore@bhs.org, feline.ogorman@bhs.org")
  SET len = size(trim(dclcom))
  SET status = 0
  SET stat = dcl(dclcom,len,status)
 ENDIF
 FREE RECORD m_rec
 SET reply->status_data[1].status = "S"
END GO
