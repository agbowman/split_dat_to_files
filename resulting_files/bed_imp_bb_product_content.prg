CREATE PROGRAM bed_imp_bb_product_content
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
 FREE SET product_request
 RECORD product_request(
   1 product_list[*]
     2 prodcat_disp = vc
     2 display = vc
     2 description = vc
     2 bar_code_val = vc
     2 auto_ind = vc
     2 directed_ind = vc
     2 max_exp_val = vc
     2 max_exp_unit = vc
     2 calc_exp_from_draw_ind = vc
     2 volume_def = vc
     2 def_supplier = vc
     2 aborh_conf_test_name = vc
     2 dispense_ind = vc
     2 min_bef_quar = vc
     2 validate_antibody_ind = vc
     2 validate_transf_req_ind = vc
     2 int_units_ind = vc
     2 def_storage_temp = vc
 )
 FREE SET product_reply
 RECORD product_reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE error_msg = vc WITH private
 DECLARE error_flag = vc WITH private
 DECLARE numrows = i4
 SET reply->status_data.status = "F"
 SET error_flag = "F"
 SET numrows = size(requestin->list_0,5)
 FOR (x = 1 TO numrows)
   SET stat = alterlist(product_request->product_list,x)
   SET product_request->product_list[x].prodcat_disp = requestin->list_0[x].prodcat_disp
   SET product_request->product_list[x].display = requestin->list_0[x].display
   SET product_request->product_list[x].description = requestin->list_0[x].description
   SET product_request->product_list[x].bar_code_val = requestin->list_0[x].bar_code_val
   SET product_request->product_list[x].auto_ind = requestin->list_0[x].auto_ind
   SET product_request->product_list[x].directed_ind = requestin->list_0[x].directed_ind
   SET product_request->product_list[x].max_exp_unit = requestin->list_0[x].max_exp_unit
   SET product_request->product_list[x].max_exp_val = requestin->list_0[x].max_exp_val
   SET product_request->product_list[x].calc_exp_from_draw_ind = requestin->list_0[x].
   calc_exp_from_draw_ind
   SET product_request->product_list[x].volume_def = requestin->list_0[x].volume_def
   SET product_request->product_list[x].def_supplier = requestin->list_0[x].def_supplier
   SET product_request->product_list[x].aborh_conf_test_name = requestin->list_0[x].
   aborh_conf_test_name
   SET product_request->product_list[x].dispense_ind = requestin->list_0[x].dispense_ind
   SET product_request->product_list[x].min_bef_quar = requestin->list_0[x].min_bef_quar
   SET product_request->product_list[x].validate_antibody_ind = requestin->list_0[x].
   validate_antibody_ind
   SET product_request->product_list[x].validate_transf_req_ind = requestin->list_0[x].
   validate_transf_req_ind
   SET product_request->product_list[x].int_units_ind = requestin->list_0[x].int_units_ind
   SET product_request->product_list[x].def_storage_temp = requestin->list_0[x].def_storage_temp
 ENDFOR
 SET trace = recpersist
 EXECUTE bed_ens_bb_product_content  WITH replace("REQUEST",product_request), replace("REPLY",
  product_reply)
 GO TO exit_script
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_BB_PRODUCT_CONTENT","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
