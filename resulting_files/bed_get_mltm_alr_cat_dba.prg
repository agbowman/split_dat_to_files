CREATE PROGRAM bed_get_mltm_alr_cat:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 allergies[*]
      2 alr_category_id = f8
      2 alr_category_description = vc
      2 alr_description_plural = vc
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 too_many_results_ind = i2
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE cnt = i2
 DECLARE max_rep = i2
 DECLARE wcard = vc
 DECLARE parse_txt = vc
 DECLARE search_string = vc
 SET cnt = 0
 SET max_rep = 4000
 SET wcard = "*"
 IF (trim(request->description) > " ")
  IF ((request->search_type_flag="S"))
   SET search_string = concat(trim(cnvtupper(request->description)),wcard)
  ELSE
   SET search_string = concat(wcard,trim(cnvtupper(request->description)),wcard)
  ENDIF
  SET parse_txt = concat("cnvtupper(mac.category_description) = '",search_string,"'")
 ELSE
  SET search_string = wcard
  SET parse_txt = concat("trim(cnvtupper(mac.category_description)) = '",search_string,"'")
 ENDIF
 SELECT INTO "nl:"
  FROM mltm_alr_category mac
  WHERE parser(parse_txt)
   AND  NOT (mac.alr_category_id IN (
  (SELECT
   br.parent_entity_id
   FROM br_datamart_value br
   WHERE br.parent_entity_name="MLTM_ALR_CATEGORY"
    AND br.br_datamart_flex_id=0.0)))
  ORDER BY mac.category_description
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->allergies,cnt), reply->allergies[cnt].alr_category_id =
   mac.alr_category_id,
   reply->allergies[cnt].alr_category_description = mac.category_description, reply->allergies[cnt].
   alr_description_plural = mac.category_description_plural
  WITH nocounter
 ;end select
 IF (cnt > max_rep
  AND max_rep > 0)
  SET stat = alterlist(reply->allergies,0)
  SET reply->too_many_results_ind = 1
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
