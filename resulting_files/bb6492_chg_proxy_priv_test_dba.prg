CREATE PROGRAM bb6492_chg_proxy_priv_test:dba
 FREE SET request
 FREE SET reply
 FREE SET temp
 FREE SET temp_add
 SET trace = recpersist
 RECORD request(
   1 prsnl_id = f8
   1 qual[*]
     2 privilege_cd = f8
     2 privilege_id = f8
     2 add_qual[*]
       3 parent_entity_id = f8
       3 parent_entity_name = vc
       3 proxy_beg_dt_tm = dq8
       3 proxy_end_dt_tm = dq8
     2 updt_qual[*]
       3 parent_entity_id = f8
       3 parent_entity_name = vc
       3 proxy_beg_dt_tm = dq8
       3 proxy_end_dt_tm = dq8
     2 del_qual[*]
       3 parent_entity_id = f8
       3 parent_entity_name = vc
 )
 SET stat = alterlist(request->qual,2)
 SET stat = alterlist(request->qual[1].add_qual,2)
 SET stat = alterlist(request->qual[1].updt_qual,1)
 SET stat = alterlist(request->qual[1].del_qual,1)
 SET stat = alterlist(request->qual[2].add_qual,1)
 SET stat = alterlist(request->qual[2].updt_qual,2)
 SET stat = alterlist(request->qual[2].del_qual,0)
 SET request->prsnl_id =  $1
 SET request->qual[1].privilege_cd =  $2
 SET request->qual[1].privilege_id = 0
 SET request->qual[1].add_qual[1].parent_entity_id =  $3
 SET request->qual[1].add_qual[1].parent_entity_name = "PRSNL"
 SET request->qual[1].add_qual[1].proxy_beg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET request->qual[1].add_qual[1].proxy_end_dt_tm = cnvtdatetime("26-MAY-2002 00:00:00.00")
 SET request->qual[1].add_qual[2].parent_entity_id =  $4
 SET request->qual[1].add_qual[2].parent_entity_name = "PRSNL"
 SET request->qual[1].add_qual[2].proxy_beg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET request->qual[1].add_qual[2].proxy_end_dt_tm = cnvtdatetime("26-MAY-2002 00:00:00.00")
 SET request->qual[1].updt_qual[1].parent_entity_id =  $3
 SET request->qual[1].updt_qual[1].parent_entity_name = "PRSNL"
 SET request->qual[1].updt_qual[1].proxy_beg_dt_tm = cnvtdatetime("31-MAY-2002 00:00:00.00")
 SET request->qual[1].updt_qual[1].proxy_end_dt_tm = cnvtdatetime("31-JUL-2002 00:00:00.00")
 SET request->qual[1].del_qual[1].parent_entity_id =  $4
 SET request->qual[1].del_qual[1].parent_entity_name = "PRSNL"
 SET request->qual[2].privilege_cd =  $5
 SET request->qual[2].privilege_id =  $6
 SET request->qual[2].add_qual[1].parent_entity_id =  $7
 SET request->qual[2].add_qual[1].parent_entity_name = "PRSNL"
 SET request->qual[2].add_qual[1].proxy_beg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET request->qual[2].add_qual[1].proxy_end_dt_tm = cnvtdatetime("05-NOV-2003 00:00:00.00")
 SET request->qual[2].updt_qual[1].parent_entity_id =  $8
 SET request->qual[2].updt_qual[1].parent_entity_name = "PRSNL"
 SET request->qual[2].updt_qual[1].proxy_beg_dt_tm = cnvtdatetime("26-MAY-2002 00:00:00.00")
 SET request->qual[2].updt_qual[1].proxy_end_dt_tm = cnvtdatetime("12-APR-2010 00:00:00.00")
 SET request->qual[2].updt_qual[2].parent_entity_id =  $9
 SET request->qual[2].updt_qual[2].parent_entity_name = "PRSNL"
 SET request->qual[2].updt_qual[2].proxy_beg_dt_tm = cnvtdatetime("27-APR-2002 00:00:00.00")
 SET request->qual[2].updt_qual[2].proxy_end_dt_tm = cnvtdatetime("27-APR-2002 22:00:00.00")
 EXECUTE aps_chg_proxy_privileges
 CALL echorecord(reply)
END GO
