CREATE PROGRAM codinggrp_discover_keys:dba
 RECORD reply(
   1 parents[*]
     2 code_key = vc
     2 changed = dq8
   1 children[*]
     2 code_key = vc
     2 changed = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE parentcnt = i4 WITH public, noconstant(0)
 DECLARE parentcap = i4 WITH public, noconstant(0)
 DECLARE childcnt = i4 WITH public, noconstant(0)
 DECLARE childcap = i4 WITH public, noconstant(0)
 SELECT INTO "nl:"
  FROM code_value_group c
  PLAN (c
   WHERE c.updt_dt_tm > cnvtdatetime(request->since))
  ORDER BY c.parent_code_value, c.updt_dt_tm DESC
  HEAD c.parent_code_value
   IF (parentcnt=parentcap)
    IF (parentcap=0)
     parentcap = 4
    ELSE
     parentcap = (parentcap * 2)
    ENDIF
    stat = alterlist(reply->parents,parentcap)
   ENDIF
   parentcnt = (parentcnt+ 1), reply->parents[parentcnt].code_key = cnvtstring(c.parent_code_value),
   reply->parents[parentcnt].changed = c.updt_dt_tm
  FOOT REPORT
   stat = alterlist(reply->parents,parentcnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value_group c
  PLAN (c
   WHERE c.updt_dt_tm > cnvtdatetime(request->since))
  ORDER BY c.child_code_value, c.updt_dt_tm DESC
  HEAD c.child_code_value
   IF (childcnt=childcap)
    IF (childcap=0)
     childcap = 4
    ELSE
     childcap = (childcap * 2)
    ENDIF
    stat = alterlist(reply->children,childcap)
   ENDIF
   childcnt = (childcnt+ 1), reply->children[childcnt].code_key = cnvtstring(c.child_code_value),
   reply->children[childcnt].changed = c.updt_dt_tm
  FOOT REPORT
   stat = alterlist(reply->children,childcnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
