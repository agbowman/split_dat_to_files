CREATE PROGRAM bhs_rpt_enc_aud_ord_full:dba
 FREE RECORD m_rec
 RECORD m_rec(
   1 accts[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 s_fin = c30
     2 s_mrn = c30
     2 s_pat_name = c50
     2 s_encntr_type = c30
     2 s_facility = c20
     2 s_admit_dt_tm = c20
     2 s_arrive_dt_tm = c20
     2 s_disch_dt_tm = c20
     2 s_ord_mnem = c50
     2 s_chg_status = c20
     2 s_orig_ord_dt_tm = c20
     2 s_ord_by = c50
     2 s_attending = c50
     2 s_admitting = c50
     2 s_med_service = c50
     2 s_location = c30
 ) WITH protect
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 )
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
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
 DECLARE mf_cat1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "SELECTADMITINPATIENTSERVICE"))
 DECLARE mf_cat2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ADMITINPATIENTSERVICE"))
 DECLARE mf_cat3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ADMITMEDICINETOINPTSERVICESTATUS"))
 DECLARE mf_cat4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "REASSIGNPTSTATUSOBSERVATIONTOINPT"))
 DECLARE mf_cat5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"STATUSINPATIENT"))
 DECLARE mf_cat6_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ASSIGNOBSERVATIONSTATUS"))
 DECLARE mf_cat7_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "SELECTOBSERVATIONSTATUS"))
 DECLARE mf_cat8_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "REASSIGNPTSTATUSINPTTOOBSERVATION"))
 DECLARE mf_cat9_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ASSIGNMEDICALADMITOBSERVATIONSTATUS"))
 DECLARE mf_cat10_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "STATUSOBSERVATIONPATIENT"))
 DECLARE mf_cat11_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "STATUSDAYSTAYPATIENT"))
 DECLARE mf_cat12_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ASSIGNDAYSTAYSTATUS"))
 DECLARE mf_cat13_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "SELECTDAYSTAYSTATUS"))
 DECLARE mf_cat14_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "STATUSCHANGEPATIENTTYPETO"))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_filename = vc WITH protect, noconstant("cisencounter_orders90.dat")
 SET ms_end_dt_tm = concat(trim(format(sysdate,"dd-mmm-yyyy;;d"))," 00:00:00")
 SET ms_beg_dt_tm = trim(format(cnvtlookbehind("90,D",cnvtdatetime(ms_end_dt_tm)),
   "dd-mmm-yyyy hh:mm:ss;;d"))
 CALL echo(build2("beg: ",ms_beg_dt_tm))
 CALL echo(build2("end: ",ms_end_dt_tm))
 SELECT INTO "nl:"
  FROM encounter e,
   orders o,
   order_detail od,
   order_action oa,
   prsnl pr1
  PLAN (e
   WHERE cnvtdatetime(ms_beg_dt_tm) <= e.reg_dt_tm
    AND e.reg_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND e.encntr_type_cd IN (mf_inpt_cd, mf_disch_cd, mf_expired_cd, mf_obs_cd, mf_disch_obs_cd,
   mf_exp_obs_cd))
   JOIN (o
   WHERE o.encntr_id=e.encntr_id
    AND o.catalog_cd IN (mf_cat1_cd, mf_cat2_cd, mf_cat3_cd, mf_cat4_cd, mf_cat5_cd,
   mf_cat6_cd, mf_cat7_cd, mf_cat8_cd, mf_cat9_cd, mf_cat10_cd,
   mf_cat11_cd, mf_cat12_cd, mf_cat13_cd, mf_cat14_cd))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=1)
   JOIN (od
   WHERE (od.order_id= Outerjoin(o.order_id))
    AND (od.oe_field_id= Outerjoin(mf_level_chg_cd)) )
   JOIN (pr1
   WHERE (pr1.person_id= Outerjoin(oa.action_personnel_id)) )
  ORDER BY e.encntr_id, o.order_id
  HEAD REPORT
   pl_cnt = 0
  HEAD o.order_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->accts,5))
    stat = alterlist(m_rec->accts,(pl_cnt+ 20))
   ENDIF
   m_rec->accts[pl_cnt].f_encntr_id = e.encntr_id, m_rec->accts[pl_cnt].f_person_id = e.person_id,
   m_rec->accts[pl_cnt].s_encntr_type = trim(uar_get_code_display(e.encntr_type_cd)),
   m_rec->accts[pl_cnt].s_facility = trim(uar_get_code_display(e.loc_facility_cd)), m_rec->accts[
   pl_cnt].s_admit_dt_tm = format(e.reg_dt_tm,"mm/dd/yyyy hh:mm;;d"), m_rec->accts[pl_cnt].
   s_arrive_dt_tm = format(e.arrive_dt_tm,"mm/dd/yyyy hh:mm;;d"),
   m_rec->accts[pl_cnt].s_disch_dt_tm = format(e.disch_dt_tm,"mm/dd/yyyy hh:mm;;d"), m_rec->accts[
   pl_cnt].s_med_service = uar_get_code_display(e.med_service_cd), m_rec->accts[pl_cnt].s_ord_mnem =
   trim(o.order_mnemonic),
   m_rec->accts[pl_cnt].s_orig_ord_dt_tm = format(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm:ss;;d"), m_rec
   ->accts[pl_cnt].s_ord_by = substring(1,30,pr1.name_full_formatted), m_rec->accts[pl_cnt].
   s_location = concat(trim(uar_get_code_display(e.loc_nurse_unit_cd))," ",trim(uar_get_code_display(
      e.loc_room_cd)),trim(uar_get_code_display(e.loc_bed_cd)))
   IF (od.oe_field_id=mf_level_chg_cd
    AND trim(od.oe_field_display_value) > " ")
    m_rec->accts[pl_cnt].s_chg_status = trim(od.oe_field_display_value)
   ENDIF
  FOOT REPORT
   stat = alterlist(m_rec->accts,pl_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->accts,5))),
   encntr_prsnl_reltn epr,
   prsnl pr
  PLAN (d)
   JOIN (epr
   WHERE (epr.encntr_id=m_rec->accts[d.seq].f_encntr_id)
    AND epr.encntr_prsnl_r_cd IN (mf_attendmd_cd, mf_admitmd_cd))
   JOIN (pr
   WHERE pr.person_id=epr.prsnl_person_id)
  ORDER BY d.seq, epr.end_effective_dt_tm DESC
  DETAIL
   IF (epr.encntr_prsnl_r_cd=mf_attendmd_cd
    AND trim(m_rec->accts[d.seq].s_attending) <= " ")
    m_rec->accts[d.seq].s_attending = substring(1,30,pr.name_full_formatted)
   ELSEIF (epr.encntr_prsnl_r_cd=mf_admitmd_cd
    AND trim(m_rec->accts[d.seq].s_admitting) <= " ")
    m_rec->accts[d.seq].s_admitting = substring(1,30,pr.name_full_formatted)
   ENDIF
  WITH nocounter
 ;end select
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
  account = m_rec->accts[d.seq].s_fin, mrn = m_rec->accts[d.seq].s_mrn, name = m_rec->accts[d.seq].
  s_pat_name,
  type = m_rec->accts[d.seq].s_encntr_type, facility = m_rec->accts[d.seq].s_facility, admit_date =
  m_rec->accts[d.seq].s_admit_dt_tm,
  arrive_date = m_rec->accts[d.seq].s_arrive_dt_tm, disch_date = m_rec->accts[d.seq].s_disch_dt_tm,
  order_menmonic = m_rec->accts[d.seq].s_ord_mnem,
  status = m_rec->accts[d.seq].s_chg_status, order_dt_tm = m_rec->accts[d.seq].s_orig_ord_dt_tm,
  ordered_by = m_rec->accts[d.seq].s_ord_by,
  attending_physician = m_rec->accts[d.seq].s_attending, admitting_physician = m_rec->accts[d.seq].
  s_admitting, medsrv = m_rec->accts[d.seq].s_med_service,
  location = m_rec->accts[d.seq].s_location
  FROM (dummyt d  WITH seq = value(size(m_rec->accts,5)))
  PLAN (d)
  WITH nocounter, separator = "|", format
 ;end select
 SET dclcom = concat("$cust_script/bhs_ftp_file.ksh ",ms_filename,
  " transfer.baystatehealth.org 'bhs/cisftp' C!sftp01 BHAuditServicesSensitive")
 CALL echo(dclcom)
 SET status = 0
 SET len = size(trim(dclcom))
 CALL dcl(dclcom,len,status)
 CALL pause(5)
 CALL echo("deleting email file")
 IF (((stat=0) OR (findfile(ms_filename)=1)) )
  CALL echo("unable to delete file")
 ELSE
  CALL echo("file deleted")
 ENDIF
 SET reply->status_data[1].status = "S"
#exit_script
 FREE RECORD m_rec
END GO
