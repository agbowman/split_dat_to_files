CREATE PROGRAM bed_get_name_value:dba
 FREE SET reply
 RECORD reply(
   1 nlist[*]
     2 name = vc
     2 value = vc
     2 name_value_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "Z"
 SET tot_count = 0
 SET count = 0
 SET stat = alterlist(reply->nlist,50)
 DECLARE name_parse = vc
 DECLARE name_pares2 = vc
 SET name_parse = concat("b.br_nv_key1 = '",trim(request->key1),"'")
 SET ncount = size(request->nlist,5)
 FOR (x = 1 TO ncount)
   IF (x=1)
    SET name_parse = concat(name_parse," and ((b.br_name = '",trim(request->nlist[x].name),"')")
   ELSE
    SET name_parse = concat(name_parse," or (b.br_name = '",trim(request->nlist[x].name),"')")
   ENDIF
 ENDFOR
 IF (ncount > 0)
  SET name_parse = concat(name_parse,")")
 ENDIF
 SELECT INTO "NL:"
  FROM br_name_value b
  WHERE parser(name_parse)
  ORDER BY b.br_value
  DETAIL
   tot_count = (tot_count+ 1), count = (count+ 1)
   IF (count > 50)
    stat = alterlist(reply->nlist,(tot_count+ 50)), count = 1
   ENDIF
   reply->nlist[tot_count].name = b.br_name, reply->nlist[tot_count].value = b.br_value, reply->
   nlist[tot_count].name_value_id = b.br_name_value_id
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->nlist,tot_count)
 GO TO exit_script
#exit_script
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
