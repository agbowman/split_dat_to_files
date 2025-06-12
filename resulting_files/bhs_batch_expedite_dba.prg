CREATE PROGRAM bhs_batch_expedite:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Update Method:" = "accession",
  "Enter Single Accession Number OR .csv Filename" = "",
  "" = 0
  WITH outdev, s_updt_type, s_accession,
  f_template_id
 IF (validate(requestin)=0)
  RECORD requestin(
    1 list_0[*]
      2 accession = vc
      2 orderable = vc
      2 complete_dt_tm = vc
      2 service_resource = vc
      2 report_status = vc
      2 username = vc
      2 position = vc
      2 ordering_physician = vc
      2 patient = vc
      2 fin_nbr = vc
      2 fax = vc
  )
 ENDIF
 FREE RECORD request
 RECORD request(
   1 qual[1]
     2 request_type = i4
     2 scope_flag = i2
     2 person_id = f8
     2 encntr_id = f8
     2 order_id = f8
     2 accession_nbr = c20
     2 chart_format_id = f8
     2 distribution_id = f8
     2 dist_run_type_cd = f8
     2 reader_group = c15
     2 dist_run_dt_tm = dq8
     2 dist_initiator_ind = i2
     2 dist_terminator_ind = i2
     2 date_range_ind = i2
     2 begin_dt_tm = dq8
     2 end_dt_tm = dq8
     2 page_range_ind = i2
     2 begin_page = i4
     2 end_page = i4
     2 print_complete_flag = i2
     2 chart_pending_flag = i2
     2 output_dest_cd = f8
     2 addl_copies = i4
     2 output_device_cd = f8
     2 rrd_deliver_dt_tm = dq8
     2 rrd_country_access = c3
     2 rrd_area_code = c10
     2 rrd_exchange = c10
     2 rrd_phone_suffix = c30
     2 trigger_id = f8
     2 trigger_type = c15
     2 prsnl_person_id = f8
     2 prsnl_person_r_cd = f8
     2 event_ind = i2
     2 file_storage_cd = f8
     2 file_storage_location = vc
     2 dest_ind = i2
     2 dest_id = f8
     2 dest_txt = vc
     2 requestor_ind = i2
     2 requestor_id = f8
     2 requestor_txt = vc
     2 reason_cd = f8
     2 comments = vc
     2 pco_ind = i2
     2 input_device = vc
     2 trigger_name = c100
     2 prsnl_reltn_id = f8
     2 chart_route_id = f8
     2 sequence_group_id = f8
     2 nurse_unit_cv = f8
     2 org = c20
     2 display = c20
     2 mrnt = c20
     2 name = c20
     2 room = c20
     2 bed = c20
     2 mrn = c20
     2 fac = c20
     2 device_cd = f8
     2 web_browser_ind = i2
     2 activity_type_mean = c12
     2 suppress_mrpnodata_ind = i2
     2 prov[*]
       3 person_id = f8
       3 r_cd = f8
       3 copy_ind = i2
       3 prov_name = c20
     2 event_id_list[*]
       3 cr_event_id = f8
       3 event_id = f8
       3 result_status_cd = f8
     2 encntr_list[*]
       3 encntr_id = f8
     2 chart_sect_list[*]
       3 chart_section_id = f8
     2 order_list[*]
       3 order_id = f8
     2 group_order_id = f8
     2 order_group_flag = i4
     2 result_lookup_ind = i2
     2 template_id = f8
     2 batch_id = f8
     2 cr_mask_id = f8
     2 chart_trigger_id = f8
     2 user_role_profile = vc
     2 requesting_prsnl_id = f8
     2 non_ce_begin_dt_tm = dq8
     2 non_ce_end_dt_tm = dq8
   1 requesting_locale = c5
 )
 FREE RECORD m_rec
 RECORD m_rec(
   1 acc[*]
     2 s_acc_nbr = vc
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 f_order_id = f8
     2 f_device_cd = f8
 ) WITH protect
 DECLARE ms_updt_type = vc WITH protect, constant(trim(cnvtlower( $S_UPDT_TYPE),3))
 DECLARE ms_accession = vc WITH protect, constant(trim( $S_ACCESSION,3))
 DECLARE mf_template_id = f8 WITH protect, constant(cnvtreal( $F_TEMPLATE_ID))
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(trim(format(cnvtlookbehind("1,Y",sysdate),
    "dd-mmm-yyyy hh:mm;;d"),3))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(trim(format(sysdate,"dd-mmm-yyyy hh:mm;;d"),3))
 DECLARE ms_source_file = vc WITH protect, noconstant(" ")
 DECLARE ms_rtl_file = vc WITH protect, noconstant(" ")
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 IF (ms_updt_type="file")
  SET ms_source_file = ms_accession
  IF (findstring(".csv",ms_source_file)=0)
   SET ms_source_file = concat(ms_source_file,".csv")
  ENDIF
  IF (findfile(ms_source_file)=0)
   SET ms_log =
   "File not found - make sure file is in CCLUSERDIR and is named in all lowercase letters"
   GO TO exit_script
  ENDIF
  CALL parser(concat("set logical ms_rtl_file 'ccluserdir:",ms_source_file,"' go"))
  FREE DEFINE rtl2
  DEFINE rtl2 "ms_rtl_file"
  SELECT INTO "nl:"
   FROM rtl2t r
   HEAD REPORT
    pl_cnt = 0, pl_endpos = 0
   DETAIL
    CALL echo(r.line)
    IF (cnvtlower(substring(1,15,r.line)) != "*accession*"
     AND textlen(trim(r.line,3)) > 0)
     pl_cnt += 1
     IF (pl_cnt > size(requestin->list_0,5))
      CALL alterlist(requestin->list_0,(pl_cnt+ 10))
     ENDIF
     pl_endpos = findstring('"',r.line,2)
     IF (pl_endpos > 0)
      ms_tmp = substring(2,(pl_endpos - 2),r.line), requestin->list_0[pl_cnt].accession = trim(ms_tmp,
       3)
     ENDIF
    ENDIF
   FOOT REPORT
    CALL alterlist(requestin->list_0,pl_cnt)
   WITH nocounter
  ;end select
  IF (size(requestin->list_0,5)=0)
   SET ms_log = "No values found in file"
   GO TO exit_script
  ENDIF
 ELSE
  CALL alterlist(requestin->list_0,1)
  SET requestin->list_0[1].accession = ms_accession
 ENDIF
 CALL alterlist(m_rec->acc,size(requestin->list_0,5))
 FOR (ml_loop = 1 TO size(m_rec->acc,5))
   SET m_rec->acc[ml_loop].s_acc_nbr = requestin->list_0[ml_loop].accession
 ENDFOR
 CALL echo("get order rad details")
 SELECT INTO "nl:"
  FROM order_radiology o
  PLAN (o
   WHERE expand(ml_exp,1,size(m_rec->acc,5),o.accession,m_rec->acc[ml_exp].s_acc_nbr))
  HEAD o.accession
   ml_idx = locateval(ml_loc,1,size(m_rec->acc,5),o.accession,m_rec->acc[ml_loc].s_acc_nbr), m_rec->
   acc[ml_idx].f_person_id = o.person_id, m_rec->acc[ml_idx].f_encntr_id = o.encntr_id,
   m_rec->acc[ml_idx].f_order_id = o.order_id
  WITH nocounter, expand = 1
 ;end select
 CALL echo("get output dest")
 SELECT INTO "nl:"
  FROM order_radiology o,
   device_xref dx,
   device d,
   output_dest od
  PLAN (o
   WHERE expand(ml_exp,1,size(m_rec->acc,5),o.accession,m_rec->acc[ml_exp].s_acc_nbr))
   JOIN (dx
   WHERE dx.parent_entity_id=o.order_physician_id)
   JOIN (d
   WHERE d.device_cd=dx.device_cd)
   JOIN (od
   WHERE od.device_cd=d.device_cd)
  ORDER BY o.accession
  HEAD REPORT
   pl_cnt = 0
  HEAD o.accession
   pl_cnt += 1, ml_idx = locateval(ml_loc,1,size(m_rec->acc,5),o.accession,m_rec->acc[ml_loc].
    s_acc_nbr), m_rec->acc[ml_idx].f_device_cd = od.device_cd
  FOOT REPORT
   CALL echo(build2("device_cds found: ",pl_cnt))
  WITH nocounter, expand = 1
 ;end select
 SET ml_cnt = 0
 FOR (ml_loop = 1 TO size(m_rec->acc,5))
  CALL echo("loop")
  IF ((m_rec->acc[ml_loop].f_device_cd=0.0))
   CALL echo(concat("device_cd not found: ",m_rec->acc[ml_loop].s_acc_nbr))
  ELSE
   SET ml_cnt += 1
   SET stat = initrec(request)
   SET request->qual[1].accession_nbr = m_rec->acc[ml_loop].s_acc_nbr
   SET request->qual[1].person_id = m_rec->acc[ml_loop].f_person_id
   SET request->qual[1].encntr_id = m_rec->acc[ml_loop].f_encntr_id
   SET request->qual[1].order_id = m_rec->acc[ml_loop].f_order_id
   SET request->qual[1].date_range_ind = 1
   SET request->qual[1].begin_dt_tm = cnvtdatetime(ms_beg_dt_tm)
   SET request->qual[1].end_dt_tm = cnvtdatetime(ms_end_dt_tm)
   SET request->qual[1].web_browser_ind = 0
   SET request->qual[1].activity_type_mean = "radiology"
   SET request->qual[1].template_id = mf_template_id
   SET request->qual[1].requesting_prsnl_id = reqinfo->updt_id
   SET request->qual[1].device_cd = m_rec->acc[ml_loop].f_device_cd
   SET trace = recpersist
   EXECUTE exm_add_chart_request
   SET trace = norecpersist
  ENDIF
 ENDFOR
 SET ms_log = concat(ms_log,char(10),char(13),trim(cnvtstring(ml_cnt),3)," rows processed")
 SET ms_log = concat(ms_log,char(10),char(13),"End - check reportrequestmaint.exe for results")
#exit_script
 SELECT INTO value( $OUTDEV)
  FROM (dummyt d  WITH seq = value(size(m_rec->acc,5)))
  HEAD REPORT
   col 0, ms_log, row + 1
  DETAIL
   IF ((m_rec->acc[d.seq].f_device_cd=0.0))
    ms_tmp = concat(m_rec->acc[d.seq].s_acc_nbr," - device_cd not found or is a duplicate accession"),
    col 0, ms_tmp,
    row + 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
