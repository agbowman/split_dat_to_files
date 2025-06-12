CREATE PROGRAM bhs_dist_read_hne_file:dba
 DECLARE ms_current_date = vc WITH protect, constant(format(cnvtdatetime(sysdate),"YYYYMMDDHHMMSS;;d"
   ))
 DECLARE ms_files_loc = vc WITH protect, constant(concat(trim(logical("bhscust"),3),"/hne/xr/aca/"))
 DECLARE ms_read_file = vc WITH protect, constant(concat("hne_xr_file_list_",ms_current_date,".txt"))
 DECLARE ml_stat = i4 WITH protect, noconstant(0)
 DECLARE ms_dclcom = vc WITH protect, noconstant("")
 DECLARE ml_file_loop = i4 WITH protect, noconstant(0)
 DECLARE mf_cs319_fin_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE ml_cidx = i4 WITH protect, noconstant(0)
 DECLARE ml_lcnt = i4 WITH protect, noconstant(0)
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_idx2 = i4 WITH protect, noconstant(0)
 FREE RECORD hne_in
 RECORD hne_in(
   1 l_cnt = i4
   1 qual[*]
     2 s_filename = vc
 )
 FREE RECORD m_tmp_fin
 RECORD m_tmp_fin(
   1 l_cnt = i4
   1 qual[*]
     2 s_fin = vc
 ) WITH protect
 SET ms_dclcom = concat("ls ",ms_files_loc,"*.csv | xargs -n 1 basename "," > ",ms_files_loc,
  ms_read_file)
 CALL echo(build("DCL:",ms_dclcom))
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
 SET ms_dclcom = concat("chmod 777 ",ms_files_loc,ms_read_file)
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
 SET logical hne_in_ls value(build(ms_files_loc,ms_read_file))
 FREE DEFINE rtl2
 DEFINE rtl2 "hne_in_ls"
 SELECT INTO "nl:"
  FROM rtl2t r
  WHERE  NOT (r.line IN ("", " ", null))
   AND r.line != "total *"
   AND r.line != "d*"
  HEAD REPORT
   hne_in->l_cnt = 0
  DETAIL
   hne_in->l_cnt += 1, stat = alterlist(hne_in->qual,hne_in->l_cnt), hne_in->qual[hne_in->l_cnt].
   s_filename = trim(r.line,3)
  WITH nocounter
 ;end select
 FREE DEFINE rtl2
 CALL echorecord(hne_in)
 SET ms_dclcom = concat("mkdir ",ms_files_loc,"archive/",ms_current_date)
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
 SET ms_dclcom = concat("chmod 777 ",ms_files_loc,"archive/",ms_current_date)
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
 SET ms_dclcom = concat("mv ",ms_files_loc,ms_read_file," ",ms_files_loc,
  "archive/",ms_current_date,"/",ms_read_file)
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
 IF ((hne_in->l_cnt > 0))
  FOR (ml_file_loop = 1 TO hne_in->l_cnt)
    SET logical hne_in_ls value(build(ms_files_loc,hne_in->qual[ml_file_loop].s_filename))
    FREE DEFINE rtl2
    DEFINE rtl2 "hne_in_ls"
    SELECT INTO "nl:"
     FROM rtl2t r
     WHERE  NOT (r.line IN ("", " ", null))
     HEAD REPORT
      CALL echo(hne_in->qual[ml_file_loop].s_filename), ml_lcnt = 0
     DETAIL
      ml_lcnt += 1
      IF (ml_lcnt > 1)
       CALL echo(r.line), ml_cidx = findstring(",",r.line,1,1), m_tmp_fin->l_cnt += 1,
       stat = alterlist(m_tmp_fin->qual,m_tmp_fin->l_cnt), m_tmp_fin->qual[m_tmp_fin->l_cnt].s_fin =
       trim(substring((ml_cidx+ 1),25,r.line),3)
      ENDIF
     WITH nocounter
    ;end select
    SET ms_dclcom = concat("mv ",ms_files_loc,hne_in->qual[ml_file_loop].s_filename," ",ms_files_loc,
     "archive/",ms_current_date,"/",hne_in->qual[ml_file_loop].s_filename)
    CALL dcl(ms_dclcom,size(trim(ms_dclcom)),ml_stat)
  ENDFOR
 ENDIF
 IF ((m_tmp_fin->l_cnt > 0))
  SELECT INTO "nl:"
   FROM encntr_alias ea,
    encounter e
   PLAN (ea
    WHERE expand(ml_idx1,1,m_tmp_fin->l_cnt,ea.alias,m_tmp_fin->qual[ml_idx1].s_fin)
     AND ea.active_ind=1
     AND ea.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND ea.encntr_alias_type_cd=mf_cs319_fin_cd)
    JOIN (e
    WHERE e.encntr_id=ea.encntr_id
     AND e.active_ind=1)
   ORDER BY e.encntr_id
   HEAD REPORT
    ml_idx2 = 0
   HEAD e.encntr_id
    ml_idx2 += 1, stat = alterlist(cp_encntr->encntr_list,ml_idx2), cp_encntr->encntr_list[ml_idx2].
    encntr_id = e.encntr_id,
    cp_encntr->encntr_list[ml_idx2].person_id = e.person_id
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(m_tmp_fin)
 CALL echorecord(cp_encntr)
#exit_script
END GO
