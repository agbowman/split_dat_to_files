CREATE PROGRAM bhs_athn_get_order_folders
 RECORD out_rec(
   1 root = vc
   1 root_id = vc
   1 child_qual[*]
     2 name = vc
     2 folder_id = vc
     2 type = vc
     2 sequence = i2
     2 clinical_category = vc
     2 sentence_id = vc
     2 sentence_display_line = vc
     2 activity_type_cd = vc
     2 activity_type_disp = vc
     2 catalog_cd = vc
     2 catalog_disp = vc
     2 catalog_type_cd = vc
     2 catalog_type_disp = vc
     2 format_id = vc
     2 sliding_scale = i2
 )
 DECLARE t_cnt = i4
 DECLARE facility_cd = f8
 DECLARE t_sliding_scale = i2 WITH protect, noconstant(0)
 DECLARE f_ivsolution_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",16389,
   "IVSOLUTIONS"))
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id= $2))
  HEAD REPORT
   facility_cd = e.loc_facility_cd
  WITH nocounter, time = 30
 ;end select
 IF (( $4=0)
  AND ( $5=0))
  SELECT INTO "nl:"
   FROM prsnl pr,
    name_value_prefs nvp,
    app_prefs ap,
    alt_sel_cat ascat,
    alt_sel_list asl,
    alt_sel_cat ascat1
   PLAN (pr
    WHERE (pr.person_id= $3))
    JOIN (nvp
    WHERE nvp.pvc_name="INPT_CATALOG_BROWSER_ROOT"
     AND nvp.active_ind=1
     AND nvp.pvc_value != " ")
    JOIN (ap
    WHERE ap.app_prefs_id=nvp.parent_entity_id
     AND ap.position_cd=pr.position_cd
     AND ap.active_ind=1)
    JOIN (ascat
    WHERE ascat.alt_sel_category_id=cnvtreal(nvp.pvc_value))
    JOIN (asl
    WHERE asl.alt_sel_category_id=ascat.alt_sel_category_id)
    JOIN (ascat1
    WHERE ascat1.alt_sel_category_id=asl.child_alt_sel_cat_id)
   ORDER BY asl.sequence
   HEAD REPORT
    out_rec->root = ascat.short_description, out_rec->root_id = cnvtstring(ascat.alt_sel_category_id)
   HEAD asl.sequence
    t_cnt += 1
    IF (mod(t_cnt,100)=1)
     stat = alterlist(out_rec->child_qual,(t_cnt+ 99))
    ENDIF
    out_rec->child_qual[t_cnt].name = ascat1.short_description, out_rec->child_qual[t_cnt].folder_id
     = cnvtstring(ascat1.alt_sel_category_id), out_rec->child_qual[t_cnt].type = "Folder",
    out_rec->child_qual[t_cnt].sequence = asl.sequence, out_rec->child_qual[t_cnt].clinical_category
     = "", out_rec->child_qual[t_cnt].sentence_id = "",
    out_rec->child_qual[t_cnt].sentence_display_line = "", out_rec->child_qual[t_cnt].
    activity_type_cd = "", out_rec->child_qual[t_cnt].catalog_cd = "",
    out_rec->child_qual[t_cnt].catalog_type_cd = "", out_rec->child_qual[t_cnt].format_id = ""
   FOOT REPORT
    stat = alterlist(out_rec->child_qual,t_cnt)
   WITH nocounter, time = 30
  ;end select
 ENDIF
 IF (((( $4 > 0)) OR (( $5=1))) )
  DECLARE where_params = vc WITH noconstant("")
  IF (( $4=0))
   SET where_params = build("ascat.owner_id =", $3,
    ' and ascat.short_description = "Favorites" and ascat.source_component_flag = 1')
  ELSE
   SET where_params = build("ascat.alt_sel_category_id =", $4)
  ENDIF
  SELECT INTO "nl:"
   FROM alt_sel_cat ascat,
    alt_sel_list asl,
    alt_sel_cat ascat1,
    order_catalog_synonym ocs,
    ocs_facility_r ofr,
    pw_cat_synonym pcs,
    order_sentence os
   PLAN (ascat
    WHERE parser(where_params))
    JOIN (asl
    WHERE asl.alt_sel_category_id=ascat.alt_sel_category_id)
    JOIN (ascat1
    WHERE ascat1.alt_sel_category_id=asl.child_alt_sel_cat_id)
    JOIN (ocs
    WHERE (ocs.synonym_id= Outerjoin(asl.synonym_id))
     AND (ocs.hide_flag= Outerjoin(0)) )
    JOIN (ofr
    WHERE (ofr.synonym_id= Outerjoin(ocs.synonym_id))
     AND (ofr.facility_cd= Outerjoin(facility_cd)) )
    JOIN (pcs
    WHERE (pcs.pw_cat_synonym_id= Outerjoin(asl.pw_cat_synonym_id)) )
    JOIN (os
    WHERE (os.order_sentence_id= Outerjoin(asl.order_sentence_id)) )
   ORDER BY asl.sequence
   HEAD REPORT
    out_rec->root = ascat.short_description, out_rec->root_id = cnvtstring(ascat.alt_sel_category_id)
   HEAD asl.sequence
    IF (ocs.synonym_id=0
     AND pcs.pw_cat_synonym_id=0
     AND ascat1.alt_sel_category_id != 0)
     t_cnt += 1
     IF (mod(t_cnt,100)=1)
      stat = alterlist(out_rec->child_qual,(t_cnt+ 99))
     ENDIF
     out_rec->child_qual[t_cnt].name = ascat1.short_description, out_rec->child_qual[t_cnt].folder_id
      = cnvtstring(ascat1.alt_sel_category_id), out_rec->child_qual[t_cnt].type = "Folder",
     out_rec->child_qual[t_cnt].sequence = asl.sequence
    ENDIF
    t_sliding_scale = evaluate(band(ocs.rx_mask,16),0,0,1)
    IF (ocs.synonym_id > 0
     AND ocs.active_ind=1
     AND ofr.synonym_id > 0
     AND t_sliding_scale != 1)
     t_cnt += 1
     IF (mod(t_cnt,100)=1)
      stat = alterlist(out_rec->child_qual,(t_cnt+ 99))
     ENDIF
     out_rec->child_qual[t_cnt].sliding_scale = t_sliding_scale, out_rec->child_qual[t_cnt].name =
     ocs.mnemonic, out_rec->child_qual[t_cnt].folder_id = cnvtstring(ocs.synonym_id),
     out_rec->child_qual[t_cnt].type = "Synonym", out_rec->child_qual[t_cnt].sequence = asl.sequence
     IF (ocs.orderable_type_flag=6)
      out_rec->child_qual[t_cnt].type = "Care Set - Order Set"
     ENDIF
     IF (((ocs.rx_mask=1) OR (ocs.rx_mask=2))
      AND ocs.rx_mask != 4)
      out_rec->child_qual[t_cnt].clinical_category = cnvtstring(f_ivsolution_cd)
     ELSE
      out_rec->child_qual[t_cnt].clinical_category = cnvtstring(ocs.dcp_clin_cat_cd)
     ENDIF
     out_rec->child_qual[t_cnt].sentence_id = cnvtstring(asl.order_sentence_id), out_rec->child_qual[
     t_cnt].sentence_display_line = os.order_sentence_display_line, out_rec->child_qual[t_cnt].
     activity_type_cd = cnvtstring(ocs.activity_type_cd),
     out_rec->child_qual[t_cnt].activity_type_disp = uar_get_code_display(ocs.activity_type_cd),
     out_rec->child_qual[t_cnt].catalog_cd = cnvtstring(ocs.catalog_cd), out_rec->child_qual[t_cnt].
     catalog_disp = uar_get_code_display(ocs.catalog_cd),
     out_rec->child_qual[t_cnt].catalog_type_cd = cnvtstring(ocs.catalog_type_cd), out_rec->
     child_qual[t_cnt].catalog_type_disp = uar_get_code_display(ocs.catalog_type_cd), out_rec->
     child_qual[t_cnt].format_id = cnvtstring(ocs.oe_format_id)
    ENDIF
    IF (pcs.pw_cat_synonym_id > 0)
     t_cnt += 1
     IF (mod(t_cnt,100)=1)
      stat = alterlist(out_rec->child_qual,(t_cnt+ 99))
     ENDIF
     out_rec->child_qual[t_cnt].name = pcs.synonym_name, out_rec->child_qual[t_cnt].folder_id =
     cnvtstring(pcs.pw_cat_synonym_id), out_rec->child_qual[t_cnt].type = "Plan",
     out_rec->child_qual[t_cnt].sequence = asl.sequence
    ENDIF
   FOOT REPORT
    stat = alterlist(out_rec->child_qual,t_cnt)
   WITH nocounter, time = 30
  ;end select
 ENDIF
 SET _memory_reply_string = cnvtrectojson(out_rec)
END GO
