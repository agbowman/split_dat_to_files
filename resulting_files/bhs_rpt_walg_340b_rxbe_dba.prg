CREATE PROGRAM bhs_rpt_walg_340b_rxbe:dba
 PROMPT
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Test file?" = "no"
  WITH s_beg_dt, s_end_dt, s_test_file
 FREE RECORD m_rec
 RECORD m_rec(
   1 erx[*]
     2 n_skip = i2
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_pat_name_last = vc
     2 s_pat_name_first = vc
     2 s_pat_dob = vc
     2 s_pat_zip = vc
     2 s_mrn = vc
     2 s_facility = vc
     2 s_unit = vc
     2 s_pharm_npi = vc
     2 s_pharm_ncpdp = vc
     2 s_prov_npi = vc
     2 s_prov_dea = vc
     2 s_pres_name_last = vc
     2 s_pres_name_first = vc
     2 s_written_loc = vc
     2 s_written_loc_desc = vc
     2 s_written_dt = vc
     2 s_written_tm = vc
     2 f_order_id = f8
     2 s_ord_dt_tm = vc
     2 s_ndc_desc = vc
     2 s_drug_desc = vc
     2 s_drug_strength = vc
     2 s_drug_unit = vc
     2 s_drug_form = vc
     2 s_drug_qty = vc
     2 s_drug_ndc = vc
     2 s_fin = vc
     2 s_diag_cd = vc
     2 s_diag_src = vc
     2 s_diag_prim = vc
     2 s_route_electc = vc
     2 s_pharmacy = vc
     2 s_order_status = vc
     2 s_order_cki = vc
   1 fac[*]
     2 s_disp = vc
     2 f_cd = f8
   1 nu[*]
     2 s_disp = vc
     2 f_cd = f8
   1 loc[*]
     2 s_disp = vc
     2 f_cd = f8
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
 EXECUTE bhs_check_domain
 EXECUTE bhs_hlp_ftp
 DECLARE ms_test_file = vc WITH protect, constant(cnvtlower(trim( $S_TEST_FILE,3)))
 DECLARE mf_pharm_cat_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,
   "PHARMACY"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE mf_deleted_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"DELETED"))
 DECLARE mf_order_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6003,"ORDER"))
 DECLARE mf_npi_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",320,
   "NATIONALPROVIDERIDENTIFIER"))
 DECLARE mf_dea_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",320,"DOCDEA"))
 DECLARE mf_pharm_act_ty = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",106,"PHARMACY"))
 DECLARE mf_cs17_final_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!13984"))
 DECLARE mf_cs104501_fac = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",104501,
   "WALGREENSERXFACS"))
 DECLARE mf_cs104501_nu = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",104501,
   "WALGREENSERXNURSEUNITS"))
 DECLARE mf_cs104501_ordloc = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",104501,
   "WALGREENSERXORDLOCATIONS"))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_home_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE ms_loc_dir = vc WITH protect, noconstant(" ")
 DECLARE ms_file_name = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_cmd = vc WITH protect, noconstant(" ")
 DECLARE ms_beg_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_end_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE ms_line = vc WITH protect, noconstant(" ")
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE ml_exp = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_file_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_timestamp = vc WITH protect, noconstant(" ")
 DECLARE ms_sponsor_code = vc WITH protect, noconstant(" ")
 DECLARE ml_exp1 = i4 WITH protect, noconstant(0)
 DECLARE ml_exp2 = i4 WITH protect, noconstant(0)
 DECLARE ml_exp3 = i4 WITH protect, noconstant(0)
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
  FROM code_value_group cvg
  WHERE cvg.parent_code_value IN (mf_cs104501_fac, mf_cs104501_nu, mf_cs104501_ordloc)
  ORDER BY cvg.parent_code_value
  HEAD REPORT
   pl_cnt = 0
  HEAD cvg.parent_code_value
   pl_cnt = 0
  DETAIL
   pl_cnt += 1
   IF (cvg.parent_code_value=mf_cs104501_fac)
    CALL alterlist(m_rec->fac,pl_cnt), m_rec->fac[pl_cnt].f_cd = cvg.child_code_value, m_rec->fac[
    pl_cnt].s_disp = trim(uar_get_code_display(cvg.child_code_value),3)
   ELSEIF (cvg.parent_code_value=mf_cs104501_nu)
    CALL alterlist(m_rec->nu,pl_cnt), m_rec->nu[pl_cnt].f_cd = cvg.child_code_value, m_rec->nu[pl_cnt
    ].s_disp = trim(uar_get_code_display(cvg.child_code_value),3)
   ELSEIF (cvg.parent_code_value=mf_cs104501_ordloc)
    CALL alterlist(m_rec->loc,pl_cnt), m_rec->loc[pl_cnt].f_cd = cvg.child_code_value, m_rec->loc[
    pl_cnt].s_disp = trim(uar_get_code_display(cvg.child_code_value),3)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o,
   order_detail od1,
   dummyt d,
   order_detail od2,
   order_action oa,
   encounter e,
   encntr_alias ea,
   person p,
   address a,
   prsnl pr,
   prsnl_alias pa1,
   prsnl_alias pa2
  PLAN (o
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(ms_beg_dt_tm) AND cnvtdatetime(ms_end_dt_tm)
    AND o.active_ind=1
    AND o.product_id=o.product_id
    AND o.order_status_cd != mf_deleted_cd
    AND o.catalog_type_cd=mf_pharm_cat_type_cd
    AND o.orig_ord_as_flag=1
    AND o.activity_type_cd=mf_pharm_act_ty)
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.order_status_cd=mf_ordered_cd
    AND oa.action_type_cd=mf_order_cd
    AND expand(ml_exp1,1,size(m_rec->loc,5),oa.order_locn_cd,m_rec->loc[ml_exp1].f_cd))
   JOIN (od1
   WHERE (od1.order_id= Outerjoin(o.order_id))
    AND (cnvtupper(od1.oe_field_display_value)= Outerjoin("ROUTE TO PHARMACY ELECTRONICALLY")) )
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND expand(ml_exp2,1,size(m_rec->fac,5),e.loc_facility_cd,m_rec->fac[ml_exp2].f_cd)
    AND expand(ml_exp3,1,size(m_rec->nu,5),e.loc_nurse_unit_cd,m_rec->nu[ml_exp3].f_cd))
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd IN (mf_mrn_cd, mf_fin_cd))
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (a
   WHERE a.parent_entity_id=p.person_id
    AND a.parent_entity_name="PERSON"
    AND a.active_ind=1
    AND a.end_effective_dt_tm > sysdate
    AND a.address_type_seq=1
    AND a.address_type_cd=mf_home_cd
    AND textlen(trim(a.zipcode_key,3)) > 0)
   JOIN (pr
   WHERE pr.person_id=oa.order_provider_id)
   JOIN (pa1
   WHERE pa1.person_id=oa.order_provider_id
    AND pa1.active_ind=1
    AND pa1.end_effective_dt_tm > sysdate
    AND pa1.prsnl_alias_type_cd=mf_npi_cd)
   JOIN (pa2
   WHERE (pa2.person_id= Outerjoin(oa.order_provider_id))
    AND (pa2.active_ind= Outerjoin(1))
    AND (pa2.end_effective_dt_tm> Outerjoin(sysdate))
    AND (pa2.prsnl_alias_type_cd= Outerjoin(mf_dea_cd)) )
   JOIN (d)
   JOIN (od2
   WHERE od2.order_id=o.order_id
    AND od2.oe_field_meaning IN ("DISPENSEQTY", "STRENGTHDOSE", "VOLUMEDOSE", "STRENGTHDOSEUNIT",
   "VOLUMEDOSEUNIT",
   "DRUGFORM", "ROUTINGPHARMACYNAME"))
  ORDER BY o.order_id, ea.encntr_alias_type_cd, od2.detail_sequence
  HEAD REPORT
   pl_cnt = 0
  HEAD o.order_id
   pl_cnt += 1
   IF (pl_cnt > size(m_rec->erx,5))
    CALL alterlist(m_rec->erx,(pl_cnt+ 100))
   ENDIF
   m_rec->erx[pl_cnt].f_person_id = o.person_id, m_rec->erx[pl_cnt].f_encntr_id = o.encntr_id, m_rec
   ->erx[pl_cnt].s_facility = trim(uar_get_code_display(e.loc_facility_cd),3),
   m_rec->erx[pl_cnt].s_pat_name_last = trim(p.name_last_key,3), m_rec->erx[pl_cnt].s_pat_name_first
    = trim(p.name_first_key,3), m_rec->erx[pl_cnt].s_pat_dob = trim(format(p.birth_dt_tm,
     "YYYY-MM-DD;;d"),3),
   m_rec->erx[pl_cnt].s_pres_name_last = trim(pr.name_last_key,3), m_rec->erx[pl_cnt].
   s_pres_name_first = trim(pr.name_first_key,3), m_rec->erx[pl_cnt].s_written_loc = trim(
    uar_get_code_display(oa.order_locn_cd),3),
   m_rec->erx[pl_cnt].s_written_loc_desc = trim(uar_get_code_description(e.loc_nurse_unit_cd),3),
   m_rec->erx[pl_cnt].s_written_dt = trim(format(o.orig_order_dt_tm,"YYYY-MM-DD;;d"),3), m_rec->erx[
   pl_cnt].s_written_tm = trim(format(o.orig_order_dt_tm,"hh:mm:ss;;d"),3),
   m_rec->erx[pl_cnt].f_order_id = o.order_id, m_rec->erx[pl_cnt].s_ord_dt_tm = trim(format(o
     .orig_order_dt_tm,"YYYY-MM-DD;;d"),3), m_rec->erx[pl_cnt].s_order_status = trim(
    uar_get_code_display(o.order_status_cd),3),
   m_rec->erx[pl_cnt].s_drug_desc = trim(o.hna_order_mnemonic,3)
   IF (cnvtupper(od1.oe_field_display_value)="ROUTE TO PHARMACY ELECTRONICALLY")
    m_rec->erx[pl_cnt].s_route_electc = "Y"
   ELSE
    m_rec->erx[pl_cnt].s_route_electc = "N"
   ENDIF
   m_rec->erx[pl_cnt].s_pat_zip = trim(a.zipcode_key,3), m_rec->erx[pl_cnt].s_prov_npi = trim(pa1
    .alias,3)
   IF (pa2.person_id > 0.0)
    m_rec->erx[pl_cnt].s_prov_dea = trim(pa2.alias,3)
   ENDIF
  HEAD ea.encntr_alias_type_cd
   IF (ea.encntr_alias_type_cd=mf_fin_cd)
    m_rec->erx[pl_cnt].s_fin = format(trim(ea.alias,3),"############;P0")
   ELSEIF (ea.encntr_alias_type_cd=mf_mrn_cd)
    m_rec->erx[pl_cnt].s_mrn = format(trim(ea.alias,3),"#######;P0")
   ENDIF
  DETAIL
   IF (od2.oe_field_meaning="DISPENSEQTY")
    m_rec->erx[pl_cnt].s_drug_qty = od2.oe_field_display_value
   ELSEIF (od2.oe_field_meaning IN ("STRENGTHDOSE", "VOLUMEDOSE"))
    m_rec->erx[pl_cnt].s_drug_strength = trim(od2.oe_field_display_value,3)
   ELSEIF (od2.oe_field_meaning IN ("STRENGTHDOSEUNIT", "VOLUMEDOSEUNIT"))
    m_rec->erx[pl_cnt].s_drug_unit = trim(od2.oe_field_display_value,3)
   ELSEIF (od2.oe_field_meaning="DRUGFORM")
    m_rec->erx[pl_cnt].s_drug_form = trim(od2.oe_field_display_value,3)
   ELSEIF (od2.oe_field_meaning="ROUTINGPHARMACYNAME")
    m_rec->erx[pl_cnt].s_pharmacy = trim(od2.oe_field_display_value,3)
   ENDIF
  FOOT  o.order_id
   IF (textlen(trim(m_rec->erx[pl_cnt].s_drug_strength,3)) > 0)
    m_rec->erx[pl_cnt].s_drug_desc = trim(concat(m_rec->erx[pl_cnt].s_drug_desc," ",m_rec->erx[pl_cnt
      ].s_drug_strength,m_rec->erx[pl_cnt].s_drug_unit),3)
   ENDIF
   IF (textlen(trim(m_rec->erx[pl_cnt].s_drug_form,3)) > 0)
    m_rec->erx[pl_cnt].s_drug_desc = trim(concat(m_rec->erx[pl_cnt].s_drug_desc," ",m_rec->erx[pl_cnt
      ].s_drug_form),3)
   ENDIF
  FOOT REPORT
   CALL alterlist(m_rec->erx,pl_cnt)
  WITH nocounter, outerjoin = d, expand = 1
 ;end select
 IF (size(m_rec->erx,5)=0)
  SET ms_log = "No records found"
  GO TO exit_script
 ENDIF
 CALL echo("get dx")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(m_rec->erx,5))),
   diagnosis dx,
   nomenclature n
  PLAN (d)
   JOIN (dx
   WHERE (dx.encntr_id=m_rec->erx[d.seq].f_encntr_id)
    AND dx.active_ind=1
    AND dx.end_effective_dt_tm > sysdate
    AND dx.diag_type_cd=mf_cs17_final_cd)
   JOIN (n
   WHERE n.nomenclature_id=dx.nomenclature_id)
  ORDER BY d.seq, dx.diag_priority, n.nomenclature_id
  HEAD REPORT
   pl_cnt = 0
  HEAD d.seq
   pl_cnt = 0
  HEAD n.nomenclature_id
   pl_cnt += 1
   IF (pl_cnt > 1)
    m_rec->erx[d.seq].s_diag_cd = concat(trim(m_rec->erx[d.seq].s_diag_cd,3),";"), m_rec->erx[d.seq].
    s_diag_src = concat(trim(m_rec->erx[d.seq].s_diag_src,3),";")
   ENDIF
   m_rec->erx[d.seq].s_diag_cd = concat(trim(m_rec->erx[d.seq].s_diag_cd,3),trim(n.source_identifier,
     3)), m_rec->erx[d.seq].s_diag_src = concat(trim(m_rec->erx[d.seq].s_diag_src,3),trim(
     uar_get_code_display(n.source_vocabulary_cd),3))
  WITH nocounter
 ;end select
 IF (gl_bhs_prod_flag=1)
  SET ms_loc_dir = "/cerner/d_p627/bhscust/walg_340b_rxbe/"
 ENDIF
 FOR (ml_loop = 1 TO size(m_rec->erx,5))
   IF (textlen(trim(m_rec->erx[ml_loop].s_pat_zip,3))=0)
    SET m_rec->erx[ml_loop].n_skip = 1
   ENDIF
 ENDFOR
 IF (size(m_rec->erx,5) > 0)
  SET ms_timestamp = trim(format(sysdate,"yyyymmddhhmmss;;d"),3)
  SET ms_file_name = concat("5977_flatver4_delta_",ms_timestamp,".txt")
  IF (ms_test_file="test")
   SET ms_file_name = concat("test_",ms_file_name)
  ENDIF
  CALL echo(build2("write: ",size(m_rec->erx,5)))
  CALL echo(build2("ms_file_name: ",ms_file_name))
  SET frec->file_buf = "w"
  SET frec->file_name = concat(ms_loc_dir,ms_file_name)
  CALL echo(frec->file_name)
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = concat(
   "Patient_ID|Last_NM|First_NM|DOB|Order_ID|Location_ID|NPI|Diagnosis_CD|",
   "Diagnosis_CD_TYP|COV_EFFECTIVE_DT|GPI|GCN",char(10))
  SET stat = cclio("WRITE",frec)
  FOR (ml_loop = 1 TO size(m_rec->erx,5))
    IF ((m_rec->erx[ml_loop].n_skip=0))
     SET ms_line = concat(m_rec->erx[ml_loop].s_mrn,"|",m_rec->erx[ml_loop].s_pat_name_last,"|",m_rec
      ->erx[ml_loop].s_pat_name_first,
      "|",m_rec->erx[ml_loop].s_pat_dob,"|",trim(cnvtstring(m_rec->erx[ml_loop].f_order_id),3),"|",
      m_rec->erx[ml_loop].s_facility,"|",m_rec->erx[ml_loop].s_prov_npi,"|",m_rec->erx[ml_loop].
      s_diag_cd,
      "|",m_rec->erx[ml_loop].s_diag_src,"|",m_rec->erx[ml_loop].s_ord_dt_tm,"|",
      "|",char(10))
     SET frec->file_buf = ms_line
     SET stat = cclio("WRITE",frec)
    ENDIF
  ENDFOR
  SET stat = cclio("CLOSE",frec)
 ENDIF
 SET reply->status_data[1].status = "S"
#exit_script
 FREE RECORD m_rec
END GO
