CREATE PROGRAM bhs_extract_nanotech_cust:dba
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx3 = i4 WITH protect, noconstant(0)
 DECLARE ml_p_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_e_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_d_cnt = i4 WITH protect, noconstant(0)
 FREE RECORD m_pers
 RECORD m_pers(
   1 ml_cnt = i4
   1 qual[*]
     2 mf_person_id = f8
     2 ms_gender = vc
     2 ms_dob = vc
     2 ms_cmrn = vc
     2 ms_zip = vc
     2 enc[*]
       3 mf_encntr_id = f8
       3 ms_fin = vc
       3 ms_reg_dt = vc
       3 ms_arrive_dt = vc
       3 ms_disch_dt = vc
       3 ms_encntr_type = vc
       3 diag[*]
         4 mf_dx_id = f8
         4 ms_dx_code = vc
         4 ms_dx_vocab = vc
         4 ms_dx_type = vc
         4 ms_dx_active_dt = vc
         4 ms_dx_desc = vc
         4 ms_dx_concept_cki = vc
 ) WITH protect
 FREE RECORD m_enc
 RECORD m_enc(
   1 mf_person_id = f8
   1 ms_gender = vc
   1 ms_dob = vc
   1 ms_cmrn = vc
   1 ms_zip = vc
   1 enc[*]
     2 mf_encntr_id = f8
     2 ms_fin = vc
     2 ms_reg_dt = vc
     2 ms_arrive_dt = vc
     2 ms_disch_dt = vc
     2 ms_encntr_type = vc
     2 diag[*]
       3 mf_dx_id = f8
       3 ms_dx_code = vc
       3 ms_dx_vocab = vc
       3 ms_dx_type = vc
       3 ms_dx_active_dt = vc
       3 ms_dx_desc = vc
 ) WITH protect
 DECLARE ml_ndx = i4 WITH protect, noconstant(0)
 SET m_angelce_list_cnt = size(requestin->list_0,5)
 SELECT INTO "nl:"
  FROM orders o,
   person p,
   person_alias pa,
   diagnosis d,
   bhs_nomen_list bnl
  PLAN (o
   WHERE o.catalog_cd IN (570514693, 881933, 881949, 881931, 881870,
   881966, 881898, 881896, 881900, 909902,
   881872, 503378110, 313199701, 130899567, 495987214,
   787366, 788497, 788491, 787398, 478561861,
   787364, 787362, 385310606, 385310616, 385310621,
   575468450, 570514681, 570514693, 575468369, 575468381,
   580638240)
    AND o.order_status_cd=2543.00
    AND o.orig_order_dt_tm > cnvtdatetime((curdate - 1095),0))
   JOIN (p
   WHERE p.person_id=o.person_id
    AND p.birth_dt_tm < cnvtdatetime((curdate - 6417),0)
    AND p.deceased_dt_tm = null)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=2.0
    AND  NOT (expand(ml_ndx,1,m_angelce_list_cnt,cnvtreal(requestin->list_0[ml_ndx].cmrn),cnvtreal(pa
     .alias))))
   JOIN (d
   WHERE d.person_id=p.person_id
    AND d.active_ind=1
    AND d.end_effective_dt_tm > sysdate)
   JOIN (bnl
   WHERE bnl.nomenclature_id=d.nomenclature_id
    AND bnl.active_ind=1
    AND bnl.nomen_list_key="REGISTRY-CHF")
  ORDER BY p.person_id
  HEAD REPORT
   m_pers->ml_cnt = 0
  HEAD p.person_id
   m_pers->ml_cnt = (m_pers->ml_cnt+ 1), stat = alterlist(m_pers->qual,m_pers->ml_cnt), m_pers->qual[
   m_pers->ml_cnt].mf_person_id = p.person_id
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM person p,
   person_alias pa,
   address a
  PLAN (p
   WHERE expand(ml_idx1,1,m_pers->ml_cnt,p.person_id,m_pers->qual[ml_idx1].mf_person_id))
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate
    AND pa.person_alias_type_cd=2.0)
   JOIN (a
   WHERE a.parent_entity_name=outerjoin("PERSON")
    AND a.parent_entity_id=outerjoin(p.person_id)
    AND a.active_ind=outerjoin(1)
    AND a.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00"))
    AND a.address_type_cd=outerjoin(756.00)
    AND a.address_type_seq=outerjoin(1))
  ORDER BY p.person_id
  HEAD p.person_id
   ml_idx2 = 0, ml_idx2 = locateval(ml_idx1,1,m_pers->ml_cnt,p.person_id,m_pers->qual[ml_idx1].
    mf_person_id)
   IF (ml_idx2 > 0)
    m_pers->qual[ml_idx2].ms_gender = substring(1,1,uar_get_code_display(p.sex_cd)), m_pers->qual[
    ml_idx2].ms_dob = format(p.birth_dt_tm,"MM/DD/YYYY;;q"), m_pers->qual[ml_idx2].ms_cmrn = trim(pa
     .alias,3),
    m_pers->qual[ml_idx2].ms_zip = trim(a.zipcode,3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 FOR (ml_idx2 = 1 TO m_pers->ml_cnt)
  SET ml_e_cnt = 0
  SELECT INTO "nl:"
   FROM encounter e,
    diagnosis d,
    nomenclature n
   PLAN (e
    WHERE (e.person_id=m_pers->qual[ml_idx2].mf_person_id)
     AND e.active_ind=1
     AND e.reg_dt_tm IS NOT null)
    JOIN (d
    WHERE d.encntr_id=outerjoin(e.encntr_id)
     AND d.active_ind=outerjoin(1)
     AND d.end_effective_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 00:00:00.00")))
    JOIN (n
    WHERE n.nomenclature_id=outerjoin(d.nomenclature_id))
   ORDER BY e.encntr_id, d.diagnosis_id
   HEAD e.encntr_id
    ml_e_cnt = (ml_e_cnt+ 1), stat = alterlist(m_pers->qual[ml_idx2].enc,ml_e_cnt), m_pers->qual[
    ml_idx2].enc[ml_e_cnt].mf_encntr_id = e.encntr_id,
    m_pers->qual[ml_idx2].enc[ml_e_cnt].ms_encntr_type = uar_get_code_display(e.encntr_type_cd),
    m_pers->qual[ml_idx2].enc[ml_e_cnt].ms_arrive_dt = format(e.arrive_dt_tm,"MM/DD/YYYY HH:mm:ss;;q"
     ), m_pers->qual[ml_idx2].enc[ml_e_cnt].ms_disch_dt = format(e.disch_dt_tm,
     "MM/DD/YYYY HH:mm:ss;;q"),
    m_pers->qual[ml_idx2].enc[ml_e_cnt].ms_reg_dt = format(e.reg_dt_tm,"MM/DD/YYYY HH:mm:ss;;q"),
    ml_d_cnt = 0
   HEAD d.diagnosis_id
    IF (d.diagnosis_id > 0
     AND d.nomenclature_id > 0)
     ml_d_cnt = (ml_d_cnt+ 1), stat = alterlist(m_pers->qual[ml_idx2].enc[ml_e_cnt].diag,ml_d_cnt),
     m_pers->qual[ml_idx2].enc[ml_e_cnt].diag[ml_d_cnt].mf_dx_id = d.diagnosis_id,
     m_pers->qual[ml_idx2].enc[ml_e_cnt].diag[ml_d_cnt].ms_dx_active_dt = format(d
      .beg_effective_dt_tm,"MM/DD/YYYY HH:mm:ss;;q"), m_pers->qual[ml_idx2].enc[ml_e_cnt].diag[
     ml_d_cnt].ms_dx_type = uar_get_code_display(d.diag_type_cd), m_pers->qual[ml_idx2].enc[ml_e_cnt]
     .diag[ml_d_cnt].ms_dx_code = trim(n.source_identifier,3),
     m_pers->qual[ml_idx2].enc[ml_e_cnt].diag[ml_d_cnt].ms_dx_desc = trim(n.source_string,3), m_pers
     ->qual[ml_idx2].enc[ml_e_cnt].diag[ml_d_cnt].ms_dx_vocab = uar_get_code_display(n
      .source_vocabulary_cd), m_pers->qual[ml_idx2].enc[ml_e_cnt].diag[ml_d_cnt].ms_dx_concept_cki =
     trim(n.concept_cki,3)
    ENDIF
   WITH nocounter
  ;end select
 ENDFOR
 DECLARE m_per_str = vc WITH protect, noconstant("")
 DECLARE m_enc_str = vc WITH protect, noconstant("")
 DECLARE m_diag_str = vc WITH protect, noconstant("")
 DECLARE ms_tab = vc WITH protect, constant(char(09))
 DECLARE ml_output_size = i4 WITH protect, noconstant(0)
 FOR (ml_idx1 = 1 TO m_pers->ml_cnt)
   SET m_per_str = concat(m_pers->qual[ml_idx1].ms_cmrn,ms_tab,m_pers->qual[ml_idx1].ms_dob,ms_tab,
    m_pers->qual[ml_idx1].ms_gender,
    ms_tab,m_pers->qual[ml_idx1].ms_zip)
   SET ml_output_size = size(m_per_str)
   SELECT INTO "bhs_nano_pat.txt"
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     CALL print(m_per_str)
    WITH nocounter, maxcol = 130, format,
     append, noheading
   ;end select
   SET m_enc_str = ""
   IF (size(m_pers->qual[ml_idx1].enc,5) > 0)
    FOR (ml_idx2 = 1 TO size(m_pers->qual[ml_idx1].enc,5))
      SET m_enc_str = concat(m_pers->qual[ml_idx1].ms_cmrn,ms_tab,trim(cnvtstring(m_pers->qual[
         ml_idx1].enc[ml_idx2].mf_encntr_id,20),3),ms_tab,m_pers->qual[ml_idx1].enc[ml_idx2].
       ms_arrive_dt,
       ms_tab,m_pers->qual[ml_idx1].enc[ml_idx2].ms_reg_dt,ms_tab,m_pers->qual[ml_idx1].enc[ml_idx2].
       ms_disch_dt,ms_tab,
       m_pers->qual[ml_idx1].enc[ml_idx2].ms_encntr_type)
      SELECT INTO "bhs_nano_enc.txt"
       FROM (dummyt d  WITH seq = 1)
       DETAIL
        CALL print(m_enc_str)
       WITH nocounter, maxcol = 150, format,
        append, noheading
      ;end select
      SET m_diag_str = ""
      IF (size(m_pers->qual[ml_idx1].enc[ml_idx2].diag,5) > 0)
       FOR (ml_idx3 = 1 TO size(m_pers->qual[ml_idx1].enc[ml_idx2].diag,5))
        SET m_diag_str = concat(m_pers->qual[ml_idx1].ms_cmrn,ms_tab,trim(cnvtstring(m_pers->qual[
           ml_idx1].enc[ml_idx2].mf_encntr_id,20),3),ms_tab,m_pers->qual[ml_idx1].enc[ml_idx2].diag[
         ml_idx3].ms_dx_code,
         ms_tab,m_pers->qual[ml_idx1].enc[ml_idx2].diag[ml_idx3].ms_dx_vocab,ms_tab,m_pers->qual[
         ml_idx1].enc[ml_idx2].diag[ml_idx3].ms_dx_type,ms_tab,
         m_pers->qual[ml_idx1].enc[ml_idx2].diag[ml_idx3].ms_dx_active_dt,ms_tab,m_pers->qual[ml_idx1
         ].enc[ml_idx2].diag[ml_idx3].ms_dx_desc,ms_tab,m_pers->qual[ml_idx1].enc[ml_idx2].diag[
         ml_idx3].ms_dx_concept_cki)
        SELECT INTO "bhs_nano_dx.txt"
         FROM (dummyt d  WITH seq = 1)
         DETAIL
          CALL print(m_diag_str)
         WITH nocounter, maxcol = 500, format,
          append, noheading
        ;end select
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
END GO
