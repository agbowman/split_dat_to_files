CREATE PROGRAM dm_lookup_mrg_xlates:dba
 DECLARE dm_counter = i4 WITH public, noconstant(0)
 DECLARE dm_stat = i4 WITH public, noconstant(0)
 DECLARE dm_total = i4 WITH public, noconstant(0)
 FREE RECORD reply
 RECORD reply(
   1 sourceenvid = f8
   1 targetenvid = f8
   1 qual[*]
     2 fromvalue = f8
     2 tovalue = f8
 )
 SET reply->sourceenvid = request->sourceenvid
 SET reply->targetenvid = request->targetenvid
 SET dm_total = size(request->qual,5)
 IF (dm_total > 0)
  SELECT INTO "NL:"
   FROM dm_merge_translate dmt,
    (dummyt d  WITH seq = value(dm_total))
   PLAN (d)
    JOIN (dmt
    WHERE (dmt.env_source_id=request->sourceenvid)
     AND (dmt.env_target_id=request->targetenvid)
     AND (dmt.table_name=request->tablename)
     AND (dmt.from_value=request->qual[d.seq].fromvalue))
   HEAD REPORT
    dm_stat = alterlist(reply->qual,dm_total)
   DETAIL
    reply->qual[d.seq].fromvalue = dmt.from_value, reply->qual[d.seq].tovalue = dmt.to_value
   WITH nocounter
  ;end select
 ELSE
  IF ((request->code_set > 0))
   SELECT INTO "NL:"
    FROM code_value cv,
     dm_merge_translate dmt
    PLAN (cv
     WHERE (request->code_set=cv.code_set))
     JOIN (dmt
     WHERE dmt.from_value=cv.code_value
      AND dmt.table_name="CODE_VALUE"
      AND (dmt.env_source_id=request->sourceenvid)
      AND (dmt.env_target_id=request->targetenvid))
    HEAD REPORT
     dm_counter = 0, dm_stat = alterlist(reply->qual,10)
    DETAIL
     dm_counter += 1
     IF (mod(dm_counter,10)=1
      AND dm_counter != 1)
      dm_stat = alterlist(reply->qual,(dm_counter+ 10))
     ENDIF
     reply->qual[dm_counter].tovalue = dmt.to_value, reply->qual[dm_counter].fromvalue = dmt
     .from_value
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "NL:"
    FROM dm_merge_translate dmt
    PLAN (dmt
     WHERE (dmt.env_source_id=request->sourceenvid)
      AND (dmt.env_target_id=request->targetenvid)
      AND (dmt.table_name=request->tablename))
    HEAD REPORT
     dm_counter = 0, dm_stat = alterlist(reply->qual,10)
    DETAIL
     dm_counter += 1
     IF (mod(dm_counter,10)=1
      AND dm_counter != 1)
      dm_stat = alterlist(reply->qual,(dm_counter+ 10))
     ENDIF
     reply->qual[dm_counter].fromvalue = dmt.from_value, reply->qual[dm_counter].tovalue = dmt
     .to_value
    WITH nocounter
   ;end select
  ENDIF
  SET dm_stat = alterlist(reply->qual,dm_counter)
 ENDIF
END GO
