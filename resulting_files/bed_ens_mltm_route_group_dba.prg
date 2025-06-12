CREATE PROGRAM bed_ens_mltm_route_group:dba
 RECORD requestin(
   1 list_0[*]
     2 current_route = vc
     2 group_route = vc
     2 active_ind = vc
 )
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET sub_cnt = 0
 SET list_cnt = 0
 SET tot_cnt = 0
 SET cnt = size(request->route_grouper,5)
 SET stat = alterlist(requestin->list_0,20)
 FOR (x = 1 TO cnt)
  SET sub_cnt = size(request->route_grouper[x].routes,5)
  FOR (z = 1 TO sub_cnt)
    IF ((((request->route_grouper[x].routes[z].action_flag=3)) OR ((((request->route_grouper[x].
    routes[z].action_flag=1)) OR ((request->route_grouper[x].routes[z].action_flag=0))) )) )
     SET tot_cnt = (tot_cnt+ 1)
     SET list_cnt = (list_cnt+ 1)
     IF (list_cnt > 20)
      SET stat = alterlist(requestin->list_0,(tot_cnt+ 20))
      SET list_cnt = 1
     ENDIF
     SET requestin->list_0[tot_cnt].current_route = request->route_grouper[x].display
     SET requestin->list_0[tot_cnt].group_route = request->route_grouper[x].routes[z].display
     IF ((request->route_grouper[x].routes[z].action_flag=3))
      SET requestin->list_0[tot_cnt].active_ind = "0"
     ELSEIF ((((request->route_grouper[x].routes[z].action_flag=1)) OR ((request->route_grouper[x].
     routes[z].action_flag=0))) )
      SET requestin->list_0[tot_cnt].active_ind = "1"
     ENDIF
    ENDIF
  ENDFOR
 ENDFOR
 SET stat = alterlist(requestin->list_0,tot_cnt)
 SET trace = recpersist
 EXECUTE kia_add_route_premise  WITH replace("REQUEST",requestin), replace("REPLY",replyin)
 IF ((replyin->status_data.status="F"))
  SET error_flag = "Y"
  SET reply->error_msg = "Unable to group Multum routes to Millennium routes"
  GO TO exit_script
 ENDIF
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
