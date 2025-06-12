CREATE PROGRAM bed_get_dmart_map_types:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 items[*]
      2 br_datamart_mapping_type_id = f8
      2 datamart_category_id = f8
      2 datamart_filter_category_id = f8
      2 data_type_value = f8
      2 map_data_type_display = vc
      2 sequence = i4
      2 mapping_item_type_cd = f8
      2 mapping_item_type_meaning = vc
      2 mapping_item_type_display = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 DECLARE replycount = i4 WITH noconstant(0), protect
 DECLARE datamart_filter_category_id = f8 WITH noconstant(0.0), protect
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 SELECT INTO "nl:"
  FROM br_datamart_filter_category dmart_filter
  WHERE (dmart_filter.filter_category_mean=request->filter_category_mean)
  DETAIL
   datamart_filter_category_id = dmart_filter.br_datamart_filter_category_id
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "SEL br_datamart_filter_category table"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 IF (datamart_filter_category_id=0.0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Couldn't find data from the request"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM br_datam_mapping_type dmart_map,
   code_value cv
  PLAN (dmart_map
   WHERE (dmart_map.br_datamart_category_id=request->datamart_category_id)
    AND dmart_map.br_datamart_filter_category_id=datamart_filter_category_id)
   JOIN (cv
   WHERE cv.code_value=dmart_map.map_data_type_cd)
  DETAIL
   replycount = (replycount+ 1), stat = alterlist(reply->items,replycount), reply->items[replycount].
   br_datamart_mapping_type_id = dmart_map.br_datam_mapping_type_id,
   reply->items[replycount].datamart_category_id = dmart_map.br_datamart_category_id, reply->items[
   replycount].datamart_filter_category_id = dmart_map.br_datamart_filter_category_id, reply->items[
   replycount].data_type_value = dmart_map.map_data_type_value,
   reply->items[replycount].map_data_type_display = dmart_map.map_data_type_display, reply->items[
   replycount].sequence = dmart_map.display_seq, reply->items[replycount].mapping_item_type_cd =
   dmart_map.map_data_type_cd,
   reply->items[replycount].mapping_item_type_meaning = cv.cdf_meaning, reply->items[replycount].
   mapping_item_type_display = cv.display
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "SEL br_datamart_mapping_type table"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
