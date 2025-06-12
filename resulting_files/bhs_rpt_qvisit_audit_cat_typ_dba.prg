CREATE PROGRAM bhs_rpt_qvisit_audit_cat_typ:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Catalog Type:" = 0
  WITH outdev, f_cat_type_cd
 RECORD m_rec(
   1 l_cpcnt = i4
   1 cplist[*]
     2 f_cp_pathway_id = f8
     2 c_quick_visit_name = c100
     2 l_cmpcnt = i4
     2 cmplist[*]
       3 f_synonym_id = f8
       3 f_order_sentence_id = f8
       3 f_cp_component_id = f8
       3 l_collation_seq = i4
       3 c_component_type = c100
       3 c_catalog_type = c100
       3 c_orderable = c100
       3 c_order_sentence = c255
 ) WITH protect
 DECLARE mf_qvisit_cp_type_cd = f8 WITH constant(uar_get_code_by("MEANING",4003197,"QUICKVISIT")),
 protect
 DECLARE mf_order_comp_type_cd = f8 WITH constant(uar_get_code_by("MEANING",4003130,"ORDERS")),
 protect
 DECLARE mf_rx_comp_type_cd = f8 WITH constant(uar_get_code_by("MEANING",4003130,"PRESCRIPTION")),
 protect
 DECLARE l_cpcnt = i4 WITH protect, noconstant(0)
 DECLARE l_cmpcnt = i4 WITH protect, noconstant(0)
 DECLARE ml_num = i4 WITH noconstant(0), protect
 DECLARE ml_pos = i4 WITH noconstant(0), protect
 DECLARE mf_catalog_type_cd = f8 WITH protect, noconstant(0.00)
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_cat_type_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_date_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_outstring = vc WITH protect, noconstant(" ")
 DECLARE ms_filename_in = vc WITH protect, noconstant(" ")
 DECLARE md_filename_out = vc WITH protect, noconstant(" ")
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
 ENDIF
 SELECT INTO "nl:"
  FROM cp_pathway cp,
   cp_component cpn,
   cp_node cn,
   cp_component_detail ccd,
   order_sentence os,
   ord_cat_sent_r ocsr,
   order_catalog_synonym ocs
  PLAN (cp
   WHERE cp.pathway_type_cd=mf_qvisit_cp_type_cd
    AND cp.cp_pathway_id > 0
    AND cp.owner_prsnl_id=0.00
    AND cp.active_ind > 0)
   JOIN (cn
   WHERE cn.cp_pathway_id=cp.cp_pathway_id)
   JOIN (cpn
   WHERE cpn.cp_node_id=cn.cp_node_id
    AND cpn.comp_type_cd IN (mf_order_comp_type_cd, mf_rx_comp_type_cd))
   JOIN (ccd
   WHERE ccd.cp_component_id=cpn.cp_component_id)
   JOIN (os
   WHERE os.order_sentence_id=ccd.component_entity_id)
   JOIN (ocsr
   WHERE ocsr.order_sentence_id=os.order_sentence_id
    AND ocsr.active_ind=1)
   JOIN (ocs
   WHERE ocs.synonym_id=ocsr.synonym_id
    AND ocs.catalog_type_cd=mf_catalog_type_cd
    AND ocs.active_ind=1)
  ORDER BY cp.cp_pathway_id, cpn.comp_type_cd, ocs.catalog_type_cd,
   ccd.cp_component_detail_id, ccd.collation_seq
  HEAD REPORT
   l_cpcnt = 0
  HEAD cp.cp_pathway_id
   l_cpcnt += 1, m_rec->l_cpcnt = l_cpcnt, stat = alterlist(m_rec->cplist,l_cpcnt),
   m_rec->cplist[l_cpcnt].f_cp_pathway_id = cp.cp_pathway_id, m_rec->cplist[l_cpcnt].
   c_quick_visit_name = cp.pathway_name, l_cmpcnt = 0
  HEAD cpn.comp_type_cd
   null
  HEAD ocs.catalog_type_cd
   null
  HEAD ccd.cp_component_detail_id
   l_cmpcnt += 1, m_rec->cplist[l_cpcnt].l_cmpcnt = l_cmpcnt, stat = alterlist(m_rec->cplist[l_cpcnt]
    .cmplist,l_cmpcnt),
   m_rec->cplist[l_cpcnt].cmplist[l_cmpcnt].f_cp_component_id = cpn.cp_component_id, m_rec->cplist[
   l_cpcnt].cmplist[l_cmpcnt].f_synonym_id = ocs.synonym_id, m_rec->cplist[l_cpcnt].cmplist[l_cmpcnt]
   .f_order_sentence_id = os.order_sentence_id,
   m_rec->cplist[l_cpcnt].cmplist[l_cmpcnt].c_catalog_type = uar_get_code_display(ocs.catalog_type_cd
    ), m_rec->cplist[l_cpcnt].cmplist[l_cmpcnt].c_component_type = uar_get_code_display(cpn
    .comp_type_cd), m_rec->cplist[l_cpcnt].cmplist[l_cmpcnt].c_orderable = ocs.mnemonic,
   m_rec->cplist[l_cpcnt].cmplist[l_cmpcnt].c_order_sentence = os.order_sentence_display_line
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM cp_pathway cp,
   cp_component cpn,
   cp_node cn,
   cp_component_detail ccd,
   order_catalog_synonym ocs
  PLAN (cp
   WHERE cp.pathway_type_cd=mf_qvisit_cp_type_cd
    AND cp.cp_pathway_id > 0
    AND cp.owner_prsnl_id=0.00
    AND cp.active_ind > 0)
   JOIN (cn
   WHERE cn.cp_pathway_id=cp.cp_pathway_id)
   JOIN (cpn
   WHERE cpn.cp_node_id=cn.cp_node_id
    AND cpn.comp_type_cd IN (mf_order_comp_type_cd, mf_rx_comp_type_cd))
   JOIN (ccd
   WHERE ccd.cp_component_id=cpn.cp_component_id)
   JOIN (ocs
   WHERE ocs.synonym_id=ccd.component_entity_id
    AND ocs.catalog_type_cd=mf_catalog_type_cd
    AND ocs.active_ind=1)
  ORDER BY cp.cp_pathway_id, cpn.comp_type_cd, ocs.catalog_type_cd,
   ccd.cp_component_detail_id, ccd.collation_seq
  HEAD REPORT
   l_cpcnt = 0
  HEAD cp.cp_pathway_id
   ml_pos = locateval(ml_num,1,size(m_rec->cplist,5),cp.cp_pathway_id,m_rec->cplist[ml_num].
    f_cp_pathway_id)
   IF (ml_pos > 0)
    l_cpcnt = ml_pos, l_cmpcnt = m_rec->cplist[l_cpcnt].l_cmpcnt
   ELSE
    l_cpcnt += 1, m_rec->l_cpcnt = l_cpcnt, stat = alterlist(m_rec->cplist,l_cpcnt),
    m_rec->cplist[l_cpcnt].f_cp_pathway_id = cp.cp_pathway_id, m_rec->cplist[l_cpcnt].
    c_quick_visit_name = cp.pathway_name, l_cmpcnt = 0
   ENDIF
  HEAD cpn.comp_type_cd
   null
  HEAD ocs.catalog_type_cd
   null
  HEAD ccd.cp_component_detail_id
   l_cmpcnt += 1, m_rec->cplist[l_cpcnt].l_cmpcnt = l_cmpcnt, stat = alterlist(m_rec->cplist[l_cpcnt]
    .cmplist,l_cmpcnt),
   m_rec->cplist[l_cpcnt].cmplist[l_cmpcnt].f_cp_component_id = cpn.cp_component_id, m_rec->cplist[
   l_cpcnt].cmplist[l_cmpcnt].f_synonym_id = ocs.synonym_id, m_rec->cplist[l_cpcnt].cmplist[l_cmpcnt]
   .c_catalog_type = uar_get_code_display(ocs.catalog_type_cd),
   m_rec->cplist[l_cpcnt].cmplist[l_cmpcnt].c_component_type = uar_get_code_display(cpn.comp_type_cd),
   m_rec->cplist[l_cpcnt].cmplist[l_cmpcnt].c_orderable = ocs.mnemonic
  WITH nocounter
 ;end select
 SELECT
  IF (mn_email_ind=1)
   WITH format, format = stream, pcformat('"',",",1),
    nocounter
  ELSE
  ENDIF
  INTO value(ms_output_dest)
  quick_visit_name = trim(m_rec->cplist[d1.seq].c_quick_visit_name,3), component_type = trim(m_rec->
   cplist[d1.seq].cmplist[d2.seq].c_component_type,3), catalog_type = trim(m_rec->cplist[d1.seq].
   cmplist[d2.seq].c_catalog_type,3),
  orderable = trim(m_rec->cplist[d1.seq].cmplist[d2.seq].c_orderable,3), order_sentence = trim(m_rec
   ->cplist[d1.seq].cmplist[d2.seq].c_order_sentence,3)
  FROM (dummyt d1  WITH seq = m_rec->l_cpcnt),
   (dummyt d2  WITH seq = 1)
  PLAN (d1
   WHERE maxrec(d2,m_rec->cplist[d1.seq].l_cmpcnt))
   JOIN (d2)
  ORDER BY quick_visit_name, component_type, catalog_type
  WITH format, separator = " ", nocounter
 ;end select
 IF (mn_email_ind=1)
  SET ms_filename_in = trim(ms_output_dest)
  SET ms_filename_out = concat("Orders_in_Quick_Visits_Audit_",replace(ms_cat_type_disp," ","_"),"_",
   format(curdate,"YYYYMMDD;;D"),".csv")
  CALL echo(ms_filename_out)
  EXECUTE bhs_ma_email_file
  CALL emailfile(ms_filename_in,ms_filename_out, $OUTDEV,concat(
    "Orders in Quick Visits by Catalog Type - ",format(curdate,"MMDDYYYY;;D")),1)
 ENDIF
#exit_script
END GO
