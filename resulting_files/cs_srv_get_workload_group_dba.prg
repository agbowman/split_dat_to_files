CREATE PROGRAM cs_srv_get_workload_group:dba
 CALL echo(concat("CS_SRV_GET_WORKLOAD_GROUP - ",format(curdate,"MMM DD, YYYY;;D"),format(curtime3,
    " - HH:MM:SS;;S")))
 DECLARE cnt = i2
 SET cnt = 0
 SELECT INTO "nl:"
  w.workload_code_id, w.book_cd, w.chapter_cd,
  w.section_cd
  FROM workload_group w
  WHERE w.workload_code_id > 0
   AND w.active_ind=1
  DETAIL
   cnt += 1, stat = alterlist(reply->workload_group,cnt), reply->workload_group[cnt].workload_code_id
    = w.workload_code_id,
   reply->workload_group[cnt].book_cd = w.book_cd, reply->workload_group[cnt].chapter_cd = w
   .chapter_cd, reply->workload_group[cnt].section_cd = w.section_cd
  WITH nocounter
 ;end select
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(reply)
 ENDIF
END GO
