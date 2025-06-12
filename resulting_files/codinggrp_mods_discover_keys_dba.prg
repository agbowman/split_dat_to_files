CREATE PROGRAM codinggrp_mods_discover_keys:dba
 RECORD reply(
   1 parents[*]
     2 code_key = vc
     2 changed = f8
   1 children[*]
     2 code_key = vc
     2 changed = f8
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
 DECLARE table_logical_cnt = f8 WITH public, noconstant(- (1.0))
 DECLARE table_window = i4 WITH public, constant(((2** 16) - 1))
 DECLARE qual = i4 WITH public, noconstant(0)
 SELECT INTO "nl:"
  FROM code_value_group_mods c
  PLAN (c
   WHERE (c.logical_cnt > request->logical_cnt)
    AND (c.logical_cnt_index != - (1)))
  ORDER BY c.parent_code_value, c.logical_cnt DESC
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
   reply->parents[parentcnt].changed = c.logical_cnt
  FOOT REPORT
   stat = alterlist(reply->parents,parentcnt)
  WITH nocounter
 ;end select
 SET qual = curqual
 SELECT INTO "nl:"
  FROM code_value_group_mods c
  PLAN (c
   WHERE (c.logical_cnt > request->logical_cnt)
    AND (c.logical_cnt_index != - (1)))
  ORDER BY c.child_code_value, c.logical_cnt DESC
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
   reply->children[childcnt].changed = c.logical_cnt
  FOOT REPORT
   stat = alterlist(reply->children,childcnt)
  WITH nocounter
 ;end select
 SET qual = (curqual+ qual)
 SELECT INTO "nl:"
  FROM code_value_group_mods c
  PLAN (c
   WHERE c.logical_cnt_index=mod(request->logical_cnt,table_window))
  DETAIL
   table_logical_cnt = c.logical_cnt
  WITH nocounter
 ;end select
 IF ((((table_logical_cnt=request->logical_cnt)) OR ((request->logical_cnt=0)
  AND (table_logical_cnt=- (1)))) )
  IF (qual=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SET stat = alterlist(reply->codes,0)
  SET stat = alterlist(reply->codesets,0)
  SET stat = alterlist(reply->ckis,0)
  SET stat = alterlist(reply->concept_ckis,0)
  SET reply->status_data.status = "F"
 ENDIF
END GO
