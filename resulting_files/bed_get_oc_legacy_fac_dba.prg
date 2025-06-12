CREATE PROGRAM bed_get_oc_legacy_fac:dba
 FREE SET reply
 RECORD reply(
   1 fac_list[*]
     2 fac_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "Z"
 SET count = 0
 SET listcount = 0
 SET catalog_display = fillstring(42," ")
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6000
   AND cv.active_ind=1
   AND (cv.code_value=request->filters.catalog_type_code_value)
  DETAIL
   catalog_display = concat("'",trim(cnvtupper(cv.display)),"'")
  WITH nocounter
 ;end select
 SET activity_display = fillstring(42," ")
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.active_ind=1
   AND (cv.code_value=request->filters.activity_type_code_value)
  DETAIL
   activity_display = concat("'",trim(cnvtupper(cv.display)),"'")
  WITH nocounter
 ;end select
 DECLARE br_parse = vc
 SET br_parse = concat("b.oc_id > 0 and b.facility > '   *' ")
 IF (catalog_display > "   *")
  SET br_parse = concat(br_parse," and cnvtupper(b.catalog_type) =",catalog_display)
 ENDIF
 IF (activity_display > "   *")
  SET br_parse = concat(br_parse," and cnvtupper(b.activity_type) =",activity_display)
 ENDIF
 SELECT DISTINCT INTO "NL:"
  b.facility
  FROM br_oc_work b
  PLAN (b
   WHERE parser(br_parse))
  ORDER BY b.facility
  HEAD REPORT
   stat = alterlist(reply->fac_list,10)
  DETAIL
   count = (count+ 1), listcount = (listcount+ 1)
   IF (listcount > 10)
    stat = alterlist(reply->fac_list,(count+ 10)), listcount = 1
   ENDIF
   reply->fac_list[count].fac_name = b.facility
  FOOT REPORT
   stat = alterlist(reply->fac_list,count)
  WITH nocounter
 ;end select
#exit_script
 IF (count > 0)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
