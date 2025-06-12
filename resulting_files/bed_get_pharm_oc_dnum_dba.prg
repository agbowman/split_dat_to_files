CREATE PROGRAM bed_get_pharm_oc_dnum:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 orderables[*]
      2 code_value = f8
      2 display = vc
      2 description = vc
      2 ignore_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE medications_cd = f8
 DECLARE ivsolutions_cd = f8
 DECLARE pharmacy_cd = f8
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET list_count = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.cdf_meaning="PHARMACY"
   AND cv.active_ind=1
  DETAIL
   pharmacy_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog oc
  WHERE oc.catalog_type_cd=pharmacy_cd
   AND ((oc.orderable_type_flag=1) OR (oc.orderable_type_flag=0))
   AND ((oc.cki=" ") OR (((oc.cki=null) OR (oc.cki="")) ))
   AND oc.active_ind=1
   AND oc.catalog_cd > 0
  HEAD REPORT
   cnt = 0, list_count = 0, stat = alterlist(reply->orderables,200)
  DETAIL
   list_count = (list_count+ 1), cnt = (cnt+ 1)
   IF (list_count > 200)
    stat = alterlist(reply->orderables,(cnt+ 200)), list_count = 1
   ENDIF
   reply->orderables[cnt].code_value = oc.catalog_cd, reply->orderables[cnt].display = oc
   .primary_mnemonic, reply->orderables[cnt].description = oc.description,
   reply->orderables[cnt].ignore_ind = 0
  FOOT REPORT
   stat = alterlist(reply->orderables,cnt)
  WITH nocounter
 ;end select
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    br_name_value b
   PLAN (d)
    JOIN (b
    WHERE b.br_nv_key1="MLTM_IGN_DNUM"
     AND (cnvtreal(trim(b.br_value))=reply->orderables[d.seq].code_value)
     AND b.br_name="ORDER_CATALOG")
   DETAIL
    reply->orderables[d.seq].ignore_ind = 1
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
