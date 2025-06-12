CREATE PROGRAM bed_get_cat_type_for_ord:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 catalog_types[*]
      2 code_value = f8
      2 display = c40
      2 description = c60
      2 mean = c12
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET ocnt = 0
 SET ocnt = size(request->orderables,5)
 IF (ocnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->catalog_types,ocnt)
 DECLARE replycnt = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 IF ((request->synonym_item_ind=1))
  SELECT INTO "NL:"
   FROM order_catalog_synonym ocs,
    code_value cv
   PLAN (ocs
    WHERE expand(num,1,size(request->orderables,5),ocs.synonym_id,request->orderables[num].code_value
     ))
    JOIN (cv
    WHERE cv.code_value=ocs.catalog_type_cd)
   DETAIL
    replycnt = (replycnt+ 1), stat = alterlist(reply->catalog_types,replycnt), reply->catalog_types[
    replycnt].code_value = cv.code_value,
    reply->catalog_types[replycnt].display = cv.display, reply->catalog_types[replycnt].description
     = cv.description, reply->catalog_types[replycnt].mean = cv.cdf_meaning
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "NL:"
   FROM order_catalog oc,
    code_value cv
   PLAN (oc
    WHERE expand(num,1,size(request->orderables,5),oc.catalog_cd,request->orderables[num].code_value)
    )
    JOIN (cv
    WHERE cv.code_value=oc.catalog_type_cd)
   DETAIL
    replycnt = (replycnt+ 1), stat = alterlist(reply->catalog_types,replycnt), reply->catalog_types[
    replycnt].code_value = cv.code_value,
    reply->catalog_types[replycnt].display = cv.display, reply->catalog_types[replycnt].description
     = cv.description, reply->catalog_types[replycnt].mean = cv.cdf_meaning
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
