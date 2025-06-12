CREATE PROGRAM bhs_rpt_implant_analysis:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date:" = "CURDATE",
  "End Date" = "CURDATE",
  "Scheduled Location" = "",
  "Case Start Lookback Days" = 7
  WITH outdev, ms_start_dt, ms_end_dt,
  ms_loc_list, ml_lookback_days
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE ms_loc_dir = vc WITH protect, constant(build(logical("bhscust"),
   "/ftp/bhs_rpt_implant_analysis/"))
 DECLARE ms_filename = vc WITH protect, constant(concat(ms_loc_dir,"lawson_implant_analysis_",trim(
    cnvtstring(rand(0),20),3),"_",format(cnvtdatetime(sysdate),"YYYYMMDDHHMMSS;;d"),
   ".csv"))
 DECLARE ms_filename2 = vc WITH protect, constant(concat(ms_loc_dir,"lawson_implant_analysis_rpt_",
   trim(cnvtstring(rand(0),20),3),"_",format(cnvtdatetime(sysdate),"YYYYMMDDHHMMSS;;d"),
   ".csv"))
 DECLARE ms_outdev = vc WITH protect, noconstant(value( $OUTDEV))
 DECLARE mf_beg_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE mf_end_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE mf_case_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE ml_ops_ind = i4 WITH protect, noconstant(0)
 DECLARE ms_data_type = vc WITH protect, noconstant("")
 DECLARE ms_temp_str = vc WITH protect, noconstant("")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_parse_str = vc WITH protect, noconstant(" 1=1 ")
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 DECLARE ml_stat = i4 WITH protect, noconstant(0)
 SET ms_data_type = reflect(parameter(4,0))
 IF (substring(1,1,ms_data_type) != "L")
  SET ms_parse_str = parameter(4,1)
  IF (size(trim(ms_parse_str)) > 0)
   IF (trim(ms_parse_str)=char(42))
    SET ms_parse_str = " 1=1 "
   ELSE
    SET ms_parse_str = concat(" sc.sched_surg_area_cd  = ",trim(ms_parse_str))
   ENDIF
  ELSE
   GO TO exit_program
  ENDIF
 ELSE
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_tmp_str = parameter(4,ml_cnt)
   IF (ml_cnt=1)
    SET ms_parse_str = concat(" sc.sched_surg_area_cd in (",trim(ms_tmp_str))
   ELSE
    SET ms_parse_str = concat(ms_parse_str,", ",trim(ms_tmp_str))
   ENDIF
  ENDFOR
  SET ms_parse_str = concat(ms_parse_str,")")
 ENDIF
 IF (ms_outdev="OPS")
  SET ml_ops_ind = 1
  SET mf_beg_dt_tm = cnvtdatetime((curdate - 1),0)
  SET mf_end_dt_tm = cnvtdatetime((curdate - 1),235959)
  SET mf_case_dt_tm = cnvtdatetime((curdate -  $ML_LOOKBACK_DAYS),0)
 ELSE
  SET mf_beg_dt_tm = cnvtdatetime(cnvtdate2( $MS_START_DT,"mm/dd/yyyy"),0)
  SET mf_end_dt_tm = cnvtdatetime(cnvtdate2( $MS_END_DT,"mm/dd/yyyy"),235959)
  SET mf_case_dt_tm = cnvtdatetime((cnvtdate2( $MS_START_DT,"mm/dd/yyyy") -  $ML_LOOKBACK_DAYS),0)
 ENDIF
 FREE RECORD m_data
 RECORD m_data(
   1 l_cnt = i4
   1 list[*]
     2 ms_case_start_dt = vc
     2 ms_case_num = vc
     2 ms_catalog_number = vc
     2 ms_department = vc
     2 ms_doc_type = vc
     2 ms_free_text_item_ind = vc
     2 ms_implant_item_description = vc
     2 ms_lot_num = vc
     2 ms_manufacturer = vc
     2 ms_model_num = vc
     2 ms_serial_num = vc
     2 ms_patient_name = vc
     2 ms_patient_cmrn = vc
     2 ms_pat_fname = vc
     2 ms_pat_lname = vc
     2 ms_lawson_num = vc
     2 ms_prim_procedure = vc
     2 ms_prim_surgeon = vc
     2 ms_surg_area = vc
     2 ms_num_of_implants = vc
 ) WITH protect
 SELECT INTO "nl:"
  case_start_date_time = format(cnvtdatetime(sc.surg_start_dt_tm),"@SHORTDATETIMENOSEC"),
  catalog_number = il.catalog_number, department = uar_get_code_display(sc.sched_surg_area_cd),
  document_type = uar_get_code_display(il.doc_type_cd), free_text_item_indicator = evaluate(
   cnvtstring(il.item_id),"0","Yes","No "), implant_item_description = evaluate(cnvtstring(il.item_id
    ),"0",il.free_text_item_desc,moim.description),
  lot_number = il.lot_number, manufacturer = il.manufacturer, model_number = il.model_number,
  serial_number = il.serial_number, or_case_number = sc.surg_case_nbr_formatted, patient_name = trim(
   p.name_full_formatted,3),
  lawson_number = moim.stock_nbr, primary_procedure = uar_get_code_display(scp1.surg_proc_cd),
  primary_surgeon = pr.name_full_formatted,
  surgical_area = uar_get_code_display(sc.sched_surg_area_cd), number_of_implants = count(il
   .implant_log_st_id)
  FROM sn_implant_log_st il,
   segment_header sh,
   surgical_case sc,
   encounter e,
   surg_case_procedure scp1,
   perioperative_document pd,
   person p,
   person_alias pa,
   sn_doc_ref sdr,
   mm_omf_item_master moim,
   prsnl pr
  PLAN (sc
   WHERE sc.surg_case_id != null
    AND sc.surg_case_id != 0
    AND parser(ms_parse_str)
    AND sc.surg_start_dt_tm > cnvtdatetime(mf_case_dt_tm))
   JOIN (il
   WHERE il.surg_case_id=sc.surg_case_id
    AND il.surg_case_id > 0
    AND il.updt_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_tm) AND cnvtdatetime(mf_end_dt_tm))
   JOIN (sh
   WHERE sh.segment_header_id=il.segment_header_id
    AND sh.discontinue_reason_cd=0)
   JOIN (p
   WHERE p.person_id=sc.person_id)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND pa.person_alias_type_cd=mf_cmrn_cd)
   JOIN (e
   WHERE e.encntr_id=sc.encntr_id)
   JOIN (pd
   WHERE pd.periop_doc_id=il.periop_doc_id
    AND pd.rec_ver_id > 0
    AND pd.doc_term_reason_cd=0)
   JOIN (sdr
   WHERE sdr.doc_type_cd=pd.doc_type_cd
    AND sdr.area_cd=pd.surg_area_cd)
   JOIN (scp1
   WHERE scp1.surg_case_id=sc.surg_case_id
    AND scp1.primary_proc_ind=1
    AND scp1.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=scp1.primary_surgeon_id)
   JOIN (moim
   WHERE (moim.item_master_id= Outerjoin(il.item_id)) )
  GROUP BY sc.surg_start_dt_tm, il.catalog_number, il.ecri_device_code,
   il.exp_date, il.item_id, evaluate(cnvtstring(il.item_id),"0",il.free_text_item_desc,moim
    .description),
   il.lot_number, il.manufacturer, il.other_identifier,
   il.quantity, il.serial_number, il.implant_site,
   sc.surg_case_id, sc.surg_case_nbr_formatted, sc.encntr_id,
   sc.person_id, p.person_id, p.name_first,
   p.name_last, p.name_full_formatted, pa.alias,
   scp1.surg_proc_cd, pr.name_full_formatted, sc.sched_surg_area_cd,
   evaluate(cnvtint(il.item_id),0,1,0), evaluate(cnvtstring(il.item_id),"0","Yes","No "), il
   .doc_type_cd,
   il.model_number, moim.item_master_id, moim.sys_item_nbr,
   moim.stock_nbr, il.free_text_item_desc
  ORDER BY surgical_area, case_start_date_time
  HEAD REPORT
   m_data->l_cnt = 0
  DETAIL
   m_data->l_cnt += 1, stat = alterlist(m_data->list,m_data->l_cnt), m_data->list[m_data->l_cnt].
   ms_case_start_dt = trim(format(cnvtdatetime(sc.surg_start_dt_tm),"YYYYMMDD;;q"),3),
   m_data->list[m_data->l_cnt].ms_case_num = trim(sc.surg_case_nbr_formatted,3), m_data->list[m_data
   ->l_cnt].ms_catalog_number = trim(il.catalog_number,3), m_data->list[m_data->l_cnt].ms_department
    = trim(uar_get_code_display(sc.sched_surg_area_cd),3),
   m_data->list[m_data->l_cnt].ms_doc_type = trim(uar_get_code_display(il.doc_type_cd),3), m_data->
   list[m_data->l_cnt].ms_free_text_item_ind = evaluate(cnvtstring(il.item_id),"0","Yes","No "),
   m_data->list[m_data->l_cnt].ms_implant_item_description = trim(implant_item_description,3),
   m_data->list[m_data->l_cnt].ms_lot_num = trim(il.lot_number,3), m_data->list[m_data->l_cnt].
   ms_manufacturer = trim(il.manufacturer,3), m_data->list[m_data->l_cnt].ms_model_num = trim(il
    .model_number,3),
   m_data->list[m_data->l_cnt].ms_serial_num = trim(il.serial_number,3), m_data->list[m_data->l_cnt].
   ms_patient_name = trim(p.name_full_formatted,3), m_data->list[m_data->l_cnt].ms_patient_cmrn =
   trim(pa.alias,3),
   m_data->list[m_data->l_cnt].ms_pat_fname = trim(p.name_first,3), m_data->list[m_data->l_cnt].
   ms_pat_lname = trim(p.name_last,3), m_data->list[m_data->l_cnt].ms_lawson_num = trim(moim
    .stock_nbr,3),
   m_data->list[m_data->l_cnt].ms_prim_procedure = trim(uar_get_code_display(scp1.surg_proc_cd),3),
   m_data->list[m_data->l_cnt].ms_prim_surgeon = trim(pr.name_full_formatted,3), m_data->list[m_data
   ->l_cnt].ms_surg_area = trim(uar_get_code_display(sc.sched_surg_area_cd),3),
   m_data->list[m_data->l_cnt].ms_num_of_implants = trim(cnvtstring(number_of_implants),3)
  WITH nocounter, separator = " ", format
 ;end select
 CALL echorecord(m_data)
 IF (ms_outdev="OPS")
  FREE RECORD frec
  RECORD frec(
    1 file_desc = i4
    1 file_offset = i4
    1 file_dir = i4
    1 file_name = vc
    1 file_buf = vc
  )
  SET frec->file_name = ms_filename
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  IF ((m_data->l_cnt=0))
   SET frec->file_buf = concat(" ",char(13))
   SET stat = cclio("WRITE",frec)
  ENDIF
  FOR (ml_cnt = 1 TO m_data->l_cnt)
   SET frec->file_buf = concat('"',m_data->list[ml_cnt].ms_prim_surgeon,'","',m_data->list[ml_cnt].
    ms_case_start_dt,'","',
    m_data->list[ml_cnt].ms_lot_num,'","',m_data->list[ml_cnt].ms_serial_num,'","',m_data->list[
    ml_cnt].ms_lawson_num,
    '","',m_data->list[ml_cnt].ms_manufacturer,'","',m_data->list[ml_cnt].ms_implant_item_description,
    '","',
    substring(1,1,m_data->list[ml_cnt].ms_pat_fname),'","',substring(1,1,m_data->list[ml_cnt].
     ms_pat_lname),'","',m_data->list[ml_cnt].ms_case_num,
    '","',m_data->list[ml_cnt].ms_patient_cmrn,'","',m_data->list[ml_cnt].ms_num_of_implants,'","',
    m_data->list[ml_cnt].ms_surg_area,'"',char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
  SET ms_dclcom = concat("cp -f ",ms_filename," ",build(ms_loc_dir,"IMPORDFILE.csv"))
  CALL echo(ms_dclcom)
  CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
  SET frec->file_name = ms_filename2
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = concat(
   '"Last Name","First Name","OR Case Number","Surgeon Name","Date of Service","Lot Number",',
   '"Lawson Item Number","Manufacturer Name","Manufacturer Number","Serial Number","Item Description",',
   '"Quantity Used","Surgical Area"',char(13))
  SET stat = cclio("WRITE",frec)
  FOR (ml_cnt = 1 TO m_data->l_cnt)
   SET frec->file_buf = concat('"',substring(1,1,m_data->list[ml_cnt].ms_pat_lname),'","',substring(1,
     1,m_data->list[ml_cnt].ms_pat_fname),'","',
    m_data->list[ml_cnt].ms_case_num,'","',m_data->list[ml_cnt].ms_prim_surgeon,'","',m_data->list[
    ml_cnt].ms_case_start_dt,
    '","',m_data->list[ml_cnt].ms_lot_num,'","',m_data->list[ml_cnt].ms_lawson_num,'","',
    m_data->list[ml_cnt].ms_manufacturer,'","',m_data->list[ml_cnt].ms_catalog_number,'","',m_data->
    list[ml_cnt].ms_serial_num,
    '","',m_data->list[ml_cnt].ms_implant_item_description,'","',m_data->list[ml_cnt].
    ms_num_of_implants,'","',
    m_data->list[ml_cnt].ms_surg_area,'"',char(13))
   SET stat = cclio("WRITE",frec)
  ENDFOR
  SET stat = cclio("CLOSE",frec)
 ELSE
  SELECT INTO value(ms_outdev)
   case_start_date_time = substring(1,250,m_data->list[d.seq].ms_case_start_dt), catalog_number =
   substring(1,250,m_data->list[d.seq].ms_catalog_number), department = substring(1,250,m_data->list[
    d.seq].ms_department),
   document_type = substring(1,250,m_data->list[d.seq].ms_doc_type), free_text_item_indicator =
   substring(1,250,m_data->list[d.seq].ms_free_text_item_ind), implant_item_description = substring(1,
    250,m_data->list[d.seq].ms_implant_item_description),
   lot_number = substring(1,250,m_data->list[d.seq].ms_lot_num), manufacturer = substring(1,250,
    m_data->list[d.seq].ms_manufacturer), model_number = substring(1,250,m_data->list[d.seq].
    ms_model_num),
   serial_number = substring(1,250,m_data->list[d.seq].ms_serial_num), or_case_number = substring(1,
    250,m_data->list[d.seq].ms_case_num), patient_name = substring(1,250,m_data->list[d.seq].
    ms_patient_name),
   lawson_number = substring(1,250,m_data->list[d.seq].ms_lawson_num), primary_procedure = substring(
    1,250,m_data->list[d.seq].ms_prim_procedure), primary_surgeon = substring(1,250,m_data->list[d
    .seq].ms_prim_surgeon),
   surgical_area = substring(1,250,m_data->list[d.seq].ms_surg_area), number_of_implants = substring(
    1,250,m_data->list[d.seq].ms_num_of_implants)
   FROM (dummyt d  WITH seq = m_data->l_cnt)
   WITH nocounter, separator = " ", format
  ;end select
 ENDIF
END GO
