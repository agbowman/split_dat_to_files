CREATE PROGRAM dm_purge_get_jobs:dba
 FREE SET reply
 RECORD reply(
   1 data[*]
     2 name = vc
     2 job_id = f8
     2 purge_flag = i4
     2 last_run_date = vc
     2 active_flag = i4
     2 last_run_status_flag = i4
     2 max_rows = f8
     2 template_nbr = f8
     2 feature_nbr = f8
     2 tokens[*]
       3 token_str = vc
       3 prompt_str = vc
       3 data_type_flag = i4
       3 value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD dpgj_template
 RECORD dpgj_template(
   1 tmp_cnt = i4
   1 tmp_list[*]
     2 tmp_nbr = i4
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
 SET dpgj_template->tmp_cnt = 0
 SET v_templ_cnt = 0
 SET v_prev_template_nbr = - (999)
 SELECT INTO "nl:"
  dt.template_nbr, dt.name, dt.feature_nbr
  FROM dm_purge_template dt
  WHERE dt.active_ind=1
   AND (dt.schema_dt_tm=
  (SELECT
   max(dt2.schema_dt_tm)
   FROM dm_purge_template dt2
   WHERE dt2.template_nbr=dt.template_nbr))
   AND dt.program_str != patstring("XNT*")
  ORDER BY dt.template_nbr
  HEAD dt.template_nbr
   IF (v_prev_template_nbr != dt.template_nbr)
    IF (checkprg(cnvtupper(dt.program_str)) != 0)
     v_templ_cnt = (v_templ_cnt+ 1)
     IF (mod(v_templ_cnt,10)=1)
      stat = alterlist(reply->data,(v_templ_cnt+ 9))
     ENDIF
     reply->data[v_templ_cnt].template_nbr = dt.template_nbr, reply->data[v_templ_cnt].feature_nbr =
     dt.feature_nbr, reply->data[v_templ_cnt].job_id = - ((1 * dt.template_nbr)),
     reply->data[v_templ_cnt].name = dt.name, reply->data[v_templ_cnt].active_flag = c_inactive,
     reply->data[v_templ_cnt].purge_flag = c_audit,
     v_prev_template_nbr = dt.template_nbr
    ELSE
     dpgj_template->tmp_cnt = (dpgj_template->tmp_cnt+ 1)
     IF (mod(dpgj_template->tmp_cnt,10)=1)
      stat = alterlist(dpgj_template->tmp_list,(dpgj_template->tmp_cnt+ 9))
     ENDIF
     dpgj_template->tmp_list[dpgj_template->tmp_cnt].tmp_nbr = dt.template_nbr
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->data,v_templ_cnt), stat = alterlist(dpgj_template->tmp_list,dpgj_template
    ->tmp_cnt)
  WITH nocounter
 ;end select
 FOR (tmpl_ndx1 = 1 TO dpgj_template->tmp_cnt)
   UPDATE  FROM dm_purge_job dpj
    SET dpj.active_flag = c_tmpl_changed
    WHERE (dpj.template_nbr=dpgj_template->tmp_list[tmpl_ndx1].tmp_nbr)
    WITH nocounter
   ;end update
 ENDFOR
 COMMIT
 FOR (tmpl_ndx = 1 TO size(reply->data,5))
   SELECT INTO "nl:"
    dj.job_id, dj.max_rows, dj.purge_flag,
    dj.active_flag, dj.last_run_status_flag, last_run_date = format(dj.last_run_dt_tm,c_df)
    FROM dm_purge_job dj
    WHERE (dj.template_nbr=reply->data[tmpl_ndx].template_nbr)
    DETAIL
     reply->data[tmpl_ndx].job_id = dj.job_id, reply->data[tmpl_ndx].max_rows = dj.max_rows, reply->
     data[tmpl_ndx].purge_flag = dj.purge_flag,
     reply->data[tmpl_ndx].last_run_status_flag = dj.last_run_status_flag, reply->data[tmpl_ndx].
     last_run_date = last_run_date
     IF ((reply->data[tmpl_ndx].active_flag != c_tmpl_changed))
      reply->data[tmpl_ndx].active_flag = dj.active_flag
     ENDIF
    WITH nocounter
   ;end select
   SET v_tok_cnt = 0
   SELECT INTO "nl:"
    pt.prompt_str, pt.data_type_flag
    FROM dm_purge_token pt
    WHERE (pt.template_nbr=reply->data[tmpl_ndx].template_nbr)
     AND (pt.feature_nbr=reply->data[tmpl_ndx].feature_nbr)
    DETAIL
     v_tok_cnt = (v_tok_cnt+ 1), stat = alterlist(reply->data[tmpl_ndx].tokens,v_tok_cnt), reply->
     data[tmpl_ndx].tokens[v_tok_cnt].token_str = pt.token_str,
     reply->data[tmpl_ndx].tokens[v_tok_cnt].prompt_str = pt.prompt_str, reply->data[tmpl_ndx].
     tokens[v_tok_cnt].data_type_flag = pt.data_type_flag
    WITH nocounter
   ;end select
   IF ((reply->data[tmpl_ndx].job_id > 0)
    AND size(reply->data[tmpl_ndx].tokens,5) > 0)
    SELECT INTO "nl:"
     pjt.value
     FROM dm_purge_job_token pjt,
      (dummyt d  WITH seq = value(size(reply->data[tmpl_ndx].tokens,5)))
     PLAN (d)
      JOIN (pjt
      WHERE (pjt.token_str=reply->data[tmpl_ndx].tokens[d.seq].token_str)
       AND (pjt.job_id=reply->data[tmpl_ndx].job_id))
     DETAIL
      reply->data[tmpl_ndx].tokens[d.seq].value = pjt.value
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 IF (size(reply->data,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
