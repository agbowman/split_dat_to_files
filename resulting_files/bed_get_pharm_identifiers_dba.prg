CREATE PROGRAM bed_get_pharm_identifiers:dba
 FREE SET reply
 RECORD reply(
   1 items[*]
     2 item_id = f8
     2 identifiers[*]
       3 identifier_id = f8
       3 value = vc
       3 primary_ind = i2
       3 identifier_type
         4 code_value = f8
         4 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 FREE SET rxa_get_req
 FREE SET rxa_get_reply
 EXECUTE rxa_get_medprod_rr_incl  WITH replace("REQUEST","RXA_GET_REQ"), replace("REPLY",
  "RXA_GET_REPLY")
 SET inpatient_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4500
   AND cv.cdf_meaning="INPATIENT"
   AND cv.active_ind=1
  DETAIL
   inpatient_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET system_code_value = 0.0
 SET system_package_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4062
   AND cv.cdf_meaning IN ("SYSTEM", "SYSPKGTYP")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="SYSTEM")
    system_code_value = cv.code_value
   ELSEIF (cv.cdf_meaning="SYSPKGTYP")
    system_package_code_value = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->items,size(request->items,5))
 FOR (main_i = 1 TO size(request->items,5))
   SET stat = initrec(rxa_get_reply)
   SET stat = initrec(rxa_get_req)
   SET stat = alterlist(rxa_get_req->qual,1)
   SET rxa_get_req->pharm_type_cd = inpatient_code_value
   SET rxa_get_req->qual[1].item_id = request->items[main_i].item_id
   EXECUTE rxa_get_medproduct  WITH replace("REQUEST",rxa_get_req), replace("REPLY",rxa_get_reply)
   SET cnt = size(rxa_get_reply->meddefqual,5)
   FOR (x = 1 TO cnt)
    SET reply->items[main_i].item_id = rxa_get_reply->meddefqual[x].item_id
    FOR (y = 1 TO size(rxa_get_reply->meddefqual[x].meddefflexqual,5))
      IF ((rxa_get_reply->meddefqual[x].meddefflexqual[y].flex_type_cd=system_code_value))
       IF (size(rxa_get_reply->meddefqual[x].meddefflexqual[y].medidentifierqual,5) > 0)
        SELECT INTO "nl:"
         FROM (dummyt d  WITH seq = size(rxa_get_reply->meddefqual[x].meddefflexqual[y].
           medidentifierqual,5)),
          code_value cv
         PLAN (d
          WHERE (rxa_get_reply->meddefqual[x].meddefflexqual[y].medidentifierqual[d.seq].active_ind=1
          )
           AND (rxa_get_reply->meddefqual[x].meddefflexqual[y].medidentifierqual[d.seq].primary_ind
           IN (1, request->only_primary_ind)))
          JOIN (cv
          WHERE (cv.code_value=rxa_get_reply->meddefqual[x].meddefflexqual[y].medidentifierqual[d.seq
          ].med_identifier_type_cd))
         ORDER BY d.seq
         HEAD REPORT
          icnt = 0, ilcnt = 0, stat = alterlist(reply->items[main_i].identifiers,10)
         DETAIL
          icnt = (icnt+ 1), ilcnt = (ilcnt+ 1)
          IF (ilcnt > 10)
           stat = alterlist(reply->items[main_i].identifiers,(icnt+ 10)), ilcnt = 1
          ENDIF
          reply->items[main_i].identifiers[icnt].identifier_id = rxa_get_reply->meddefqual[x].
          meddefflexqual[y].medidentifierqual[d.seq].med_identifier_id, reply->items[main_i].
          identifiers[icnt].identifier_type.code_value = rxa_get_reply->meddefqual[x].meddefflexqual[
          y].medidentifierqual[d.seq].med_identifier_type_cd, reply->items[main_i].identifiers[icnt].
          identifier_type.display = cv.display,
          reply->items[main_i].identifiers[icnt].primary_ind = rxa_get_reply->meddefqual[x].
          meddefflexqual[y].medidentifierqual[d.seq].primary_ind, reply->items[main_i].identifiers[
          icnt].value = rxa_get_reply->meddefqual[x].meddefflexqual[y].medidentifierqual[d.seq].value
         FOOT REPORT
          stat = alterlist(reply->items[main_i].identifiers,icnt)
         WITH nocounter
        ;end select
       ENDIF
      ENDIF
    ENDFOR
   ENDFOR
 ENDFOR
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
