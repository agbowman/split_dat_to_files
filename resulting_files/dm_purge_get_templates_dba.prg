CREATE PROGRAM dm_purge_get_templates:dba
 FREE SET reply
 RECORD reply(
   1 data[*]
     2 template_nbr = f8
     2 name = vc
     2 program_str = vc
     2 last_updt_date = vc
     2 updt_name = vc
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET c_df = "YYYYMMDDHHMMSScc;;d"
 SET c_del_high_log = 1
 SET c_del_dtl_log = 2
 SET c_audit = 3
 SET c_ptf_delete = 1
 SET c_ptf_update = 2
 SET c_active = 1
 SET c_inactive = 2
 SET c_tmpl_changed = 3
 SET c_sf_success = 1
 SET c_sf_failed = 2
 DECLARE omf_get_pers_full() = c255
 SET v_templ_cnt = 0
 SELECT INTO "nl:"
  dt.template_nbr, dt.name, dt.program_str,
  last_updt_date = format(dt.updt_dt_tm,c_df), updt_name = omf_get_pers_full(dt.updt_id), dt
  .active_ind
  FROM dm_purge_template dt
  WHERE list(dt.template_nbr,dt.schema_dt_tm) IN (
  (SELECT
   dt2.template_nbr, max(dt2.schema_dt_tm)
   FROM dm_purge_template dt2
   GROUP BY dt2.template_nbr))
   AND dt.feature_nbr > 0
  DETAIL
   v_templ_cnt = (v_templ_cnt+ 1)
   IF (mod(v_templ_cnt,10)=1)
    stat = alterlist(reply->data,(v_templ_cnt+ 9))
   ENDIF
   reply->data[v_templ_cnt].template_nbr = dt.template_nbr, reply->data[v_templ_cnt].name = dt.name,
   reply->data[v_templ_cnt].program_str = dt.program_str,
   reply->data[v_templ_cnt].last_updt_date = last_updt_date, reply->data[v_templ_cnt].updt_name =
   updt_name, reply->data[v_templ_cnt].active_ind = dt.active_ind
  FOOT REPORT
   stat = alterlist(reply->data,v_templ_cnt)
  WITH nocounter
 ;end select
 IF (size(reply->data,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
