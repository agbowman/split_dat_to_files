CREATE PROGRAM bed_get_oc_list:dba
 FREE SET reply
 RECORD reply(
   1 oc_list[*]
     2 catalog_code_value = f8
     2 primary_name = c100
     2 assay_list[*]
       3 code_value = f8
       3 display = c40
       3 required = i2
       3 description = vc
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE search_string = vc
 SET count = 0
 SET listcount = 0
 SET tot_count = 0
 IF ((request->filters.service_resource_code_value=0))
  SET search_string = "*"
  IF ((request->filters.search_type_flag="S"))
   SET search_string = concat('"',trim(request->filters.search_string),'*"')
  ELSE
   SET search_string = concat('"*',trim(request->filters.search_string),'*"')
  ENDIF
  SET search_string = cnvtupper(search_string)
  DECLARE oc_parse = vc
  SET oc_parse = build("o.active_ind = 1 and o.primary_mnemonic != 'zz*' and ",
   " o.orderable_type_flag != 6 and o.orderable_type_flag != 2 and "," o.catalog_type_cd = ",request
   ->filters.catalog_type_code_value)
  IF ((request->filters.activity_type_code_value > 0))
   SET oc_parse = build(oc_parse," and o.activity_type_cd = ",request->filters.
    activity_type_code_value)
  ENDIF
  IF ((request->filters.subactivity_type_code_value > 0))
   SET oc_parse = build(oc_parse," and o.activity_subtype_cd = ",request->filters.
    subactivity_type_code_value)
  ENDIF
  IF (search_string > "    ")
   SET oc_parse = concat(oc_parse," and cnvtupper(o.primary_mnemonic) = ",search_string)
  ENDIF
  IF ((request->filters.exclude_bill_only_ind > 0))
   SET oc_parse = concat(oc_parse," and (o.bill_only_ind = 0 or o.bill_only_ind = NULL) ")
  ENDIF
  CALL echo(oc_parse)
  SELECT INTO "NL:"
   FROM order_catalog o,
    profile_task_r ptr,
    code_value cv
   PLAN (o
    WHERE parser(oc_parse))
    JOIN (ptr
    WHERE ptr.catalog_cd=outerjoin(o.catalog_cd))
    JOIN (cv
    WHERE outerjoin(ptr.task_assay_cd)=cv.code_value
     AND cv.active_ind=outerjoin(1))
   ORDER BY o.primary_mnemonic
   HEAD REPORT
    stat = alterlist(reply->oc_list,50), count = 0, listcount = 0
   HEAD o.catalog_cd
    tot_count = 0, dta_count = 0, count = (count+ 1),
    listcount = (listcount+ 1)
    IF (listcount > 50)
     stat = alterlist(reply->oc_list,(count+ 50)), listcount = 1
    ENDIF
    reply->oc_list[count].catalog_code_value = o.catalog_cd, reply->oc_list[count].primary_name = o
    .primary_mnemonic, reply->oc_list[count].description = o.description,
    stat = alterlist(reply->oc_list[count].assay_list,5)
   HEAD cv.code_value
    IF ((request->load.assay_list_ind=1)
     AND cv.code_value > 0
     AND ptr.active_ind=1)
     tot_count = (tot_count+ 1), dta_count = (dta_count+ 1)
     IF (dta_count > 5)
      stat = alterlist(reply->oc_list[count].assay_list,(tot_count+ 5)), dta_count = 0
     ENDIF
     reply->oc_list[count].assay_list[tot_count].display = cv.display, reply->oc_list[count].
     assay_list[tot_count].code_value = cv.code_value, reply->oc_list[count].assay_list[tot_count].
     required = ptr.pending_ind,
     reply->oc_list[count].assay_list[tot_count].description = cv.description
    ENDIF
   DETAIL
    i = 0
   FOOT  o.catalog_cd
    stat = alterlist(reply->oc_list[count].assay_list,tot_count)
   FOOT REPORT
    stat = alterlist(reply->oc_list,count)
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->filters.service_resource_code_value > 0))
  SELECT INTO "NL:"
   o.catalog_cd, o.primary_mnemonic
   FROM orc_resource_list orl,
    order_catalog o,
    profile_task_r ptr,
    code_value cv
   PLAN (orl
    WHERE (orl.service_resource_cd=request->filters.service_resource_code_value)
     AND orl.catalog_cd > 0
     AND orl.active_ind=1)
    JOIN (o
    WHERE o.active_ind=1
     AND o.orderable_type_flag != 6
     AND o.orderable_type_flag != 2
     AND o.primary_mnemnic != "zz*"
     AND o.catalog_cd=orl.catalog_cd
     AND (o.catalog_type_cd=request->filters.catalog_type_code_value)
     AND (((o.activity_type_cd=request->filters.activity_type_code_value)) OR ((request->filters.
    activity_type_code_value=0)))
     AND (((o.activity_subtype_cd=request->filters.subactivity_type_code_value)) OR ((request->
    filters.subactivity_type_code_value=0))) )
    JOIN (ptr
    WHERE ptr.catalog_cd=outerjoin(o.catalog_cd))
    JOIN (cv
    WHERE outerjoin(ptr.task_assay_cd)=cv.code_value
     AND cv.active_ind=outerjoin(1))
   ORDER BY o.primary_mnemonic
   HEAD REPORT
    stat = alterlist(reply->oc_list,50), count = 0, listcount = 0
   HEAD o.catalog_cd
    tot_count = 0, dta_count = 0, count = (count+ 1),
    listcount = (listcount+ 1)
    IF (listcount > 50)
     stat = alterlist(reply->oc_list,(count+ 50)), listcount = 1
    ENDIF
    reply->oc_list[count].catalog_code_value = o.catalog_cd, reply->oc_list[count].primary_name = o
    .primary_mnemonic, reply->oc_list[count].description = o.description,
    stat = alterlist(reply->oc_list[count].assay_list,5)
   HEAD cv.code_value
    IF ((request->load.assay_list_ind=1)
     AND cv.code_value > 0
     AND ptr.active_ind=1)
     tot_count = (tot_count+ 1), dta_count = (dta_count+ 1)
     IF (dta_count > 5)
      stat = alterlist(reply->oc_list[count].assay_list,(tot_count+ 5)), dta_count = 0
     ENDIF
     reply->oc_list[count].assay_list[tot_count].display = cv.display, reply->oc_list[count].
     assay_list[tot_count].code_value = cv.code_value, reply->oc_list[count].assay_list[tot_count].
     required = ptr.pending_ind,
     reply->oc_list[count].assay_list[tot_count].description = cv.description
    ENDIF
   DETAIL
    i = 0
   FOOT  o.catalog_cd
    stat = alterlist(reply->oc_list[count].assay_list,tot_count)
   FOOT REPORT
    stat = alterlist(reply->oc_list,count)
   WITH nocounter
  ;end select
 ENDIF
 IF (count=0)
  SET reply->status_data.status = "Z"
 ENDIF
 IF (count > 0)
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO
