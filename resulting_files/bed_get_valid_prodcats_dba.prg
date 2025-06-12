CREATE PROGRAM bed_get_valid_prodcats:dba
 FREE SET reply
 RECORD reply(
   1 prodcat_list[*]
     2 prodcat_code_value = f8
     2 prodcat_id = f8
     2 prodcat_display = vc
     2 reviewed_ind = i2
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE error_flag = vc
 DECLARE error_msg = vc
 DECLARE repcnt = i4
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET repcnt = 0
 IF ((request->load=0))
  SELECT INTO "nl:"
   FROM br_bb_prodcat bc
   PLAN (bc
    WHERE bc.prodcat_cd > 0
     AND bc.selected_ind=1)
   ORDER BY bc.display
   HEAD bc.display
    repcnt = (repcnt+ 1), stat = alterlist(reply->prodcat_list,repcnt), reply->prodcat_list[repcnt].
    prodcat_code_value = bc.prodcat_cd,
    reply->prodcat_list[repcnt].prodcat_id = bc.prodcat_id, reply->prodcat_list[repcnt].
    prodcat_display = bc.display
   WITH nocounter
  ;end select
  IF (repcnt=0)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(repcnt)),
    br_bb_product bp,
    product_index pi
   PLAN (d)
    JOIN (bp
    WHERE (bp.prodcat_id=reply->prodcat_list[d.seq].prodcat_id)
     AND bp.product_cd > 0)
    JOIN (pi
    WHERE pi.product_cd=bp.product_cd
     AND (pi.product_cat_cd=reply->prodcat_list[d.seq].prodcat_code_value)
     AND pi.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    reply->prodcat_list[d.seq].reviewed_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(repcnt)),
    br_bb_product bp
   PLAN (d)
    JOIN (bp
    WHERE (bp.prodcat_id=reply->prodcat_list[d.seq].prodcat_id)
     AND bp.autobuild_ind=1
     AND bp.selected_ind=1
     AND bp.active_ind=0)
   ORDER BY d.seq
   HEAD d.seq
    reply->prodcat_list[d.seq].reviewed_ind = 0
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM br_bb_prodcat bc,
    br_bb_product bp
   PLAN (bc
    WHERE bc.prodcat_cd > 0
     AND bc.active_ind=1
     AND bc.selected_ind=1)
    JOIN (bp
    WHERE bp.prodcat_id=bc.prodcat_id
     AND bp.product_cd > 0
     AND bp.selected_ind=1
     AND bp.active_ind=1)
   ORDER BY bc.display
   HEAD bc.display
    repcnt = (repcnt+ 1), stat = alterlist(reply->prodcat_list,repcnt), reply->prodcat_list[repcnt].
    prodcat_code_value = bc.prodcat_cd,
    reply->prodcat_list[repcnt].prodcat_id = bc.prodcat_id, reply->prodcat_list[repcnt].
    prodcat_display = bc.display
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="T")
  SET reply->error_msg = concat(">> PROGRAM NAME: BED_GET_VALID_PRODCATS  ",">> ERROR MESSAGE: ",
   error_msg)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
