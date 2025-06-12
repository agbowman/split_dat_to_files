CREATE PROGRAM cdi_get_doctype_config:dba
 RECORD reply(
   1 document_type_list[*]
     2 event_cd = f8
     2 cdi_document_type_id = f8
     2 combine_ind = i2
     2 combine_all_ind = i2
     2 max_page_cnt = i4
     2 updt_cnt = i4
     2 default_date_of_service_flag = i2
     2 subtype_list[*]
       3 cdi_document_subtype_id = f8
       3 alias = vc
       3 subject = vc
       3 combine_ind = i2
       3 combine_all_ind = i2
       3 max_page_cnt = i4
       3 updt_cnt = i4
       3 default_date_of_service_flag = i2
       3 contributor_source_cd = f8
     2 code_set = i4
     2 category_cd = f8
     2 send_to_manual_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 DECLARE qual_cnt = i4 WITH noconstant(value(size(request->doctype_list,5))), protect
 DECLARE n = i4 WITH noconstant(0), protect
 SET i = 0
 SET dt_cnt = 0
 SET st_cnt = 0
 SET reply->status_data.status = "F"
 CALL echo("qual_cnt:")
 CALL echo(qual_cnt)
 SELECT INTO "nl:"
  dt.cdi_document_type_id, dt.event_cd, dt.code_set,
  dt.combine_ind, dt.combine_all_ind, dt.max_page_cnt,
  dt.updt_cnt, dt.default_date_of_service_flag, dt.category_cd,
  dt.send_to_manual_ind, st.cdi_document_subtype_id, st.document_type_alias,
  st.subject, st.combine_ind, st.combine_all_ind,
  st.max_page_cnt, st.updt_cnt, st.default_date_of_service_flag,
  st.contributor_source_cd
  FROM cdi_document_type dt,
   cdi_document_subtype st
  WHERE dt.event_cd > 0
   AND dt.cdi_ac_batchclass_id=0
   AND ((qual_cnt < 1) OR (expand(n,1,qual_cnt,dt.event_cd,request->doctype_list[n].event_cd)))
   AND outerjoin(dt.cdi_document_type_id)=st.cdi_document_type_id
  ORDER BY dt.cdi_document_type_id, st.cdi_document_subtype_id
  HEAD REPORT
   dt_cnt = 0, stat = alterlist(reply->document_type_list,10)
  HEAD dt.cdi_document_type_id
   dt_cnt = (dt_cnt+ 1)
   IF (mod(dt_cnt,10)=1
    AND dt_cnt != 1)
    stat = alterlist(reply->document_type_list,(dt_cnt+ 9))
   ENDIF
   reply->document_type_list[dt_cnt].event_cd = dt.event_cd, reply->document_type_list[dt_cnt].
   code_set = dt.code_set, reply->document_type_list[dt_cnt].cdi_document_type_id = dt
   .cdi_document_type_id,
   reply->document_type_list[dt_cnt].combine_ind = dt.combine_ind, reply->document_type_list[dt_cnt].
   combine_all_ind = dt.combine_all_ind, reply->document_type_list[dt_cnt].max_page_cnt = dt
   .max_page_cnt,
   reply->document_type_list[dt_cnt].updt_cnt = dt.updt_cnt, reply->document_type_list[dt_cnt].
   default_date_of_service_flag = dt.default_date_of_service_flag, reply->document_type_list[dt_cnt].
   category_cd = dt.category_cd,
   reply->document_type_list[dt_cnt].send_to_manual_ind = dt.send_to_manual_ind, st_cnt = 0, stat =
   alterlist(reply->document_type_list[dt_cnt].subtype_list,10)
  DETAIL
   IF (st.cdi_document_subtype_id > 0)
    st_cnt = (st_cnt+ 1)
    IF (mod(st_cnt,10)=1
     AND st_cnt != 1)
     stat = alterlist(reply->document_type_list[dt_cnt].subtype_list,(st_cnt+ 9))
    ENDIF
    reply->document_type_list[dt_cnt].subtype_list[st_cnt].cdi_document_subtype_id = st
    .cdi_document_subtype_id, reply->document_type_list[dt_cnt].subtype_list[st_cnt].alias = st
    .document_type_alias, reply->document_type_list[dt_cnt].subtype_list[st_cnt].subject = st.subject,
    reply->document_type_list[dt_cnt].subtype_list[st_cnt].combine_ind = st.combine_ind, reply->
    document_type_list[dt_cnt].subtype_list[st_cnt].combine_all_ind = st.combine_all_ind, reply->
    document_type_list[dt_cnt].subtype_list[st_cnt].max_page_cnt = st.max_page_cnt,
    reply->document_type_list[dt_cnt].subtype_list[st_cnt].updt_cnt = st.updt_cnt, reply->
    document_type_list[dt_cnt].subtype_list[st_cnt].default_date_of_service_flag = st
    .default_date_of_service_flag, reply->document_type_list[dt_cnt].subtype_list[st_cnt].
    contributor_source_cd = st.contributor_source_cd
   ENDIF
  FOOT  dt.cdi_document_type_id
   stat = alterlist(reply->document_type_list[dt_cnt].subtype_list,st_cnt)
  FOOT REPORT
   stat = alterlist(reply->document_type_list,dt_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
