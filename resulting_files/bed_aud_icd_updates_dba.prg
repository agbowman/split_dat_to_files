CREATE PROGRAM bed_aud_icd_updates:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE SET tnom
 RECORD tnom(
   1 syns[*]
     2 nomen_id = f8
     2 nonbill_ind = i2
     2 active_ind = i2
     2 obsolete_ind = i2
     2 dig_folder = vc
     2 fav_folder = vc
     2 fam_his = vc
     2 pn = vc
     2 hmaint = vc
     2 ignore_ind = i2
     2 end_effective_dt_tm = dq8
     2 source_identifier = vc
 )
 FREE RECORD icd9s
 RECORD icd9s(
   1 icd9[*]
     2 value = vc
     2 scr_term_id = f8
     2 nomenclature_id = f8
     2 cki_identifier = vc
 )
 SET reply->status_data.status = "F"
 SET tot_cnt = 0
 SET tot_col = 9
 SET stat = alterlist(reply->collist,tot_col)
 SET reply->collist[1].header_text = "Code"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Term"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Inactive"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Obsolete"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Non-Billable"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "PowerNote Encounter Pathway"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Diagnosis Folder"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Favorites Folder"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Family History Folder"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET icd_code = uar_get_code_by("MEANING",400,"ICD9")
 SET content_version_id = 0.0
 SELECT INTO "nl:"
  c.version_ft
  FROM cmt_content_version c
  WHERE c.source_vocabulary_cd=icd_code
  ORDER BY c.version_number DESC
  DETAIL
   content_version_id = c.cmt_content_version_id
  WITH maxqual(c,1)
 ;end select
 IF (content_version_id=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value c,
   nomen_cat_list ncl,
   nomen_category nc,
   nomenclature n,
   icd9cm_extension i
  PLAN (c
   WHERE c.code_set=25321
    AND c.cdf_meaning="DIAGNOSIS"
    AND c.active_ind=1)
   JOIN (nc
   WHERE nc.category_type_cd=c.code_value
    AND nc.parent_entity_name IN ("GENERAL", "PRSNL"))
   JOIN (ncl
   WHERE ncl.parent_category_id=nc.nomen_category_id
    AND ncl.nomenclature_id > 0)
   JOIN (n
   WHERE n.nomenclature_id=ncl.nomenclature_id
    AND n.source_vocabulary_cd=icd_code)
   JOIN (i
   WHERE i.source_identifier=outerjoin(n.source_identifier)
    AND i.active_ind=outerjoin(n.active_ind)
    AND i.valid_flag_desc=outerjoin("N"))
  ORDER BY n.nomenclature_id, cnvtupper(nc.category_name), nc.nomen_category_id,
   i.end_effective_dt_tm
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(tnom->syns,100),
   nom_load = 0, g_load = 0, e_load = 0
  HEAD n.nomenclature_id
   nom_load = 0
   IF (((((n.active_ind=0) OR (((n.beg_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (n
   .end_effective_dt_tm <= cnvtdatetime(curdate,curtime3))) )) ) OR (i.icd9cm_extension_id > 0)) )
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 100)
     stat = alterlist(tnom->syns,(tcnt+ 100)), cnt = 1
    ENDIF
    tnom->syns[tcnt].nomen_id = n.nomenclature_id, tnom->syns[tcnt].active_ind = n.active_ind
    IF (((n.beg_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (n.end_effective_dt_tm <=
    cnvtdatetime(curdate,curtime3))) )
     tnom->syns[tcnt].obsolete_ind = 1
    ENDIF
    IF (i.icd9cm_extension_id > 0)
     tnom->syns[tcnt].nonbill_ind = 1
    ENDIF
    nom_load = 1
   ENDIF
   g_load = 0, e_load = 0
  HEAD nc.nomen_category_id
   IF (nom_load=1)
    IF (nc.parent_entity_name="GENERAL")
     IF (g_load=0)
      tnom->syns[tcnt].dig_folder = trim(nc.category_name), g_load = 1
     ELSE
      tnom->syns[tcnt].dig_folder = concat(tnom->syns[tcnt].dig_folder,", ",trim(nc.category_name))
     ENDIF
    ELSE
     IF (e_load=0)
      tnom->syns[tcnt].fav_folder = trim(nc.category_name), e_load = 1
     ELSE
      tnom->syns[tcnt].fav_folder = concat(tnom->syns[tcnt].fav_folder,", ",trim(nc.category_name))
     ENDIF
    ENDIF
   ENDIF
  DETAIL
   IF (nom_load=1)
    IF (i.icd9cm_extension_id > 0)
     tnom->syns[tcnt].nonbill_ind = 1
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(tnom->syns,tcnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM fhx_section_def f,
   code_value c,
   nomenclature n,
   icd9cm_extension i
  PLAN (f
   WHERE f.nomenclature_id > 0
    AND f.active_ind=1)
   JOIN (c
   WHERE c.code_value=f.category_cd
    AND c.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=f.nomenclature_id
    AND n.source_vocabulary_cd=icd_code)
   JOIN (i
   WHERE i.source_identifier=outerjoin(n.source_identifier)
    AND i.active_ind=outerjoin(n.active_ind)
    AND i.valid_flag_desc=outerjoin("N"))
  ORDER BY n.nomenclature_id, c.display_key, c.code_value,
   i.end_effective_dt_tm
  HEAD REPORT
   cnt = 0, tcnt = size(tnom->syns,5), stat = alterlist(tnom->syns,(tcnt+ 100)),
   nom_load = 0, c_load = 0
  HEAD n.nomenclature_id
   nom_load = 0
   IF (((((n.active_ind=0) OR (((n.beg_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (n
   .end_effective_dt_tm <= cnvtdatetime(curdate,curtime3))) )) ) OR (i.icd9cm_extension_id > 0)) )
    cnt = (cnt+ 1), tcnt = (tcnt+ 1)
    IF (cnt > 100)
     stat = alterlist(tnom->syns,(tcnt+ 100)), cnt = 1
    ENDIF
    tnom->syns[tcnt].nomen_id = n.nomenclature_id, tnom->syns[tcnt].active_ind = n.active_ind
    IF (((n.beg_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (n.end_effective_dt_tm <=
    cnvtdatetime(curdate,curtime3))) )
     tnom->syns[tcnt].obsolete_ind = 1
    ENDIF
    IF (i.icd9cm_extension_id > 0)
     tnom->syns[tcnt].nonbill_ind = 1
    ENDIF
    nom_load = 1
   ENDIF
   c_load = 0
  HEAD c.code_value
   IF (nom_load=1)
    IF (c_load=0)
     tnom->syns[tcnt].fam_his = trim(c.display), c_load = 1
    ELSE
     tnom->syns[tcnt].fam_his = concat(tnom->syns[tcnt].fam_his,", ",trim(c.display))
    ENDIF
   ENDIF
  DETAIL
   IF (nom_load=1)
    IF (i.icd9cm_extension_id > 0)
     tnom->syns[tcnt].nonbill_ind = 1
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(tnom->syns,tcnt)
  WITH nocounter
 ;end select
 SET diagnosis_code = 0.0
 SET diagnosis_code = uar_get_code_by("MEANING",14413,"DIAGNOSIS")
 SET dx_nomen_code = 0.0
 SET dx_nomen_code = uar_get_code_by("MEANING",14709,"DX NOMEN")
 SET def_code = 0.0
 SET def_code = uar_get_code_by("MEANING",14709,"DEF")
 SET icdcount = 0
 DECLARE icd = vc
 SELECT INTO "nl:"
  FROM scr_term term,
   scr_term_definition def
  PLAN (term
   WHERE term.term_type_cd=diagnosis_code
    AND term.active_ind=1)
   JOIN (def
   WHERE def.scr_term_def_id=term.scr_term_def_id
    AND def.fkey_entity_name="NOMENCLATURE"
    AND def.scr_term_def_type_cd IN (def_code, dx_nomen_code))
  ORDER BY term.scr_term_id
  DETAIL
   icd9pos = 0
   IF (def.scr_term_def_type_cd=dx_nomen_code)
    icd9pos = findstring("ICD9!",def.def_text,1,1)
    IF (icd9pos > 0)
     defsize = size(def.def_text), icd = substring((icd9pos+ 5),defsize,def.def_text), icdcount = (
     icdcount+ 1),
     stat = alterlist(icd9s->icd9,icdcount), icd9s->icd9[icdcount].value = icd, icd9s->icd9[icdcount]
     .scr_term_id = term.scr_term_id
    ENDIF
   ELSE
    icd9pos = findstring("CKII=",def.def_text,1,1)
    IF (icd9pos > 0)
     defsize = size(def.def_text), icd = substring((icd9pos+ 5),defsize,def.def_text), icdcount = (
     icdcount+ 1),
     stat = alterlist(icd9s->icd9,icdcount), icd9s->icd9[icdcount].value = icd, icd9s->icd9[icdcount]
     .scr_term_id = term.scr_term_id
    ELSE
     icd9pos = findstring("ICD9!=",def.def_text,1,1)
     IF (icd9pos > 0)
      defsize = size(def.def_text), icd = substring((icd9pos+ 6),defsize,def.def_text), icdcount = (
      icdcount+ 1),
      stat = alterlist(icd9s->icd9,icdcount), icd9s->icd9[icdcount].value = icd, icd9s->icd9[icdcount
      ].scr_term_id = term.scr_term_id
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM scr_term term
  PLAN (term
   WHERE term.term_type_cd=diagnosis_code
    AND term.concept_cki="ICD9CM!*"
    AND term.active_ind=1)
  DETAIL
   defsize = size(term.concept_cki), icd = substring(7,defsize,term.concept_cki), icdcount = (
   icdcount+ 1),
   stat = alterlist(icd9s->icd9,icdcount), icd9s->icd9[icdcount].value = icd, icd9s->icd9[icdcount].
   scr_term_id = term.scr_term_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM scr_term_hier term
  PLAN (term
   WHERE term.cki_source="CKI"
    AND term.concept_cki="ICD9CM!*")
  DETAIL
   defsize = size(term.concept_cki), icd = substring(7,defsize,term.concept_cki), icdcount = (
   icdcount+ 1),
   stat = alterlist(icd9s->icd9,icdcount), icd9s->icd9[icdcount].value = icd, icd9s->icd9[icdcount].
   scr_term_id = term.scr_term_id
  WITH nocounter
 ;end select
 IF (icdcount > 0)
  SET ep_code = 0.0
  SET ep_code = uar_get_code_by("MEANING",14409,"EP")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(icdcount)),
    nomenclature n,
    icd9cm_extension i,
    scr_term term,
    scr_term_text text,
    scr_term_hier hier,
    scr_pattern pat
   PLAN (d)
    JOIN (n
    WHERE n.source_identifier=trim(icd9s->icd9[d.seq].value)
     AND n.source_vocabulary_cd=icd_code)
    JOIN (i
    WHERE i.source_identifier=outerjoin(n.source_identifier)
     AND i.active_ind=outerjoin(n.active_ind)
     AND i.valid_flag_desc=outerjoin("N"))
    JOIN (term
    WHERE (term.scr_term_id=icd9s->icd9[d.seq].scr_term_id)
     AND term.active_ind=1)
    JOIN (text
    WHERE text.scr_term_id=term.scr_term_id)
    JOIN (hier
    WHERE hier.scr_term_id=term.scr_term_id)
    JOIN (pat
    WHERE pat.scr_pattern_id=hier.scr_pattern_id
     AND pat.pattern_type_cd=ep_code
     AND pat.active_ind=1)
   ORDER BY n.source_identifier, n.end_effective_dt_tm, cnvtupper(pat.definition),
    pat.scr_pattern_id, i.end_effective_dt_tm
   HEAD REPORT
    cnt = 0, tcnt = size(tnom->syns,5), stat = alterlist(tnom->syns,(tcnt+ 100)),
    nom_load = 0, pat_load = 0
   DETAIL
    IF (((((n.active_ind=0) OR (((n.beg_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (n
    .end_effective_dt_tm <= cnvtdatetime(curdate,curtime3))) )) ) OR (i.icd9cm_extension_id > 0)) )
     cnt = (cnt+ 1), tcnt = (tcnt+ 1)
     IF (cnt > 100)
      stat = alterlist(tnom->syns,(tcnt+ 100)), cnt = 1
     ENDIF
     nom_load = 1
    ELSE
     nom_load = 0
    ENDIF
    pat_load = 0
    IF (nom_load=1)
     IF (pat_load=0)
      tnom->syns[tcnt].pn = trim(pat.definition), pat_load = 1
     ELSE
      tnom->syns[tcnt].pn = concat(tnom->syns[tcnt].pn,", ",trim(pat.definition))
     ENDIF
     IF (i.icd9cm_extension_id > 0)
      tnom->syns[tcnt].nonbill_ind = 1
     ENDIF
     tnom->syns[tcnt].nomen_id = n.nomenclature_id, tnom->syns[tcnt].active_ind = n.active_ind
     IF (((n.beg_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (n.end_effective_dt_tm <=
     cnvtdatetime(curdate,curtime3))) )
      tnom->syns[tcnt].obsolete_ind = 1
     ENDIF
     tnom->syns[tcnt].source_identifier = n.source_identifier, tnom->syns[tcnt].end_effective_dt_tm
      = n.end_effective_dt_tm
    ENDIF
   FOOT REPORT
    stat = alterlist(tnom->syns,tcnt)
   WITH nocounter
  ;end select
  SET tcnt = size(tnom->syns,5)
  IF (tcnt=0)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tcnt)),
    nomenclature n
   PLAN (d)
    JOIN (n
    WHERE n.source_vocabulary_cd=icd_code
     AND ((n.primary_vterm_ind+ 0)=1)
     AND n.active_ind=1
     AND (n.source_identifier=tnom->syns[d.seq].source_identifier)
     AND cnvtdatetime(tnom->syns[d.seq].end_effective_dt_tm) < n.end_effective_dt_tm
     AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3))
   DETAIL
    tnom->syns[d.seq].ignore_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 SET tcnt = size(tnom->syns,5)
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET tot_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(tcnt)),
   nomenclature n
  PLAN (d
   WHERE (tnom->syns[d.seq].ignore_ind=0))
   JOIN (n
   WHERE (n.nomenclature_id=tnom->syns[d.seq].nomen_id))
  ORDER BY n.source_identifier, cnvtupper(n.source_string), n.nomenclature_id
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(reply->rowlist,100)
  HEAD n.nomenclature_id
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->rowlist,(tot_cnt+ 100)), cnt = 1
   ENDIF
   stat = alterlist(reply->rowlist[tot_cnt].celllist,tot_col), reply->rowlist[tot_cnt].celllist[1].
   string_value = n.source_identifier, reply->rowlist[tot_cnt].celllist[2].string_value = n
   .source_string
  DETAIL
   IF ((tnom->syns[d.seq].active_ind=0))
    reply->rowlist[tot_cnt].celllist[3].string_value = "Yes"
   ENDIF
   IF ((tnom->syns[d.seq].obsolete_ind=1))
    reply->rowlist[tot_cnt].celllist[4].string_value = "Yes"
   ENDIF
   IF ((tnom->syns[d.seq].nonbill_ind=1))
    reply->rowlist[tot_cnt].celllist[5].string_value = "Yes"
   ENDIF
   IF ((tnom->syns[d.seq].pn > " "))
    reply->rowlist[tot_cnt].celllist[6].string_value = trim(tnom->syns[d.seq].pn)
   ENDIF
   IF ((tnom->syns[d.seq].dig_folder > " "))
    reply->rowlist[tot_cnt].celllist[7].string_value = trim(tnom->syns[d.seq].dig_folder)
   ENDIF
   IF ((tnom->syns[d.seq].fav_folder > " "))
    reply->rowlist[tot_cnt].celllist[8].string_value = trim(tnom->syns[d.seq].fav_folder)
   ENDIF
   IF ((tnom->syns[d.seq].fam_his > " "))
    reply->rowlist[tot_cnt].celllist[9].string_value = trim(tnom->syns[d.seq].fam_his)
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->rowlist,tot_cnt)
  WITH nocounter
 ;end select
#exit_script
 IF ((request->skip_volume_check_ind=0))
  IF (tot_cnt > 10000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   SET stat = alterlist(reply->collist,0)
   GO TO exit_script
  ELSEIF (tot_cnt > 5000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   SET stat = alterlist(reply->collist,0)
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->run_status_flag = 1
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("icd_vocabulary_invalid.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
