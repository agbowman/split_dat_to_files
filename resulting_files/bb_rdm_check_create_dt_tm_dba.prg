CREATE PROGRAM bb_rdm_check_create_dt_tm:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 RECORD product_dates(
   1 products[*]
     2 product_id = f8
     2 create_dt_tm = dq8
 )
 DECLARE modified_type_cd = f8
 DECLARE pooled_type_cd = f8
 SET modified_type_cd = 0.0
 SET pooled_type_cd = 0.0
 SET readme_data->status = "F"
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=1610
    AND cv.cdf_meaning IN ("24", "18")
    AND cv.active_ind=1)
  DETAIL
   IF (cv.cdf_meaning="24")
    modified_type_cd = cv.code_value
   ELSE
    pooled_type_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (modified_type_cd > 0
  AND pooled_type_cd > 0)
  SELECT INTO "nl:"
   pe.event_dt_tm, pe.product_id
   FROM product_event pe,
    product pr
   PLAN (pe
    WHERE pe.event_type_cd IN (modified_type_cd, pooled_type_cd))
    JOIN (pr
    WHERE pe.product_id=pr.product_id
     AND pr.create_dt_tm = null)
   HEAD REPORT
    product_count = 0, stat = alterlist(product_dates->products,10)
   DETAIL
    product_count = (product_count+ 1)
    IF (size(product_dates->products,5) < product_count)
     stat = alterlist(product_dates->products,(product_count+ 9))
    ENDIF
    product_dates->products[product_count].product_id = pe.product_id, product_dates->products[
    product_count].create_dt_tm = pe.event_dt_tm
   FOOT REPORT
    stat = alterlist(product_dates->products,product_count)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SELECT INTO "nl:"
    pr.product_id
    FROM product pr,
     (dummyt d  WITH seq = value(size(product_dates->products,5)))
    PLAN (d)
     JOIN (pr
     WHERE (pr.product_id=product_dates->products[d.seq].product_id))
    WITH nocounter, forupdate(pr)
   ;end select
   UPDATE  FROM product pr,
     (dummyt d  WITH seq = value(size(product_dates->products,5)))
    SET pr.create_dt_tm = cnvtdatetime(product_dates->products[d.seq].create_dt_tm)
    PLAN (d)
     JOIN (pr
     WHERE (pr.product_id=product_dates->products[d.seq].product_id))
    WITH nocounter
   ;end update
   IF (curqual > 0)
    SET readme_data->status = "S"
    SET readme_data->message = "Product table successfully updated."
    COMMIT
   ELSE
    SET readme_data->status = "F"
    SET readme_data->message = "Update into Product table failed."
    ROLLBACK
   ENDIF
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message = "No products found.  Readme Successful."
   COMMIT
  ENDIF
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message =
  "Modified Product and Pooled code_values are not present on code_set 1610."
  ROLLBACK
 ENDIF
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
 ENDIF
END GO
