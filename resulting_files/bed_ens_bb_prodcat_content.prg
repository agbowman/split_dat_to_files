CREATE PROGRAM bed_ens_bb_prodcat_content
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE error_msg = vc WITH private
 DECLARE error_flag = vc WITH private
 DECLARE numrows = i4
 DECLARE prodcat_found = vc
 DECLARE prodcat_id = f8
 DECLARE redcell = i2
 DECLARE rh = i2
 DECLARE aborhconf = i2
 DECLARE valcompat = i2
 DECLARE xm = i2
 DECLARE promptvol = i2
 DECLARE segnum = i2
 DECLARE altid = i2
 DECLARE xmtag = i2
 DECLARE comptag = i2
 DECLARE pilotlabel = i2
 DECLARE nextid = f8
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET redcell = 0
 SET rh = 0
 SET aborhconf = 0
 SET valcompat = 0
 SET xm = 0
 SET promptvol = 0
 SET segnum = 0
 SET altid = 0
 SET xmtag = 0
 SET comptag = 0
 SET pilotlabel = 0
 SET numrows = size(request->prodcat_list,5)
 FOR (x = 1 TO numrows)
   IF ((request->prodcat_list[x].red_cell_ind="Y"))
    SET redcell = 1
   ELSE
    SET redcell = 0
   ENDIF
   IF ((request->prodcat_list[x].rh_req_ind="Y"))
    SET rh = 1
   ELSE
    SET rh = 0
   ENDIF
   IF ((request->prodcat_list[x].aborh_conf_req_ind="Y"))
    SET aborhconf = 1
   ELSE
    SET aborhconf = 0
   ENDIF
   IF ((request->prodcat_list[x].val_compat_ind="Y"))
    SET valcompat = 1
   ELSE
    SET valcompat = 0
   ENDIF
   IF ((request->prodcat_list[x].xm_req_ind="Y"))
    SET xm = 1
   ELSE
    SET xm = 0
   ENDIF
   IF ((request->prodcat_list[x].prompt_for_vol_ind="Y"))
    SET promptvol = 1
   ELSE
    SET promptvol = 0
   ENDIF
   IF ((request->prodcat_list[x].seg_num_ind="Y"))
    SET segnum = 1
   ELSE
    SET segnum = 0
   ENDIF
   IF ((request->prodcat_list[x].alternate_id_ind="Y"))
    SET altid = 1
   ELSE
    SET altid = 0
   ENDIF
   IF ((request->prodcat_list[x].xm_tag_req_ind="Y"))
    SET xmtag = 1
   ELSE
    SET xmtag = 0
   ENDIF
   IF ((request->prodcat_list[x].comp_tag_req_ind="Y"))
    SET comptag = 1
   ELSE
    SET comptag = 0
   ENDIF
   IF ((request->prodcat_list[x].pilot_label_req_ind="Y"))
    SET pilotlabel = 1
   ELSE
    SET pilotlabel = 0
   ENDIF
   SET prodcat_found = "N"
   SELECT INTO "nl:"
    FROM br_bb_prodcat b
    PLAN (b
     WHERE (b.display=request->prodcat_list[x].display))
    DETAIL
     prodcat_found = "Y", prodcat_id = b.prodcat_id
    WITH nocounter
   ;end select
   IF (prodcat_found="N")
    SELECT INTO "nl:"
     y = seq(bedrock_seq,nextval)
     FROM dual
     DETAIL
      nextid = y
     WITH nocounter
    ;end select
    INSERT  FROM br_bb_prodcat b
     SET b.prodcat_id = nextid, b.display = request->prodcat_list[x].display, b.description = request
      ->prodcat_list[x].description,
      b.selected_ind = 0, b.prodcat_cd = 0.0, b.product_class_mean = cnvtupper(request->prodcat_list[
       x].product_class_mean),
      b.red_cell_ind = redcell, b.rh_req_ind = rh, b.aborh_conf_req_ind = aborhconf,
      b.val_compat_ind = valcompat, b.xm_req_ind = xm, b.uom_def = request->prodcat_list[x].uom_def,
      b.ship_cond_def = request->prodcat_list[x].ship_cond_def, b.prompt_for_vol_ind = promptvol, b
      .seg_num_ind = segnum,
      b.alternate_id_ind = altid, b.xm_tag_req_ind = xmtag, b.comp_tag_req_ind = comptag,
      b.pilot_label_req_ind = pilotlabel, b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id =
      reqinfo->updt_id,
      b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat("Error adding product category",request->prodcat_list[x].display,
      " to Bedrock table")
     GO TO exit_script
    ENDIF
   ELSE
    UPDATE  FROM br_bb_prodcat b
     SET b.display = request->prodcat_list[x].display, b.description = request->prodcat_list[x].
      description, b.selected_ind = 0,
      b.prodcat_cd = 0.0, b.product_class_mean = cnvtupper(request->prodcat_list[x].
       product_class_mean), b.red_cell_ind = redcell,
      b.rh_req_ind = rh, b.aborh_conf_req_ind = aborhconf, b.val_compat_ind = valcompat,
      b.xm_req_ind = xm, b.uom_def = request->prodcat_list[x].uom_def, b.ship_cond_def = request->
      prodcat_list[x].ship_cond_def,
      b.prompt_for_vol_ind = promptvol, b.seg_num_ind = segnum, b.alternate_id_ind = altid,
      b.xm_tag_req_ind = xmtag, b.comp_tag_req_ind = comptag, b.pilot_label_req_ind = pilotlabel,
      b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->updt_id, b.updt_task =
      reqinfo->updt_task,
      b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = (b.updt_cnt+ 1)
     WHERE b.prodcat_id=prodcat_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat("Error updating product category",request->prodcat_list[x].display,
      " in Bedrock table")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 GO TO exit_script
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_BB_PRODCAT_CONTENT","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
