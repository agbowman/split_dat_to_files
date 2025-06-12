CREATE PROGRAM ccps_pha_lbt_preproc:dba
 IF (debug_ind=1)
  CALL echo("Entering sc_cps_pha_lbt_preproc . .")
 ENDIF
 DECLARE mi_description_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3290"))
 DECLARE mi_generic_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3294"))
 DECLARE mi_pharm_ipt_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!101131"))
 SELECT INTO "nl:"
  ingredient_type = evaluate(oi.ingredient_type_flag,params->ingred_sort_list[1].flag,1,params->
   ingred_sort_list[2].flag,2,
   params->ingred_sort_list[3].flag,3,4)
  FROM (dummyt d  WITH seq = size(label_rec->qual,5)),
   (dummyt d1  WITH seq = 1),
   order_ingredient oi
  PLAN (d
   WHERE maxrec(d1,size(label_rec->qual[d.seq].ingredients,5)))
   JOIN (d1)
   JOIN (oi
   WHERE (oi.order_id=label_ids->qual[d.seq].order_id)
    AND (oi.comp_sequence=label_rec->qual[d.seq].ingredients[d1.seq].sequence)
    AND (oi.action_sequence=label_ids->qual[d.seq].action_sequence))
  ORDER BY d.seq, oi.order_id, ingredient_type
  HEAD REPORT
   MACRO (parse_zeroes)
    dsvalue = fillstring(16," "), move_fld = fillstring(16," "), strfld = fillstring(16," "),
    sig_dig = 0, sig_dec = 0, strfld = cnvtstring(pass_field_in,16,4,r),
    str_cnt = 1, len = 0
    WHILE (str_cnt < 12
     AND substring(str_cnt,1,strfld) IN ("0", " "))
      str_cnt = (str_cnt+ 1)
    ENDWHILE
    sig_dig = (str_cnt - 1), str_cnt = 16
    WHILE (str_cnt > 12
     AND substring(str_cnt,1,strfld) IN ("0", " "))
      str_cnt = (str_cnt - 1)
    ENDWHILE
    IF (str_cnt=12
     AND substring(str_cnt,1,strfld)=".")
     str_cnt = (str_cnt - 1)
    ENDIF
    sig_dec = str_cnt
    IF (sig_dig=11
     AND sig_dec=11)
     dsvalue = "n/a"
    ELSE
     len = movestring(strfld,(sig_dig+ 1),move_fld,1,(sig_dec - sig_dig)), dsvalue = trim(move_fld)
     IF (substring(1,1,dsvalue)=".")
      dsvalue = concat("0",trim(move_fld))
     ENDIF
    ENDIF
   ENDMACRO
  DETAIL
   snormalizedrate = fillstring(30," "), snormalizedrateunit = fillstring(30," ")
   IF (oi.normalized_rate > 0
    AND oi.normalized_rate_unit_cd > 0)
    pass_field_in = oi.normalized_rate, parse_zeroes, snormalizedrateunit = trim(uar_get_code_display
     (oi.normalized_rate_unit_cd)),
    snormalizedrate = concat("[",trim(dsvalue,3)," ",snormalizedrateunit,"]"), label_rec->qual[d.seq]
    .normalized_rate = oi.normalized_rate, label_rec->qual[d.seq].normalized_rate_unit =
    snormalizedrateunit,
    label_rec->qual[d.seq].normalized_rate_string = snormalizedrate, label_rec->qual[d.seq].
    ingredients[d1.seq].normrate = snormalizedrate
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(label_rec->qual,5)),
   (dummyt d1  WITH seq = 1),
   fill_print_ord_hx po,
   med_identifier mi
  PLAN (d
   WHERE maxrec(d1,size(label_rec->qual[d.seq].ingredients,5)))
   JOIN (d1)
   JOIN (po
   WHERE (po.run_id=label_rec->run_id)
    AND (po.order_id=label_ids->qual[d.seq].order_id)
    AND (po.ingred_seq=label_rec->qual[d.seq].ingredients[d1.seq].sequence)
    AND trim(cnvtupper(po.cdm),3)=trim(cnvtupper(label_rec->qual[d.seq].ingredients[d1.seq].cdm),3))
   JOIN (mi
   WHERE mi.item_id=po.item_id
    AND mi.med_identifier_type_cd IN (mi_description_cd, mi_generic_cd)
    AND mi.pharmacy_type_cd=mi_pharm_ipt_cd
    AND mi.med_product_id=0
    AND mi.active_ind=1
    AND mi.primary_ind=1)
  ORDER BY po.order_id, po.order_row_seq
  DETAIL
   IF (mi.med_identifier_type_cd=mi_description_cd
    AND size(trim(mi.value)) > 0
    AND po.tnf_id=0)
    label_rec->qual[d.seq].ingredients[d1.seq].label_description = trim(mi.value)
   ELSEIF (mi.med_identifier_type_cd=mi_generic_cd
    AND size(trim(mi.value)) > 0
    AND po.tnf_id=0)
    label_rec->qual[d.seq].ingredients[d1.seq].generic_name = trim(mi.value)
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 IF (debug_ind=1)
  CALL echo(
   "Last Mod = 001 07/12/12 ma010032             Don't Overwrite the label description and generic name for TNF"
   )
  CALL echo(". . Exiting sc_cps_pha_lbt_preproc")
 ENDIF
END GO
