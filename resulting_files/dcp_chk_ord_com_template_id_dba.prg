CREATE PROGRAM dcp_chk_ord_com_template_id:dba
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
 SET success_ind = 0
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
 ;end update
 SET success_ind = 0
 SELECT INTO "nl:"
  oc.catalog_cd
  FROM order_catalog oc,
   (dummyt d  WITH seq = value(count1))
  PLAN (d)
   JOIN (oc
   WHERE (oc.catalog_cd=internal->qual[d.seq].catalog_cd))
  HEAD REPORT
   count1 = 1
  DETAIL
   count1 = (count1+ 1)
   IF ((oc.ord_com_template_long_text_id != internal->qual[count1].long_text_id))
    success_ind = 1
   ENDIF
  FOOT REPORT
   stat = alterlist(internal->qual,count1)
  WITH check
 ;end select
 SET request->setup_proc[1].process_id = 799
 IF (success_ind=1)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = "Update of ord_com_long_text_id FAILED"
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = "Update of ord_com_long_text_id SUCCEEDED"
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
