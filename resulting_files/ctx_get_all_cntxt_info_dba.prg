CREATE PROGRAM ctx_get_all_cntxt_info:dba
 SELECT INTO "nl:"
  a.app_ctx_id
  FROM application_context a
  WHERE  $1
   AND  $2
   AND  $3
   AND  $4
   AND  $5
   AND  $6
  DETAIL
   count1 += 1, reply->qual[count1].app_ctx_id = a.app_ctx_id, reply->qual[count1].application_number
    = a.application_number,
   reply->qual[count1].name = a.name, reply->qual[count1].username = a.username, reply->qual[count1].
   start_dt_tm = cnvtdatetime(a.start_dt_tm),
   reply->qual[count1].end_dt_tm = cnvtdatetime(a.end_dt_tm), reply->qual[count1].application_image
    = a.application_image, reply->qual[count1].authorization_ind = a.authorization_ind,
   reply->qual[count1].client_tz = a.client_tz, reply->qual[count1].person_id = a.person_id
   IF (count1=maxrows)
    context->context_ind = 1, context->application_context_id = a.applctx
   ENDIF
  WITH nocounter, maxqual(a,value(maxrows))
 ;end select
END GO
