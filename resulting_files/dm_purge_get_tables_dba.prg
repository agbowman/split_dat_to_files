CREATE PROGRAM dm_purge_get_tables:dba
 FREE SET reply
 RECORD reply(
   1 data[*]
     2 table_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET v_tab_cnt = 0
 SELECT INTO "nl:"
  ut.table_name
  FROM user_tables ut
  WHERE ut.table_name=value(concat(cnvtupper(request->table_name),"*"))
  DETAIL
   v_tab_cnt = (v_tab_cnt+ 1)
   IF (mod(v_tab_cnt,10)=1)
    stat = alterlist(reply->data,(v_tab_cnt+ 9))
   ENDIF
   reply->data[v_tab_cnt].table_name = ut.table_name
  FOOT REPORT
   stat = alterlist(reply->data,v_tab_cnt)
  WITH nocounter
 ;end select
 IF (v_tab_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
