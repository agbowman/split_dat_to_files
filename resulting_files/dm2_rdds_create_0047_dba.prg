CREATE PROGRAM dm2_rdds_create_0047:dba
 DECLARE get_target_location_cd(loc_code=f8) = vc WITH public
 DECLARE get_target_resource_cd(rec_code=f8) = vc WITH public
 DECLARE get_target_task_ref_cd(tr_code=f8) = vc WITH public
 DECLARE get_target_event_cd(tr_code=f8) = vc WITH public
 DECLARE get_target_image_class_cd(imc_code=f8) = vc WITH public
 DECLARE get_target_catalog_cd(source_cat_code=f8) = vc WITH public
 DECLARE get_target_pchart_comp_cd(pchart_code=f8) = vc WITH public
 DECLARE get_target_dta(dta_code=f8) = vc WITH public
 DECLARE get_target_oefields(oe_code=f8) = vc WITH public
 DECLARE get_value(sbr_table=vc,sbr_column=vc,sbr_origin=vc) = vc WITH public
 DECLARE get_nullind(sbr_table=vc,sbr_column=vc) = i2 WITH public
 DECLARE put_value(sbr_table=vc,sbr_column=vc,sbr_value=vc) = null
 DECLARE get_translates(sbr_table=vc) = null
 DECLARE is_translated(sbr_table=vc,sbr_column=vc) = i2
 DECLARE get_seq(sbr_table=vc,sbr_column=vc) = f8
 DECLARE get_col_pos(sbr_table=vc,sbr_column=vc) = i4
 DECLARE get_primary_key(sbr_table=vc) = vc WITH public
 DECLARE check_ui_exist(sbr_table_name=vc) = i2
 DECLARE check_sec_trans(sbr_table_name=vc,sbr_col_name=vc) = null
 DECLARE inc_prelink = vc
 DECLARE inc_postlink = vc
 FREE RECORD rdds_exception
 RECORD rdds_exception(
   1 qual[*]
     2 tab_col_name = vc
     2 tru_tab_name = vc
     2 tru_col_name = vc
 )
 SUBROUTINE get_target_location_cd(loc_cd)
   DECLARE ui_loc_cd = vc
   DECLARE ui_cnt = i4
   DECLARE source_parent_ind = i2
   DECLARE to_par = f8
   DECLARE to_active = i2
   DECLARE mult_cnt = i4
   DECLARE mult_loop = i4
   DECLARE trans_ref = vc
   DECLARE par_cdf = vc
   DECLARE alt_par_cdf = vc
   DECLARE unknown_ind = i2
   DECLARE second_try_ind = i2
   DECLARE mult_loop = i4
   DECLARE sbr_any_trans = i2
   DECLARE new_cv_ind = i2
   FREE RECORD mult_loc
   RECORD mult_loc(
     1 qual[*]
       2 src_cd1 = f8
       2 src_cd2 = f8
       2 trans_ind1 = i2
       2 trans_ind2 = i2
       2 tgt_cd1 = f8
       2 tgt_cd2 = f8
       2 tgt_val = vc
       2 tgt_cnt = i4
       2 sec_try = i2
   )
   SET to_active = 0
   SET to_par = 0
   SET ui_cnt = 0
   SET source_parent_ind = 0
   SET unknown_ind = 0
   SET gt_select = concat(value(dm2_ref_data_doc->pre_link_name),"code_value",value(dm2_ref_data_doc
     ->post_link_name))
   CASE (rs_619->from_values.cdf_meaning)
    OF "NURSEUNIT":
    OF "AMBULATORY":
     SET gt_lgselect = concat(value(dm2_ref_data_doc->pre_link_name),"nurse_unit",value(
       dm2_ref_data_doc->post_link_name))
     CALL parser("select into 'nl:' from ",0)
     CALL parser(concat(gt_lgselect," l "),0)
     CALL parser(concat(" where l.location_cd = ",cnvtstring(loc_cd)),0)
     CALL parser(" detail mult_cnt = mult_cnt + 1 ",0)
     CALL parser(" stat = alterlist(mult_loc->qual, mult_cnt) ",0)
     CALL parser(concat(" mult_loc->qual[mult_cnt].src_cd1 = l.loc_building_cd ",
       " mult_loc->qual[mult_cnt].src_cd2 = l.loc_facility_cd "),0)
     CALL parser(" with nocounter go",1)
    OF "ROOM":
     SET gt_lgselect = concat(value(dm2_ref_data_doc->pre_link_name),"room",value(dm2_ref_data_doc->
       post_link_name))
     CALL parser("select into 'nl:' from ",0)
     CALL parser(concat(gt_lgselect," l "),0)
     CALL parser(concat(" where l.location_cd = ",cnvtstring(loc_cd)),0)
     CALL parser(" detail mult_cnt = mult_cnt + 1 ",0)
     CALL parser(" stat = alterlist(mult_loc->qual, mult_cnt) ",0)
     CALL parser(" mult_loc->qual[mult_cnt].src_cd1 = l.loc_nurse_unit_cd ",0)
     CALL parser(" with nocounter go",1)
    OF "BED":
     SET gt_lgselect = concat(value(dm2_ref_data_doc->pre_link_name),"bed",value(dm2_ref_data_doc->
       post_link_name))
     CALL parser("select into 'nl:' from ",0)
     CALL parser(concat(gt_lgselect," l "),0)
     CALL parser(concat(" where l.location_cd = ",cnvtstring(loc_cd)),0)
     CALL parser(" detail mult_cnt = mult_cnt + 1 ",0)
     CALL parser(" stat = alterlist(mult_loc->qual, mult_cnt) ",0)
     CALL parser(" mult_loc->qual[mult_cnt].src_cd1 = l.loc_room_cd ",0)
     CALL parser(" with nocounter go",1)
    OF "FACILITY":
    OF "ACTASGNROOT":
    OF "APPTROOT":
    OF "BBOWNERROOT":
    OF "COLLROOT":
    OF "CSLOGIN":
    OF "CSTRACK":
    OF "FOLLOWUPAMB":
    OF "HIMROOT":
    OF "HIS":
    OF "INVGRP":
    OF "INVVIEW":
    OF "LAB":
    OF "MMGRPROOT":
    OF "PATLISTROOT":
    OF "PLREMOTE":
    OF "PTTRACKROOT":
    OF "PTTRACKVIEW":
    OF "ROUNDSROOT":
    OF "RXLOCGROUP":
    OF "SPECCOLLROOT":
    OF "SPECTRKROOT":
    OF "SRVAREA":
    OF "STORAGERACK":
    OF "STORAGEROOT":
    OF "STORTRKROOT":
    OF "TRANSPORT":
    OF "TSKGRPROOT":
     CALL echo("No source work needs to be done for this CDF_Meaning")
     SET mult_cnt = 1
     SET stat = alterlist(mult_loc->qual,mult_cnt)
    ELSE
     IF ((rs_619->from_values.cdf_meaning IN ("ANCILSURG", "APPTLOC", "HIM", "PHARM", "RAD")))
      SET par_cdf = "BUILDING"
      SET alt_par_cdf = ""
     ELSEIF ((rs_619->from_values.cdf_meaning="BBINVAREA"))
      SET par_cdf = "BBOWNERROOT"
      SET alt_par_cdf = ""
     ELSEIF ((rs_619->from_values.cdf_meaning="BUILDING"))
      SET par_cdf = "FACILITY"
      SET alt_par_cdf = ""
     ELSEIF ((rs_619->from_values.cdf_meaning IN ("CHECKOUT", "WAITROOM")))
      SET par_cdf = "AMBULATORY"
      SET alt_par_cdf = ""
     ELSEIF ((rs_619->from_values.cdf_meaning="COLLRTE"))
      SET par_cdf = "COLLRUN"
      SET alt_par_cdf = ""
     ELSEIF ((rs_619->from_values.cdf_meaning="COLLRUN"))
      SET par_cdf = "COLLROOT"
      SET alt_par_cdf = ""
     ELSEIF ((rs_619->from_values.cdf_meaning="INVLOC"))
      SET par_cdf = "BUILDING"
      SET alt_par_cdf = "ANCILSURG"
     ELSEIF ((rs_619->from_values.cdf_meaning="INVLOCATOR"))
      SET par_cdf = "INVLOC"
      SET alt_par_cdf = ""
     ELSEIF ((rs_619->from_values.cdf_meaning="PTTRACK"))
      SET par_cdf = "PTTRACKROOT"
      SET alt_par_cdf = ""
     ELSEIF ((rs_619->from_values.cdf_meaning="STORAGESHELF"))
      SET par_cdf = "STORAGEUNIT"
      SET alt_par_cdf = ""
     ELSEIF ((rs_619->from_values.cdf_meaning="STORAGEUNIT"))
      SET par_cdf = "STORAGEROOT"
      SET alt_par_cdf = ""
     ELSE
      SET par_cdf = ""
      SET alt_par_cdf = ""
      SET unknown_ind = 1
     ENDIF
     SET gt_lgselect = concat(value(dm2_ref_data_doc->pre_link_name),"location_group",value(
       dm2_ref_data_doc->post_link_name))
     CALL parser("select into 'nl:' from ",0)
     IF (par_cdf="")
      CALL parser(concat(gt_lgselect," l "),0)
      CALL parser(concat(" where l.child_loc_cd = ",cnvtstring(loc_cd)),0)
     ELSE
      CALL parser(concat(gt_lgselect," l, ",gt_select," c"),0)
      CALL parser(concat(" where l.child_loc_cd = ",cnvtstring(loc_cd)),0)
      CALL parser(" and l.parent_loc_cd = c.code_value and c.cdf_meaning = par_cdf",0)
     ENDIF
     CALL parser(" detail mult_cnt = mult_cnt + 1 ",0)
     CALL parser(" stat = alterlist(mult_loc->qual, mult_cnt) ",0)
     CALL parser(
      " mult_loc->qual[mult_cnt].src_cd1=l.parent_loc_cd mult_loc->qual[mult_cnt].src_cd2=l.root_loc_cd",
      0)
     CALL parser(" with nocounter go",1)
     IF (mult_cnt=0
      AND alt_par_cdf != "")
      CALL parser("select into 'nl:' from ",0)
      CALL parser(concat(gt_lgselect," l, ",gt_select," c"),0)
      CALL parser(concat(" where l.child_loc_cd = ",cnvtstring(loc_cd)),0)
      CALL parser(" and l.parent_loc_cd = c.code_value and c.cdf_meaning = alt_par_cdf",0)
      CALL parser(" detail mult_cnt = mult_cnt + 1 ",0)
      CALL parser(" stat = alterlist(mult_loc->qual, mult_cnt) ",0)
      CALL parser(" mult_loc->qual[mult_cnt].src_cd1 = l.parent_loc_cd ",0)
      CALL parser(" mult_loc->qual[mult_cnt].src_cd2 = l.root_loc_cd with nocounter go",1)
     ENDIF
   ENDCASE
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
    RETURN("No_Trans20")
   ENDIF
   IF (mult_cnt=0)
    IF (unknown_ind=0)
     RETURN("No_Trans17")
    ENDIF
   ENDIF
   FOR (mult_loop = 1 TO mult_cnt)
    IF ((mult_loc->qual[mult_loop].src_cd1 > 0))
     SET trans_ref = select_merge_translate(cnvtstring(mult_loc->qual[mult_loop].src_cd1),
      "CODE_VALUE")
     IF (trans_ref != "No Trans")
      SET mult_loc->qual[mult_loop].tgt_cd1 = cnvtreal(trans_ref)
      SET mult_loc->qual[mult_loop].trans_ind1 = 1
     ENDIF
    ELSE
     SET mult_loc->qual[mult_loop].tgt_cd1 = 0
     SET mult_loc->qual[mult_loop].trans_ind1 = 1
    ENDIF
    IF ((mult_loc->qual[mult_loop].src_cd2 > 0))
     SET trans_ref = select_merge_translate(cnvtstring(mult_loc->qual[mult_loop].src_cd2),
      "CODE_VALUE")
     IF (trans_ref != "No Trans")
      SET mult_loc->qual[mult_loop].tgt_cd2 = cnvtreal(trans_ref)
      SET mult_loc->qual[mult_loop].trans_ind2 = 1
     ENDIF
    ELSE
     SET mult_loc->qual[mult_loop].tgt_cd2 = 0
     SET mult_loc->qual[mult_loop].trans_ind2 = 1
    ENDIF
   ENDFOR
   FOR (mult_loop = 1 TO mult_cnt)
     IF ((mult_loc->qual[mult_loop].trans_ind1=1)
      AND (mult_loc->qual[mult_loop].trans_ind2=1))
      SET sbr_any_trans = 1
     ENDIF
   ENDFOR
   IF (sbr_any_trans=0)
    RETURN("No_Trans1")
   ENDIF
   FOR (mult_loop = 1 TO mult_cnt)
     SET ui_cnt = 0
     SET ui_loc_cd = ""
     IF ((mult_loc->qual[mult_loop].trans_ind1=1)
      AND (mult_loc->qual[mult_loop].trans_ind2=1))
      CASE (rs_619->from_values.cdf_meaning)
       OF "NURSEUNIT":
       OF "AMBULATORY":
        CALL parser("select into 'nl:' from code_value cv",0)
        CALL parser(" where list(cv.display, cv.display_key, cv.cdf_meaning) in (",0)
        CALL parser("select cv2.display, cv2.display_key, cv2.cdf_meaning from",0)
        CALL parser(concat(gt_select," cv2 "),0)
        CALL parser(concat(" where cv2.code_value = ",cnvtstring(loc_cd),")"),0)
        CALL parser("and cv.code_set = 220 and cv.code_value in (select l.location_cd",0)
        CALL parser(concat(" from nurse_unit l where l.loc_building_cd= ",cnvtstring(mult_loc->qual[
           mult_loop].tgt_cd1)),0)
        CALL parser(concat(" and l.loc_facility_cd = ",cnvtstring(mult_loc->qual[mult_loop].tgt_cd2),
          ")"),0)
        CALL parser(
         " detail ui_cnt = ui_cnt + 1 ui_loc_cd = cnvtstring(cv.code_value) with nocounter go ",1)
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         SET dm_err->err_ind = 0
         SET nodelete_ind = 1
         RETURN("No_Trans20")
        ENDIF
        IF (ui_cnt > 1)
         SET ui_cnt = 0
         SET mult_loc->qual[mult_loop].sec_try = 1
         CALL parser("select into 'nl:' from code_value cv",0)
         CALL parser(" where list(cv.display, cv.display_key, cv.cdf_meaning, cv.active_ind) in (",0)
         CALL parser("select cv2.display, cv2.display_key, cv2.cdf_meaning, cv2.active_ind from",0)
         CALL parser(concat(gt_select," cv2 "),0)
         CALL parser(concat(" where cv2.code_value = ",cnvtstring(loc_cd),")"),0)
         CALL parser("and cv.code_set = 220 and cv.code_value in (select l.location_cd",0)
         CALL parser(concat(" from nurse_unit l where l.loc_building_cd = ",cnvtstring(mult_loc->
            qual[mult_loop].tgt_cd1)),0)
         CALL parser(concat(" and l.loc_facility_cd = ",cnvtstring(mult_loc->qual[mult_loop].tgt_cd2),
           ")"),0)
         CALL parser(
          " detail ui_cnt = ui_cnt + 1 ui_loc_cd = cnvtstring(cv.code_value) with nocounter go ",1)
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          SET dm_err->err_ind = 0
          SET nodelete_ind = 1
          RETURN("No_Trans20")
         ENDIF
        ENDIF
       OF "ROOM":
        CALL parser("select into 'nl:' from code_value cv",0)
        CALL parser(" where list(cv.display, cv.display_key, cv.cdf_meaning, cv.description) in (",0)
        CALL parser("select cv2.display, cv2.display_key, cv2.cdf_meaning, cv2.description from",0)
        CALL parser(concat(gt_select," cv2 "),0)
        CALL parser(concat(" where cv2.code_value = ",cnvtstring(loc_cd),")"),0)
        CALL parser("and cv.code_set = 220 and cv.code_value in (select l.location_cd",0)
        CALL parser(concat(" from room l where l.loc_nurse_unit_cd=",cnvtstring(mult_loc->qual[
           mult_loop].tgt_cd1),")"),0)
        CALL parser(
         " detail ui_cnt = ui_cnt + 1 ui_loc_cd = cnvtstring(cv.code_value) with nocounter go ",1)
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         SET dm_err->err_ind = 0
         SET nodelete_ind = 1
         RETURN("No_Trans20")
        ENDIF
        IF (ui_cnt > 1)
         SET ui_cnt = 0
         SET mult_loc->qual[mult_loop].sec_try = 1
         CALL parser("select into 'nl:' from code_value cv",0)
         CALL parser(
          " where list(cv.display, cv.display_key, cv.cdf_meaning, cv.description, cv.active_ind) in (",
          0)
         CALL parser(
          "select cv2.display, cv2.display_key, cv2.cdf_meaning, cv2.description, cv2.active_ind from",
          0)
         CALL parser(concat(gt_select," cv2 "),0)
         CALL parser(concat(" where cv2.code_value = ",cnvtstring(loc_cd),")"),0)
         CALL parser("and cv.code_set = 220 and cv.code_value in (select l.location_cd",0)
         CALL parser(concat(" from room l where l.loc_nurse_unit_cd = ",cnvtstring(mult_loc->qual[
            mult_loop].tgt_cd1),")"),0)
         CALL parser(
          " detail ui_cnt = ui_cnt + 1 ui_loc_cd = cnvtstring(cv.code_value) with nocounter go ",1)
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          SET dm_err->err_ind = 0
          SET nodelete_ind = 1
          RETURN("No_Trans20")
         ENDIF
        ENDIF
       OF "BED":
        CALL parser("select into 'nl:' from code_value cv",0)
        CALL parser(" where list(cv.display, cv.display_key, cv.cdf_meaning) in (",0)
        CALL parser("select cv2.display, cv2.display_key, cv2.cdf_meaning from",0)
        CALL parser(concat(gt_select," cv2 "),0)
        CALL parser(concat(" where cv2.code_value = ",cnvtstring(loc_cd),")"),0)
        CALL parser("and cv.code_set = 220 and cv.code_value in (select l.location_cd",0)
        CALL parser(concat(" from bed l where l.loc_room_cd = ",cnvtstring(mult_loc->qual[mult_loop].
           tgt_cd1),")"),0)
        CALL parser(
         " detail ui_cnt = ui_cnt + 1 ui_loc_cd = cnvtstring(cv.code_value) with nocounter go ",1)
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         SET dm_err->err_ind = 0
         SET nodelete_ind = 1
         RETURN("No_Trans20")
        ENDIF
        IF (ui_cnt > 1)
         SET ui_cnt = 0
         SET mult_loc->qual[mult_loop].sec_try = 1
         CALL parser("select into 'nl:' from code_value cv",0)
         CALL parser(" where list(cv.display, cv.display_key, cv.cdf_meaning, cv.active_ind) in (",0)
         CALL parser("select cv2.display, cv2.display_key, cv2.cdf_meaning, cv2.active_ind from",0)
         CALL parser(concat(gt_select," cv2 "),0)
         CALL parser(concat(" where cv2.code_value = ",cnvtstring(loc_cd),")"),0)
         CALL parser("and cv.code_set = 220 and cv.code_value in (select l.location_cd",0)
         CALL parser(concat(" from bed l where l.loc_room_cd = ",cnvtstring(mult_loc->qual[mult_loop]
            .tgt_cd1),")"),0)
         CALL parser(
          " detail ui_cnt = ui_cnt + 1 ui_loc_cd = cnvtstring(cv.code_value) with nocounter go ",1)
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          SET dm_err->err_ind = 0
          SET nodelete_ind = 1
          RETURN("No_Trans20")
         ENDIF
        ENDIF
       OF "FACILITY":
       OF "CSTRACK":
       OF "CSLOGIN":
        CALL parser("select into 'nl:' from code_value cv",0)
        CALL parser(" where list(cv.display, cv.display_key, cv.cdf_meaning, cv.description) in (",0)
        CALL parser("select cv2.display, cv2.display_key, cv2.cdf_meaning, cv2.description from",0)
        CALL parser(concat(gt_select," cv2 "),0)
        CALL parser(concat(" where cv2.code_value = ",cnvtstring(loc_cd),")"),0)
        CALL parser("and cv.code_set = 220 ",0)
        CALL parser(
         " detail ui_cnt = ui_cnt + 1 ui_loc_cd = cnvtstring(cv.code_value) with nocounter go ",1)
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         SET dm_err->err_ind = 0
         SET nodelete_ind = 1
         RETURN("No_Trans20")
        ENDIF
        IF (ui_cnt > 1)
         SET ui_cnt = 0
         SET mult_loc->qual[mult_loop].sec_try = 1
         CALL parser("select into 'nl:' from code_value cv",0)
         CALL parser(
          " where list(cv.display, cv.display_key, cv.cdf_meaning, cv.description, cv.active_ind) in (",
          0)
         CALL parser(
          "select cv2.display, cv2.display_key, cv2.cdf_meaning, cv2.description, cv2.active_ind from",
          0)
         CALL parser(concat(gt_select," cv2 "),0)
         CALL parser(concat(" where cv2.code_value = ",cnvtstring(loc_cd),")"),0)
         CALL parser("and cv.code_set = 220 ",0)
         CALL parser(
          " detail ui_cnt = ui_cnt + 1 ui_loc_cd = cnvtstring(cv.code_value) with nocounter go ",1)
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          SET dm_err->err_ind = 0
          SET nodelete_ind = 1
          RETURN("No_Trans20")
         ENDIF
        ENDIF
       OF "ACTASGNROOT":
       OF "APPTROOT":
       OF "BBOWNERROOT":
       OF "COLLROOT":
       OF "FOLLOWUPAMB":
       OF "HIMROOT":
       OF "HIS":
       OF "INVGRP":
       OF "INVVIEW":
       OF "LAB":
       OF "MMGRPROOT":
       OF "PATLISTROOT":
       OF "PLREMOTE":
       OF "PTTRACKROOT":
       OF "PTTRACKVIEW":
       OF "ROUNDSROOT":
       OF "RXLOCGROUP":
       OF "SPECCOLLROOT":
       OF "SPECTRKROOT":
       OF "STORAGEROOT":
       OF "STORTRKROOT":
       OF "SRVAREA":
       OF "STORAGERACK":
       OF "TSKGRPROOT":
       OF "TRANSPORT":
        CALL parser("select into 'nl:' from code_value cv",0)
        CALL parser(" where list(cv.display, cv.display_key, cv.cdf_meaning) in (",0)
        CALL parser("select cv2.display, cv2.display_key, cv2.cdf_meaning from",0)
        CALL parser(concat(gt_select," cv2 "),0)
        CALL parser(concat(" where cv2.code_value = ",cnvtstring(loc_cd),")"),0)
        CALL parser("and cv.code_set = 220 ",0)
        CALL parser(
         " detail ui_cnt = ui_cnt + 1 ui_loc_cd = cnvtstring(cv.code_value) with nocounter go ",1)
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         SET dm_err->err_ind = 0
         SET nodelete_ind = 1
         RETURN("No_Trans20")
        ENDIF
        IF (ui_cnt > 1)
         SET ui_cnt = 0
         SET mult_loc->qual[mult_loop].sec_try = 1
         CALL parser("select into 'nl:' from code_value cv",0)
         CALL parser(" where list(cv.display, cv.display_key, cv.cdf_meaning,cv.active_ind) in (",0)
         CALL parser("select cv2.display, cv2.display_key, cv2.cdf_meaning, cv2.active_ind from",0)
         CALL parser(concat(gt_select," cv2 "),0)
         CALL parser(concat(" where cv2.code_value = ",cnvtstring(loc_cd),")"),0)
         CALL parser("and cv.code_set = 220 ",0)
         CALL parser(
          " detail ui_cnt = ui_cnt + 1 ui_loc_cd = cnvtstring(cv.code_value) with nocounter go ",1)
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          SET dm_err->err_ind = 0
          SET nodelete_ind = 1
          RETURN("No_Trans20")
         ENDIF
        ENDIF
       ELSE
        IF (unknown_ind=1
         AND (mult_loc->qual[mult_loop].tgt_cd1=0))
         CALL parser("select into 'nl:' from code_value cv",0)
         CALL parser(" where list(cv.display, cv.display_key, cv.cdf_meaning, cv.description) in (",0
          )
         CALL parser("select cv2.display, cv2.display_key, cv2.cdf_meaning, cv2.description from",0)
         CALL parser(concat(gt_select," cv2 "),0)
         CALL parser(concat(" where cv2.code_value = ",cnvtstring(loc_cd),")"),0)
         CALL parser("and cv.code_set = 220 ",0)
         CALL parser(
          " detail ui_cnt = ui_cnt + 1 ui_loc_cd = cnvtstring(cv.code_value) with nocounter go ",1)
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          SET dm_err->err_ind = 0
          SET nodelete_ind = 1
          RETURN("No_Trans20")
         ENDIF
         IF (ui_cnt > 1)
          SET ui_cnt = 0
          SET mult_loc->qual[mult_loop].sec_try = 1
          CALL parser("select into 'nl:' from code_value cv",0)
          CALL parser(
           " where list(cv.display, cv.display_key, cv.cdf_meaning, cv.description, cv.active_ind) in (",
           0)
          CALL parser(
           "select cv2.display, cv2.display_key, cv2.cdf_meaning, cv2.description, cv2.active_ind from",
           0)
          CALL parser(concat(gt_select," cv2 "),0)
          CALL parser(concat(" where cv2.code_value = ",cnvtstring(loc_cd),")"),0)
          CALL parser("and cv.code_set = 220 ",0)
          CALL parser(
           " detail ui_cnt = ui_cnt + 1 ui_loc_cd = cnvtstring(cv.code_value) with nocounter go ",1)
          IF (check_error(dm_err->eproc)=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           SET dm_err->err_ind = 0
           SET nodelete_ind = 1
           RETURN("No_Trans20")
          ENDIF
         ENDIF
        ELSE
         CALL parser("select into 'nl:' from code_value cv",0)
         CALL parser(" where list(cv.display, cv.display_key, cv.cdf_meaning) in (",0)
         CALL parser("select cv2.display, cv2.display_key, cv2.cdf_meaning from",0)
         CALL parser(concat(gt_select," cv2 "),0)
         CALL parser(concat(" where cv2.code_value = ",cnvtstring(loc_cd),")"),0)
         CALL parser("and cv.code_set = 220 and cv.code_value in (",0)
         CALL parser(concat(" select l.child_loc_cd from location_group l where l.parent_loc_cd = ",
           cnvtstring(mult_loc->qual[mult_loop].tgt_cd1)),0)
         CALL parser(concat(" and l.root_loc_cd = ",cnvtstring(mult_loc->qual[mult_loop].tgt_cd2),")"
           ),0)
         CALL parser(
          " detail ui_cnt = ui_cnt + 1 ui_loc_cd = cnvtstring(cv.code_value) with nocounter go ",1)
         IF (check_error(dm_err->eproc)=1)
          CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
          SET dm_err->err_ind = 0
          SET nodelete_ind = 1
          RETURN("No_Trans20")
         ENDIF
         IF (ui_cnt > 1)
          SET ui_cnt = 0
          SET mult_loc->qual[mult_loop].sec_try = 1
          CALL parser("select into 'nl:' from code_value cv",0)
          CALL parser(" where list(cv.display, cv.display_key, cv.cdf_meaning, cv.active_ind) in (",0
           )
          CALL parser("select cv2.display, cv2.display_key, cv2.cdf_meaning, cv2.active_ind from",0)
          CALL parser(concat(gt_select," cv2 "),0)
          CALL parser(concat(" where cv2.code_value = ",cnvtstring(loc_cd),")"),0)
          CALL parser("and cv.code_set = 220 and cv.code_value in (",0)
          CALL parser(concat(" select l.child_loc_cd from location_group l where l.parent_loc_cd = ",
            cnvtstring(mult_loc->qual[mult_loop].tgt_cd1)),0)
          CALL parser(concat(" and l.root_loc_cd = ",cnvtstring(mult_loc->qual[mult_loop].tgt_cd2),
            ")"),0)
          CALL parser(
           " detail ui_cnt = ui_cnt + 1 ui_loc_cd = cnvtstring(cv.code_value) with nocounter go ",1)
          IF (check_error(dm_err->eproc)=1)
           CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
           SET dm_err->err_ind = 0
           SET nodelete_ind = 1
           RETURN("No_Trans20")
          ENDIF
         ENDIF
        ENDIF
      ENDCASE
      SET mult_loc->qual[mult_loop].tgt_cnt = ui_cnt
      SET mult_loc->qual[mult_loop].tgt_val = ui_loc_cd
     ENDIF
   ENDFOR
   SET new_cv_ind = 1
   FOR (mult_loop = 1 TO mult_cnt)
     IF ((mult_loc->qual[mult_loop].trans_ind1=1)
      AND (mult_loc->qual[mult_loop].trans_ind2=1))
      IF ((mult_loc->qual[mult_loop].tgt_cnt > 0))
       SET new_cv_ind = 0
      ENDIF
      IF ((mult_loc->qual[mult_loop].tgt_cnt=1))
       RETURN(mult_loc->qual[mult_loop].tgt_val)
      ENDIF
     ENDIF
   ENDFOR
   IF (new_cv_ind=1)
    SET second_try_ind = 0
    FOR (mult_loop = 1 TO mult_cnt)
      IF ((mult_loc->qual[mult_loop].trans_ind1=1)
       AND (mult_loc->qual[mult_loop].trans_ind2=1))
       IF ((mult_loc->qual[mult_loop].sec_try=1))
        SET second_try_ind = 1
       ENDIF
      ENDIF
    ENDFOR
    IF (second_try_ind=0)
     RETURN("0")
    ELSE
     RETURN("No_Trans19")
    ENDIF
   ENDIF
   RETURN("No_Trans2")
 END ;Subroutine
 SUBROUTINE get_target_catalog_cd(source_cat_code)
   DECLARE ui_cat_cd = vc
   DECLARE ui_cat_cnt = i4
   SET ui_cat_cnt = 0
   SET inc_prelink = dm2_ref_data_doc->pre_link_name
   SET inc_postlink = dm2_ref_data_doc->post_link_name
   SET gt_select = concat(inc_prelink,"order_catalog",inc_postlink)
   SELECT INTO "nl:"
    oct.catalog_cd
    FROM order_catalog oct
    WHERE (oct.primary_mnemonic=
    (SELECT
     oc.primary_mnemonic
     FROM (value(gt_select) oc)
     WHERE oc.catalog_cd=source_cat_code))
    DETAIL
     ui_cat_cnt = (ui_cat_cnt+ 1), ui_cat_cd = cnvtstring(oct.catalog_cd)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
    RETURN("No_Trans20")
   ENDIF
   IF (curqual > 0)
    IF (ui_cat_cnt=1)
     RETURN(ui_cat_cd)
    ELSE
     RETURN("No_Trans3")
    ENDIF
   ELSE
    RETURN(cnvtstring(0))
   ENDIF
 END ;Subroutine
 SUBROUTINE get_target_event_cd(tr_code)
   DECLARE ui_es_cd = vc
   DECLARE ui_es_cnt = i4
   SET ui_es_cnt = 0
   SET inc_prelink = dm2_ref_data_doc->pre_link_name
   SET inc_postlink = dm2_ref_data_doc->post_link_name
   SET gt_select = concat(inc_prelink,"v500_event_code",inc_postlink)
   SELECT INTO "nl:"
    es.event_cd
    FROM v500_event_code es
    WHERE list(es.event_cd_disp,es.event_cd_descr,es.event_set_name) IN (
    (SELECT
     es1.event_cd_disp, es1.event_cd_descr, es1.event_set_name
     FROM (value(gt_select) es1)
     WHERE es1.event_cd=tr_code))
    DETAIL
     ui_es_cnt = (ui_es_cnt+ 1), ui_es_cd = cnvtstring(es.event_cd)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
    RETURN("No_Trans20")
   ENDIF
   IF (curqual > 0)
    IF (ui_es_cnt=1)
     RETURN(ui_es_cd)
    ELSE
     RETURN("No_Trans18")
    ENDIF
   ELSE
    RETURN(cnvtstring(0))
   ENDIF
 END ;Subroutine
 SUBROUTINE get_target_pchart_comp_cd(pchart_code)
   DECLARE ui_cat_cd = vc
   DECLARE ui_cat_cnt = i4
   SET ui_cat_cnt = 0
   SET inc_prelink = dm2_ref_data_doc->pre_link_name
   SET inc_postlink = dm2_ref_data_doc->post_link_name
   SET gt_select = concat(inc_prelink,"code_value",inc_postlink)
   SELECT INTO "nl:"
    c.code_value
    FROM (parser(gt_select) cv),
     code_value c
    WHERE cv.code_value=pchart_code
     AND cv.definition=c.definition
     AND cv.cdf_meaning=c.cdf_meaning
    DETAIL
     ui_cat_cnt = (ui_cat_cnt+ 1), ui_cat_cd = cnvtstring(c.code_value)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
    RETURN("No_Trans20")
   ENDIF
   IF (curqual > 0)
    IF (ui_cat_cnt=1)
     RETURN(ui_cat_cd)
    ELSE
     RETURN("No_Trans4")
    ENDIF
   ELSE
    RETURN(cnvtstring(0))
   ENDIF
 END ;Subroutine
 SUBROUTINE get_target_resource_cd(rec_cd)
   DECLARE ui_rec_cd = vc
   DECLARE ui_rec_cnt = i4
   DECLARE cv_parent_ind = i2
   DECLARE source_parent_ind = i2
   DECLARE to_par = f8
   DECLARE to_active = i2
   FREE RECORD res_cd
   RECORD res_cd(
     1 qual[*]
       2 from_val = f8
       2 to_val = f8
       2 trans_ind = i2
       2 active_ind = i2
   )
   DECLARE res_rs_loop = i4
   DECLARE sbr_ret_value = vc
   DECLARE par_res_cnt = i4
   SET to_active = 0
   SET ui_rec_cd = ""
   SET to_par = 0
   SET ui_rec_cnt = 0
   SET source_parent_ind = 0
   SET cv_parent_ind = 0
   SET gt_select = concat(value(dm2_ref_data_doc->pre_link_name),"code_value",value(dm2_ref_data_doc
     ->post_link_name))
   SET gt_lgselect = concat(value(dm2_ref_data_doc->pre_link_name),"resource_group",value(
     dm2_ref_data_doc->post_link_name))
   CALL parser("select into 'nl:' from ",0)
   CALL parser(concat(gt_lgselect," r"),0)
   CALL parser(concat(" where r.child_service_resource_cd = ",cnvtstring(rec_cd)),0)
   CALL parser(" detail to_active = r.active_ind source_parent_ind = 1 with nocounter go",1)
   IF (curqual > 0)
    CALL parser("select into 'nl:'",0)
    CALL parser(concat("from ",gt_lgselect," r"),0)
    CALL parser(concat("where r.child_service_resource_cd = ",cnvtstring(rec_cd)),0)
    CALL parser(" detail par_res_cnt = par_res_cnt + 1 stat=alterlist(res_cd->qual,par_res_cnt) ",0)
    CALL parser(" res_cd->qual[par_res_cnt].from_val=r.parent_service_resource_cd ",0)
    CALL parser(" res_cd->qual[par_res_cnt].active_ind = r.active_ind with nocounter go",1)
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET nodelete_ind = 1
     RETURN("No_Trans20")
    ENDIF
    FOR (res_rs_loop = 1 TO par_res_cnt)
     SET sbr_ret_value = select_merge_translate(cnvtstring(res_cd->qual[res_rs_loop].from_val),
      "CODE_VALUE")
     IF (sbr_ret_value != "No Trans")
      SET res_cd->qual[res_rs_loop].to_val = cnvtreal(sbr_ret_value)
      SET res_cd->qual[res_rs_loop].trans_ind = 1
      SET cv_parent_ind = 1
     ENDIF
    ENDFOR
   ENDIF
   IF (source_parent_ind=1)
    IF (cv_parent_ind=0)
     RETURN("No_Trans5")
    ELSE
     FOR (res_rs_loop = 1 TO par_res_cnt)
       IF ((res_cd->qual[res_rs_loop].trans_ind=1))
        CALL parser("select into 'nl:' from code_value cv where cv.display_key = ",0)
        CALL parser(concat("(select cv2.display_key from ",gt_select,
          " cv2 where cv2.code_set = 221 and cv2.code_value = ",cnvtstring(rec_cd),")"),0)
        CALL parser(" and cv.code_set = 221 and cv.code_value in (",0)
        CALL parser("select rt.child_service_resource_cd from resource_group rt ",0)
        CALL parser(concat("where rt.parent_service_resource_cd = ",cnvtstring(res_cd->qual[
           res_rs_loop].to_val)," and rt.active_ind = ",cnvtstring(res_cd->qual[res_rs_loop].
           active_ind),")"),0)
        CALL parser(
         "detail ui_rec_cnt = ui_rec_cnt + 1 ui_rec_cd = cnvtstring(cv.code_value) with nocounter go",
         0)
        IF (check_error(dm_err->eproc)=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         SET dm_err->err_ind = 0
         SET nodelete_ind = 1
         RETURN("No_Trans20")
        ENDIF
        IF (curqual > 0)
         SET res_rs_loop = par_res_cnt
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM code_value cv
     WHERE list(cv.display_key,cv.cdf_meaning) IN (
     (SELECT
      cv2.display_key, cv2.cdf_meaning
      FROM (value(gt_select) cv2)
      WHERE cv2.code_set=221
       AND cv2.code_value=rec_cd))
      AND cv.code_set=221
      AND  NOT (cv.code_value IN (
     (SELECT
      r.child_service_resource_cd
      FROM resource_group r
      WHERE r.child_service_resource_cd=cv.code_value)))
     DETAIL
      ui_rec_cd = cnvtstring(cv.code_value), ui_rec_cnt = (ui_rec_cnt+ 1)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET nodelete_ind = 1
     RETURN("No_Trans20")
    ENDIF
   ENDIF
   IF (ui_rec_cnt > 0)
    IF (ui_rec_cnt=1)
     RETURN(ui_rec_cd)
    ELSE
     RETURN("No_Trans6")
    ENDIF
   ELSE
    RETURN(cnvtstring(0))
   ENDIF
 END ;Subroutine
 SUBROUTINE get_target_image_class_cd(imc_cd)
   DECLARE ui_imc_cd = vc
   DECLARE ui_imc_cnt = i4
   DECLARE cv_parent_ind = i2
   DECLARE source_parent_ind = i2
   DECLARE lib_cd = f8
   DECLARE par_cd = f8
   DECLARE no_par_ind = i2
   DECLARE lib_trans_ind = i2
   DECLARE par_trans_ind = i2
   DECLARE to_lib = f8
   DECLARE to_par = f8
   DECLARE vc_lib = vc
   DECLARE vc_par = vc
   SET par_trans_ind = 0
   SET lib_trans_ind = 0
   SET no_par_ind = 0
   SET par_cd = 0
   SET lib_cd = 0
   SET ui_imc_cnt = 0
   SET source_parent_ind = 0
   SET cv_parent_ind = 0
   SET gt_select = concat(value(dm2_ref_data_doc->pre_link_name),"code_value",value(dm2_ref_data_doc
     ->post_link_name))
   SET gt_lgselect = concat(value(dm2_ref_data_doc->pre_link_name),"image_class_type",value(
     dm2_ref_data_doc->post_link_name))
   CALL parser(concat("select into 'nl:' from ",gt_lgselect," i where i.image_class_type_cd = ",
     cnvtstring(imc_cd)),0)
   CALL parser(
    "detail lib_cd = i.lib_group_cd par_cd = i.parent_image_class_type_cd with nocounter go",1)
   IF (par_cd=imc_cd)
    SET no_par_ind = 1
    SET par_trans_ind = 1
   ENDIF
   SET vc_lib = select_merge_translate(cnvtstring(lib_cd),"CODE_VALUE")
   IF (vc_lib != "No Trans")
    SET to_lib = cnvtreal(vc_lib)
    SET lib_trans_ind = 1
   ENDIF
   SET vc_par = select_merge_translate(cnvtstring(par_cd),"CODE_VALUE")
   IF (vc_par != "No Trans")
    SET to_par = cnvtreal(vc_par)
    SET par_trans_ind = 1
   ENDIF
   IF (lib_trans_ind=1)
    IF (par_trans_ind=1)
     SELECT INTO "nl:"
      FROM code_value cv
      WHERE list(cv.display_key,cv.description) IN (
      (SELECT
       cv2.display_key, cv2.description
       FROM (value(gt_select) cv2)
       WHERE cv2.code_set=5503
        AND cv2.code_value=imc_cd))
       AND cv.code_set=5503
       AND  EXISTS (
      (SELECT
       "x"
       FROM image_class_type ic
       WHERE ic.image_class_type_cd=cv.code_value
        AND ic.parent_image_class_type_cd=evaluate(no_par_ind,0,to_par,1,ic.image_class_type_cd)
        AND ic.lib_group_cd=to_lib))
      DETAIL
       ui_imc_cd = cnvtstring(cv.code_value), ui_imc_cnt = (ui_imc_cnt+ 1)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->err_ind = 0
      SET nodelete_ind = 1
      RETURN("No_Trans20")
     ENDIF
    ELSE
     RETURN("No_Trans7")
    ENDIF
   ELSE
    RETURN("No_Trans8")
   ENDIF
   IF (ui_imc_cnt != 0)
    IF (ui_imc_cnt=1)
     RETURN(ui_imc_cd)
    ELSE
     RETURN("No_Trans9")
    ENDIF
   ELSE
    RETURN(cnvtstring(0))
   ENDIF
 END ;Subroutine
 SUBROUTINE get_target_task_ref_cd(sbr_code)
   DECLARE ui_tr_cd = vc
   DECLARE ui_tr_cnt = i4
   DECLARE s_tr_gr_cd = f8
   DECLARE as_cd_cnt = i4
   DECLARE tr_gr_cd = f8
   DECLARE sbr_ret_val = vc
   SET ui_tr_cnt = 0
   SET inc_prelink = dm2_ref_data_doc->pre_link_name
   SET inc_postlink = dm2_ref_data_doc->post_link_name
   SET gt_select = concat(inc_prelink,"CODE_VALUE",inc_postlink)
   SELECT INTO "NL:"
    cv.code_value
    FROM (parser(gt_select) cv)
    WHERE cv.code_set=16370
     AND (cv.display=rs_619->from_values.definition)
    DETAIL
     ui_tr_cnt = (ui_tr_cnt+ 1), s_tr_gr_cd = cv.code_value
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
    RETURN("No_Trans20")
   ENDIF
   IF (ui_tr_cnt=1)
    SET sbr_ret_val = select_merge_translate(cnvtstring(tr_gr_cd),"CODE_VALUE")
    IF (sbr_ret_val != "No Trans")
     SET tr_gr_cd = cnvtreal(sbr_ret_val)
    ELSE
     SET ui_tr_cnt = 0
    ENDIF
   ENDIF
   IF (ui_tr_cnt=0)
    RETURN("No_Trans10")
   ELSEIF (ui_tr_cnt=1)
    SELECT INTO "NL:"
     FROM track_reference tr
     WHERE tr.tracking_group_cd=tr_gr_cd
      AND (tr.description=rs_619->from_values.description)
     DETAIL
      as_cd_cnt = (as_cd_cnt+ 1), ui_tr_cd = cnvtstring(tr.assoc_code_value)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET nodelete_ind = 1
     RETURN("No_Trans20")
    ENDIF
    IF (as_cd_cnt != 0)
     IF (as_cd_cnt=1)
      RETURN(ui_tr_cd)
     ELSE
      RETURN("No_Trans12")
     ENDIF
    ELSE
     RETURN(cnvtstring(0))
    ENDIF
   ELSE
    RETURN("No_Trans11")
   ENDIF
 END ;Subroutine
 SUBROUTINE get_target_dta(source_dta_code)
   DECLARE ui_dta_cd = f8
   DECLARE ui_cv_cnt = i4
   DECLARE ui_cv_cd = vc
   DECLARE src_act_cd = f8
   DECLARE src_act_cnt = i4
   DECLARE sbr_ret_val = vc
   SET src_act_cnt = 0
   SET ui_cv_cnt = 0
   SET inc_prelink = dm2_ref_data_doc->pre_link_name
   SET inc_postlink = dm2_ref_data_doc->post_link_name
   SET dta_select = concat(inc_prelink,"discrete_task_assay",inc_postlink)
   SET cv_select = concat(inc_prelink,"code_value",inc_postlink)
   SELECT INTO "NL:"
    dta.activity_type_cd
    FROM (parser(dta_select) dta)
    WHERE dta.task_assay_cd=source_dta_code
    DETAIL
     src_act_cd = dta.activity_type_cd
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
    RETURN("No_Trans20")
   ENDIF
   IF (src_act_cd > 0)
    SET sbr_ret_val = select_merge_translate(cnvtstring(src_act_cd),"CODE_VALUE")
    IF (sbr_ret_val != "No Trans")
     SET ui_dta_cd = cnvtreal(sbr_ret_val)
     SET src_act_cnt = 1
    ENDIF
   ELSE
    SET ui_dta_cd = 0
    SET src_act_cnt = 1
   ENDIF
   IF (src_act_cnt > 0)
    SELECT INTO "NL:"
     FROM code_value c,
      discrete_task_assay dta
     PLAN (c
      WHERE list(c.display_key,c.code_set) IN (
      (SELECT
       c1.display_key, c1.code_set
       FROM (parser(cv_select) c1)
       WHERE c1.code_value=source_dta_code)))
      JOIN (dta
      WHERE dta.task_assay_cd=c.code_value
       AND dta.activity_type_cd=ui_dta_cd)
     DETAIL
      ui_cv_cnt = (ui_cv_cnt+ 1), ui_cv_cd = cnvtstring(c.code_value)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET nodelete_ind = 1
     RETURN("No_Trans20")
    ENDIF
    IF (ui_cv_cnt=0)
     RETURN(cnvtstring(0))
    ELSEIF (ui_cv_cnt=1)
     RETURN(ui_cv_cd)
    ELSE
     RETURN("No_Trans14")
    ENDIF
   ELSE
    RETURN("No_Trans13")
   ENDIF
 END ;Subroutine
 SUBROUTINE get_target_oefields(source_oe_code)
   DECLARE ui_oe_cd = f8
   DECLARE ui_cv_cnt = i4
   DECLARE ui_cv_cd = vc
   DECLARE src_cat_cd = f8
   DECLARE src_cat_cnt = i4
   DECLARE sbr_ret_val = vc
   SET src_cat_cnt = 0
   SET ui_cv_cnt = 0
   SET inc_prelink = dm2_ref_data_doc->pre_link_name
   SET inc_postlink = dm2_ref_data_doc->post_link_name
   SET oe_select = concat(inc_prelink,"order_entry_fields",inc_postlink)
   SET cv_select = concat(inc_prelink,"code_value",inc_postlink)
   SELECT INTO "NL:"
    oe.catalog_type_cd
    FROM (parser(oe_select) oe)
    WHERE oe.oe_field_id=source_oe_code
    DETAIL
     src_cat_cd = oe.catalog_type_cd
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 0
    SET nodelete_ind = 1
    RETURN("No_Trans20")
   ENDIF
   IF (src_cat_cd > 0)
    SET sbr_ret_val = select_merge_translate(cnvtstring(src_cat_cd),"CODE_VALUE")
    IF (sbr_ret_val != "No Trans")
     SET ui_oe_cd = cnvtreal(sbr_ret_val)
     SET src_cat_cnt = 1
    ENDIF
   ELSE
    SET ui_oe_cd = 0
    SET src_cat_cnt = 1
   ENDIF
   IF (src_cat_cnt > 0)
    SELECT INTO "NL:"
     FROM code_value c,
      order_entry_fields oe
     PLAN (c
      WHERE list(c.display_key,c.code_set) IN (
      (SELECT
       c1.display_key, c1.code_set
       FROM (parser(cv_select) c1)
       WHERE c1.code_value=source_oe_code)))
      JOIN (oe
      WHERE oe.oe_field_id=c.code_value
       AND oe.catalog_type_cd=ui_oe_cd)
     DETAIL
      ui_cv_cnt = (ui_cv_cnt+ 1), ui_cv_cd = cnvtstring(c.code_value)
     WITH nocounter
    ;end select
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     SET dm_err->err_ind = 0
     SET nodelete_ind = 1
     RETURN("No_Trans20")
    ENDIF
    IF (ui_cv_cnt=0)
     RETURN(cnvtstring(0))
    ELSEIF (ui_cv_cnt=1)
     RETURN(ui_cv_cd)
    ELSE
     RETURN("No_Trans16")
    ENDIF
   ELSE
    RETURN("No_Trans15")
   ENDIF
 END ;Subroutine
 SUBROUTINE get_value(sbr_table,sbr_column,sbr_origin)
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_col_cnt = i4
   DECLARE sbr_data_type = vc
   DECLARE sbr_loop = i4
   DECLARE sbr_rs_name = vc
   DECLARE sbr_return = vc
   DECLARE dyn_origin = vc
   DECLARE sbr_error_name = vc
   SET sbr_tbl_cnt = 0
   SET sbr_col_cnt = 0
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != "")
    AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != " "))
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script
   ELSE
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name
   ENDIF
   SET sbr_col_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual,5),
    sbr_column,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name)
   IF (sbr_col_cnt=0)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_error_name,": The column",sbr_column,
     " doesn't exist.")
    RETURN("NO_COLUMN")
   ENDIF
   IF (cnvtupper(sbr_origin)="FROM")
    SET dyn_origin = "FROM"
   ELSEIF (cnvtupper(sbr_origin)="TO")
    SET dyn_origin = "TO"
   ELSE
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_error_name,": Invalid origin passed in.")
    RETURN("INVALID_ORIGIN")
   ENDIF
   SET sbr_data_type = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_col_cnt].data_type
   SET sbr_rs_name = concat(" RS_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix)
   CASE (sbr_data_type)
    OF "VC":
     CALL parser(concat("set sbr_return = ",sbr_rs_name,"->",dyn_origin,"_values.",
       sbr_column," go"),1)
    OF "DQ8":
     CALL parser(concat("set sbr_return = cnvtstring(",sbr_rs_name,"->",dyn_origin,"_values.",
       sbr_column,") go"),1)
    OF "I4":
     CALL parser(concat("set sbr_return = cnvtstring(",sbr_rs_name,"->",dyn_origin,"_values.",
       sbr_column,") go"),1)
    OF "F8":
     CALL parser(concat("set sbr_return = cnvtstring(",sbr_rs_name,"->",dyn_origin,"_values.",
       sbr_column,") go"),1)
    ELSE
     CALL parser(concat("set sbr_return = ",sbr_rs_name,"->",dyn_origin,"_values.",
       sbr_column," go"),1)
   ENDCASE
   FREE SET sbr_tbl_cnt
   FREE SET sbr_col_cnt
   FREE SET sbr_data_type
   FREE SET sbr_loop
   FREE SET sbr_rs_name
   FREE SET dyn_origin
   FREE SET sbr_error_name
   RETURN(sbr_return)
 END ;Subroutine
 SUBROUTINE get_nullind(sbr_table,sbr_column)
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_col_cnt = i4
   DECLARE sbr_data_type = vc
   DECLARE sbr_loop = i4
   DECLARE sbr_rs_name = vc
   DECLARE sbr_return = i2
   DECLARE sbr_error_name = vc
   SET sbr_tbl_cnt = 0
   SET sbr_col_cnt = 0
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != "")
    AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != " "))
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script
   ELSE
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name
   ENDIF
   SET sbr_col_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual,5),
    sbr_column,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name)
   IF (sbr_col_cnt=0)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_error_name,
     ": The column passed in to the GET_NULLIND sub isn't valid.")
    RETURN(- (1))
   ENDIF
   SET sbr_return = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_col_cnt].check_null
   FREE SET sbr_tbl_cnt
   FREE SET sbr_col_cnt
   FREE SET sbr_data_type
   FREE SET sbr_loop
   FREE SET sbr_rs_name
   FREE SET sbr_error_name
   RETURN(sbr_return)
 END ;Subroutine
 SUBROUTINE put_value(sbr_table,sbr_column,sbr_value)
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_col_cnt = i4
   DECLARE sbr_data_type = vc
   DECLARE sbr_loop = i4
   DECLARE sbr_rs_name = vc
   DECLARE sbr_error_name = vc
   SET sbr_tbl_cnt = 0
   SET sbr_col_cnt = 0
   IF (sbr_value="")
    SET sbr_value = "0"
   ENDIF
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != "")
    AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != " "))
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script
   ELSE
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name
   ENDIF
   SET sbr_col_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual,5),
    sbr_column,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name)
   IF (sbr_col_cnt=0)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_error_name,":",sbr_column,
     " doesn't exist on this table.")
    RETURN("NO_COLUMN")
   ENDIF
   SET sbr_data_type = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_col_cnt].data_type
   SET sbr_rs_name = concat(" RS_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix)
   SET dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_col_cnt].translated = 1
   CASE (sbr_data_type)
    OF "VC":
     CALL parser(concat("set ",sbr_rs_name,"->to_values.",sbr_column," = '",
       sbr_value,"' go"),1)
    OF "DQ8":
     CALL parser(concat("set ",sbr_rs_name,"->to_values.",sbr_column," = ",
       sbr_value," go"),1)
    OF "I4":
     CALL parser(concat("set ",sbr_rs_name,"->to_values.",sbr_column," = ",
       sbr_value," go"),1)
    OF "F8":
     CALL parser(concat("set ",sbr_rs_name,"->to_values.",sbr_column," = ",
       sbr_value," go"),1)
    ELSE
     CALL parser(concat("set ",sbr_rs_name,"->to_values.",sbr_column," = '",
       sbr_value,"' go"),1)
   ENDCASE
   FREE SET sbr_tbl_cnt
   FREE SET sbr_col_cnt
   FREE SET sbr_data_type
   FREE SET sbr_loop
   FREE SET sbr_rs_name
   FREE SET sbr_error_name
 END ;Subroutine
 SUBROUTINE is_translated(sbr_table,sbr_column)
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_col_cnt = i4
   DECLARE sbr_loop = i4
   DECLARE sbr_trans_ind = i2
   DECLARE sbr_err_msg = vc
   DECLARE sbr_rpt_orphan_ind = i2
   DECLARE skip_for_orphan_ind = i2
   SET sbr_trans_ind = 1
   SET sbr_tbl_cnt = 0
   SET sbr_col_cnt = 0
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF (sbr_tbl_cnt=0)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_table," is not a valid table name.")
    SET sbr_trans_ind = 0
   ELSE
    IF (sbr_column="ALL")
     SET sbr_rpt_orphan_ind = 0
     SET sbr_col_cnt = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt
     FOR (sbr_loop = 1 TO sbr_col_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].idcd_ind=1))
        IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].translated=0))
         SET skip_for_orphan_ind = 0
         IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[sbr_loop].parent_entity_col != ""))
          DECLARE rpt_col_value = vc
          DECLARE rpt_fnd = i4
          DECLARE rpt_srch = i4
          DECLARE rpt_parent_col = vc
          DECLARE rpt_i_domain = vc
          DECLARE rpt_i_name = vc
          DECLARE rpt_data_type = vc
          DECLARE rpt_col_pos = i4
          DECLARE rpt_mult_cnt = i4
          SET rpt_fnd = locateval(rpt_srch,1,size(rdds_exception->qual,5),dm2_ref_data_doc->tbl_qual[
           sbr_tbl_cnt].col_qual[sbr_loop].column_name,rdds_exception->qual[rpt_srch].tab_col_name)
          IF (rpt_fnd > 0)
           IF ((rdds_exception->qual[rpt_fnd].tru_tab_name="INVALID")
            AND (rdds_exception->qual[rpt_fnd].tru_col_name="INVALID"))
            SET rpt_table = ""
            SET rpt_column = ""
            SET rpt_from = 0
           ELSE
            SET rpt_table = rdds_exception->qual[rpt_fnd].tru_tab_name
            SET rpt_column = rdds_exception->qual[rpt_fnd].tru_col_name
            CALL parser(concat("set rpt_from = RS_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix,
              "->from_values.",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name,
              " go"),1)
           ENDIF
          ELSE
           SET rpt_col_value = value(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].
            parent_entity_col)
           CALL parser(concat("set rpt_from = RS_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix,
             "->from_values.",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name,
             " go"),1)
           SET rpt_col_pos = locateval(rpt_srch,1,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt,
            rpt_col_value,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[rpt_srch].column_name)
           IF (rpt_col_pos > 0)
            SET rpt_data_type = value(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[rpt_col_pos].
             data_type)
            IF (rpt_data_type IN ("VC", "C*"))
             SET rpt_fnd = 0
             SET rpt_fnd = locateval(rpt_srch,1,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt,
              rpt_col_value,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[rpt_srch].column_name)
             IF (rpt_fnd != 0)
              CALL parser(concat("set rpt_parent_col = cnvtupper(RS_",dm2_ref_data_doc->tbl_qual[
                sbr_tbl_cnt].suffix,"->from_values.",rpt_col_value,") go"),1)
              IF (rpt_parent_col != ""
               AND rpt_parent_col != " ")
               SET rpt_parent_col = find_p_e_col(rpt_parent_col,sbr_loop)
              ELSE
               SET rpt_i_domain = concat("RDDS_PE_ABBREV:",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].
                table_name)
               SET rpt_i_name = concat(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].
                column_name,":",rpt_parent_col)
               SELECT INTO "NL:"
                FROM dm_info d
                WHERE d.info_domain=rpt_i_domain
                 AND d.info_name=rpt_i_name
                DETAIL
                 rpt_parent_col = d.info_char
                WITH nocounter
               ;end select
              ENDIF
             ENDIF
            ENDIF
           ENDIF
           IF (rpt_parent_col != "INVALIDTABLE"
            AND rpt_parent_col != "")
            SET rpt_table = rpt_parent_col
            SET rpt_fnd = locateval(rpt_srch,1,dguc_reply->rs_tbl_cnt,rpt_table,dguc_reply->dtd_hold[
             rpt_srch].tbl_name)
            IF (rpt_fnd != 0)
             IF ((dguc_reply->dtd_hold[rpt_fnd].pk_cnt >= 1))
              SET rpt_srch = 0
              FOR (rpt_mult_cnt = 1 TO dguc_reply->dtd_hold[rpt_fnd].pk_cnt)
                IF ((((dguc_reply->dtd_hold[rpt_fnd].pk_hold[rpt_mult_cnt].pk_name="*ID")) OR ((((
                dguc_reply->dtd_hold[rpt_fnd].pk_hold[rpt_mult_cnt].pk_name="*CD")) OR ((dguc_reply->
                dtd_hold[rpt_fnd].pk_hold[rpt_mult_cnt].pk_name="CODE_VALUE"))) )) )
                 IF ((((dguc_reply->dtd_hold[rpt_fnd].pk_hold[rpt_mult_cnt].pk_name="*ID")) OR ((
                 dguc_reply->dtd_hold[rpt_fnd].pk_hold[rpt_mult_cnt].pk_name="CODE_VALUE"))) )
                  SET rpt_column = dguc_reply->dtd_hold[rpt_fnd].pk_hold[rpt_mult_cnt].pk_name
                  SET rpt_srch = (rpt_srch+ 1)
                 ENDIF
                ENDIF
              ENDFOR
             ENDIF
             IF (rpt_srch > 1)
              SET rpt_column = ""
             ENDIF
            ENDIF
           ENDIF
          ENDIF
         ELSEIF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].root_entity_name != ""))
          DECLARE rpt_fnd = i4
          DECLARE rpt_srch = i4
          SET rpt_fnd = locateval(rpt_srch,1,size(rdds_exception->qual,5),dm2_ref_data_doc->tbl_qual[
           sbr_tbl_cnt].col_qual[sbr_loop].column_name,rdds_exception->qual[rpt_srch].tab_col_name)
          IF (rpt_fnd > 0)
           IF ((rdds_exception->qual[rpt_fnd].tru_tab_name="INVALID")
            AND (rdds_exception->qual[rpt_fnd].tru_col_name="INVALID"))
            SET rpt_table = ""
            SET rpt_column = ""
            SET rpt_from = 0
           ELSE
            SET rpt_table = rdds_exception->qual[rpt_fnd].tru_tab_name
            SET rpt_column = rdds_exception->qual[rpt_fnd].tru_col_name
            CALL parser(concat("set rpt_from = RS_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix,
              "->from_values.",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name,
              " go"),1)
           ENDIF
          ELSE
           SET rpt_table = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].
           root_entity_name
           SET rpt_column = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].
           root_entity_attr
           CALL parser(concat("set rpt_from = RS_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix,
             "->from_values.",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name,
             " go"),1)
          ENDIF
         ENDIF
         SET rpt_missing = ""
         IF (rpt_table != ""
          AND rpt_from != 0)
          SET rpt_missing = report_missing(rpt_table,rpt_column,rpt_from)
         ENDIF
         IF (rpt_missing="ORPHAN")
          IF ((((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].unique_ident_ind=1)) OR (
          (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].pk_ind=1))) )
           SET sbr_rpt_orphan_ind = 1
           SET dm2_ref_data_reply->error_ind = 1
           SET dm2_ref_data_reply->error_msg = concat(rpt_missing," - ",dm2_ref_data_doc->tbl_qual[
            sbr_tbl_cnt].col_qual[sbr_loop].column_name)
           SET sbr_err_msg = concat(rpt_missing," - ",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].
            col_qual[sbr_loop].column_name)
           SET sbr_loop = sbr_col_cnt
          ELSE
           SET dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].translated = 1
           CALL parser(concat("set rs_",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].suffix,"->to_values.",
             dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name," = 0 go"),1)
           SET skip_for_orphan_ind = 1
          ENDIF
         ELSEIF (rpt_missing="OLDVER")
          SET dm2_ref_data_reply->error_ind = 1
          SET dm2_ref_data_reply->error_msg = rpt_missing
          SET sbr_err_msg = concat("This log_id ",
           "wasn't translated because there was no translation for the ",dm2_ref_data_doc->tbl_qual[
           sbr_tbl_cnt].col_qual[sbr_loop].column_name," column.")
          SET sbr_loop = sbr_col_cnt
         ELSE
          SET dm2_ref_data_reply->error_ind = 1
          SET dm2_ref_data_reply->error_msg = concat("This log_id ",
           "wasn't translated because not all columns were translated.")
          SET sbr_err_msg = concat("This log_id ",
           "wasn't translated because there was no translation for the ",dm2_ref_data_doc->tbl_qual[
           sbr_tbl_cnt].col_qual[sbr_loop].column_name," column.")
         ENDIF
         IF (skip_for_orphan_ind=0)
          CALL echo("")
          CALL echo("")
          CALL echo(sbr_err_msg)
          CALL echo("")
          CALL echo("")
          ROLLBACK
          CALL merge_audit("FAILREASON",sbr_err_msg)
          IF (drdm_error_out_ind=1)
           ROLLBACK
          ELSE
           COMMIT
          ENDIF
          SET sbr_trans_ind = 0
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
    ELSEIF (sbr_column="UNIQUE")
     SET sbr_col_cnt = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt
     FOR (sbr_loop = 1 TO sbr_col_cnt)
       IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].unique_ident_ind=1))
        IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].idcd_ind=1))
         IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].translated=0))
          SET dm2_ref_data_reply->error_ind = 1
          SET dm2_ref_data_reply->error_msg = concat("This log_id ",
           "wasn't translated because of the ",dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[
           sbr_loop].column_name," column.")
          SET sbr_trans_ind = 0
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
    ELSE
     SET sbr_col_cnt = locateval(sbr_loop,1,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt,
      sbr_column,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name)
     IF (sbr_col_cnt=0)
      SET dm2_ref_data_reply->error_ind = 1
      SET dm2_ref_data_reply->error_msg = concat(sbr_column," is not on the ",sbr_table," table.")
      SET sbr_trans_ind = 0
     ELSE
      IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_col_cnt].translated=0))
       SET sbr_trans_ind = 0
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   FREE SET sbr_tbl_cnt
   FREE SET sbr_col_cnt
   FREE SET sbr_loop
   RETURN(sbr_trans_ind)
 END ;Subroutine
 SUBROUTINE get_seq(sbr_table,sbr_column)
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_col_cnt = i4
   DECLARE sbr_loop = i4
   DECLARE sbr_ret_val = f8
   DECLARE sbr_error_name = vc
   SET sbr_tbl_cnt = 0
   SET sbr_col_cnt = 0
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != "")
    AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != " "))
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script
   ELSE
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name
   ENDIF
   SET sbr_col_cnt = locateval(sbr_loop,1,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt,sbr_column,
    dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name)
   IF (sbr_col_cnt=0)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_error_name,":",sbr_column," is not on the ",
     sbr_table,
     " table.")
    CALL echo("")
    CALL echo("")
    CALL echo(dm2_ref_data_reply->error_msg)
    CALL echo("")
    CALL echo("")
    RETURN(- (1))
   ENDIF
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_col_cnt].sequence_name != ""))
    CALL parser("select into 'nl:' y = seq(",0)
    CALL parser(concat(dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_col_cnt].sequence_name,
      ", nextval) from dual detail sbr_ret_val = y with nocounter go"),1)
    SET new_seq_ind = 1
   ELSE
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_error_name,":",sbr_column,
     " does not have a valid sequence")
    CALL echo("")
    CALL echo("")
    CALL echo(dm2_ref_data_reply->error_msg)
    CALL echo("")
    CALL echo("")
    RETURN(- (1))
   ENDIF
   FREE SET sbr_tbl_cnt
   FREE SET sbr_col_cnt
   FREE SET sbr_loop
   FREE SET sbr_error_name
   RETURN(sbr_ret_val)
 END ;Subroutine
 SUBROUTINE get_col_pos(sbr_table,sbr_column)
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_col_cnt = i4
   DECLARE sbr_loop = i4
   DECLARE sbr_error_name = vc
   SET sbr_tbl_cnt = 0
   SET sbr_col_cnt = 0
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF ((dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != "")
    AND (dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script != " "))
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].custom_script
   ELSE
    SET sbr_error_name = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].table_name
   ENDIF
   SET sbr_col_cnt = locateval(sbr_loop,1,dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt,sbr_column,
    dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_qual[sbr_loop].column_name)
   IF (sbr_col_cnt=0)
    SET dm2_ref_data_reply->error_ind = 1
    SET dm2_ref_data_reply->error_msg = concat(sbr_error_name,":",sbr_column," is not on the ",
     sbr_table,
     " table.")
   ENDIF
   FREE SET sbr_tbl_cnt
   FREE SET sbr_loop
   RETURN(sbr_col_cnt)
 END ;Subroutine
 SUBROUTINE get_primary_key(sbr_table)
   DECLARE sbr_col_cnt = i4
   DECLARE sbr_return = vc
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_loop = i4
   SET sbr_return = ""
   SET sbr_tbl_cnt = 0
   SET sbr_col_cnt = 0
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF (sbr_tbl_cnt=0)
    RETURN("")
   ENDIF
   SET sbr_col_cnt = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(sbr_col_cnt))
    DETAIL
     IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name=dm2_ref_data_doc->
     tbl_qual[temp_tbl_cnt].col_qual[d.seq].root_entity_attr)
      AND (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].table_name=dm2_ref_data_doc->tbl_qual[
     temp_tbl_cnt].col_qual[d.seq].root_entity_name))
      sbr_return = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name
     ENDIF
    WITH nocounter
   ;end select
   FREE SET sbr_col_cnt
   FREE SET sbr_tbl_cnt
   FREE SET sbr_loop
   RETURN(sbr_return)
 END ;Subroutine
 SUBROUTINE check_ui_exist(sbr_table_name)
   DECLARE sbr_return = i2
   DECLARE sbr_tbl_cnt = i4
   DECLARE sbr_loop = i4
   DECLARE sbr_col_cnt = i4
   SET sbr_tbl_cnt = locateval(sbr_loop,1,size(dm2_ref_data_doc->tbl_qual,5),sbr_table_name,
    dm2_ref_data_doc->tbl_qual[sbr_loop].table_name)
   IF (sbr_tbl_cnt=0)
    RETURN(0)
   ENDIF
   SET sbr_return = 0
   SET sbr_col_cnt = dm2_ref_data_doc->tbl_qual[sbr_tbl_cnt].col_cnt
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(sbr_col_cnt))
    DETAIL
     IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].unique_ident_ind=1))
      sbr_return = 1
     ENDIF
    WITH nocounter
   ;end select
   FREE SET sbr_col_cnt
   FREE SET sbr_tbl_cnt
   FREE SET sbr_loop
   RETURN(sbr_return)
 END ;Subroutine
 SET trace = nowarning
 IF (validate(dm2_db_options->lob_build_ind," ")=" ")
  FREE RECORD dm2_db_options
  RECORD dm2_db_options(
    1 load_ind = i2
    1 dm2_toolset_usage = vc
    1 cursor_commit_cnt = vc
    1 new_tspace_type = vc
    1 dmt_freelist_grp = vc
    1 lob_storage_bp = vc
    1 lob_pctversion = vc
    1 lob_build_ind = vc
    1 lob_chunk = vc
    1 lob_cache = vc
  )
  SET dm2_db_options->load_ind = 0
  SET dm2_db_options->dm2_toolset_usage = "NOT_SET"
  SET dm2_db_options->cursor_commit_cnt = "NOT_SET"
  SET dm2_db_options->dmt_freelist_grp = "NOT_SET"
  SET dm2_db_options->lob_pctversion = "NOT_SET"
  SET dm2_db_options->lob_chunk = "NOT_SET"
  SET dm2_db_options->lob_cache = "NOT_SET"
  SET dm2_db_options->lob_build_ind = "NOT_SET"
  SET dm2_db_options->new_tspace_type = "NOT_SET"
  SET dm2_db_options->lob_storage_bp = "NOT_SET"
 ENDIF
 IF (validate(dm_err->ecode,- (1)) < 0)
  FREE RECORD dm_err
  IF (currev >= 8)
   RECORD dm_err(
     1 logfile = vc
     1 debug_flag = i2
     1 ecode = i4
     1 emsg = vc
     1 eproc = vc
     1 err_ind = i2
     1 user_action = vc
     1 asterisk_line = c80
     1 tempstr = vc
     1 errfile = vc
     1 errtext = vc
     1 unique_fname = vc
     1 disp_msg_emsg = vc
   )
  ELSE
   RECORD dm_err(
     1 logfile = vc
     1 debug_flag = i2
     1 ecode = i4
     1 emsg = c132
     1 eproc = vc
     1 err_ind = i2
     1 user_action = vc
     1 asterisk_line = c80
     1 tempstr = vc
     1 errfile = vc
     1 errtext = vc
     1 unique_fname = vc
     1 disp_msg_emsg = vc
   )
  ENDIF
  SET dm_err->asterisk_line = fillstring(80,"*")
  SET dm_err->ecode = 0
  IF (validate(dm2_debug_flag,- (1)) > 0)
   SET dm_err->debug_flag = dm2_debug_flag
  ELSE
   SET dm_err->debug_flag = 0
  ENDIF
  SET dm_err->err_ind = 0
  SET dm_err->user_action = "NONE"
  SET dm_err->tempstr = " "
  SET dm_err->errfile = "NONE"
  SET dm_err->logfile = "NONE"
  SET dm_err->unique_fname = "NONE"
 ENDIF
 IF (validate(dm2_install_schema->process_option," ")=" ")
  FREE RECORD dm2_install_schema
  RECORD dm2_install_schema(
    1 process_option = vc
    1 file_prefix = vc
    1 schema_loc = vc
    1 schema_prefix = vc
    1 target_dbase_name = vc
    1 dbase_name = vc
    1 u_name = vc
    1 p_word = vc
    1 connect_str = vc
    1 v500_p_word = vc
    1 v500_connect_str = vc
    1 cdba_p_word = vc
    1 cdba_connect_str = vc
    1 run_id = i4
    1 menu_driver = vc
    1 oragen3_ignore_dm_columns_doc = i2
    1 last_checkpoint = vc
    1 gen_id = i4
    1 restart_method = i2
    1 appl_id = vc
    1 hostname = vc
    1 ccluserdir = vc
    1 cer_install = vc
    1 servername = vc
    1 frmt_servername = vc
    1 default_fg_name = vc
    1 curprog = vc
    1 adl_username = vc
    1 tgt_sch_cleanup = i2
    1 special_ih_process = i2
    1 dbase_type = vc
    1 data_to_move = c30
    1 percent_tspace = i4
    1 src_dbase_name = vc
    1 src_v500_p_word = vc
    1 src_v500_connect_str = vc
    1 logfile_prefix = vc
    1 src_run_id = f8
    1 src_op_id = f8
    1 target_env_name = vc
    1 dm2_updt_task_value = i2
  )
  SET dm2_install_schema->process_option = "NONE"
  SET dm2_install_schema->file_prefix = "NONE"
  SET dm2_install_schema->schema_loc = "NONE"
  SET dm2_install_schema->schema_prefix = "NONE"
  SET dm2_install_schema->target_dbase_name = "NONE"
  SET dm2_install_schema->dbase_name = "NONE"
  SET dm2_install_schema->u_name = "NONE"
  SET dm2_install_schema->p_word = "NONE"
  SET dm2_install_schema->connect_str = "NONE"
  SET dm2_install_schema->v500_p_word = "NONE"
  SET dm2_install_schema->v500_connect_str = "NONE"
  SET dm2_install_schema->cdba_p_word = "NONE"
  SET dm2_install_schema->cdba_connect_str = "NONE"
  SET dm2_install_schema->run_id = 0
  SET dm2_install_schema->menu_driver = "NONE"
  SET dm2_install_schema->oragen3_ignore_dm_columns_doc = 0
  SET dm2_install_schema->last_checkpoint = "NONE"
  SET dm2_install_schema->gen_id = 0
  SET dm2_install_schema->restart_method = 0
  SET dm2_install_schema->appl_id = "NONE"
  SET dm2_install_schema->hostname = "NONE"
  SET dm2_install_schema->servername = "NONE"
  SET dm2_install_schema->default_fg_name = "NONE"
  SET dm2_install_schema->curprog = "NONE"
  SET dm2_install_schema->adl_username = "NONE"
  SET dm2_install_schema->tgt_sch_cleanup = 0
  SET dm2_install_schema->special_ih_process = 0
  SET dm2_install_schema->dbase_type = "NONE"
  SET dm2_install_schema->data_to_move = "NONE"
  SET dm2_install_schema->percent_tspace = 0
  SET dm2_install_schema->src_dbase_name = "NONE"
  SET dm2_install_schema->src_v500_p_word = "NONE"
  SET dm2_install_schema->src_v500_connect_str = "NONE"
  SET dm2_install_schema->logfile_prefix = "NONE"
  SET dm2_install_schema->src_run_id = 0
  SET dm2_install_schema->src_op_id = 0
  SET dm2_install_schema->target_env_name = "NONE"
  SET dm2_install_schema->dm2_updt_task_value = 15301
  IF (cursys="AIX")
   SET dm2_install_schema->ccluserdir = build(logical("ccluserdir"),"/")
   SET dm2_install_schema->cer_install = build(logical("cer_install"),"/")
  ELSEIF (cursys="WIN")
   SET dm2_install_schema->ccluserdir = build(logical("ccluserdir"),"\")
   SET dm2_install_schema->cer_install = build(logical("cer_install"),"\")
  ELSE
   SET dm2_install_schema->ccluserdir = logical("ccluserdir")
   SET dm2_install_schema->cer_install = logical("cer_install")
  ENDIF
 ENDIF
 IF (validate(dm2_common1->snapshot_id,5)=5)
  FREE RECORD dm2_common1
  RECORD dm2_common1(
    1 snapshot_id = i2
  )
  SET dm2_common1->snapshot_id = 0
 ENDIF
 IF (validate(retrieve_data->result_status,- (1)) < 0)
  FREE RECORD retrieve_data
  RECORD retrieve_data(
    1 result_str = vc
    1 result_status = i2
  )
  SET retrieve_data->result_status = 0
  SET retrieve_data->result_str = " "
 ENDIF
 IF (validate(db2_node_info->node_fnd,- (1)) < 0)
  FREE RECORD db2_node_info
  RECORD db2_node_info(
    1 node_fnd = i2
    1 node_name = vc
    1 protocol_fnd = i2
    1 protocol = vc
    1 hostname_fnd = i2
    1 hostname = vc
    1 service_name_fnd = i2
    1 service_name = vc
  )
  SET db2_node_info->node_fnd = 0
  SET db2_node_info->protocol_fnd = 0
  SET db2_node_info->hostname_fnd = 0
  SET db2_node_info->service_name_fnd = 0
  SET db2_node_info->node_name = " "
  SET db2_node_info->protocol = "-"
  SET db2_node_info->hostname = "-"
  SET db2_node_info->service_name = "-"
 ENDIF
 IF (validate(db2_dbase_info->dbase_fnd,- (1)) < 0)
  FREE RECORD db2_dbase_info
  RECORD db2_dbase_info(
    1 dbase_fnd = i2
    1 alias = vc
    1 dbase_name_fnd = i2
    1 dbase_name = vc
    1 node_name_fnd = i2
    1 node_name = vc
    1 dir_entry_ty_fnd = i2
    1 dir_entry_ty = vc
    1 authen_fnd = i2
    1 authen = vc
    1 ctlg_nd_nbr_fnd = i2
    1 ctlg_nd_nbr = vc
  )
  SET db2_dbase_info->dbase_fnd = 0
  SET db2_dbase_info->dbase_name_fnd = 0
  SET db2_dbase_info->node_name_fnd = 0
  SET db2_dbase_info->dir_entry_ty_fnd = 0
  SET db2_dbase_info->authen_fnd = 0
  SET db2_dbase_info->ctlg_nd_nbr_fnd = 0
  SET db2_dbase_info->alias = " "
  SET db2_dbase_info->dbase_name = "-"
  SET db2_dbase_info->node_name = "-"
  SET db2_dbase_info->dir_entry_ty = "-"
  SET db2_dbase_info->authen = "-"
  SET db2_dbase_info->ctlg_nd_nbr = "-"
 ENDIF
 IF (validate(dm2_sch_except->tcnt,- (1)) < 0)
  FREE RECORD dm2_sch_except
  RECORD dm2_sch_except(
    1 tcnt = i4
    1 tbl[*]
      2 tbl_name = vc
    1 seq_cnt = i4
    1 seq[*]
      2 seq_name = vc
  )
  SET dm2_sch_except->tcnt = 0
  SET dm2_sch_except->seq_cnt = 0
 ENDIF
 IF (validate(db2_table->full_table_name,- (1)) < 0)
  FREE RECORD dm2_table
  RECORD dm2_table(
    1 full_table_name = vc
    1 suffixed_table_name = vc
    1 table_suffix = vc
  )
  SET dm2_table->full_table_name = " "
  SET dm2_table->suffixed_table_name = " "
  SET dm2_table->table_suffix = " "
 ENDIF
 IF (validate(inhouse_misc->inhouse_domain,- (1)) < 0)
  FREE RECORD inhouse_misc
  RECORD inhouse_misc(
    1 inhouse_domain = i2
    1 fk_err_ind = i2
    1 nonfk_err_ind = i2
    1 fk_parent_table = vc
    1 tablespace_err_code = f8
    1 foreignkey_err_code = f8
  )
  SET inhouse_misc->inhouse_domain = 0
  SET inhouse_misc->fk_err_ind = 0
  SET inhouse_misc->nonfk_err_ind = 0
  SET inhouse_misc->fk_parent_table = ""
  SET inhouse_misc->tablespace_err_code = 93
  SET inhouse_misc->foreignkey_err_code = 94
 ENDIF
 IF (validate(dm2_rdbms_version->level1,- (1)) < 0)
  FREE RECORD dm2_rdbms_version
  RECORD dm2_rdbms_version(
    1 version = vc
    1 level1 = i2
    1 level2 = i2
    1 level3 = i2
    1 level4 = i2
    1 level5 = i2
  )
  CASE (currdb)
   OF "ORACLE":
    SET dm2_rdbms_version->level1 = 0
    SET dm2_rdbms_version->level2 = 0
    SET dm2_rdbms_version->level3 = 0
    SET dm2_rdbms_version->level4 = 0
    SET dm2_rdbms_version->level5 = 0
   OF "DB2":
    SET dm2_rdbms_version->level1 = 8
    SET dm2_rdbms_version->level2 = 1
    SET dm2_rdbms_version->level3 = 2
    SET dm2_rdbms_version->level4 = 0
    SET dm2_rdbms_version->level5 = 0
   OF "SQLSRV":
    SET dm2_rdbms_version->level1 = 2000
    SET dm2_rdbms_version->level2 = 8
    SET dm2_rdbms_version->level3 = 0
    SET dm2_rdbms_version->level4 = 194
    SET dm2_rdbms_version->level5 = 0
  ENDCASE
 ENDIF
 IF (validate(dm2_dft_extsize,- (1)) < 0)
  DECLARE dm2_dft_extsize = i4 WITH public, constant(163840)
  DECLARE dm2_dft_clin_tspace = vc WITH public, constant("D_A_SMALL")
  DECLARE dm2_dft_clin_itspace = vc WITH public, constant("I_A_SMALL")
  DECLARE dm2_dft_clin_ltspace = vc WITH public, constant("L_A_SMALL")
 ENDIF
 DECLARE dm2_push_cmd(sbr_dpcstr=vc,sbr_cmd_end=i2) = i2
 DECLARE dm2_push_dcl(sbr_dpdstr=vc) = i2
 DECLARE get_unique_file(sbr_fprefix=vc,sbr_fext=vc) = i2
 DECLARE parse_errfile(sbr_errfile=vc) = i2
 DECLARE check_error(sbr_ceprocess=vc) = i2
 DECLARE disp_msg(sbr_demsg=vc,sbr_dlogfile=vc,sbr_derr_ind=i2) = null
 DECLARE init_logfile(sbr_logfile=vc,sbr_header_msg=vc) = i2
 DECLARE dm2_val_sch_date_str(sbr_datestr=vc) = i2
 DECLARE dm2_push_adm_maint(sbr_maint_str=vc) = i2
 DECLARE check_logfile(sbr_lprefix=vc,sbr_lext=vc,sbr_hmsg=vc) = i2
 DECLARE val_user_privs(sbr_dummy_param=i2) = i2
 DECLARE final_disp_msg(sbr_log_prefix=vc) = null
 DECLARE validate_node_info(sbr_nname=vc,sbr_ni_ignore_err=i2) = i2
 DECLARE validate_dbase_info(sbr_vi_dbase=vc,sbr_vi_ignore_err=i2) = i2
 DECLARE retrieve_data(sbr_srch_str=vc,sbr_sprtr=vc,sbr_rd_str=vc) = i2
 DECLARE db2_push_dcl_w_connect(sbr_dwc_dbase=vc,sbr_dwc_user=vc,sbr_dwc_user_pwd=vc,sbr_dwc_str=vc,
  sbr_dwc_commit_ind=i2) = i2
 DECLARE dm2parse_output(sbr_attr_nbr=i4,sbr_parse_fname=vc,sbr_orientation=vc) = i2
 DECLARE dm2_fill_sch_except(sbr_dfse_from=vc) = i2
 DECLARE dm2_system_defs_init(sbr_sdi_regen_ind=i2) = i2
 DECLARE dm2_get_appl_status(gas_appl_id=vc) = c1
 DECLARE dm2_cleanup_stranded_appl() = i2
 DECLARE dm2_table_exists(dte_table_name=vc) = c1
 DECLARE dm2_set_autocommit(sbr_dsa_flag=i2) = i2
 DECLARE dm2_get_srvname(sbr_spc_view=i2) = i2
 DECLARE dm2_prg_maint(sbr_maint_type=vc) = i2
 DECLARE dm2_fill_nick_except(sbr_alias=vc) = vc
 DECLARE prompt_for_host(sbr_host_db=vc) = i2
 DECLARE dm2_val_file_prefix(sbr_file_prefix=vc) = i2
 DECLARE dm2_validate_dblink(vdl_linkname=vc) = i2
 DECLARE dm2_include_exclude_list() = vc
 DECLARE dm2_get_rdbms_version() = i2
 DECLARE dm2_set_inhouse_domain() = i2
 DECLARE dm2_set_nn_default(dsn_datatype=vc) = vc
 DECLARE dm2_findfile(sbr_file_path=vc) = i2
 DECLARE dm2_setup_dbase_env(null) = i2
 DECLARE dm2ceil(dc_numin) = null
 DECLARE dm2floor(dc_numin) = null
 DECLARE dm2_toolset_usage(null) = i2
 SUBROUTINE dm2_push_cmd(sbr_dpcstr,sbr_cmd_end)
   IF ((dm_err->debug_flag > 0))
    CALL echo("*")
    CALL echo(concat("dm2_push_cmd executing: ",sbr_dpcstr))
    CALL echo("*")
   ENDIF
   CALL parser(sbr_dpcstr,1)
   SET dm_err->tempstr = concat(dm_err->tempstr," ",sbr_dpcstr)
   IF (sbr_cmd_end=1)
    IF ((dm_err->err_ind=0))
     IF (check_error(concat("dm2_push_cmd executing: ",dm_err->tempstr))=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      SET dm_err->tempstr = " "
      RETURN(0)
     ENDIF
    ENDIF
    SET dm_err->tempstr = " "
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_push_dcl(sbr_dpdstr)
   DECLARE dpd_stat = i4 WITH protect, noconstant(0)
   DECLARE newstr = vc WITH protect
   DECLARE strloc = i4 WITH protect, noconstant(0)
   DECLARE temp_file = vc WITH protect, noconstant(" ")
   DECLARE str2 = vc WITH protect, noconstant(" ")
   DECLARE posx = i4 WITH protect, noconstant(0)
   DECLARE sql_warn_ind = i2 WITH protect, noconstant(0)
   IF ((dm_err->errfile="NONE"))
    IF (get_unique_file("dm2_",".err")=0)
     RETURN(0)
    ELSE
     SET dm_err->errfile = dm_err->unique_fname
    ENDIF
   ENDIF
   IF (cursys IN ("AIX", "WIN"))
    SET strloc = findstring(">",sbr_dpdstr,1,0)
    IF (strloc > 0)
     SET strlength = size(trim(sbr_dpdstr))
     IF (findstring("2>&1",sbr_dpdstr) > 0)
      SET temp_file = build(substring((strloc+ 1),((strlength - strloc) - 4),sbr_dpdstr))
     ELSE
      SET temp_file = build(substring((strloc+ 1),(strlength - strloc),sbr_dpdstr))
     ENDIF
     SET newstr = sbr_dpdstr
    ELSE
     SET newstr = concat(sbr_dpdstr," > ",dm2_install_schema->ccluserdir,dm_err->errfile," 2>&1")
    ENDIF
   ELSE
    SET strloc = findstring(">",sbr_dpdstr,1,0)
    IF (strloc > 0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Cannot support additional piping outside of push dcl subroutine"
     SET dm_err->eproc = "Check push dcl command for piping character (>)."
     RETURN(0)
    ENDIF
    SET newstr = concat("pipe ",sbr_dpdstr," > ccluserdir:",dm_err->errfile)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo("*")
    CALL echo(concat("dm2_push_dcl executing: ",newstr))
    CALL echo("*")
   ENDIF
   CALL dcl(newstr,size(newstr),dpd_stat)
   IF (dpd_stat=0)
    IF (temp_file > " ")
     CASE (cursys)
      OF "AIX":
       SET str2 = concat("cp ",temp_file," ",dm_err->errfile)
      OF "WIN":
       SET str2 = concat("copy ",temp_file," ",dm_err->errfile)
     ENDCASE
     CALL dcl(str2,size(str2),dpd_stat)
    ENDIF
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
    IF (currdb="DB2UDB")
     SET posx = 1
     SET sql_warn_ind = false
     WHILE (posx < size(dm_err->errtext))
      SET posx = findstring("SQL",dm_err->errtext,posx)
      IF (posx > 0)
       SET posx = (posx+ 7)
       IF (isnumeric(substring(posx,1,dm_err->errtext)) > 0)
        SET posx = (posx+ 1)
        IF (isnumeric(substring(posx,1,dm_err->errtext))=0)
         CASE (substring(posx,1,dm_err->errtext))
          OF "W":
           SET sql_warn_ind = true
           IF ((dm_err->debug_flag > 0))
            CALL echo("5 digit warning encountered")
           ENDIF
          OF "E":
           SET sql_warn_ind = false
           SET posx = size(dm_err->errtext)
           IF ((dm_err->debug_flag > 0))
            CALL echo("5 digit E error encountered")
           ENDIF
          OF "N":
           SET sql_warn_ind = false
           SET posx = size(dm_err->errtext)
           IF ((dm_err->debug_flag > 0))
            CALL echo("5 digit N error encountered")
           ENDIF
          ELSE
           IF ((dm_err->debug_flag > 0))
            CALL echo("Not W, E, N")
           ENDIF
         ENDCASE
        ENDIF
       ELSE
        CASE (substring(posx,1,dm_err->errtext))
         OF "W":
          SET sql_warn_ind = true
          IF ((dm_err->debug_flag > 0))
           CALL echo("4 digit warning encountered")
          ENDIF
         OF "E":
          SET sql_warn_ind = false
          SET posx = size(dm_err->errtext)
          IF ((dm_err->debug_flag > 0))
           CALL echo("4 digit E error encountered")
          ENDIF
         OF "N":
          SET sql_warn_ind = false
          SET posx = size(dm_err->errtext)
          IF ((dm_err->debug_flag > 0))
           CALL echo("4 digit N error encountered")
          ENDIF
         ELSE
          IF ((dm_err->debug_flag > 0))
           CALL echo("Not W, E, N")
          ENDIF
        ENDCASE
       ENDIF
      ELSE
       SET posx = size(dm_err->errtext)
      ENDIF
     ENDWHILE
    ENDIF
    IF (sql_warn_ind=true)
     SET dm_err->user_action = "NONE"
     SET dm_err->eproc = concat("Warning Encountered:",dm_err->errtext)
     CALL disp_msg("",dm_err->logfile,0)
    ELSE
     SET dm_err->eproc = concat("dm2_push_dcl executing: ",newstr)
     SET dm_err->err_ind = 1
     SET dm_err->disp_msg_emsg = dm_err->errtext
     SET dm_err->emsg = dm_err->disp_msg_emsg
     CALL disp_msg("dm_err->disp_msg_emsg",dm_err->logfile,1)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo(concat("PARSING THROUGH - ",dm_err->errfile))
    IF (parse_errfile(dm_err->errfile)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE get_unique_file(sbr_fprefix,sbr_fext)
   DECLARE guf_return_val = i4 WITH protect, noconstant(1)
   DECLARE fini = i2 WITH protect, noconstant(0)
   DECLARE fname = vc WITH protect
   DECLARE unique_tempstr = vc WITH protect
   IF (textlen(concat(sbr_fprefix,sbr_fext)) > 24)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Combination of file prefix and extension exceeded length limit of 24."
    SET dm_err->eproc = concat("Getting unique file name using prefix: ",sbr_fprefix," and ext: ",
     sbr_fext)
    SET dm_err->user_action =
    "Please enter a file prefix and extension that does not exceed a length of 24."
    SET guf_return_val = 0
   ENDIF
   IF (guf_return_val=1)
    WHILE (fini=0)
      SET unique_tempstr = substring(1,6,cnvtstring((datetimediff(cnvtdatetime(curdate,curtime3),
         cnvtdatetime(curdate,000000)) * 864000)))
      SET fname = cnvtlower(build(sbr_fprefix,unique_tempstr,sbr_fext))
      IF (findfile(fname)=0)
       SET fini = 1
      ENDIF
    ENDWHILE
    IF (check_error(concat("Getting unique file name using prefix: ",sbr_fprefix," and ext: ",
      sbr_fext))=1)
     SET guf_return_val = 0
    ENDIF
   ENDIF
   IF (guf_return_val=0)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(concat("Error occurred in ",dm_err->eproc))
    CALL echo("*")
    CALL echo(trim(dm_err->emsg))
    CALL echo("*")
    IF ((dm_err->user_action != "NONE"))
     CALL echo(dm_err->user_action)
     CALL echo("*")
    ENDIF
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ELSE
    SET dm_err->unique_fname = fname
    CALL echo(concat("**Unique filename = ",dm_err->unique_fname))
   ENDIF
   RETURN(guf_return_val)
 END ;Subroutine
 SUBROUTINE parse_errfile(sbr_errfile)
   SET dm_err->errtext = " "
   FREE DEFINE rtl2
   FREE SET file_loc
   SET logical file_loc value(sbr_errfile)
   DEFINE rtl2 "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    DETAIL
     IF ((dm_err->debug_flag > 1))
      CALL echo(concat("TEXT = ",r.line))
     ENDIF
     dm_err->errtext = build(dm_err->errtext,r.line)
    WITH nocounter, maxcol = 255
   ;end select
   IF (check_error(concat("Parsing error file ",dm_err->errfile))=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE check_error(sbr_ceprocess)
   DECLARE return_val = i4 WITH protect, noconstant(0)
   IF ((dm_err->err_ind=1))
    SET return_val = 1
   ELSE
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF ((dm_err->ecode != 0))
     SET dm_err->eproc = sbr_ceprocess
     SET dm_err->err_ind = 1
     SET return_val = 1
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE disp_msg(sbr_demsg,sbr_dlogfile,sbr_derr_ind)
   DECLARE dm_txt = c132 WITH protect
   DECLARE dm_ecode = i4 WITH protect
   DECLARE dm_emsg = c132 WITH protect
   DECLARE dm_full_emsg = vc WITH protect
   DECLARE dm_eproc_length = i4 WITH protect
   DECLARE dm_full_emsg_length = i4 WITH protect
   DECLARE dm_user_action_length = i4 WITH protect
   IF (sbr_demsg="dm_err->disp_msg_emsg")
    SET dm_full_emsg = dm_err->disp_msg_emsg
   ELSE
    SET dm_full_emsg = sbr_demsg
   ENDIF
   SET dm_eproc_length = textlen(dm_err->eproc)
   SET dm_full_emsg_length = textlen(dm_full_emsg)
   SET dm_user_action_length = textlen(dm_err->user_action)
   IF ( NOT (sbr_dlogfile IN ("NONE", "DM2_LOGFILE_NOTSET"))
    AND trim(sbr_dlogfile) != ""
    AND textlen(sbr_dlogfile) <= 30)
    SELECT INTO value(sbr_dlogfile)
     FROM (dummyt d  WITH seq = 1)
     HEAD REPORT
      beg_pos = 1, end_pos = 132, not_done = 1
     DETAIL
      row + 1, curdate"mm/dd/yyyy;;d", " ",
      curtime3"hh:mm:ss;3;m"
      IF (sbr_derr_ind=1)
       row + 1, "* Component Name:  ", curprog,
       row + 1, "* Process Description:  "
      ENDIF
      dm_txt = substring(beg_pos,end_pos,dm_err->eproc)
      WHILE (not_done=1)
        row + 1, col 0, dm_txt
        IF (end_pos > dm_eproc_length)
         not_done = 0
        ELSE
         beg_pos = (end_pos+ 1), end_pos = (end_pos+ 132), dm_txt = substring(beg_pos,132,dm_err->
          eproc)
        ENDIF
      ENDWHILE
      IF (sbr_derr_ind=1)
       row + 1, "* Error Message:  ", beg_pos = 1,
       end_pos = 132, dm_txt = substring(beg_pos,132,dm_full_emsg), not_done = 1
       WHILE (not_done=1)
         row + 1, col 0, dm_txt
         IF (end_pos > dm_full_emsg_length)
          not_done = 0
         ELSE
          beg_pos = (end_pos+ 1), end_pos = (end_pos+ 132), dm_txt = substring(beg_pos,132,
           dm_full_emsg)
         ENDIF
       ENDWHILE
      ENDIF
      IF ((dm_err->user_action != "NONE"))
       row + 1, "* Recommended Action(s):  ", beg_pos = 1,
       end_pos = 132, dm_txt = substring(beg_pos,132,dm_err->user_action), not_done = 1
       WHILE (not_done=1)
         row + 1, col 0, dm_txt
         IF (end_pos > dm_user_action_length)
          not_done = 0
         ELSE
          beg_pos = (end_pos+ 1), end_pos = (end_pos+ 132), dm_txt = substring(beg_pos,132,dm_err->
           user_action)
         ENDIF
       ENDWHILE
      ENDIF
      row + 1
     WITH nocounter, format = variable, formfeed = none,
      maxrow = 1, maxcol = 200, append
    ;end select
    SET dm_ecode = error(dm_emsg,1)
   ELSEIF (sbr_dlogfile != "DM2_LOGFILE_NOTSET")
    SET dm_ecode = 1
    SET dm_emsg = "Message couldn't write to log file since name passed in was invalid."
   ENDIF
   IF (dm_ecode > 0)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(concat("Component Name:  ",curprog))
    CALL echo("*")
    CALL echo(concat("Process Description:  Writing message to log file."))
    CALL echo("*")
    CALL echo(concat("Error Message:  ",trim(dm_emsg)))
    CALL echo("*")
    IF ( NOT (sbr_dlogfile IN ("NONE", "DM2_LOGFILE_NOTSET")))
     CALL echo(concat("Log file is ccluserdir:",sbr_dlogfile))
     CALL echo("*")
    ENDIF
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ENDIF
   IF (sbr_derr_ind=1)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(concat("Component Name:  ",curprog))
    CALL echo("*")
    CALL echo(concat("Process Description:  ",dm_err->eproc))
    CALL echo("*")
    CALL echo(concat("Error Message:  ",trim(dm_full_emsg)))
    CALL echo("*")
    IF ((dm_err->user_action != "NONE"))
     CALL echo(concat("Recommended Action(s):  ",trim(dm_err->user_action)))
     CALL echo("*")
    ENDIF
    IF ( NOT (sbr_dlogfile IN ("NONE", "DM2_LOGFILE_NOTSET")))
     CALL echo(concat("Log file is ccluserdir:",sbr_dlogfile))
     CALL echo("*")
    ENDIF
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ELSE
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(dm_err->eproc)
    CALL echo("*")
    IF ((dm_err->user_action != "NONE"))
     CALL echo(concat("Recommended Action(s):  ",trim(dm_err->user_action)))
     CALL echo("*")
    ENDIF
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ENDIF
   SET dm_err->user_action = "NONE"
 END ;Subroutine
 SUBROUTINE init_logfile(sbr_logfile,sbr_header_msg)
   DECLARE init_return_val = i4 WITH protect, noconstant(1)
   IF (sbr_logfile != "NONE"
    AND trim(sbr_logfile) != ""
    AND textlen(sbr_logfile) <= 30)
    SELECT INTO value(sbr_logfile)
     FROM (dummyt d  WITH seq = 1)
     DETAIL
      row + 1, curdate"mm/dd/yyyy;;d", " ",
      curtime3"hh:mm:ss;;m", row + 1, sbr_header_msg,
      row + 1, row + 1
     WITH nocounter, format = variable, formfeed = none,
      maxrow = 1, maxcol = 512
    ;end select
    IF (check_error(concat("Creating log file ",trim(sbr_logfile)))=1)
     SET init_return_val = 0
    ELSE
     SET dm_err->eproc = concat("Log file created.  Log file name is: ",sbr_logfile)
     CALL disp_msg(" ",sbr_logfile,0)
    ENDIF
   ELSE
    SET dm_err->err_ind = 1
    SET dm_err->eproc = concat("Creating log file ",trim(sbr_logfile))
    SET dm_err->emsg = concat("Log file name passed is invalid.  Name passed in is: ",trim(
      sbr_logfile))
    SET init_return_val = 0
   ENDIF
   IF (init_return_val=0)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo(concat("Error occurred in ",dm_err->eproc))
    CALL echo("*")
    CALL echo(trim(dm_err->emsg))
    CALL echo("*")
    CALL echo(dm_err->asterisk_line)
    CALL echo("*")
    CALL echo("*")
    CALL echo("*")
   ENDIF
   RETURN(init_return_val)
 END ;Subroutine
 SUBROUTINE dm2_val_sch_date_str(sbr_datestr)
   DECLARE bad_sd_ind = i2 WITH protect, noconstant(0)
   DECLARE cnvt_datestr = vc WITH protect, noconstant(cnvtupper(sbr_datestr))
   IF (textlen(cnvt_datestr) != 11)
    SET bad_sd_ind = 1
   ELSEIF (substring(3,1,cnvt_datestr) != "-")
    SET bad_sd_ind = 1
   ELSEIF (substring(7,1,cnvt_datestr) != "-")
    SET bad_sd_ind = 1
   ELSEIF (cnvtint(substring(1,2,cnvt_datestr)) > 31)
    SET bad_sd_ind = 1
   ELSEIF (cnvtint(substring(1,2,cnvt_datestr)) <= 0)
    SET bad_sd_ind = 1
   ELSEIF (cnvtint(substring(8,4,cnvt_datestr)) <= 0)
    SET bad_sd_ind = 1
   ENDIF
   IF (bad_sd_ind=1)
    SET dm_err->eproc = "Validating schema date"
    SET dm_err->err_ind = 1
    SET dm_err->user_action =
    'Please specify a valid date in the format "DD-MON-YYYY", e.g. "15-JAN-2002" '
    CALL disp_msg(concat('Invalid schema date of "',sbr_datestr,'" was passed in'),dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_push_adm_maint(sbr_maint_str)
   DECLARE adm_maint_err = i4 WITH protect, noconstant(1)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SET adm_maint_err = dm2_push_cmd(sbr_maint_str,1)
   IF (adm_maint_err=0)
    ROLLBACK
   ELSE
    COMMIT
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   RETURN(adm_maint_err)
 END ;Subroutine
 SUBROUTINE check_logfile(sbr_lprefix,sbr_lext,sbr_hmsg)
   IF ((dm_err->logfile IN ("NONE", "DM2_LOGFILE_NOTSET")))
    IF ((dm_err->debug_flag > 1))
     SET trace = echoprogsub
     IF (((currev > 8) OR (currev=8
      AND currevminor >= 1)) )
      SET trace = echosub
     ENDIF
    ENDIF
    IF (get_unique_file(sbr_lprefix,sbr_lext)=0)
     RETURN(0)
    ENDIF
    SET dm_err->logfile = dm_err->unique_fname
    IF (init_logfile(dm_err->logfile,sbr_hmsg)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF (dm2_prg_maint("BEGIN")=0)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE val_user_privs(sbr_dummy_param)
   SET dm_err->eproc = "Retrieving CCL user data from duaf."
   SELECT INTO "nl:"
    d.group
    FROM duaf d
    WHERE cnvtupper(d.user_name)=cnvtupper(curuser)
     AND d.group=0
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0
    AND cnvtupper(curuser) != "P30INS")
    SET dm_err->err_ind = 1
    SET dm_err->eproc = "Validating user privileges"
    CALL disp_msg(concat("Current user, ",curuser,", does not have CCL DBA privileges required",
      " to run this program. Please contact your system administrator."),dm_err->logfile,1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE final_disp_msg(sbr_log_prefix)
   DECLARE plength = i2
   SET plength = textlen(sbr_log_prefix)
   IF (dm2_prg_maint("END")=0)
    RETURN(0)
   ENDIF
   IF ((dm_err->err_ind=0))
    IF (cnvtlower(sbr_log_prefix)=substring(1,plength,dm_err->logfile))
     SET dm_err->eproc = concat(dm_err->eproc,"  Log file is ccluserdir:",dm_err->logfile)
     CALL disp_msg(" ",dm_err->logfile,0)
    ELSE
     CALL disp_msg(" ",dm_err->logfile,0)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE validate_node_info(sbr_nname,sbr_ni_ignore_err)
   DECLARE vni_return = i2 WITH protect, noconstant(1)
   DECLARE err_pos = i4 WITH protect, noconstant(0)
   SET db2_node_info->node_fnd = 0
   SET db2_node_info->protocol_fnd = 0
   SET db2_node_info->hostname_fnd = 0
   SET db2_node_info->service_name_fnd = 0
   SET db2_node_info->node_name = " "
   SET db2_node_info->protocol = "-"
   SET db2_node_info->hostname = "-"
   SET db2_node_info->service_name = "-"
   IF (dm2_push_dcl("db2 list node directory")=0)
    IF (sbr_ni_ignore_err=1)
     IF (findstring("SQL1027N",dm_err->errtext)=0
      AND findstring("SQL1037W",dm_err->errtext)=0)
      RETURN(0)
     ELSE
      SET dm_err->eproc =
      "Message reported when executing db2 list node is okay - process continuing"
      CALL disp_msg(" ",dm_err->logfile,0)
      SET dm_err->err_ind = 0
      RETURN(1)
     ENDIF
    ELSE
     RETURN(0)
    ENDIF
   ENDIF
   FREE DEFINE rtl
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    DETAIL
     IF (vni_return=1)
      IF ((db2_node_info->node_fnd=0))
       IF ((db2_node_info->node_name=" "))
        IF (retrieve_data("Node name","=",r.line)=0)
         vni_return = 0
        ELSEIF ((retrieve_data->result_status=1))
         IF (cnvtupper(retrieve_data->result_str)=cnvtupper(sbr_nname))
          db2_node_info->node_name = cnvtupper(sbr_nname), db2_node_info->node_fnd = 1
         ENDIF
        ENDIF
       ENDIF
      ELSE
       IF (retrieve_data("Node name","=",r.line)=0)
        vni_return = 0
       ELSEIF ((retrieve_data->result_status=1))
        db2_node_info->node_fnd = 0
       ENDIF
       IF (vni_return=1
        AND retrieve_data("Protocol","=",r.line)=0)
        vni_return = 0
       ELSEIF ((retrieve_data->result_status=1))
        db2_node_info->protocol = retrieve_data->result_str, db2_node_info->protocol_fnd = 1
       ENDIF
       IF (vni_return=1
        AND retrieve_data("Hostname","=",r.line)=0)
        vni_return = 0
       ELSEIF ((retrieve_data->result_status=1))
        db2_node_info->hostname = retrieve_data->result_str, db2_node_info->hostname_fnd = 1
       ENDIF
       IF (vni_return=1
        AND retrieve_data("Service name","=",r.line)=0)
        vni_return = 0
       ELSEIF ((retrieve_data->result_status=1))
        db2_node_info->service_name = retrieve_data->result_str, db2_node_info->service_name_fnd = 1
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (vni_return=0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   ELSEIF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET vni_return = 0
   ENDIF
   RETURN(vni_return)
 END ;Subroutine
 SUBROUTINE validate_dbase_info(sbr_vi_dbase,sbr_vi_ignore_err)
   DECLARE vdi_return = i2 WITH protect, noconstant(1)
   SET db2_dbase_info->dbase_fnd = 0
   SET db2_dbase_info->dbase_name_fnd = 0
   SET db2_dbase_info->node_name_fnd = 0
   SET db2_dbase_info->dir_entry_ty_fnd = 0
   SET db2_dbase_info->authen_fnd = 0
   SET db2_dbase_info->ctlg_nd_nbr_fnd = 0
   SET db2_dbase_info->alias = " "
   SET db2_dbase_info->dbase_name = "-"
   SET db2_dbase_info->node_name = "-"
   SET db2_dbase_info->dir_entry_ty = "-"
   SET db2_dbase_info->authen = "-"
   SET db2_dbase_info->ctlg_nd_nbr = "-"
   IF (dm2_push_dcl("db2 list database directory")=0)
    IF (sbr_vi_ignore_err=1)
     IF (findstring("SQL1031N",dm_err->errtext)=0
      AND findstring("SQL1057W",dm_err->errtext)=0)
      RETURN(0)
     ELSE
      SET dm_err->eproc =
      "Message reported when executing db2 list database is okay - process continuing"
      CALL disp_msg(" ",dm_err->logfile,0)
      SET dm_err->err_ind = 0
      RETURN(1)
     ENDIF
    ELSE
     RETURN(0)
    ENDIF
   ENDIF
   FREE DEFINE rtl
   FREE SET file_loc
   SET logical file_loc value(dm_err->errfile)
   DEFINE rtl "file_loc"
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    DETAIL
     IF (vdi_return=1)
      IF ((db2_dbase_info->dbase_fnd=0))
       IF ((db2_dbase_info->alias=" "))
        IF (retrieve_data("Database alias","=",r.line)=0)
         vdi_return = 0
        ELSEIF ((retrieve_data->result_status=1))
         IF (cnvtupper(retrieve_data->result_str)=cnvtupper(sbr_vi_dbase))
          db2_dbase_info->alias = cnvtupper(sbr_vi_dbase), db2_dbase_info->dbase_fnd = 1
         ENDIF
        ENDIF
       ENDIF
      ELSE
       IF (retrieve_data("Database alias","=",r.line)=0)
        vdi_return = 0
       ELSEIF ((retrieve_data->result_status=1))
        db2_dbase_info->dbase_fnd = 0
       ENDIF
       IF (vdi_return=1
        AND retrieve_data("Database name","=",r.line)=0)
        vdi_return = 0
       ELSEIF ((retrieve_data->result_status=1))
        db2_dbase_info->dbase_name = retrieve_data->result_str, db2_dbase_info->dbase_name_fnd = 1
       ENDIF
       IF (vdi_return=1
        AND retrieve_data("Node name","=",r.line)=0)
        vdi_return = 0
       ELSEIF ((retrieve_data->result_status=1))
        db2_dbase_info->node_name = retrieve_data->result_str, db2_dbase_info->node_name_fnd = 1
       ENDIF
       IF (vdi_return=1
        AND retrieve_data("Directory entry type","=",r.line)=0)
        vdi_return = 0
       ELSEIF ((retrieve_data->result_status=1))
        db2_dbase_info->dir_entry_ty = retrieve_data->result_str, db2_dbase_info->dir_entry_ty_fnd =
        1
       ENDIF
       IF (vdi_return=1
        AND retrieve_data("Authentication","=",r.line)=0)
        vdi_return = 0
       ELSEIF ((retrieve_data->result_status=1))
        db2_dbase_info->authen = retrieve_data->result_str, db2_dbase_info->authen_fnd = 1
       ENDIF
       IF (vdi_return=1
        AND retrieve_data("Catalog database partition number","=",r.line)=0)
        vdi_return = 0
       ELSEIF ((retrieve_data->result_status=1))
        db2_dbase_info->ctlg_nd_nbr = retrieve_data->result_str, db2_dbase_info->ctlg_nd_nbr_fnd = 1
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (vdi_return=0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   ELSEIF (check_error(dm_err->eproc)=1)
    SET dm_err->eproc = "Reading through Database List Directory"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET vdi_return = 0
   ENDIF
   RETURN(vdi_return)
 END ;Subroutine
 SUBROUTINE retrieve_data(sbr_srch_str,sbr_sprtr,sbr_rd_str)
   SET retrieve_data->result_str = " "
   SET retrieve_data->result_status = 0
   DECLARE str_loc = i4 WITH protect, noconstant(0)
   DECLARE str_len = i4 WITH protect, noconstant(0)
   DECLARE srch_str_len = i4 WITH protect, noconstant(0)
   DECLARE sstart = i4 WITH protect, noconstant(0)
   DECLARE slength = i4 WITH protect, noconstant(0)
   IF ( NOT (sbr_sprtr IN (" ", "=")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Separator parameter invalid.  Must be either ' ' or '='."
    SET dm_err->eproc = "Separator validation."
    RETURN(0)
   ENDIF
   SET str_loc = findstring(sbr_srch_str,sbr_rd_str)
   IF (str_loc > 0)
    IF (sbr_sprtr="=")
     SET str_len = textlen(trim(sbr_rd_str))
     SET str_loc = findstring(sbr_sprtr,sbr_rd_str)
     IF (str_loc=0)
      SET dm_err->err_ind = 1
      SET dm_err->emsg = "Separator not found.  DB2 List output contains invalid/outdated info."
      SET dm_err->eproc = concat("Locating '",sbr_sprtr,"' on line containing '",sbr_srch_str,"'.")
      RETURN(0)
     ELSE
      SET sstart = (str_loc+ 1)
      SET slength = (str_len - str_loc)
      SET retrieve_data->result_str = trim(substring(sstart,slength,sbr_rd_str),3)
      SET retrieve_data->result_status = 1
      RETURN(1)
     ENDIF
    ELSE
     SET str_len = textlen(trim(sbr_rd_str))
     SET srch_str_len = textlen(sbr_srch_str)
     SET sstart = (str_loc+ srch_str_len)
     SET slength = (((str_len - str_loc) - srch_str_len)+ 1)
     SET retrieve_data->result_str = trim(substring(sstart,slength,sbr_rd_str),3)
     SET retrieve_data->result_status = 1
     RETURN(1)
    ENDIF
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE db2_push_dcl_w_connect(sbr_dwc_dbase,sbr_dwc_user,sbr_dwc_user_pwd,sbr_dwc_str,
  sbr_dwc_commit_ind)
   DECLARE push_rtrn = i2 WITH protect, noconstant(1)
   IF (dm2_push_dcl(concat('db2 "connect to ',cnvtlower(sbr_dwc_dbase)," user ",cnvtlower(
      sbr_dwc_user)," using ",
     cnvtlower(sbr_dwc_user_pwd),'"'))=0)
    RETURN(0)
   ENDIF
   IF (sbr_dwc_commit_ind=1)
    IF (dm2_push_dcl(concat("db2 -c ",sbr_dwc_str))=0)
     SET push_rtrn = 0
    ENDIF
   ELSE
    IF (dm2_push_dcl(concat("db2 +c ",sbr_dwc_str))=0)
     SET push_rtrn = 0
    ENDIF
   ENDIF
   IF (dm2_push_dcl("db2 terminate")=0)
    SET push_rtrn = 0
   ENDIF
   RETURN(push_rtrn)
 END ;Subroutine
 SUBROUTINE dm2parse_output(sbr_nbr_attr,sbr_parse_fname,sbr_orientation)
   DECLARE select_str = vc WITH protect, noconstant(" ")
   DECLARE foot_str = vc WITH protect, noconstant(" ")
   DECLARE buf_cnt = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE dm2_stat = i4 WITH protect, noconstant(0)
   DECLARE dm2_str = vc WITH protect, noconstant(" ")
   RECORD dm2parse_buf(
     1 qual[*]
       2 str = vc
   )
   SET select_str = concat('select into "nl:" r.line'," from rtlt r",' where r.line > " "'," detail "
    )
   FOR (attr_nbr = 1 TO sbr_nbr_attr)
     SET buf_cnt = (buf_cnt+ 1)
     IF (mod(buf_cnt,10)=1)
      SET stat = alterlist(dm2parse_buf->qual,(buf_cnt+ 9))
     ENDIF
     IF (attr_nbr=1)
      SET dm2parse_buf->qual[buf_cnt].str = concat(" if (findstring(dm2parse->attr1, r.line))",
       " cnt = cnt + 1"," if(mod(cnt,10) = 1)"," stat = alterlist(dm2parse->qual, cnt +9)"," endif",
       " if(retrieve_data(dm2parse->attr1, dm2parse->attr1sep, r.line))",
       " dm2parse->qual[cnt]->attr1val = retrieve_data->result_str"," endif")
     ELSE
      IF (sbr_orientation="V")
       SET dm2parse_buf->qual[buf_cnt].str = concat(" elseif (findstring( dm2parse->attr",trim(
         cnvtstring(attr_nbr),3)," , r.line))"," if (retrieve_data(dm2parse->attr",trim(cnvtstring(
          attr_nbr),3),
        ",dm2parse->attr",trim(cnvtstring(attr_nbr),3),"sep , r.line)) dm2parse->qual[cnt]->attr",
        trim(cnvtstring(attr_nbr),3),"val = retrieve_data->result_str endif")
      ELSE
       SET dm2parse_buf->qual[buf_cnt].str = concat(" endif if (findstring( dm2parse->attr",trim(
         cnvtstring(attr_nbr),3)," , r.line))"," if (retrieve_data(dm2parse->attr",trim(cnvtstring(
          attr_nbr),3),
        ",dm2parse->attr",trim(cnvtstring(attr_nbr),3),"sep , r.line)) dm2parse->qual[cnt]->attr",
        trim(cnvtstring(attr_nbr),3),"val = retrieve_data->result_str endif")
      ENDIF
     ENDIF
     IF (attr_nbr=sbr_nbr_attr)
      SET dm2parse_buf->qual[buf_cnt].str = concat(dm2parse_buf->qual[buf_cnt].str," endif")
     ENDIF
   ENDFOR
   SET stat = alterlist(dm2parse_buf->qual,buf_cnt)
   SET foot_str = concat(" foot report"," stat = alterlist(dm2parse->qual, cnt)"," with nocounter go"
    )
   SET dm2_stat = dm2_push_cmd("free define rtl go",1)
   IF ( NOT (dm2_stat))
    RETURN(0)
   ENDIF
   SET dm2_stat = dm2_push_cmd("free set file_loc go",1)
   IF ( NOT (dm2_stat))
    RETURN(0)
   ENDIF
   SET dm2_str = concat('set logical = file_loc "',sbr_parse_fname,'" go')
   SET dm2_stat = dm2_push_cmd(dm2_str,1)
   IF ( NOT (dm2_stat))
    RETURN(0)
   ENDIF
   SET dm2_stat = dm2_push_cmd('define rtl is "file_loc" go',1)
   IF ( NOT (dm2_stat))
    RETURN(0)
   ENDIF
   IF (dm2_push_cmd(select_str,0))
    FOR (parse_cnt = 1 TO size(dm2parse_buf->qual,5))
     SET dm2_stat = dm2_push_cmd(dm2parse_buf->qual[parse_cnt].str,0)
     IF ( NOT (dm2_stat))
      RETURN(0)
     ENDIF
    ENDFOR
    IF (dm2_push_cmd(foot_str,1))
     RETURN(1)
    ELSE
     RETURN(0)
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_fill_sch_except(sbr_dfse_from)
   IF ( NOT (cnvtupper(sbr_dfse_from) IN ("REMOTE", "LOCAL")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid from table indicator (should be either REMOTE or LOCAL)."
    SET dm_err->eproc = "Building exception list of tables"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm2_sch_except->tcnt=0))
    IF (dm2_set_autocommit(1)=0)
     RETURN(0)
    ENDIF
    IF (cnvtupper(sbr_dfse_from)="REMOTE")
     SELECT INTO "nl:"
      d.table_name
      FROM dm2_src_tables t
      WHERE t.table_name IN ("DM2_DDL_OPS*", "DM2*TMPSIZE")
      DETAIL
       dm2_sch_except->tcnt = (dm2_sch_except->tcnt+ 1), stat = alterlist(dm2_sch_except->tbl,
        dm2_sch_except->tcnt), dm2_sch_except->tbl[dm2_sch_except->tcnt].tbl_name = t.table_name
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      d.table_name
      FROM dm2_user_tables t
      WHERE t.table_name IN ("DM2_DDL_OPS*", "DM2*TMPSIZE")
      DETAIL
       dm2_sch_except->tcnt = (dm2_sch_except->tcnt+ 1), stat = alterlist(dm2_sch_except->tbl,
        dm2_sch_except->tcnt), dm2_sch_except->tbl[dm2_sch_except->tcnt].tbl_name = t.table_name
      WITH nocounter
     ;end select
    ENDIF
    IF (check_error("Determining tables that should be in dm2_sch_except record structure")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ENDIF
    IF (dm2_set_autocommit(0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   IF ((dm2_sch_except->seq_cnt=0))
    SET dm2_sch_except->seq_cnt = 1
    SET stat = alterlist(dm2_sch_except->seq,1)
    SET dm2_sch_except->seq[1].seq_name = "DM_SEQ"
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_suffixed_tablename(tbl_name)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   DECLARE dm2_str = vc WITH protect, noconstant(" ")
   SET dm2_str = concat("select into 'nl:'"," from dm_tables_doc dtd ",
    " where dtd.table_name = cnvtupper('",tbl_name,"')",
    " detail"," dm2_table->suffixed_table_name = dtd.suffixed_table_name",
    " dm2_table->table_suffix = dtd.table_suffix"," dm2_table->full_table_name = dtd.full_table_name",
    " with nocounter",
    " go")
   IF ( NOT (dm2_push_cmd(dm2_str,1)))
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_system_defs_init(sbr_sdi_regen_ind)
   DECLARE sdi_def_cur_user = vc WITH protect, constant(cnvtupper(currdbuser))
   DECLARE sdi_def1_exists_ind = i2 WITH protect, noconstant(0)
   DECLARE sdi_def2_exists_ind = i2 WITH protect, noconstant(0)
   CASE (currdb)
    OF "ORACLE":
     SELECT INTO "nl:"
      FROM dtable d
      WHERE d.table_name IN ("USER_VIEWS", "DM2_DBA_TAB_COLUMNS")
      DETAIL
       CASE (d.table_name)
        OF "USER_VIEWS":
         sdi_def1_exists_ind = 1
        OF "DM2_DBA_TAB_COLUMNS":
         sdi_def2_exists_ind = 1
       ENDCASE
      WITH nocounter
     ;end select
     IF (check_error("Verifying USER_VIEWS & DM2_DBA_TAB_COLUMNS table defs exist.")=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (((sdi_def1_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
      IF (sdi_def1_exists_ind=1)
       DROP TABLE user_views
       IF (check_error("Dropping USER_VIEWS definition.")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
      DROP DDLRECORD user_views FROM DATABASE v500 WITH deps_deleted
      CREATE DDLRECORD user_views FROM DATABASE v500
 TABLE user_views
  1 view_name  = c30 CCL(view_name)
  1 text_length  = f8 CCL(text_length)
  1 text  = vc32000 CCL(text)
  1 type_text_length  = f8 CCL(type_text_length)
  1 type_text  = vc4000 CCL(type_text)
  1 oid_text_length  = f8 CCL(oid_text_length)
  1 oid_text  = vc4000 CCL(oid_text)
  1 view_type_owner  = c30 CCL(view_type_owner)
  1 view_type  = c30 CCL(view_type)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE user_views
      IF (check_error("Generating USER_VIEWS CCL definition.")=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
     SELECT INTO "nl:"
      FROM user_views uv
      WHERE uv.view_name="DM2_DBA_TAB_COLUMNS"
      WITH nocounter
     ;end select
     IF (check_error("Determining whether DM2_DBA_TAB_COLUMNS view already exists.")=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (((curqual=0) OR (sbr_sdi_regen_ind=1)) )
      IF (curqual=1)
       RDB drop view dm2_dba_tab_columns
       END ;Rdb
       IF (check_error("Dropping DM2_DBA_TAB_COLUMNS view.")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
      CALL parser(concat("rdb grant select any table to ",sdi_def_cur_user," go"))
      RDB asis ( "create view dm2_dba_tab_columns (" ) asis (
      "  OWNER,            TABLE_NAME,        COLUMN_NAME,      DATA_TYPE," ) asis (
      "  DATA_LENGTH,      DATA_PRECISION,    DATA_SCALE,       NULLABLE," ) asis (
      "  COLUMN_ID,        DEFAULT_LENGTH,    DATA_DEFAULT,     NUM_DISTINCT," ) asis (
      "  LOW_VALUE,        HIGH_VALUE,        DENSITY,          NUM_NULLS," ) asis (
      "  NUM_BUCKETS,      LAST_ANALYZED,     SAMPLE_SIZE,      LOGGED," ) asis (
      "  COMPACT,          IDENTITY_IND,      GENERATED" ) asis ( ") as select" ) asis (
      "  c.owner,          c.table_name,      c.column_name,    c.data_type," ) asis (
      "  c.data_length,    c.data_precision,  c.data_scale,     c.nullable," ) asis (
      "  c.column_id,      c.default_length,  c.data_default,   c.num_distinct," ) asis (
      "  c.low_value,      c.high_value,      c.density,        c.num_nulls," ) asis (
      "  c.num_buckets,    c.last_analyzed,   c.sample_size,    'N/A'," ) asis (
      "  'N/A',            'N/A',             'N/A'" ) asis ( "from dba_tab_columns c" ) asis (
      "union all" ) asis ( "select" ) asis (
      "  dc.owner,         ds.synonym_name,   dc.column_name,   dc.data_type," ) asis (
      "  dc.data_length,   dc.data_precision, dc.data_scale,    dc.nullable," ) asis (
      "  dc.column_id,     dc.default_length, dc.data_default,  dc.num_distinct," ) asis (
      "  dc.low_value,     dc.high_value,     dc.density,       dc.num_nulls," ) asis (
      "  dc.num_buckets,   dc.last_analyzed,  dc.sample_size,   'N/A'," ) asis (
      "  'N/A',            'N/A',             'N/A'" ) asis (
      "from dba_tab_columns dc, dba_synonyms ds" ) asis ( "where ds.table_name = dc.table_name" )
      asis ( "  and ds.synonym_name != ds.table_name" ) asis ( "  and not exists " ) asis (
      "     (select c.synonym_name, count(*) " ) asis ( "          from dba_synonyms c " ) asis (
      "          where c.synonym_name = ds.synonym_name " ) asis (
      "          group by c.synonym_name " ) asis ( "          having count(*) > 1) " )
      END ;Rdb
      IF (check_error("CREATING DM2_DBA_TAB_COLUMNS VIEW")=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
     IF (((sdi_def2_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
      IF (sdi_def2_exists_ind=1)
       DROP TABLE dm2_dba_tab_columns
       IF (check_error("Dropping DM2_DBA_TAB_COLUMNS table def.")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
      DROP DDLRECORD dm2_dba_tab_columns FROM DATABASE v500 WITH deps_deleted
      CREATE DDLRECORD dm2_dba_tab_columns FROM DATABASE v500
 TABLE dm2_dba_tab_columns
  1 owner  = c30 CCL(owner)
  1 table_name  = c30 CCL(table_name)
  1 column_name  = c30 CCL(column_name)
  1 data_type  = vc106 CCL(data_type)
  1 data_length  = f8 CCL(data_length)
  1 data_precision  = f8 CCL(data_precision)
  1 data_scale  = f8 CCL(data_scale)
  1 nullable  = c1 CCL(nullable)
  1 column_id  = f8 CCL(column_id)
  1 default_length  = f8 CCL(default_length)
  1 data_default  = vc2000 CCL(data_default)
  1 num_distinct  = f8 CCL(num_distinct)
  1 low_value  = gc32 CCL(low_value)
  1 high_value  = gc32 CCL(high_value)
  1 density  = f8 CCL(density)
  1 num_nulls  = f8 CCL(num_nulls)
  1 num_buckets  = f8 CCL(num_buckets)
  1 last_analyzed  = di8 CCL(last_analyzed)
  1 sample_size  = f8 CCL(sample_size)
  1 logged  = c3 CCL(logged)
  1 compact  = c3 CCL(compact)
  1 identity_ind  = c3 CCL(identity_ind)
  1 generated  = c3 CCL(generated)
  1 rowid CCL(rowid)
    2 rowid_fld  = c18
 END TABLE dm2_dba_tab_columns
      IF (check_error("Creating DM2_DBA_TAB_COLUMNS table def.")=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
    OF "DB2UDB":
     SELECT INTO "nl:"
      FROM dtable d
      WHERE d.table_name IN ("TABLES", "DM2_DBA_TAB_COLUMNS")
      DETAIL
       CASE (d.table_name)
        OF "TABLES":
         sdi_def1_exists_ind = 1
        OF "DM2_DBA_TAB_COLUMNS":
         sdi_def2_exists_ind = 1
       ENDCASE
      WITH nocounter
     ;end select
     IF (check_error("Verifying TABLES & DM2_DBA_TAB_COLUMNS table defs exist.")=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (((sdi_def1_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
      IF (sdi_def1_exists_ind=1)
       DROP TABLE tables
       IF (check_error("Dropping TABLES definition.")=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
      DROP DDLRECORD tables FROM DATABASE v500 WITH deps_deleted
      CREATE DDLRECORD tables FROM DATABASE v500
 TABLE tables
  1 tabschema  = vc128 CCL(tabschema)
  1 tabname  = vc128 CCL(tabname)
  1 definer  = vc128 CCL(definer)
  1 type  = c1 CCL(type)
  1 status  = c1 CCL(status)
  1 base_tabschema  = vc128 CCL(base_tabschema)
  1 base_tabname  = vc128 CCL(base_tabname)
  1 rowtypeschema  = vc128 CCL(rowtypeschema)
  1 rowtypename  = vc128 CCL(rowtypename)
  1 create_time  = dq8 CCL(create_time)
  1 stats_time  = dq8 CCL(stats_time)
  1 colcount  = f8 CCL(colcount)
  1 tableid  = f8 CCL(tableid)
  1 tbspaceid  = f8 CCL(tbspaceid)
  1 card  = f8 CCL(card)
  1 npages  = f8 CCL(npages)
  1 fpages  = f8 CCL(fpages)
  1 overflow  = f8 CCL(overflow)
  1 tbspace  = vc128 CCL(tbspace)
  1 index_tbspace  = vc128 CCL(index_tbspace)
  1 long_tbspace  = vc128 CCL(long_tbspace)
  1 parents  = f8 CCL(parents)
  1 children  = f8 CCL(children)
  1 selfrefs  = f8 CCL(selfrefs)
  1 keycolumns  = f8 CCL(keycolumns)
  1 keyindexid  = f8 CCL(keyindexid)
  1 keyunique  = f8 CCL(keyunique)
  1 checkcount  = f8 CCL(checkcount)
  1 datacapture  = c1 CCL(datacapture)
  1 const_checked  = c32 CCL(const_checked)
  1 pmap_id  = f8 CCL(pmap_id)
  1 partition_mode  = c1 CCL(partition_mode)
  1 log_attribute  = c1 CCL(log_attribute)
  1 pctfree  = f8 CCL(pctfree)
  1 append_mode  = c1 CCL(append_mode)
  1 refresh  = c1 CCL(refresh)
  1 refresh_time  = dq8 CCL(refresh_time)
  1 locksize  = c1 CCL(locksize)
  1 volatile  = c1 CCL(volatile)
  1 remarks  = vc254 CCL(remarks)
  1 row_format  = c1 CCL(row_format)
  1 property  = c32 CCL(property)
  1 statistics_profile  = vc32000 CCL(statistics_profile)
  1 compression  = c1 CCL(compression)
  1 access_mode  = c1 CCL(access_mode)
  1 clustered  = c1 CCL(clustered)
  1 active_blocks  = f8 CCL(active_blocks)
  1 droprule  = c1 CCL(droprule)
  1 maxfreespacesearch  = f8 CCL(maxfreespacesearch)
 END TABLE tables
      IF (check_error("Generating TABLES CCL definition.")=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
     SELECT INTO "nl:"
      FROM (syscat.tables t)
      WHERE t.tabname="DM2_DBA_TAB_COLUMNS"
       AND t.tabschema=sdi_def_cur_user
       AND t.type="V"
      WITH nocounter
     ;end select
     IF (check_error("Determining whether DM2_DBA_TAB_COLUMNS view already exists.")=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (((curqual=0) OR (sbr_sdi_regen_ind=1)) )
      IF (curqual=1)
       RDB drop view dm2_dba_tab_columns
       END ;Rdb
       IF (check_error("Dropping DM2_DBA_TAB_COLUMNS view.")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
      RDB asis ( "create view dm2_dba_tab_columns (" ) asis (
      "  OWNER,                 TABLE_NAME,             COLUMN_NAME,     DATA_TYPE," ) asis (
      "  DATA_LENGTH,           DATA_PRECISION,         DATA_SCALE,      NULLABLE," ) asis (
      "  COLUMN_ID,             DEFAULT_LENGTH,         DATA_DEFAULT,    NUM_DISTINCT," ) asis (
      "  LOW_VALUE,             HIGH_VALUE,             DENSITY,         NUM_NULLS," ) asis (
      "  NUM_BUCKETS,           LAST_ANALYZED,          SAMPLE_SIZE,     LOGGED," ) asis (
      "  COMPACT,               IDENTITY_IND,           GENERATED" ) asis ( ") as select" ) asis (
      "  sc.tabschema,          sc.tabname,             sc.colname,      varchar(sc.typename,106)," )
       asis ( "  bigint(sc.length),     bigint(0),              sc.scale,        sc.nulls," ) asis (
      "  sc.colno,              bigint(length(sc.default))," ) asis ( "  CASE sc.identity" ) asis (
      "    when 'Y' THEN" ) asis ( "      CASE sc.generated" ) asis (
      "        when 'D' THEN 'GENERATED BY DEFAULT AS IDENTITY'" ) asis ( "        else sc.default" )
       asis ( "      END" ) asis ( "    else sc.default" ) asis ( "  END," ) asis ( "  sc.colcard," )
       asis ( "  sc.low2key,            sc.high2key,            sc.nmostfreq,    sc.numnulls," ) asis
       ( "  sc.nquantiles,         current timestamp,      bigint(0),       varchar(sc.logged,3)," )
      asis ( "  varchar(sc.compact,3), varchar(sc.identity,3), varchar(sc.generated,3)" ) asis (
      "from syscat.columns sc" )
      END ;Rdb
      IF (check_error("CREATING DM2_DBA_TAB_COLUMNS VIEW")=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ELSE
       COMMIT
      ENDIF
     ENDIF
     IF (((sdi_def2_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
      IF (sdi_def2_exists_ind=1)
       DROP TABLE dm2_dba_tab_columns
       IF (check_error("Dropping DM2_DBA_TAB_COLUMNS table def.")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
      DROP DDLRECORD dm2_dba_tab_columns FROM DATABASE v500 WITH deps_deleted
      CREATE DDLRECORD dm2_dba_tab_columns FROM DATABASE v500
 TABLE dm2_dba_tab_columns
  1 owner  = vc128 CCL(owner)
  1 table_name  = vc128 CCL(table_name)
  1 column_name  = vc128 CCL(column_name)
  1 data_type  = vc106 CCL(data_type)
  1 data_length  = f8 CCL(data_length)
  1 data_precision  = f8 CCL(data_precision)
  1 data_scale  = f8 CCL(data_scale)
  1 nullable  = c1 CCL(nullable)
  1 column_id  = f8 CCL(column_id)
  1 default_length  = f8 CCL(default_length)
  1 data_default  = vc2000 CCL(data_default)
  1 num_distinct  = f8 CCL(num_distinct)
  1 low_value  = gc32 CCL(low_value)
  1 high_value  = gc32 CCL(high_value)
  1 density  = f8 CCL(density)
  1 num_nulls  = f8 CCL(num_nulls)
  1 num_buckets  = f8 CCL(num_buckets)
  1 last_analyzed  = di8 CCL(last_analyzed)
  1 sample_size  = f8 CCL(sample_size)
  1 logged  = c3 CCL(logged)
  1 compact  = c3 CCL(compact)
  1 identity_ind  = c3 CCL(identity_ind)
  1 generated  = c3 CCL(generated)
 END TABLE dm2_dba_tab_columns
      IF (check_error("Creating DM2_DBA_TAB_COLUMNS table def.")=1)
       ROLLBACK
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
    OF "SQLSRV":
     SELECT INTO "nl:"
      FROM dtable d
      WHERE d.table_name IN ("TABLES", "DM2_DBA_TAB_COLUMNS")
      DETAIL
       CASE (d.table_name)
        OF "TABLES":
         sdi_def1_exists_ind = 1
        OF "DM2_DBA_TAB_COLUMNS":
         sdi_def2_exists_ind = 1
       ENDCASE
      WITH nocounter
     ;end select
     IF (check_error("Verifying TABLES & DM2_DBA_TAB_COLUMNS table defs exist.")=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF (((sdi_def1_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
      IF (sdi_def1_exists_ind=1)
       DROP TABLE tables
       IF (check_error("Dropping TABLES definition.")=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
      DROP DDLRECORD tables FROM DATABASE v500 WITH deps_deleted
      CREATE DDLRECORD tables FROM DATABASE v500
 TABLE tables
  1 table_catalog  = vc128 CCL(table_catalog)
  1 table_schema  = vc128 CCL(table_schema)
  1 table_name  = vc128 CCL(table_name)
  1 table_type  = vc10 CCL(table_type)
 END TABLE tables
      IF (check_error("Generating TABLES CCL definition.")=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
     ENDIF
     IF (sbr_sdi_regen_ind IN (0, 1))
      SELECT INTO "nl:"
       FROM (information_schema.tables t)
       WHERE t.table_name="DM2_DBA_TAB_COLUMNS"
        AND t.table_schema=sdi_def_cur_user
        AND t.table_type="VIEW"
       WITH nocounter
      ;end select
      IF (check_error("Determining whether DM2_DBA_TAB_COLUMNS view already exists.")=1)
       CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
       RETURN(0)
      ENDIF
      IF (((curqual=0) OR (sbr_sdi_regen_ind=1)) )
       IF (curqual=1)
        RDB drop view dm2_dba_tab_columns
        END ;Rdb
        IF (check_error("Dropping DM2_DBA_TAB_COLUMNS view.")=1)
         ROLLBACK
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
       ENDIF
       RDB asis ( "create view DM2_DBA_TAB_COLUMNS as select " ) asis ( " c.TABLE_SCHEMA OWNER," )
       asis ( " c.TABLE_NAME TABLE_NAME," ) asis ( " c.COLUMN_NAME COLUMN_NAME, " ) asis (
       " convert(varchar(106), UPPER(c.DATA_TYPE)) DATA_TYPE, " ) asis (
       " convert(int,isnull(c.CHARACTER_MAXIMUM_LENGTH, c.NUMERIC_PRECISION)) DATA_LENGTH, " ) asis (
        " convert(int,c.NUMERIC_PRECISION) DATA_PRECISION, " ) asis (
       " convert(int,c.NUMERIC_SCALE) DATA_SCALE, " ) asis (
       " convert(varchar(1), c.IS_NULLABLE) NULLABLE, " ) asis (
       " convert(int, c.ORDINAL_POSITION) COLUMN_ID, " ) asis (
       " convert(int, len(c.COLUMN_DEFAULT)) DEFAULT_LENGTH, " ) asis (
       " convert(varchar(8000),CASE columnproperty(object_id(c.TABLE_SCHEMA+'.'+c.TABLE_NAME),  " )
       asis ( "             c.COLUMN_NAME,'IsIdentity') " ) asis (
       "                         WHEN 1 THEN 'IDENTITY(1,1)' " ) asis (
       "                         ELSE substring(c.COLUMN_DEFAULT,2,(len(c.COLUMN_DEFAULT) - 2)) " )
       asis ( "                       END) DATA_DEFAULT, " ) asis (
       " convert(int,null) NUM_DISTINCT, " ) asis ( " convert(varchar(32),'N/A') LOW_VALUE, " ) asis
       ( " convert(varchar(32),'N/A') HIGH_VALUE, " ) asis ( " convert(int,null) DENSITY, " ) asis (
       " convert(int,0) NUM_NULLS, " ) asis ( " convert(int,null) NUM_BUCKETS, " ) asis (
       " convert(datetime,'1900/01/01') LAST_ANALYZED, " ) asis ( " convert(int,0) SAMPLE_SIZE, " )
       asis ( " convert(varchar(3),'N/A') LOGGED, " ) asis ( " convert(varchar(3),'N/A') COMPACT, " )
        asis ( " convert(varchar(3), 'N/A') IDENTITY_IND, " ) asis (
       " convert(varchar(3), 'N/A') GENERATED " ) asis ( "from INFORMATION_SCHEMA.COLUMNS c " ) asis
       ( "union all" ) asis ( "select" ) asis ( " c2.TABLE_SCHEMA OWNER," ) asis (
       " c2.TABLE_NAME TABLE_NAME," ) asis ( " c2.COLUMN_NAME COLUMN_NAME, " ) asis (
       " convert(varchar(106), UPPER(c2.DATA_TYPE)) DATA_TYPE, " ) asis (
       " convert(int,isnull(c2.CHARACTER_MAXIMUM_LENGTH, c2.NUMERIC_PRECISION)) DATA_LENGTH, " ) asis
        ( " convert(int,c2.NUMERIC_PRECISION) DATA_PRECISION, " ) asis (
       " convert(int,c2.NUMERIC_SCALE) DATA_SCALE, " ) asis (
       " convert(varchar(1), c2.IS_NULLABLE) NULLABLE, " ) asis (
       " convert(int, c2.ORDINAL_POSITION) COLUMN_ID, " ) asis (
       " convert(int, len(c2.COLUMN_DEFAULT)) DEFAULT_LENGTH, " ) asis (
       " convert(varchar(8000),CASE columnproperty(object_id(c2.TABLE_SCHEMA+'.'+c2.TABLE_NAME),  " )
        asis ( "             c2.COLUMN_NAME,'IsIdentity') " ) asis (
       "                         WHEN 1 THEN 'IDENTITY(1,1)' " ) asis (
       "                         ELSE substring(c2.COLUMN_DEFAULT,2,(len(c2.COLUMN_DEFAULT) - 2)) " )
        asis ( "                       END) DATA_DEFAULT, " ) asis (
       " convert(int,null) NUM_DISTINCT, " ) asis ( " convert(varchar(32),'N/A') LOW_VALUE, " ) asis
       ( " convert(varchar(32),'N/A') HIGH_VALUE, " ) asis ( " convert(int,null) DENSITY, " ) asis (
       " convert(int,0) NUM_NULLS, " ) asis ( " convert(int,null) NUM_BUCKETS, " ) asis (
       " convert(datetime,'1900/01/01') LAST_ANALYZED, " ) asis ( " convert(int,0) SAMPLE_SIZE, " )
       asis ( " convert(varchar(3),'N/A') LOGGED, " ) asis ( " convert(varchar(3),'N/A') COMPACT, " )
        asis ( " convert(varchar(3), 'N/A') IDENTITY_IND, " ) asis (
       " convert(varchar(3), 'N/A') GENERATED " ) asis ( "from master.INFORMATION_SCHEMA.COLUMNS c2 "
        ) asis ( "where c2.TABLE_SCHEMA = 'INFORMATION_SCHEMA'" )
       END ;Rdb
       IF (check_error("CREATING DM2_DBA_TAB_COLUMNS VIEW")=1)
        ROLLBACK
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ELSE
        COMMIT
       ENDIF
      ENDIF
      IF (((sdi_def2_exists_ind=0) OR (sbr_sdi_regen_ind=1)) )
       IF (sdi_def2_exists_ind=1)
        DROP TABLE dm2_dba_tab_columns
        IF (check_error("Dropping DM2_DBA_TAB_COLUMNS table def.")=1)
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(0)
        ENDIF
       ENDIF
       DROP DDLRECORD dm2_dba_tab_columns FROM DATABASE v500 WITH deps_deleted
       CREATE DDLRECORD dm2_dba_tab_columns FROM DATABASE v500
 TABLE dm2_dba_tab_columns
  1 owner  = vc128 CCL(owner)
  1 table_name  = vc128 CCL(table_name)
  1 column_name  = vc128 CCL(column_name)
  1 data_type  = vc106 CCL(data_type)
  1 data_length  = f8 CCL(data_length)
  1 data_precision  = f8 CCL(data_precision)
  1 data_scale  = f8 CCL(data_scale)
  1 nullable  = c1 CCL(nullable)
  1 column_id  = f8 CCL(column_id)
  1 default_length  = f8 CCL(default_length)
  1 data_default  = vc2000 CCL(data_default)
  1 num_distinct  = f8 CCL(num_distinct)
  1 low_value  = gc32 CCL(low_value)
  1 high_value  = gc32 CCL(high_value)
  1 density  = f8 CCL(density)
  1 num_nulls  = f8 CCL(num_nulls)
  1 num_buckets  = f8 CCL(num_buckets)
  1 last_analyzed  = di8 CCL(last_analyzed)
  1 sample_size  = f8 CCL(sample_size)
  1 logged  = c3 CCL(logged)
  1 compact  = c3 CCL(compact)
  1 identity_ind  = c3 CCL(identity_ind)
  1 generated  = c3 CCL(generated)
 END TABLE dm2_dba_tab_columns
       IF (check_error("Creating DM2_DBA_TAB_COLUMNS table def.")=1)
        CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
        RETURN(0)
       ENDIF
      ENDIF
     ENDIF
   ENDCASE
   COMMIT
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_appl_status(gas_appl_id)
   DECLARE gas_error_status = c1 WITH protect, constant("E")
   DECLARE gas_active_status = c1 WITH protect, constant("A")
   DECLARE gas_inactive_status = c1 WITH protect, constant("I")
   DECLARE gas_text = vc WITH protect, noconstant(" ")
   DECLARE gas_currdblink = vc WITH protect, noconstant(cnvtupper(trim(currdblink,3)))
   DECLARE gas_appl_id_cvt = vc WITH protect, noconstant(" ")
   IF (currdb="DB2UDB")
    SET gas_appl_id_cvt = replace(trim(gas_appl_id,3),"*","\*",0)
    SELECT INTO "nl:"
     FROM dm2_user_views
     WHERE view_name="DM2_SNAP_APPL_INFO"
     WITH nocounter
    ;end select
    IF (check_error("Selecting from dm2_user_views in subroutine DM2_GET_APPL_STATUS")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ENDIF
    IF (curqual=0)
     SET gas_text = concat("RDB ASIS (^ ","CREATE VIEW DM2_SNAP_APPL_INFO AS ",
      " ( SELECT * FROM TABLE(SNAPSHOT_APPL_INFO('",gas_currdblink,"',-1 )) AS SNAPSHOT_APPL_INFO )",
      " ^) GO ")
     IF (dm2_push_cmd(gas_text,1) != 1)
      ROLLBACK
      RETURN(gas_error_status)
     ELSE
      COMMIT
      EXECUTE oragen3 "DM2_SNAP_APPL_INFO"
      IF ((dm_err->err_ind=1))
       RETURN(gas_error_status)
      ENDIF
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     FROM dtable
     WHERE table_name="DM2_SNAP_APPL_INFO"
     WITH nocounter
    ;end select
    IF (check_error("Selecting from dtable in subroutine DM2_GET_APPL_STATUS")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ENDIF
    IF (curqual != 1)
     EXECUTE oragen3 "DM2_SNAP_APPL_INFO"
     IF ((dm_err->err_ind=1))
      RETURN(gas_error_status)
     ENDIF
    ENDIF
    SET gas_text = concat('select into "nl:" from DM2_SNAP_APPL_INFO where appl_id = "',
     gas_appl_id_cvt,'" with nocounter go')
    IF (dm2_push_cmd(gas_text,1) != 1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ENDIF
    IF (curqual=1)
     RETURN(gas_active_status)
    ELSE
     RETURN(gas_inactive_status)
    ENDIF
   ELSEIF (currdb="SQLSRV")
    DECLARE gas_str_loc1 = i4 WITH protect, noconstant(0)
    DECLARE gas_str_loc2 = i4 WITH protect, noconstant(0)
    DECLARE gas_str_loc3 = i4 WITH protect, noconstant(0)
    DECLARE gas_spid = i4 WITH protect, noconstant(0)
    DECLARE gas_login_date = vc WITH protect, noconstant(" ")
    DECLARE gas_login_time = i4 WITH protect, noconstant(0)
    SET gas_str_loc1 = findstring("-",trim(gas_appl_id,3),1,0)
    SET gas_str_loc2 = findstring(" ",trim(gas_appl_id,3),1,1)
    SET gas_str_loc3 = findstring(":",trim(gas_appl_id,3),1,1)
    IF (((gas_str_loc1=0) OR (((gas_str_loc2=0) OR (gas_str_loc3=0)) )) )
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "Invalid application handle"
     SET dm_err->eproc =
     "Parsing through application handle to determine spid and login date and time"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ELSE
     SET gas_spid = cnvtint(build(substring(1,(gas_str_loc1 - 1),trim(gas_appl_id,3))))
     SET gas_login_date = cnvtupper(cnvtalphanum(substring((gas_str_loc1+ 1),(gas_str_loc2 -
        gas_str_loc1),trim(gas_appl_id,3))))
     SET gas_login_time = cnvtint(cnvtalphanum(substring(gas_str_loc2,(gas_str_loc3 - gas_str_loc2),
        trim(gas_appl_id,3))))
    ENDIF
    SELECT INTO "nl:"
     FROM sysprocesses p
     WHERE p.spid=gas_spid
      AND p.login_time=cnvtdatetime(cnvtdate2(gas_login_date,"DDMMMYYYY"),gas_login_time)
     WITH nocounter
    ;end select
    IF (check_error("Selecting from sysprocesses in subroutine DM2_GET_APPL_STATUS")=1)
     ROLLBACK
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ELSEIF (curqual=0)
     RETURN(gas_inactive_status)
    ELSE
     RETURN(gas_active_status)
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM v$session s
     WHERE s.audsid=cnvtint(gas_appl_id)
     WITH nocounter
    ;end select
    IF (check_error("Selecting from v$session in subroutine DM2_GET_APPL_STATUS")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(gas_error_status)
    ELSEIF (curqual=0)
     RETURN(gas_inactive_status)
    ELSE
     RETURN(gas_active_status)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_cleanup_stranded_appl(null)
   DECLARE dcsa_applx = i4 WITH protect, noconstant(0)
   DECLARE dcsa_fmt_appl_id = vc WITH protect, noconstant(" ")
   DECLARE dcsa_error_msg = vc WITH protect, noconstant(" ")
   FREE RECORD dcsa_appl_rs
   RECORD dcsa_appl_rs(
     1 dcsa_appl_cnt = i4
     1 dcsa_appl[*]
       2 dcsa_appl_id = vc
   )
   SELECT INTO "nl:"
    FROM dm2_user_tables ut
    WHERE ut.table_name="DM2_DDL_OPS_LOG*"
    WITH nocounter
   ;end select
   IF (check_error("Find_Stranded_Runner - DDL_OPS_LOG table existence check")=true)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(false)
   ENDIF
   IF (curqual=0)
    CALL echo(
     "dm2_ddl_ops_log table not found in dm2_user_tables, bypassing dm2_cleanup_stranded_appl logic..."
     )
    RETURN(1)
   ELSE
    IF ((dm_err->debug_flag > 1))
     CALL echo("Curqual from user_tables for dm2_ddl_ops_log* returned != 0")
    ENDIF
   ENDIF
   SELECT DISTINCT INTO "nl:"
    ddol_appl_id = ddol.appl_id
    FROM dm2_ddl_ops_log ddol
    WHERE ddol.status IN ("RUNNING", null)
    HEAD REPORT
     dcsa_applx = 0
    DETAIL
     dcsa_applx = (dcsa_applx+ 1)
     IF (mod(dcsa_applx,10)=1)
      stat = alterlist(dcsa_appl_rs->dcsa_appl,(dcsa_applx+ 9))
     ENDIF
     dcsa_appl_rs->dcsa_appl[dcsa_applx].dcsa_appl_id = ddol_appl_id
    FOOT REPORT
     dcsa_appl_rs->dcsa_appl_cnt = dcsa_applx, stat = alterlist(dcsa_appl_rs->dcsa_appl,dcsa_applx)
    WITH nocounter
   ;end select
   IF (check_error("Find_Stranded_Runner - Select")=true)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(false)
   ENDIF
   IF ((dcsa_appl_rs->dcsa_appl_cnt > 0))
    SET dcsa_applx = 1
    WHILE ((dcsa_applx <= dcsa_appl_rs->dcsa_appl_cnt))
      SET dcsa_fmt_appl_id = dcsa_appl_rs->dcsa_appl[dcsa_applx].dcsa_appl_id
      CASE (dm2_get_appl_status(value(dcsa_appl_rs->dcsa_appl[dcsa_applx].dcsa_appl_id)))
       OF "I":
        SET dcsa_error_msg = concat("Application Id ",trim(dcsa_fmt_appl_id))
        SET dcsa_error_msg = concat(dcsa_error_msg," is no longer active.")
        UPDATE  FROM dm2_ddl_ops_log ddol
         SET ddol.status = "ERROR", ddol.error_msg = dcsa_error_msg, ddol.end_dt_tm = cnvtdatetime(
           curdate,curtime3)
         WHERE ddol.appl_id=dcsa_fmt_appl_id
          AND ddol.status IN ("RUNNING", null)
        ;end update
        IF (check_error("Find_Stranded_Processes - Update")=true)
         ROLLBACK
         CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
         RETURN(false)
        ELSE
         COMMIT
        ENDIF
       OF "A":
        IF ((dm_err->debug_flag > 0))
         CALL echo(build("Application Id ",dcsa_fmt_appl_id," is active."))
        ENDIF
       OF "E":
        IF ((dm_err->debug_flag > 0))
         CALL echo("Error Detected in dm2_get_appl_status")
        ENDIF
        RETURN(false)
      ENDCASE
      SET dcsa_applx = (dcsa_applx+ 1)
    ENDWHILE
   ELSE
    IF ((dm_err->debug_flag > 0))
     CALL echo("********** No Application Ids Detected **********")
    ENDIF
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE dm2_table_exists(dte_table_name)
  SELECT INTO "nl:"
   FROM dm2_user_tab_columns dutc,
    dtable dt
   WHERE dutc.table_name=trim(cnvtupper(dte_table_name))
    AND dutc.table_name=dt.table_name
   WITH nocounter
  ;end select
  IF (check_error(dm_err->eproc)=1)
   CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
   RETURN("E")
  ELSE
   IF (curqual=0)
    RETURN("N")
   ELSE
    RETURN("F")
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE dm2_set_autocommit(sbr_dsa_flag)
   IF ( NOT (sbr_dsa_flag IN (0, 1)))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid autocommit flag"
    SET dm_err->eproc = "Setting autocommit indicator"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (currdb="SQLSRV")
    IF (currdbhandle > " ")
     IF (sbr_dsa_flag=1)
      IF (dm2_push_cmd("rdb set autocommit go",1)=0)
       RETURN(0)
      ENDIF
      IF (dm2_push_cmd("rdb set inlineparameters go",1)=0)
       RETURN(0)
      ENDIF
     ELSE
      IF (dm2_push_cmd("rdb set noautocommit go",1)=0)
       RETURN(0)
      ENDIF
      IF (dm2_push_cmd("rdb set noinlineparameters go",1)=0)
       RETURN(0)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_get_srvname(sbr_spc_view)
   IF ( NOT (sbr_spc_view IN (0, 1)))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid view indicator"
    SET dm_err->eproc = "Retrieving server name"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF (currdb="SQLSRV")
    IF (sbr_spc_view=0)
     SELECT INTO "nl:"
      FROM sysservers s
      WHERE s.srvproduct="SQL Server"
       AND s.srvname=s.datasource
       AND s.srvid=0
       AND s.isremote=0
      DETAIL
       dm2_install_schema->servername = s.srvname, dm2_install_schema->frmt_servername = cnvtupper(
        replace(trim(s.srvname,3),"\","_",1))
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM dm2syssrv s
      WHERE s.srvproduct="SQL Server"
       AND s.srvname=s.datasource
       AND s.srvid=0
       AND s.isremote=0
      DETAIL
       dm2_install_schema->servername = s.srvname, dm2_install_schema->frmt_servername = cnvtupper(
        replace(trim(s.srvname,3),"\","_",1))
      WITH nocounter
     ;end select
    ENDIF
    IF (check_error("Retreiving server name in subroutine DM2_GET_SRVNAME")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=0)
     SET dm_err->err_ind = 1
     SET dm_err->emsg = "No row qualified"
     SET dm_err->eproc = "Retreiving server name in subroutine DM2_GET_SRVNAME"
     CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_prg_maint(sbr_maint_type)
   IF ( NOT (cnvtupper(trim(sbr_maint_type,3)) IN ("BEGIN", "END")))
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Invalid maintenance type"
    SET dm_err->eproc = "Performing program maintenance"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 1))
    CALL echo("********************************************************")
    CALL echo("* CCL current resource usage statistics                *")
    CALL echo("********************************************************")
    CALL trace(7)
   ENDIF
   IF (cnvtupper(trim(sbr_maint_type,3))="BEGIN")
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF (dm2_set_autocommit(0)=0)
     RETURN(0)
    ENDIF
    SET dm2_install_schema->curprog = curprog
   ELSE
    IF (dm2_set_autocommit(0)=0)
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_fill_nick_except(sbr_alias)
   DECLARE dfne_in_clause = vc WITH public, noconstant("")
   SET dfne_in_clause = concat("substring(1,3,",sbr_alias,".table_name) != 'DM2' ")
   SET dfne_in_clause = concat(dfne_in_clause," and ",sbr_alias,".table_name not in ('DM_INFO',",
    "'DM_SEGMENTS',",
    "'DM_TABLE_LIST',","'DM_USER_CONSTRAINTS',","'DM_USER_CONS_COLUMNS',","'DM_USER_IND_COLUMNS',",
    "'DM_USER_TAB_COLS',",
    "'EXPLAIN_ARGUMENT',","'EXPLAIN_INSTANCE',","'EXPLAIN_OBJECT',","'EXPLAIN_OPERATOR',",
    "'EXPLAIN_PREDICATE',",
    "'EXPLAIN_STATEMENT',","'EXPLAIN_STREAM') ")
   RETURN(dfne_in_clause)
 END ;Subroutine
 SUBROUTINE prompt_for_host(sbr_host_db)
   DECLARE pfah_choice = vc WITH protect, noconstant(" ")
   SET message = window
   SET width = 132
   CALL clear(1,1)
   CALL video(n)
   CALL text(2,1,concat("Creating a database connection to the ",cnvtupper(sbr_host_db)," database: "
     ),w)
   IF (currdb IN ("ORACLE", "DB2UDB"))
    CALL text(4,1,
     ">>> In the Host Name field, type the database server system's host name or IP address.")
   ELSE
    CALL text(4,1,
     ">>> In the Host Name field, type the database's server name (include named instance).")
   ENDIF
   CALL box(6,5,8,120)
   CALL text(7,7,"Host Name: ")
   CALL text(10,1,">>> Enter 'C' to continue or 'Q' to quit (C or Q) :")
   CALL accept(7,18,"P(100);C"," "
    WHERE  NOT (curaccept=" "))
   SET dm2_install_schema->hostname = trim(curaccept,3)
   CALL accept(10,53,"A;cu","C"
    WHERE curaccept IN ("Q", "C"))
   SET pfah_choice = curaccept
   SET message = nowindow
   IF (pfah_choice="Q")
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_val_file_prefix(sbr_file_prefix)
   DECLARE sbr_vfp_sch_date_fmt = f8 WITH protect
   DECLARE sbr_vfp_dir = vc WITH protect
   IF (findstring("-",sbr_file_prefix) IN (0, 1))
    SET dm2_install_schema->schema_prefix = "dm2o"
    SET dm2_install_schema->file_prefix = sbr_file_prefix
   ELSE
    IF ((dm2_install_schema->process_option IN ("ADMIN CREATE", "ADMIN UPGRADE")))
     SET dm2_install_schema->schema_prefix = "dm2a"
    ELSE
     SET dm2_install_schema->schema_prefix = "dm2c"
    ENDIF
    IF (dm2_val_sch_date_str(sbr_file_prefix)=0)
     RETURN(0)
    ELSE
     SET sbr_vfp_sch_date_fmt = cnvtdate2(sbr_file_prefix,"DD-MMM-YYYY")
     SET dm2_install_schema->file_prefix = cnvtalphanum(format(sbr_vfp_sch_date_fmt,"MM/DD/YYYY;;D"))
    ENDIF
   ENDIF
   IF ((((dm2_install_schema->schema_prefix="dm2o")) OR ((dm2_install_schema->process_option=
   "INHOUSE"))) )
    SET sbr_vfp_dir = dm2_install_schema->ccluserdir
    SET dm2_install_schema->schema_loc = "ccluserdir"
   ELSE
    SET sbr_vfp_dir = dm2_install_schema->cer_install
    SET dm2_install_schema->schema_loc = "cer_install"
   ENDIF
   IF (findfile(build(sbr_vfp_dir,cnvtlower(trim(dm2_install_schema->schema_prefix)),cnvtlower(trim(
       dm2_install_schema->file_prefix)),cnvtlower(dm2_sch_file->qual[1].file_suffix),".dat"))=0)
    SET dm_err->emsg = concat("Schema files not found for file prefix ",sbr_file_prefix," in ",
     sbr_vfp_dir)
    SET dm_err->eproc = "File Prefix Validation"
    SET dm_err->user_action = "Schema files not found.  Please enter a valid file prefix."
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_validate_dblink(vdl_linkname)
   DECLARE vdl_dot_pos = i4 WITH protect, noconstant(0)
   DECLARE vdl_match_cnt = i4 WITH protect, noconstant(0)
   SET vdl_linkname = trim(vdl_linkname,3)
   IF (findstring(".",vdl_linkname,1) > 0)
    SET dm_err->emsg = concat("dm2_common_routines,dm2_validate_dblink:  ","The database link name (",
     vdl_linkname,") is invalid.  Millenium / CCL ",
     "does not support dots (.) in database link names for SQL purposes.")
    SET dm_err->user_action = concat(
     "Specify the base part of the link name only in the command.    ",
     "Example1: Specify ADMIN instead of ADMIN.WORLD or ADMIN.WORLD.COM    ",
     "Example2: Select * from table_name@ADMIN vs select * from table_name@ADMIN.WORLD    ",
     "Example3: Oragen3 'table_name@ADMIN' vs Oragen3 'table_name@ADMIN.WORLD")
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM all_db_links adl
    DETAIL
     vdl_dot_pos = findstring(".",adl.db_link,1)
     IF (vdl_dot_pos=0)
      IF (cnvtupper(vdl_linkname)=cnvtupper(adl.db_link))
       dm2_install_schema->adl_username = adl.username, vdl_match_cnt = (vdl_match_cnt+ 1)
      ENDIF
     ELSE
      IF (cnvtupper(vdl_linkname)=cnvtupper(substring(1,(vdl_dot_pos - 1),adl.db_link)))
       dm2_install_schema->adl_username = adl.username, vdl_match_cnt = (vdl_match_cnt+ 1)
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SET dm_err->eproc = "Selecting against all_db_links to validate database link name."
   IF (check_error(dm_err->eproc) != 0)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (vdl_match_cnt != 1)
    IF (vdl_match_cnt=0)
     SET dm_err->emsg = concat("dm2_common_routines,dm2_validate_dblink:  The database link name (",
      vdl_linkname,") was not found to be a valid database link name in ALL_DB_LINKS. ")
    ELSEIF (vdl_match_cnt > 1)
     SET dm_err->emsg = concat(
      "dm2_common_routines,dm2_validate_dblink:  Multiple occurences of the database ","link name (",
      vdl_linkname,") was found in ALL_DB_LINKS.  To prevent Millenium ",
      "processing errors, the first part of the database link name (text before the first ",
      "'.') needs to be unique.")
    ENDIF
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_include_exclude_list(null)
   DECLARE diel_where_clause = vc WITH public, noconstant("")
   SET dm_err->eproc = "Creating list of data_model_section values to include/exclude"
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="DM2_INCL_EXCL"
    ORDER BY d.info_char
    HEAD REPORT
     diel_where_clause = " "
    HEAD d.info_char
     cnt = 0
     IF (diel_where_clause=" ")
      IF (cnvtupper(d.info_char)="INCLUDE")
       diel_where_clause = "td.data_model_section in "
      ELSEIF (cnvtupper(d.info_char)="EXCLUDE")
       diel_where_clause = "td.data_model_section not in "
      ELSE
       diel_where_clause = "ERROR - invalid type"
      ENDIF
     ELSE
      diel_where_clause = "ERROR - can only process one type (include/exclude)"
     ENDIF
    DETAIL
     IF (substring(1,5,diel_where_clause) != "ERROR")
      cnt = (cnt+ 1)
      IF (cnt > 1)
       diel_where_clause = concat(diel_where_clause,"','",trim(d.info_name,3))
      ELSE
       diel_where_clause = concat(diel_where_clause," ('",trim(d.info_name,3))
      ENDIF
     ENDIF
    FOOT REPORT
     IF (substring(1,5,diel_where_clause) != "ERROR")
      diel_where_clause = concat(diel_where_clause,"')")
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET diel_where_clause = "ERROR"
   ELSEIF (curqual=0)
    SET diel_where_clause = "NONE"
   ELSEIF (substring(1,5,diel_where_clause)="ERROR")
    SET dm_err->emsg = diel_where_clause
    SET dm_err->err_ind = 1
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET diel_where_clause = "ERROR"
   ENDIF
   RETURN(diel_where_clause)
 END ;Subroutine
 SUBROUTINE dm2_get_rdbms_version(null)
   DECLARE dgrv_level = i2 WITH protect, noconstant(0)
   DECLARE dgrv_loc = i2 WITH protect, noconstant(0)
   DECLARE dgrv_prev_loc = i2 WITH protect, noconstant(0)
   DECLARE dgrv_loop = i2 WITH protect, noconstant(0)
   DECLARE dgrv_len = i2 WITH protect, noconstant(0)
   IF (currdb IN ("DB2UDB", "SQLSRV"))
    RETURN(1)
   ENDIF
   SELECT INTO "nl:"
    FROM product_component_version p
    WHERE cnvtupper(p.product)="ORACLE*"
    DETAIL
     dm2_rdbms_version->version = p.version
    WITH nocounter
   ;end select
   IF (check_error("Getting product component version")=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSEIF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Product component version not found."
    SET dm_err->eproc = "Getting product component version"
    CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
    RETURN(0)
   ENDIF
   WHILE (dgrv_loop=0)
     SET dgrv_level = (dgrv_level+ 1)
     SET dgrv_loc = 0
     SET dgrv_prev_loc = dgrv_loc
     SET dgrv_loc = findstring(".",dm2_rdbms_version->version,(dgrv_prev_loc+ 1),0)
     IF (dgrv_loc > 0)
      SET dgrv_len = ((dgrv_loc - dgrv_prev_loc) - 1)
      CASE (dgrv_level)
       OF 1:
        SET dm2_rdbms_version->level1 = cnvtint(substring(1,dgrv_len,dm2_rdbms_version->version))
       OF 2:
        SET dm2_rdbms_version->level2 = cnvtint(substring((dgrv_prev_loc+ 1),dgrv_len,
          dm2_rdbms_version->version))
       OF 3:
        SET dm2_rdbms_version->level3 = cnvtint(substring((dgrv_prev_loc+ 1),dgrv_len,
          dm2_rdbms_version->version))
       OF 4:
        SET dm2_rdbms_version->level4 = cnvtint(substring((dgrv_prev_loc+ 1),dgrv_len,
          dm2_rdbms_version->version))
       OF 5:
        SET dm2_rdbms_version->level5 = cnvtint(substring((dgrv_prev_loc+ 1),dgrv_len,
          dm2_rdbms_version->version))
       ELSE
        SET dgrv_loop = 1
      ENDCASE
     ELSE
      IF (dgrv_level=1)
       SET dm_err->err_ind = 1
       SET dm_err->emsg = "Product component version not in expected format."
       SET dm_err->eproc = "Getting product component version"
       CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
       RETURN(0)
      ENDIF
      SET dgrv_loop = 1
     ENDIF
   ENDWHILE
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_set_inhouse_domain(null)
   DECLARE dsid_tbl_ind = c1 WITH protect, noconstant(" ")
   IF (validate(dm2_inhouse_flag,- (1)) > 0)
    SET dm_err->eproc = "Inhouse Domain Detected."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET inhouse_misc->inhouse_domain = 1
    RETURN(1)
   ENDIF
   SET dm_err->eproc = "Determining whether table dm_info exists"
   SET dsid_tbl_ind = dm2_table_exists("DM_INFO")
   IF ((dm_err->err_ind=1))
    RETURN(0)
   ENDIF
   IF (dsid_tbl_ind="F")
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="INHOUSE DOMAIN"
     WITH nocounter
    ;end select
    IF (check_error("Determine if process running in an in-house domain")=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF (curqual=1)
     SET inhouse_misc->inhouse_domain = 1
    ELSE
     SET inhouse_misc->inhouse_domain = 0
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_set_nn_default(dsn_datatype)
   IF (currdb="ORACLE")
    DECLARE dsn_default = vc
    IF (dsn_datatype IN ("NUMBER", "FLOAT"))
     SET dsn_default = "0"
    ELSEIF (dsn_datatype="DATE")
     SET dsn_default = "TO_DATE('01/01/1900 00:00:00', 'MM/DD/YYYY HH24:MI:SS')"
    ELSEIF (dsn_datatype="*CHAR*")
     SET dsn_default = "' '"
    ELSE
     SET dsn_default = "ERROR"
    ENDIF
    RETURN(dsn_default)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_findfile(sbr_file_path)
   DECLARE dff_cmd_txt = vc WITH protect, noconstant(" ")
   DECLARE dff_err_str = vc WITH protect, noconstant(" ")
   DECLARE dff_tmp_err_ind = i2 WITH protect, noconstant(0)
   IF (cursys="AIX")
    SET dff_cmd_txt = concat("ls -l ",sbr_file_path)
    SET dff_err_str = concat(sbr_file_path," does not exist")
   ENDIF
   IF (cursys="AXP")
    CALL dm2_push_dcl(concat('@cer_install:dm2_findfile_os.com "',sbr_file_path,'"'))
   ELSE
    CALL dm2_push_dcl(dff_cmd_txt)
   ENDIF
   IF ((dm_err->err_ind=1))
    SET dm_err->err_ind = 0
    SET dff_tmp_err_ind = 1
   ENDIF
   IF (parse_errfile(dm_err->errfile)=0)
    RETURN(0)
   ENDIF
   IF (cursys="AIX")
    IF (findstring(dff_err_str,dm_err->errtext,1,0) > 0)
     CALL echo("This is an acceptable error.")
     SET dm_err->emsg = concat("File",sbr_file_path," not found.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,0)
     RETURN(0)
    ELSEIF (dff_tmp_err_ind=1)
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
   ELSEIF (cursys="AXP")
    IF ((dm_err->errtext="NOT FOUND"))
     SET dm_err->emsg = concat("File",sbr_file_path," not found.")
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     RETURN(0)
    ELSEIF ((dm_err->errtext="FOUND"))
     RETURN(1)
    ELSEIF (((dff_tmp_err_ind=1) OR ( NOT ((dm_err->errtext IN ("FOUND", "NOT FOUND"))))) )
     SET dm_err->emsg = dm_err->errtext
     SET dm_err->eproc = "Error in DM2_FINDFILE"
     SET dm_err->err_ind = 1
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2_setup_dbase_env(null)
   DECLARE max_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE new_env_id = f8 WITH protect, noconstant(0.0)
   DECLARE dsdes_connect_str = vc WITH protect, noconstant(" ")
   IF (currdb="ORACLE")
    SET dsdes_cnnct_str = cnvtlower(build("v500","/",dm2_install_schema->v500_p_word,"@",
      dm2_install_schema->v500_connect_str))
   ELSE
    SET dsdes_cnnct_str = build("v500","/",dm2_install_schema->v500_p_word,"/",dm2_install_schema->
     v500_connect_str)
   ENDIF
   SET dm_err->eproc = "Determining if environment already set up."
   CALL disp_msg(" ",dm_err->logfile,0)
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_environment e
    WHERE cnvtupper(e.environment_name)=cnvtupper(dm2_install_schema->target_env_name)
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->eproc = "Determining next environment id."
    CALL disp_msg(" ",dm_err->logfile,0)
    IF (currdb="ORACLE")
     SELECT INTO "nl:"
      y = seq(dm_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_env_id = cnvtreal(y)
      WITH format, nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     IF ((dm_err->debug_flag > 0))
      CALL echo(dm_err->asterisk_line)
      CALL echo(build("new_env_id=",new_env_id))
      CALL echo(dm_err->asterisk_line)
     ENDIF
    ELSE
     SELECT INTO "nl:"
      FROM dm_environment e
      FOOT REPORT
       max_env_id = max(e.environment_id)
      WITH nocounter
     ;end select
     IF (check_error(dm_err->eproc)=1)
      CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
      RETURN(0)
     ENDIF
     SET new_env_id = (max_env_id+ 1)
     IF ((dm_err->debug_flag > 0))
      CALL echo(dm_err->asterisk_line)
      CALL echo(build("max_env_id=",max_env_id))
      CALL echo(build("new_env_id=",new_env_id))
      CALL echo(dm_err->asterisk_line)
     ENDIF
    ENDIF
    SET dm_err->eproc = concat("Inserting dm_environment row for database ",dm2_install_schema->
     target_dbase_name,".")
    CALL disp_msg(" ",dm_err->logfile,0)
    SET adm_maint_str = concat("insert into dm_environment de ",
     " set de.environment_id =  new_env_id ",
     ", de.environment_name =  cnvtupper(dm2_install_schema->target_env_name)",
     ", de.database_name = ' '",", de.admin_dbase_link_name = 'ADMIN1'",
     ", de.schema_version = 0.0",", de.from_schema_version = 0.0",
     ", de.v500_connect_string = dsdes_cnnct_str",", de.volume_group = 'N/A'",
     ", de.root_dir_name = 'N/A'",
     ", de.target_operating_system = cursys ",", de.updt_applctx = 0 ",
     ", de.updt_dt_tm = cnvtdatetime(curdate,curtime3) ",", de.updt_cnt = 0 ",", de.updt_id = 0 ",
     ", de.updt_task = 0 ","  with nocounter go")
    IF (dm2_push_adm_maint(adm_maint_str)=0)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSE
    SET dm_err->eproc = "Updating environment id with current information."
    CALL disp_msg(" ",dm_err->logfile,0)
    SET adm_maint_str = concat("update from dm_environment de ",
     "set  de.admin_dbase_link_name = 'ADMIN1'",", de.schema_version = 0.0",
     ", de.from_schema_version = 0.0",", de.v500_connect_string =  dsdes_cnnct_str",
     ", de.updt_dt_tm = cnvtdatetime(curdate,curtime3) ",", de.updt_cnt = 0 ",", de.updt_id = 0 ",
     ", de.updt_task = 0 ",
     "  where de.environment_name = cnvtupper(dm2_install_schema->target_env_name) ",
     "  with nocounter go")
    IF (dm2_push_adm_maint(adm_maint_str)=0)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   IF (dm2_set_autocommit(1)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Prompt to confirm environment name"
   CALL disp_msg(" ",dm_err->logfile,0)
   EXECUTE dm_set_env_id
   SET message = nowindow
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF (dm2_set_autocommit(0)=0)
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Determining if 'INHOUSE DOMAIN' dm_info row exists."
   CALL disp_msg(" ",dm_err->logfile,0)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="DATA MANAGEMENT"
     AND di.info_name="INHOUSE DOMAIN"
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ELSEIF (curqual > 0)
    SET dm_err->eproc = "Deleting 'INHOUSE DOMAIN' row from dm_info."
    CALL disp_msg(" ",dm_err->logfile,0)
    DELETE  FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="INHOUSE DOMAIN"
     WITH nocounter
    ;end delete
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dm2ceil(dc_numin)
   SET dc_numin_save = dc_numin
   DECLARE dc_numin_vc = vc WITH noconstant("")
   DECLARE dc_numin_precision = i4 WITH noconstant(0)
   DECLARE dc_numin_decpos = i2 WITH noconstant(0)
   DECLARE dc_numin_whole = f8 WITH protect, noconstant(0.0)
   SET dc_numin_vc = cnvtstring(dc_numin_save,30,9,"R")
   SET dc_numin_decpos = findstring(".",dc_numin_vc)
   SET dc_numin_whole = cnvtreal(substring(1,(dc_numin_decpos - 1),dc_numin_vc))
   IF (dc_numin_decpos <= 0)
    RETURN(dc_numin)
   ELSE
    SET dc_numin_precision = cnvtint(substring((dc_numin_decpos+ 1),9,dc_numin_vc))
    IF (dc_numin_precision > 0)
     IF (dc_numin < 0)
      SET dc_numin_save = dc_numin_whole
     ELSE
      SET dc_numin_save = (dc_numin_whole+ 1)
     ENDIF
    ELSE
     SET dc_numin_save = dc_numin_whole
    ENDIF
    RETURN(dc_numin_save)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2floor(dc_numin)
   SET dc_numin_save = dc_numin
   DECLARE dc_numin_vc = vc WITH noconstant("")
   DECLARE dc_numin_precision = i4 WITH noconstant(0)
   DECLARE dc_numin_decpos = i2 WITH noconstant(0)
   DECLARE dc_numin_whole = f8 WITH protect, noconstant(0.0)
   SET dc_numin_vc = cnvtstring(dc_numin_save,30,9,"R")
   SET dc_numin_decpos = findstring(".",dc_numin_vc)
   SET dc_numin_whole = cnvtreal(substring(1,(dc_numin_decpos - 1),dc_numin_vc))
   IF (dc_numin_decpos <= 0)
    RETURN(dc_numin)
   ELSE
    SET dc_numin_precision = cnvtint(substring((dc_numin_decpos+ 1),9,dc_numin_vc))
    IF (dc_numin_precision > 0)
     IF (dc_numin < 0)
      SET dc_numin_save = (dc_numin_whole - 1)
     ELSE
      SET dc_numin_save = dc_numin_whole
     ENDIF
    ELSE
     SET dc_numin_save = dc_numin_whole
    ENDIF
    RETURN(dc_numin_save)
   ENDIF
 END ;Subroutine
 SUBROUTINE dm2_toolset_usage(null)
   DECLARE dtu_use_dm2_toolset = i2
   DECLARE dtu_use_dm_toolset = i2
   DECLARE dtu_envid = i4
   DECLARE dtu_dm_info_exists = i2
   SET dtu_use_dm2_toolset = 1
   SET dtu_use_dm_toolset = 2
   SET dtu_envid = 0
   SET dtu_dm_info_exists = 0
   IF (currdb IN ("DB2UDB", "SQLSRV"))
    IF ((dm_err->debug_flag > 0))
     CALL echo("Using DM2 toolset because database is DB2/SQLSRV")
    ENDIF
    RETURN(dtu_use_dm2_toolset)
   ENDIF
   SET dm_err->eproc = "Determining if DM_INFO exists."
   SELECT INTO "nl:"
    FROM user_tab_columns utc,
     dtable dt
    WHERE utc.table_name="DM_INFO"
     AND utc.table_name=dt.table_name
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dtu_dm_info_exists = 1
    SET dm_err->eproc = "Determining if database option exists."
    FREE RECORD dtu_db_option
    RECORD dtu_db_option(
      1 info_char = vc
      1 info_date = dq8
    )
    SELECT INTO "nl:"
     FROM dm_info d
     WHERE d.info_domain=concat("DM2_",trim(currdb),"_DB_OPTION")
      AND d.info_name="DM2_TOOLSET_USAGE"
     DETAIL
      dtu_db_option->info_char = d.info_char, dtu_db_option->info_date = d.info_date
     WITH nocounter
    ;end select
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF ((dm_err->ecode != 0))
     SET dm_err->err_ind = 1
     FREE RECORD dtu_db_option
     RETURN(0)
    ENDIF
    IF (curqual=1)
     IF ((dtu_db_option->info_char IN ("Y", "N"))
      AND (dtu_db_option->info_date=cnvtdatetime("22-JUN-1996 00:00:00")))
      IF ((dtu_db_option->info_char="Y"))
       FREE RECORD dtu_db_option
       IF ((dm_err->debug_flag > 0))
        CALL echo("Using DM2 toolset because database option designates dm2 toolset usage")
       ENDIF
       RETURN(dtu_use_dm2_toolset)
      ELSE
       FREE RECORD dtu_db_option
       IF ((dm_err->debug_flag > 0))
        CALL echo("Using DM toolset because database option designates dm toolset usage")
       ENDIF
       RETURN(dtu_use_dm_toolset)
      ENDIF
     ELSE
      IF ((dtu_db_option->info_char != "CERNER_DEFAULT"))
       IF ((dm_err->debug_flag > 0))
        CALL echo("Not using the database option because it is not set up correctly.")
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (currev < 8)
    IF ((dm_err->debug_flag > 0))
     CALL echo("Using DM toolset because the current rev is less then 8.0")
    ENDIF
    RETURN(dtu_use_dm_toolset)
   ENDIF
   IF (currdbuser="CDBA")
    IF ((dm_err->debug_flag > 0))
     CALL echo("Using DM2 toolset because ADMIN database (always use dm2 toolset)")
    ENDIF
    RETURN(dtu_use_dm2_toolset)
   ENDIF
   SET dm_err->eproc = "Determining if process running in an in-house domain."
   SET inhouse_misc->inhouse_domain = 0
   IF (validate(dm2_inhouse_flag,- (1)) > 0)
    SET inhouse_misc->inhouse_domain = 1
   ENDIF
   IF ((inhouse_misc->inhouse_domain=0)
    AND dtu_dm_info_exists=1)
    SELECT INTO "nl:"
     FROM dm_info di
     WHERE di.info_domain="DATA MANAGEMENT"
      AND di.info_name="INHOUSE DOMAIN"
     WITH nocounter
    ;end select
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF ((dm_err->ecode != 0))
     SET dm_err->err_ind = 1
     RETURN(0)
    ELSEIF (curqual=1)
     SET inhouse_misc->inhouse_domain = 1
    ENDIF
   ENDIF
   IF ((inhouse_misc->inhouse_domain=1))
    IF ((dm_err->debug_flag > 0))
     CALL echo("Using DM2 toolset because INHOUSE domain (always use dm2 toolset)")
    ENDIF
    RETURN(dtu_use_dm2_toolset)
   ENDIF
   IF (dtu_dm_info_exists=0)
    IF ((dm_err->debug_flag > 0))
     CALL echo(
      "Using DM toolset because DM_INFO does not exist and DM2 toolset requires it's existence")
    ENDIF
    RETURN(dtu_use_dm_toolset)
   ENDIF
   SET dm_err->eproc = "Getting environment id."
   SELECT INTO "nl:"
    FROM dm_info a,
     dm_environment b
    WHERE a.info_domain="DATA MANAGEMENT"
     AND a.info_name="DM_ENV_ID"
     AND a.info_number=b.environment_id
    DETAIL
     dtu_envid = b.environment_id
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSEIF (curqual=0)
    SET dm_err->err_ind = 1
    SET dm_err->emsg = "Unable to obtain ENVIRONMENT_ID from DM_INFO."
    RETURN(0)
   ENDIF
   SET dm_err->eproc = "Checking if packages are installed"
   SELECT INTO "nl:"
    FROM dm_alpha_features_env dafe,
     dm_ocd_log dol
    WHERE dafe.environment_id=dtu_envid
     AND dafe.alpha_feature_nbr IN (11277, 13384, 10292)
     AND dafe.environment_id=dol.environment_id
     AND dafe.alpha_feature_nbr=dol.ocd
     AND dol.project_type="INSTALL LOG"
     AND dol.project_name="POST-INST READMES"
     AND dol.status="COMPLETE"
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSEIF (curqual > 0)
    IF ((dm_err->debug_flag > 0))
     CALL echo("Using DM2 toolset because required installation package exists.")
    ENDIF
    RETURN(dtu_use_dm2_toolset)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_alpha_features_env dafe
    WHERE dafe.environment_id=dtu_envid
     AND dafe.alpha_feature_nbr=10292
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_alpha_features_env dafe2
     WHERE dafe.environment_id=dafe2.environment_id
      AND dafe2.alpha_feature_nbr IN (11277, 13384))))
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ELSEIF (curqual > 0)
    IF ((dm_err->debug_flag > 0))
     CALL echo("Using DM2 toolset because required installation package exists.")
    ENDIF
    RETURN(dtu_use_dm2_toolset)
   ENDIF
   SET dm_err->eproc = "Determining if CODE_VALUE exists."
   SELECT INTO "nl:"
    FROM user_tab_columns utc,
     dtable dt
    WHERE utc.table_name="CODE_VALUE"
     AND utc.table_name=dt.table_name
    WITH nocounter
   ;end select
   SET dm_err->ecode = error(dm_err->emsg,1)
   IF ((dm_err->ecode != 0))
    SET dm_err->err_ind = 1
    RETURN(0)
   ENDIF
   IF (curqual > 0)
    SET dm_err->eproc = "Selecting from CODE_VALUE for codeset"
    SELECT INTO "nl:"
     FROM code_value c
     WHERE c.code_set=289570
      AND c.display="2004.02"
      AND c.active_ind=1
     WITH nocounter
    ;end select
    SET dm_err->ecode = error(dm_err->emsg,1)
    IF ((dm_err->ecode != 0))
     SET dm_err->err_ind = 1
     RETURN(0)
    ELSEIF (curqual > 0)
     IF ((dm_err->debug_flag > 0))
      CALL echo("Using DM2 toolset because required code value exists.")
     ENDIF
     RETURN(dtu_use_dm2_toolset)
    ENDIF
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echo("Using DM toolset because no DM2 toolset usage requirements were met.")
   ENDIF
   RETURN(dtu_use_dm_toolset)
 END ;Subroutine
 IF (check_logfile("dm2_rdds_create",".log","DM2_RDDS_CREATE LOG")=0)
  SET dm_err->err_ind = 1
  SET dm_err->emsg = "Unable to Create Log File"
  CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
  GO TO exit_main
 ENDIF
 SET perm_col_cnt = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt
 SELECT INTO "dm2_ref_data_mover_0047"
  FROM (dummyt d  WITH seq = value(perm_col_cnt))
  HEAD REPORT
   row 1, col 1, "drop program dm2_ref_data_mover_0047:dba go",
   row + 1, "create program dm2_ref_data_mover_0047:dba", row + 1,
   "%i cclsource:dm2_common_routines.inc", row + 1, "%i cclsource:dm2_ref_data_doc.inc",
   row + 1, "declare cust_catalog_cd_s = f8", row + 1,
   "declare cust_catalog_cd = f8", row + 1, "declare comp_seq_cnt = i4",
   row + 1, "declare cust_tab_name_s = vc", row + 1,
   "declare cust_cs_loop = i4", row + 1, "declare cust_col_cnt = i4",
   row + 1, "declare cust_col_num = i4", row + 1,
   "declare cust_check_loop = i4", row + 1, "declare cust_nodelete_ind = i2",
   row + 1, "declare cust_chg_log = vc", row + 1,
   "declare cust_merge_loop = i4", row + 1, "declare cust_index_var = i4",
   row + 1, "declare cust_cur_merges = i4", row + 1,
   "declare cust_fail_merges = i4", row + 1, "declare cust_del_msg = vc",
   row + 1, "declare cust_where_clause  =vc", row + 1,
   "declare cust_parser_cnt = i4", row + 1, "declare cust_col_name = vc",
   row + 1, "declare passed_var = vc", row + 1,
   "declare drdm_dmt_tab = vc", row + 1, "declare cust_loop = i4",
   row + 1, "declare cust_from_val = f8", row + 1,
   "declare cust_to_val = f8", row + 1, "declare cust_from_str =vc",
   row + 1, "declare chg_log_smry_name =vc", row + 1,
   "declare cust_eq_cnt = i4", row + 1, "declare cust_sp_cnt = i4",
   row + 1, "declare except_tab = vc", row + 1,
   "declare except_log_type = vc", row + 1, "declare rpt_table = vc",
   row + 1, "declare rpt_column = vc", row + 1,
   "declare rpt_from = f8", row + 1, "declare orphan_ind = i2",
   row + 1, "free record cust_cs_rows", row + 1,
   "record cust_cs_rows (", row + 1, "1 qual[*]",
   row + 1, "  2 comp_seq = i4", row + 1,
   "  2 trans_ind = i2)", row + 1, row + 1,
   "declare cs_Insert(temp_tbl_cnt = i4, perm_col_cnt = i4) = null", row + 1,
   "declare cs_merge_audit(action = vc, text= vc) = null",
   row + 1, "set perm_col_cnt = dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_cnt", row + 1,
   'set cust_tab_name_s = concat(dm2_ref_data_doc->pre_link_name, "CS_COMPONENT", dm2_ref_data_doc->post_link_name)',
   row + 1, 'set cust_eq_cnt = findstring("=",drdm_chg->log[drdm_log_loop].pk_where) + 1',
   row + 1,
   'set cust_sp_cnt = findstring(" ",drdm_chg->log[drdm_log_loop].pk_where, cust_eq_cnt + 1)  - cust_eq_cnt',
   row + 1,
   "if (cust_sp_cnt < 0)", row + 1,
   "   set cust_sp_cnt = size(drdm_chg->log[drdm_log_loop].pk_where) - cust_eq_cnt + 1",
   row + 1, "endif", row + 1,
   "set cust_catalog_cd_s = cnvtreal(trim(substring(cust_eq_cnt, cust_sp_cnt, drdm_chg->log[drdm_log_loop].pk_where)))",
   row + 1, row + 1,
   'select into "NL:"', row + 1, "from (parser(cust_tab_name_s) c)",
   row + 1, "where c.catalog_cd = cust_catalog_cd_s", row + 1,
   "order by c.comp_seq", row + 1, "head report",
   row + 1, "   comp_seq_cnt = 0", row + 1,
   "   stat = alterlist(cust_cs_rows->qual, 10)", row + 1, "detail",
   row + 1, "   comp_seq_cnt = comp_seq_cnt + 1", row + 1,
   "   if (mod(comp_seq_cnt, 10) = 1 and comp_seq_cnt != 1)", row + 1,
   "      stat = alterlist(cust_cs_rows->qual, comp_seq_cnt + 9)",
   row + 1, "   endif", row + 1,
   "   cust_cs_rows->qual[comp_seq_cnt].comp_seq = c.comp_seq", row + 1, "foot report",
   row + 1, "   stat = alterlist(cust_cs_rows->qual, comp_seq_cnt)", row + 1,
   "with nocounter", row + 1, ";error checking",
   row + 1, "if (check_error(dm_err->eproc) = 1)", row + 1,
   "   call disp_msg(dm_err->emsg, dm_err->logfile, 1)", row + 1, "   go to EXIT_0047",
   row + 1, "endif", row + 1,
   row + 1, "if (curqual = 0)", row + 1,
   '   set cust_chg_log = concat(dm2_ref_data_doc->pre_link_name, "DM_CHG_LOG", dm2_ref_Data_doc->post_link_name)',
   row + 1, "   update into (parser(cust_chg_log) d)",
   row + 1, '   set d.log_type = "NO SRC",', row + 1,
   "       d.updt_dt_tm = cnvtdatetime(curdate, curtime3),", row + 1,
   "       d.updt_cnt = d.updt_cnt + 1",
   row + 1, "   where d.log_id = drdm_chg->log[drdm_log_loop].log_id", row + 1,
   "   with nocounter", row + 1,
   "   set chg_log_smry_name = concat(dm2_ref_data_doc->pre_link_name, ",
   row + 1, '      "DM_CHG_LOG_SMRY", dm2_ref_data_doc->post_link_name)', row + 1,
   "   update into (parser(chg_log_smry_name) d)", row + 1, "   set d.row_count = d.row_count + 1",
   row + 1, '   where d.table_name = "CS_COMPONENT"', row + 1,
   "      and d.target_env_id = dm2_ref_data_doc->env_target_id", row + 1,
   '      and d.log_type = "NO SRC"',
   row + 1, "   if (curqual = 0)", row + 1,
   "      insert into (parser(chg_log_smry_name) d)", row + 1,
   '      set d.row_count = 1, d.table_name ="CS_COMPONENT", d.target_env_id = dm2_ref_data_doc->env_target_id,',
   row + 1, '          d.log_type = "NO SRC"', row + 1,
   "   endif            ", row + 1, "   if (check_error(dm_err->eproc) = 1)",
   row + 1, "      call disp_msg(dm_err->emsg, dm_err->logfile, 1)", row + 1,
   "      go to EXIT_0047", row + 1, "   endif",
   row + 1, "   commit", row + 1,
   "   go to EXIT_0047", row + 1, "endif",
   row + 1, 'select into "NL:"', row + 1,
   "from dm_merge_translate t", row + 1, "where t.from_value = cust_catalog_cd_s",
   row + 1, '   and t.table_name = "CODE_VALUE"', row + 1,
   "   and t.env_source_id = dm2_ref_data_doc->env_source_id", row + 1,
   "   and t.env_target_id = dm2_ref_data_doc->env_target_id",
   row + 1, "detail", row + 1,
   "   cust_catalog_cd = t.to_value", row + 1, "with nocounter",
   row + 1, row + 1, "if (check_error(dm_err->eproc) = 1)",
   row + 1, "   call disp_msg(dm_err->emsg, dm_err->logfile, 1)", row + 1,
   "   go to EXIT_0047", row + 1, "endif",
   row + 1, "if (cust_catalog_cd = 0)", row + 1,
   '   set drdm_dmt_tab = concat(dm2_ref_data_doc->pre_linK_name, "DM_MERGE_TRANSLATE", dm2_ref_data_doc->post_link_name)',
   row + 1, "   insert into dm_merge_translate",
   row + 1, "   (env_source_id, env_target_id, table_name, from_value, to_value)", row + 1,
   "   (select dm2_ref_data_doc->env_source_id, dm2_ref_data_doc->env_target_id,", row + 1,
   '    "CODE_VALUE", dmt1.from_value, dmt1.to_value',
   row + 1, "   from dm_merge_translate dmt1, (value(drdm_dmt_tab) dmt2)", row + 1,
   "   where dmt1.from_value = rs_47->from_values.catalog_cd", row + 1,
   '   and dmt1.table_name = "CODE_VALUE"',
   row + 1, "   and dmt1.env_source_id = 0", row + 1,
   "   and dmt1.env_target_id = 0", row + 1, "   and dmt2.from_value = dmt1.from_value",
   row + 1, "   and dmt2.table_name = dmt1.table_name", row + 1,
   "   and dmt2.env_source_id = 0", row + 1, "   and dmt2.env_target_id = 0)",
   row + 1, "   with nocounter", row + 1,
   "   if (check_error(dm_err->eproc) = 1)", row + 1,
   "      call disp_msg(dm_err->emsg, dm_err->logfile, 1)",
   row + 1, "   endif", row + 1,
   "   if (curqual > 0)", row + 1,
   '      call rdds_del_except("CODE_VALUE", cnvtreal(rs_47->from_values.catalog_cd))   ;002',
   row + 1, '      select into "NL:"', row + 1,
   "      from dm_merge_translate t", row + 1, "      where t.from_value = cust_catalog_cd_s",
   row + 1, '         and t.table_name = "CODE_VALUE"', row + 1,
   "         and t.env_source_id = dm2_ref_data_doc->env_source_id", row + 1,
   "         and t.env_target_id = dm2_ref_data_doc->env_target_id",
   row + 1, "      detail", row + 1,
   "         cust_catalog_cd = t.to_value", row + 1, "      with nocounter",
   row + 1, "      if (check_error(dm_err->eproc) = 1)", row + 1,
   "         call disp_msg(dm_err->emsg, dm_err->logfile, 1)", row + 1, "      endif",
   row + 1, "   endif", row + 1,
   "endif", row + 1, "if (cust_catalog_cd = 0)",
   row + 1, '   call echo("This log_id was not translated because of the CATALOG_CD column.")', row
    + 1,
   "   ;log to merge_audit", row + 1, "   go to EXIT_0047",
   row + 1, "endif", row + 1,
   row + 1, "delete from CS_COMPONENT c", row + 1,
   "where c.catalog_cd = cust_catalog_cd", row + 1, "with nocounter",
   row + 1, ";error checking", row + 1,
   "if (check_error(dm_err->eproc) = 1)", row + 1,
   "   call disp_msg(dm_err->emsg, dm_err->logfile, 1)",
   row + 1, "   go to EXIT_0047", row + 1,
   "endif", row + 1, row + 1,
   "for (cust_cs_loop = 1 to comp_seq_cnt)", row + 1, 'select into "nl:"',
   row + 1
  DETAIL
   passed_var = concat("var",trim(cnvtstring(d.seq)))
   IF (d.seq=perm_col_cnt)
    passed_var, " = nullind(c.", dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name,
    ")"
   ELSE
    passed_var, " = nullind(c.", dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name,
    "), "
   ENDIF
   row + 1
  FOOT REPORT
   "from (parser(cust_tab_name_s) c)", row + 1, "where c.catalog_cd = cust_catalog_cd_s",
   row + 1, "    and c.comp_seq = cust_cs_rows->qual[cust_cs_loop].comp_seq", row + 1,
   "detail", row + 1
  WITH nocounter, maxrow = 1, format = variable,
   formfeed = none
 ;end select
 SELECT INTO "dm2_ref_data_mover_0047"
  FROM (dummyt d  WITH seq = value(perm_col_cnt))
  HEAD REPORT
   row 1, col 1
  DETAIL
   "rs_47->from_values.", dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name,
   " = c.",
   dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name, row + 1
   IF ( NOT ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name IN ("*_ID", "*_CD"
   ))))
    "rs_47->to_values.", dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name,
    " = c.",
    dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name, row + 1
   ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name="UPDT_ID"))
    "rs_47->to_values.", dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name, " = 0",
    row + 1
   ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name="UPDT_CNT"))
    "rs_47->to_values.", dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name, " = 0",
    row + 1
   ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name="UPDT_DT_TM"))
    "rs_47->to_values.", dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name,
    " = cnvtdatetime(curdate, curtime3)",
    row + 1
   ELSEIF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name="VARIANCE_FORMAT_ID"
   ))
    "rs_47->to_values.", dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name, " = 0",
    row + 1
   ENDIF
   'cust_col_num = locateval(cust_index_var, 1, perm_col_cnt, "', dm2_ref_data_doc->tbl_qual[
   temp_tbl_cnt].col_qual[d.seq].column_name, '", ',
   row + 1, "dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[cust_index_var].column_name)", row + 1,
   passed_var = concat("var",trim(cnvtstring(d.seq))),
   "dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[cust_col_num].check_null = ", passed_var,
   row + 1, "dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[cust_col_num].translated = 0", row + 1
  FOOT REPORT
   "with nocounter", row + 1, "if (check_error(dm_err->eproc) = 1)",
   row + 1, "   call disp_msg(dm_err->emsg, dm_err->logfile, 1)", row + 1,
   "   go to EXIT_0047", row + 1, "endif",
   row + 1, "if (curqual = 0)", row + 1,
   "   go to EXIT_0047", row + 1, "endif",
   row + 1
  WITH append, formfeed = none, maxrow = 1,
   format = variable
 ;end select
 SELECT INTO "dm2_ref_data_mover_0047"
  FROM (dummyt d  WITH seq = value(perm_col_cnt))
  HEAD REPORT
   row 1, col 1, 'call echo("")',
   row + 1, 'call echo("")', row + 1,
   'call echo(build("Post RS = ", curmem))', row + 1, 'call echo("")',
   row + 1, 'call echo("")', row + 1,
   'call echo("**************LOOKING UP TRANSLATIONS***************")', row + 1, 'call echo("")',
   row + 1, 'call echo("")', row + 1,
   "set cust_cur_merges = cust_cur_merges + 1", row + 1,
   'set child_merge_audit->num[cust_cur_merges].action = "CONSTANT"',
   row + 1, 'set child_merge_audit->num[cust_cur_merges].text = "CS_COMPONENT  UPDT_ID"', row + 1,
   "set cust_cur_merges = cust_cur_merges + 1", row + 1,
   'set child_merge_audit->num[cust_cur_merges].action = "CONSTANT"',
   row + 1, 'set child_merge_audit->num[cust_cur_merges].text = "CS_COMPONENT  VARIANCE_FORMAT_ID"',
   row + 1,
   "set RS_47->log_id = drdm_chg->log[drdm_log_loop].log_id", row + 1,
   'set RS_47->From_table_name = "CS_COMPONENT"',
   row + 1, 'set RS_47->to_table_name = "CS_COMPONENT"', row + 1,
   "set RS_47->audit_sequence = merge_audit_cnt", row + 1, "set no_insert_update = 0",
   row + 1
  DETAIL
   IF ((( NOT ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name IN ("*_ID",
   "*_CD", "CODE_VALUE")))) OR ((((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].
   column_name="UPDT_ID")) OR ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name=
   "VARIANCE_FORMAT_ID"))) )) )
    passed_var = concat("set dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[",trim(cnvtstring(d
       .seq)),"].translated = 1"), passed_var, row + 1
   ELSE
    "if (rs_47->from_values.", dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name,
    "  != 0)",
    row + 1, "set found_rec = 0", row + 1,
    'select into "nl:" ', row + 1, "from dm_merge_translate dm",
    row + 1, "where dm.from_value = rs_47->from_values.", dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
    col_qual[d.seq].column_name,
    " and ", row + 1, '    dm.table_name = "',
    dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].root_entity_name, '" and', row + 1,
    "    dm.env_source_id = dm2_ref_data_doc->env_source_id and", row + 1,
    "    dm.env_target_id = dm2_Ref_Data_doc->env_target_id",
    row + 1, "detail", row + 1,
    "    rs_47->to_values.", dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name,
    " = dm.to_value",
    row + 1, "    found_rec = 1", row + 1,
    "with nocounter", row + 1, "if (check_error(dm_err->eproc) = 1)",
    row + 1, "   call disp_msg(dm_err->emsg, dm_err->logfile, 1)", row + 1,
    "endif", row + 1, "else",
    row + 1, " set found_rec = 1", row + 1,
    " set rs_47->to_values.", dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name,
    " = 0",
    row + 1, "endif", row + 1,
    "if (found_rec = 0)", row + 1,
    '   set drdm_dmt_tab = concat(dm2_ref_data_doc->pre_linK_name, "DM_MERGE_TRANSLATE", dm2_ref_data_doc->post_link_name)',
    row + 1, "   insert into dm_merge_translate", row + 1,
    "   (env_source_id, env_target_id, table_name, from_value, to_value)", row + 1,
    "   (select dm2_ref_data_doc->env_source_id, dm2_ref_data_doc->env_target_id,",
    row + 1, '    "', dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].root_entity_name,
    '", dmt1.from_value, dmt1.to_value', row + 1,
    "   from dm_merge_translate dmt1, (value(drdm_dmt_tab) dmt2)",
    row + 1, "   where dmt1.from_value = rs_47->from_values.", dm2_ref_data_doc->tbl_qual[
    temp_tbl_cnt].col_qual[d.seq].column_name,
    row + 1, '   and dmt1.table_name = "', dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].
    root_entity_name,
    '"', row + 1, "   and dmt1.env_source_id = 0",
    row + 1, "   and dmt1.env_target_id = 0", row + 1,
    "   and dmt2.from_value = dmt1.from_value", row + 1, "   and dmt2.table_name = dmt1.table_name",
    row + 1, "   and dmt2.env_source_id = 0", row + 1,
    "   and dmt2.env_target_id = 0)", row + 1, "   with nocounter",
    row + 1, "   if (check_error(dm_err->eproc) = 1)", row + 1,
    "      call disp_msg(dm_err->emsg, dm_err->logfile, 1)", row + 1, "   endif",
    row + 1, "   if (curqual > 0)", row + 1,
    '      call rdds_del_except("', dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].
    root_entity_name, '",',
    "cnvtreal(rs_47->from_values.", dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].
    column_name, "))",
    row + 1, ";002", row + 1,
    'select into "nl:" ', row + 1, "from dm_merge_translate dm",
    row + 1, "where dm.from_value = rs_47->from_values.", dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].
    col_qual[d.seq].column_name,
    " and ", row + 1, '    dm.table_name = "',
    dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].root_entity_name, '" and', row + 1,
    "    dm.env_source_id = dm2_ref_data_doc->env_source_id and", row + 1,
    "    dm.env_target_id = dm2_Ref_Data_doc->env_target_id",
    row + 1, "detail", row + 1,
    "    rs_47->to_values.", dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name,
    " = dm.to_value",
    row + 1, "    found_rec = 1", row + 1,
    "with nocounter", row + 1, "if (check_error(dm_err->eproc) = 1)",
    row + 1, "   call disp_msg(dm_err->emsg, dm_err->logfile, 1)", row + 1,
    "endif", row + 1, "   endif",
    row + 1, "endif", row + 1,
    "if (found_rec = 1)", row + 1,
    '  set cust_col_num = locateval(cust_index_var, 1, perm_col_cnt, "',
    dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name, '", ', row + 1,
    "   dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[cust_index_var].column_name)", row + 1,
    "  set dm2_ref_Data_doc->tbl_qual[temp_tbl_cnt].col_qual[cust_col_num].translated = 1",
    row + 1, "  set cust_cur_merges = cust_cur_merges + 1", row + 1,
    '  set child_merge_audit->num[cust_cur_merges].action = "LOOKUPS"', row + 1,
    '  set child_merge_audit->num[cust_cur_merges].text = "CS_COMPONENT   ',
    dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name, '"', row + 1,
    "endif", row + 2
   ENDIF
  FOOT REPORT
   '   call echo(build("P Code_value = ", curmem))', row + 1, "   set IDCD_check = 0",
   row + 1, '   call echo("")', row + 1,
   '   call echo("")', row + 1,
   '   call echo("***************CHECKING ID AND CD COLUMNS******************")',
   row + 1, '   call echo("")', row + 1,
   '   call echo("")', row + 1, '   set dm_err->eproc = "Checking ID and CD columns"',
   row + 1, "   ;Checking id and cd columns", row + 1,
   "   for (cust_check_loop = 1 to perm_col_cnt)", row + 1,
   '      if (value(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[cust_check_loop].column_name) in ("*_ID") or',
   row + 1,
   '         value(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[cust_check_loop].column_name) in ("*_CD"))',
   row + 1,
   "         if (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[cust_check_loop].translated = 0)  ",
   row + 1,
   "            call echo(dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[cust_check_loop].column_name)",
   row + 1,
   '            if (dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[cust_check_loop].root_entity_name != "")',
   row + 1,
   "               set rpt_table=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[cust_check_loop].root_entity_name",
   row + 1,
   "               set rpt_column=dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[cust_check_loop].root_entity_attr",
   row + 1, '               call parser(concat("set rpt_from = RS_47->from_values.",', row + 1,
   '                  dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[cust_check_loop].column_name, " go"), 1)',
   row + 1, "            endif",
   row + 1, '            if (rpt_table != "" and rpt_from != 0)', row + 1,
   '               set except_tab = concat(value(dm2_ref_data_doc->pre_link_name), "DM_CHG_LOG_EXCEPTION",',
   row + 1, "                  value(dm2_ref_data_doc->post_link_name))",
   row + 2, '               SELECT into "NL:"', row + 1,
   "               FROM (parser(except_tab) d)", row + 1,
   "               WHERE d.TARGET_ENV_ID = dm2_ref_data_doc->env_target_id",
   row + 1, "                   AND d.TABLE_NAME = rpt_table", row + 1,
   "                   AND d.COLUMN_NAME = rpt_column", row + 1,
   "                   AND d.FROM_VALUE = rpt_from",
   row + 1, "               detail", row + 1,
   "                  except_log_type = d.log_type", row + 1, "               with nocounter",
   row + 2, "               IF (curqual = 0)", row + 1,
   "                  rollback", row + 1, "                  INSERT into (parser(except_tab) d)",
   row + 1, '                  set d.log_type = "NOXLAT", ', row + 1,
   "                     d.table_name = rpt_table, ", row + 1,
   "                     d.column_name = rpt_column, ",
   row + 1, "                     d.from_value = rpt_from,", row + 1,
   "                     d.target_env_id = dm2_ref_data_doc->env_target_id", row + 1,
   "                  with nocounter",
   row + 1, "                  if (check_error(dm_err->eproc) = 1)", row + 1,
   "                     call disp_msg(dm_err->emsg, dm_err->logfile, 1)", row + 1,
   "                     set drdm_error_out_ind = 1",
   row + 1, "                     set dm_err->err_ind = 0", row + 1,
   "                  else", row + 1, "                     commit",
   row + 1, "                  endif", row + 1,
   "               else", row + 1, '                  if (except_log_type = "ORPHAN")',
   row + 1, "                     set orphan_ind = 1", row + 1,
   "                  endif", row + 1, "               endif",
   row + 1, "            endif", row + 2,
   "            set IDCD_Check = 1", row + 1,
   '            set dm_err->eproc = concat("This log_id ",',
   row + 1, '               "was not translated because of the ",', row + 1,
   "               dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[cust_check_loop].column_name, ",
   row + 1, '               " column.")',
   row + 1, '            call echo("")', row + 1,
   '            call echo("")', row + 1, "            call echo(dm_err->eproc)",
   row + 1, '            call echo("")', row + 1,
   '            call echo("")', row + 1, "            set cust_fail_merges= cust_fail_merges + 1",
   row + 1, '            set fail_merge_audit->num[cust_fail_merges].action = "FAILREASON"', row + 1,
   "            set fail_merge_audit->num[cust_fail_merges].text = dm_err->eproc", row + 1,
   "            rollback",
   row + 1, "            set cust_cs_loop = comp_seq_cnt", row + 1,
   "            call cs_merge_audit(fail_merge_audit->num[cust_fail_merges].action, ", row + 1,
   "               fail_merge_audit->num[cust_fail_merges].text)",
   row + 1, "            if (drdm_error_out_ind = 1)", row + 1,
   "               rollback", row + 1, "               set cust_check_loop = perm_col_cnt",
   row + 1, "            else", row + 1,
   "               commit", row + 1, "            endif",
   row + 1, "         endif", row + 1,
   "      endif", row + 1, "   endfor ",
   row + 1, "   if (drdm_error_out_ind = 1)", row + 1,
   "      set cust_cs_loop = comp_seq_cnt", row + 1, "   endif",
   row + 1, "", row + 1,
   "   if (IDCD_check = 0)", row + 1, "      call cs_Insert(temp_tbl_cnt, perm_col_cnt)",
   row + 1, '      call echo(build("p Insert = ", curmem))', row + 1,
   "      if (cust_nodelete_ind = 0)", row + 1, "         if (cust_cs_loop = comp_seq_cnt)",
   row + 1, "            set update_cnt = 0", row + 1,
   '            set cust_chg_log = concat(dm2_ref_data_doc->pre_link_name, "DM_CHG_LOG", dm2_ref_Data_doc->post_link_name)',
   row + 1, '            select into "nl:"',
   row + 1, "            from (parser(cust_chg_log) dc)", row + 1,
   "            where dc.log_id = drdm_chg->log[drdm_log_loop].log_id", row + 1, "            detail",
   row + 1, "               update_cnt = dc.updt_cnt", row + 1,
   "            with nocounter", row + 1,
   "            if (update_cnt = drdm_chg->log[drdm_log_loop].updt_cnt)",
   row + 1, "               update into (parser(cust_chg_log) d)", row + 1,
   '               set d.log_type = "MERGED",', row + 1,
   "                  d.updt_dt_tm = cnvtdatetime(curdate, curtime3),",
   row + 1, "                  d.updt_cnt = d.updt_cnt + 1", row + 1,
   "               where d.log_id = rs_47->log_id", row + 1, "               with nocounter",
   row + 1, "               set drdm_any_translated = 1", row + 1,
   "               set chg_log_smry_name = concat(dm2_ref_data_doc->pre_link_name, ", row + 1,
   '                  "DM_CHG_LOG_SMRY", dm2_ref_data_doc->post_link_name)',
   row + 1, "               update into (parser(chg_log_smry_name) d)", row + 1,
   "               set d.row_count = d.row_count + 1", row + 1,
   '               where d.table_name = "CS_COMPONENT"',
   row + 1, "                  and d.target_env_id = dm2_ref_data_doc->env_target_id", row + 1,
   '                  and d.log_type = "MERGED"', row + 1, "               if (curqual = 0)",
   row + 1, "                  insert into (parser(chg_log_smry_name) d)", row + 1,
   '                  set d.row_count = 1, d.table_name ="CS_COMPONENT", d.target_env_id = dm2_ref_data_doc->env_target_id,',
   row + 1, '                     d.log_type = "MERGED"',
   row + 1, "               endif", row + 1,
   "               if (check_error(dm_err->eproc) = 1)", row + 1,
   "                  call disp_msg(dm_err->emsg, dm_err->logfile, 1)",
   row + 1, "                  set drdm_error_out_ind = 1", row + 1,
   "                  rollback", row + 1, "                  set cust_cs_loop = comp_seq_cnt",
   row + 1, "              endif", row + 1,
   "            else", row + 1,
   '               set cust_del_msg = concat("Could not delete log_id ", ',
   row + 1, "                  trim(cnvtstring(drdm_chg->log[drdm_log_loop].log_id)),", row + 1,
   '                  " because it has been updated since the mover picked it up. It will be merged next pass.")',
   row + 1, '               call echo("")',
   row + 1, '               call echo("")', row + 1,
   "               call echo(cust_del_msg)", row + 1, '               call echo("")',
   row + 1, '               call echo("")  ', row + 1,
   "               set cust_fail_merges= cust_fail_merges + 1", row + 1,
   '               set fail_merge_audit->num[cust_fail_merges].action = "FAILREASON"',
   row + 1, "               set fail_merge_audit->num[cust_fail_merges].text = cust_del_msg", row + 1,
   "               rollback", row + 1,
   "               call cs_merge_audit(fail_merge_audit->num[cust_fail_merges].action, ",
   row + 1, "                  fail_merge_audit->num[cust_fail_merges].text)", row + 1,
   "               if (drdm_error_out_ind = 1)", row + 1, "                   rollback",
   row + 1, "                   set cust_cs_loop = comp_seq_cnt + 1", row + 1,
   "               else", row + 1, "                  commit",
   row + 1, "                  set cust_cur_merges = 0 ", row + 1,
   "               endif", row + 1, "           endif",
   row + 1, "         endif", row + 1,
   "         for (cust_merge_loop = 1 to cust_cur_merges)", row + 1,
   "             call cs_merge_audit(child_merge_audit->num[cust_merge_loop].action,",
   row + 1, "               child_merge_audit->num[cust_merge_loop].text)", row + 1,
   "             if (drdm_error_out_ind = 1)", row + 1, "                rollback",
   row + 1, "                set cust_merge_loop = cust_cur_merges", row + 1,
   "            endif", row + 1, "         endfor",
   row + 1, "         if (drdm_error_out_ind = 1)", row + 1,
   "            set cust_cs_loop = comp_seq_cnt + 1", row + 1, "         endif",
   row + 1, "         set merge_audit_cnt = merge_audit_cnt + cust_cur_merges", row + 1,
   "         set cust_cur_merges = 0", row + 1,
   "         set cust_cs_rows->qual[cust_cs_loop].trans_ind = 1",
   row + 1, "         if (cust_cs_loop = comp_seq_cnt)", row + 1,
   '            call echo(build("p Delete = ", curmem))', row + 1, "            commit ",
   row + 1, "         endif", row + 1,
   "      else", row + 1,
   '         set cust_del_msg = concat("Could not insert log_id ", cnvtstring(drdm_chg->log[drdm_log_loop].log_id))',
   row + 1, '         call echo("")', row + 1,
   '         call echo("")', row + 1, "         call echo(cust_del_msg)",
   row + 1, '         call echo("")', row + 1,
   '         call echo("")', row + 1, "         rollback",
   row + 1, "         set cust_cur_merges  = 0", row + 1,
   "         set cust_cs_loop = comp_seq_cnt", row + 1, "      endif ",
   row + 1, "   else", row + 1,
   "      if (orphan_ind = 1)", row + 1, "         set update_cnt = 0",
   row + 1, "         rollback", row + 1,
   '         set cust_chg_log = concat(dm2_ref_data_doc->pre_link_name, "DM_CHG_LOG", dm2_ref_Data_doc->post_link_name)',
   row + 1, '         select into "nl:"',
   row + 1, "         from (parser(cust_chg_log) dc)", row + 1,
   "         where dc.log_id = drdm_chg->log[drdm_log_loop].log_id", row + 1, "         detail",
   row + 1, "            update_cnt = dc.updt_cnt", row + 1,
   "         with nocounter", row + 1,
   "         if (update_cnt = drdm_chg->log[drdm_log_loop].updt_cnt)",
   row + 1, "            update into (parser(cust_chg_log) d)", row + 1,
   '            set d.log_type = "ORPHAN",', row + 1,
   "               d.updt_dt_tm = cnvtdatetime(curdate, curtime3),",
   row + 1, "               d.updt_cnt = d.updt_cnt + 1", row + 1,
   "            where d.log_id = drdm_chg->log[drdm_log_loop].log_id", row + 1,
   "            with nocounter  ;002>",
   row + 1, "            update into (parser(chg_log_smry_name) d)", row + 1,
   "            set d.row_count = d.row_count + 1, d.updt_cnt = d.updt_cnt + 1, d.updt_dt_tm = cnvtdatetime(curdate, curtime3)",
   row + 1, '            where d.table_name = "CS_COMPONENT"',
   row + 1, "               and d.target_env_id = DM2_REF_DATA_DOC->ENV_TARGET_ID", row + 1,
   '               and d.log_type = "ORPHAN"', row + 1, "            if (curqual = 0)",
   row + 1, "               insert into (parser(chg_log_smry_name) d)", row + 1,
   '               set d.row_count = 1, d.table_name ="CS_COMPONENT", d.target_env_id = DM2_REF_DATA_DOC->ENV_TARGET_ID,',
   row + 1,
   '                  d.log_type = "ORPHAN", d.updt_cnt = 1, d.updt_dt_tm = cnvtdatetime(curdate, curtime3)',
   row + 1, "            endif", row + 1,
   "            if (check_error(dm_err->eproc) = 1)", row + 1,
   "               call disp_msg(dm_err->emsg, dm_err->logfile, 1)",
   row + 1, "               set drdm_error_out_ind = 1", row + 1,
   "               rollback", row + 1, "               go to EXIT_0047",
   row + 1, "            else", row + 1,
   "               commit", row + 1, "            endif  ;<002",
   row + 1, "         endif", row + 1,
   "      endif", row + 1, "      set cust_cur_merges = 0",
   row + 1, "      rollback ", row + 1,
   "      set cust_cs_loop = comp_seq_cnt", row + 1, "   endif",
   row + 1, "endfor", row + 1
  WITH append, formfeed = none, maxrow = 1,
   format = variable
 ;end select
 SELECT INTO "dm2_ref_data_mover_0047"
  FROM (dummyt d  WITH seq = value(perm_col_cnt))
  HEAD REPORT
   row 1, col 1, ";*************************************************************************",
   row + 1, ";cs_Insert_row accepts 2 variables that are all i4 and returns an i2**", row + 1,
   ";It decides whether to update the row in the target or insert a new row **", row + 1,
   ";*************************************************************************",
   row + 1, "subroutine cs_Insert(temp_tbl_cnt, perm_col_cnt)", row + 1,
   "", row + 1, ";changing updt* columns to be correct.",
   row + 1, "set rs_47->to_values.updt_dt_tm = cnvtdatetime(curdate,curtime3)", row + 1,
   "set rs_47->to_values.updt_cnt = 0", row + 1, "set rs_47->to_values.updt_task = 0",
   row + 1, 'set dm_err->eproc = "Inserting Row"', row + 1,
   'call echo("")', row + 1, 'call echo("")',
   row + 1, 'call echo("*******************INSERTING ROW******************")', row + 1,
   'call echo("")', row + 1, 'call echo("")',
   row + 1, "", row + 1,
   ";constructing insert statement", row + 1, "insert into cs_component c set",
   row + 1
  DETAIL
   IF ((dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].data_type="DATE"))
    IF (d.seq=perm_col_cnt)
     "   c.", dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name,
     " = cnvtdatetime(rs_47->to_values.",
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name, ")", row + 1
    ELSE
     "   c.", dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name,
     " = cnvtdatetime(rs_47->to_values.",
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name, "),", row + 1
    ENDIF
   ELSE
    IF (d.seq=perm_col_cnt)
     "   c.", dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name,
     " = rs_47->to_values.",
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name, row + 1
    ELSE
     "   c.", dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name,
     " = rs_47->to_values.",
     dm2_ref_data_doc->tbl_qual[temp_tbl_cnt].col_qual[d.seq].column_name, ",", row + 1
    ENDIF
   ENDIF
  FOOT REPORT
   "with nocounter", row + 1, "   if (check_error(dm_err->eproc) = 1)",
   row + 1, "      call disp_msg(dm_err->emsg, dm_err->logfile, 1)", row + 1,
   "      set cust_nodelete_ind = 1", row + 1, "      set dm_err->err_ind = 0",
   row + 1, "   endif", row + 1,
   "   ", row + 1, "   ;inserting record into dm_merge_audit",
   row + 1, "   set cust_cur_merges = cust_cur_merges+1", row + 1,
   '   set child_merge_audit->num[cust_cur_merges].action = "INSERT"', row + 1,
   "   set child_merge_audit->num[cust_cur_merges].text = dm2_ref_Data_doc->tbl_qual[temp_tbl_cnt].table_name",
   row + 1, "end ;subroutine", row + 3,
   ";*************************************************", row + 1,
   ";Merge audit accects two VCs and returns an i2***",
   row + 1, ";*************************************************", row + 1,
   "subroutine cs_merge_audit(action, text)", row + 1, "",
   row + 1, 'if (drdm_log_level = 1 and action not in ("INSERT", "UPDATE", "FAILREASON"))		', row + 1,
   "   return (null)									", row + 1, "else											",
   row + 1, "   insert into dm_merge_audit dm", row + 1,
   "   set dm.merge_dt_tm = sysdate, dm.sequence = rs_47->audit_sequence, dm.merge_id = rs_47->log_id,",
   row + 1, "         dm.action = action, dm.text = text",
   row + 1, "      ", row + 1,
   "   if (check_error(dm_err->eproc) = 1)", row + 1,
   "      call disp_msg(dm_err->emsg, dm_err->logfile, 1)",
   row + 1, "      set dm_err->err_ind = 0", row + 1,
   "      set drdm_error_out_ind = 1", row + 1, "   endif",
   row + 1, "   ", row + 1,
   '  if (action = "FAILREASON")', row + 1, "      set merge_audit_cnt = merge_audit_cnt + 1",
   row + 1, "   endif", row + 1,
   "   set rs_47->audit_sequence = rs_47->audit_sequence + 1", row + 1, "endif											",
   row + 1, "", row + 1,
   "end ;subroutine", row + 1, row + 1,
   "#EXIT_0047", row + 1, "free set cust_catalog_cd_s",
   row + 1, "free set cust_catalog_cd", row + 1,
   "free set comp_seq_cnt", row + 1, "free set cust_tab_name_s",
   row + 1, "free set cust_cs_loop", row + 1,
   "free set cust_col_cnt", row + 1, "free set cust_col_num",
   row + 1, "free set cust_cust_index_var", row + 1,
   "free set cust_check_loop", row + 1, "free set cust_nodelete_ind ",
   row + 1, "free set cust_chg_log", row + 1,
   "free set cust_merge_loop", row + 1, "free set cust_cur_merges",
   row + 1, "free set cust_fail_merges", row + 1,
   "free set cust_del_msg", row + 1, "free set cust_where_clause",
   row + 1, "free set cust_parser_cnt", row + 1,
   "free set cust_col_name", row + 1, "free set passed_var",
   row + 1, "free set cust_loop", row + 1,
   "free set cust_from_val", row + 1, "free set cust_to_val",
   row + 1, "free set cust_from_str", row + 1,
   "end go", row + 1
  WITH append, formfeed = none, maxrow = 1,
   format = variable
 ;end select
 CALL compile("dm2_ref_data_mover_0047.dat","dm2_0047_log.dat")
#exit_main
END GO
