CREATE PROGRAM bhs_rpt_ordfldr_audit_cat_typ:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Catalog Type:" = 0
  WITH outdev, f_cat_type_cd
 DECLARE mf_cat_type_cd = f8 WITH protect, noconstant(0.00)
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_cat_type_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_date_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_outstring = vc WITH protect, noconstant(" ")
 DECLARE ms_filename_in = vc WITH protect, noconstant(" ")
 DECLARE md_filename_out = vc WITH protect, noconstant(" ")
 IF (findstring("@", $OUTDEV) > 0)
  SET mn_email_ind = 1
  SET ms_output_dest = concat("public_orders_folders_",format(cnvtdatetime(sysdate),"YYYYMMDD;;D"),
   ".csv")
 ELSE
  SET mn_email_ind = 0
  SET ms_output_dest =  $OUTDEV
 ENDIF
 SET mf_cat_type_cd =  $F_CAT_TYPE_CD
 SET ms_cat_type_disp = build(uar_get_code_display(mf_cat_type_cd))
 IF (mf_cat_type_cd=0.00)
  GO TO exit_script
 ENDIF
 SELECT
  IF (mn_email_ind=1)
   WITH format, format = stream, pcformat('"',",",1),
    nocounter
  ELSE
  ENDIF
  INTO value(ms_output_dest)
  folder_description = trim(asc1.long_description,3), folder_display = trim(asc1.short_description,3),
  order_mnemonic = trim(ocs.mnemonic,3),
  primary_mnemonic = trim(uar_get_code_display(ocs.catalog_cd),3), order_sentence =
  IF (asl1.order_sentence_id > 0.00) trim(os.order_sentence_display_line,3)
  ENDIF
  FROM alt_sel_cat asc1,
   alt_sel_list asl1,
   order_catalog_synonym ocs,
   order_sentence os
  PLAN (asc1
   WHERE asc1.owner_id=0.00
    AND asc1.ahfs_ind IN (0, null))
   JOIN (asl1
   WHERE asl1.alt_sel_category_id=asc1.alt_sel_category_id
    AND asl1.synonym_id > 0.00)
   JOIN (ocs
   WHERE ocs.synonym_id=asl1.synonym_id
    AND ocs.catalog_type_cd=mf_cat_type_cd)
   JOIN (os
   WHERE os.order_sentence_id=asl1.order_sentence_id)
  ORDER BY asc1.long_description_key_cap, asl1.sequence
  WITH format, separator = " ", nocounter
 ;end select
 IF (mn_email_ind=1)
  SET ms_filename_in = trim(ms_output_dest)
  SET ms_filename_out = concat("Order_Folder_Audit_",replace(ms_cat_type_disp," ","_"),"_",format(
    curdate,"YYYYMMDD;;D"),".csv")
  CALL echo(ms_filename_out)
  EXECUTE bhs_ma_email_file
  CALL emailfile(ms_filename_in,ms_filename_out, $OUTDEV,concat(
    "Orders in Public foders by Catalog Type - ",format(curdate,"MMDDYYYY;;D")),1)
 ENDIF
#exit_script
END GO
