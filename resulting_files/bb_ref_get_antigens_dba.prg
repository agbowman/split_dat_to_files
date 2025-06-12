CREATE PROGRAM bb_ref_get_antigens:dba
 RECORD reply(
   1 antigens[*]
     2 antigen_cd = f8
     2 display = vc
     2 description = vc
     2 opposite_cd = f8
     2 active_ind = i2
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
 SET stat = alterlist(reply->antigens,10)
 SELECT
  IF ((request->active_flag=2))
   PLAN (cv
    WHERE cv.code_set=1612
     AND cv.cdf_meaning IN ("+", "-"))
    JOIN (cve
    WHERE cve.code_value=cv.code_value
     AND cve.field_name="Opposite"
     AND cve.code_set=cv.code_set)
  ELSE
   PLAN (cv
    WHERE cv.code_set=1612
     AND cv.cdf_meaning IN ("+", "-")
     AND (cv.active_ind=request->active_flag))
    JOIN (cve
    WHERE cve.code_value=cv.code_value
     AND cve.field_name="Opposite"
     AND cve.code_set=cv.code_set)
  ENDIF
  INTO "nl:"
  FROM code_value cv,
   code_value_extension cve
  HEAD cv.code_value
   ncnt = (ncnt+ 1)
   IF (mod(ncnt,10)=1
    AND ncnt != 1)
    stat = alterlist(reply->antigens,(ncnt+ 10))
   ENDIF
  DETAIL
   reply->antigens[ncnt].antigen_cd = cv.code_value, reply->antigens[ncnt].display = cv.display,
   reply->antigens[ncnt].description = cv.description,
   reply->antigens[ncnt].active_ind = cv.active_ind
   IF (trim(cve.field_value)="")
    reply->antigens[ncnt].opposite_cd = 0
   ELSE
    reply->antigens[ncnt].opposite_cd = cnvtreal(cve.field_value)
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->antigens,ncnt)
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
