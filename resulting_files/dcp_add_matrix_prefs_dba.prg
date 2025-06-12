CREATE PROGRAM dcp_add_matrix_prefs:dba
 SET readme_data->message = build(
  "PVReadMe 1112 BEGIN:dcp_add_matrix_prefs: create root folders for matrix prefs.")
 EXECUTE dm_readme_status
 COMMIT
 RECORD clin_cat_cd(
   1 qual[16]
     2 code_value = f8
     2 display = vc
 )
 SET root_qual[16] = 0.0
 SET fav_qual[16] = 0.0
 SET stat = initarray(root_qual,0.0)
 SET stat = initarray(fav_qual,0.0)
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=16389
  DETAIL
   CASE (c.cdf_meaning)
    OF "ACTIVITY":
     clin_cat_cd->qual[1].code_value = c.code_value,clin_cat_cd->qual[1].display = c.display
    OF "CONDITION":
     clin_cat_cd->qual[2].code_value = c.code_value,clin_cat_cd->qual[2].display = c.display
    OF "CONSULTS":
     clin_cat_cd->qual[3].code_value = c.code_value,clin_cat_cd->qual[3].display = c.display
    OF "DIAGTESTS":
     clin_cat_cd->qual[4].code_value = c.code_value,clin_cat_cd->qual[4].display = c.display
    OF "DIET":
     clin_cat_cd->qual[5].code_value = c.code_value,clin_cat_cd->qual[5].display = c.display
    OF "IVSOLUTIONS":
     clin_cat_cd->qual[6].code_value = c.code_value,clin_cat_cd->qual[6].display = c.display
    OF "LABORATORY":
     clin_cat_cd->qual[7].code_value = c.code_value,clin_cat_cd->qual[7].display = c.display
    OF "MEDICATIONS":
     clin_cat_cd->qual[8].code_value = c.code_value,clin_cat_cd->qual[8].display = c.display
    OF "NURSORDERS":
     clin_cat_cd->qual[9].code_value = c.code_value,clin_cat_cd->qual[9].display = c.display
    OF "SPECIAL":
     clin_cat_cd->qual[10].code_value = c.code_value,clin_cat_cd->qual[10].display = c.display
    OF "VITALS":
     clin_cat_cd->qual[11].code_value = c.code_value,clin_cat_cd->qual[11].display = c.display
    OF "USERDEF1":
     clin_cat_cd->qual[12].code_value = c.code_value,clin_cat_cd->qual[12].display = c.display
    OF "USERDEF2":
     clin_cat_cd->qual[13].code_value = c.code_value,clin_cat_cd->qual[13].display = c.display
    OF "USERDEF3":
     clin_cat_cd->qual[14].code_value = c.code_value,clin_cat_cd->qual[14].display = c.display
    OF "USERDEF4":
     clin_cat_cd->qual[15].code_value = c.code_value,clin_cat_cd->qual[15].display = c.display
    OF "USERDEF5":
     clin_cat_cd->qual[16].code_value = c.code_value,clin_cat_cd->qual[16].display = c.display
   ENDCASE
  WITH check
 ;end select
 SELECT INTO "nl:"
  a.long_description
  FROM alt_sel_cat a
  WHERE a.long_description="Matrix*"
  DETAIL
   CASE (a.long_description)
    OF "Matrix Activity Root":
     root_qual[1] = a.alt_sel_category_id
    OF "Matrix Activity Favorites":
     fav_qual[1] = a.alt_sel_category_id
    OF "Matrix Condition Root":
     root_qual[2] = a.alt_sel_category_id
    OF "Matrix Condition Favorites":
     fav_qual[2] = a.alt_sel_category_id
    OF "Matrix Consults Root":
     root_qual[3] = a.alt_sel_category_id
    OF "Matrix Consults Favorites":
     fav_qual[3] = a.alt_sel_category_id
    OF "Matrix Diag Tests Root":
     root_qual[4] = a.alt_sel_category_id
    OF "Matrix Diag Tests Favorites":
     fav_qual[4] = a.alt_sel_category_id
    OF "Matrix Diet Root":
     root_qual[5] = a.alt_sel_category_id
    OF "Matrix Diet Favorites":
     fav_qual[5] = a.alt_sel_category_id
    OF "Matrix IV Root":
     root_qual[6] = a.alt_sel_category_id
    OF "Matrix IV Favorites":
     fav_qual[6] = a.alt_sel_category_id
    OF "Matrix Lab Root":
     root_qual[7] = a.alt_sel_category_id
    OF "Matrix Lab Favorites":
     fav_qual[7] = a.alt_sel_category_id
    OF "Matrix Meds Root":
     root_qual[8] = a.alt_sel_category_id
    OF "Matrix Meds Favorites":
     fav_qual[8] = a.alt_sel_category_id
    OF "Matrix Nursing Root":
     root_qual[9] = a.alt_sel_category_id
    OF "Matrix Nursing Favorites":
     fav_qual[9] = a.alt_sel_category_id
    OF "Matrix Special Root":
     root_qual[10] = a.alt_sel_category_id
    OF "Matrix Special Favorites":
     fav_qual[10] = a.alt_sel_category_id
    OF "Matrix Vitals Root":
     root_qual[11] = a.alt_sel_category_id
    OF "Matrix Vitals Favorites":
     fav_qual[11] = a.alt_sel_category_id
    OF "Matrix User Defined 1 Root":
     root_qual[12] = a.alt_sel_category_id
    OF "Matrix User Defined 1 Favorites":
     fav_qual[12] = a.alt_sel_category_id
    OF "Matrix User Defined 2 Root":
     root_qual[13] = a.alt_sel_category_id
    OF "Matrix User Defined 2 Favorites":
     fav_qual[13] = a.alt_sel_category_id
    OF "Matrix User Defined 3 Root":
     root_qual[14] = a.alt_sel_category_id
    OF "Matrix User Defined 3 Favorites":
     fav_qual[14] = a.alt_sel_category_id
    OF "Matrix User Defined 4 Root":
     root_qual[15] = a.alt_sel_category_id
    OF "Matrix User Defined 4 Favorites":
     fav_qual[15] = a.alt_sel_category_id
    OF "Matrix User Defined 5 Root":
     root_qual[16] = a.alt_sel_category_id
    OF "Matrix User Defined 5 Favorites":
     fav_qual[16] = a.alt_sel_category_id
   ENDCASE
  WITH check
 ;end select
 FOR (x = 1 TO 16)
   SET clin_cat_disp = fillstring(100,"")
   CASE (x)
    OF 1:
     SET clin_cat_disp = "Activity"
    OF 2:
     SET clin_cat_disp = "Condition"
    OF 3:
     SET clin_cat_disp = "Consults"
    OF 4:
     SET clin_cat_disp = "Diag Tests"
    OF 5:
     SET clin_cat_disp = "Diet"
    OF 6:
     SET clin_cat_disp = "IV"
    OF 7:
     SET clin_cat_disp = "Lab"
    OF 8:
     SET clin_cat_disp = "Meds"
    OF 9:
     SET clin_cat_disp = "Nursing"
    OF 10:
     SET clin_cat_disp = "Special"
    OF 11:
     SET clin_cat_disp = "Vitals"
    OF 12:
     SET clin_cat_disp = "User Defined 1"
    OF 13:
     SET clin_cat_disp = "User Defined 2"
    OF 14:
     SET clin_cat_disp = "User Defined 3"
    OF 15:
     SET clin_cat_disp = "User Defined 4"
    OF 16:
     SET clin_cat_disp = "User Defined 5"
   ENDCASE
   IF ((clin_cat_cd->qual[x].code_value > 0)
    AND (root_qual[x]=0.0))
    INSERT  FROM alt_sel_cat a
     SET a.alt_sel_category_id = seq(reference_seq,nextval), a.short_description = clin_cat_cd->qual[
      x].display, a.long_description = concat("Matrix ",clin_cat_disp," Root"),
      a.owner_id = 0, a.security_flag = 2, a.updt_id = 0.0,
      a.updt_task = 0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_cnt = 0,
      a.updt_applctx = 0, a.child_cat_ind = 1, a.long_description_key_cap = trim(cnvtupper(concat(
         "Matrix ",clin_cat_disp," Root"))),
      a.ahfs_ind = 0, a.adhoc_ind = 0
     WITH check
    ;end insert
   ENDIF
   IF ((clin_cat_cd->qual[x].code_value > 0)
    AND (fav_qual[x] > 0.0))
    DELETE  FROM alt_sel_list asl
     WHERE (asl.alt_sel_category_id=fav_qual[x])
      AND asl.alt_sel_category_id != 0.0
    ;end delete
    DELETE  FROM alt_sel_cat a
     WHERE (a.alt_sel_category_id=fav_qual[x])
      AND a.alt_sel_category_id != 0.0
    ;end delete
   ENDIF
 ENDFOR
 DELETE  FROM dcp_clinical_category d
  WHERE d.dcp_clin_cat_cd > 0
  WITH check
 ;end delete
 FOR (x = 1 TO 16)
   SET clin_cat_disp = fillstring(100,"")
   SET new_view_name = fillstring(100,"")
   SET rx_mask_pref_name = fillstring(100,"")
   CASE (x)
    OF 1:
     SET clin_cat_disp = "Activity"
     SET new_view_name = "ORDERDLG"
     SET rx_mask_pref_name = ""
    OF 2:
     SET clin_cat_disp = "Condition"
     SET new_view_name = "ORDERDLG"
     SET rx_mask_pref_name = ""
    OF 3:
     SET clin_cat_disp = "Consults"
     SET new_view_name = "ORDERDLG"
     SET rx_mask_pref_name = ""
    OF 4:
     SET clin_cat_disp = "Diag Tests"
     SET new_view_name = "ORDERDLG"
     SET rx_mask_pref_name = ""
    OF 5:
     SET clin_cat_disp = "Diet"
     SET new_view_name = "ORDERDLG"
     SET rx_mask_pref_name = ""
    OF 6:
     SET clin_cat_disp = "IV"
     SET new_view_name = "IVDLG"
     SET rx_mask_pref_name = "Matrix IV Rx Mask"
    OF 7:
     SET clin_cat_disp = "Lab"
     SET new_view_name = "ORDERDLG"
     SET rx_mask_pref_name = ""
    OF 8:
     SET clin_cat_disp = "Meds"
     SET new_view_name = "MEDDLG"
     SET rx_mask_pref_name = "Matrix Meds Rx Mask"
    OF 9:
     SET clin_cat_disp = "Nursing"
     SET new_view_name = "ORDERDLG"
     SET rx_mask_pref_name = ""
    OF 10:
     SET clin_cat_disp = "Special"
     SET new_view_name = "ORDERDLG"
     SET rx_mask_pref_name = ""
    OF 11:
     SET clin_cat_disp = "Vitals"
     SET new_view_name = "ORDERDLG"
     SET rx_mask_pref_name = ""
    OF 12:
     SET clin_cat_disp = "User Defined 1"
     SET new_view_name = "ORDERDLG"
     SET rx_mask_pref_name = ""
    OF 13:
     SET clin_cat_disp = "User Defined 2"
     SET new_view_name = "ORDERDLG"
     SET rx_mask_pref_name = ""
    OF 14:
     SET clin_cat_disp = "User Defined 3"
     SET new_view_name = "ORDERDLG"
     SET rx_mask_pref_name = ""
    OF 15:
     SET clin_cat_disp = "User Defined 4"
     SET new_view_name = "ORDERDLG"
     SET rx_mask_pref_name = ""
    OF 16:
     SET clin_cat_disp = "User Defined 5"
     SET new_view_name = "ORDERDLG"
     SET rx_mask_pref_name = ""
   ENDCASE
   IF ((clin_cat_cd->qual[x].code_value > 0))
    INSERT  FROM dcp_clinical_category d
     SET d.dcp_clin_cat_cd = clin_cat_cd->qual[x].code_value, d.new_view_name = new_view_name, d
      .aos_cat_gen_pref_name = concat("Matrix ",clin_cat_disp," Root"),
      d.aos_cat_cust_pref_name = "", d.aos_cat_sys_pref_name = "", d.rx_mask_pref_name =
      rx_mask_pref_name,
      d.updt_id = 0.0, d.updt_task = 0, d.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      d.updt_cnt = 0, d.updt_applctx = 0
     WITH check
    ;end insert
   ENDIF
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message = build("PVReadMe 1112 FINISHED: Prefs successfully written.")
 EXECUTE dm_readme_status
 COMMIT
END GO
