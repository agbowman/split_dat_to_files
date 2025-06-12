CREATE PROGRAM al_test_race_data:dba
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 ) WITH protect
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 f_person_id = f8
     2 s_name = vc
     2 s_cmrn = vc
     2 s_person_race = vc
     2 s_race1 = vc
     2 s_race2 = vc
     2 s_race3 = vc
     2 s_race4 = vc
     2 s_race5 = vc
 ) WITH protect
 SELECT INTO "nl:"
  FROM person p,
   person_alias pa
  PLAN (p
   WHERE p.active_ind=1
    AND p.race_cd=566080184.0)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.active_ind=1
    AND pa.person_alias_type_cd=2.00)
  ORDER BY p.person_id, pa.beg_effective_dt_tm
  HEAD p.person_id
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
   f_person_id = p.person_id,
   m_rec->qual[m_rec->l_cnt].s_name = trim(p.name_full_formatted,3), m_rec->qual[m_rec->l_cnt].s_cmrn
    = trim(pa.alias,3), m_rec->qual[m_rec->l_cnt].s_person_race = trim(uar_get_code_display(p.race_cd
     ),3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM person_info pi
  PLAN (pi
   WHERE expand(ml_idx1,1,m_rec->l_cnt,pi.person_id,m_rec->qual[ml_idx1].f_person_id)
    AND pi.active_ind=1
    AND pi.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND pi.info_sub_type_cd IN (778552579.00, 777030121.00, 777030161.00, 777030185.00, 777030497.00)
    AND pi.info_type_cd=1170.0)
  ORDER BY pi.person_id
  HEAD pi.person_id
   ml_idx2 = locatevalsort(ml_idx1,1,m_rec->l_cnt,pi.person_id,m_rec->qual[ml_idx1].f_person_id)
  DETAIL
   IF (ml_idx2 > 0)
    IF (pi.value_cd > 0)
     IF (pi.info_sub_type_cd=778552579.0)
      m_rec->qual[ml_idx2].s_race1 = trim(uar_get_code_display(pi.value_cd),3)
     ELSEIF (pi.info_sub_type_cd=777030121.0)
      m_rec->qual[ml_idx2].s_race2 = trim(uar_get_code_display(pi.value_cd),3)
     ELSEIF (pi.info_sub_type_cd=777030161.0)
      m_rec->qual[ml_idx2].s_race3 = trim(uar_get_code_display(pi.value_cd),3)
     ELSEIF (pi.info_sub_type_cd=777030185.0)
      m_rec->qual[ml_idx2].s_race4 = trim(uar_get_code_display(pi.value_cd),3)
     ELSEIF (pi.info_sub_type_cd=777030497.0)
      m_rec->qual[ml_idx2].s_race5 = trim(uar_get_code_display(pi.value_cd),3)
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SET frec->file_name = "pat_race_multiple.csv"
 SET frec->file_buf = "w"
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = build('"',"Patient",'","',"CMRN",'","',
  "Race on Patient Table",'","',"Race1",'","',"Race2",
  '","',"Race3",'","',"Race4",'","',
  "Race5",'"',char(13),char(10))
 SET stat = cclio("WRITE",frec)
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   IF (size(trim(m_rec->qual[ml_idx1].s_race1,3))=0
    AND size(trim(m_rec->qual[ml_idx1].s_race2,3))=0
    AND size(trim(m_rec->qual[ml_idx1].s_race3,3))=0
    AND size(trim(m_rec->qual[ml_idx1].s_race4,3))=0
    AND size(trim(m_rec->qual[ml_idx1].s_race5,3))=0)
    SET frec->file_buf = build('"',trim(m_rec->qual[ml_idx1].s_name,3),'","',trim(m_rec->qual[ml_idx1
      ].s_cmrn,3),'","',
     trim(m_rec->qual[ml_idx1].s_person_race,3),'","',trim(m_rec->qual[ml_idx1].s_race1,3),'","',trim
     (m_rec->qual[ml_idx1].s_race2,3),
     '","',trim(m_rec->qual[ml_idx1].s_race3,3),'","',trim(m_rec->qual[ml_idx1].s_race4,3),'","',
     trim(m_rec->qual[ml_idx1].s_race5,3),'"',char(13),char(10))
    SET stat = cclio("WRITE",frec)
   ELSEIF (size(trim(m_rec->qual[ml_idx1].s_race1,3)) != 0
    AND size(trim(m_rec->qual[ml_idx1].s_race2,3))=0
    AND size(trim(m_rec->qual[ml_idx1].s_race3,3))=0
    AND size(trim(m_rec->qual[ml_idx1].s_race4,3))=0
    AND size(trim(m_rec->qual[ml_idx1].s_race5,3))=0)
    SET frec->file_buf = build('"',trim(m_rec->qual[ml_idx1].s_name,3),'","',trim(m_rec->qual[ml_idx1
      ].s_cmrn,3),'","',
     trim(m_rec->qual[ml_idx1].s_person_race,3),'","',trim(m_rec->qual[ml_idx1].s_race1,3),'","',trim
     (m_rec->qual[ml_idx1].s_race2,3),
     '","',trim(m_rec->qual[ml_idx1].s_race3,3),'","',trim(m_rec->qual[ml_idx1].s_race4,3),'","',
     trim(m_rec->qual[ml_idx1].s_race5,3),'"',char(13),char(10))
    SET stat = cclio("WRITE",frec)
   ENDIF
 ENDFOR
 SET stat = cclio("CLOSE",frec)
#exit_script
END GO
