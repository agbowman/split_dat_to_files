CREATE PROGRAM bhs_ma_rpt_cat_ref_txt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Reference Text Location:" = 0
  WITH outdev, l_ref_txt_loc
 DECLARE ml_loc1 = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp_str = vc WITH protect, noconstant("")
 DECLARE ms_uncomp_blob = vc WITH protect, noconstant("")
 DECLARE mf_cs6011_primary_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3128"))
 IF (( $L_REF_TXT_LOC=1))
  FREE RECORD m_rec
  RECORD m_rec(
    1 l_cnt = i4
    1 qual[*]
      2 catalog_cd = f8
      2 cat_type = vc
      2 l_hide_flag = i4
      2 mnemonic = vc
      2 synonym = vc
      2 ref_text = vc
  )
  SELECT INTO "nl:"
   FROM order_catalog oc,
    order_catalog_synonym ocs,
    ref_text_reltn rtr,
    ref_text rt,
    long_blob lb,
    ocs_facility_r ofr
   PLAN (oc
    WHERE oc.active_ind=1)
    JOIN (ocs
    WHERE ocs.catalog_cd=oc.catalog_cd
     AND ocs.active_ind=1)
    JOIN (rtr
    WHERE rtr.parent_entity_id=oc.catalog_cd
     AND rtr.parent_entity_name="ORDERCATALOG"
     AND rtr.active_ind=1)
    JOIN (rt
    WHERE rt.refr_text_id=rtr.refr_text_id
     AND rt.text_entity_name="LONG_BLOB")
    JOIN (lb
    WHERE lb.long_blob_id=rt.text_entity_id)
    JOIN (ofr
    WHERE ofr.synonym_id=ocs.synonym_id)
   DETAIL
    ms_uncomp_blob = lb.long_blob, ml_loc1 = findstring("http://eworkplace",ms_uncomp_blob)
    IF (ml_loc1 > 0)
     ms_tmp_str = substring(ml_loc1,5000,ms_uncomp_blob), ml_loc1 = findstring("}",ms_tmp_str),
     ms_tmp_str = substring(1,(ml_loc1 - 3),ms_tmp_str),
     m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
     catalog_cd = oc.catalog_cd,
     m_rec->qual[m_rec->l_cnt].mnemonic = trim(oc.primary_mnemonic,3), m_rec->qual[m_rec->l_cnt].
     ref_text = ms_tmp_str, m_rec->qual[m_rec->l_cnt].l_hide_flag = ocs.hide_flag,
     m_rec->qual[m_rec->l_cnt].cat_type = trim(uar_get_code_display(oc.catalog_type_cd),3), m_rec->
     qual[m_rec->l_cnt].synonym = trim(ocs.mnemonic,3)
    ENDIF
   WITH nocounter
  ;end select
  SELECT DISTINCT INTO  $OUTDEV
   catalog_cd = m_rec->qual[d.seq].catalog_cd, catalog_type = trim(substring(1,100,m_rec->qual[d.seq]
     .cat_type),3), primary_mnemonic = trim(substring(1,120,m_rec->qual[d.seq].mnemonic),3),
   synonym = trim(substring(1,120,m_rec->qual[d.seq].synonym),3), hide_flag = m_rec->qual[d.seq].
   l_hide_flag, ref_text_link = trim(substring(1,1000,m_rec->qual[d.seq].ref_text),3)
   FROM (dummyt d  WITH seq = m_rec->l_cnt)
   PLAN (d)
   ORDER BY catalog_cd, catalog_type, primary_mnemonic,
    synonym, hide_flag
   WITH nocounter, heading, maxrow = 1,
    formfeed = none, format, separator = " "
  ;end select
 ENDIF
 IF (( $L_REF_TXT_LOC=2))
  FREE RECORD m_rec
  RECORD m_rec(
    1 l_cnt = i4
    1 qual[*]
      2 dta_cd = f8
      2 mnemonic = vc
      2 description = vc
      2 event_cd_disp = vc
      2 ref_text = vc
  )
  SELECT INTO "nl:"
   FROM discrete_task_assay d,
    ref_text_reltn rtr,
    ref_text rt,
    long_blob lb
   PLAN (d
    WHERE d.active_ind=1)
    JOIN (rtr
    WHERE rtr.parent_entity_id=d.task_assay_cd
     AND rtr.parent_entity_name="DISCRETE_TASK_ASSAY"
     AND rtr.active_ind=1)
    JOIN (rt
    WHERE rt.refr_text_id=rtr.refr_text_id
     AND rt.text_entity_name="LONG_BLOB")
    JOIN (lb
    WHERE lb.long_blob_id=rt.text_entity_id)
   DETAIL
    ms_uncomp_blob = lb.long_blob, ml_loc1 = findstring("http://eworkplace",ms_uncomp_blob)
    IF (ml_loc1 > 0)
     ms_tmp_str = substring(ml_loc1,5000,ms_uncomp_blob), ml_loc1 = findstring("}",ms_tmp_str),
     ms_tmp_str = substring(1,(ml_loc1 - 3),ms_tmp_str),
     m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].dta_cd
      = d.task_assay_cd,
     m_rec->qual[m_rec->l_cnt].mnemonic = trim(d.mnemonic,3), m_rec->qual[m_rec->l_cnt].description
      = trim(d.description,3), m_rec->qual[m_rec->l_cnt].event_cd_disp = trim(uar_get_code_display(d
       .event_cd),3),
     m_rec->qual[m_rec->l_cnt].ref_text = ms_tmp_str
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO  $OUTDEV
   dta_cd = m_rec->qual[d.seq].dta_cd, mnemonic = trim(substring(1,120,m_rec->qual[d.seq].mnemonic),3
    ), description = trim(substring(1,120,m_rec->qual[d.seq].description),3),
   event_cd_display = trim(substring(1,120,m_rec->qual[d.seq].event_cd_disp),3), ref_text_link = trim
   (substring(1,1000,m_rec->qual[d.seq].ref_text),3)
   FROM (dummyt d  WITH seq = m_rec->l_cnt)
   PLAN (d)
   WITH nocounter, heading, maxrow = 1,
    formfeed = none, format, separator = " "
  ;end select
 ENDIF
 IF (( $L_REF_TXT_LOC=3))
  FREE RECORD m_rec
  RECORD m_rec(
    1 l_cnt = i4
    1 qual[*]
      2 description = vc
      2 display_method = vc
      2 ref_text = vc
      2 evidence_link = vc
  )
  SELECT INTO "nl:"
   FROM pathway_catalog pc,
    ref_text_reltn rtr,
    ref_text rt,
    long_blob lb
   PLAN (pc
    WHERE pc.active_ind=1)
    JOIN (rtr
    WHERE rtr.parent_entity_id=pc.pathway_catalog_id
     AND rtr.parent_entity_name="PATHWAY_CATALOG"
     AND rtr.active_ind=1)
    JOIN (rt
    WHERE rt.refr_text_id=rtr.refr_text_id
     AND rt.text_entity_name="LONG_BLOB")
    JOIN (lb
    WHERE lb.long_blob_id=rt.text_entity_id)
   DETAIL
    CALL echo(lb.long_blob_id), ms_uncomp_blob = lb.long_blob, ml_loc1 = findstring(
     "http://eworkplace",ms_uncomp_blob)
    IF (ml_loc1 > 0)
     ms_tmp_str = substring(ml_loc1,5000,ms_uncomp_blob), ml_loc1 = findstring("}",ms_tmp_str),
     ms_tmp_str = substring(1,(ml_loc1 - 3),ms_tmp_str),
     CALL echo(ms_tmp_str), m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt),
     m_rec->qual[m_rec->l_cnt].description = pc.description, m_rec->qual[m_rec->l_cnt].display_method
      = trim(uar_get_code_display(pc.display_method_cd),3), m_rec->qual[m_rec->l_cnt].ref_text =
     ms_tmp_str
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM pathway_catalog pc,
    pw_evidence_reltn per
   PLAN (pc
    WHERE pc.active_ind=1)
    JOIN (per
    WHERE per.pathway_catalog_id=pc.pathway_catalog_id
     AND per.type_mean="URL"
     AND cnvtupper(per.evidence_locator)="*EWORKPLACE*")
   DETAIL
    m_rec->l_cnt += 1, stat = alterlist(m_rec->qual,m_rec->l_cnt), m_rec->qual[m_rec->l_cnt].
    description = pc.description,
    m_rec->qual[m_rec->l_cnt].display_method = trim(uar_get_code_display(pc.display_method_cd),3),
    m_rec->qual[m_rec->l_cnt].evidence_link = trim(per.evidence_locator,3)
   WITH nocounter
  ;end select
  SELECT INTO  $OUTDEV
   description = trim(substring(1,120,m_rec->qual[d.seq].description),3), display_method = trim(
    substring(1,120,m_rec->qual[d.seq].display_method),3), evidence_link = trim(substring(1,1000,
     m_rec->qual[d.seq].evidence_link),3),
   ref_text_link = trim(substring(1,1000,m_rec->qual[d.seq].ref_text),3)
   FROM (dummyt d  WITH seq = m_rec->l_cnt)
   PLAN (d)
   WITH nocounter, heading, maxrow = 1,
    formfeed = none, format, separator = " "
  ;end select
 ENDIF
END GO
