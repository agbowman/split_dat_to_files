CREATE PROGRAM dcp_pl_cv_util
 PROMPT
  "Activate the Relationship Patient List Type ((Y)es or (N)o-default): " = "N"
 SET activate =  $1
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET newcv = 0
 SET oldcv = 0
 SET newcvdt = cnvtdatetime(curdate,curtime3)
 SET oldcvdt = cnvtdatetime("31-DEC-2100")
 IF (((activate="Y") OR (activate="y")) )
  SET newcv = 1
  SET newcvdt = cnvtdatetime("31-DEC-2100")
  SET oldcvdt = cnvtdatetime(curdate,curtime3)
 ELSE
  SET oldcv = 1
  SET newcvdt = cnvtdatetime(curdate,curtime3)
  SET oldcvdt = cnvtdatetime("31-DEC-2100")
 ENDIF
 CALL echo(newcv)
 CALL echo(oldcv)
 UPDATE  FROM code_value cv
  SET cv.active_ind = newcv, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   cv.end_effective_dt_tm = cnvtdatetime(newcvdt), cv.updt_id = reqinfo->updt_id, cv.updt_applctx = 0,
   cv.updt_task = 0
  WHERE cv.code_set=6022
   AND cv.cdf_meaning IN ("PTRELTNLST")
  WITH nocounter
 ;end update
 UPDATE  FROM code_value cv
  SET cv.active_ind = oldcv, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   cv.end_effective_dt_tm = cnvtdatetime(oldcvdt), cv.updt_id = reqinfo->updt_id, cv.updt_applctx = 0,
   cv.updt_task = 0
  WHERE cv.code_set=6022
   AND cv.cdf_meaning IN ("PTVRELTNLST", "PTLRELTNLST", "PTLOCTNGRPLS")
  WITH nocounter
 ;end update
 UPDATE  FROM code_value cv
  SET cv.active_ind = newcv, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   cv.end_effective_dt_tm = cnvtdatetime(newcvdt), cv.updt_id = reqinfo->updt_id, cv.updt_applctx = 0,
   cv.updt_task = 0
  WHERE cv.code_set=27360
   AND cv.cdf_meaning IN ("RELTN")
  WITH nocounter
 ;end update
 UPDATE  FROM code_value cv
  SET cv.active_ind = oldcv, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   cv.end_effective_dt_tm = cnvtdatetime(oldcvdt), cv.updt_id = reqinfo->updt_id, cv.updt_applctx = 0,
   cv.updt_task = 0
  WHERE cv.code_set=27360
   AND cv.cdf_meaning IN ("VRELTN", "LRELTN", "LOCATIONGRP")
  WITH nocounter
 ;end update
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 COMMIT
END GO
