CREATE PROGRAM bed_rec_rx_mnem_miss_rxmask
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET reply->run_status_flag = 1
 SET cdesc = 0.0
 SET crxm = 0.0
 SET corder = 0.0
 SET csystem = 0.0
 SET cinpatient = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=11000
    AND cv.cdf_meaning="DESC"
    AND cv.active_ind=1)
  DETAIL
   cdesc = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6011
    AND cv.cdf_meaning="RXMNEMONIC"
    AND cv.active_ind=1)
  DETAIL
   crxm = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6003
    AND cv.cdf_meaning="ORDER"
    AND cv.active_ind=1)
  DETAIL
   corder = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=4062
    AND cv.cdf_meaning="SYSTEM"
    AND cv.active_ind=1)
  DETAIL
   csystem = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=4500
    AND cv.cdf_meaning="INPATIENT"
    AND cv.active_ind=1)
  DETAIL
   cinpatient = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog_item_r ocir,
   order_catalog oc,
   item_definition id,
   med_identifier mi,
   order_catalog_synonym ocs,
   med_def_flex mdf
  PLAN (ocir)
   JOIN (oc
   WHERE oc.catalog_cd=ocir.catalog_cd
    AND oc.active_ind=1)
   JOIN (id
   WHERE id.item_id=ocir.item_id
    AND id.active_ind=1)
   JOIN (mdf
   WHERE mdf.item_id=ocir.item_id
    AND mdf.flex_type_cd=csystem
    AND mdf.pharmacy_type_cd=cinpatient)
   JOIN (mi
   WHERE mi.item_id=id.item_id
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=cdesc
    AND mi.active_ind=1
    AND mi.primary_ind=1
    AND mi.pharmacy_type_cd=cinpatient)
   JOIN (ocs
   WHERE ocs.item_id=ocir.item_id
    AND ocs.mnemonic_type_cd=crxm
    AND ocs.active_ind=1)
  DETAIL
   IF (ocs.rx_mask=0)
    reply->run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf
      AND c.active_ind=1)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
