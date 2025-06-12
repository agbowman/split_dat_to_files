CREATE PROGRAM bhs_rpt_hsrn:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 EXECUTE bhs_ma_email_file
 FREE RECORD m_dtas
 RECORD m_dtas(
   1 l_dcnt = i4
   1 dtalst[*]
     2 f_task_assay_cd = f8
     2 f_event_cd = f8
     2 c_mnemonic = c50
     2 l_rescnt = i4
     2 reslst[*]
       3 f_nomenclature_id = f8
       3 c_response = c255
       3 l_seq = i4
       3 l_rptcol = i4
 ) WITH protect
 FREE RECORD m_plans
 RECORD m_plans(
   1 l_pcnt = i4
   1 plst[*]
     2 f_person_id = f8
     2 c_patient_name = c100
     2 c_dob = c10
     2 c_hne_id = c100
 )
 FREE RECORD m_hsrn
 RECORD m_hsrn(
   1 l_ecnt = i4
   1 elst[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 d_hsrn_dt_tm = dq8
     2 c_patient_name = c100
     2 c_dob = c10
     2 c_hne_id = c100
     2 c_mass_health_id = vc
     2 c_location = c100
     2 c_hrsn_date = c10
     2 c_hrsn_signing_user = c100
     2 l_dtacnt = i4
     2 dtalst[*]
       3 f_event_id = f8
       3 f_event_cd = f8
       3 f_task_assay_cd = f8
       3 c_mnemonic = vc
       3 l_rescnt = i4
       3 reslst[*]
         4 f_nomenclature_id = f8
         4 c_response = vc
         4 l_rptcol = i4
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = h
   1 file_offset = h
   1 file_dir = h
 )
 IF ( NOT (validate(reply->status_data.status,0)))
  RECORD reply(
    1 ops_event = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD m_rpt
 RECORD m_rpt(
   1 l_rptcnt = i4
   1 rptlst[*]
     2 c_field1 = c255
     2 c_field2 = c255
     2 c_field3 = c255
     2 c_field4 = c255
     2 c_field5 = c255
     2 c_field6 = c255
     2 c_field7 = c255
     2 c_field8 = c255
     2 c_field9 = c255
     2 c_field10 = c255
     2 c_field11 = c255
     2 c_field12 = c255
     2 c_field13 = c255
     2 c_field14 = c255
     2 c_field15 = c255
     2 c_field16 = c255
     2 c_field17 = c255
     2 c_field18 = c255
     2 c_field19 = c255
     2 c_field20 = c255
     2 c_field21 = c255
     2 c_field22 = c255
     2 c_field23 = c255
     2 c_field24 = c255
     2 c_field25 = c255
     2 c_field26 = c255
     2 c_field27 = c255
     2 c_field28 = c255
     2 c_field29 = c255
     2 c_field30 = c255
     2 c_field31 = c255
     2 c_field32 = c255
     2 c_field33 = c255
     2 c_field34 = c255
     2 c_field35 = c255
     2 c_field36 = c255
     2 c_field37 = c255
     2 c_field38 = c255
     2 c_field39 = c255
     2 c_field40 = c255
     2 c_field41 = c255
     2 c_field42 = c255
     2 c_field43 = c255
     2 c_field44 = c255
     2 c_field0 = c255
 ) WITH protect
 FREE RECORD cmrns
 RECORD cmrns(
   1 qual[*]
     2 cmrn = vc
     2 person_id = vc
     2 masshealth_id = vc
 )
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_cs319_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_cs8_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_cs8_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_cs8_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_cs8_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"ACTIVE")), protect
 DECLARE bhs_debug_flag = i4 WITH persistscript, noconstant(100)
 DECLARE md_beg_dt_tm = dq8 WITH protect
 DECLARE md_end_dt_tm = dq8 WITH protect
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_parse = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_dcnt = i4 WITH protect, noconstant(0)
 DECLARE ml_rescnt = i4 WITH protect, noconstant(0)
 DECLARE ml_pcnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ecnt = i4 WITH protect, noconstant(0)
 DECLARE ml_pidx = i4 WITH protect, noconstant(0)
 DECLARE ml_pnum = i4 WITH protect, noconstant(0)
 DECLARE ml_ppos = i4 WITH protect, noconstant(0)
 DECLARE ml_dtaidx = i4 WITH protect, noconstant(0)
 DECLARE ml_dtanum = i4 WITH protect, noconstant(0)
 DECLARE ml_dtapos = i4 WITH protect, noconstant(0)
 DECLARE ml_residx = i4 WITH protect, noconstant(0)
 DECLARE ml_resnum = i4 WITH protect, noconstant(0)
 DECLARE ml_respos = i4 WITH protect, noconstant(0)
 DECLARE ml_rptcnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ptinfocnt = i4 WITH protect, noconstant(0)
 DECLARE ml_fldnum = i4 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ml_hloop = i4 WITH protect, noconstant(0)
 DECLARE ms_message_file = vc WITH protect, noconstant(" ")
 DECLARE ms_address_list = vc WITH protect, noconstant(" ")
 DECLARE ms_body = vc WITH protect, noconstant(" ")
 DECLARE ms_subject = vc WITH protect, noconstant(" ")
 DECLARE ms_filename = vc WITH protect, noconstant(" ")
 DECLARE ml_dclcom_len = i4 WITH protect, noconstant(0)
 DECLARE mn_status_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_source_file = vc WITH protect, constant("cmrns_4_masshealth.csv")
 DECLARE ms_cmrn_file = vc WITH protect, constant(concat("/cerner/d_",trim(cnvtlower(curdomain),3),
   "/bhscust/hne/hrsn/",ms_source_file))
 DECLARE mf_cs4_cmrn = f8 WITH constant(uar_get_code_by("DISPLAYKEY",4,"CORPORATEMEDICALRECORDNUMBER"
   )), protect
 DECLARE mf_cs263_bhsmrn = f8 WITH constant(uar_get_code_by("DISPLAYKEY",263,"BHSCMRN")), protect
 DECLARE ms_current_date = vc WITH protect, constant(format(cnvtdatetime(sysdate),"YYYYMMDDHHMMSS;;d"
   ))
 DECLARE ml_stat = i4 WITH protect, noconstant(0)
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 DECLARE ml_file_loop = i4 WITH protect, noconstant(0)
 DECLARE ms_files_loc = vc WITH protect, constant(concat(trim(logical("bhscust"),3),"/hne/hrsn"))
 DECLARE ml_pacnt = i4
 DECLARE num = i4
 DECLARE ml_idx = i4
 DECLARE ms_sender = vc WITH protect
 DECLARE ms_msgcls = vc WITH protect
 DECLARE ms_sendto = vc WITH protect
 DECLARE ms_mail_subject = vc WITH protect
 DECLARE ml_msgpriority = i4 WITH protect
 SET logical workfile ms_cmrn_file
 SET mllcrm_ct = 0
 FREE DEFINE rtl
 DEFINE rtl "WORKFILE"
 SET ml_stat = 0
 SET ms_dclcom = concat("find ",ms_files_loc," -type f -daystart -mtime 0 -name ",ms_source_file,
  " | grep -q '.'")
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
 SET md_beg_dt_tm = datetimefind(cnvtlookbehind("1 D",datetimefind(cnvtdatetime(curdate,0),"M","B",
    "B")),"Y","B","B")
 SET md_end_dt_tm = datetimefind(cnvtdatetime(curdate,0),"M","B","B")
 SET ms_filename = concat("hsrn_report_",format(cnvtlookbehind("1D",cnvtdatetime(md_end_dt_tm)),
   "yyyymmdd;;D"),"_ytd.csv")
 IF (ml_stat=1)
  SELECT INTO "NL:"
   r.*
   FROM rtlt r
   HEAD REPORT
    stat = alterlist(cmrns->qual,10)
   DETAIL
    mllcrm_ct += 1
    IF (mllcrm_ct > 1)
     IF (mod(mllcrm_ct,10)=1
      AND mllcrm_ct != 1)
      stat = alterlist(cmrns->qual,(mllcrm_ct+ 9))
     ENDIF
     cmrns->qual[mllcrm_ct].cmrn = piece(r.line,",",1,"NOT FOUND",0), cmrns->qual[mllcrm_ct].
     masshealth_id = piece(r.line,",",2,"NOT FOUND",0)
    ENDIF
   FOOT REPORT
    stat = alterlist(cmrns->qual,mllcrm_ct)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   dta_sort =
   IF (dta.mnemonic_key_cap="SDOH SCREENING CONDUCTED") 1
   ELSEIF (dta.mnemonic_key_cap="SDOH UNABLE TO OBTAIN RESOURCES") 2
   ELSEIF (dta.mnemonic_key_cap="SDOH FOOD RUN OUT") 3
   ELSEIF (dta.mnemonic_key_cap="SDOH HOUSING SITUATION") 4
   ELSEIF (dta.mnemonic_key_cap="SDOH TALK TO PEOPLE") 5
   ELSEIF (dta.mnemonic_key_cap="SDOH FEEL SAFE") 6
   ELSEIF (dta.mnemonic_key_cap="SDOH HELP CONNECTING TO RESOURCES") 7
   ENDIF
   FROM discrete_task_assay dta,
    reference_range_factor rrf,
    alpha_responses ar,
    nomenclature n
   PLAN (dta
    WHERE dta.mnemonic_key_cap IN ("SDOH FEEL SAFE", "SDOH FOOD RUN OUT",
    "SDOH HELP CONNECTING TO RESOURCES", "SDOH HOUSING SITUATION", "SDOH SCREENING CONDUCTED",
    "SDOH TALK TO PEOPLE", "SDOH UNABLE TO OBTAIN RESOURCES")
     AND dta.active_ind=1
     AND dta.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
    JOIN (rrf
    WHERE rrf.task_assay_cd=dta.task_assay_cd
     AND rrf.active_ind=1
     AND rrf.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
    JOIN (ar
    WHERE ar.reference_range_factor_id=rrf.reference_range_factor_id
     AND ar.active_ind=1
     AND ar.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
    JOIN (n
    WHERE n.nomenclature_id=ar.nomenclature_id
     AND n.active_ind=1
     AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   ORDER BY dta_sort, dta.mnemonic_key_cap, ar.sequence,
    n.source_string_keycap
   HEAD REPORT
    ml_dcnt = 0
   HEAD dta_sort
    null
   HEAD dta.mnemonic_key_cap
    ml_dcnt += 1, m_dtas->l_dcnt = ml_dcnt, stat = alterlist(m_dtas->dtalst,ml_dcnt),
    m_dtas->dtalst[ml_dcnt].f_event_cd = dta.event_cd, m_dtas->dtalst[ml_dcnt].f_task_assay_cd = dta
    .task_assay_cd, m_dtas->dtalst[ml_dcnt].c_mnemonic = trim(dta.mnemonic),
    ml_rescnt = 0
   HEAD ar.sequence
    null
   HEAD n.source_string_keycap
    ml_rescnt += 1, m_dtas->dtalst[ml_dcnt].l_rescnt = ml_rescnt, stat = alterlist(m_dtas->dtalst[
     ml_dcnt].reslst,ml_rescnt),
    m_dtas->dtalst[ml_dcnt].reslst[ml_rescnt].f_nomenclature_id = n.nomenclature_id, m_dtas->dtalst[
    ml_dcnt].reslst[ml_rescnt].l_seq = ar.sequence, m_dtas->dtalst[ml_dcnt].reslst[ml_rescnt].
    c_response = n.source_string
   WITH nocounter
  ;end select
  SET ml_rptcnt = 2
  SET m_rpt->l_rptcnt = ml_rptcnt
  SET stat = alterlist(m_rpt->rptlst,ml_rptcnt)
  SET ml_ptinfocnt = 6
  SET ml_fldnum = (ml_ptinfocnt+ 1)
  SET m_rpt->rptlst[2].c_field1 = "Patient Name"
  SET m_rpt->rptlst[2].c_field2 = "DOB"
  SET m_rpt->rptlst[2].c_field3 = "MassHealthId"
  SET m_rpt->rptlst[2].c_field4 = "Location"
  SET m_rpt->rptlst[2].c_field5 = "HRSN Date"
  SET m_rpt->rptlst[2].c_field6 = "HRSN Signing User"
  FOR (ml_dloop = 1 TO m_dtas->l_dcnt)
    SET ms_parse = concat("set m_rpt->rptlst[1].c_field",build(ml_fldnum),' = "',build(m_dtas->
      dtalst[ml_dloop].c_mnemonic),'" go')
    CALL parser(ms_parse)
    FOR (ml_rloop = 1 TO m_dtas->dtalst[ml_dloop].l_rescnt)
      SET ms_parse = concat("set m_rpt->rptlst[2].c_field",build((ml_fldnum+ (ml_rloop - 1))),' = "',
       build(m_dtas->dtalst[ml_dloop].reslst[ml_rloop].c_response),'" go')
      SET m_dtas->dtalst[ml_dloop].reslst[ml_rloop].l_rptcol = (ml_fldnum+ (ml_rloop - 1))
      CALL parser(ms_parse)
    ENDFOR
    SET ml_fldnum += m_dtas->dtalst[ml_dloop].l_rescnt
  ENDFOR
  SELECT INTO "nl:"
   FROM clinical_event ce,
    prsnl pr,
    encounter e,
    person p,
    ce_coded_result cer,
    nomenclature n,
    person_alias pa
   PLAN (pa
    WHERE expand(ml_idx,1,size(cmrns->qual,5),trim(pa.alias,3),trim(cmrns->qual[ml_idx].cmrn,3))
     AND pa.alias_pool_cd=mf_cs263_bhsmrn
     AND pa.person_alias_type_cd=mf_cs4_cmrn)
    JOIN (ce
    WHERE expand(ml_dtaidx,1,size(m_dtas->dtalst,5),ce.event_cd,m_dtas->dtalst[ml_dtaidx].f_event_cd)
     AND ce.person_id=pa.person_id
     AND ce.event_end_dt_tm >= cnvtdatetime(md_beg_dt_tm)
     AND ce.event_end_dt_tm < cnvtdatetime(md_end_dt_tm)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ce.task_assay_cd > 0.00
     AND ce.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_active
    ))
    JOIN (pr
    WHERE pr.person_id=ce.performed_prsnl_id)
    JOIN (e
    WHERE e.encntr_id=ce.encntr_id)
    JOIN (p
    WHERE p.person_id=e.person_id)
    JOIN (cer
    WHERE cer.event_id=ce.event_id
     AND cer.valid_until_dt_tm=ce.valid_until_dt_tm)
    JOIN (n
    WHERE n.nomenclature_id=cer.nomenclature_id)
   ORDER BY ce.encntr_id, ce.task_assay_cd, ce.event_end_dt_tm DESC,
    cer.sequence_nbr, cer.nomenclature_id
   HEAD REPORT
    ml_ecnt = 0
   HEAD ce.encntr_id
    ml_ecnt += 1, m_hsrn->l_ecnt = ml_ecnt, stat = alterlist(m_hsrn->elst,ml_ecnt),
    m_hsrn->elst[ml_ecnt].f_encntr_id = e.encntr_id, m_hsrn->elst[ml_ecnt].c_patient_name = build(p
     .name_full_formatted), m_hsrn->elst[ml_ecnt].c_dob = format(p.birth_dt_tm,"mm/dd/yyyy;;D"),
    m_hsrn->elst[ml_ecnt].c_location = replace(replace(build(uar_get_code_display(e.location_cd)),
      char(13),""),char(10),""), m_hsrn->elst[ml_ecnt].d_hsrn_dt_tm = ce.performed_dt_tm, m_hsrn->
    elst[ml_ecnt].c_hrsn_date = format(ce.performed_dt_tm,"mm/dd/yyyy;;D"),
    m_hsrn->elst[ml_ecnt].c_hrsn_signing_user = build(pr.name_full_formatted), cmrnpos = locateval(
     ml_idx,1,size(cmrns->qual,5),trim(pa.alias,3),trim(cmrns->qual[ml_idx].cmrn,3)), m_hsrn->elst[
    ml_ecnt].c_mass_health_id = trim(cmrns->qual[cmrnpos].masshealth_id,3),
    m_hsrn->elst[ml_ecnt].l_dtacnt = m_dtas->l_dcnt, stat = alterlist(m_hsrn->elst[ml_ecnt].dtalst,
     m_dtas->l_dcnt)
    FOR (ml_dtaloop = 1 TO m_dtas->l_dcnt)
     m_hsrn->elst[ml_ecnt].dtalst[ml_dtaloop].l_rescnt = m_dtas->dtalst[ml_dtaloop].l_rescnt,stat =
     alterlist(m_hsrn->elst[ml_ecnt].dtalst[ml_dtaloop].reslst,m_dtas->dtalst[ml_dtaloop].l_rescnt)
    ENDFOR
   HEAD ce.task_assay_cd
    ml_dtapos = 0, ml_dtapos = locateval(ml_dtanum,1,m_dtas->l_dcnt,ce.task_assay_cd,m_dtas->dtalst[
     ml_dtanum].f_task_assay_cd)
   HEAD cer.sequence_nbr
    null
   HEAD cer.nomenclature_id
    ml_respos = 0, ml_respos = locateval(ml_resnum,1,m_dtas->dtalst[ml_dtapos].l_rescnt,n
     .nomenclature_id,m_dtas->dtalst[ml_dtapos].reslst[ml_resnum].f_nomenclature_id)
    IF (ml_dtapos > 0
     AND ml_respos > 0)
     m_hsrn->elst[ml_ecnt].dtalst[ml_dtapos].f_event_cd = ce.event_cd, m_hsrn->elst[ml_ecnt].dtalst[
     ml_dtapos].f_task_assay_cd = ce.task_assay_cd, m_hsrn->elst[ml_ecnt].dtalst[ml_dtapos].
     c_mnemonic = m_dtas->dtalst[ml_dtapos].c_mnemonic,
     m_hsrn->elst[ml_ecnt].dtalst[ml_dtapos].reslst[ml_respos].f_nomenclature_id = n.nomenclature_id,
     m_hsrn->elst[ml_ecnt].dtalst[ml_dtapos].reslst[ml_respos].c_response = build(n.source_string),
     m_hsrn->elst[ml_ecnt].dtalst[ml_dtapos].reslst[ml_respos].l_rptcol = m_dtas->dtalst[ml_dtapos].
     reslst[ml_respos].l_rptcol
    ENDIF
   WITH expand = 2, nocounter
  ;end select
  IF ((m_hsrn->l_ecnt > 0))
   FOR (ml_eloop = 1 TO m_hsrn->l_ecnt)
     SET ml_rptcnt += 1
     SET m_rpt->l_rptcnt = ml_rptcnt
     SET stat = alterlist(m_rpt->rptlst,ml_rptcnt)
     SET m_rpt->rptlst[ml_rptcnt].c_field1 = build(m_hsrn->elst[ml_eloop].c_patient_name)
     SET m_rpt->rptlst[ml_rptcnt].c_field2 = build(m_hsrn->elst[ml_eloop].c_dob)
     SET m_rpt->rptlst[ml_rptcnt].c_field3 = build(m_hsrn->elst[ml_eloop].c_mass_health_id)
     SET m_rpt->rptlst[ml_rptcnt].c_field4 = build(m_hsrn->elst[ml_eloop].c_location)
     SET m_rpt->rptlst[ml_rptcnt].c_field5 = build(m_hsrn->elst[ml_eloop].c_hrsn_date)
     SET m_rpt->rptlst[ml_rptcnt].c_field6 = build(m_hsrn->elst[ml_eloop].c_hrsn_signing_user)
     FOR (ml_dloop = 1 TO m_hsrn->elst[ml_eloop].l_dtacnt)
       FOR (ml_rloop = 1 TO m_hsrn->elst[ml_eloop].dtalst[ml_dloop].l_rescnt)
         IF ((m_hsrn->elst[ml_eloop].dtalst[ml_dloop].reslst[ml_rloop].l_rptcol > 0))
          SET ms_parse = concat("set m_rpt->rptlst[ml_rptcnt].c_field",build(m_hsrn->elst[ml_eloop].
            dtalst[ml_dloop].reslst[ml_rloop].l_rptcol),' = "',build(m_hsrn->elst[ml_eloop].dtalst[
            ml_dloop].reslst[ml_rloop].c_response),'" go')
          CALL parser(ms_parse)
         ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
   SET frec->file_name = ms_filename
   SET frec->file_buf = "w"
   SET stat = cclio("OPEN",frec)
   FOR (ml_loop = 1 TO m_rpt->l_rptcnt)
    SET frec->file_buf = concat('"',trim(m_rpt->rptlst[ml_loop].c_field1,3),'"',',"',trim(m_rpt->
      rptlst[ml_loop].c_field2,3),
     '"',',"',trim(m_rpt->rptlst[ml_loop].c_field3,3),'"',',"',
     trim(m_rpt->rptlst[ml_loop].c_field4,3),'"',',"',trim(m_rpt->rptlst[ml_loop].c_field5,3),'"',
     ',"',trim(m_rpt->rptlst[ml_loop].c_field6,3),'"',',"',trim(m_rpt->rptlst[ml_loop].c_field7,3),
     '"',',"',trim(m_rpt->rptlst[ml_loop].c_field8,3),'"',',"',
     trim(m_rpt->rptlst[ml_loop].c_field9,3),'"',',"',trim(m_rpt->rptlst[ml_loop].c_field10,3),'"',
     ',"',trim(m_rpt->rptlst[ml_loop].c_field11,3),'"',',"',trim(m_rpt->rptlst[ml_loop].c_field12,3),
     '"',',"',trim(m_rpt->rptlst[ml_loop].c_field13,3),'"',',"',
     trim(m_rpt->rptlst[ml_loop].c_field14,3),'"',',"',trim(m_rpt->rptlst[ml_loop].c_field15,3),'"',
     ',"',trim(m_rpt->rptlst[ml_loop].c_field16,3),'"',',"',trim(m_rpt->rptlst[ml_loop].c_field17,3),
     '"',',"',trim(m_rpt->rptlst[ml_loop].c_field18,3),'"',',"',
     trim(m_rpt->rptlst[ml_loop].c_field19,3),'"',',"',trim(m_rpt->rptlst[ml_loop].c_field20,3),'"',
     ',"',trim(m_rpt->rptlst[ml_loop].c_field21,3),'"',',"',trim(m_rpt->rptlst[ml_loop].c_field22,3),
     '"',',"',trim(m_rpt->rptlst[ml_loop].c_field23,3),'"',',"',
     trim(m_rpt->rptlst[ml_loop].c_field24,3),'"',',"',trim(m_rpt->rptlst[ml_loop].c_field25,3),'"',
     ',"',trim(m_rpt->rptlst[ml_loop].c_field26,3),'"',',"',trim(m_rpt->rptlst[ml_loop].c_field27,3),
     '"',',"',trim(m_rpt->rptlst[ml_loop].c_field28,3),'"',',"',
     trim(m_rpt->rptlst[ml_loop].c_field29,3),'"',',"',trim(m_rpt->rptlst[ml_loop].c_field30,3),'"',
     ',"',trim(m_rpt->rptlst[ml_loop].c_field31,3),'"',',"',trim(m_rpt->rptlst[ml_loop].c_field32,3),
     '"',',"',trim(m_rpt->rptlst[ml_loop].c_field33,3),'"',',"',
     trim(m_rpt->rptlst[ml_loop].c_field34,3),'"',',"',trim(m_rpt->rptlst[ml_loop].c_field35,3),'"',
     ',"',trim(m_rpt->rptlst[ml_loop].c_field36,3),'"',',"',trim(m_rpt->rptlst[ml_loop].c_field37,3),
     '"',',"',trim(m_rpt->rptlst[ml_loop].c_field38,3),'"',',"',
     trim(m_rpt->rptlst[ml_loop].c_field39,3),'"',',"',trim(m_rpt->rptlst[ml_loop].c_field40,3),'"',
     ',"',trim(m_rpt->rptlst[ml_loop].c_field41,3),'"',',"',trim(m_rpt->rptlst[ml_loop].c_field42,3),
     '"',',"',trim(m_rpt->rptlst[ml_loop].c_field43,3),'"',',"',
     trim(m_rpt->rptlst[ml_loop].c_field44,3),'"',char(13),char(10))
    IF ((ml_loop < m_rpt->l_rptcnt))
     SET stat = cclio("PUTS",frec)
    ENDIF
   ENDFOR
   SET stat = cclio("WRITE",frec)
   SET stat = cclio("CLOSE",frec)
  ENDIF
 ELSE
  SET ms_email_body = " No Patient File Found for script BHS_RPT_HSRN"
  SET ms_mail_subject = " No Patient File Found for script BHS_RPT_HSRN "
  SET ms_sendto = "joseph.fenton2@baystatehealth.org"
  SET ms_msgcls = "IPM.NOTE"
  SET ms_sender = "d_p627@bhsmaapp1.cernerasp.com"
  CALL uar_send_mail(nullterm(ms_sendto),nullterm(ms_mail_subject),nullterm(ms_email_body),nullterm(
    ms_sender),ml_msgpriority,
   nullterm(ms_msgcls))
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 SET reply->ops_event = "Ops Job completed successfully"
 SET reply->status_data.subeventstatus[1].operationstatus = "S"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "Ops Job completed successfully"
 SET reply->status_data.subeventstatus[1].targetobjectname = ""
END GO
