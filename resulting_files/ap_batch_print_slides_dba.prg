CREATE PROGRAM ap_batch_print_slides:dba
 PROMPT
  "Output Destination:" = "",
  "Barcode" = ""
  WITH outputdest, barcode
 FREE RECORD request
 RECORD request(
   1 output_dest_cd = f8
   1 qual[*]
     2 processing_task_id = f8
   1 resend_ind = i2
 )
 DECLARE billing_task_cd = f8 WITH protect, noconstant(0.0)
 DECLARE processing_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ordered_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ap_tag_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx1 = i4 WITH protect, noconstant(0)
 DECLARE idx2 = i4 WITH protect, noconstant(0)
 DECLARE idx3 = i4 WITH protect, noconstant(0)
 DECLARE rcnt = i4 WITH protect, noconstant(0)
 SET stat = uar_get_meaning_by_codeset(5801,"APBILLING",1,billing_task_cd)
 SET stat = uar_get_meaning_by_codeset(1305,"ORDERED",1,ordered_cd)
 SET stat = uar_get_meaning_by_codeset(1305,"PROCESSING",1,processing_cd)
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
 SELECT INTO "n1:"
  o.output_dest_cd, o.name, o.label_prefix,
  o.label_program_name, o.label_xpos, o.label_ypos,
  o.description
  FROM output_dest o
  WHERE (o.name= $OUTPUTDEST)
  DETAIL
   request->output_dest_cd = o.output_dest_cd
  WITH nocounter
 ;end select
#script
 DECLARE barcodetype = vc WITH persistscript, noconstant("")
 DECLARE codevalue = vc WITH persistscript, noconstant("")
 SET barcode_size = findstring(";", $BARCODE,5,1)
 SET barcodetype = substring(2,2,cnvtupper( $BARCODE))
 IF (barcode_size > 0
  AND barcode_size < textlen( $BARCODE))
  SET codevalue = substring(5,(barcode_size - 5), $BARCODE)
 ELSE
  SET codevalue = trim(substring(5,16, $BARCODE))
 ENDIF
 IF (barcodetype="CC")
  SELECT INTO "n1:"
   s.content_table_id, pt.processing_task_id, pt.cassette_id,
   pt.case_specimen_id, pt.case_specimen_tag_id, pt.cassette_id,
   pt.cassette_tag_id, pt.slide_id, pt.slide_tag_id,
   pt.status_cd, pt.request_prsnl_id, pt.task_assay_cd,
   ncreatespecimen = evaluate(pt.create_inventory_flag,4,1,0), ncreateblock = evaluate(pt
    .create_inventory_flag,1,1,2,0,
    3,1,4,0,0,
    0), ncreateslide = evaluate(pt.create_inventory_flag,1,0,2,1,
    3,1,4,0,0,
    0),
   ap_tag_spec_idx = locateval(idx1,1,ap_tag_cnt,pt.case_specimen_tag_id,temp_ap_tag->qual[idx1].
    tag_id), ap_tag_cass_idx = locateval(idx2,1,ap_tag_cnt,pt.cassette_tag_id,temp_ap_tag->qual[idx2]
    .tag_id), ap_tag_slide_idx = locateval(idx3,1,ap_tag_cnt,pt.slide_tag_id,temp_ap_tag->qual[idx3].
    tag_id),
   pt.request_dt_tm, s.tracking_location_cd
   FROM storage_content s,
    processing_task pt,
    profile_task_r ptr,
    order_catalog oc,
    ap_task_assay_addl ataa,
    pathology_case pc
   PLAN (s
    WHERE s.storage_item_cd=cnvtint(codevalue)
     AND s.content_table_id > 0
     AND s.content_table_name="CASSETTE")
    JOIN (pt
    WHERE pt.status_cd IN (ordered_cd, processing_cd)
     AND pt.cassette_id=s.content_table_id
     AND pt.slide_id > 0)
    JOIN (ptr
    WHERE ptr.task_assay_cd=pt.task_assay_cd
     AND ptr.active_ind=1
     AND ptr.item_type_flag=0
     AND ptr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
     AND ptr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (oc
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND oc.active_ind=1
     AND oc.activity_subtype_cd != billing_task_cd)
    JOIN (ataa
    WHERE pt.task_assay_cd=ataa.task_assay_cd
     AND ataa.print_label_ind=1)
    JOIN (pc
    WHERE pc.case_id=pt.case_id)
   ORDER BY pc.accession_nbr, ap_tag_spec_idx, ncreatespecimen DESC,
    ap_tag_cass_idx, pt.cassette_id, ncreateblock DESC,
    ap_tag_slide_idx, pt.slide_id, ncreateslide DESC,
    pt.request_dt_tm
   HEAD REPORT
    stat = alterlist(request->qual,5)
   DETAIL
    rcnt = (rcnt+ 1)
    IF (mod(rcnt,5)=1
     AND rcnt > 5)
     stat = alterlist(request->qual,(rcnt+ 4))
    ENDIF
    request->qual[rcnt].processing_task_id = pt.processing_task_id, request->resend_ind = 2
   FOOT REPORT
    stat = alterlist(request->qual,rcnt)
   WITH nocounter, separator = "", format
  ;end select
 ELSE
  IF (barcodetype="LC")
   SELECT INTO "n1:"
    s.content_table_id, pt.cassette_id, pt.case_specimen_id,
    pt.case_specimen_tag_id, pt.cassette_id, pt.cassette_tag_id,
    pt.slide_id, pt.slide_tag_id, pt.status_cd,
    pt.request_prsnl_id, pt.task_assay_cd, ncreatespecimen = evaluate(pt.create_inventory_flag,4,1,0),
    ncreateblock = evaluate(pt.create_inventory_flag,1,1,2,0,
     3,1,4,0,0,
     0), ncreateslide = evaluate(pt.create_inventory_flag,1,0,2,1,
     3,1,4,0,0,
     0), ap_tag_spec_idx = locateval(idx1,1,ap_tag_cnt,pt.case_specimen_tag_id,temp_ap_tag->qual[idx1
     ].tag_id),
    ap_tag_cass_idx = locateval(idx2,1,ap_tag_cnt,pt.cassette_tag_id,temp_ap_tag->qual[idx2].tag_id),
    ap_tag_slide_idx = locateval(idx3,1,ap_tag_cnt,pt.slide_tag_id,temp_ap_tag->qual[idx3].tag_id),
    pt.request_dt_tm,
    s.tracking_location_cd
    FROM storage_content s,
     processing_task pt,
     profile_task_r ptr,
     order_catalog oc,
     ap_task_assay_addl ataa,
     pathology_case pc
    PLAN (s
     WHERE s.tracking_location_cd=cnvtint(codevalue)
      AND s.content_table_id > 0
      AND s.content_table_name="CASSETTE")
     JOIN (pt
     WHERE pt.status_cd IN (ordered_cd, processing_cd)
      AND pt.cassette_id=s.content_table_id
      AND pt.slide_id > 0)
     JOIN (ptr
     WHERE ptr.task_assay_cd=pt.task_assay_cd
      AND ptr.active_ind=1
      AND ptr.item_type_flag=0
      AND ptr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND ptr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (oc
     WHERE ptr.catalog_cd=oc.catalog_cd
      AND oc.active_ind=1
      AND oc.activity_subtype_cd != billing_task_cd)
     JOIN (ataa
     WHERE pt.task_assay_cd=ataa.task_assay_cd
      AND ataa.print_label_ind=1)
     JOIN (pc
     WHERE pc.case_id=pt.case_id)
    ORDER BY pc.accession_nbr, ap_tag_spec_idx, ncreatespecimen DESC,
     ap_tag_cass_idx, pt.cassette_id, ncreateblock DESC,
     ap_tag_slide_idx, pt.slide_id, ncreateslide DESC,
     pt.request_dt_tm
    HEAD REPORT
     stat = alterlist(request->qual,5)
    DETAIL
     rcnt = (rcnt+ 1)
     IF (mod(rcnt,5)=1
      AND rcnt > 5)
      stat = alterlist(request->qual,(rcnt+ 4))
     ENDIF
     request->qual[rcnt].processing_task_id = pt.processing_task_id, request->resend_ind = 2
    FOOT REPORT
     stat = alterlist(request->qual,rcnt)
    WITH nocounter, separator = "", format
   ;end select
  ENDIF
 ENDIF
 IF ((request->output_dest_cd > 0)
  AND size(request->qual,5) > 0)
  EXECUTE aps_get_label_info_by_task
 ENDIF
END GO
