CREATE PROGRAM dcp_upd_ord_com_template_id:dba
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
 RECORD internal(
   1 qual[*]
     2 catalog_cd = f8
     2 long_text_id = f8
 )
 SET count1 = 0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET text_type_cd = 0.0
 SET code_set = 6009
 SET cdf_meaning = "ORD COM TEMP"
 EXECUTE cpm_get_cd_for_cdf
 SET text_type_cd = code_value
 IF (text_type_cd=0.0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  oct.catalog_cd
  FROM order_catalog_text oct
  WHERE oct.text_type_cd=text_type_cd
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(internal->qual,5))
    stat = alterlist(internal->qual,(count1+ 10))
   ENDIF
   internal->qual[count1].catalog_cd = oct.catalog_cd, internal->qual[count1].long_text_id = oct
   .long_text_id
  FOOT REPORT
   stat = alterlist(internal->qual,count1)
  WITH check
 ;end select
 UPDATE  FROM order_catalog oc,
   (dummyt d  WITH seq = value(count1))
  SET oc.ord_com_template_long_text_id = internal->qual[d.seq].long_text_id
  PLAN (d)
   JOIN (oc
   WHERE (oc.catalog_cd=internal->qual[d.seq].catalog_cd))
  WITH nocounter
 ;end update
 COMMIT
#exit_script
 SET readme_data->status = "S"
 IF (curqual > 0)
  SET readme_data->message = "ReadMe 1117: Update successfull."
 ELSE
  SET readme_data->message = "ReadMe 1117: No update needed."
 ENDIF
 EXECUTE dm_readme_status
END GO
