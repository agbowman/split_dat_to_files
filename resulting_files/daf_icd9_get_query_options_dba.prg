CREATE PROGRAM daf_icd9_get_query_options:dba
 RECORD reply(
   1 detail_list[*]
     2 detail_id = f8
     2 find_name = vc
     2 detail_type_flag = i2
     2 detail_meaning = vc
     2 detail_description = vc
     2 active_ind = i2
     2 last_run_dt_tm = dq8
   1 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE errcode = i4 WITH public, noconstant(0)
 DECLARE errmsg = vc WITH public
 SELECT INTO "nl:"
  fd.dm_text_find_detail_id, f.find_name, fd.detail_type_flag,
  fd.detail_description, fd.active_ind
  FROM dm_text_find_cat c,
   dm_text_find_cat_r cr,
   dm_text_find f,
   dm_text_find_detail fd
  WHERE (c.find_category=request->find_category)
   AND cr.dm_text_find_cat_id=c.dm_text_find_cat_id
   AND f.dm_text_find_id=cr.dm_text_find_id
   AND fd.dm_text_find_id=f.dm_text_find_id
   AND fd.detail_type_flag IN (2, 3, 4)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->detail_list,cnt), reply->detail_list[cnt].detail_id = fd
   .dm_text_find_detail_id,
   reply->detail_list[cnt].find_name = f.find_name, reply->detail_list[cnt].detail_type_flag = fd
   .detail_type_flag, reply->detail_list[cnt].detail_meaning = fd.detail_meaning,
   reply->detail_list[cnt].detail_description = fd.detail_description, reply->detail_list[cnt].
   active_ind = fd.active_ind
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  SET reply->status_data.status = "F"
  SET reply->message = concat("Unable to fetch Query Detail Information:",errmsg)
  SET stat = alterlist(reply->detail_list,0)
  GO TO exit_script
 ENDIF
 DECLARE loopctr = i4 WITH public, noconstant(0)
 FOR (loopctr = 1 TO size(reply->detail_list,5))
   IF ((reply->detail_list[loopctr].active_ind=1))
    SELECT INTO "nl:"
     max_date = max(fl.end_dt_tm)
     FROM dm_text_find_log fl
     WHERE (fl.dm_text_find_detail_id=reply->detail_list[loopctr].detail_id)
      AND fl.log_status IN ("SUCCESS", "INCOMPLETE")
     DETAIL
      reply->detail_list[loopctr].last_run_dt_tm = cnvtdatetime(max_date)
     WITH nocounter
    ;end select
    SET errcode = error(errmsg,1)
    IF (errcode != 0)
     SET reply->status_data.status = "F"
     SET reply->message = concat("Problems fetching last run date:",errmsg)
     SET stat = alterlist(reply->detail_list,0)
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->message = "Successfully gathered all details."
#exit_script
END GO
