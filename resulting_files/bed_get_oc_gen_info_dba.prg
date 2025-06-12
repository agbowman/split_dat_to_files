CREATE PROGRAM bed_get_oc_gen_info:dba
 FREE SET reply
 RECORD reply(
   1 olist[*]
     2 catalog_cd = f8
     2 description = c100
     2 primary_mnemonic = c100
     2 dept_name = c100
     2 catalog_type_cd = f8
     2 catalog_type_display = c40
     2 catalog_type_cdf_meaning = c12
     2 activity_type_cd = f8
     2 activity_type_display = c40
     2 activity_type_cdf_meaning = c12
     2 activity_subtype_cd = f8
     2 activity_subtype_display = c40
     2 activity_subtype_cdf_meaning = c12
     2 active_ind = i2
     2 procedure_type
       3 code_value = f8
       3 display = vc
       3 mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET oc_cnt = 0
 SET oc_cnt = size(request->oclist,5)
 IF (oc_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->olist,oc_cnt)
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = oc_cnt),
   order_catalog oc,
   service_directory sd,
   code_value cv1,
   code_value cv2,
   code_value cv3
  PLAN (d)
   JOIN (oc
   WHERE (oc.catalog_cd=request->oclist[d.seq].catalog_cd))
   JOIN (cv1
   WHERE cv1.code_value=outerjoin(oc.catalog_type_cd))
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(oc.activity_type_cd))
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(oc.activity_subtype_cd))
   JOIN (sd
   WHERE sd.catalog_cd=outerjoin(oc.catalog_cd))
  DETAIL
   reply->olist[d.seq].catalog_cd = request->oclist[d.seq].catalog_cd, reply->olist[d.seq].
   description = oc.description, reply->olist[d.seq].primary_mnemonic = oc.primary_mnemonic
   IF (sd.catalog_cd > 0)
    reply->olist[d.seq].dept_name = sd.short_description, reply->olist[d.seq].procedure_type.
    code_value = sd.bb_processing_cd
   ELSE
    reply->olist[d.seq].dept_name = oc.dept_display_name
   ENDIF
   reply->olist[d.seq].catalog_type_cd = oc.catalog_type_cd, reply->olist[d.seq].catalog_type_display
    = cv1.display, reply->olist[d.seq].catalog_type_cdf_meaning = cv1.cdf_meaning,
   reply->olist[d.seq].activity_type_cd = oc.activity_type_cd, reply->olist[d.seq].
   activity_type_display = cv2.display, reply->olist[d.seq].activity_type_cdf_meaning = cv2
   .cdf_meaning,
   reply->olist[d.seq].activity_subtype_cd = oc.activity_subtype_cd, reply->olist[d.seq].
   activity_subtype_display = cv3.display, reply->olist[d.seq].activity_subtype_cdf_meaning = cv3
   .cdf_meaning,
   reply->olist[d.seq].active_ind = oc.active_ind
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = oc_cnt),
   code_value cv
  PLAN (d
   WHERE (reply->olist[d.seq].procedure_type.code_value > 0))
   JOIN (cv
   WHERE (cv.code_value=reply->olist[d.seq].procedure_type.code_value))
  DETAIL
   reply->olist[d.seq].procedure_type.display = cv.display, reply->olist[d.seq].procedure_type.mean
    = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
#exit_script
END GO
