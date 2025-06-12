CREATE PROGRAM bed_get_valid_clients:dba
 FREE SET reply
 RECORD reply(
   1 client_cnt = i2
   1 clist[*]
     2 br_client_id = f8
     2 br_client_name = vc
     2 start_version_nbr = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->client_cnt = 0
 IF (trim(request->username) > "")
  SELECT INTO "nl:"
   FROM br_prsnl p,
    br_client bc
   PLAN (p
    WHERE (p.username=request->username))
    JOIN (bc
    WHERE bc.br_client_id=p.br_client_id)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->clist,cnt), reply->clist[cnt].br_client_id = bc
    .br_client_id,
    reply->clist[cnt].br_client_name = bc.br_client_name, reply->clist[cnt].start_version_nbr = bc
    .start_version_nbr
   FOOT REPORT
    reply->client_cnt = cnt
   WITH nocounter, skipbedrock = 1
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM br_prsnl bp,
    br_client bc
   PLAN (bp
    WHERE (bp.br_prsnl_id=reqinfo->updt_id))
    JOIN (bc
    WHERE bc.br_client_id=bp.br_client_id)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reply->clist,cnt), reply->clist[cnt].br_client_id = bc
    .br_client_id,
    reply->clist[cnt].br_client_name = bc.br_client_name, reply->clist[cnt].start_version_nbr = bc
    .start_version_nbr
   FOOT REPORT
    reply->client_cnt = cnt
   WITH nocounter, skipbedrock = 1
  ;end select
 ENDIF
#exit_script
 IF ((reply->client_cnt > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
