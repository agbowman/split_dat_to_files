CREATE PROGRAM codingoutb_mods_discover_keys:dba
 RECORD reply(
   1 codes[*]
     2 source_key = vc
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
 DECLARE codecnt = i4 WITH public, noconstant(0)
 DECLARE codecap = i4 WITH public, noconstant(0)
 DECLARE table_logical_cnt = f8 WITH public, noconstant(- (1.0))
 DECLARE table_window = i4 WITH public, constant(((2** 16) - 1))
 DECLARE qual = i4 WITH public, noconstant(0)
 SELECT INTO "nl:"
  FROM code_value_outbound_mods c
  PLAN (c
   WHERE (c.logical_cnt > request->logical_cnt)
    AND (c.logical_cnt_index != - (1)))
  DETAIL
   IF (codecnt=codecap)
    IF (codecap=0)
     codecap = 4
    ELSE
     codecap = (codecap * 2)
    ENDIF
    stat = alterlist(reply->codes,codecap)
   ENDIF
   codecnt = (codecnt+ 1), reply->codes[codecnt].source_key = cnvtstring(c.contributor_source_cd),
   reply->codes[codecnt].code_key = cnvtstring(c.code_value),
   reply->codes[codecnt].changed = c.logical_cnt
  FOOT REPORT
   stat = alterlist(reply->codes,codecnt)
  WITH nocounter
 ;end select
 SET qual = curqual
 SELECT INTO "nl:"
  FROM code_value_outbound_mods c
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
