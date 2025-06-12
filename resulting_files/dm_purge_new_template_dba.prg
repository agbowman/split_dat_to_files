CREATE PROGRAM dm_purge_new_template:dba
 FREE SET reply
 RECORD reply(
   1 template_nbr = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET v_next_template_nbr = 1
 SELECT INTO "nl:"
  max_templ = max(dt.template_nbr)
  FROM dm_purge_template dt
  DETAIL
   v_next_template_nbr = (max_templ+ 1)
  WITH nocounter
 ;end select
 INSERT  FROM dm_purge_template dt
  SET dt.template_nbr = v_next_template_nbr, dt.feature_nbr = 0, dt.updt_task = reqinfo->updt_task,
   dt.updt_id = reqinfo->updt_id, dt.updt_applctx = reqinfo->updt_applctx, dt.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   dt.updt_cnt = 0
 ;end insert
 COMMIT
 SET reply->template_nbr = v_next_template_nbr
 SET reply->status_data.status = "S"
END GO
