CREATE PROGRAM bed_get_os_sentence:dba
 FREE SET reply
 RECORD reply(
   1 sentences[*]
     2 sentence_id = f8
     2 display = vc
     2 order_set_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET list_cnt = 0
 SET orderable_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6030
    AND cv.cdf_meaning="ORDERABLE"
    AND cv.active_ind=1)
  DETAIL
   orderable_code_value = cv.code_value
  WITH nocounter
 ;end select
 IF ((request->order_set_code_value > 0))
  SELECT INTO "nl:"
   FROM cs_component cs,
    order_catalog_synonym ocs,
    order_sentence os,
    order_sentence_filter f
   PLAN (cs
    WHERE (cs.catalog_cd=request->order_set_code_value)
     AND cs.comp_type_cd=orderable_code_value
     AND (cs.comp_id=request->synonym_id)
     AND cs.order_sentence_id > 0)
    JOIN (ocs
    WHERE ocs.synonym_id=cs.comp_id)
    JOIN (os
    WHERE os.order_sentence_id=cs.order_sentence_id
     AND ((os.oe_format_id+ 0)=ocs.oe_format_id)
     AND ((os.oe_format_id+ 0) > 0))
    JOIN (f
    WHERE f.order_sentence_id=outerjoin(os.order_sentence_id))
   ORDER BY os.order_sentence_display_line
   HEAD REPORT
    cnt = 0, list_cnt = 0, stat = alterlist(reply->sentences,100)
   HEAD os.order_sentence_display_line
    IF (f.order_sentence_id=0)
     cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
     IF (list_cnt > 100)
      stat = alterlist(reply->sentences,(cnt+ 100)), list_cnt = 1
     ENDIF
     reply->sentences[cnt].sentence_id = os.order_sentence_id, reply->sentences[cnt].display = os
     .order_sentence_display_line, reply->sentences[cnt].order_set_ind = 1
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->sentences,cnt)
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM ord_cat_sent_r ocr,
   order_sentence os,
   order_sentence_filter f
  PLAN (ocr
   WHERE (ocr.synonym_id=request->synonym_id)
    AND ocr.active_ind=1)
   JOIN (os
   WHERE os.order_sentence_id=ocr.order_sentence_id)
   JOIN (f
   WHERE f.order_sentence_id=outerjoin(os.order_sentence_id))
  ORDER BY ocr.order_sentence_disp_line
  HEAD REPORT
   cnt = size(reply->sentences,5), list_cnt = 0, stat = alterlist(reply->sentences,(cnt+ 100))
  HEAD ocr.order_sentence_disp_line
   IF (f.order_sentence_id=0)
    cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
    IF (list_cnt > 100)
     stat = alterlist(reply->sentences,(cnt+ 100)), list_cnt = 1
    ENDIF
    reply->sentences[cnt].sentence_id = ocr.order_sentence_id, reply->sentences[cnt].display = ocr
    .order_sentence_disp_line, reply->sentences[cnt].order_set_ind = 0
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->sentences,cnt)
  WITH nocounter
 ;end select
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
