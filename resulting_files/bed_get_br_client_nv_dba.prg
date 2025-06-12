CREATE PROGRAM bed_get_br_client_nv:dba
 FREE SET reply
 RECORD reply(
   01 nlist[*]
     02 name = vc
     02 value = vc
     02 name_value_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET ncnt = size(request->nlist,5)
 IF (ncnt > 0
  AND (request->key1 > " "))
  SET stat = alterlist(reply->nlist,ncnt)
  FOR (x = 1 TO ncnt)
    SET reply->nlist[x].name = request->nlist[x].name
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = ncnt),
    br_name_value bnv
   PLAN (d)
    JOIN (bnv
    WHERE (bnv.br_nv_key1=request->key1)
     AND (bnv.br_name=request->nlist[d.seq].name))
   DETAIL
    reply->nlist[d.seq].value = bnv.br_value, reply->nlist[d.seq].name_value_id = bnv
    .br_name_value_id
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO
