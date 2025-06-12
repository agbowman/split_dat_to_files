CREATE PROGRAM bhs_rpt_cms_autorization:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = 0,
  "Nurse Unit" = 0,
  "Order by" = "",
  "Email recipients (comma separated list)" = ""
  WITH outdev, f_facility_code, f_nurse_unit_cd,
  s_order_by, s_recipients
 FREE RECORD m_row_rec
 RECORD m_row_rec(
   1 l_row_cnt = i4
   1 rows[*]
     2 s_mrn = vc
     2 s_patient_name = vc
     2 s_facility = vc
     2 s_nurse_unit = vc
     2 s_room = vc
     2 s_admit_dt_tm = vc
     2 s_orig_order_dt_tm = vc
     2 s_order_status = vc
     2 s_supervising_provider = vc
     2 s_original_provider = vc
 )
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  ) WITH protect
 ENDIF
 DECLARE mf_oa_type_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3094")), protect
 DECLARE mf_act_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,
   "ADMITTRANSFERDISCHARGE"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE mf_daystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE mf_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_observation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")
  )
 DECLARE mf_emergency_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY"))
 DECLARE mf_adm_inpt_svs_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ADMITINPATIENTSERVICE"))
 DECLARE mf_sel_adm_inpt_svs_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "SELECTADMITINPATIENTSERVICE"))
 DECLARE mf_sts_inpat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "STATUSINPATIENT"))
 DECLARE mf_adm_med_to_inp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ADMITMEDICINETOINPTSERVICESTATUS"))
 DECLARE mf_assoctprof_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSASSOCIATEPROFESSIONAL"))
 DECLARE mf_bhassoctprof_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSBHASSOCIATEPROFESSIONAL"))
 DECLARE mf_bhpcoassoctprof_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSBHPCOASSOCIATEPROFESSIONAL"))
 DECLARE mf_bhsmidwife_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",88,"BHSMIDWIFE"))
 DECLARE mf_pcoassoctprof_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSPCOASSOCIATEPROFESSIONAL"))
 DECLARE mf_radassoctprof_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSRADASSOCIATEPROFESSIONAL"))
 DECLARE mf_bhsbhresident_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSBHRESIDENT"))
 DECLARE mf_bhsradresident_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",88,
   "BHSRADRESIDENT"))
 DECLARE mf_bhsresident_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",88,"BHSRESIDENT")
  )
 DECLARE mf_facility_cd = f8 WITH protect, constant(cnvtreal( $F_FACILITY_CODE))
 DECLARE ms_any_loc_ind = vc WITH protect, noconstant(" ")
 DECLARE ms_order_by_ind = vc WITH protect, noconstant(trim( $S_ORDER_BY))
 DECLARE ml_first_ind = i4 WITH protect, noconstant(0)
 DECLARE ms_loc_where = vc WITH protect, noconstant(" ")
 DECLARE ms_recipients = vc WITH protect, noconstant(" ")
 DECLARE ms_recipients2 = vc WITH protect, noconstant(" ")
 DECLARE ms_recipients3 = vc WITH protect, noconstant(" ")
 DECLARE ml_emailcount = i4 WITH protect, noconstant(0)
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ms_temp = vc WITH protect, noconstant(" ")
 DECLARE ms_filename = vc WITH protect, noconstant(" ")
 IF (validate(request->batch_selection))
  SET mn_ops = 1
  SET reply->status_data[1].status = "F"
  SELECT INTO "nl:"
   FROM dm_info di
   WHERE di.info_domain="BHS_RPT_CMS_AUTORIZATION"
   ORDER BY di.info_name
   HEAD REPORT
    ml_emailcount = 0
   DETAIL
    ml_emailcount = (ml_emailcount+ 1)
    IF (ml_emailcount < 11)
     IF (textlen(trim(ms_recipients,3)) < 1)
      ms_recipients = trim(di.info_name,3)
     ELSE
      ms_recipients = concat(ms_recipients,",",trim(di.info_name,3))
     ENDIF
    ELSEIF (ml_emailcount < 22)
     IF (textlen(trim(ms_recipients2,3)) < 1)
      ms_recipients2 = trim(di.info_name,3)
     ELSE
      ms_recipients2 = concat(ms_recipients2,",",trim(di.info_name,3))
     ENDIF
    ELSE
     IF (textlen(trim(ms_recipients3,3)) < 1)
      ms_recipients3 = trim(di.info_name,3)
     ELSE
      ms_recipients3 = concat(ms_recipients3,",",trim(di.info_name,3))
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SET ms_order_by_ind = "LOCATION"
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=220
     AND cv.active_ind=1
     AND cv.end_effective_dt_tm > sysdate
     AND cv.cdf_meaning="FACILITY"
     AND cv.display_key IN ("BMC", "BFMC", "BMLH", "BFMCINPTPSYCH", "BMCINPTPSYCH"))
   HEAD REPORT
    ms_loc_where = build2(" ed.loc_facility_cd in ("), ml_first_ind = 0
   DETAIL
    IF (ml_first_ind > 0)
     ms_loc_where = build2(ms_loc_where,",")
    ENDIF
    ml_first_ind = 1, ms_loc_where = build(ms_loc_where,cv.code_value)
   FOOT REPORT
    ms_loc_where = build(ms_loc_where,")")
   WITH nocounter
  ;end select
 ELSE
  SET ms_recipients = trim( $S_RECIPIENTS)
  IF (((findstring("@",ms_recipients)=0
   AND textlen(ms_recipients) > 0) OR (textlen(ms_recipients) < 10)) )
   SET ms_temp = "Recipient email is invalid"
   GO TO exit_script
  ENDIF
  SET ms_any_loc_ind = substring(1,1,reflect(parameter(3,0)))
  IF (ms_any_loc_ind="C")
   SET ms_loc_where = build2(" ed.loc_facility_cd = ",mf_facility_cd)
  ELSEIF (( $F_NURSE_UNIT_CD > 0))
   SET ms_loc_where = build2(" ed.loc_nurse_unit_cd = ", $F_NURSE_UNIT_CD)
  ELSE
   SET ms_loc_where = build2(" ed.loc_facility_cd = ",mf_facility_cd)
  ENDIF
 ENDIF
 SELECT
  IF (ms_order_by_ind="PHYSNAME")
   ORDER BY oa.supervising_provider_id, e.loc_facility_cd, e.loc_room_cd,
    e.loc_bed_cd
  ELSEIF (ms_order_by_ind="LOCATION")
   ORDER BY e.loc_facility_cd, e.loc_room_cd, e.loc_bed_cd
  ELSE
  ENDIF
  INTO  $OUTDEV
  pat_name = omf_get_pers_full(o.person_id), facility = uar_get_code_description(e.loc_facility_cd),
  nunit = uar_get_code_display(e.loc_nurse_unit_cd),
  room = uar_get_code_display(e.loc_room_cd), mrn = cnvtalias(omf_get_alias("mrn",e.encntr_id),
   omf_get_alias_pool_cd("mrn",319,e.encntr_id)), supervising_provider = trim(omf_get_prsnl_full(oa
    .supervising_provider_id)),
  original_provider = trim(omf_get_prsnl_full(oa.action_personnel_id))
  FROM orders o,
   order_action oa,
   encounter e,
   encntr_domain ed,
   prsnl p
  PLAN (ed
   WHERE parser(ms_loc_where)
    AND ed.end_effective_dt_tm > sysdate
    AND ed.loc_nurse_unit_cd > 0)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.disch_dt_tm = null
    AND e.encntr_type_cd IN (mf_daystay_cd, mf_inpatient_cd, mf_observation_cd, mf_emergency_cd))
   JOIN (o
   WHERE o.encntr_id=e.encntr_id
    AND o.activity_type_cd=mf_act_type_cd
    AND o.order_status_cd IN (mf_ordered_cd)
    AND o.catalog_cd IN (mf_adm_inpt_svs_cd, mf_sel_adm_inpt_svs_cd, mf_sts_inpat_cd,
   mf_adm_med_to_inp_cd)
    AND o.need_doctor_cosign_ind > 0)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=mf_oa_type_cd)
   JOIN (p
   WHERE oa.action_personnel_id=p.person_id
    AND p.position_cd IN (mf_assoctprof_cd, mf_bhassoctprof_cd, mf_bhpcoassoctprof_cd,
   mf_bhsmidwife_cd, mf_pcoassoctprof_cd,
   mf_radassoctprof_cd, mf_bhsbhresident_cd, mf_bhsradresident_cd, mf_bhsresident_cd))
  HEAD REPORT
   m_row_rec->l_row_cnt = 0
  DETAIL
   m_row_rec->l_row_cnt = (m_row_rec->l_row_cnt+ 1), stat = alterlist(m_row_rec->rows,m_row_rec->
    l_row_cnt), m_row_rec->rows[m_row_rec->l_row_cnt].s_mrn = mrn,
   m_row_rec->rows[m_row_rec->l_row_cnt].s_patient_name = pat_name, m_row_rec->rows[m_row_rec->
   l_row_cnt].s_facility = facility, m_row_rec->rows[m_row_rec->l_row_cnt].s_nurse_unit = nunit,
   m_row_rec->rows[m_row_rec->l_row_cnt].s_room = room, m_row_rec->rows[m_row_rec->l_row_cnt].
   s_admit_dt_tm = format(e.reg_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q"), m_row_rec->rows[m_row_rec->
   l_row_cnt].s_orig_order_dt_tm = format(o.orig_order_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q"),
   m_row_rec->rows[m_row_rec->l_row_cnt].s_supervising_provider = supervising_provider, m_row_rec->
   rows[m_row_rec->l_row_cnt].s_original_provider = original_provider
  WITH nocounter, separator = " ", format
 ;end select
 IF (curqual < 1)
  IF (mn_ops=0)
   SET ms_temp = concat("No orders found. Email will not be sent.")
   CALL echo(build("bhs_rpt_cms_autorization ",ms_temp))
  ENDIF
  GO TO exit_script
 ELSE
  SET ms_filename = build("bhs_cms_autorization_log",trim(format(sysdate,"ddmmyyyyhhmmss;;d")),".csv"
   )
  SELECT INTO value(ms_filename)
   FROM (dummyt d  WITH seq = value(size(m_row_rec->rows,5)))
   PLAN (d)
   HEAD REPORT
    ms_temp = concat("BHS_CMS_AUTORIZATION_LOG"), col 0, ms_temp,
    ms_temp = build("REPORT TIME=",trim(format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d"))), row + 1, col 0,
    ms_temp
    IF (ms_order_by_ind="LOCATION")
     ms_temp = concat("FACILITY,NURSE_UNIT,ROOM,SUPERVISING_PROVIDER,PATIENT_NAME,MRN,ADMIT_DT_TM",
      ",ORDERED_BY,ORIG_ORDER_DT_TM")
    ELSE
     ms_temp = concat("SUPERVISING_PROVIDER,FACILITY,NURSE_UNIT,ROOM,PATIENT_NAME,MRN,ADMIT_DT_TM",
      ",ORDERED_BY,ORIG_ORDER_DT_TM")
    ENDIF
    row + 1, col 0, ms_temp
   DETAIL
    row + 1
    IF (ms_order_by_ind="LOCATION")
     ms_temp = build('"',trim(m_row_rec->rows[d.seq].s_facility),'",','"',trim(m_row_rec->rows[d.seq]
       .s_nurse_unit),
      '",','"',trim(m_row_rec->rows[d.seq].s_room),'",','"',
      trim(m_row_rec->rows[d.seq].s_supervising_provider),'",','"',trim(m_row_rec->rows[d.seq].
       s_patient_name),'",',
      '"',trim(m_row_rec->rows[d.seq].s_mrn),'",','"',trim(m_row_rec->rows[d.seq].s_admit_dt_tm),
      '",','"',trim(m_row_rec->rows[d.seq].s_original_provider),'",','"',
      trim(m_row_rec->rows[d.seq].s_orig_order_dt_tm),'"')
    ELSE
     ms_temp = build('"',trim(m_row_rec->rows[d.seq].s_supervising_provider),'",','"',trim(m_row_rec
       ->rows[d.seq].s_facility),
      '",','"',trim(m_row_rec->rows[d.seq].s_nurse_unit),'",','"',
      trim(m_row_rec->rows[d.seq].s_room),'",','"',trim(m_row_rec->rows[d.seq].s_patient_name),'",',
      '"',trim(m_row_rec->rows[d.seq].s_mrn),'",','"',trim(m_row_rec->rows[d.seq].s_admit_dt_tm),
      '",','"',trim(m_row_rec->rows[d.seq].s_original_provider),'",','"',
      trim(m_row_rec->rows[d.seq].s_orig_order_dt_tm),'"')
    ENDIF
    col 0, ms_temp
   WITH nocounter, format = variable, formfeed = none,
    maxcol = 500
  ;end select
  SET ms_temp = build("BHS_CMS_AUTORIZATION_LOG-",trim(format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d")))
  IF (textlen(trim(ms_recipients,3)) > 0)
   EXECUTE bhs_ma_email_file
   IF (textlen(trim(ms_recipients3,3)) > 0)
    CALL emailfile(value(ms_filename),ms_filename,concat('"',ms_recipients,'"'),ms_temp,0)
    CALL emailfile(value(ms_filename),ms_filename,concat('"',ms_recipients2,'"'),ms_temp,0)
    CALL emailfile(value(ms_filename),ms_filename,concat('"',ms_recipients3,'"'),ms_temp,1)
   ELSEIF (textlen(trim(ms_recipients2,3)) > 0)
    CALL emailfile(value(ms_filename),ms_filename,concat('"',ms_recipients,'"'),ms_temp,0)
    CALL emailfile(value(ms_filename),ms_filename,concat('"',ms_recipients2,'"'),ms_temp,1)
   ELSE
    CALL emailfile(value(ms_filename),ms_filename,concat('"',ms_recipients,'"'),ms_temp,1)
   ENDIF
  ENDIF
  IF (mn_ops=0)
   SET ms_temp = build(m_row_rec->l_row_cnt," unsigned orders found. Email is sent.")
  ENDIF
 ENDIF
#exit_script
 IF (mn_ops=1)
  SET reply->status_data[1].status = "S"
 ELSE
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    col 0, ms_temp
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD m_row_rec
END GO
