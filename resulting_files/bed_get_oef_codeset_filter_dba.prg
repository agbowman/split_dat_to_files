CREATE PROGRAM bed_get_oef_codeset_filter:dba
 FREE SET reply
 RECORD reply(
   1 flexed_list[*]
     2 code_value = f8
     2 display = c40
     2 mean = c12
   1 not_flexed_list[*]
     2 code_value = f8
     2 display = c40
     2 mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET fcnt = 0
 SET nfcnt = 0
 SET alterlist_fcnt = 0
 SET alterlist_nfcnt = 0
 SET stat = alterlist(reply->flexed_list,20)
 SET stat = alterlist(reply->not_flexed_list,20)
 SELECT INTO "NL:"
  FROM code_value cv,
   accept_format_flexing aff
  PLAN (cv
   WHERE (cv.code_set=request->code_set)
    AND cv.active_ind=1)
   JOIN (aff
   WHERE aff.oe_format_id=outerjoin(request->oe_format_id)
    AND aff.action_type_cd=outerjoin(request->action_type_cd)
    AND aff.flex_cd=outerjoin(cv.code_value))
  ORDER BY cv.display, aff.flex_cd
  HEAD aff.flex_cd
   IF (aff.flex_cd > 0)
    alterlist_fcnt = (alterlist_fcnt+ 1)
    IF (alterlist_fcnt > 20)
     stat = alterlist(reply->flexed_list,(fcnt+ 20)), alterlist_fcnt = 1
    ENDIF
    fcnt = (fcnt+ 1), reply->flexed_list[fcnt].code_value = cv.code_value, reply->flexed_list[fcnt].
    display = cv.display,
    reply->flexed_list[fcnt].mean = cv.cdf_meaning
   ENDIF
  DETAIL
   IF (aff.flex_cd=0)
    alterlist_nfcnt = (alterlist_nfcnt+ 1)
    IF (alterlist_nfcnt > 20)
     stat = alterlist(reply->not_flexed_list,(nfcnt+ 20)), alterlist_nfcnt = 1
    ENDIF
    nfcnt = (nfcnt+ 1), reply->not_flexed_list[nfcnt].code_value = cv.code_value, reply->
    not_flexed_list[nfcnt].display = cv.display,
    reply->not_flexed_list[nfcnt].mean = cv.cdf_meaning
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->flexed_list,fcnt)
 SET stat = alterlist(reply->not_flexed_list,nfcnt)
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
