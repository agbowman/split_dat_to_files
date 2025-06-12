CREATE PROGRAM bed_get_bb_prodcat_details:dba
 FREE SET reply
 RECORD reply(
   1 prodcat_list[*]
     2 prodcat_id = f8
     2 prodcat_code_value = f8
     2 red_cell_ind = i2
     2 rh_req_ind = i2
     2 aborh_conf_req_ind = i2
     2 val_compat_ind = i2
     2 xm_req_ind = i2
     2 uom_def_code_value = f8
     2 uom_def_display = vc
     2 ship_cond_def_code_value = f8
     2 ship_cond_def_display = vc
     2 prompt_for_vol_ind = i2
     2 seg_num_ind = i2
     2 alternate_id_ind = i2
     2 xm_tag_req_ind = i2
     2 comp_tag_req_ind = i2
     2 pilot_label_req_ind = i2
     2 new_prodcat_ind = i2
     2 prodcat_display = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET treply
 RECORD treply(
   1 prodcat_list[*]
     2 prodcat_id = f8
     2 prodcat_code_value = f8
     2 prodcat_display = vc
     2 prodclass_mean = vc
     2 red_cell_ind = i2
     2 rh_req_ind = i2
     2 aborh_conf_req_ind = i2
     2 val_compat_ind = i2
     2 xm_req_ind = i2
     2 uom_def_code_value = f8
     2 uom_def_display = vc
     2 ship_cond_def_code_value = f8
     2 ship_cond_def_display = vc
     2 prompt_for_vol_ind = i2
     2 seg_num_ind = i2
     2 alternate_id_ind = i2
     2 xm_tag_req_ind = i2
     2 comp_tag_req_ind = i2
     2 pilot_label_req_ind = i2
     2 new_prodcat_ind = i2
 )
 DECLARE error_flag = vc
 DECLARE error_msg = vc
 DECLARE catcnt = i4
 DECLARE repsze = i4
 DECLARE def_uom_cd = f8
 DECLARE def_uom_disp = vc
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET catcnt = size(request->prodcat_list,5)
 SET repsze = 0
 SET def_uom_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=54
    AND cv.cdf_meaning="ML"
    AND cv.active_ind=1)
  DETAIL
   def_uom_cd = cv.code_value, def_uom_disp = cv.display
  WITH nocounter
 ;end select
 FOR (ii = 1 TO catcnt)
   SELECT INTO "nl:"
    FROM br_bb_prodcat bc
    PLAN (bc
     WHERE (bc.prodcat_id=request->prodcat_list[ii].prodcat_id))
    DETAIL
     repsze = (repsze+ 1), stat = alterlist(treply->prodcat_list,repsze), treply->prodcat_list[repsze
     ].prodcat_display = cnvtupper(trim(bc.display)),
     treply->prodcat_list[repsze].prodclass_mean = bc.product_class_mean, treply->prodcat_list[repsze
     ].prodcat_id = bc.prodcat_id, treply->prodcat_list[repsze].prodcat_code_value = bc.prodcat_cd,
     treply->prodcat_list[repsze].red_cell_ind = bc.red_cell_ind, treply->prodcat_list[repsze].
     rh_req_ind = bc.rh_req_ind, treply->prodcat_list[repsze].aborh_conf_req_ind = bc
     .aborh_conf_req_ind,
     treply->prodcat_list[repsze].val_compat_ind = bc.val_compat_ind, treply->prodcat_list[repsze].
     xm_req_ind = bc.xm_req_ind, treply->prodcat_list[repsze].uom_def_display = bc.uom_def,
     treply->prodcat_list[repsze].ship_cond_def_display = bc.ship_cond_def, treply->prodcat_list[
     repsze].prompt_for_vol_ind = bc.prompt_for_vol_ind, treply->prodcat_list[repsze].seg_num_ind =
     bc.seg_num_ind,
     treply->prodcat_list[repsze].alternate_id_ind = bc.alternate_id_ind, treply->prodcat_list[repsze
     ].xm_tag_req_ind = bc.xm_tag_req_ind, treply->prodcat_list[repsze].comp_tag_req_ind = bc
     .comp_tag_req_ind,
     treply->prodcat_list[repsze].pilot_label_req_ind = bc.pilot_label_req_ind, treply->prodcat_list[
     repsze].prodcat_display = bc.display, treply->prodcat_list[repsze].new_prodcat_ind = bc
     .new_prodcat_ind
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Error reading product category for prodcat_id: ",cnvtstring(request->
      prodcat_list[ii].prodcat_id))
    GO TO exit_script
   ENDIF
   SET treply->prodcat_list[repsze].uom_def_code_value = 0.0
   IF ((treply->prodcat_list[repsze].uom_def_display > " "))
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=54
       AND cv.active_ind=1
       AND cv.display=trim(treply->prodcat_list[repsze].uom_def_display))
     DETAIL
      treply->prodcat_list[repsze].uom_def_code_value = cv.code_value
     WITH nocounter
    ;end select
   ELSE
    SET treply->prodcat_list[repsze].uom_def_code_value = def_uom_cd
    SET treply->prodcat_list[repsze].uom_def_display = def_uom_disp
   ENDIF
   SET treply->prodcat_list[repsze].ship_cond_def_code_value = 0.0
   IF ((treply->prodcat_list[repsze].ship_cond_def_display > " "))
    SELECT INTO "nl:"
     FROM code_value cv
     PLAN (cv
      WHERE cv.code_set=1600
       AND cv.active_ind=1
       AND cv.display_key=cnvtupper(cnvtalphanum(trim(treply->prodcat_list[repsze].
         ship_cond_def_display))))
     DETAIL
      treply->prodcat_list[repsze].ship_cond_def_code_value = cv.code_value
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->prodcat_list,repsze)
 SET jj = 0
 IF (repsze > 0)
  SELECT INTO "nl:"
   disp1 = treply->prodcat_list[d.seq].prodclass_mean, disp2 = treply->prodcat_list[d.seq].
   prodcat_display
   FROM (dummyt d  WITH seq = repsze)
   PLAN (d)
   ORDER BY disp1, disp2
   DETAIL
    jj = (jj+ 1), reply->prodcat_list[jj].prodcat_id = treply->prodcat_list[d.seq].prodcat_id, reply
    ->prodcat_list[jj].prodcat_code_value = treply->prodcat_list[d.seq].prodcat_code_value,
    reply->prodcat_list[jj].red_cell_ind = treply->prodcat_list[d.seq].red_cell_ind, reply->
    prodcat_list[jj].rh_req_ind = treply->prodcat_list[d.seq].rh_req_ind, reply->prodcat_list[jj].
    aborh_conf_req_ind = treply->prodcat_list[d.seq].aborh_conf_req_ind,
    reply->prodcat_list[jj].val_compat_ind = treply->prodcat_list[d.seq].val_compat_ind, reply->
    prodcat_list[jj].xm_req_ind = treply->prodcat_list[d.seq].xm_req_ind, reply->prodcat_list[jj].
    uom_def_display = treply->prodcat_list[d.seq].uom_def_display,
    reply->prodcat_list[jj].ship_cond_def_display = treply->prodcat_list[d.seq].ship_cond_def_display,
    reply->prodcat_list[jj].prompt_for_vol_ind = treply->prodcat_list[d.seq].prompt_for_vol_ind,
    reply->prodcat_list[jj].seg_num_ind = treply->prodcat_list[d.seq].seg_num_ind,
    reply->prodcat_list[jj].alternate_id_ind = treply->prodcat_list[d.seq].alternate_id_ind, reply->
    prodcat_list[jj].xm_tag_req_ind = treply->prodcat_list[d.seq].xm_tag_req_ind, reply->
    prodcat_list[jj].comp_tag_req_ind = treply->prodcat_list[d.seq].comp_tag_req_ind,
    reply->prodcat_list[jj].pilot_label_req_ind = treply->prodcat_list[d.seq].pilot_label_req_ind,
    reply->prodcat_list[jj].ship_cond_def_code_value = treply->prodcat_list[d.seq].
    ship_cond_def_code_value, reply->prodcat_list[jj].uom_def_code_value = treply->prodcat_list[d.seq
    ].uom_def_code_value,
    reply->prodcat_list[jj].uom_def_display = treply->prodcat_list[d.seq].uom_def_display, reply->
    prodcat_list[jj].prodcat_display = treply->prodcat_list[d.seq].prodcat_display, reply->
    prodcat_list[jj].new_prodcat_ind = treply->prodcat_list[d.seq].new_prodcat_ind
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="T")
  SET reply->error_msg = concat(">> PROGRAM NAME: BED_GET_BB_PRODCAT_DETAILS  ",">> ERROR MESSAGE: ",
   error_msg)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
