CREATE PROGRAM bbd_get_order_results:dba
 RECORD reply(
   1 abo_cnt = i2
   1 discrepant_aborh = c1
   1 donor_abo_cd = f8
   1 donor_abo_disp = c40
   1 donor_abo_desc = c60
   1 donor_abo_mean = c12
   1 donor_rh_cd = f8
   1 donor_rh_disp = c40
   1 donor_rh_desc = c60
   1 donor_rh_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE script_name = c25 WITH constant("bbd_get_order_results.prg")
 DECLARE verified_status_cd = f8 WITH noconstant(0.0)
 DECLARE corrected_status_cd = f8 WITH noconstant(0.0)
 DECLARE product_abo_cd = f8 WITH noconstant(0.0)
 DECLARE interp_result_cd = f8 WITH noconstant(0.0)
 DECLARE donor_activity_type_cd = f8 WITH noconstant(0.0)
 DECLARE parent_product_id = f8 WITH noconstant(0.0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE abo_test_count = i2 WITH noconstant(0)
 DECLARE root = i2 WITH noconstant(1)
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE error_msg = c255 WITH noconstant(fillstring(255," "))
 DECLARE order_code_set = i4 WITH protect, constant(1635)
 DECLARE result_stat_code_set = i4 WITH protect, constant(1901)
 DECLARE result_type_code_set = i4 WITH protect, constant(289)
 DECLARE activity_type_code_set = i4 WITH protect, constant(106)
 DECLARE verified_status_cdf_meaning = c12 WITH noconstant(fillstring(12," "))
 DECLARE corrected_status_cdf_meaning = c12 WITH noconstant(fillstring(12," "))
 DECLARE product_abo_cdf_meaning = c12 WITH noconstant(fillstring(12," "))
 DECLARE interp_result_cdf_meaning = c12 WITH noconstant(fillstring(12," "))
 DECLARE activity_cdf_meaning = c12 WITH noconstant(fillstring(12," "))
 SET verified_status_cdf_meaning = "VERIFIED"
 SET corrected_status_cdf_meaning = "CORRECTED"
 SET product_abo_cdf_meaning = "PRODUCT ABO"
 SET interp_result_cdf_meaning = "4"
 SET activity_cdf_meaning = "BBDONORPROD"
 SET reply->discrepant_aborh = "Y"
 SET error_check = error(error_msg,1)
 SET stat = uar_get_meaning_by_codeset(result_stat_code_set,verified_status_cdf_meaning,1,
  verified_status_cd)
 IF ((request->debug_ind=1))
  CALL echo(stat)
  CALL echo(result_stat_code_set)
  CALL echo(verified_status_cdf_meaning)
  CALL echo(verified_status_cd)
  CALL echo(" ")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(result_stat_code_set,corrected_status_cdf_meaning,1,
  corrected_status_cd)
 IF ((request->debug_ind=1))
  CALL echo(stat)
  CALL echo(result_stat_code_set)
  CALL echo(corrected_status_cdf_meaning)
  CALL echo(corrected_status_cd)
  CALL echo(" ")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(order_code_set,product_abo_cdf_meaning,1,product_abo_cd)
 IF ((request->debug_ind=1))
  CALL echo(stat)
  CALL echo(order_code_set)
  CALL echo(product_abo_cdf_meaning)
  CALL echo(product_abo_cd)
  CALL echo(" ")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(result_type_code_set,interp_result_cdf_meaning,1,
  interp_result_cd)
 IF ((request->debug_ind=1))
  CALL echo(stat)
  CALL echo(result_type_code_set)
  CALL echo(interp_result_cdf_meaning)
  CALL echo(interp_result_cd)
  CALL echo(" ")
 ENDIF
 SET stat = uar_get_meaning_by_codeset(activity_type_code_set,activity_cdf_meaning,1,
  donor_activity_type_cd)
 IF ((request->debug_ind=1))
  CALL echo(stat)
  CALL echo(activity_type_code_set)
  CALL echo(activity_cdf_meaning)
  CALL echo(donor_activity_type_cd)
  CALL echo(" ")
 ENDIF
 IF (((verified_status_cd=0.0) OR (((corrected_status_cd=0.0) OR (((product_abo_cd=0.0) OR (((
 interp_result_cd=0.0) OR (donor_activity_type_cd=0.0)) )) )) )) )
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = script_name
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Retrieve code values."
  IF (verified_status_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error retrieving the VERIFIED result status code value."
  ELSEIF (corrected_status_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error retrieving the CORRECTED result status code value."
  ELSEIF (product_abo_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error retrieving the PRODUCT ABO order type code value."
  ELSEIF (interp_result_cd=0.0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error retrieving the Interp result type code value."
  ELSE
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error retrieving the BBDONORPROD activity type code value."
  ENDIF
  GO TO exit_script
 ENDIF
 SET parent_product_id = request->product_id
 WHILE (root=1)
   SET root = 0
   SELECT INTO "nl:"
    p.product_id, p.modified_product_id
    FROM product p
    PLAN (p
     WHERE p.product_id=parent_product_id)
    DETAIL
     IF (p.modified_product_id > 0.0)
      parent_product_id = p.modified_product_id, root = 1
     ELSE
      root = 0
     ENDIF
    WITH nocounter
   ;end select
   SET error_check = error(error_msg,0)
   IF (error_check != 0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].operationname = script_name
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Find root parent"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
    GO TO exit_script
   ENDIF
 ENDWHILE
 SELECT INTO "nl:"
  o.order_id
  FROM service_directory sd,
   orders o,
   result r,
   perform_result pr
  PLAN (sd
   WHERE sd.bb_processing_cd=product_abo_cd)
   JOIN (o
   WHERE o.catalog_cd=sd.catalog_cd
    AND o.product_id=parent_product_id
    AND o.activity_type_cd=donor_activity_type_cd
    AND o.order_id > 0.0)
   JOIN (r
   WHERE r.order_id=o.order_id
    AND r.result_status_cd IN (corrected_status_cd, verified_status_cd))
   JOIN (pr
   WHERE pr.result_id=r.result_id
    AND pr.result_type_cd=interp_result_cd
    AND pr.result_status_cd IN (corrected_status_cd, verified_status_cd))
  ORDER BY o.order_id
  HEAD o.order_id
   abo_test_count = (abo_test_count+ 1)
  DETAIL
   row + 0
  FOOT  o.order_id
   row + 0
  WITH nocounter
 ;end select
 SET error_check = error(error_msg,0)
 IF (error_check != 0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = script_name
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Retrieve ABO count"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  GO TO exit_script
 ENDIF
 SET reply->abo_cnt = abo_test_count
 IF ((request->debug_ind=1))
  CALL echo(abo_test_count)
 ENDIF
 SELECT INTO "nl:"
  bp.cur_abo_cd, bp.cur_rh_cd, pa.abo_cd,
  pa.rh_cd
  FROM blood_product bp,
   donor_aborh da
  PLAN (bp
   WHERE (bp.product_id=request->product_id))
   JOIN (da
   WHERE da.person_id=bp.donor_person_id
    AND da.active_ind=1)
  DETAIL
   IF (bp.cur_abo_cd=da.abo_cd
    AND bp.cur_rh_cd=da.rh_cd)
    reply->discrepant_aborh = "N"
   ELSE
    reply->donor_abo_cd = da.abo_cd, reply->donor_rh_cd = da.rh_cd
   ENDIF
  WITH nocounter
 ;end select
 SET error_check = error(error_msg,0)
 IF (error_check != 0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = script_name
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Determine discrepant ABO/Rh"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  GO TO exit_script
 ENDIF
 IF ((request->debug_ind=1))
  CALL echo(reply->discrepant_aborh)
  CALL echo(reply->donor_abo_cd)
  CALL echo(reply->donor_rh_cd)
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
END GO
