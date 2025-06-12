CREATE PROGRAM dm_purge_get_log_tab:dba
 FREE SET reply
 RECORD reply(
   1 log[*]
     2 log_id = f8
     2 tab[*]
       3 table_name = vc
       3 purge_flag = i4
       3 num_rows = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->log,size(request->log,5))
 FOR (log_ndx = 1 TO size(reply->log,5))
   SET reply->log[log_ndx].log_id = request->log[log_ndx].log_id
   SET v_tabs = 0
   SELECT INTO "nl:"
    lt.table_name, lt.purge_flag, lt.num_rows
    FROM dm_purge_job_log_tab lt
    WHERE (lt.log_id=request->log[log_ndx].log_id)
    DETAIL
     v_tabs = (v_tabs+ 1), stat = alterlist(reply->log[log_ndx].tab,v_tabs), reply->log[log_ndx].tab[
     v_tabs].table_name = lt.table_name,
     reply->log[log_ndx].tab[v_tabs].purge_flag = lt.purge_flag, reply->log[log_ndx].tab[v_tabs].
     num_rows = lt.num_rows
    WITH nocounter
   ;end select
 ENDFOR
 SET reply->status_data.status = "S"
END GO
