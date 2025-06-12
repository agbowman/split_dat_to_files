CREATE PROGRAM bhs_athn_clin_add_clin_doc
 RECORD orequest(
   1 ensure_type = i2
   1 event_subclass_cd = f8
   1 eso_action_meaning = vc
   1 ensure_type2 = i2
   1 override_pat_context_tz = i4
   1 clin_event
     2 ensure_type = i2
     2 event_id = f8
     2 view_level = i4
     2 view_level_ind = i2
     2 order_id = f8
     2 catalog_cd = f8
     2 catalog_cd_cki = vc
     2 series_ref_nbr = vc
     2 person_id = f8
     2 encntr_id = f8
     2 encntr_financial_id = f8
     2 accession_nbr = vc
     2 contributor_system_cd = f8
     2 contributor_system_cd_cki = vc
     2 reference_nbr = vc
     2 parent_event_id = f8
     2 event_class_cd = f8
     2 event_class_cd_cki = vc
     2 event_cd = f8
     2 event_cd_cki = vc
     2 event_tag = vc
     2 event_reltn_cd = f8
     2 event_reltn_cd_cki = vc
     2 event_start_dt_tm = dq8
     2 event_start_dt_tm_ind = i2
     2 event_end_dt_tm = dq8
     2 event_end_dt_tm_ind = i2
     2 event_end_dt_tm_os = f8
     2 event_end_dt_tm_os_ind = i2
     2 task_assay_cd = f8
     2 task_assay_cd_cki = vc
     2 record_status_cd = f8
     2 record_status_cd_cki = vc
     2 result_status_cd = f8
     2 result_status_cd_cki = vc
     2 authentic_flag = i2
     2 authentic_flag_ind = i2
     2 publish_flag = i2
     2 publish_flag_ind = i2
     2 qc_review_cd = f8
     2 qc_review_cd_cki = vc
     2 normalcy_cd = f8
     2 normalcy_cd_cki = vc
     2 normalcy_method_cd = f8
     2 normalcy_method_cd_cki = vc
     2 inquire_security_cd = f8
     2 inquire_security_cd_cki = vc
     2 resource_group_cd = f8
     2 resource_group_cd_cki = vc
     2 resource_cd = f8
     2 resource_cd_cki = vc
     2 subtable_bit_map = i4
     2 subtable_bit_map_ind = i2
     2 event_title_text = vc
     2 collating_seq = vc
     2 normal_low = vc
     2 normal_high = vc
     2 critical_low = vc
     2 critical_high = vc
     2 expiration_dt_tm = dq8
     2 expiration_dt_tm_ind = i2
     2 note_importance_bit_map = i2
     2 event_tag_set_flag = i2
     2 clinsig_updt_dt_tm_flag = i2
     2 clinsig_updt_dt_tm = dq8
     2 clinsig_updt_dt_tm_ind = i2
     2 clinical_event_id = f8
     2 valid_until_dt_tm = dq8
     2 valid_until_dt_tm_ind = i2
     2 valid_from_dt_tm = dq8
     2 valid_from_dt_tm_ind = i2
     2 result_val = vc
     2 result_units_cd = f8
     2 result_units_cd_cki = vc
     2 result_time_units_cd = f8
     2 result_time_units_cd_cki = vc
     2 verified_dt_tm = dq8
     2 verified_dt_tm_ind = i2
     2 verified_prsnl_id = f8
     2 performed_dt_tm = dq8
     2 performed_dt_tm_ind = i2
     2 performed_prsnl_id = f8
     2 updt_dt_tm = dq8
     2 updt_dt_tm_ind = i2
     2 updt_id = f8
     2 updt_task = i4
     2 updt_task_ind = i2
     2 updt_cnt = i4
     2 updt_cnt_ind = i2
     2 updt_applctx = i4
     2 updt_applctx_ind = i2
     2 ensure_type2 = i2
     2 order_action_sequence = i4
     2 entry_mode_cd = f8
     2 source_cd = f8
     2 clinical_seq = vc
     2 event_start_tz = i4
     2 event_end_tz = i4
     2 verified_tz = i4
     2 performed_tz = i4
     2 replacement_event_id = f8
     2 task_assay_version_nbr = f8
     2 modifier_long_text = vc
     2 modifier_long_text_id = f8
     2 src_event_id = f8
     2 src_clinsig_updt_dt_tm = dq8
     2 nomen_string_flag = i2
     2 ce_dynamic_label_id = f8
     2 replacement_label_id = f8
     2 event_prsnl_list[*]
       3 event_prsnl_id = f8
       3 person_id = f8
       3 event_id = f8
       3 action_type_cd = f8
       3 request_dt_tm = dq8
       3 request_dt_tm_ind = i2
       3 request_prsnl_id = f8
       3 request_prsnl_ft = vc
       3 request_comment = vc
       3 action_dt_tm = dq8
       3 action_dt_tm_ind = i2
       3 action_prsnl_id = f8
       3 action_prsnl_ft = vc
       3 proxy_prsnl_id = f8
       3 proxy_prsnl_ft = vc
       3 action_status_cd = f8
       3 action_comment = vc
       3 change_since_action_flag = i2
       3 change_since_action_flag_ind = i2
       3 action_prsnl_pin = vc
       3 defeat_succn_ind = i2
       3 ce_event_prsnl_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
       3 long_text_id = f8
       3 linked_event_id = f8
       3 request_tz = i4
       3 action_tz = i4
       3 system_comment = vc
     2 blob_result[*]
       3 succession_type_cd = f8
       3 sub_series_ref_nbr = vc
       3 storage_cd = f8
       3 format_cd = f8
       3 device_cd = f8
       3 blob_handle = vc
       3 blob_attributes = vc
       3 blob[*]
         4 blob_seq_num = i4
         4 blob_seq_num_ind = i2
         4 compression_cd = f8
         4 blob_contents = gvc
         4 blob_contents_ind = i2
         4 event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 blob_length = i4
         4 blob_length_ind = i2
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_id = f8
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 max_sequence_nbr = i4
       3 max_sequence_nbr_ind = i2
       3 checksum = i4
       3 checksum_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_id = f8
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
 )
 RECORD oreply(
   1 status = vc
 )
 DECLARE mdoc_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"MDOC"))
 DECLARE active_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE"))
 DECLARE authverified_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED"))
 DECLARE modify_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"MODIFY"))
 DECLARE completed_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",103,"COMPLETED"))
 DECLARE sign_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"SIGN"))
 DECLARE pending_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",103,"PENDING"))
 DECLARE doc_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"DOC"))
 DECLARE powerchart_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",89,"POWERCHART"))
 DECLARE r_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",24,"R"))
 DECLARE c_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",24,"C"))
 DECLARE routclinical_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",87,"ROUTCLINICAL"))
 DECLARE inprogress_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"INPROGRESS"))
 DECLARE dynamicdocumentation_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",29520,
   "DYNAMICDOCUMENTATION"))
 DECLARE undefined_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",29520,"UNDEFINED"))
 DECLARE final_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",63,"FINAL"))
 DECLARE longblob_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",25,"LONGBLOB"))
 DECLARE ocfcompression_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",120,"OCFCOMPRESSION"))
 DECLARE perform_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"PERFORM"))
 DECLARE verify_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"VERIFY"))
 DECLARE parent_event_id = f8
 DECLARE t_line = vc
 DECLARE t_file = vc
 DECLARE t_blob = vc
 DECLARE action_dt_tm = dq8
 SET date_line = substring(1,10, $6)
 SET time_line = substring(12,8, $6)
 SET action_dt_tm = cnvtdatetimeutc2(date_line,"YYYY-MM-DD",time_line,"HH;mm;ss",4)
 IF (( $10=1))
  SET t_blob =  $12
 ELSE
  IF (( $9 !=  $10))
   SET t_file = concat( $11,"_",trim(cnvtstring( $9)),".dat")
   SELECT INTO value(t_file)
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     col 0,  $12
    WITH nocounter, maxcol = 15250
   ;end select
   GO TO exit_script
  ENDIF
  IF (( $9= $10))
   SET t_file = concat( $11,"_",trim(cnvtstring( $9)),".dat")
   SELECT INTO value(t_file)
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     col 0,  $12
    WITH nocounter, maxcol = 15250
   ;end select
   FOR (i = 1 TO  $10)
     SET t_file = concat( $11,"_",trim(cnvtstring(i)),".dat")
     FREE DEFINE rtl3
     DEFINE rtl3 t_file
     SELECT
      FROM rtl3t r
      DETAIL
       t_line = r.line
      WITH nocounter
     ;end select
     SET t_blob = concat(trim(t_blob),trim(t_line))
   ENDFOR
  ENDIF
 ENDIF
 FREE RECORD oreply
 SET orequest->ensure_type = 2
 SET orequest->clin_event[1].person_id =  $2
 SET orequest->clin_event[1].encntr_id =  $3
 SET orequest->clin_event[1].clinsig_updt_dt_tm = cnvtdatetime(curdate,curtime3)
 SET orequest->clin_event[1].event_cd =  $4
 SET orequest->clin_event[1].event_class_cd = mdoc_cd
 SET orequest->clin_event[1].view_level = 1
 SET orequest->clin_event[1].contributor_system_cd = powerchart_cd
 SET orequest->clin_event[1].event_reltn_cd = r_cd
 SET orequest->clin_event[1].valid_from_dt_tm = cnvtdatetime(curdate,curtime3)
 SET orequest->clin_event[1].event_tag = uar_get_code_display(cnvtreal( $4))
 SET orequest->clin_event[1].event_title_text =  $8
 SET orequest->clin_event[1].event_end_dt_tm = sysdate
 SET orequest->clin_event[1].record_status_cd = active_cd
 IF (( $14=0))
  SET orequest->clin_event[1].result_status_cd = authverified_cd
 ELSEIF (( $14=1))
  SET orequest->clin_event[1].result_status_cd = inprogress_cd
 ENDIF
 SET orequest->clin_event[1].authentic_flag = 1
 SET orequest->clin_event[1].publish_flag = 1
 SET orequest->clin_event[1].inquire_security_cd = routclinical_cd
 SET orequest->clin_event[1].subtable_bit_map = 1
 SET orequest->clin_event[1].updt_dt_tm = cnvtdatetime(curdate,curtime3)
 SET orequest->clin_event[1].updt_dt_tm_ind = 1
 SET orequest->clin_event[1].updt_id =  $5
 SET orequest->clin_event[1].updt_cnt = 1
 SET orequest->clin_event[1].updt_task = 3202004
 SET orequest->clin_event[1].updt_task_ind = 1
 SET orequest->clin_event[1].order_id =  $7
 IF (( $13=564029427))
  SET orequest->clin_event[1].entry_mode_cd = dynamicdocumentation_cd
 ELSE
  SET orequest->clin_event[1].entry_mode_cd = undefined_cd
 ENDIF
 SET stat = alterlist(orequest->clin_event[1].event_prsnl_list,3)
 SET orequest->clin_event[1].event_prsnl_list[1].action_prsnl_id =  $5
 SET orequest->clin_event[1].event_prsnl_list[1].action_type_cd = perform_cd
 SET orequest->clin_event[1].event_prsnl_list[1].action_dt_tm = action_dt_tm
 SET orequest->clin_event[1].event_prsnl_list[1].action_status_cd = 653
 SET orequest->clin_event[1].event_prsnl_list[1].updt_id =  $5
 SET orequest->clin_event[1].event_prsnl_list[2].action_prsnl_id =  $5
 SET orequest->clin_event[1].event_prsnl_list[2].action_type_cd = verify_cd
 SET orequest->clin_event[1].event_prsnl_list[2].action_dt_tm = action_dt_tm
 SET orequest->clin_event[1].event_prsnl_list[2].action_status_cd = 653
 SET orequest->clin_event[1].event_prsnl_list[2].updt_id =  $5
 SET orequest->clin_event[1].event_prsnl_list[3].action_prsnl_id =  $5
 SET orequest->clin_event[1].event_prsnl_list[3].action_type_cd = sign_cd
 SET orequest->clin_event[1].event_prsnl_list[3].action_dt_tm = action_dt_tm
 IF (( $14=0))
  SET orequest->clin_event[1].event_prsnl_list[3].action_status_cd = completed_cd
 ELSEIF (( $14=1))
  SET orequest->clin_event[1].event_prsnl_list[3].action_status_cd = pending_cd
 ENDIF
 SET orequest->clin_event[1].event_prsnl_list[3].updt_id =  $5
 SET stat = tdbexecute(3200000,3202004,1000012,"REC",orequest,
  "REC",oreply)
 SET parent_event_id = oreply->rb_list[1].parent_event_id
 FREE RECORD oreply
 SET orequest->clin_event[1].ensure_type = 2
 SET orequest->clin_event[1].person_id =  $2
 SET orequest->clin_event[1].encntr_id =  $3
 SET orequest->clin_event[1].parent_event_id = parent_event_id
 SET orequest->clin_event[1].clinsig_updt_dt_tm = cnvtdatetime(curdate,curtime3)
 SET orequest->clin_event[1].event_cd =  $4
 SET orequest->clin_event[1].event_class_cd = doc_cd
 SET orequest->clin_event[1].view_level = 0
 SET orequest->clin_event[1].contributor_system_cd = powerchart_cd
 SET orequest->clin_event[1].event_reltn_cd = c_cd
 SET orequest->clin_event[1].valid_from_dt_tm = cnvtdatetime(curdate,curtime3)
 SET orequest->clin_event[1].event_tag = uar_get_code_display(cnvtreal( $4))
 SET orequest->clin_event[1].event_end_dt_tm = cnvtdatetime(curdate,curtime3)
 SET orequest->clin_event[1].record_status_cd = active_cd
 IF (( $14=0))
  SET orequest->clin_event[1].result_status_cd = authverified_cd
 ELSEIF (( $14=1))
  SET orequest->clin_event[1].result_status_cd = inprogress_cd
 ENDIF
 SET orequest->clin_event[1].authentic_flag = 1
 SET orequest->clin_event[1].publish_flag = 1
 SET orequest->clin_event[1].inquire_security_cd = routclinical_cd
 SET orequest->clin_event[1].subtable_bit_map = 1
 SET orequest->clin_event[1].updt_dt_tm = cnvtdatetime(curdate,curtime3)
 SET orequest->clin_event[1].updt_dt_tm_ind = 1
 SET orequest->clin_event[1].updt_id =  $5
 SET orequest->clin_event[1].updt_cnt = 1
 SET orequest->clin_event[1].updt_task = 3202004
 SET orequest->clin_event[1].updt_task_ind = 1
 SET orequest->clin_event[1].order_id =  $7
 SET orequest->clin_event[1].collating_seq = "1"
 IF (( $13=564029427))
  SET orequest->clin_event[1].entry_mode_cd = dynamicdocumentation_cd
 ELSE
  SET orequest->clin_event[1].entry_mode_cd = undefined_cd
 ENDIF
 SET stat = alterlist(orequest->clin_event[1].blob_result,1)
 SET orequest->clin_event[1].blob_result[1].succession_type_cd = final_cd
 SET orequest->clin_event[1].blob_result[1].storage_cd = longblob_cd
 SET orequest->clin_event[1].blob_result[1].format_cd =  $13
 SET t_blob = replace(t_blob,"||~~||","")
 SET t_blob = trim(replace(replace(replace(replace(replace(t_blob,"ltsquotgt",'"',0),"ltpercgt","%",
      0),"ltampgt","&",0),"ltsaposgt","'",0),"ltscolgt",";",0),3)
 SET stat = alterlist(orequest->clin_event[1].blob_result.blob,1)
 SET orequest->clin_event[1].blob_result[1].blob[1].compression_cd = ocfcompression_cd
 SET orequest->clin_event[1].blob_result[1].blob[1].blob_contents = t_blob
 SET orequest->clin_event[1].blob_result[1].blob[1].blob_length = textlen(t_blob)
 SET stat = alterlist(orequest->clin_event[1].event_prsnl_list,3)
 SET orequest->clin_event[1].event_prsnl_list[1].action_prsnl_id =  $5
 SET orequest->clin_event[1].event_prsnl_list[1].action_type_cd = perform_cd
 SET orequest->clin_event[1].event_prsnl_list[1].action_dt_tm = action_dt_tm
 SET orequest->clin_event[1].event_prsnl_list[1].action_status_cd = 653
 SET orequest->clin_event[1].event_prsnl_list[1].updt_id =  $5
 SET orequest->clin_event[1].event_prsnl_list[2].action_prsnl_id =  $5
 SET orequest->clin_event[1].event_prsnl_list[2].action_type_cd = verify_cd
 SET orequest->clin_event[1].event_prsnl_list[2].action_dt_tm = action_dt_tm
 SET orequest->clin_event[1].event_prsnl_list[2].action_status_cd = 653
 SET orequest->clin_event[1].event_prsnl_list[2].updt_id =  $5
 SET orequest->clin_event[1].event_prsnl_list[3].action_prsnl_id =  $5
 SET orequest->clin_event[1].event_prsnl_list[3].action_type_cd = sign_cd
 SET orequest->clin_event[1].event_prsnl_list[3].action_dt_tm = action_dt_tm
 IF (( $14=0))
  SET orequest->clin_event[1].event_prsnl_list[3].action_status_cd = completed_cd
 ELSEIF (( $14=1))
  SET orequest->clin_event[1].event_prsnl_list[3].action_status_cd = pending_cd
 ENDIF
 SET orequest->clin_event[1].event_prsnl_list[3].updt_id =  $5
 SET stat = tdbexecute(3202004,3202004,1000012,"REC",orequest,
  "REC",oreply)
#exit_script
 IF (( $10=1))
  CALL echojson(oreply, $1)
 ENDIF
 IF (( $10 > 1))
  IF (( $9 !=  $10))
   SET oreply->status = concat("Successfully Sent Part ",trim(cnvtstring( $9))," of ",trim(cnvtstring
     ( $10)))
   CALL echojson(oreply, $1)
  ENDIF
  IF (( $9= $10))
   CALL echojson(oreply, $1)
   FOR (i = 1 TO  $10)
     SET t_file = concat( $11,"_",trim(cnvtstring(i)),".dat")
     DECLARE dclcom = vc
     SET dclcom = concat("rm ",t_file)
     SET stat = 0
     CALL dcl(dclcom,size(dclcom),stat)
   ENDFOR
  ENDIF
 ENDIF
END GO
