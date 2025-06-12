CREATE PROGRAM bed_add_br_bb_prodcat
 FREE SET reply
 RECORD reply(
   1 prodcat_list[*]
     2 prodcat_display = vc
     2 prodcat_id = f8
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
 DECLARE product_class_mean = vc
 DECLARE last_prodclass_cd = f8
 SET repcnt = 0
 DECLARE nextid = f8
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET repcnt = 0
 SET nextid = 0.0
 SET last_prodclass_cd = 0.0
 SET numrows = size(request->prodcat_list,5)
 FOR (x = 1 TO numrows)
   SET prodcat_found = "N"
   SELECT INTO "nl:"
    FROM br_bb_prodcat bc
    PLAN (bc
     WHERE cnvtupper(bc.display)=cnvtupper(request->prodcat_list[x].display))
    DETAIL
     prodcat_found = "Y", prodcat_id = bc.prodcat_id
    WITH nocounter
   ;end select
   IF (prodcat_found="N")
    SELECT INTO "nl:"
     y = seq(bedrock_seq,nextval)
     FROM dual
     DETAIL
      nextid = cnvtreal(y)
     WITH nocounter
    ;end select
    IF ((last_prodclass_cd=request->prodcat_list[x].prodclass_code_value))
     SET last_prodclass_cd = request->prodcat_list[x].prodclass_code_value
    ELSE
     SET last_prodclass_cd = request->prodcat_list[x].prodclass_code_value
     SET product_class_mean = " "
     SELECT INTO "nl:"
      FROM code_value cv
      PLAN (cv
       WHERE (cv.code_value=request->prodcat_list[x].prodclass_code_value)
        AND cv.code_set=1606
        AND cv.active_ind=1)
      DETAIL
       product_class_mean = cv.cdf_meaning
      WITH nocounter
     ;end select
    ENDIF
    INSERT  FROM br_bb_prodcat bc
     SET bc.prodcat_id = nextid, bc.display = request->prodcat_list[x].display, bc.description =
      request->prodcat_list[x].description,
      bc.selected_ind = 0, bc.new_prodcat_ind = 1, bc.prodcat_cd = 0.0,
      bc.product_class_mean = product_class_mean, bc.red_cell_ind = 0, bc.rh_req_ind = 0,
      bc.aborh_conf_req_ind = 0, bc.val_compat_ind = 0, bc.xm_req_ind = 0,
      bc.uom_def = " ", bc.ship_cond_def = " ", bc.prompt_for_vol_ind = 0,
      bc.seg_num_ind = 0, bc.alternate_id_ind = 0, bc.xm_tag_req_ind = 0,
      bc.comp_tag_req_ind = 0, bc.pilot_label_req_ind = 0, bc.updt_dt_tm = cnvtdatetime(curdate,
       curtime),
      bc.updt_id = reqinfo->updt_id, bc.updt_task = reqinfo->updt_task, bc.updt_applctx = reqinfo->
      updt_applctx,
      bc.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat("Error adding product category ",request->prodcat_list[x].display,
      " to Bedrock table")
     GO TO exit_script
    ELSE
     SET repcnt = (repcnt+ 1)
     SET stat = alterlist(reply->prodcat_list,repcnt)
     SET reply->prodcat_list[repcnt].prodcat_display = request->prodcat_list[x].display
     SET reply->prodcat_list[repcnt].prodcat_id = nextid
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
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ADD_BR_BB_PRODCAT","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
