CREATE PROGRAM dm_load_codeset:dba
 RECORD reply(
   1 qual[*]
     2 code_set = f8
     2 code_value = f8
     2 display = c100
     2 display_key = c100
     2 description = c100
     2 active = c5
     2 data_status_disp = c12
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_name = c30
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET cv_cnt = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  c1.seq, p.person_id, p.name_full_formatted
  FROM code_value c1,
   code_value c2,
   dummyt d,
   prsnl p
  PLAN (c1
   WHERE (c1.code_set=request->code_set)
    AND (c1.data_status_cd != request->auth_cd)
    AND  EXISTS (
   (SELECT
    "x"
    FROM dm_transaction_data dtd
    WHERE dtd.field_num_value=c1.code_value)))
   JOIN (c2
   WHERE c2.code_value=c1.data_status_cd)
   JOIN (d)
   JOIN (p
   WHERE p.person_id=c1.data_status_prsnl_id)
  ORDER BY c1.code_set, c1.code_value
  DETAIL
   cv_cnt = (cv_cnt+ 1), stat = alterlist(reply->qual,cv_cnt), reply->qual[cv_cnt].code_set = c1
   .code_set,
   reply->qual[cv_cnt].code_value = c1.code_value, reply->qual[cv_cnt].display = substring(1,30,c1
    .display), reply->qual[cv_cnt].display_key = substring(1,30,c1.display_key),
   reply->qual[cv_cnt].description = substring(1,30,c1.description)
   IF (c1.active_ind=1)
    reply->qual[cv_cnt].active = "ACT"
   ELSE
    reply->qual[cv_cnt].active = "INACT"
   ENDIF
   reply->qual[cv_cnt].data_status_disp = substring(1,12,c2.display), reply->qual[cv_cnt].
   data_status_dt_tm = c1.data_status_dt_tm, reply->qual[cv_cnt].data_status_prsnl_name = substring(1,
    30,p.name_full_formatted)
  WITH nocounter, outerjoin = d
 ;end select
 SET reply->status_data.status = "S"
END GO
