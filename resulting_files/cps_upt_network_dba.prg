CREATE PROGRAM cps_upt_network:dba
 SET false = 0
 SET true = 1
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET replace_error = 6
 SET delete_error = 7
 SET undelete_error = 8
 SET remove_error = 9
 SET attribute_error = 10
 SET lock_error = 11
 SET none_found = 12
 SET select_error = 13
 SET failed = false
 SET table_name = fillstring(50," ")
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 network_qual = i2
    1 network[10]
      2 network_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->network_qual
  SET reply->network_qual = request->network_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "NETWORK"
 CALL upt_network(action_begin,action_end)
 IF (failed != false)
  GO TO check_error
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF replace_error:
    SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   OF undelete_error:
    SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
   OF remove_error:
    SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
 GO TO end_program
 SUBROUTINE upt_network(upt_begin,upt_end)
   FOR (x = upt_begin TO upt_end)
     SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
     SET count1 = 0
     SET active_status_code = 0
     SELECT INTO "nl:"
      n.*
      FROM network n
      WHERE (n.network_id=request->network[x].network_id)
      HEAD REPORT
       count1 = 0
      DETAIL
       count1 = (count1+ 1)
       IF ((request->network[x].active_status_cd > 0))
        active_status_code = n.active_status_cd
       ENDIF
      WITH forupdate(n)
     ;end select
     IF (curqual=0)
      SET failed = lock_error
      RETURN
     ENDIF
     UPDATE  FROM network n
      SET n.carrier_id = evaluate(request->network[x].carrier_id,0.0,n.carrier_id,- (1.0),0.0,
        request->network[x].carrier_id), n.network_name = evaluate(request->network[x].network_name,
        " ",n.network_name,'""',null,
        request->network[x].network_name), n.network_description = evaluate(request->network[x].
        network_description," ",n.network_description,'""',null,
        request->network[x].network_description),
       n.beg_effective_dt_tm = evaluate(request->network[x].beg_effective_dt_tm,0.0,n
        .beg_effective_dt_tm,blank_date,null,
        cnvtdatetime(request->network[x].beg_effective_dt_tm)), n.end_effective_dt_tm = evaluate(
        request->network[x].end_effective_dt_tm,0.0,n.end_effective_dt_tm,blank_date,null,
        cnvtdatetime(request->network[x].end_effective_dt_tm)), n.active_ind = nullcheck(n.active_ind,
        request->network[x].active_ind,
        IF ((request->network[x].active_ind_ind=false)) 0
        ELSE 1
        ENDIF
        ),
       n.active_status_cd = nullcheck(n.active_status_cd,request->network[x].active_status_cd,
        IF ((request->network[x].active_status_cd=active_status_code)) 0
        ELSE 1
        ENDIF
        ), n.active_status_prsnl_id = nullcheck(n.active_status_prsnl_id,reqinfo->updt_id,
        IF ((request->network[x].active_status_cd=active_status_code)) 0
        ELSE 1
        ENDIF
        ), n.active_status_dt_tm = nullcheck(n.active_status_dt_tm,cnvtdatetime(curdate,curtime3),
        IF ((request->network[x].active_status_cd=active_status_code)) 0
        ELSE 1
        ENDIF
        ),
       n.updt_cnt = (n.updt_cnt+ 1), n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id =
       reqinfo->updt_id,
       n.updt_applctx = reqinfo->updt_applctx, n.updt_task = reqinfo->updt_task
      WHERE (n.network_id=request->network[x].network_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = update_error
      RETURN
     ELSE
      SET reply->network[x].network_id = request->network[x].network_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
