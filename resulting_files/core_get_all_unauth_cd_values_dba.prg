CREATE PROGRAM core_get_all_unauth_cd_values:dba
 SET modify = predeclare
 FREE RECORD reply
 RECORD reply(
   1 code_values[*]
     2 code_value = f8
     2 code_set = i4
     2 display = c40
     2 description = c60
     2 definition = vc
     2 cdf_meaning = c12
     2 contributor_source_cd = f8
     2 contributor_source_disp = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE unauth = f8 WITH public, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET unauth = uar_get_code_by("MEANING",8,"UNAUTH")
 SELECT
  IF ((request->code_set > 0.0))
   PLAN (cv
    WHERE cv.data_status_cd=unauth
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND (cv.code_set=request->code_set))
    JOIN (cva
    WHERE cva.code_value=outerjoin(cv.code_value)
     AND cva.code_set=outerjoin(cv.code_set))
  ELSE
   PLAN (cv
    WHERE cv.data_status_cd=unauth
     AND cv.active_ind=1
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (cva
    WHERE cva.code_value=outerjoin(cv.code_value)
     AND cva.code_set=outerjoin(cv.code_set))
  ENDIF
  INTO "nl:"
  cv.code_set, cv.code_value, cv.definition,
  cv.description, cv.display
  FROM code_value cv,
   code_value_alias cva
  ORDER BY cv.code_set
  HEAD REPORT
   cv_cnt = 0
  DETAIL
   cv_cnt = (cv_cnt+ 1)
   IF (mod(cv_cnt,10)=1)
    stat = alterlist(reply->code_values,(cv_cnt+ 9))
   ENDIF
   reply->code_values[cv_cnt].code_value = cv.code_value, reply->code_values[cv_cnt].code_set = cv
   .code_set, reply->code_values[cv_cnt].display = cv.display,
   reply->code_values[cv_cnt].description = cv.description, reply->code_values[cv_cnt].definition =
   cv.definition, reply->code_values[cv_cnt].cdf_meaning = cv.cdf_meaning,
   reply->code_values[cv_cnt].contributor_source_cd = cva.contributor_source_cd
  FOOT REPORT
   stat = alterlist(reply->code_values,cv_cnt)
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "000 03/06/03 JF8275"
END GO
