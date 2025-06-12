CREATE PROGRAM dcp_get_ref_text_exists:dba
 SET modify = predeclare
 RECORD reply(
   1 cdf_qual[*]
     2 cdf_meaning = vc
     2 code_value = f8
     2 exist_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE where_cond = vc WITH noconstant
 DECLARE cdf_cnt = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE dummy = i4 WITH noconstant(0)
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 SET where_cond = concat(" r.text_type_cd = OUTERJOIN(c.code_value)",
  " and r.parent_entity_name = OUTERJOIN(request->parent_entity_name)",
  " and r.parent_entity_id = OUTERJOIN(request->parent_entity_id)")
 IF ((request->parent_entity_dt_tm > 0))
  SET where_cond = build(where_cond,
   " and r.beg_effective_dt_tm <= OUTERJOIN(cnvtdatetime(request->parent_entity_dt_tm))")
  SET where_cond = build(where_cond,
   " and r.end_effective_dt_tm >= OUTERJOIN(cnvtdatetime(request->parent_entity_dt_tm))")
 ELSE
  SET where_cond = build(where_cond,
   " and r.beg_effective_dt_tm <= OUTERJOIN(cnvtdatetime(curdate, curtime3))")
  SET where_cond = build(where_cond,
   " and r.end_effective_dt_tm >= OUTERJOIN(cnvtdatetime(curdate, curtime3))")
 ENDIF
 IF (where_cond <= " ")
  CALL report_failure("SELECT","F","DCP_GET_REF_TEXT_EXISTS",
   "Failed to build the dynamic where clause")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  c.code_value, c.cdf_meaning, r.text_type_cd
  FROM code_value c,
   ref_text_reltn r
  PLAN (c
   WHERE c.code_set=6009
    AND c.active_ind=1)
   JOIN (r
   WHERE parser(where_cond))
  ORDER BY c.code_value
  HEAD REPORT
   cdf_cnt = 0, stat = alterlist(reply->cdf_qual,10)
  HEAD c.code_value
   cdf_cnt = (cdf_cnt+ 1)
   IF (cdf_cnt > size(reply->cdf_qual,5))
    stat = alterlist(reply->cdf_qual,(cdf_cnt+ 10))
   ENDIF
   reply->cdf_qual[cdf_cnt].cdf_meaning = c.cdf_meaning, reply->cdf_qual[cdf_cnt].code_value = c
   .code_value
  DETAIL
   IF (r.text_type_cd > 0)
    reply->cdf_qual[cdf_cnt].exist_ind = 1
   ENDIF
  FOOT  c.code_value
   dummy = 0
  FOOT REPORT
   stat = alterlist(reply->cdf_qual,cdf_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL report_failure("SELECT","F","DCP_GET_REF_TEXT_EXISTS","Data select failed")
  GO TO exit_script
 ENDIF
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   SET cfailed = "T"
   SET stat = alterlist(reply->status_data.subeventstatus,(value(size(reply->status_data.
      subeventstatus,5))+ 1))
   SET reply->status_data.subeventstatus[1].operationname = trim(opname)
   SET reply->status_data.subeventstatus[1].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[1].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
