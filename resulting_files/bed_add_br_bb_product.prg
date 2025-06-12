CREATE PROGRAM bed_add_br_bb_product
 FREE SET reply
 RECORD reply(
   1 product_list[*]
     2 product_display = vc
     2 product_id = f8
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
 DECLARE product_found = vc
 DECLARE product_id = f8
 SET repcnt = 0
 DECLARE nextid = f8
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET repcnt = 0
 SET nextid = 0.0
 SET numrows = size(request->product_list,5)
 FOR (x = 1 TO numrows)
   SET product_found = "N"
   SELECT INTO "nl:"
    FROM br_bb_product bp
    PLAN (bp
     WHERE cnvtupper(bp.display)=cnvtupper(request->product_list[x].display))
    DETAIL
     product_found = "Y", product_id = bp.product_id
    WITH nocounter
   ;end select
   IF (product_found="N")
    SELECT INTO "nl:"
     y = seq(bedrock_seq,nextval)
     FROM dual
     DETAIL
      nextid = cnvtreal(y)
     WITH nocounter
    ;end select
    INSERT  FROM br_bb_product bp
     SET bp.product_id = nextid, bp.display = request->product_list[x].display, bp.description =
      request->product_list[x].description,
      bp.selected_ind = 0, bp.product_cd = 0.0, bp.prodcat_id = 0.0,
      bp.bar_code_val = " ", bp.auto_ind = 0, bp.directed_ind = 0,
      bp.max_exp_unit = " ", bp.max_exp_val = 0, bp.calc_exp_from_draw_ind = 0,
      bp.volume_def = 0, bp.def_supplier = " ", bp.aborh_conf_test_name = " ",
      bp.dispense_ind = 0, bp.min_bef_quar = 0, bp.validate_antibody_ind = 0,
      bp.validate_transf_req_ind = 0, bp.int_units_ind = 0, bp.def_storage_temp = " ",
      bp.updt_dt_tm = cnvtdatetime(curdate,curtime), bp.updt_id = reqinfo->updt_id, bp.updt_task =
      reqinfo->updt_task,
      bp.updt_applctx = reqinfo->updt_applctx, bp.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat("Error adding product ",request->product_list[x].display,
      " to Bedrock table")
     GO TO exit_script
    ELSE
     SET repcnt = (repcnt+ 1)
     SET stat = alterlist(reply->product_list,repcnt)
     SET reply->product_list[repcnt].product_display = request->product_list[x].display
     SET reply->product_list[repcnt].product_id = nextid
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
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ADD_BR_BB_PRODUCT","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
