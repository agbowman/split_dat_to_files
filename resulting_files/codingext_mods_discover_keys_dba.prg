CREATE PROGRAM codingext_mods_discover_keys:dba
 RECORD reply(
   1 codes[*]
     2 code_key = vc
     2 changed = f8
   1 codesets[*]
     2 codeset_key = vc
     2 name_key = vc
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
 DECLARE codesetcnt = i4 WITH public, noconstant(0)
 DECLARE codesetcap = i4 WITH public, noconstant(0)
 DECLARE table_logical_cnt = f8 WITH public, noconstant(- (1.0))
 DECLARE table_window = i4 WITH public, constant(((2** 16) - 1))
 DECLARE qual = i4 WITH public, noconstant(0)
 SELECT INTO "nl:"
  FROM code_value_extnsn_mods c
  PLAN (c
   WHERE (c.logical_cnt > request->logical_cnt)
    AND (c.logical_cnt_index != - (1)))
  ORDER BY c.code_value, c.logical_cnt DESC
  HEAD c.code_value
   IF (codecnt=codecap)
    IF (codecap=0)
     codecap = 4
    ELSE
     codecap = (codecap * 2)
    ENDIF
    stat = alterlist(reply->codes,codecap)
   ENDIF
   codecnt = (codecnt+ 1), reply->codes[codecnt].code_key = cnvtstring(c.code_value), reply->codes[
   codecnt].changed = c.logical_cnt
  FOOT REPORT
   stat = alterlist(reply->codes,codecnt)
  WITH nocounter
 ;end select
 SET qual = curqual
 SELECT DISTINCT INTO "nl:"
  c.code_set, c.field_name
  FROM code_value_extnsn_mods c
  PLAN (c
   WHERE (c.logical_cnt > request->logical_cnt)
    AND (c.logical_cnt_index != - (1)))
  ORDER BY c.code_set, c.field_name, c.logical_cnt DESC
  DETAIL
   IF (codesetcnt=codesetcap)
    IF (codesetcap=0)
     codesetcap = 4
    ELSE
     codesetcap = (codesetcap * 2)
    ENDIF
    stat = alterlist(reply->codesets,codesetcap)
   ENDIF
   codesetcnt = (codesetcnt+ 1), reply->codesets[codesetcnt].codeset_key = cnvtstring(c.code_set),
   reply->codesets[codesetcnt].name_key = c.field_name,
   reply->codesets[codesetcnt].changed = c.logical_cnt
  FOOT REPORT
   stat = alterlist(reply->codesets,codesetcnt)
  WITH nocounter
 ;end select
 SET qual = (qual+ curqual)
 SELECT INTO "nl:"
  FROM code_value_extnsn_mods c
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
