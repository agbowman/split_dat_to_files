CREATE PROGRAM bhs_rpt_order_privs_by_syn:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Catalog Type:" = 2516.00,
  "Select synonym:" = 0
  WITH outdev, f_cat_type_cd, f_synonym_id
 RECORD m_rec(
   1 f_catalog_type_cd = f8
   1 f_activity_type_cd = f8
   1 c_catalog_type = c40
   1 l_scnt = i4
   1 slist[*]
     2 f_catalog_cd = f8
     2 f_activity_type_cd = f8
     2 f_synonym_id = f8
     2 c_mnemonic = c200
     2 c_mnemonic_type = c200
     2 c_mnemonic_key_cap = c200
     2 c_primary_mnemonic = c100
   1 l_pcnt = i4
   1 plist[*]
     2 c_position = c100
     2 c_priv = c3
     2 c_reason = c255
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
 )
 DECLARE mf_orderpriv_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6016,"ORDER"))
 DECLARE l_rcnt = i4 WITH protect, noconstant(0)
 DECLARE l_scnt = i4 WITH protect, noconstant(0)
 DECLARE l_pcnt = i4 WITH protect, noconstant(0)
 DECLARE ml_aidx = i4 WITH noconstant(0), protect
 DECLARE ml_sidx = i4 WITH noconstant(0), protect
 DECLARE ml_anum = i4 WITH noconstant(0), protect
 DECLARE ml_snum = i4 WITH noconstant(0), protect
 DECLARE ml_spos = i4 WITH noconstant(0), protect
 DECLARE ml_loop = i4 WITH noconstant(0), protect
 DECLARE mf_catalog_type_cd = f8 WITH protect, noconstant(0.00)
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
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
   ORDER BY ocs.catalog_cd, ocs.mnemonic_key_cap, oc.primary_mnemonic
   HEAD REPORT
    ml_scnt = 0
   HEAD ocs.catalog_cd
    ml_scnt += 1, m_rec->l_scnt = ml_scnt, stat = alterlist(m_rec->slist,ml_scnt),
    m_rec->slist[ml_scnt].f_catalog_cd = ocs.catalog_cd, m_rec->slist[ml_scnt].f_activity_type_cd =
    ocs.activity_type_cd, m_rec->slist[ml_scnt].f_synonym_id = ocs.synonym_id,
    m_rec->slist[ml_scnt].c_mnemonic = build(ocs.mnemonic), m_rec->slist[ml_scnt].c_mnemonic_type =
    build(uar_get_code_display(ocs.mnemonic_type_cd)), m_rec->slist[ml_scnt].c_mnemonic_key_cap =
    build(ocs.mnemonic_key_cap),
    m_rec->slist[ml_scnt].c_primary_mnemonic = build(oc.primary_mnemonic)
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
   ORDER BY ocs.catalog_cd, ocs.mnemonic_key_cap, oc.primary_mnemonic
   HEAD REPORT
    ml_scnt = 0
   HEAD ocs.catalog_cd
    ml_scnt += 1, m_rec->l_scnt = ml_scnt, stat = alterlist(m_rec->slist,ml_scnt),
    m_rec->slist[ml_scnt].f_catalog_cd = ocs.catalog_cd, m_rec->slist[ml_scnt].f_activity_type_cd =
    ocs.activity_type_cd, m_rec->slist[ml_scnt].f_synonym_id = ocs.synonym_id,
    m_rec->slist[ml_scnt].c_mnemonic = build(ocs.mnemonic), m_rec->slist[ml_scnt].c_mnemonic_type =
    build(uar_get_code_display(ocs.mnemonic_type_cd)), m_rec->slist[ml_scnt].c_mnemonic_key_cap =
    build(ocs.mnemonic_key_cap),
    m_rec->slist[ml_scnt].c_primary_mnemonic = build(oc.primary_mnemonic)
   WITH nocounter
  ;end select
 ENDIF
 IF ((m_rec->l_scnt=0))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  priv_val = uar_get_code_display(p.priv_value_cd), exception_type_sort = cnvtupper(
   uar_get_code_display(pe.exception_type_cd)), position_sort = cnvtupper(uar_get_code_display(plr
    .position_cd))
  FROM privilege p,
   priv_loc_reltn plr,
   dummyt d2,
   privilege_exception pe
  PLAN (p
   WHERE p.privilege_cd=mf_orderpriv_cd
    AND p.active_ind=1)
   JOIN (plr
   WHERE plr.priv_loc_reltn_id=p.priv_loc_reltn_id
    AND plr.position_cd > 0.00
    AND plr.active_ind=1
    AND plr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND plr.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (d2)
   JOIN (pe
   WHERE pe.privilege_id=p.privilege_id
    AND pe.active_ind=1
    AND ((expand(ml_sidx,1,m_rec->l_scnt,pe.exception_id,m_rec->slist[ml_sidx].f_catalog_cd)) OR (
   expand(ml_aidx,1,m_rec->l_scnt,pe.exception_id,m_rec->slist[ml_aidx].f_activity_type_cd))) )
  ORDER BY position_sort, priv_val
  HEAD REPORT
   ml_pcnt = 0
  HEAD position_sort
   null
  HEAD priv_val
   ml_pcnt += 1, m_rec->l_pcnt = ml_pcnt, stat = alterlist(m_rec->plist,ml_pcnt),
   m_rec->plist[ml_pcnt].c_position = trim(uar_get_code_display(plr.position_cd),3)
   CASE (priv_val)
    OF "No":
     m_rec->plist[ml_pcnt].c_priv = "No",m_rec->plist[ml_pcnt].c_reason = "Order privilege = No"
    OF "No, except for":
     ml_spos = 0,
     IF (pe.exception_entity_name="ACTIVITY TYPE")
      ml_spos = locateval(ml_snum,1,m_rec->l_scnt,pe.exception_id,m_rec->slist[ml_snum].
       f_activity_type_cd)
      IF (ml_spos > 0)
       m_rec->plist[ml_pcnt].c_priv = "Yes", m_rec->plist[ml_pcnt].c_reason = concat(
        "Order privilege = No, except for ACTIVITY TYPE of ",trim(uar_get_code_display(pe
          .exception_id),3))
      ELSE
       m_rec->plist[ml_pcnt].c_priv = "No", m_rec->plist[ml_pcnt].c_reason =
       "Order privilege = No, except for (with no qualifying exception)"
      ENDIF
     ELSEIF (pe.exception_entity_name="ORDER CATALOG")
      ml_spos = locateval(ml_snum,1,m_rec->l_scnt,pe.exception_id,m_rec->slist[ml_snum].f_catalog_cd)
      IF (ml_spos > 0)
       m_rec->plist[ml_pcnt].c_priv = "Yes", m_rec->plist[ml_pcnt].c_reason = concat(
        "Order privilege = No, except for ORDER CATALOG of ",trim(uar_get_code_display(pe
          .exception_id),3))
      ENDIF
     ELSE
      m_rec->plist[ml_pcnt].c_priv = "No", m_rec->plist[ml_pcnt].c_reason =
      "Order privilege = No, except for (with no qualifying exception)"
     ENDIF
    OF "Yes":
     m_rec->plist[ml_pcnt].c_priv = "Yes",m_rec->plist[ml_pcnt].c_reason = "Order privilege = Yes"
    OF "Yes, except for":
     ml_spos = 0,
     IF (pe.exception_entity_name="ACTIVITY TYPE")
      ml_spos = locateval(ml_snum,1,m_rec->l_scnt,pe.exception_id,m_rec->slist[ml_snum].
       f_activity_type_cd)
      IF (ml_spos > 0)
       m_rec->plist[ml_pcnt].c_priv = "No", m_rec->plist[ml_pcnt].c_reason = concat(
        "Order privilege = Yes, except for ACTIVITY TYPE of ",trim(uar_get_code_display(pe
          .exception_id),3))
      ELSE
       m_rec->plist[ml_pcnt].c_priv = "Yes", m_rec->plist[ml_pcnt].c_reason =
       "Order privilege = Yes, except for (with no qualifying exception)"
      ENDIF
     ELSEIF (pe.exception_entity_name="ORDER CATALOG")
      ml_spos = locateval(ml_snum,1,m_rec->l_scnt,pe.exception_id,m_rec->slist[ml_snum].f_catalog_cd)
      IF (ml_spos > 0)
       m_rec->plist[ml_pcnt].c_priv = "No", m_rec->plist[ml_pcnt].c_reason = concat(
        "Order privilege = Yes, except for ORDER CATALOG of ",trim(uar_get_code_display(pe
          .exception_id),3))
      ENDIF
     ELSE
      m_rec->plist[ml_pcnt].c_priv = "Yes", m_rec->plist[ml_pcnt].c_reason =
      "Order privilege = Yes, except for (with no qualifying exception)"
     ENDIF
   ENDCASE
  WITH outerjoin = d2, dontcare = pe, outerjoin = d3,
   nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO  $OUTDEV
   message = "No data found"
   FROM dummyt d1
   PLAN (d1)
   WITH format, separator = " ", nocounter
  ;end select
  GO TO exit_script
 ENDIF
 SELECT INTO  $OUTDEV
  position = trim(m_rec->plist[d1.seq].c_position,3), privilege = trim(m_rec->plist[d1.seq].c_priv,3),
  reason = trim(m_rec->plist[d1.seq].c_reason,3)
  FROM (dummyt d1  WITH seq = m_rec->l_pcnt)
  PLAN (d1)
  WITH format, separator = " ", nocounter
 ;end select
#exit_script
END GO
