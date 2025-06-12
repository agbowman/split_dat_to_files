CREATE PROGRAM bed_get_bb_cat_active_prod:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 active_products_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE disposed_cd = f8 WITH protect, noconstant(0.0)
 DECLARE transfused_cd = f8 WITH protect, noconstant(0.0)
 DECLARE destroyed_cd = f8 WITH protect, noconstant(0.0)
 DECLARE shipped_cd = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=1610
   AND cv.cdf_meaning IN ("5", "7", "14", "15")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="5")
    disposed_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="7")
    transfused_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="14")
    destroyed_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="15")
    shipped_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET category_cd = 0.0
 SELECT INTO "nl:"
  FROM br_bb_prodcat b
  WHERE (b.prodcat_id=request->category_id)
   AND b.active_ind=1
  DETAIL
   category_cd = b.prodcat_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM product p,
   product_event pe
  PLAN (p
   WHERE p.product_cat_cd=category_cd
    AND p.active_ind=1)
   JOIN (pe
   WHERE pe.product_id=p.product_id
    AND pe.event_type_cd != disposed_cd
    AND pe.event_type_cd != transfused_cd
    AND pe.event_type_cd != destroyed_cd
    AND pe.event_type_cd != shipped_cd
    AND pe.active_ind=1)
  DETAIL
   reply->active_products_ind = 1
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
