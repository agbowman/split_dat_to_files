CREATE PROGRAM bed_upd_bb_prod_desc
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
 DECLARE error_msg = vc
 DECLARE error_flag = vc
 SET numrows = 0
 DECLARE product_cd = f8
 DECLARE prodcat_cd = f8
 SET error_flag = "F"
 SET numrows = size(request->prodcat_list,5)
 FOR (x = 1 TO numrows)
   IF ((request->prodcat_list[x].action_flag=2)
    AND (request->prodcat_list[x].prodcat_display > " ")
    AND (request->prodcat_list[x].prodcat_desc > " "))
    CALL updt_prodcat(x)
   ENDIF
 ENDFOR
 SET numrows = size(request->product_list,5)
 FOR (x = 1 TO numrows)
   IF ((request->product_list[x].action_flag=2)
    AND (request->product_list[x].product_display > " ")
    AND (request->product_list[x].product_desc > " "))
    CALL updt_product(x)
   ENDIF
 ENDFOR
 SUBROUTINE updt_prodcat(x)
   SET prodcat_cd = 0.0
   SELECT INTO "nl:"
    FROM br_bb_prodcat bc
    PLAN (bc
     WHERE (bc.prodcat_id=request->prodcat_list[x].prodcategory_id))
    DETAIL
     prodcat_cd = bc.prodcat_cd
    WITH nocounter
   ;end select
   UPDATE  FROM br_bb_prodcat bc
    SET bc.display = request->prodcat_list[x].prodcat_display, bc.description = request->
     prodcat_list[x].prodcat_desc, bc.updt_id = reqinfo->updt_id,
     bc.updt_task = reqinfo->updt_task, bc.updt_cnt = (bc.updt_cnt+ 1), bc.updt_dt_tm = cnvtdatetime(
      curdate,curtime)
    WHERE (bc.prodcat_id=request->prodcat_list[x].prodcategory_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Unable to update description for category: ",cnvtstring(request->
      prodcat_list[x].prodcategory_id))
    GO TO exit_script
   ENDIF
   IF (prodcat_cd > 0.0)
    UPDATE  FROM code_value cv
     SET cv.display = request->prodcat_list[x].prodcat_display, cv.display_key = cnvtupper(
       cnvtalphanum(request->prodcat_list[x].prodcat_display)), cv.description = request->
      prodcat_list[x].prodcat_desc,
      cv.definition = request->prodcat_list[x].prodcat_desc, cv.updt_id = reqinfo->updt_id, cv
      .updt_task = reqinfo->updt_task,
      cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(curdate,curtime)
     WHERE cv.code_value=prodcat_cd
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat("Unable to update code value description for category: ",cnvtstring(
       request->prodcat_list[x].prodcategory_id))
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE updt_product(x)
   SET product_cd = 0.0
   SELECT INTO "nl:"
    FROM br_bb_product bp
    PLAN (bp
     WHERE (bp.product_id=request->product_list[x].prod_id))
    DETAIL
     product_cd = bp.product_cd
    WITH nocounter
   ;end select
   UPDATE  FROM br_bb_product bp
    SET bp.display = request->product_list[x].product_display, bp.description = request->
     product_list[x].product_desc, bp.updt_id = reqinfo->updt_id,
     bp.updt_task = reqinfo->updt_task, bp.updt_cnt = (bp.updt_cnt+ 1), bp.updt_dt_tm = cnvtdatetime(
      curdate,curtime)
    WHERE (bp.product_id=request->product_list[x].prod_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "T"
    SET error_msg = concat("Unable to update description for product: ",cnvtstring(request->
      product_list[x].prod_id))
    GO TO exit_script
   ENDIF
   IF (product_cd > 0.0)
    UPDATE  FROM code_value cv
     SET cv.display = request->product_list[x].product_display, cv.display_key = cnvtupper(
       cnvtalphanum(request->product_list[x].product_display)), cv.description = request->
      product_list[x].product_desc,
      cv.definition = request->product_list[x].product_desc, cv.updt_id = reqinfo->updt_id, cv
      .updt_task = reqinfo->updt_task,
      cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(curdate,curtime)
     WHERE cv.code_value=product_cd
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "T"
     SET error_msg = concat("Unable to update code value description for product: ",cnvtstring(
       request->product_list[x].prod_id))
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_UPD_BB_PROD_DESC","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
