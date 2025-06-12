CREATE PROGRAM bhs_rpt_iv_by_cdm:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH outdev, s_beg_dt, s_end_dt
 FREE RECORD m_rec
 RECORD m_rec(
   1 ord[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_fin = vc
     2 f_charge_item_id = f8
     2 s_charge_desc = vc
     2 f_service_dt_tm = f8
     2 s_service_dt_tm = vc
     2 s_cdm = vc
     2 s_quantity = vc
     2 s_charge_type = vc
     2 f_order_id = f8
     2 s_template_ord_flag = vc
     2 s_order_as_mnemonic = vc
     2 s_catalog = vc
     2 s_clin_disp_line = vc
     2 f_enc_fac = f8
     2 s_enc_fac = vc
     2 s_enc_unit = vc
     2 s_ord_unit = vc
     2 s_dept = vc
     2 f_admin_dt_tm = f8
     2 s_admin_dt_tm = vc
     2 s_admin_unit = vc
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 SET frec->file_buf = "w"
 IF (validate(reply->status_data[1].status)=0)
  RECORD reply(
    1 status_data[1]
      2 status = c1
  )
 ENDIF
 SET reply->status_data[1].status = "F"
 DECLARE ms_loc_dir = vc WITH protect, constant(build(logical("bhscust"),"/ftp/bhs_rpt_iv_by_cdm/"))
 DECLARE ms_filename = vc WITH protect, constant(concat(ms_loc_dir,"baystate_bh_daily_ivfluid_",trim(
    format(sysdate,"yyyymmdd;;d"),3),".csv"))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(concat(trim( $S_BEG_DT,3)," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(concat(trim( $S_END_DT,3)," 23:59:59"))
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE mn_ops = i2 WITH protect, noconstant(0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 IF (validate(request->batch_selection)=0)
  IF (((textlen(trim( $S_BEG_DT,3))=0) OR (textlen(trim( $S_END_DT,3))=0)) )
   SET ms_log = "Both dates must be filled out"
   GO TO exit_script
  ENDIF
  IF (cnvtdatetime( $S_BEG_DT) > cnvtdatetime( $S_END_DT))
   SET ms_log = "End date must be greater than Beg date"
   GO TO exit_script
  ENDIF
  SET ms_beg_dt_tm = concat(trim( $S_BEG_DT,3)," 00:00:00")
  SET ms_end_dt_tm = concat(trim( $S_END_DT,3)," 23:59:59")
 ELSE
  SET mn_ops = 1
  SET ms_beg_dt_tm = trim(format(datetimefind(cnvtlookbehind("1,D",sysdate),"D","B","B"),
    "dd-mmm-yyyy hh:mm:ss;;d"),3)
  SET ms_end_dt_tm = trim(format(datetimefind(cnvtlookbehind("1,D",sysdate),"D","E","E"),
    "dd-mmm-yyyy hh:mm:ss;;d"),3)
 ENDIF
 CALL echo(build2("beg dt: ",ms_beg_dt_tm," end dt: ",ms_end_dt_tm))
 SELECT INTO "nl:"
  FROM charge c,
   charge_mod cm,
   code_value cv,
   orders o,
   encounter e,
   encntr_alias ea
  PLAN (c
   WHERE c.service_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND c.active_ind=1
    AND c.offset_charge_item_id=0)
   JOIN (cm
   WHERE cm.charge_item_id=c.charge_item_id
    AND cm.field6 IN ("6288765", "6288766", "6288764", "6288738", "6288712",
   "6288713", "6288736", "6288737", "6288745", "6288703",
   "6288704", "6288731", "6288706", "6288707", "6288730",
   "6288724", "6288700", "6288723", "6288752", "6288751",
   "6288709", "6288710", "6288722", "6288725", "6287874",
   "6288772", "6288915", "6288916", "6286141", "6286141",
   "6288718", "6288719", "6288924", "6288931", "6288926",
   "6288927"))
   JOIN (cv
   WHERE cv.code_value=cm.field1_id
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate
    AND cv.code_set=14002
    AND cv.cdf_meaning="CDM_SCHED")
   JOIN (o
   WHERE (o.order_id= Outerjoin(c.order_id)) )
   JOIN (e
   WHERE e.encntr_id=c.encntr_id
    AND e.loc_facility_cd != 2583987.00)
   JOIN (ea
   WHERE ea.encntr_id=c.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=1077)
  ORDER BY c.encntr_id, c.order_id
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->ord,5))
    CALL alterlist(m_rec->ord,(pl_cnt+ 1000))
   ENDIF
   m_rec->ord[pl_cnt].f_person_id = c.person_id, m_rec->ord[pl_cnt].f_encntr_id = c.encntr_id, m_rec
   ->ord[pl_cnt].s_fin = trim(ea.alias,3),
   m_rec->ord[pl_cnt].f_charge_item_id = c.charge_item_id, m_rec->ord[pl_cnt].s_charge_desc = trim(c
    .charge_description,3), m_rec->ord[pl_cnt].f_service_dt_tm = c.service_dt_tm,
   m_rec->ord[pl_cnt].s_service_dt_tm = trim(format(c.service_dt_tm,"mm/dd/yy hh:mm;;d"),3), m_rec->
   ord[pl_cnt].s_cdm = trim(cm.field6,3), m_rec->ord[pl_cnt].s_quantity = trim(cnvtstring(ceil(c
      .item_quantity)),3),
   m_rec->ord[pl_cnt].s_charge_type = trim(uar_get_code_display(c.charge_type_cd),3), m_rec->ord[
   pl_cnt].f_order_id = o.order_id, m_rec->ord[pl_cnt].s_order_as_mnemonic = trim(o
    .ordered_as_mnemonic,3)
   IF (o.template_order_flag=0)
    m_rec->ord[pl_cnt].s_template_ord_flag = "None"
   ELSEIF (o.template_order_flag=1)
    m_rec->ord[pl_cnt].s_template_ord_flag = "Template"
   ELSEIF (o.template_order_flag=2)
    m_rec->ord[pl_cnt].s_template_ord_flag = "Order based"
   ELSEIF (o.template_order_flag=3)
    m_rec->ord[pl_cnt].s_template_ord_flag = "Task based"
   ELSEIF (o.template_order_flag=4)
    m_rec->ord[pl_cnt].s_template_ord_flag = "Rx based"
   ELSEIF (o.template_order_flag=5)
    m_rec->ord[pl_cnt].s_template_ord_flag = "Future recurring template"
   ELSEIF (o.template_order_flag=6)
    m_rec->ord[pl_cnt].s_template_ord_flag = "Future recurring instance"
   ELSEIF (o.template_order_flag=7)
    m_rec->ord[pl_cnt].s_template_ord_flag = "Protocol"
   ENDIF
   m_rec->ord[pl_cnt].s_catalog = trim(uar_get_code_display(o.catalog_cd),3), m_rec->ord[pl_cnt].
   s_clin_disp_line = trim(o.clinical_display_line,3), m_rec->ord[pl_cnt].s_clin_disp_line = replace(
    m_rec->ord[pl_cnt].s_clin_disp_line,char(10)," "),
   m_rec->ord[pl_cnt].s_clin_disp_line = replace(m_rec->ord[pl_cnt].s_clin_disp_line,char(13)," "),
   m_rec->ord[pl_cnt].s_enc_fac = trim(uar_get_code_display(e.loc_facility_cd),3), m_rec->ord[pl_cnt]
   .s_enc_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd),3),
   m_rec->ord[pl_cnt].s_dept = trim(uar_get_code_display(c.department_cd),3)
   IF ((m_rec->ord[pl_cnt].s_dept="*Surgical Services*"))
    m_rec->ord[pl_cnt].s_admin_unit = concat(m_rec->ord[pl_cnt].s_enc_fac," OR")
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->ord,pl_cnt)
  WITH nocounter
 ;end select
 CALL echo("get admin event reg orders")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->ord,5))),
   med_admin_event mae,
   encntr_loc_hist elh
  PLAN (d
   WHERE (m_rec->ord[d.seq].f_order_id > 0.0)
    AND (m_rec->ord[d.seq].s_template_ord_flag != "Template"))
   JOIN (mae
   WHERE (mae.order_id=m_rec->ord[d.seq].f_order_id))
   JOIN (elh
   WHERE (elh.encntr_id=m_rec->ord[d.seq].f_encntr_id)
    AND elh.active_ind=1)
  ORDER BY d.seq, mae.order_id
  HEAD REPORT
   CALL echo("head report 1"), pl_adm_match = 0
  HEAD d.seq
   null
  DETAIL
   IF (((mae.beg_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm) OR (mae.beg_dt_tm
    >= elh.beg_effective_dt_tm
    AND elh.end_effective_dt_tm=null)) )
    IF (((textlen(trim(m_rec->ord[d.seq].s_admin_dt_tm,3))=0) OR (abs(datetimediff(cnvtdatetime(m_rec
       ->ord[d.seq].f_service_dt_tm),mae.beg_dt_tm)) < abs(datetimediff(cnvtdatetime(m_rec->ord[d.seq
       ].f_service_dt_tm),cnvtdatetime(m_rec->ord[d.seq].f_admin_dt_tm))))) )
     m_rec->ord[d.seq].s_admin_unit = trim(uar_get_code_display(elh.loc_nurse_unit_cd),3), m_rec->
     ord[d.seq].f_admin_dt_tm = mae.beg_dt_tm, m_rec->ord[d.seq].s_admin_dt_tm = trim(format(mae
       .beg_dt_tm,"mm/dd/yy hh:mm;;d"),3)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("get admin event template orders")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->ord,5))),
   med_admin_event mae,
   encntr_loc_hist elh
  PLAN (d
   WHERE (m_rec->ord[d.seq].f_order_id > 0.0)
    AND (m_rec->ord[d.seq].s_template_ord_flag="Template"))
   JOIN (mae
   WHERE (mae.template_order_id=m_rec->ord[d.seq].f_order_id))
   JOIN (elh
   WHERE (elh.encntr_id=m_rec->ord[d.seq].f_encntr_id))
  ORDER BY d.seq, mae.order_id
  HEAD REPORT
   CALL echo("head report 2")
  HEAD d.seq
   null
  DETAIL
   IF (((mae.beg_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm) OR (mae.beg_dt_tm
    >= elh.beg_effective_dt_tm
    AND elh.end_effective_dt_tm=null)) )
    IF (((textlen(trim(m_rec->ord[d.seq].s_admin_dt_tm,3))=0) OR (abs(datetimediff(cnvtdatetime(m_rec
       ->ord[d.seq].f_service_dt_tm),mae.beg_dt_tm)) < abs(datetimediff(cnvtdatetime(m_rec->ord[d.seq
       ].f_service_dt_tm),cnvtdatetime(m_rec->ord[d.seq].f_admin_dt_tm))))) )
     m_rec->ord[d.seq].s_admin_unit = trim(uar_get_code_display(elh.loc_nurse_unit_cd),3), m_rec->
     ord[d.seq].f_admin_dt_tm = mae.beg_dt_tm, m_rec->ord[d.seq].s_admin_dt_tm = trim(format(mae
       .beg_dt_tm,"mm/dd/yy hh:mm;;d"),3)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (mn_ops=1)
  CALL echo(build2("ms_FILENAME: ",ms_filename))
  IF (size(m_rec->ord,5))
   SET frec->file_name = ms_filename
   SET frec->file_buf = "w"
   SET stat = cclio("OPEN",frec)
   SET ms_tmp = concat(
    '"person_id","encntr_id","fin","charge_item_id","charge_desc","service_dt_tm","cdm","quantity",',
    '"charge_type","order_id","template_order_flag","ordered_as_mnemonic","catalog","clin_disp_line",',
    '"enc_facility","enc_unit","department","admin_dt_tm","admin_unit"')
   SET frec->file_buf = concat(ms_tmp,char(13),char(10))
   SET stat = cclio("WRITE",frec)
   FOR (ml_loop = 1 TO size(m_rec->ord,5))
     SET ms_tmp = concat('"',trim(cnvtstring(m_rec->ord[ml_loop].f_person_id),3),'",','"',trim(
       cnvtstring(m_rec->ord[ml_loop].f_encntr_id),3),
      '",','"',m_rec->ord[ml_loop].s_fin,'",','"',
      trim(cnvtstring(m_rec->ord[ml_loop].f_charge_item_id),3),'",','"',m_rec->ord[ml_loop].
      s_charge_desc,'",',
      '"',m_rec->ord[ml_loop].s_service_dt_tm,'",','"',m_rec->ord[ml_loop].s_cdm,
      '",','"',m_rec->ord[ml_loop].s_quantity,'",','"',
      m_rec->ord[ml_loop].s_charge_type,'",','"',trim(cnvtstring(m_rec->ord[ml_loop].f_order_id),3),
      '",',
      '"',m_rec->ord[ml_loop].s_template_ord_flag,'",','"',m_rec->ord[ml_loop].s_order_as_mnemonic,
      '",','"',m_rec->ord[ml_loop].s_catalog,'",','"',
      m_rec->ord[ml_loop].s_clin_disp_line,'",','"',m_rec->ord[ml_loop].s_enc_fac,'",',
      '"',m_rec->ord[ml_loop].s_enc_unit,'",','"',m_rec->ord[ml_loop].s_dept,
      '",','"',m_rec->ord[ml_loop].s_admin_dt_tm,'",','"',
      m_rec->ord[ml_loop].s_admin_unit,'"')
     SET frec->file_buf = concat(ms_tmp,char(13),char(10))
     SET stat = cclio("WRITE",frec)
   ENDFOR
   SET stat = cclio("CLOSE",frec)
  ENDIF
 ELSE
  SELECT INTO value( $OUTDEV)
   person_id = m_rec->ord[d.seq].f_person_id, encntr_id = m_rec->ord[d.seq].f_encntr_id, fin =
   substring(1,20,m_rec->ord[d.seq].s_fin),
   charge_item_id = trim(cnvtstring(m_rec->ord[d.seq].f_charge_item_id),3), charge_desc = substring(1,
    75,m_rec->ord[d.seq].s_charge_desc), service_dt_tm = m_rec->ord[d.seq].s_service_dt_tm,
   cdm = substring(1,10,m_rec->ord[d.seq].s_cdm), quantity = substring(1,3,m_rec->ord[d.seq].
    s_quantity), charge_type = substring(1,25,m_rec->ord[d.seq].s_charge_type),
   order_id = trim(cnvtstring(m_rec->ord[d.seq].f_order_id),3), template_order_flag = substring(1,15,
    m_rec->ord[d.seq].s_template_ord_flag), ordered_as_mnemonic = substring(1,100,m_rec->ord[d.seq].
    s_order_as_mnemonic),
   catalog = substring(1,75,m_rec->ord[d.seq].s_catalog), clin_disp_line = substring(1,250,m_rec->
    ord[d.seq].s_clin_disp_line), enc_facility = substring(1,20,m_rec->ord[d.seq].s_enc_fac),
   enc_unit = substring(1,30,m_rec->ord[d.seq].s_enc_unit), department = substring(1,30,m_rec->ord[d
    .seq].s_dept), admin_dt_tm = m_rec->ord[d.seq].s_admin_dt_tm,
   admin_unit = substring(1,30,m_rec->ord[d.seq].s_admin_unit)
   FROM (dummyt d  WITH seq = value(size(m_rec->ord,5)))
   WITH nocounter, format, separator = " ",
    maxrow = 1
  ;end select
 ENDIF
 SET reply->status_data[1].status = "S"
#exit_script
 IF (mn_ops=0
  AND textlen(trim(ms_log,3)) > 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    ms_log
   WITH nocounter
  ;end select
 ENDIF
END GO
