CREATE PROGRAM aps_get_case_processing_tasks:dba
 RECORD reply(
   1 case_id = f8
   1 prefix_cd = f8
   1 tag_qual[2]
     2 tag_type_flag = i2
     2 tag_group_cd = f8
     2 tag_separator = c1
   1 spec_ctr = i4
   1 spec_qual[*]
     2 case_specimen_id = f8
     2 spec_descr = vc
     2 spec_tag_group_cd = f8
     2 spec_tag_cd = f8
     2 spec_tag_sequence = i4
     2 spec_tag = c7
     2 spec_seq = i4
     2 spec_fixative_cd = f8
     2 spec_fixative_disp = vc
     2 spec_cd = f8
     2 spec_disp = vc
     2 spec_collect_dt_tm = dq8
     2 s_t_ctr = i4
     2 t_qual[*]
       3 t_task_assay_cd = f8
       3 t_task_assay_disp = vc
       3 t_task_assay_desc = vc
       3 t_comment = vc
       3 t_lt_c_updt_cnt = i4
       3 t_comments_long_text_id = f8
       3 t_status_cd = f8
       3 t_status_disp = vc
       3 t_status_desc = vc
       3 t_status_mean = vc
       3 t_request_dt_tm = dq8
       3 t_request_prsnl = vc
       3 t_create_inv_flag = i2
       3 t_order_id = f8
       3 t_hold_cd = f8
       3 t_hold_disp = vc
       3 t_hold_comment = vc
       3 t_updt_dt_tm = dq8
       3 t_status_dt_tm = dq8
       3 t_status_prsnl_name = vc
       3 t_quantity = i4
       3 t_processing_task_id = f8
       3 t_service_resource_cd = f8
       3 t_service_resource_disp = vc
       3 t_service_resource_desc = vc
       3 t_priority_cd = f8
       3 t_priority_disp = vc
       3 t_updt_cnt = i4
       3 t_worklist_nbr = i4
       3 t_cancel_cd = f8
       3 t_cancel_disp = c40
       3 t_cassette_tag_cd = f8
       3 t_slide_tag_cd = f8
       3 t_no_charge_ind = i2
       3 t_research_account_id = f8
       3 t_task_type_flag = i2
       3 t_mnemonic = vc
       3 t_description = vc
     2 s_slide_ctr = i4
     2 slide_qual[*]
       3 sl_task_assay_cd = f8
       3 sl_tag = c7
       3 sl_seq = i4
       3 sl_updt_cnt = i4
       3 sl_slide_id = f8
       3 sl_origin_modifier = c7
       3 sl_stain_task_assay_cd = f8
       3 sl_stain_task_assay_disp = vc
       3 s_s_t_ctr = i4
       3 sl_content_status_cd = f8
       3 sl_content_status_disp = vc
       3 sl_content_status_desc = vc
       3 sl_content_status_mean = vc
       3 t_qual[*]
         4 t_task_assay_cd = f8
         4 t_task_assay_disp = vc
         4 t_task_assay_desc = vc
         4 t_comment = vc
         4 t_lt_c_updt_cnt = i4
         4 t_comments_long_text_id = f8
         4 t_status_cd = f8
         4 t_status_disp = vc
         4 t_status_desc = vc
         4 t_status_mean = vc
         4 t_request_dt_tm = dq8
         4 t_request_prsnl = vc
         4 t_create_inv_flag = i2
         4 t_order_id = f8
         4 t_hold_cd = f8
         4 t_hold_disp = vc
         4 t_hold_comment = vc
         4 t_updt_dt_tm = dq8
         4 t_status_dt_tm = dq8
         4 t_status_prsnl_name = vc
         4 t_quantity = i4
         4 t_processing_task_id = f8
         4 t_service_resource_cd = f8
         4 t_service_resource_disp = vc
         4 t_service_resource_desc = vc
         4 t_priority_cd = f8
         4 t_priority_disp = vc
         4 t_worklist_nbr = i4
         4 t_updt_cnt = i4
         4 t_cancel_cd = f8
         4 t_cancel_disp = c40
         4 t_no_charge_ind = i2
         4 t_research_account_id = f8
         4 t_task_type_flag = i2
         4 t_mnemonic = vc
         4 t_description = vc
         4 t_stain_ind = i2
       3 sl_stain_proc_task_id = f8
     2 s_c_ctr = i4
     2 cass_qual[*]
       3 cass_id = f8
       3 cass_tag = c7
       3 cass_seq = i4
       3 cass_task_assay_cd = f8
       3 cass_task_assay_disp = vc
       3 cass_task_assay_inv_flag = i2
       3 cass_pieces = c3
       3 cass_fixative_cd = f8
       3 cass_fixative_disp = vc
       3 cass_origin_modifier = c7
       3 cass_updt_cnt = i4
       3 s_c_t_ctr = i4
       3 cass_content_status_cd = f8
       3 cass_content_status_disp = vc
       3 cass_content_status_desc = vc
       3 cass_content_status_mean = vc
       3 t_qual[*]
         4 t_task_assay_cd = f8
         4 t_task_assay_disp = vc
         4 t_task_assay_desc = vc
         4 t_comment = vc
         4 t_lt_c_updt_cnt = i4
         4 t_comments_long_text_id = f8
         4 t_status_cd = f8
         4 t_status_disp = vc
         4 t_status_desc = vc
         4 t_status_mean = vc
         4 t_request_dt_tm = dq8
         4 t_request_prsnl = vc
         4 t_create_inv_flag = i2
         4 t_order_id = f8
         4 t_hold_cd = f8
         4 t_hold_disp = vc
         4 t_hold_comment = vc
         4 t_updt_dt_tm = dq8
         4 t_status_dt_tm = dq8
         4 t_status_prsnl_name = vc
         4 t_quantity = i4
         4 t_processing_task_id = f8
         4 t_service_resource_cd = f8
         4 t_service_resource_disp = vc
         4 t_service_resource_desc = vc
         4 t_priority_cd = f8
         4 t_priority_disp = vc
         4 t_worklist_nbr = i4
         4 t_updt_cnt = i4
         4 t_cancel_cd = f8
         4 t_cancel_disp = c40
         4 t_no_charge_ind = i2
         4 t_research_account_id = f8
         4 t_task_type_flag = i2
         4 t_mnemonic = vc
         4 t_description = vc
       3 s_c_slide_ctr = i4
       3 slide_qual[*]
         4 s_task_assay_cd = f8
         4 s_tag = c7
         4 s_seq = i4
         4 s_updt_cnt = i4
         4 s_slide_id = f8
         4 s_origin_modifier = c7
         4 s_stain_task_assay_cd = f8
         4 s_stain_task_assay_disp = vc
         4 s_c_s_t_ctr = i4
         4 s_content_status_cd = f8
         4 s_content_status_disp = vc
         4 s_content_status_desc = vc
         4 s_content_status_mean = vc
         4 t_qual[*]
           5 t_task_assay_cd = f8
           5 t_task_assay_disp = vc
           5 t_task_assay_desc = vc
           5 t_comment = vc
           5 t_lt_c_updt_cnt = i4
           5 t_comments_long_text_id = f8
           5 t_status_cd = f8
           5 t_status_disp = vc
           5 t_status_desc = vc
           5 t_status_mean = vc
           5 t_request_dt_tm = dq8
           5 t_request_prsnl = vc
           5 t_create_inv_flag = i2
           5 t_order_id = f8
           5 t_hold_cd = f8
           5 t_hold_disp = vc
           5 t_hold_comment = vc
           5 t_updt_dt_tm = dq8
           5 t_status_dt_tm = dq8
           5 t_status_prsnl_name = vc
           5 t_quantity = i4
           5 t_processing_task_id = f8
           5 t_service_resource_cd = f8
           5 t_service_resource_disp = vc
           5 t_service_resource_desc = vc
           5 t_priority_cd = f8
           5 t_priority_disp = vc
           5 t_worklist_nbr = i4
           5 t_updt_cnt = i4
           5 t_cancel_cd = f8
           5 t_cancel_disp = c40
           5 t_no_charge_ind = i2
           5 t_research_account_id = f8
           5 t_task_type_flag = i2
           5 t_mnemonic = vc
           5 t_description = vc
           5 t_stain_ind = i2
         4 s_stain_proc_task_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 exception_data[1]
     2 get_tag_info = c1
     2 get_specimen_info = c1
     2 get_cassette_info = c1
     2 get_slide_info = c1
 )
 RECORD temp(
   1 or_qual[*]
     2 or_id = f8
     2 spec_idx = i4
     2 cass_idx = i4
     2 slide_idx = i4
     2 t_idx = i4
     2 pt_status_cd = f8
   1 ta_qual[*]
     2 ta_id = f8
     2 spec_idx = i4
     2 cass_idx = i4
     2 slide_idx = i4
     2 t_idx = i4
 )
 RECORD inventory(
   1 t_list[*]
     2 id = f8
     2 spec_idx = i4
     2 cass_idx = i4
     2 slide_idx = i4
     2 t_idx = i4
   1 slide_list[*]
     2 id = f8
     2 spec_idx = i4
     2 cass_idx = i4
     2 slide_idx = i4
     2 content_status_cd = f8
   1 cass_list[*]
     2 id = f8
     2 spec_idx = i4
     2 cass_idx = i4
     2 content_status_cd = f8
 )
 DECLARE getcontentstatuscd() = null WITH protect
 DECLARE setcontentstatuscdforreply() = null WITH protect
 DECLARE postqualifyreplyitems() = null WITH protect
 DECLARE discarded_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",2061,"DISCARDED"))
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE ap_tag_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx1 = i4 WITH protect, noconstant(0)
 DECLARE idx2 = i4 WITH protect, noconstant(0)
 DECLARE idx3 = i4 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH noconstant(40)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE lvindex = i4 WITH noconstant(0)
 DECLARE loop_cnt = i4 WITH noconstant(0)
 DECLARE padded_size = i4 WITH noconstant(0)
 DECLARE ninv_t_cnt = i4 WITH noconstant(0)
 DECLARE ninv_s_cnt = i4 WITH noconstant(0)
 DECLARE ninv_c_cnt = i4 WITH noconstant(0)
 DECLARE spec_index = i4 WITH noconstant(0)
 DECLARE cass_index = i4 WITH noconstant(0)
 DECLARE slide_index = i4 WITH noconstant(0)
 DECLARE t_index = i4 WITH noconstant(0)
 DECLARE ntemp_o_cnt = i4 WITH noconstant(0)
 DECLARE ntemp_t_cnt = i4 WITH noconstant(0)
#script
 SET reply->status_data.status = "F"
 SET spec_ctr = 0
 SET s_slide_ctr = 0
 SET s_c_ctr = 0
 SET s_c_slide_ctr = 0
 SET s_t_ctr = 0
 SET s_s_t_ctr = 0
 SET s_c_t_ctr = 0
 SET s_c_s_t_ctr = 0
 SET billing_task_cd = uar_get_code_by("MEANING",5801,"APBILLING")
 SET code_cancel = uar_get_code_by("MEANING",1305,"CANCEL")
 SET code_verify = uar_get_code_by("MEANING",1305,"VERIFIED")
 IF (((code_cancel <= 0) OR (((code_verify <= 0) OR (discarded_cd <= 0)) )) )
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  IF (code_cancel <= 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - CANCEL"
  ELSEIF (code_verify <= 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - VERIFIED"
  ELSE
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - DISCARDED"
  ENDIF
  GO TO exit_program
 ENDIF
 DECLARE determineexpandtotal(lactualsize=i4,lexpandsize=i4) = i4 WITH protect, noconstant(0)
 DECLARE determineexpandsize(lrecordsize=i4,lmaximumsize=i4) = i4 WITH protect, noconstant(0)
 SUBROUTINE determineexpandtotal(lactualsize,lexpandsize)
   RETURN((ceil((cnvtreal(lactualsize)/ lexpandsize)) * lexpandsize))
 END ;Subroutine
 SUBROUTINE determineexpandsize(lrecordsize,lmaximumsize)
   DECLARE lreturn = i4 WITH protect, noconstant(0)
   IF (lrecordsize <= 1)
    SET lreturn = 1
   ELSEIF (lrecordsize <= 10)
    SET lreturn = 10
   ELSEIF (lrecordsize <= 500)
    SET lreturn = 50
   ELSE
    SET lreturn = 100
   ENDIF
   IF (lmaximumsize < lreturn)
    SET lreturn = lmaximumsize
   ENDIF
   RETURN(lreturn)
 END ;Subroutine
 IF ( NOT (validate(temp_ap_tag,0)))
  RECORD temp_ap_tag(
    1 qual[*]
      2 tag_group_id = f8
      2 tag_id = f8
      2 tag_sequence = i4
      2 tag_disp = c7
  )
 ENDIF
 DECLARE aps_get_tags(none) = i4
 SUBROUTINE aps_get_tags(none)
   DECLARE tag_cnt = i4 WITH protect, noconstant(0)
   DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
   DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
   SELECT INTO "nl:"
    ap.tag_id
    FROM ap_tag ap
    WHERE ap.active_ind=1
    ORDER BY ap.tag_group_id, ap.tag_sequence
    HEAD REPORT
     tag_cnt = 0
    DETAIL
     tag_cnt = (tag_cnt+ 1)
     IF (tag_cnt > size(temp_ap_tag->qual,5))
      stat = alterlist(temp_ap_tag->qual,(tag_cnt+ 9))
     ENDIF
     temp_ap_tag->qual[tag_cnt].tag_group_id = ap.tag_group_id, temp_ap_tag->qual[tag_cnt].tag_id =
     ap.tag_id, temp_ap_tag->qual[tag_cnt].tag_sequence = ap.tag_sequence,
     temp_ap_tag->qual[tag_cnt].tag_disp = ap.tag_disp
    FOOT REPORT
     stat = alterlist(temp_ap_tag->qual,tag_cnt)
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (((error_check != 0) OR (tag_cnt=0)) )
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_TAG"
    SET reply->status_data.status = "Z"
    RETURN(0)
   ENDIF
   RETURN(tag_cnt)
 END ;Subroutine
 SET ap_tag_cnt = aps_get_tags(0)
 IF (ap_tag_cnt=0)
  GO TO exit_program
 ENDIF
 SET reply->case_id = request->case_id
 SELECT
  IF ((request->return_specimens_ind > 0))
   PLAN (pt
    WHERE (request->case_id=pt.case_id)
     AND pt.status_prsnl_id > 0
     AND pt.request_prsnl_id > 0)
    JOIN (p
    WHERE p.person_id=pt.status_prsnl_id)
    JOIN (p2
    WHERE p2.person_id=pt.request_prsnl_id)
    JOIN (ataa
    WHERE ((ataa.task_assay_cd=pt.task_assay_cd) OR (ataa.task_assay_cd=0
     AND pt.create_inventory_flag=4)) )
  ELSE
   PLAN (pt
    WHERE (request->case_id=pt.case_id)
     AND pt.status_prsnl_id > 0
     AND pt.request_prsnl_id > 0
     AND pt.create_inventory_flag != 4)
    JOIN (p
    WHERE p.person_id=pt.status_prsnl_id)
    JOIN (p2
    WHERE p2.person_id=pt.request_prsnl_id)
    JOIN (ataa
    WHERE ataa.task_assay_cd=pt.task_assay_cd)
  ENDIF
  INTO "nl:"
  pt.case_id, pt.processing_task_id, pt.status_prsnl_id,
  p.username, pt.case_specimen_id, pt.cassette_id,
  pt.slide_id, pt.status_cd, pt.request_prsnl_id,
  pt.task_assay_cd, pt.order_id, pt.create_inventory_flag,
  ncreatespecimen = evaluate(pt.create_inventory_flag,4,1,0), ncreateblock = evaluate(pt
   .create_inventory_flag,1,1,2,0,
   3,1,4,0,0,
   0), ncreateslide = evaluate(pt.create_inventory_flag,1,0,2,1,
   3,1,4,0,0,
   0),
  ap_tag_spec_idx = locateval(idx1,1,ap_tag_cnt,pt.case_specimen_tag_id,temp_ap_tag->qual[idx1].
   tag_id), ap_tag_cass_idx = evaluate(pt.cassette_id,0.0,0,locateval(idx2,1,ap_tag_cnt,pt
    .cassette_tag_id,temp_ap_tag->qual[idx2].tag_id)), ap_tag_slide_idx = evaluate(pt.slide_id,0.0,0,
   locateval(idx3,1,ap_tag_cnt,pt.slide_tag_id,temp_ap_tag->qual[idx3].tag_id))
  FROM processing_task pt,
   prsnl p,
   prsnl p2,
   ap_task_assay_addl ataa
  ORDER BY ap_tag_spec_idx, ncreatespecimen DESC, ap_tag_cass_idx,
   pt.cassette_id, ncreateblock DESC, ap_tag_slide_idx,
   pt.slide_id, ncreateslide DESC, pt.request_dt_tm
  HEAD REPORT
   spec_ctr = 0, s_slide_ctr = 0, s_c_ctr = 0,
   s_c_slide_ctr = 0, case_cnt = 0, s_t_ctr = 0,
   s_s_t_ctr = 0, s_c_t_ctr = 0, s_c_s_t_ctr = 0,
   stat = alterlist(reply->spec_qual,10), ntemp_o_cnt = 0, ntemp_t_cnt = 0,
   stat = alterlist(temp->or_qual,10), stat = alterlist(temp->ta_qual,10)
  HEAD ap_tag_spec_idx
   spec_ctr = (spec_ctr+ 1)
   IF (spec_ctr > size(reply->spec_qual,5))
    stat = alterlist(reply->spec_qual,(spec_ctr+ 9))
   ENDIF
   reply->spec_ctr = spec_ctr, reply->spec_qual[spec_ctr].case_specimen_id = pt.case_specimen_id,
   s_c_ctr = 0,
   s_t_ctr = 0, s_slide_ctr = 0, stat = alterlist(reply->spec_qual[spec_ctr].cass_qual,10),
   stat = alterlist(reply->spec_qual[spec_ctr].slide_qual,10), stat = alterlist(reply->spec_qual[
    spec_ctr].t_qual,10)
  HEAD pt.cassette_id
   IF (pt.cassette_id != 0.0)
    s_c_ctr = (s_c_ctr+ 1)
    IF (s_c_ctr > size(reply->spec_qual[spec_ctr].cass_qual,5))
     stat = alterlist(reply->spec_qual[spec_ctr].cass_qual,(s_c_ctr+ 9))
    ENDIF
    reply->spec_qual[spec_ctr].s_c_ctr = s_c_ctr, reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].
    cass_id = pt.cassette_id, stat = alterlist(reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].
     slide_qual,10),
    stat = alterlist(reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual,10)
   ENDIF
   s_c_slide_ctr = 0, s_c_t_ctr = 0
  HEAD pt.slide_id
   IF (pt.cassette_id != 0.00)
    IF (pt.slide_id != 0.00)
     s_c_slide_ctr = (s_c_slide_ctr+ 1)
     IF (s_c_slide_ctr > size(reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual,5))
      stat = alterlist(reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual,(s_c_slide_ctr+ 9))
     ENDIF
     reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].s_c_slide_ctr = s_c_slide_ctr, reply->spec_qual[
     spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].s_slide_id = pt.slide_id, stat =
     alterlist(reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual,10)
    ENDIF
   ELSE
    IF (pt.slide_id != 0.00)
     s_slide_ctr = (s_slide_ctr+ 1)
     IF (s_slide_ctr > size(reply->spec_qual[spec_ctr].slide_qual,5))
      stat = alterlist(reply->spec_qual[spec_ctr].slide_qual,(s_slide_ctr+ 9))
     ENDIF
     reply->spec_qual[spec_ctr].s_slide_ctr = s_slide_ctr, reply->spec_qual[spec_ctr].slide_qual[
     s_slide_ctr].sl_slide_id = pt.slide_id, stat = alterlist(reply->spec_qual[spec_ctr].slide_qual[
      s_slide_ctr].t_qual,10)
    ENDIF
   ENDIF
   s_c_s_t_ctr = 0, s_s_t_ctr = 0
  DETAIL
   IF (pt.cassette_id > 0)
    IF (pt.slide_id > 0)
     s_c_s_t_ctr = (s_c_s_t_ctr+ 1)
     IF (s_c_s_t_ctr > size(reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].
      t_qual,5))
      stat = alterlist(reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual,
       (s_c_s_t_ctr+ 9))
     ENDIF
     reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].s_c_s_t_ctr =
     s_c_s_t_ctr, reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[
     s_c_s_t_ctr].t_task_assay_cd = pt.task_assay_cd, reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].
     slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_comments_long_text_id = pt.comments_long_text_id,
     reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].
     t_status_cd = pt.status_cd, reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[
     s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_request_dt_tm = pt.request_dt_tm, reply->spec_qual[spec_ctr
     ].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_request_prsnl = p2
     .name_full_formatted,
     reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].
     t_status_prsnl_name = p.name_full_formatted, reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].
     slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_hold_cd = pt.hold_cd, reply->spec_qual[spec_ctr]
     .cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_updt_dt_tm = pt.updt_dt_tm,
     reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].
     t_quantity = pt.quantity, reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr
     ].t_qual[s_c_s_t_ctr].t_processing_task_id = pt.processing_task_id, reply->spec_qual[spec_ctr].
     cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_service_resource_cd = pt
     .service_resource_cd,
     reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].
     t_updt_cnt = pt.updt_cnt, reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr
     ].t_qual[s_c_s_t_ctr].t_priority_cd = pt.priority_cd, reply->spec_qual[spec_ctr].cass_qual[
     s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_worklist_nbr = pt.worklist_nbr,
     reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].
     t_cancel_cd = pt.cancel_cd, reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[
     s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_create_inv_flag = pt.create_inventory_flag, reply->
     spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_order_id
      = pt.order_id,
     reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].
     t_no_charge_ind = pt.no_charge_ind, reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[
     s_c_slide_ctr].t_qual[s_c_s_t_ctr].t_research_account_id = pt.research_account_id, reply->
     spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].
     t_task_type_flag = ataa.task_type_flag,
     reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].
     t_stain_ind = ataa.stain_ind
     IF (ataa.stain_ind > 0)
      reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].s_stain_proc_task_id =
      pt.processing_task_id
     ENDIF
     reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual[s_c_s_t_ctr].
     t_mnemonic = ""
     IF (pt.order_id > 0)
      ntemp_o_cnt = (ntemp_o_cnt+ 1)
      IF (ntemp_o_cnt > size(temp->or_qual,5))
       stat = alterlist(temp->or_qual,(ntemp_o_cnt+ 9))
      ENDIF
      temp->or_qual[ntemp_o_cnt].or_id = pt.order_id, temp->or_qual[ntemp_o_cnt].pt_status_cd = pt
      .status_cd, temp->or_qual[ntemp_o_cnt].spec_idx = spec_ctr,
      temp->or_qual[ntemp_o_cnt].cass_idx = s_c_ctr, temp->or_qual[ntemp_o_cnt].slide_idx =
      s_c_slide_ctr, temp->or_qual[ntemp_o_cnt].t_idx = s_c_s_t_ctr
     ELSEIF (pt.order_id=0)
      ntemp_t_cnt = (ntemp_t_cnt+ 1)
      IF (ntemp_t_cnt > size(temp->ta_qual,5))
       stat = alterlist(temp->ta_qual,(ntemp_t_cnt+ 9))
      ENDIF
      temp->ta_qual[ntemp_t_cnt].ta_id = pt.task_assay_cd, temp->ta_qual[ntemp_t_cnt].spec_idx =
      spec_ctr, temp->ta_qual[ntemp_t_cnt].cass_idx = s_c_ctr,
      temp->ta_qual[ntemp_t_cnt].slide_idx = s_c_slide_ctr, temp->ta_qual[ntemp_t_cnt].t_idx =
      s_c_s_t_ctr
     ENDIF
    ELSE
     s_c_t_ctr = (s_c_t_ctr+ 1)
     IF (s_c_t_ctr > size(reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual,5))
      stat = alterlist(reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual,(s_c_t_ctr+ 9))
     ENDIF
     reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].s_c_t_ctr = s_c_t_ctr, reply->spec_qual[spec_ctr].
     cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_task_assay_cd = pt.task_assay_cd, reply->spec_qual[
     spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_comments_long_text_id = pt
     .comments_long_text_id,
     reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_status_cd = pt.status_cd,
     reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_status_prsnl_name = p
     .name_full_formatted, reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].
     t_request_dt_tm = pt.request_dt_tm,
     reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_request_prsnl = p2
     .name_full_formatted, reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_hold_cd
      = pt.hold_cd, reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_updt_dt_tm = pt
     .updt_dt_tm,
     reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_quantity = pt.quantity, reply
     ->spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_processing_task_id = pt
     .processing_task_id, reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].
     t_service_resource_cd = pt.service_resource_cd,
     reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_updt_cnt = pt.updt_cnt, reply
     ->spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_priority_cd = pt.priority_cd, reply
     ->spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_worklist_nbr = pt.worklist_nbr,
     reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_cancel_cd = pt.cancel_cd,
     reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_create_inv_flag = pt
     .create_inventory_flag, reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].
     t_order_id = pt.order_id,
     reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_no_charge_ind = pt
     .no_charge_ind, reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].
     t_research_account_id = pt.research_account_id, reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].
     t_qual[s_c_t_ctr].t_task_type_flag = ataa.task_type_flag,
     reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual[s_c_t_ctr].t_mnemonic = ""
     IF (pt.order_id > 0)
      ntemp_o_cnt = (ntemp_o_cnt+ 1)
      IF (ntemp_o_cnt > size(temp->or_qual,5))
       stat = alterlist(temp->or_qual,(ntemp_o_cnt+ 9))
      ENDIF
      temp->or_qual[ntemp_o_cnt].or_id = pt.order_id, temp->or_qual[ntemp_o_cnt].pt_status_cd = pt
      .status_cd, temp->or_qual[ntemp_o_cnt].spec_idx = spec_ctr,
      temp->or_qual[ntemp_o_cnt].cass_idx = s_c_ctr, temp->or_qual[ntemp_o_cnt].slide_idx = 0, temp->
      or_qual[ntemp_o_cnt].t_idx = s_c_t_ctr
     ELSEIF (pt.order_id=0)
      ntemp_t_cnt = (ntemp_t_cnt+ 1)
      IF (ntemp_t_cnt > size(temp->ta_qual,5))
       stat = alterlist(temp->ta_qual,(ntemp_t_cnt+ 9))
      ENDIF
      temp->ta_qual[ntemp_t_cnt].ta_id = pt.task_assay_cd, temp->ta_qual[ntemp_t_cnt].spec_idx =
      spec_ctr, temp->ta_qual[ntemp_t_cnt].cass_idx = s_c_ctr,
      temp->ta_qual[ntemp_t_cnt].slide_idx = 0, temp->ta_qual[ntemp_t_cnt].t_idx = s_c_t_ctr
     ENDIF
    ENDIF
   ELSE
    IF (pt.slide_id > 0)
     s_s_t_ctr = (s_s_t_ctr+ 1)
     IF (s_s_t_ctr > size(reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual,5))
      stat = alterlist(reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual,(s_s_t_ctr+ 9))
     ENDIF
     reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].s_s_t_ctr = s_s_t_ctr, reply->spec_qual[
     spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_task_assay_cd = pt.task_assay_cd, reply->
     spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_comments_long_text_id = pt
     .comments_long_text_id,
     reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_status_cd = pt.status_cd,
     reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_status_prsnl_name = p
     .name_full_formatted, reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].
     t_request_dt_tm = pt.request_dt_tm,
     reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_request_prsnl = p2
     .name_full_formatted, reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].
     t_hold_cd = pt.hold_cd, reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].
     t_updt_dt_tm = pt.updt_dt_tm,
     reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_quantity = pt.quantity,
     reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_processing_task_id = pt
     .processing_task_id, reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].
     t_service_resource_cd = pt.service_resource_cd,
     reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_updt_cnt = pt.updt_cnt,
     reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_priority_cd = pt
     .priority_cd, reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].
     t_worklist_nbr = pt.worklist_nbr,
     reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_cancel_cd = pt.cancel_cd,
     reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_create_inv_flag = pt
     .create_inventory_flag, reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].
     t_order_id = pt.order_id,
     reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_no_charge_ind = pt
     .no_charge_ind, reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].
     t_research_account_id = pt.research_account_id, reply->spec_qual[spec_ctr].slide_qual[
     s_slide_ctr].t_qual[s_s_t_ctr].t_task_type_flag = ataa.task_type_flag,
     reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_stain_ind = ataa
     .stain_ind
     IF (ataa.stain_ind > 0)
      reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].sl_stain_proc_task_id = pt
      .processing_task_id
     ENDIF
     reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual[s_s_t_ctr].t_mnemonic = ""
     IF (pt.order_id > 0)
      ntemp_o_cnt = (ntemp_o_cnt+ 1)
      IF (ntemp_o_cnt > size(temp->or_qual,5))
       stat = alterlist(temp->or_qual,(ntemp_o_cnt+ 9))
      ENDIF
      temp->or_qual[ntemp_o_cnt].or_id = pt.order_id, temp->or_qual[ntemp_o_cnt].pt_status_cd = pt
      .status_cd, temp->or_qual[ntemp_o_cnt].spec_idx = spec_ctr,
      temp->or_qual[ntemp_o_cnt].cass_idx = 0, temp->or_qual[ntemp_o_cnt].slide_idx = s_slide_ctr,
      temp->or_qual[ntemp_o_cnt].t_idx = s_s_t_ctr
     ELSEIF (pt.order_id=0)
      ntemp_t_cnt = (ntemp_t_cnt+ 1)
      IF (ntemp_t_cnt > size(temp->ta_qual,5))
       stat = alterlist(temp->ta_qual,(ntemp_t_cnt+ 9))
      ENDIF
      temp->ta_qual[ntemp_t_cnt].ta_id = pt.task_assay_cd, temp->ta_qual[ntemp_t_cnt].spec_idx =
      spec_ctr, temp->ta_qual[ntemp_t_cnt].cass_idx = 0,
      temp->ta_qual[ntemp_t_cnt].slide_idx = s_slide_ctr, temp->ta_qual[ntemp_t_cnt].t_idx =
      s_s_t_ctr
     ENDIF
    ELSE
     s_t_ctr = (s_t_ctr+ 1)
     IF (s_t_ctr > size(reply->spec_qual[spec_ctr].t_qual,5))
      stat = alterlist(reply->spec_qual[spec_ctr].t_qual,(s_t_ctr+ 9))
     ENDIF
     reply->spec_qual[spec_ctr].s_t_ctr = s_t_ctr, reply->spec_qual[spec_ctr].t_qual[s_t_ctr].
     t_task_assay_cd = pt.task_assay_cd, reply->spec_qual[spec_ctr].t_qual[s_t_ctr].
     t_comments_long_text_id = pt.comments_long_text_id,
     reply->spec_qual[spec_ctr].t_qual[s_t_ctr].t_status_cd = pt.status_cd, reply->spec_qual[spec_ctr
     ].t_qual[s_t_ctr].t_status_prsnl_name = p.name_full_formatted, reply->spec_qual[spec_ctr].
     t_qual[s_t_ctr].t_request_dt_tm = pt.request_dt_tm,
     reply->spec_qual[spec_ctr].t_qual[s_t_ctr].t_request_prsnl = p2.name_full_formatted, reply->
     spec_qual[spec_ctr].t_qual[s_t_ctr].t_hold_cd = pt.hold_cd, reply->spec_qual[spec_ctr].t_qual[
     s_t_ctr].t_updt_dt_tm = pt.updt_dt_tm,
     reply->spec_qual[spec_ctr].t_qual[s_t_ctr].t_quantity = pt.quantity, reply->spec_qual[spec_ctr].
     t_qual[s_t_ctr].t_processing_task_id = pt.processing_task_id, reply->spec_qual[spec_ctr].t_qual[
     s_t_ctr].t_service_resource_cd = pt.service_resource_cd,
     reply->spec_qual[spec_ctr].t_qual[s_t_ctr].t_updt_cnt = pt.updt_cnt, reply->spec_qual[spec_ctr].
     t_qual[s_t_ctr].t_priority_cd = pt.priority_cd, reply->spec_qual[spec_ctr].t_qual[s_t_ctr].
     t_worklist_nbr = pt.worklist_nbr,
     reply->spec_qual[spec_ctr].t_qual[s_t_ctr].t_cancel_cd = pt.cancel_cd, reply->spec_qual[spec_ctr
     ].t_qual[s_t_ctr].t_create_inv_flag = pt.create_inventory_flag, reply->spec_qual[spec_ctr].
     t_qual[s_t_ctr].t_order_id = pt.order_id,
     reply->spec_qual[spec_ctr].t_qual[s_t_ctr].t_cassette_tag_cd = pt.cassette_tag_id, reply->
     spec_qual[spec_ctr].t_qual[s_t_ctr].t_slide_tag_cd = pt.slide_tag_id, reply->spec_qual[spec_ctr]
     .t_qual[s_t_ctr].t_no_charge_ind = pt.no_charge_ind,
     reply->spec_qual[spec_ctr].t_qual[s_t_ctr].t_research_account_id = pt.research_account_id, reply
     ->spec_qual[spec_ctr].t_qual[s_t_ctr].t_task_type_flag = ataa.task_type_flag, reply->spec_qual[
     spec_ctr].t_qual[s_t_ctr].t_mnemonic = ""
     IF (pt.order_id > 0)
      ntemp_o_cnt = (ntemp_o_cnt+ 1)
      IF (ntemp_o_cnt > size(temp->or_qual,5))
       stat = alterlist(temp->or_qual,(ntemp_o_cnt+ 9))
      ENDIF
      temp->or_qual[ntemp_o_cnt].or_id = pt.order_id, temp->or_qual[ntemp_o_cnt].pt_status_cd = pt
      .status_cd, temp->or_qual[ntemp_o_cnt].spec_idx = spec_ctr,
      temp->or_qual[ntemp_o_cnt].cass_idx = 0, temp->or_qual[ntemp_o_cnt].slide_idx = 0, temp->
      or_qual[ntemp_o_cnt].t_idx = s_t_ctr
     ELSEIF (pt.order_id=0)
      ntemp_t_cnt = (ntemp_t_cnt+ 1)
      IF (ntemp_t_cnt > size(temp->ta_qual,5))
       stat = alterlist(temp->ta_qual,(ntemp_t_cnt+ 9))
      ENDIF
      temp->ta_qual[ntemp_t_cnt].ta_id = pt.task_assay_cd, temp->ta_qual[ntemp_t_cnt].spec_idx =
      spec_ctr, temp->ta_qual[ntemp_t_cnt].cass_idx = 0,
      temp->ta_qual[ntemp_t_cnt].slide_idx = 0, temp->ta_qual[ntemp_t_cnt].t_idx = s_t_ctr
     ENDIF
    ENDIF
   ENDIF
  FOOT  pt.slide_id
   IF (pt.cassette_id != 0.00)
    IF (pt.slide_id != 0.00)
     stat = alterlist(reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual[s_c_slide_ctr].t_qual,
      s_c_s_t_ctr)
    ENDIF
   ELSE
    IF (pt.slide_id != 0.00)
     stat = alterlist(reply->spec_qual[spec_ctr].slide_qual[s_slide_ctr].t_qual,s_s_t_ctr)
    ENDIF
   ENDIF
  FOOT  pt.cassette_id
   IF (pt.cassette_id != 0.0)
    stat = alterlist(reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].slide_qual,s_c_slide_ctr), stat =
    alterlist(reply->spec_qual[spec_ctr].cass_qual[s_c_ctr].t_qual,s_c_t_ctr)
   ENDIF
  FOOT  ap_tag_spec_idx
   stat = alterlist(reply->spec_qual[spec_ctr].cass_qual,s_c_ctr), stat = alterlist(reply->spec_qual[
    spec_ctr].slide_qual,s_slide_ctr), stat = alterlist(reply->spec_qual[spec_ctr].t_qual,s_t_ctr)
  FOOT REPORT
   stat = alterlist(temp->or_qual,ntemp_o_cnt), stat = alterlist(temp->ta_qual,ntemp_t_cnt), stat =
   alterlist(reply->spec_qual,spec_ctr)
  WITH nocounter
 ;end select
 IF (ntemp_o_cnt > 0)
  SET batch_size = 40
  SET loop_cnt = ceil((cnvtreal(ntemp_o_cnt)/ batch_size))
  SET padded_size = (loop_cnt * batch_size)
  SET stat = alterlist(temp->or_qual,padded_size)
  FOR (idx = (ntemp_o_cnt+ 1) TO padded_size)
   SET temp->or_qual[idx].or_id = temp->or_qual[ntemp_o_cnt].or_id
   SET temp->or_qual[idx].pt_status_cd = temp->or_qual[ntemp_o_cnt].pt_status_cd
  ENDFOR
  SELECT
   IF ((request->task_type_ind=0))
    PLAN (d)
     JOIN (ods
     WHERE expand(idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),ods.order_id,temp->
      or_qual[idx].or_id))
     JOIN (oc
     WHERE oc.catalog_cd=ods.catalog_cd
      AND oc.activity_subtype_cd != billing_task_cd)
   ELSEIF ((request->task_type_ind=1))
    PLAN (d)
     JOIN (ods
     WHERE expand(idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),ods.order_id,temp->
      or_qual[idx].or_id))
     JOIN (oc
     WHERE oc.catalog_cd=ods.catalog_cd
      AND oc.activity_subtype_cd=billing_task_cd)
   ELSE
    PLAN (d)
     JOIN (ods
     WHERE expand(idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),ods.order_id,temp->
      or_qual[idx].or_id))
     JOIN (oc
     WHERE oc.catalog_cd=ods.catalog_cd)
   ENDIF
   INTO "nl:"
   ods.order_id, ods.catalog_cd
   FROM order_catalog oc,
    orders ods,
    (dummyt d  WITH seq = value(loop_cnt))
   DETAIL
    lvindex = 0
    WHILE (assign(lvindex,locateval(idx,(lvindex+ 1),ntemp_o_cnt,ods.order_id,temp->or_qual[idx].
      or_id)) > 0)
      IF (((oc.active_ind=1) OR (oc.active_ind=0
       AND (temp->or_qual[lvindex].pt_status_cd IN (code_cancel, code_verify)))) )
       spec_index = temp->or_qual[lvindex].spec_idx, t_index = temp->or_qual[lvindex].t_idx,
       cass_index = temp->or_qual[lvindex].cass_idx,
       slide_index = temp->or_qual[lvindex].slide_idx
       IF (cass_index > 0
        AND slide_index > 0)
        reply->spec_qual[spec_index].cass_qual[cass_index].slide_qual[slide_index].t_qual[t_index].
        t_mnemonic = oc.primary_mnemonic, reply->spec_qual[spec_index].cass_qual[cass_index].
        slide_qual[slide_index].t_qual[t_index].t_description = oc.description
       ELSEIF (slide_index=0
        AND cass_index > 0)
        reply->spec_qual[spec_index].cass_qual[cass_index].t_qual[t_index].t_mnemonic = oc
        .primary_mnemonic, reply->spec_qual[spec_index].cass_qual[cass_index].t_qual[t_index].
        t_description = oc.description
       ELSEIF (cass_index=0
        AND slide_index > 0)
        reply->spec_qual[spec_index].slide_qual[slide_index].t_qual[t_index].t_mnemonic = oc
        .primary_mnemonic, reply->spec_qual[spec_index].slide_qual[slide_index].t_qual[t_index].
        t_description = oc.description
       ELSE
        reply->spec_qual[spec_index].t_qual[t_index].t_mnemonic = oc.primary_mnemonic, reply->
        spec_qual[spec_index].t_qual[t_index].t_description = oc.description
       ENDIF
      ENDIF
    ENDWHILE
   WITH nocounter
  ;end select
  SET stat = alterlist(temp->or_qual,0)
 ENDIF
 IF (ntemp_t_cnt > 0)
  SET batch_size = 40
  SET loop_cnt = ceil((cnvtreal(ntemp_t_cnt)/ batch_size))
  SET padded_size = (loop_cnt * batch_size)
  SET stat = alterlist(temp->ta_qual,padded_size)
  FOR (idx = (ntemp_t_cnt+ 1) TO padded_size)
    SET temp->ta_qual[idx].ta_id = temp->ta_qual[ntemp_t_cnt].ta_id
  ENDFOR
  SELECT
   IF ((request->task_type_ind=0))
    PLAN (d)
     JOIN (ptr
     WHERE expand(idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),ptr.task_assay_cd,temp->
      ta_qual[idx].ta_id)
      AND ptr.active_ind=1)
     JOIN (oc
     WHERE oc.catalog_cd=ptr.catalog_cd
      AND oc.active_ind=1
      AND oc.activity_subtype_cd != billing_task_cd)
   ELSEIF ((request->task_type_ind=1))
    PLAN (d)
     JOIN (ptr
     WHERE expand(idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),ptr.task_assay_cd,temp->
      ta_qual[idx].ta_id)
      AND ptr.active_ind=1)
     JOIN (oc
     WHERE oc.catalog_cd=ptr.catalog_cd
      AND oc.active_ind=1
      AND oc.activity_subtype_cd=billing_task_cd)
   ELSE
    PLAN (d)
     JOIN (ptr
     WHERE expand(idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),ptr.task_assay_cd,temp->
      ta_qual[idx].ta_id)
      AND ptr.active_ind=1)
     JOIN (oc
     WHERE oc.catalog_cd=ptr.catalog_cd
      AND oc.active_ind=1)
   ENDIF
   INTO "nl:"
   ptr.task_assay_cd, ptr.catalog_cd
   FROM order_catalog oc,
    profile_task_r ptr,
    (dummyt d  WITH seq = value(loop_cnt))
   DETAIL
    lvindex = 0
    WHILE (assign(lvindex,locateval(idx,(lvindex+ 1),ntemp_t_cnt,ptr.task_assay_cd,temp->ta_qual[idx]
      .ta_id)) > 0)
      spec_index = temp->ta_qual[lvindex].spec_idx, t_index = temp->ta_qual[lvindex].t_idx,
      cass_index = temp->ta_qual[lvindex].cass_idx,
      slide_index = temp->ta_qual[lvindex].slide_idx
      IF (cass_index > 0
       AND slide_index > 0)
       reply->spec_qual[spec_index].cass_qual[cass_index].slide_qual[slide_index].t_qual[t_index].
       t_mnemonic = oc.primary_mnemonic, reply->spec_qual[spec_index].cass_qual[cass_index].
       slide_qual[slide_index].t_qual[t_index].t_description = oc.description
      ELSEIF (slide_index=0
       AND cass_index > 0)
       reply->spec_qual[spec_index].cass_qual[cass_index].t_qual[t_index].t_mnemonic = oc
       .primary_mnemonic, reply->spec_qual[spec_index].cass_qual[cass_index].t_qual[t_index].
       t_description = oc.description
      ELSEIF (cass_index=0
       AND slide_index > 0)
       reply->spec_qual[spec_index].slide_qual[slide_index].t_qual[t_index].t_mnemonic = oc
       .primary_mnemonic, reply->spec_qual[spec_index].slide_qual[slide_index].t_qual[t_index].
       t_description = oc.description
      ELSE
       reply->spec_qual[spec_index].t_qual[t_index].t_mnemonic = oc.primary_mnemonic, reply->
       spec_qual[spec_index].t_qual[t_index].t_description = oc.description
      ENDIF
    ENDWHILE
   WITH nocounter
  ;end select
  SET stat = alterlist(temp->ta_qual,0)
 ENDIF
 CALL postqualifyreplyitems(null)
 SELECT INTO "nl:"
  pc.prefix_id, aptg_r.tag_type_flag, aptg_r.tag_separator
  FROM pathology_case pc,
   ap_prefix_tag_group_r aptg_r
  PLAN (pc
   WHERE (reply->case_id=pc.case_id))
   JOIN (aptg_r
   WHERE pc.prefix_id=aptg_r.prefix_id
    AND aptg_r.tag_type_flag > 1)
  ORDER BY pc.prefix_id
  HEAD REPORT
   tag_ctr = 0
  HEAD pc.prefix_id
   reply->prefix_cd = pc.prefix_id
  DETAIL
   tag_ctr = (tag_ctr+ 1)
   IF (tag_ctr > size(reply->tag_qual,5))
    stat = alter(reply->tag_qual,tag_ctr)
   ENDIF
   reply->tag_qual[tag_ctr].tag_type_flag = aptg_r.tag_type_flag, reply->tag_qual[tag_ctr].
   tag_separator = aptg_r.tag_separator, reply->tag_qual[tag_ctr].tag_group_cd = aptg_r.tag_group_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "prefix_tag_group_r"
  SET reply->exception_data[1].get_tag_info = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (ninv_c_cnt > 0)
  SET batch_size = 40
  SET loop_cnt = ceil((cnvtreal(ninv_c_cnt)/ batch_size))
  SET padded_size = (loop_cnt * batch_size)
  SET stat = alterlist(inventory->cass_list,padded_size)
  FOR (idx = (ninv_c_cnt+ 1) TO padded_size)
    SET inventory->cass_list[idx].id = inventory->cass_list[ninv_c_cnt].id
  ENDFOR
  SELECT INTO "nl:"
   c.pieces
   FROM cassette c,
    ap_task_assay_addl ataa,
    (dummyt d  WITH seq = value(loop_cnt))
   PLAN (d)
    JOIN (c
    WHERE expand(idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),c.cassette_id,inventory->
     cass_list[idx].id))
    JOIN (ataa
    WHERE c.task_assay_cd=ataa.task_assay_cd)
   DETAIL
    ap_tag_cass_idx = locateval(idx2,1,ap_tag_cnt,c.cassette_tag_id,temp_ap_tag->qual[idx2].tag_id),
    lvindex = 0
    WHILE (assign(lvindex,locateval(idx,(lvindex+ 1),ninv_c_cnt,c.cassette_id,inventory->cass_list[
      idx].id)) > 0)
      spec_index = inventory->cass_list[lvindex].spec_idx, cass_index = inventory->cass_list[lvindex]
      .cass_idx
      IF (ap_tag_cass_idx > 0)
       reply->spec_qual[spec_index].cass_qual[cass_index].cass_tag = temp_ap_tag->qual[
       ap_tag_cass_idx].tag_disp, reply->spec_qual[spec_index].cass_qual[cass_index].cass_seq =
       temp_ap_tag->qual[ap_tag_cass_idx].tag_sequence
      ENDIF
      reply->spec_qual[spec_index].cass_qual[cass_index].cass_pieces = c.pieces, reply->spec_qual[
      spec_index].cass_qual[cass_index].cass_fixative_cd = c.fixative_cd, reply->spec_qual[spec_index
      ].cass_qual[cass_index].cass_updt_cnt = c.updt_cnt,
      reply->spec_qual[spec_index].cass_qual[cass_index].cass_origin_modifier = c.origin_modifier,
      reply->spec_qual[spec_index].cass_qual[cass_index].cass_task_assay_cd = c.task_assay_cd, reply
      ->spec_qual[spec_index].cass_qual[cass_index].cass_task_assay_inv_flag = ataa
      .create_inventory_flag
      IF (c.discard_dt_tm != null)
       reply->spec_qual[spec_index].cass_qual[cass_index].cass_content_status_cd = discarded_cd,
       inventory->cass_list[lvindex].content_status_cd = discarded_cd
      ELSEIF (c.original_storage_dt_tm != null)
       reply->spec_qual[spec_index].cass_qual[cass_index].cass_content_status_cd = 0.0, inventory->
       cass_list[lvindex].content_status_cd = 0.0
      ELSE
       inventory->cass_list[lvindex].content_status_cd = - (1.0)
      ENDIF
    ENDWHILE
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASSETTE TAGS, AP_TAG"
   SET reply->exception_data[1].get_cassette_info = "F"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
  SET stat = alterlist(inventory->cass_list,ninv_c_cnt)
 ENDIF
 IF (ninv_s_cnt > 0)
  SET batch_size = 40
  SET loop_cnt = ceil((cnvtreal(ninv_s_cnt)/ batch_size))
  SET padded_size = (loop_cnt * batch_size)
  SET stat = alterlist(inventory->slide_list,padded_size)
  FOR (idx = (ninv_s_cnt+ 1) TO padded_size)
    SET inventory->slide_list[idx].id = inventory->slide_list[ninv_s_cnt].id
  ENDFOR
  SELECT INTO "nl:"
   s.slide_id
   FROM slide s,
    (dummyt d  WITH seq = value(loop_cnt))
   PLAN (d)
    JOIN (s
    WHERE expand(idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),s.slide_id,inventory->
     slide_list[idx].id))
   DETAIL
    lvindex = 0
    WHILE (assign(lvindex,locateval(idx,(lvindex+ 1),ninv_s_cnt,s.slide_id,inventory->slide_list[idx]
      .id)) > 0)
      spec_index = inventory->slide_list[lvindex].spec_idx, slide_index = inventory->slide_list[
      lvindex].slide_idx, cass_index = inventory->slide_list[lvindex].cass_idx
      IF (cass_index=0)
       ap_tag_slide_idx = locateval(idx3,1,ap_tag_cnt,s.tag_id,temp_ap_tag->qual[idx3].tag_id)
       IF (ap_tag_slide_idx > 0)
        reply->spec_qual[spec_index].slide_qual[slide_index].sl_tag = temp_ap_tag->qual[
        ap_tag_slide_idx].tag_disp, reply->spec_qual[spec_index].slide_qual[slide_index].sl_seq =
        temp_ap_tag->qual[ap_tag_slide_idx].tag_sequence
       ENDIF
       reply->spec_qual[spec_index].slide_qual[slide_index].sl_updt_cnt = s.updt_cnt, reply->
       spec_qual[spec_index].slide_qual[slide_index].sl_slide_id = s.slide_id, reply->spec_qual[
       spec_index].slide_qual[slide_index].sl_origin_modifier = s.origin_modifier,
       reply->spec_qual[spec_index].slide_qual[slide_index].sl_stain_task_assay_cd = s
       .stain_task_assay_cd
       IF (s.discard_dt_tm != null)
        reply->spec_qual[spec_index].slide_qual[slide_index].sl_content_status_cd = discarded_cd,
        inventory->slide_list[lvindex].content_status_cd = discarded_cd
       ELSEIF (s.original_storage_dt_tm != null)
        reply->spec_qual[spec_index].slide_qual[slide_index].sl_content_status_cd = 0.0, inventory->
        slide_list[lvindex].content_status_cd = 0.0
       ELSE
        inventory->slide_list[lvindex].content_status_cd = - (1.0)
       ENDIF
      ELSEIF (cass_index > 0)
       ap_tag_slide_idx = locateval(idx3,1,ap_tag_cnt,s.tag_id,temp_ap_tag->qual[idx3].tag_id)
       IF (ap_tag_slide_idx > 0)
        reply->spec_qual[spec_index].cass_qual[cass_index].slide_qual[slide_index].s_tag =
        temp_ap_tag->qual[ap_tag_slide_idx].tag_disp, reply->spec_qual[spec_index].cass_qual[
        cass_index].slide_qual[slide_index].s_seq = temp_ap_tag->qual[ap_tag_slide_idx].tag_sequence
       ENDIF
       reply->spec_qual[spec_index].cass_qual[cass_index].slide_qual[slide_index].s_updt_cnt = s
       .updt_cnt, reply->spec_qual[spec_index].cass_qual[cass_index].slide_qual[slide_index].
       s_slide_id = s.slide_id, reply->spec_qual[spec_index].cass_qual[cass_index].slide_qual[
       slide_index].s_origin_modifier = s.origin_modifier,
       reply->spec_qual[spec_index].cass_qual[cass_index].slide_qual[slide_index].
       s_stain_task_assay_cd = s.stain_task_assay_cd
       IF (s.discard_dt_tm != null)
        reply->spec_qual[spec_index].cass_qual[cass_index].slide_qual[slide_index].
        s_content_status_cd = discarded_cd, inventory->slide_list[lvindex].content_status_cd =
        discarded_cd
       ELSEIF (s.original_storage_dt_tm != null)
        reply->spec_qual[spec_index].cass_qual[cass_index].slide_qual[slide_index].
        s_content_status_cd = 0.0, inventory->slide_list[lvindex].content_status_cd = 0.0
       ELSE
        inventory->slide_list[lvindex].content_status_cd = - (1.0)
       ENDIF
      ENDIF
    ENDWHILE
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "SLIDE TAGS, AP_TAG"
   SET reply->exception_data[1].get_slide_info = "F"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
  SET stat = alterlist(inventory->slide_list,ninv_s_cnt)
 ENDIF
 IF (ninv_t_cnt > 0)
  SET batch_size = 40
  SET loop_cnt = ceil((cnvtreal(ninv_t_cnt)/ batch_size))
  SET padded_size = (loop_cnt * batch_size)
  SET stat = alterlist(inventory->t_list,padded_size)
  FOR (idx = (ninv_t_cnt+ 1) TO padded_size)
    SET inventory->t_list[idx].id = inventory->t_list[ninv_t_cnt].id
  ENDFOR
  SELECT INTO "nl:"
   lt.long_text_id
   FROM long_text lt,
    (dummyt d  WITH seq = value(loop_cnt))
   PLAN (d)
    JOIN (lt
    WHERE expand(idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),lt.long_text_id,inventory->
     t_list[idx].id)
     AND lt.long_text_id > 0)
   DETAIL
    lvindex = 0
    WHILE (assign(lvindex,locateval(idx,(lvindex+ 1),ninv_t_cnt,lt.long_text_id,inventory->t_list[idx
      ].id)) > 0)
      spec_index = inventory->t_list[lvindex].spec_idx, t_index = inventory->t_list[lvindex].t_idx,
      cass_index = inventory->t_list[lvindex].cass_idx,
      slide_index = inventory->t_list[lvindex].slide_idx
      IF (cass_index > 0
       AND slide_index > 0)
       reply->spec_qual[spec_index].cass_qual[cass_index].slide_qual[slide_index].t_qual[t_index].
       t_comment = trim(lt.long_text), reply->spec_qual[spec_index].cass_qual[cass_index].slide_qual[
       slide_index].t_qual[t_index].t_lt_c_updt_cnt = lt.updt_cnt
      ELSEIF (slide_index=0
       AND cass_index > 0)
       reply->spec_qual[spec_index].cass_qual[cass_index].t_qual[t_index].t_comment = trim(lt
        .long_text), reply->spec_qual[spec_index].cass_qual[cass_index].t_qual[t_index].
       t_lt_c_updt_cnt = lt.updt_cnt
      ELSEIF (cass_index=0
       AND slide_index > 0)
       reply->spec_qual[spec_index].slide_qual[slide_index].t_qual[t_index].t_comment = trim(lt
        .long_text), reply->spec_qual[spec_index].slide_qual[slide_index].t_qual[t_index].
       t_lt_c_updt_cnt = lt.updt_cnt
      ELSE
       reply->spec_qual[spec_index].t_qual[t_index].t_comment = trim(lt.long_text), reply->spec_qual[
       spec_index].t_qual[t_index].t_lt_c_updt_cnt = lt.updt_cnt
      ENDIF
    ENDWHILE
   WITH nocounter
  ;end select
  SET stat = alterlist(inventory->t_list,ninv_t_cnt)
 ENDIF
 IF ((request->spec_cnt > 0))
  EXECUTE aps_get_proposed_protocol
 ENDIF
 IF (value(size(reply->spec_qual,5))=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NOSPECTOPROCESS"
  SET reply->status_data.status = "Z"
  GO TO exit_program
 ENDIF
 SET spec_ctr = size(reply->spec_qual,5)
 IF (spec_ctr > 0)
  SET batch_size = 40
  SET loop_cnt = ceil((cnvtreal(spec_ctr)/ batch_size))
  SET padded_size = (loop_cnt * batch_size)
  SET stat = alterlist(reply->spec_qual,padded_size)
  FOR (idx = (spec_ctr+ 1) TO padded_size)
    SET reply->spec_qual[idx].case_specimen_id = reply->spec_qual[spec_ctr].case_specimen_id
  ENDFOR
  SELECT INTO "nl:"
   cs.specimen_description
   FROM case_specimen cs,
    (dummyt d1  WITH seq = value(loop_cnt))
   PLAN (d1)
    JOIN (cs
    WHERE expand(idx,(((d1.seq - 1) * batch_size)+ 1),(d1.seq * batch_size),cs.case_specimen_id,reply
     ->spec_qual[idx].case_specimen_id))
   DETAIL
    lvindex = 0
    WHILE (assign(lvindex,locateval(idx,(lvindex+ 1),spec_ctr,cs.case_specimen_id,reply->spec_qual[
      idx].case_specimen_id)) > 0)
      reply->spec_qual[lvindex].spec_descr = cs.specimen_description, reply->spec_qual[lvindex].
      spec_fixative_cd = cs.received_fixative_cd, reply->spec_qual[lvindex].spec_tag_cd = cs
      .specimen_tag_id,
      reply->spec_qual[lvindex].spec_cd = cs.specimen_cd, reply->spec_qual[lvindex].
      spec_collect_dt_tm = cs.collect_dt_tm, ap_tag_spec_idx = locateval(idx1,1,ap_tag_cnt,cs
       .specimen_tag_id,temp_ap_tag->qual[idx1].tag_id)
      IF (ap_tag_spec_idx > 0)
       reply->spec_qual[lvindex].spec_tag = temp_ap_tag->qual[ap_tag_spec_idx].tag_disp, reply->
       spec_qual[lvindex].spec_seq = temp_ap_tag->qual[ap_tag_spec_idx].tag_sequence, reply->
       spec_qual[lvindex].spec_tag_group_cd = temp_ap_tag->qual[ap_tag_spec_idx].tag_group_id,
       reply->spec_qual[lvindex].spec_tag_sequence = temp_ap_tag->qual[ap_tag_spec_idx].tag_sequence
      ENDIF
    ENDWHILE
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_SPECIMEN"
   SET reply->exception_data[1].get_specimen_info = "F"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
  SET stat = alterlist(reply->spec_qual,spec_ctr)
 ENDIF
 IF (((ninv_s_cnt > 0) OR (ninv_c_cnt > 0)) )
  CALL getcontentstatuscd(null)
  CALL setcontentstatuscdforreply(null)
 ENDIF
 SUBROUTINE getcontentstatuscd(null)
  IF (ninv_s_cnt > 0)
   SET batch_size = determineexpandsize(ninv_s_cnt,40)
   SET loop_cnt = ceil((cnvtreal(ninv_s_cnt)/ batch_size))
   SET padded_size = (loop_cnt * batch_size)
   SET stat = alterlist(inventory->slide_list,padded_size)
   FOR (idx = (ninv_s_cnt+ 1) TO padded_size)
    SET inventory->slide_list[idx].id = inventory->slide_list[ninv_s_cnt].id
    SET inventory->slide_list[idx].content_status_cd = inventory->slide_list[ninv_s_cnt].
    content_status_cd
   ENDFOR
   SELECT INTO "nl:"
    sc.content_status_cd, sc.content_table_id, sc.content_table_name
    FROM storage_content sc,
     (dummyt d  WITH seq = value(loop_cnt))
    PLAN (d)
     JOIN (sc
     WHERE expand(idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),sc.content_table_id,
      inventory->slide_list[idx].id,
      0.0,inventory->slide_list[idx].content_status_cd)
      AND sc.content_table_name="SLIDE")
    DETAIL
     lvindex = 0
     WHILE (assign(lvindex,locateval(idx,(lvindex+ 1),ninv_s_cnt,sc.content_table_id,inventory->
       slide_list[idx].id,
       0.0,inventory->slide_list[idx].content_status_cd)) > 0)
       inventory->slide_list[lvindex].content_status_cd = sc.content_status_cd
     ENDWHILE
    WITH nocounter
   ;end select
   SET stat = alterlist(inventory->slide_list,ninv_s_cnt)
  ENDIF
  IF (ninv_c_cnt > 0)
   SET batch_size = determineexpandsize(ninv_c_cnt,40)
   SET loop_cnt = ceil((cnvtreal(ninv_c_cnt)/ batch_size))
   SET padded_size = (loop_cnt * batch_size)
   SET stat = alterlist(inventory->cass_list,padded_size)
   FOR (idx = (ninv_c_cnt+ 1) TO padded_size)
    SET inventory->cass_list[idx].id = inventory->cass_list[ninv_c_cnt].id
    SET inventory->cass_list[idx].content_status_cd = inventory->cass_list[ninv_c_cnt].
    content_status_cd
   ENDFOR
   SELECT INTO "nl:"
    sc.content_status_cd, sc.content_table_id, sc.content_table_name
    FROM storage_content sc,
     (dummyt d  WITH seq = value(loop_cnt))
    PLAN (d)
     JOIN (sc
     WHERE expand(idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),sc.content_table_id,
      inventory->cass_list[idx].id,
      0.0,inventory->cass_list[idx].content_status_cd)
      AND sc.content_table_name="CASSETTE")
    DETAIL
     lvindex = 0
     WHILE (assign(lvindex,locateval(idx,(lvindex+ 1),ninv_c_cnt,sc.content_table_id,inventory->
       cass_list[idx].id,
       0.0,inventory->cass_list[idx].content_status_cd)) > 0)
       inventory->cass_list[lvindex].content_status_cd = sc.content_status_cd
     ENDWHILE
    WITH nocounter
   ;end select
   SET stat = alterlist(inventory->cass_list,ninv_c_cnt)
  ENDIF
 END ;Subroutine
 SUBROUTINE setcontentstatuscdforreply(null)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   FOR (cnt = 1 TO ninv_c_cnt)
     IF ((inventory->cass_list[cnt].content_status_cd != - (1.0)))
      SET reply->spec_qual[inventory->cass_list[cnt].spec_idx].cass_qual[inventory->cass_list[cnt].
      cass_idx].cass_content_status_cd = inventory->cass_list[cnt].content_status_cd
     ELSE
      SET reply->spec_qual[inventory->cass_list[cnt].spec_idx].cass_qual[inventory->cass_list[cnt].
      cass_idx].cass_content_status_cd = 0
     ENDIF
   ENDFOR
   FOR (cnt = 1 TO ninv_s_cnt)
     IF ((inventory->slide_list[cnt].cass_idx > 0))
      IF ((inventory->slide_list[cnt].content_status_cd != - (1.0)))
       SET reply->spec_qual[inventory->slide_list[cnt].spec_idx].cass_qual[inventory->slide_list[cnt]
       .cass_idx].slide_qual[inventory->slide_list[cnt].slide_idx].s_content_status_cd = inventory->
       slide_list[cnt].content_status_cd
      ELSE
       SET reply->spec_qual[inventory->slide_list[cnt].spec_idx].cass_qual[inventory->slide_list[cnt]
       .cass_idx].slide_qual[inventory->slide_list[cnt].slide_idx].s_content_status_cd = 0
      ENDIF
     ELSE
      IF ((inventory->slide_list[cnt].content_status_cd != - (1.0)))
       SET reply->spec_qual[inventory->slide_list[cnt].spec_idx].slide_qual[inventory->slide_list[cnt
       ].slide_idx].sl_content_status_cd = inventory->slide_list[cnt].content_status_cd
      ELSE
       SET reply->spec_qual[inventory->slide_list[cnt].spec_idx].slide_qual[inventory->slide_list[cnt
       ].slide_idx].sl_content_status_cd = 0
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE postqualifyreplyitems(null)
   SET ninv_t_cnt = 0
   SET ninv_c_cnt = 0
   SET ninv_s_cnt = 0
   SET stat = alterlist(inventory->cass_list,10)
   SET stat = alterlist(inventory->slide_list,10)
   SET stat = alterlist(inventory->t_list,10)
   SET spec_ctr = 0
   FOR (spec_index = 1 TO reply->spec_ctr)
     SET s_t_ctr = 0
     FOR (t_index = 1 TO reply->spec_qual[(spec_index - spec_ctr)].s_t_ctr)
       IF (trim(reply->spec_qual[(spec_index - spec_ctr)].t_qual[(t_index - s_t_ctr)].t_mnemonic)="")
        SET stat = alterlist(reply->spec_qual[(spec_index - spec_ctr)].t_qual,(size(reply->spec_qual[
          (spec_index - spec_ctr)].t_qual,5) - 1),((t_index - 1) - s_t_ctr))
        SET s_t_ctr = (s_t_ctr+ 1)
       ELSE
        SET ninv_t_cnt = (ninv_t_cnt+ 1)
        IF (ninv_t_cnt > size(inventory->t_list,5))
         SET stat = alterlist(inventory->t_list,(ninv_t_cnt+ 9))
        ENDIF
        SET inventory->t_list[ninv_t_cnt].id = reply->spec_qual[(spec_index - spec_ctr)].t_qual[(
        t_index - s_t_ctr)].t_comments_long_text_id
        SET inventory->t_list[ninv_t_cnt].spec_idx = (spec_index - spec_ctr)
        SET inventory->t_list[ninv_t_cnt].cass_idx = 0
        SET inventory->t_list[ninv_t_cnt].slide_idx = 0
        SET inventory->t_list[ninv_t_cnt].t_idx = (t_index - s_t_ctr)
       ENDIF
     ENDFOR
     SET reply->spec_qual[(spec_index - spec_ctr)].s_t_ctr = size(reply->spec_qual[(spec_index -
      spec_ctr)].t_qual,5)
     SET s_c_ctr = 0
     FOR (cass_index = 1 TO reply->spec_qual[(spec_index - spec_ctr)].s_c_ctr)
       SET s_c_t_ctr = 0
       FOR (t_index = 1 TO reply->spec_qual[(spec_index - spec_ctr)].cass_qual[(cass_index - s_c_ctr)
       ].s_c_t_ctr)
         IF (trim(reply->spec_qual[(spec_index - spec_ctr)].cass_qual[(cass_index - s_c_ctr)].t_qual[
          (t_index - s_c_t_ctr)].t_mnemonic)="")
          SET stat = alterlist(reply->spec_qual[(spec_index - spec_ctr)].cass_qual[(cass_index -
           s_c_ctr)].t_qual,(size(reply->spec_qual[(spec_index - spec_ctr)].cass_qual[(cass_index -
            s_c_ctr)].t_qual,5) - 1),((t_index - 1) - s_c_t_ctr))
          SET s_c_t_ctr = (s_c_t_ctr+ 1)
         ELSE
          SET ninv_t_cnt = (ninv_t_cnt+ 1)
          IF (ninv_t_cnt > size(inventory->t_list,5))
           SET stat = alterlist(inventory->t_list,(ninv_t_cnt+ 9))
          ENDIF
          SET inventory->t_list[ninv_t_cnt].id = reply->spec_qual[(spec_index - spec_ctr)].cass_qual[
          (cass_index - s_c_ctr)].t_qual[(t_index - s_t_ctr)].t_comments_long_text_id
          SET inventory->t_list[ninv_t_cnt].spec_idx = (spec_index - spec_ctr)
          SET inventory->t_list[ninv_t_cnt].cass_idx = (cass_index - s_c_ctr)
          SET inventory->t_list[ninv_t_cnt].slide_idx = 0
          SET inventory->t_list[ninv_t_cnt].t_idx = (t_index - s_c_t_ctr)
         ENDIF
       ENDFOR
       SET reply->spec_qual[(spec_index - spec_ctr)].cass_qual[(cass_index - s_c_ctr)].s_c_t_ctr =
       size(reply->spec_qual[(spec_index - spec_ctr)].cass_qual[(cass_index - s_c_ctr)].t_qual,5)
       SET s_c_slide_ctr = 0
       FOR (slide_index = 1 TO reply->spec_qual[(spec_index - spec_ctr)].cass_qual[(cass_index -
       s_c_ctr)].s_c_slide_ctr)
         SET s_c_s_t_ctr = 0
         FOR (t_index = 1 TO reply->spec_qual[(spec_index - spec_ctr)].cass_qual[(cass_index -
         s_c_ctr)].slide_qual[(slide_index - s_c_slide_ctr)].s_c_s_t_ctr)
           IF (trim(reply->spec_qual[(spec_index - spec_ctr)].cass_qual[(cass_index - s_c_ctr)].
            slide_qual[(slide_index - s_c_slide_ctr)].t_qual[(t_index - s_c_s_t_ctr)].t_mnemonic)="")
            SET stat = alterlist(reply->spec_qual[(spec_index - spec_ctr)].cass_qual[(cass_index -
             s_c_ctr)].slide_qual[(slide_index - s_c_slide_ctr)].t_qual,(size(reply->spec_qual[(
              spec_index - spec_ctr)].cass_qual[(cass_index - s_c_ctr)].slide_qual[(slide_index -
              s_c_slide_ctr)].t_qual,5) - 1),((t_index - 1) - s_c_s_t_ctr))
            SET s_c_s_t_ctr = (s_c_s_t_ctr+ 1)
           ELSE
            SET ninv_t_cnt = (ninv_t_cnt+ 1)
            IF (ninv_t_cnt > size(inventory->t_list,5))
             SET stat = alterlist(inventory->t_list,(ninv_t_cnt+ 9))
            ENDIF
            SET inventory->t_list[ninv_t_cnt].id = reply->spec_qual[(spec_index - spec_ctr)].
            cass_qual[(cass_index - s_c_ctr)].slide_qual[(slide_index - s_c_slide_ctr)].t_qual[(
            t_index - s_c_s_t_ctr)].t_comments_long_text_id
            SET inventory->t_list[ninv_t_cnt].spec_idx = (spec_index - spec_ctr)
            SET inventory->t_list[ninv_t_cnt].cass_idx = (cass_index - s_c_ctr)
            SET inventory->t_list[ninv_t_cnt].slide_idx = (slide_index - s_c_slide_ctr)
            SET inventory->t_list[ninv_t_cnt].t_idx = (t_index - s_c_s_t_ctr)
           ENDIF
         ENDFOR
         SET reply->spec_qual[(spec_index - spec_ctr)].cass_qual[(cass_index - s_c_ctr)].slide_qual[(
         slide_index - s_c_slide_ctr)].s_c_s_t_ctr = size(reply->spec_qual[(spec_index - spec_ctr)].
          cass_qual[(cass_index - s_c_ctr)].slide_qual[(slide_index - s_c_slide_ctr)].t_qual,5)
         IF ((reply->spec_qual[(spec_index - spec_ctr)].cass_qual[(cass_index - s_c_ctr)].slide_qual[
         (slide_index - s_c_slide_ctr)].s_c_s_t_ctr=0))
          SET stat = alterlist(reply->spec_qual[(spec_index - spec_ctr)].cass_qual[(cass_index -
           s_c_ctr)].slide_qual,(size(reply->spec_qual[(spec_index - spec_ctr)].cass_qual[(cass_index
             - s_c_ctr)].slide_qual,5) - 1),((slide_index - 1) - s_c_slide_ctr))
          SET s_c_slide_ctr = (s_c_slide_ctr+ 1)
         ELSE
          SET ninv_s_cnt = (ninv_s_cnt+ 1)
          IF (ninv_s_cnt > size(inventory->slide_list,5))
           SET stat = alterlist(inventory->slide_list,(ninv_s_cnt+ 9))
          ENDIF
          SET inventory->slide_list[ninv_s_cnt].id = reply->spec_qual[(spec_index - spec_ctr)].
          cass_qual[(cass_index - s_c_ctr)].slide_qual[(slide_index - s_c_slide_ctr)].s_slide_id
          SET inventory->slide_list[ninv_s_cnt].spec_idx = (spec_index - spec_ctr)
          SET inventory->slide_list[ninv_s_cnt].cass_idx = (cass_index - s_c_ctr)
          SET inventory->slide_list[ninv_s_cnt].slide_idx = (slide_index - s_c_slide_ctr)
         ENDIF
       ENDFOR
       SET reply->spec_qual[(spec_index - spec_ctr)].cass_qual[(cass_index - s_c_ctr)].s_c_slide_ctr
        = size(reply->spec_qual[(spec_index - spec_ctr)].cass_qual[(cass_index - s_c_ctr)].slide_qual,
        5)
       IF ((reply->spec_qual[(spec_index - spec_ctr)].cass_qual[(cass_index - s_c_ctr)].s_c_t_ctr=0)
        AND (reply->spec_qual[(spec_index - spec_ctr)].cass_qual[(cass_index - s_c_ctr)].
       s_c_slide_ctr=0))
        SET stat = alterlist(reply->spec_qual[(spec_index - spec_ctr)].cass_qual,(size(reply->
          spec_qual[(spec_index - spec_ctr)].cass_qual,5) - 1),((cass_index - 1) - s_c_ctr))
        SET s_c_ctr = (s_c_ctr+ 1)
       ELSE
        SET ninv_c_cnt = (ninv_c_cnt+ 1)
        IF (ninv_c_cnt > size(inventory->cass_list,5))
         SET stat = alterlist(inventory->cass_list,(ninv_c_cnt+ 9))
        ENDIF
        SET inventory->cass_list[ninv_c_cnt].id = reply->spec_qual[(spec_index - spec_ctr)].
        cass_qual[(cass_index - s_c_ctr)].cass_id
        SET inventory->cass_list[ninv_c_cnt].spec_idx = (spec_index - spec_ctr)
        SET inventory->cass_list[ninv_c_cnt].cass_idx = (cass_index - s_c_ctr)
       ENDIF
     ENDFOR
     SET reply->spec_qual[(spec_index - spec_ctr)].s_c_ctr = size(reply->spec_qual[(spec_index -
      spec_ctr)].cass_qual,5)
     SET s_slide_ctr = 0
     FOR (slide_index = 1 TO reply->spec_qual[(spec_index - spec_ctr)].s_slide_ctr)
       SET s_s_t_ctr = 0
       FOR (t_index = 1 TO reply->spec_qual[(spec_index - spec_ctr)].slide_qual[(slide_index -
       s_slide_ctr)].s_s_t_ctr)
         IF (trim(reply->spec_qual[(spec_index - spec_ctr)].slide_qual[(slide_index - s_slide_ctr)].
          t_qual[(t_index - s_s_t_ctr)].t_mnemonic)="")
          SET stat = alterlist(reply->spec_qual[(spec_index - spec_ctr)].slide_qual[(slide_index -
           s_slide_ctr)].t_qual,(size(reply->spec_qual[(spec_index - spec_ctr)].slide_qual[(
            slide_index - s_slide_ctr)].t_qual,5) - 1),((t_index - 1) - s_s_t_ctr))
          SET s_s_t_ctr = (s_s_t_ctr+ 1)
         ELSE
          SET ninv_t_cnt = (ninv_t_cnt+ 1)
          IF (ninv_t_cnt > size(inventory->t_list,5))
           SET stat = alterlist(inventory->t_list,(ninv_t_cnt+ 9))
          ENDIF
          SET inventory->t_list[ninv_t_cnt].id = reply->spec_qual[(spec_index - spec_ctr)].
          slide_qual[(slide_index - s_slide_ctr)].t_qual[(t_index - s_s_t_ctr)].
          t_comments_long_text_id
          SET inventory->t_list[ninv_t_cnt].spec_idx = (spec_index - spec_ctr)
          SET inventory->t_list[ninv_t_cnt].cass_idx = 0
          SET inventory->t_list[ninv_t_cnt].slide_idx = (slide_index - s_slide_ctr)
          SET inventory->t_list[ninv_t_cnt].t_idx = (t_index - s_s_t_ctr)
         ENDIF
       ENDFOR
       SET reply->spec_qual[(spec_index - spec_ctr)].slide_qual[(slide_index - s_slide_ctr)].
       s_s_t_ctr = size(reply->spec_qual[(spec_index - spec_ctr)].slide_qual[(slide_index -
        s_slide_ctr)].t_qual,5)
       IF ((reply->spec_qual[(spec_index - spec_ctr)].slide_qual[(slide_index - s_slide_ctr)].
       s_s_t_ctr=0))
        SET stat = alterlist(reply->spec_qual[(spec_index - spec_ctr)].slide_qual,(size(reply->
          spec_qual[(spec_index - spec_ctr)].slide_qual,5) - 1),((slide_index - 1) - s_slide_ctr))
        SET s_slide_ctr = (s_slide_ctr+ 1)
       ELSE
        SET ninv_s_cnt = (ninv_s_cnt+ 1)
        IF (ninv_s_cnt > size(inventory->slide_list,5))
         SET stat = alterlist(inventory->slide_list,(ninv_s_cnt+ 9))
        ENDIF
        SET inventory->slide_list[ninv_s_cnt].id = reply->spec_qual[(spec_index - spec_ctr)].
        slide_qual[(slide_index - s_slide_ctr)].sl_slide_id
        SET inventory->slide_list[ninv_s_cnt].spec_idx = (spec_index - spec_ctr)
        SET inventory->slide_list[ninv_s_cnt].cass_idx = 0
        SET inventory->slide_list[ninv_s_cnt].slide_idx = (slide_index - s_slide_ctr)
       ENDIF
     ENDFOR
     SET reply->spec_qual[(spec_index - spec_ctr)].s_slide_ctr = size(reply->spec_qual[(spec_index -
      spec_ctr)].slide_qual,5)
     IF ((reply->spec_qual[(spec_index - spec_ctr)].s_t_ctr=0)
      AND (reply->spec_qual[(spec_index - spec_ctr)].s_c_ctr=0)
      AND (reply->spec_qual[(spec_index - spec_ctr)].s_slide_ctr=0))
      SET stat = alterlist(reply->spec_qual,(size(reply->spec_qual,5) - 1),((spec_index - 1) -
       spec_ctr))
      SET spec_ctr = (spec_ctr+ 1)
     ENDIF
   ENDFOR
   SET reply->spec_ctr = size(reply->spec_qual,5)
   SET stat = alterlist(inventory->cass_list,ninv_c_cnt)
   SET stat = alterlist(inventory->slide_list,ninv_s_cnt)
   SET stat = alterlist(inventory->t_list,ninv_t_cnt)
 END ;Subroutine
#exit_program
 IF ((reply->exception_data[1].get_tag_info="F")
  AND (reply->exception_data[1].get_specimen_info="F")
  AND (reply->exception_data[1].get_cassette_info="F")
  AND (reply->exception_data[1].get_slide_info="F"))
  SET reply->status_data.status = "F"
 ENDIF
 IF (validate(temp_ap_tag,0))
  FREE RECORD temp_ap_tag
 ENDIF
 FREE RECORD inventory
 FREE RECORD temp
END GO
