CREATE PROGRAM bed_get_bb_prodcat_prod_r:dba
 FREE SET reply
 RECORD reply(
   1 prodcat_code_value = f8
   1 product_list[*]
     2 product_id = f8
     2 product_code_value = f8
     2 product_display = vc
     2 relation_flag = i4
   1 unassigned[*]
     2 product_id = f8
     2 product_code_value = f8
     2 product_display = vc
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
 DECLARE uncnt = i4
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET repcnt = 0
 SET uncnt = 0
 SELECT INTO "nl:"
  FROM br_bb_prodcat bc,
   br_bb_product bp,
   dummyt d1
  PLAN (bc
   WHERE (bc.prodcat_id=request->prodcat_id))
   JOIN (d1)
   JOIN (bp
   WHERE ((bp.prodcat_id=bc.prodcat_id
    AND bp.product_cd > 0
    AND bp.selected_ind=1) OR (bp.prodcat_id=0.0
    AND bp.product_cd > 0.0
    AND bp.selected_ind=1)) )
  ORDER BY bc.prodcat_id, bp.product_id
  HEAD bc.prodcat_id
   reply->prodcat_code_value = bc.prodcat_cd
  HEAD bp.product_id
   IF ((bp.prodcat_id=request->prodcat_id))
    repcnt = (repcnt+ 1), stat = alterlist(reply->product_list,repcnt), reply->product_list[repcnt].
    product_code_value = bp.product_cd,
    reply->product_list[repcnt].product_id = bp.product_id, reply->product_list[repcnt].
    product_display = bp.display
   ELSEIF (bp.product_id > 0)
    uncnt = (uncnt+ 1), stat = alterlist(reply->unassigned,uncnt), reply->unassigned[uncnt].
    product_code_value = bp.product_cd,
    reply->unassigned[uncnt].product_id = bp.product_id, reply->unassigned[uncnt].product_display =
    bp.display
   ENDIF
  DETAIL
   stat = 1
  WITH nocounter, outerjoin = d1
 ;end select
 IF (repcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = repcnt),
    product_index pi
   PLAN (d)
    JOIN (pi
    WHERE (pi.product_cd=reply->product_list[d.seq].product_code_value))
   DETAIL
    IF (pi.product_cat_cd > 0.0)
     reply->product_list[d.seq].relation_flag = 1
    ELSE
     reply->product_list[d.seq].relation_flag = 0
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSEIF (error_flag="T")
  SET reply->error_msg = concat(">> PROGRAM NAME: BED_GET_BB_PRODCAT_PROD_R  ",">> ERROR MESSAGE: ",
   error_msg)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
