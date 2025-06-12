CREATE PROGRAM bed_imp_bb_prodcat_content
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
 FREE SET prodcat_request
 RECORD prodcat_request(
   1 prodcat_list[*]
     2 display = vc
     2 description = vc
     2 product_class_mean = vc
     2 red_cell_ind = vc
     2 rh_req_ind = vc
     2 aborh_conf_req_ind = vc
     2 val_compat_ind = vc
     2 xm_req_ind = vc
     2 uom_def = vc
     2 ship_cond_def = vc
     2 prompt_for_vol_ind = vc
     2 seg_num_ind = vc
     2 alternate_id_ind = vc
     2 xm_tag_req_ind = vc
     2 comp_tag_req_ind = vc
     2 pilot_label_req_ind = vc
 )
 FREE SET prodcat_reply
 RECORD prodcat_reply(
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
   SET stat = alterlist(prodcat_request->prodcat_list,x)
   SET prodcat_request->prodcat_list[x].display = requestin->list_0[x].display
   SET prodcat_request->prodcat_list[x].description = requestin->list_0[x].description
   SET prodcat_request->prodcat_list[x].product_class_mean = requestin->list_0[x].product_class_mean
   SET prodcat_request->prodcat_list[x].red_cell_ind = requestin->list_0[x].red_cell_ind
   SET prodcat_request->prodcat_list[x].rh_req_ind = requestin->list_0[x].rh_req_ind
   SET prodcat_request->prodcat_list[x].aborh_conf_req_ind = requestin->list_0[x].aborh_conf_req_ind
   SET prodcat_request->prodcat_list[x].val_compat_ind = requestin->list_0[x].val_compat_ind
   SET prodcat_request->prodcat_list[x].xm_req_ind = requestin->list_0[x].xm_req_ind
   SET prodcat_request->prodcat_list[x].uom_def = requestin->list_0[x].uom_def
   SET prodcat_request->prodcat_list[x].ship_cond_def = requestin->list_0[x].ship_cond_def
   SET prodcat_request->prodcat_list[x].prompt_for_vol_ind = requestin->list_0[x].prompt_for_vol_ind
   SET prodcat_request->prodcat_list[x].seg_num_ind = requestin->list_0[x].seg_num_ind
   SET prodcat_request->prodcat_list[x].alternate_id_ind = requestin->list_0[x].alternate_id_ind
   SET prodcat_request->prodcat_list[x].xm_tag_req_ind = requestin->list_0[x].xm_tag_req_ind
   SET prodcat_request->prodcat_list[x].comp_tag_req_ind = requestin->list_0[x].comp_tag_req_ind
   SET prodcat_request->prodcat_list[x].pilot_label_req_ind = requestin->list_0[x].
   pilot_label_req_ind
 ENDFOR
 SET trace = recpersist
 EXECUTE bed_ens_bb_prodcat_content  WITH replace("REQUEST",prodcat_request), replace("REPLY",
  prodcat_reply)
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
