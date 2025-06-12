CREATE PROGRAM bed_get_rel_oc_list:dba
 FREE SET reply
 RECORD reply(
   1 oc_list[*]
     2 catalog_code_value = f8
     2 primary_name = vc
     2 description = vc
     2 fac_list[*]
       3 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET temp_oc
 RECORD temp_oc(
   1 oc_list[*]
     2 catalog_code_value = f8
     2 primary_name = vc
     2 description = vc
     2 concept_cki = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SET listcount = 0
 SET auto_client_id = 0.0
 SET tot_start_count = 0
 SET i = 0
 SET stat = alterlist(temp_oc->oc_list,100)
 DECLARE oc_parse = vc
 SET oc_parse = build(" (o.active_ind = 1 and o.primary_mnemonic != 'zz*' and ",
  " o.orderable_type_flag != 6 and o.orderable_type_flag != 2 and "," o.catalog_type_cd = ",request->
  filters.catalog_type_code_value)
 IF ((request->filters.activity_type_code_value > 0))
  SET oc_parse = build(oc_parse," and o.activity_type_cd = ",request->filters.
   activity_type_code_value)
 ENDIF
 SET oc_parse = concat(oc_parse,")")
 SELECT INTO "NL:"
  FROM order_catalog o
  PLAN (o
   WHERE parser(oc_parse))
  ORDER BY o.catalog_cd
  DETAIL
   count = (count+ 1), listcount = (listcount+ 1)
   IF (listcount > 100)
    stat = alterlist(temp_oc->oc_list,(count+ 100)), listcount = 1
   ENDIF
   temp_oc->oc_list[count].catalog_code_value = o.catalog_cd, temp_oc->oc_list[count].primary_name =
   o.primary_mnemonic, temp_oc->oc_list[count].description = o.description,
   temp_oc->oc_list[count].concept_cki = o.concept_cki
  WITH nocounter
 ;end select
 SET tot_oc_count = count
 SET surg_cat_ind = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE (cv.code_value=request->filters.catalog_type_code_value)
  DETAIL
   IF (cv.cdf_meaning="SURGERY")
    surg_cat_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 DECLARE oc_parse = vc
 SET oc_parse = build(" o.catalog_type_cd = ",request->filters.catalog_type_code_value)
 IF (surg_cat_ind=1)
  SET oc_parse = concat(oc_parse," and o.surgery_ind = 1")
 ELSE
  IF ((request->filters.activity_type_code_value > 0))
   SET oc_parse = build(oc_parse," and o.activity_type_cd = ",request->filters.
    activity_type_code_value)
  ENDIF
 ENDIF
 SET tot_start_count = count
 SELECT INTO "NL:"
  FROM br_auto_order_catalog o
  PLAN (o
   WHERE parser(oc_parse))
  ORDER BY o.primary_mnemonic
  DETAIL
   found = 0
   FOR (i = 1 TO tot_start_count)
     IF ((((o.concept_cki=temp_oc->oc_list[i].concept_cki)) OR (cnvtupper(o.primary_mnemonic)=
     cnvtupper(temp_oc->oc_list[i].primary_name))) )
      found = 1, i = (tot_start_count+ 1)
     ENDIF
   ENDFOR
   IF (found=0)
    count = (count+ 1), listcount = (listcount+ 1)
    IF (listcount > 100)
     stat = alterlist(temp_oc->oc_list,(count+ 100)), listcount = 1
    ENDIF
    temp_oc->oc_list[count].catalog_code_value = o.catalog_cd, temp_oc->oc_list[count].primary_name
     = o.primary_mnemonic, temp_oc->oc_list[count].description = o.description,
    temp_oc->oc_list[count].concept_cki = o.concept_cki
   ENDIF
  WITH skipbedrock = 1, nocounter
 ;end select
 SET stat = alterlist(temp_oc->oc_list,count)
 SET stat = alterlist(reply->oc_list,count)
 IF (count > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = count)
   DETAIL
    reply->oc_list[d.seq].catalog_code_value = temp_oc->oc_list[d.seq].catalog_code_value, reply->
    oc_list[d.seq].primary_name = temp_oc->oc_list[d.seq].primary_name, reply->oc_list[d.seq].
    description = temp_oc->oc_list[d.seq].description
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM br_oc_work b,
    (dummyt d  WITH seq = count)
   PLAN (d)
    JOIN (b
    WHERE (b.match_orderable_cd=reply->oc_list[d.seq].catalog_code_value))
   ORDER BY d.seq
   HEAD d.seq
    fcnt = 0, listfcnt = 0, stat = alterlist(reply->oc_list[d.seq].fac_list,5)
   DETAIL
    fcnt = (fcnt+ 1), listfcnt = (listfcnt+ 1)
    IF (listfcnt > 5)
     stat = alterlist(reply->oc_list[d.seq].fac_list,(fcnt+ 5)), listfcnt = 1
    ENDIF
    reply->oc_list[d.seq].fac_list[fcnt].name = b.facility
   FOOT  d.seq
    stat = alterlist(reply->oc_list[d.seq].fac_list,fcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (count=0)
  SET reply->status_data.status = "Z"
 ELSEIF (count > 0)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
