CREATE PROGRAM bhs_updt_prov_email:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp_str = vc WITH protect, noconstant("")
 FREE RECORD m_rec
 RECORD m_rec(
   1 l_cnt = i4
   1 qual[*]
     2 s_active_ind = vc
     2 s_phys_ind = vc
     2 s_username = vc
     2 f_person_id = f8
     2 s_fname = vc
     2 s_lname = vc
     2 s_email = vc
     2 s_match_username = vc
     2 s_match_active_ind = vc
     2 s_match_phys_ind = vc
     2 s_match_fname = vc
     2 s_match_lname = vc
     2 s_match_email = vc
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_name = vc
   1 file_buf = vc
   1 file_dir = i4
   1 file_offset = i4
 )
 IF (findfile("bhs_prsnl_email.file",4) != 1)
  SET reply->text =
  "Terms file lbh_ext_cancer_icd.file not found. This file is needed for the extract to function."
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl2
 DEFINE rtl2 "ccluserdir:bhs_prsnl_email.file"
 SELECT INTO "nl:"
  FROM rtl2t r
  HEAD REPORT
   m_rec->l_cnt = 0
  DETAIL
   m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), ms_tmp_str = trim(r.line,3),
   ml_idx1 = findstring(",",ms_tmp_str), m_rec->qual[m_rec->l_cnt].s_active_ind = substring(1,(
    ml_idx1 - 1),ms_tmp_str), ms_tmp_str = trim(substring((ml_idx1+ 1),size(ms_tmp_str),ms_tmp_str),3
    ),
   ml_idx1 = findstring(",",ms_tmp_str), m_rec->qual[m_rec->l_cnt].s_phys_ind = substring(1,(ml_idx1
     - 1),ms_tmp_str), ms_tmp_str = trim(substring((ml_idx1+ 1),size(ms_tmp_str),ms_tmp_str),3),
   ml_idx1 = findstring(",",ms_tmp_str), m_rec->qual[m_rec->l_cnt].s_username = substring(1,(ml_idx1
     - 1),ms_tmp_str), ms_tmp_str = trim(substring((ml_idx1+ 1),size(ms_tmp_str),ms_tmp_str),3),
   ml_idx1 = findstring(",",ms_tmp_str), m_rec->qual[m_rec->l_cnt].f_person_id = cnvtreal(substring(1,
     (ml_idx1 - 1),ms_tmp_str)), ms_tmp_str = trim(substring((ml_idx1+ 1),size(ms_tmp_str),ms_tmp_str
     ),3),
   ml_idx1 = findstring(",",ms_tmp_str), m_rec->qual[m_rec->l_cnt].s_fname = substring(1,(ml_idx1 - 1
    ),ms_tmp_str), ms_tmp_str = trim(substring((ml_idx1+ 1),size(ms_tmp_str),ms_tmp_str),3),
   ml_idx1 = findstring(",",ms_tmp_str), m_rec->qual[m_rec->l_cnt].s_lname = substring(1,(ml_idx1 - 1
    ),ms_tmp_str), m_rec->qual[m_rec->l_cnt].s_email = trim(substring((ml_idx1+ 1),size(ms_tmp_str),
     ms_tmp_str),3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE expand(ml_idx1,1,m_rec->l_cnt,p.person_id,m_rec->qual[ml_idx1].f_person_id))
  ORDER BY p.person_id
  HEAD p.person_id
   ml_idx2 = locateval(ml_idx1,1,m_rec->l_cnt,p.person_id,m_rec->qual[ml_idx1].f_person_id)
   IF (ml_idx2 > 0)
    m_rec->qual[ml_idx2].s_match_active_ind = trim(cnvtstring(p.active_ind),3), m_rec->qual[ml_idx2].
    s_match_phys_ind = trim(cnvtstring(p.physician_ind),3), m_rec->qual[ml_idx2].s_match_username =
    trim(p.username,3),
    m_rec->qual[ml_idx2].s_match_fname = trim(p.name_first,3), m_rec->qual[ml_idx2].s_match_lname =
    trim(p.name_last,3), m_rec->qual[ml_idx2].s_match_email = trim(p.email,3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 FOR (ml_idx1 = 1 TO m_rec->l_cnt)
   IF (trim(cnvtupper(m_rec->qual[ml_idx1].s_username),3)=trim(cnvtupper(m_rec->qual[ml_idx1].
     s_match_username),3)
    AND size(trim(m_rec->qual[ml_idx1].s_email,3)) > 0
    AND size(trim(m_rec->qual[ml_idx1].s_match_email),3)=0)
    UPDATE  FROM prsnl p
     SET p.email = trim(m_rec->qual[ml_idx1].s_email,3), p.updt_cnt = (p.updt_cnt+ 1), p.updt_id = 99
     WHERE (p.person_id=m_rec->qual[ml_idx1].f_person_id)
    ;end update
    COMMIT
   ENDIF
 ENDFOR
#exit_script
END GO
