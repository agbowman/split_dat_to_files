CREATE PROGRAM bhs_rpt_res_lab_ord:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date:" = "CURDATE",
  "End Date:" = "CURDATE"
  WITH outdev, s_beg_dt, s_end_dt
 FREE RECORD m_rec
 RECORD m_rec(
   1 pat[*]
     2 f_person_id = f8
     2 s_pat_name = vc
     2 s_dob = vc
     2 s_cmrn = vc
     2 s_proto_acc_nbr = vc
     2 s_proto_nbr = vc
     2 s_nct_nbr = vc
     2 s_irb_nbr = vc
     2 ord[*]
       3 s_fin = vc
       3 s_fac = vc
       3 s_loc = vc
       3 s_enc_type = vc
       3 f_order_id = f8
       3 s_orig_ord_dt_tm = vc
       3 s_ord_status = vc
       3 f_catalog = f8
       3 s_catalog = vc
       3 s_ord_as_mnem = vc
       3 s_clin_disp_line = vc
       3 s_labcorp = vc
       3 s_order_by = vc
       3 s_order_by_pos = vc
       3 s_order_by_username = vc
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
 DECLARE mf_cs4_cmrn = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
 DECLARE mf_cs263_nct_nbr = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,"NCTNUMBER"))
 DECLARE mf_cs263_irb_nbr = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",263,"IRBNUMBER"))
 DECLARE mf_cs319_fin = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE mf_cs6000_lab = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3081"))
 DECLARE mf_cs6003_order = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3094"))
 DECLARE mf_cs6004_compl = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3100"))
 DECLARE mf_cs6004_inproc = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3224"))
 DECLARE mf_cs6004_ordered = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3102"))
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
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
  SET ms_beg_dt_tm = trim(format(datetimefind(cnvtlookbehind("1,D",sysdate),"D","B","B"),
    "dd-mmm-yyyy hh:mm:ss;;d"),3)
  SET ms_end_dt_tm = trim(format(datetimefind(cnvtlookbehind("1,D",sysdate),"D","E","E"),
    "dd-mmm-yyyy hh:mm:ss;;d"),3)
 ENDIF
 CALL echo(build2("beg dt: ",ms_beg_dt_tm," end dt: ",ms_end_dt_tm))
 SELECT INTO "nl:"
  FROM pt_prot_reg ppr,
   person p,
   person_alias pa,
   prot_master pm,
   prot_alias pa1,
   prot_alias pa2,
   orders o,
   order_action oa,
   prsnl pr,
   encounter e,
   encntr_alias ea
  PLAN (ppr
   WHERE ppr.off_study_dt_tm > sysdate)
   JOIN (p
   WHERE p.person_id=ppr.person_id)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mf_cs4_cmrn
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate)
   JOIN (pm
   WHERE pm.prot_master_id=ppr.prot_master_id)
   JOIN (pa1
   WHERE pa1.prot_master_id=ppr.prot_master_id
    AND pa1.alias_pool_cd=mf_cs263_nct_nbr
    AND pa1.end_effective_dt_tm > sysdate)
   JOIN (pa2
   WHERE pa2.prot_master_id=ppr.prot_master_id
    AND pa2.alias_pool_cd=mf_cs263_irb_nbr
    AND pa2.end_effective_dt_tm > sysdate)
   JOIN (o
   WHERE o.person_id=ppr.person_id
    AND o.active_ind=1
    AND o.catalog_type_cd=mf_cs6000_lab
    AND o.order_status_cd IN (mf_cs6004_inproc, mf_cs6004_ordered))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=mf_cs6003_order
    AND oa.action_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm))
   JOIN (pr
   WHERE pr.person_id=oa.order_provider_id)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.active_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=mf_cs319_fin)
  ORDER BY p.name_full_formatted, p.person_id, pm.primary_mnemonic,
   o.orig_order_dt_tm DESC, o.order_id
  HEAD REPORT
   pl_cnt = 0, pl_ord_cnt = 0
  HEAD p.person_id
   pl_ord_cnt = 0, pl_cnt += 1
   IF (pl_cnt > size(m_rec->pat,5))
    CALL alterlist(m_rec->pat,(pl_cnt+ 20))
   ENDIF
   m_rec->pat[pl_cnt].f_person_id = p.person_id, m_rec->pat[pl_cnt].s_pat_name = trim(p
    .name_full_formatted,3), m_rec->pat[pl_cnt].s_dob = trim(format(cnvtdatetimeutc(datetimezone(p
       .birth_dt_tm,p.birth_tz),1),"mm/dd/yy;;d"),3),
   m_rec->pat[pl_cnt].s_cmrn = trim(pa.alias,3), m_rec->pat[pl_cnt].s_proto_acc_nbr = trim(ppr
    .prot_accession_nbr,3), m_rec->pat[pl_cnt].s_proto_nbr = trim(pm.primary_mnemonic,3),
   m_rec->pat[pl_cnt].s_nct_nbr = trim(pa1.prot_alias,3), m_rec->pat[pl_cnt].s_irb_nbr = trim(pa2
    .prot_alias,3)
  HEAD o.order_id
   pl_ord_cnt += 1
   IF (pl_ord_cnt > size(m_rec->pat[pl_cnt].ord,5))
    CALL alterlist(m_rec->pat[pl_cnt].ord,(pl_ord_cnt+ 20))
   ENDIF
   m_rec->pat[pl_cnt].ord[pl_ord_cnt].s_fin = trim(ea.alias,3), m_rec->pat[pl_cnt].ord[pl_ord_cnt].
   s_fac = trim(uar_get_code_display(e.loc_facility_cd),3), m_rec->pat[pl_cnt].ord[pl_ord_cnt].s_loc
    = trim(uar_get_code_display(e.location_cd),3),
   m_rec->pat[pl_cnt].ord[pl_ord_cnt].s_enc_type = trim(uar_get_code_display(e.encntr_type_cd),3),
   m_rec->pat[pl_cnt].ord[pl_ord_cnt].f_order_id = o.order_id, m_rec->pat[pl_cnt].ord[pl_ord_cnt].
   s_orig_ord_dt_tm = trim(format(o.orig_order_dt_tm,"mm/dd/yy hh:mm;;d"),3),
   m_rec->pat[pl_cnt].ord[pl_ord_cnt].s_ord_status = trim(uar_get_code_display(o.order_status_cd),3),
   m_rec->pat[pl_cnt].ord[pl_ord_cnt].f_catalog = o.catalog_cd, m_rec->pat[pl_cnt].ord[pl_ord_cnt].
   s_catalog = trim(uar_get_code_display(o.catalog_cd),3),
   m_rec->pat[pl_cnt].ord[pl_ord_cnt].s_ord_as_mnem = trim(o.ordered_as_mnemonic,3), m_rec->pat[
   pl_cnt].ord[pl_ord_cnt].s_clin_disp_line = trim(o.clinical_display_line,3)
   IF (o.clinical_display_line="*LabCorp*")
    m_rec->pat[pl_cnt].ord[pl_ord_cnt].s_labcorp = "LabCorp"
   ELSE
    m_rec->pat[pl_cnt].ord[pl_ord_cnt].s_labcorp = "Not LabCorp"
   ENDIF
   m_rec->pat[pl_cnt].ord[pl_ord_cnt].s_order_by = trim(pr.name_full_formatted,3), m_rec->pat[pl_cnt]
   .ord[pl_ord_cnt].s_order_by_pos = trim(uar_get_code_display(pr.position_cd),3), m_rec->pat[pl_cnt]
   .ord[pl_ord_cnt].s_order_by_username = trim(pr.username,3)
  FOOT  p.person_id
   CALL alterlist(m_rec->pat[pl_cnt].ord,pl_ord_cnt)
  FOOT REPORT
   CALL alterlist(m_rec->pat,pl_cnt)
  WITH nocounter
 ;end select
 SELECT INTO value( $OUTDEV)
  domain = curdomain, order_dt_tm = m_rec->pat[d1.seq].ord[d2.seq].s_orig_ord_dt_tm, lab_visit_number
   = substring(1,20,m_rec->pat[d1.seq].ord[d2.seq].s_fin),
  encounter_type = substring(1,25,m_rec->pat[d1.seq].ord[d2.seq].s_enc_type), facility = substring(1,
   30,m_rec->pat[d1.seq].ord[d2.seq].s_fac), location = substring(1,30,m_rec->pat[d1.seq].ord[d2.seq]
   .s_loc),
  status = substring(1,20,m_rec->pat[d1.seq].ord[d2.seq].s_ord_status), catalog_cd = substring(1,20,
   trim(cnvtstring(m_rec->pat[d1.seq].ord[d2.seq].f_catalog),3)), catalog_cd = substring(1,50,m_rec->
   pat[d1.seq].ord[d2.seq].s_catalog),
  order_id = substring(1,20,trim(cnvtstring(m_rec->pat[d1.seq].ord[d2.seq].f_order_id),3)),
  ordered_as_mnemonic = substring(1,155,m_rec->pat[d1.seq].ord[d2.seq].s_ord_as_mnem),
  clinical_display_line = substring(1,255,m_rec->pat[d1.seq].ord[d2.seq].s_clin_disp_line),
  labcorp = substring(1,20,m_rec->pat[d1.seq].ord[d2.seq].s_labcorp), cmrn = substring(1,20,m_rec->
   pat[d1.seq].s_cmrn), patient = substring(1,100,m_rec->pat[d1.seq].s_pat_name),
  dob = m_rec->pat[d1.seq].s_dob, protocol_sequence_no = substring(1,30,m_rec->pat[d1.seq].
   s_proto_acc_nbr), protocol_number = substring(1,50,m_rec->pat[d1.seq].s_proto_nbr),
  nctnumber = substring(1,50,m_rec->pat[d1.seq].s_nct_nbr), irbnumber = substring(1,50,m_rec->pat[d1
   .seq].s_irb_nbr), ordering_doc = substring(1,100,m_rec->pat[d1.seq].ord[d2.seq].s_order_by),
  ordering_doc_position = substring(1,75,m_rec->pat[d1.seq].ord[d2.seq].s_order_by_pos),
  ordering_doc_username = substring(1,20,m_rec->pat[d1.seq].ord[d2.seq].s_order_by_username)
  FROM (dummyt d1  WITH seq = value(size(m_rec->pat,5))),
   dummyt dout,
   dummyt d2
  PLAN (d1
   WHERE maxrec(d2,size(m_rec->pat[d1.seq].ord,5)))
   JOIN (dout)
   JOIN (d2)
  WITH nocounter, outerjoin = dout, format,
   separator = " ", maxrow = 1
 ;end select
 SET reply->status_data[1].status = "S"
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
