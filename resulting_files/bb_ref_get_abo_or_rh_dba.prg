CREATE PROGRAM bb_ref_get_abo_or_rh:dba
 RECORD reply(
   1 codeset[*]
     2 code_value = f8
     2 display = vc
     2 meaning = c40
     2 description = vc
     2 barcode = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ncnt = i2
 SET ncnt = 0
 SET serrormsg = fillstring(255," ")
 SET serror_check = error(serrormsg,1)
 SET stat = alterlist(reply->codeset,10)
 SELECT
  IF ((request->active_flag=2))
   PLAN (cv
    WHERE (cv.code_set=request->code_set))
    JOIN (d)
    JOIN (cve
    WHERE cve.code_value=cv.code_value
     AND cve.field_name="Barcode"
     AND cve.code_set=cv.code_set)
  ELSE
   PLAN (cv
    WHERE (cv.code_set=request->code_set)
     AND (cv.active_ind=request->active_flag))
    JOIN (d)
    JOIN (cve
    WHERE cve.code_value=cv.code_value
     AND cve.field_name="Barcode"
     AND cve.code_set=cv.code_set)
  ENDIF
  INTO "nl:"
  cve_ind = decode(cve.seq,1,0)
  FROM code_value cv,
   (dummyt d  WITH seq = 1),
   code_value_extension cve
  ORDER BY cv.code_value
  HEAD cv.code_value
   ncnt = (ncnt+ 1)
   IF (mod(ncnt,10)=1
    AND ncnt != 1)
    stat = alterlist(reply->codeset,(ncnt+ 10))
   ENDIF
  DETAIL
   reply->codeset[ncnt].code_value = cv.code_value, reply->codeset[ncnt].display = cv.display, reply
   ->codeset[ncnt].meaning = cv.cdf_meaning,
   reply->codeset[ncnt].description = cv.description
   IF (cve_ind=1)
    reply->codeset[ncnt].barcode = cve.field_value
   ENDIF
  WITH nocounter, outerjoin(d)
 ;end select
 SET stat = alterlist(reply->codeset,ncnt)
 SET serror_check = error(serrormsg,0)
 IF (serror_check=0)
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
 ENDIF
#exit_script
END GO
