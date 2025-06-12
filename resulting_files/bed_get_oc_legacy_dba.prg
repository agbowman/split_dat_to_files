CREATE PROGRAM bed_get_oc_legacy:dba
 FREE SET reply
 RECORD reply(
   1 oc_list[*]
     2 oc_id = f8
     2 short_desc = c100
     2 long_desc = c100
     2 primary_name = c100
     2 catalog_code_value = f8
     2 fac_list[*]
       3 name = vc
     2 status = i2
     2 match_type = i2
     2 match_value = c100
     2 facility = vc
     2 cpt4_code = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
   1 catalog_loaded_ind = i2
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SET listcount = 0
 SET fac_count = 0
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
 SET br_parse = concat("b.oc_id > 0 and (b.status_ind != 3 or request->inactive_ind = 1)")
 IF (catalog_display > "   *")
  SET br_parse = concat(br_parse," and cnvtupper(b.catalog_type) =",catalog_display)
 ENDIF
 IF (activity_display > "   *")
  SET br_parse = concat(br_parse," and cnvtupper(b.activity_type) =",activity_display)
 ENDIF
 SELECT INTO "NL:"
  FROM br_oc_work b
  PLAN (b
   WHERE parser(br_parse))
  DETAIL
   reply->catalog_loaded_ind = 1
  WITH nocounter, maxqual(b,1)
 ;end select
 IF ((request->load.matches_ind=2))
  SET br_parse = concat(br_parse," and b.match_orderable_cd > 0.0")
 ELSEIF ((request->load.matches_ind=3))
  SET br_parse = concat(br_parse," and b.match_orderable_cd = 0.0")
 ENDIF
 SET fac_count = size(request->filters.fac_list,5)
 IF (fac_count > 0)
  FOR (i = 1 TO fac_count)
    IF (i=1)
     SET br_parse = concat(br_parse," and (b.facility = '",trim(request->filters.fac_list[i].name),
      "'")
    ELSE
     SET br_parse = concat(br_parse," or b.facility = '",trim(request->filters.fac_list[i].name),"'")
    ENDIF
  ENDFOR
  SET br_parse = concat(br_parse,")")
 ENDIF
 SET cpt4_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=14002
   AND cv.cki="CKI.CODEVALUE!3600"
  DETAIL
   cpt4_code_value = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  b.oc_id, b.short_desc, b.long_desc,
  o.primary_name
  FROM br_oc_work b,
   br_oc_pricing bp,
   order_catalog o
  PLAN (b
   WHERE parser(br_parse))
   JOIN (bp
   WHERE bp.oc_id=outerjoin(b.oc_id)
    AND bp.billcode_sched_cd=outerjoin(cpt4_code_value))
   JOIN (o
   WHERE o.catalog_cd=outerjoin(b.match_orderable_cd))
  ORDER BY b.short_desc
  HEAD REPORT
   stat = alterlist(reply->oc_list,50), count = 0, listcount = 0
  DETAIL
   count = (count+ 1), listcount = (listcount+ 1)
   IF (listcount > 50)
    stat = alterlist(reply->oc_list,(count+ 50)), listcount = 1
   ENDIF
   reply->oc_list[count].short_desc = b.short_desc, reply->oc_list[count].long_desc = b.long_desc,
   reply->oc_list[count].oc_id = b.oc_id,
   reply->oc_list[count].match_type = b.match_ind, reply->oc_list[count].match_value = b.match_value,
   reply->oc_list[count].status = b.status_ind
   IF (b.match_orderable_cd > 0)
    reply->oc_list[count].primary_name = o.primary_mnemonic, reply->oc_list[count].catalog_code_value
     = b.match_orderable_cd
   ENDIF
   reply->oc_list[count].facility = b.facility, reply->oc_list[count].cpt4_code = bp.billcode
  FOOT REPORT
   stat = alterlist(reply->oc_list,count)
  WITH nocounter
 ;end select
#exit_script
 IF (count=0)
  SET reply->status_data.status = "Z"
 ELSEIF (count > 0)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
