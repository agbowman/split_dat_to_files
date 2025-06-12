CREATE PROGRAM bhs_rpt_synonym_audit_cat_typ:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Catalog Type:" = 0,
  "                            Quick Visits:" = 0,
  "     Orders Folders:" = 0,
  "     Multum Obsolete:" = 0,
  "     Users' favorites:" = 0,
  "Select synonym:" = 0
  WITH outdev, f_cat_type_cd, l_quick_visits,
  l_order_folders, l_multum_obs, l_users_favs,
  f_synonym_id
 RECORD m_rec(
   1 f_catalog_type_cd = f8
   1 c_catalog_type = c40
   1 l_scnt = i4
   1 slist[*]
     2 f_synonym_id = f8
     2 c_mnemonic = c200
     2 c_mnemonic_type = c200
     2 c_mnemonic_key_cap = c200
     2 c_primary_mnemonic = c100
     2 f_drug_synonym_id = f8
     2 n_multum_obsolete_ind = i2
     2 l_oscnt = i4
     2 oslist[*]
       3 f_order_sentence_id = f8
       3 c_order_sentence_display_line = c255
     2 l_cmpcnt = i4
     2 cmplist[*]
       3 f_cp_pathway_id = f8
       3 f_cp_component_id = f8
       3 c_quick_visit_name = c100
       3 l_collation_seq = i4
       3 c_component_type = c100
       3 f_order_sentence_id = f8
       3 c_order_sentence = c255
     2 l_ofcnt = i4
     2 oflist[*]
       3 f_alt_sel_category_id = f8
       3 c_order_folder_description = c100
       3 c_order_folder_display = c100
       3 f_order_sentence_id = f8
       3 c_order_sentence = c255
       3 c_mpages_containing_folder = c1500
       3 c_folders_containing_folder = c1500
 ) WITH protect
 RECORD m_rpt(
   1 l_rcnt = i4
   1 list[*]
     2 c_field01 = c255
     2 c_field02 = c255
     2 c_field03 = c255
     2 c_field04 = c255
     2 c_field05 = c255
     2 c_field06 = c255
     2 c_field07 = c255
     2 c_field08 = c255
     2 c_field09 = c255
     2 c_field10 = c255
     2 c_field11 = c255
     2 c_field12 = c255
     2 c_field13 = c255
     2 c_field14 = c255
     2 c_field15 = c255
     2 n_multum_obsolete_ind = i2
 )
 DECLARE mf_qvisit_cp_type_cd = f8 WITH constant(uar_get_code_by("MEANING",4003197,"QUICKVISIT")),
 protect
 DECLARE mf_order_comp_type_cd = f8 WITH constant(uar_get_code_by("MEANING",4003130,"ORDERS")),
 protect
 DECLARE mf_rx_comp_type_cd = f8 WITH constant(uar_get_code_by("MEANING",4003130,"PRESCRIPTION")),
 protect
 DECLARE l_rcnt = i4 WITH protect, noconstant(0)
 DECLARE l_cpcnt = i4 WITH protect, noconstant(0)
 DECLARE l_cmpcnt = i4 WITH protect, noconstant(0)
 DECLARE l_ofcnt = i4 WITH protect, noconstant(0)
 DECLARE n_multum_obsolete_ind = i2 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH noconstant(0), protect
 DECLARE ml_pos = i4 WITH noconstant(0), protect
 DECLARE ml_sloop = i4 WITH noconstant(0), protect
 DECLARE ml_osloop = i4 WITH noconstant(0), protect
 DECLARE mf_catalog_type_cd = f8 WITH protect, noconstant(0.00)
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE s_users_favs_parse = vc WITH protect, noconstant(" ")
 DECLARE ms_cat_type_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_date_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_outstring = vc WITH protect, noconstant(" ")
 DECLARE ms_filename_in = vc WITH protect, noconstant(" ")
 DECLARE ms_filename_out = vc WITH protect, noconstant(" ")
 DECLARE ms_folder_temp = vc WITH protect, noconstant(" ")
 IF (findstring("@", $OUTDEV) > 0)
  SET mn_email_ind = 1
  SET ms_output_dest = concat("orders_quick_visits_",format(cnvtdatetime(sysdate),"YYYYMMDD;;D"),
   ".csv")
 ELSE
  SET mn_email_ind = 0
  SET ms_output_dest =  $OUTDEV
 ENDIF
 SET mf_catalog_type_cd =  $F_CAT_TYPE_CD
 SET ms_cat_type_disp = build(uar_get_code_display(mf_catalog_type_cd))
 IF (mf_catalog_type_cd=0.00)
  GO TO exit_script
 ELSE
  SET m_rec->f_catalog_type_cd = mf_catalog_type_cd
  SET m_rec->c_catalog_type = build(uar_get_code_display(mf_catalog_type_cd))
 ENDIF
 IF (( $L_MULTUM_OBS=1)
  AND mf_catalog_type_cd=2516.00)
  SET n_multum_obsolete_ind = 1
 ENDIF
 IF (((( $F_SYNONYM_ID=- (1))) OR (( $F_SYNONYM_ID=null))) )
  SELECT INTO "nl:"
   FROM order_catalog oc,
    order_catalog_synonym ocs
   PLAN (oc
    WHERE (oc.catalog_type_cd=m_rec->f_catalog_type_cd)
     AND oc.active_ind=1)
    JOIN (ocs
    WHERE ocs.catalog_cd=oc.catalog_cd
     AND ocs.active_ind=1)
   ORDER BY ocs.mnemonic_key_cap, oc.primary_mnemonic
   HEAD REPORT
    ml_scnt = 0
   DETAIL
    ml_scnt += 1, m_rec->l_scnt = ml_scnt, stat = alterlist(m_rec->slist,ml_scnt),
    m_rec->slist[ml_scnt].f_synonym_id = ocs.synonym_id, m_rec->slist[ml_scnt].c_mnemonic = build(ocs
     .mnemonic), m_rec->slist[ml_scnt].c_mnemonic_type = build(uar_get_code_display(ocs
      .mnemonic_type_cd)),
    m_rec->slist[ml_scnt].c_mnemonic_key_cap = build(ocs.mnemonic_key_cap), m_rec->slist[ml_scnt].
    c_primary_mnemonic = build(oc.primary_mnemonic),
    CALL echo(build2("cki: ",build(ocs.cki)))
    IF (ocs.cki="MUL.ORD-SYN!*")
     m_rec->slist[ml_scnt].f_drug_synonym_id = cnvtreal(replace(ocs.cki,"MUL.ORD-SYN!",""))
    ENDIF
    m_rec->slist[ml_scnt].n_multum_obsolete_ind = 0
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM order_catalog_synonym ocs,
    order_catalog oc
   PLAN (ocs
    WHERE (ocs.synonym_id= $F_SYNONYM_ID)
     AND ocs.active_ind=1)
    JOIN (oc
    WHERE oc.catalog_cd=ocs.catalog_cd
     AND (oc.catalog_type_cd=m_rec->f_catalog_type_cd)
     AND oc.active_ind=1)
   ORDER BY ocs.mnemonic_key_cap, oc.primary_mnemonic
   HEAD REPORT
    ml_scnt = 0
   DETAIL
    CALL echo(ocs.synonym_id), ml_scnt += 1, m_rec->l_scnt = ml_scnt,
    stat = alterlist(m_rec->slist,ml_scnt), m_rec->slist[ml_scnt].f_synonym_id = ocs.synonym_id,
    m_rec->slist[ml_scnt].c_mnemonic = build(ocs.mnemonic),
    m_rec->slist[ml_scnt].c_mnemonic_type = build(uar_get_code_display(ocs.mnemonic_type_cd)), m_rec
    ->slist[ml_scnt].c_mnemonic_key_cap = build(ocs.mnemonic_key_cap), m_rec->slist[ml_scnt].
    c_primary_mnemonic = build(oc.primary_mnemonic),
    CALL echo(build2("cki: ",build(ocs.cki)))
    IF (ocs.cki="MUL.ORD-SYN!*")
     m_rec->slist[ml_scnt].f_drug_synonym_id = cnvtreal(replace(ocs.cki,"MUL.ORD-SYN!",""))
    ENDIF
    m_rec->slist[ml_scnt].n_multum_obsolete_ind = 0
   WITH nocounter
  ;end select
 ENDIF
 IF ((m_rec->l_scnt=0))
  GO TO exit_script
 ENDIF
 IF (n_multum_obsolete_ind=1)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = m_rec->l_scnt),
    mltm_drug_name m,
    order_catalog_synonym ocs
   PLAN (d1)
    JOIN (m
    WHERE (m.drug_synonym_id=m_rec->slist[d1.seq].f_drug_synonym_id)
     AND m.is_obsolete="T")
    JOIN (ocs
    WHERE (ocs.synonym_id=m_rec->slist[d1.seq].f_synonym_id)
     AND ocs.active_ind=1
     AND  NOT (ocs.oe_format_id IN (343889913.00, 343890832.00, 634687.00))
     AND ocs.mnemonic_type_cd IN (614544.00, 614545.00, 614548.00, 614549.00))
   DETAIL
    m_rec->slist[d1.seq].n_multum_obsolete_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = m_rec->l_scnt),
   ord_cat_sent_r ocsr
  PLAN (d1)
   JOIN (ocsr
   WHERE (ocsr.synonym_id=m_rec->slist[d1.seq].f_synonym_id)
    AND ocsr.active_ind=1)
  ORDER BY d1.seq
  HEAD d1.seq
   ml_oscnt = 0
  DETAIL
   ml_oscnt += 1, m_rec->slist[d1.seq].l_oscnt = ml_oscnt, stat = alterlist(m_rec->slist[d1.seq].
    oslist,ml_oscnt),
   m_rec->slist[d1.seq].oslist[ml_oscnt].f_order_sentence_id = ocsr.order_sentence_id, m_rec->slist[
   d1.seq].oslist[ml_oscnt].c_order_sentence_display_line = trim(ocsr.order_sentence_disp_line,3)
  WITH nocounter
 ;end select
 IF (( $L_QUICK_VISITS=1))
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = m_rec->l_scnt),
    ord_cat_sent_r ocsr,
    order_sentence os,
    cp_component_detail ccd,
    cp_pathway cp,
    cp_component cpn,
    cp_node cn
   PLAN (d1)
    JOIN (ocsr
    WHERE (ocsr.synonym_id=m_rec->slist[d1.seq].f_synonym_id)
     AND ocsr.synonym_id > 0.00
     AND ocsr.active_ind=1)
    JOIN (os
    WHERE os.order_sentence_id=ocsr.order_sentence_id)
    JOIN (ccd
    WHERE ccd.component_entity_id=os.order_sentence_id)
    JOIN (cpn
    WHERE cpn.cp_component_id=ccd.cp_component_id
     AND cpn.comp_type_cd IN (mf_order_comp_type_cd, mf_rx_comp_type_cd))
    JOIN (cn
    WHERE cn.cp_node_id=cpn.cp_node_id)
    JOIN (cp
    WHERE cp.cp_pathway_id=cn.cp_pathway_id
     AND cp.pathway_type_cd=mf_qvisit_cp_type_cd
     AND cp.cp_pathway_id > 0
     AND cp.owner_prsnl_id=0.00
     AND cp.active_ind > 0)
   ORDER BY d1.seq, cp.cp_pathway_id, cpn.comp_type_cd,
    ccd.cp_component_detail_id, ccd.collation_seq
   HEAD d1.seq
    l_cmpcnt = 0
   HEAD cp.cp_pathway_id
    null
   HEAD cpn.comp_type_cd
    null
   HEAD ccd.cp_component_detail_id
    l_cmpcnt += 1, m_rec->slist[d1.seq].l_cmpcnt = l_cmpcnt, stat = alterlist(m_rec->slist[d1.seq].
     cmplist,l_cmpcnt),
    m_rec->slist[d1.seq].cmplist[l_cmpcnt].f_cp_pathway_id = cp.cp_pathway_id, m_rec->slist[d1.seq].
    cmplist[l_cmpcnt].c_quick_visit_name = cp.pathway_name, m_rec->slist[d1.seq].cmplist[l_cmpcnt].
    f_cp_component_id = cpn.cp_component_id,
    m_rec->slist[d1.seq].cmplist[l_cmpcnt].f_order_sentence_id = os.order_sentence_id, m_rec->slist[
    d1.seq].cmplist[l_cmpcnt].c_component_type = uar_get_code_display(cpn.comp_type_cd), m_rec->
    slist[d1.seq].cmplist[l_cmpcnt].c_order_sentence = os.order_sentence_display_line
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = m_rec->l_scnt),
    cp_component_detail ccd,
    cp_pathway cp,
    cp_component cpn,
    cp_node cn
   PLAN (d1)
    JOIN (ccd
    WHERE (ccd.cp_component_id=m_rec->slist[d1.seq].f_synonym_id)
     AND ccd.cp_component_id > 0.00)
    JOIN (cpn
    WHERE cpn.cp_component_id=ccd.cp_component_id
     AND cpn.comp_type_cd IN (mf_order_comp_type_cd, mf_rx_comp_type_cd))
    JOIN (cn
    WHERE cn.cp_node_id=cpn.cp_node_id)
    JOIN (cp
    WHERE cp.cp_pathway_id=cn.cp_pathway_id
     AND cp.pathway_type_cd=mf_qvisit_cp_type_cd
     AND cp.cp_pathway_id > 0
     AND cp.owner_prsnl_id=0.00
     AND cp.active_ind > 0)
   ORDER BY d1.seq, cp.cp_pathway_id, cpn.comp_type_cd,
    ccd.cp_component_detail_id, ccd.collation_seq
   HEAD d1.seq
    IF ((m_rec->slist[d1.seq].l_cmpcnt > 0))
     l_cmpcnt = m_rec->slist[d1.seq].l_cmpcnt
    ELSE
     l_cmpcnt = 0
    ENDIF
   HEAD cp.cp_pathway_id
    null
   HEAD cpn.comp_type_cd
    null
   HEAD ccd.cp_component_detail_id
    l_cmpcnt += 1, m_rec->slist[d1.seq].l_cmpcnt = l_cmpcnt, stat = alterlist(m_rec->slist[d1.seq].
     cmplist,l_cmpcnt),
    m_rec->slist[d1.seq].cmplist[l_cmpcnt].f_cp_pathway_id = cp.cp_pathway_id, m_rec->slist[d1.seq].
    cmplist[l_cmpcnt].c_quick_visit_name = cp.pathway_name, m_rec->slist[d1.seq].cmplist[l_cmpcnt].
    f_cp_component_id = cpn.cp_component_id,
    m_rec->slist[d1.seq].cmplist[l_cmpcnt].c_component_type = uar_get_code_display(cpn.comp_type_cd)
   WITH nocounter
  ;end select
 ENDIF
 IF ( $L_ORDER_FOLDERS)
  IF (( $L_USERS_FAVS=1))
   SET s_users_favs_parse = "asc1.owner_id >= 0.00"
  ELSE
   SET s_users_favs_parse = "asc1.owner_id = 0.00"
  ENDIF
  CALL echo(build2("s_users_favs_parse: ",s_users_favs_parse))
  SELECT INTO "nl:"
   folder_description = trim(asc1.long_description,3), folder_display = trim(asc1.short_description,3
    ), order_mnemonic = trim(ocs.mnemonic,3),
   primary_mnemonic = trim(uar_get_code_display(ocs.catalog_cd),3), order_sentence =
   IF (asl1.order_sentence_id > 0.00) trim(os.order_sentence_display_line,3)
   ENDIF
   FROM (dummyt d1  WITH seq = m_rec->l_scnt),
    order_catalog_synonym ocs,
    alt_sel_list asl1,
    order_sentence os,
    alt_sel_cat asc1
   PLAN (d1)
    JOIN (ocs
    WHERE (ocs.synonym_id=m_rec->slist[d1.seq].f_synonym_id)
     AND ocs.active_ind=1)
    JOIN (asl1
    WHERE asl1.synonym_id=ocs.synonym_id)
    JOIN (os
    WHERE os.order_sentence_id=asl1.order_sentence_id)
    JOIN (asc1
    WHERE asc1.alt_sel_category_id=asl1.alt_sel_category_id
     AND asc1.ahfs_ind IN (0, null)
     AND ((( $L_USERS_FAVS=0)
     AND asc1.owner_id=0.00) OR (( $L_USERS_FAVS=1)
     AND asc1.owner_id >= 0.00)) )
   ORDER BY d1.seq, asc1.long_description_key_cap
   HEAD d1.seq
    l_ofcnt = 0
   HEAD asc1.long_description_key_cap
    l_ofcnt += 1, m_rec->slist[d1.seq].l_ofcnt = l_ofcnt, stat = alterlist(m_rec->slist[d1.seq].
     oflist,l_ofcnt),
    m_rec->slist[d1.seq].oflist[l_ofcnt].f_alt_sel_category_id = asl1.alt_sel_category_id, m_rec->
    slist[d1.seq].oflist[l_ofcnt].c_order_folder_description = trim(asc1.long_description,3), m_rec->
    slist[d1.seq].oflist[l_ofcnt].c_order_folder_display = trim(asc1.short_description,3),
    m_rec->slist[d1.seq].oflist[l_ofcnt].f_order_sentence_id = os.order_sentence_id, m_rec->slist[d1
    .seq].oflist[l_ofcnt].c_order_sentence = trim(os.order_sentence_display_line,3)
   WITH format, separator = " ", nocounter
  ;end select
  SELECT INTO "nl:"
   asc2_ind = decode(asc2.alt_sel_category_id,1,0)
   FROM (dummyt d1  WITH seq = m_rec->l_scnt),
    (dummyt d2  WITH seq = 1),
    alt_sel_list asl1,
    alt_sel_cat asc1,
    dummyt d3,
    alt_sel_list asl2,
    alt_sel_cat asc2
   PLAN (d1
    WHERE maxrec(d2,m_rec->slist[d1.seq].l_ofcnt))
    JOIN (d2)
    JOIN (asl1
    WHERE (asl1.child_alt_sel_cat_id=m_rec->slist[d1.seq].oflist[d2.seq].f_alt_sel_category_id))
    JOIN (asc1
    WHERE asc1.alt_sel_category_id=asl1.alt_sel_category_id
     AND asc1.ahfs_ind IN (0, null))
    JOIN (d3)
    JOIN (asl2
    WHERE asl2.child_alt_sel_cat_id=asl1.alt_sel_category_id)
    JOIN (asc2
    WHERE asc2.alt_sel_category_id=asl2.alt_sel_category_id
     AND asc2.ahfs_ind IN (0, null))
   ORDER BY d1.seq, d2.seq, asc1.long_description_key_cap
   HEAD d1.seq
    null
   HEAD d2.seq
    m_rec->slist[d1.seq].oflist[d2.seq].c_folders_containing_folder = " "
   HEAD asc1.long_description_key_cap
    IF (asc2_ind=0)
     ms_folder_temp = trim(asc1.short_description,3)
    ELSE
     ms_folder_temp = concat(trim(asc2.short_description,3),"\",trim(asc1.short_description,3))
    ENDIF
    IF ((m_rec->slist[d1.seq].oflist[d2.seq].c_folders_containing_folder=" "))
     m_rec->slist[d1.seq].oflist[d2.seq].c_folders_containing_folder = trim(ms_folder_temp,3)
    ELSE
     m_rec->slist[d1.seq].oflist[d2.seq].c_folders_containing_folder = concat(m_rec->slist[d1.seq].
      oflist[d2.seq].c_folders_containing_folder,"; ",trim(ms_folder_temp,3))
    ENDIF
   WITH outerjoin = d3, nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = m_rec->l_scnt),
    (dummyt d2  WITH seq = 1),
    br_datamart_value brdv,
    br_datamart_category brdc
   PLAN (d1
    WHERE maxrec(d2,m_rec->slist[d1.seq].l_ofcnt))
    JOIN (d2)
    JOIN (brdv
    WHERE (brdv.parent_entity_id=m_rec->slist[d1.seq].oflist[d2.seq].f_alt_sel_category_id)
     AND brdv.parent_entity_name="ALT_SEL_CAT")
    JOIN (brdc
    WHERE brdc.br_datamart_category_id=brdv.br_datamart_category_id
     AND brdc.category_name="QOC*")
   ORDER BY d1.seq, d2.seq, brdc.category_name
   HEAD d1.seq
    null
   HEAD d2.seq
    m_rec->slist[d1.seq].oflist[d2.seq].c_mpages_containing_folder = " "
   HEAD brdc.category_name
    IF ((m_rec->slist[d1.seq].oflist[d2.seq].c_mpages_containing_folder=" "))
     m_rec->slist[d1.seq].oflist[d2.seq].c_mpages_containing_folder = trim(brdc.category_name,3)
    ELSE
     m_rec->slist[d1.seq].oflist[d2.seq].c_mpages_containing_folder = concat(m_rec->slist[d1.seq].
      oflist[d2.seq].c_mpages_containing_folder,"; ",trim(brdc.category_name,3))
    ENDIF
   WITH outerjoin = d3, nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = m_rec->l_scnt),
    (dummyt d2  WITH seq = 1),
    alt_sel_list asl1,
    br_datamart_value brdv,
    br_datamart_category brdc
   PLAN (d1
    WHERE maxrec(d2,m_rec->slist[d1.seq].l_ofcnt))
    JOIN (d2)
    JOIN (asl1
    WHERE (asl1.child_alt_sel_cat_id=m_rec->slist[d1.seq].oflist[d2.seq].f_alt_sel_category_id))
    JOIN (brdv
    WHERE brdv.parent_entity_id=asl1.alt_sel_category_id
     AND brdv.parent_entity_name="ALT_SEL_CAT")
    JOIN (brdc
    WHERE brdc.br_datamart_category_id=brdv.br_datamart_category_id
     AND brdc.category_name="QOC*")
   ORDER BY d1.seq, d2.seq, brdc.category_name
   HEAD d1.seq
    null
   HEAD d2.seq
    IF ( NOT ((m_rec->slist[d1.seq].oflist[d2.seq].c_mpages_containing_folder > " ")))
     m_rec->slist[d1.seq].oflist[d2.seq].c_mpages_containing_folder = " "
    ENDIF
   HEAD brdc.category_name
    IF ((m_rec->slist[d1.seq].oflist[d2.seq].c_mpages_containing_folder=" "))
     m_rec->slist[d1.seq].oflist[d2.seq].c_mpages_containing_folder = trim(brdc.category_name,3)
    ELSE
     m_rec->slist[d1.seq].oflist[d2.seq].c_mpages_containing_folder = concat(m_rec->slist[d1.seq].
      oflist[d2.seq].c_mpages_containing_folder,"; ",trim(brdc.category_name,3))
    ENDIF
   WITH outerjoin = d3, nocounter
  ;end select
 ENDIF
 SET l_rcnt = 0
 FOR (ml_sloop = 1 TO m_rec->l_scnt)
   SET l_rcnt += 1
   SET m_rpt->l_rcnt = l_rcnt
   SET stat = alterlist(m_rpt->list,l_rcnt)
   SET m_rpt->list[l_rcnt].c_field01 = trim(m_rec->c_catalog_type,3)
   SET m_rpt->list[l_rcnt].c_field02 = trim(m_rec->slist[ml_sloop].c_mnemonic,3)
   SET m_rpt->list[l_rcnt].c_field03 = trim(m_rec->slist[ml_sloop].c_mnemonic_type,3)
   SET m_rpt->list[l_rcnt].c_field04 = trim(m_rec->slist[ml_sloop].c_primary_mnemonic,3)
   IF ((m_rec->slist[ml_sloop].n_multum_obsolete_ind=1))
    SET m_rpt->list[l_rcnt].n_multum_obsolete_ind = 1
   ELSE
    SET m_rpt->list[l_rcnt].n_multum_obsolete_ind = 0
   ENDIF
   IF ((m_rec->slist[ml_sloop].l_oscnt > 0))
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = m_rec->slist[ml_sloop].l_oscnt)
     PLAN (d1)
     DETAIL
      IF (trim(m_rec->slist[ml_sloop].oslist[d1.seq].c_order_sentence_display_line,3) > " ")
       IF (d1.seq > 1)
        l_rcnt += 1, m_rpt->l_rcnt = l_rcnt, stat = alterlist(m_rpt->list,l_rcnt),
        m_rpt->list[l_rcnt].c_field01 = "", m_rpt->list[l_rcnt].c_field02 = "", m_rpt->list[l_rcnt].
        c_field03 = "",
        m_rpt->list[l_rcnt].c_field04 = "", m_rpt->list[l_rcnt].c_field05 = "Order Sentence", m_rpt->
        list[l_rcnt].c_field06 = "",
        m_rpt->list[l_rcnt].c_field07 = ""
       ENDIF
       m_rpt->list[l_rcnt].c_field08 = trim(m_rec->slist[ml_sloop].oslist[d1.seq].
        c_order_sentence_display_line,3)
       IF ((m_rec->slist[ml_sloop].n_multum_obsolete_ind=1))
        m_rpt->list[l_rcnt].n_multum_obsolete_ind = 1
       ELSE
        m_rpt->list[l_rcnt].n_multum_obsolete_ind = 0
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((m_rec->slist[ml_sloop].l_cmpcnt > 0))
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = m_rec->slist[ml_sloop].l_cmpcnt)
     PLAN (d1)
     HEAD REPORT
      l_rcnt = m_rpt->l_rcnt
     DETAIL
      l_rcnt += 1, m_rpt->l_rcnt = l_rcnt, stat = alterlist(m_rpt->list,l_rcnt),
      m_rpt->list[l_rcnt].c_field01 = "", m_rpt->list[l_rcnt].c_field02 = "", m_rpt->list[l_rcnt].
      c_field03 = "",
      m_rpt->list[l_rcnt].c_field04 = "", m_rpt->list[l_rcnt].c_field05 = "Quick Visit", m_rpt->list[
      l_rcnt].c_field06 = trim(m_rec->slist[ml_sloop].cmplist[d1.seq].c_quick_visit_name,3),
      m_rpt->list[l_rcnt].c_field07 = trim(m_rec->slist[ml_sloop].cmplist[d1.seq].c_component_type,3),
      m_rpt->list[l_rcnt].c_field08 = trim(m_rec->slist[ml_sloop].cmplist[d1.seq].c_order_sentence,3)
      IF ((m_rec->slist[ml_sloop].n_multum_obsolete_ind=1))
       m_rpt->list[l_rcnt].n_multum_obsolete_ind = 1
      ELSE
       m_rpt->list[l_rcnt].n_multum_obsolete_ind = 0
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((m_rec->slist[ml_sloop].l_ofcnt > 0))
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = m_rec->slist[ml_sloop].l_ofcnt)
     PLAN (d1)
     HEAD REPORT
      l_rcnt = m_rpt->l_rcnt
     DETAIL
      l_rcnt += 1, m_rpt->l_rcnt = l_rcnt, stat = alterlist(m_rpt->list,l_rcnt),
      m_rpt->list[l_rcnt].c_field01 = "", m_rpt->list[l_rcnt].c_field02 = "", m_rpt->list[l_rcnt].
      c_field03 = "",
      m_rpt->list[l_rcnt].c_field04 = "", m_rpt->list[l_rcnt].c_field05 = "Order Folder", m_rpt->
      list[l_rcnt].c_field06 = trim(m_rec->slist[ml_sloop].oflist[d1.seq].c_order_folder_description,
       3),
      m_rpt->list[l_rcnt].c_field07 = trim(m_rec->slist[ml_sloop].oflist[d1.seq].
       c_order_folder_display,3), m_rpt->list[l_rcnt].c_field08 = trim(m_rec->slist[ml_sloop].oflist[
       d1.seq].c_order_sentence,3), m_rpt->list[l_rcnt].c_field09 = trim(m_rec->slist[ml_sloop].
       oflist[d1.seq].c_folders_containing_folder,3),
      m_rpt->list[l_rcnt].c_field10 = trim(m_rec->slist[ml_sloop].oflist[d1.seq].
       c_mpages_containing_folder,3)
      IF ((m_rec->slist[ml_sloop].n_multum_obsolete_ind=1))
       m_rpt->list[l_rcnt].n_multum_obsolete_ind = 1
      ELSE
       m_rpt->list[l_rcnt].n_multum_obsolete_ind = 0
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SELECT
  IF (mn_email_ind=1)
   WITH format, format = stream, pcformat('"',",",1),
    nocounter
  ELSE
  ENDIF
  INTO value(ms_output_dest)
  catalog_type = trim(m_rpt->list[d1.seq].c_field01,3), mnemonic = trim(m_rpt->list[d1.seq].c_field02,
   3), mnemonic_type = trim(m_rpt->list[d1.seq].c_field03,3),
  primary_mnemonic = trim(m_rpt->list[d1.seq].c_field04,3), folder_or_quick_visit = trim(m_rpt->list[
   d1.seq].c_field05,3), folder_description_or_quick_visit_name = trim(m_rpt->list[d1.seq].c_field06,
   3),
  folder_display_or_qv_component_type = trim(m_rpt->list[d1.seq].c_field07,3), order_sentence = trim(
   m_rpt->list[d1.seq].c_field08,3), folders_containing_folder = trim(m_rpt->list[d1.seq].c_field09,3
   ),
  mpages_containing_folder = trim(m_rpt->list[d1.seq].c_field10,3)
  FROM (dummyt d1  WITH seq = m_rpt->l_rcnt)
  PLAN (d1
   WHERE ((n_multum_obsolete_ind=1
    AND (m_rec->f_catalog_type_cd=2516.00)
    AND (m_rpt->list[d1.seq].n_multum_obsolete_ind=1)) OR (n_multum_obsolete_ind=0
    AND (m_rpt->list[d1.seq].n_multum_obsolete_ind IN (1, 0)))) )
  ORDER BY d1.seq
  WITH format, separator = " ", nocounter
 ;end select
 IF (mn_email_ind=1)
  SET ms_filename_in = trim(ms_output_dest)
  SET ms_filename_out = concat("Orders_in_Quick_Visits_Audit_",replace(ms_cat_type_disp," ","_"),"_",
   format(curdate,"YYYYMMDD;;D"),".csv")
  EXECUTE bhs_ma_email_file
  CALL emailfile(ms_filename_in,ms_filename_out, $OUTDEV,concat(
    "Orders in Quick Visits by Catalog Type - ",format(curdate,"MMDDYYYY;;D")),1)
 ENDIF
#exit_script
 CALL echorecord(m_rec)
END GO
