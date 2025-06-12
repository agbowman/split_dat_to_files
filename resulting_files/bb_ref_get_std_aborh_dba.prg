CREATE PROGRAM bb_ref_get_std_aborh:dba
 RECORD reply(
   1 aborh[*]
     2 aborh_cd = f8
     2 display = vc
     2 meaning = c40
     2 description = vc
     2 abo_cd = f8
     2 rh_cd = f8
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
 SET stat = alterlist(reply->aborh,10)
 SELECT
  IF ((request->active_flag=2))
   PLAN (cv
    WHERE cv.code_set=1640)
    JOIN (cve
    WHERE cve.code_value=cv.code_value
     AND cve.field_name IN ("ABOOnly_cd", "RhOnly_cd")
     AND cve.code_set=cv.code_set)
  ELSE
   PLAN (cv
    WHERE cv.code_set=1640
     AND (cv.active_ind=request->active_flag))
    JOIN (cve
    WHERE cve.code_value=cv.code_value
     AND cve.field_name IN ("ABOOnly_cd", "RhOnly_cd")
     AND cve.code_set=cv.code_set)
  ENDIF
  INTO "nl:"
  FROM code_value cv,
   code_value_extension cve
  ORDER BY cv.code_value
  HEAD cv.code_value
   ncnt = (ncnt+ 1)
   IF (mod(ncnt,10)=1
    AND ncnt != 1)
    stat = alterlist(reply->aborh,(ncnt+ 10))
   ENDIF
  DETAIL
   reply->aborh[ncnt].aborh_cd = cv.code_value, reply->aborh[ncnt].display = cv.display, reply->
   aborh[ncnt].meaning = cv.cdf_meaning,
   reply->aborh[ncnt].description = cv.description
   IF (cve.field_name="ABOOnly_cd")
    IF (trim(cve.field_value)="")
     reply->aborh[ncnt].abo_cd = 0
    ELSE
     reply->aborh[ncnt].abo_cd = cnvtreal(cve.field_value)
    ENDIF
   ELSE
    IF (trim(cve.field_value)="")
     reply->aborh[ncnt].rh_cd = 0
    ELSE
     reply->aborh[ncnt].rh_cd = cnvtreal(cve.field_value)
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->aborh,ncnt)
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
