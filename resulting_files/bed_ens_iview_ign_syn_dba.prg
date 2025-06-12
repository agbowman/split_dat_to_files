CREATE PROGRAM bed_ens_iview_ign_syn:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET cnt = 0
 SET cnt = size(request->synonyms,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO cnt)
  IF ((request->synonyms[x].action_flag=1))
   SET br_id = 0.0
   SELECT INTO "NL:"
    j = seq(bedrock_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     br_id = cnvtreal(j)
    WITH format, counter
   ;end select
   SET ierrcode = 0
   INSERT  FROM br_name_value b
    SET b.br_name_value_id = br_id, b.br_nv_key1 = "IVDRIPS_IGN_SYN", b.br_name =
     "ORDER_CATALOG_SYNONYM",
     b.br_value = cnvtstring(request->synonyms[x].id), b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     b.updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    SET reply->error_msg = serrmsg
    GO TO exit_script
   ENDIF
  ENDIF
  IF ((request->synonyms[x].action_flag=3))
   SET ierrcode = 0
   DELETE  FROM br_name_value b
    WHERE b.br_nv_key1="IVDRIPS_IGN_SYN"
     AND b.br_name="ORDER_CATALOG_SYNONYM"
     AND b.br_value=cnvtstring(request->synonyms[x].id)
    WITH nocounter
   ;end delete
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = "Y"
    SET reply->error_msg = serrmsg
    GO TO exit_script
   ENDIF
  ENDIF
 ENDFOR
#exit_script
 IF (failed="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
