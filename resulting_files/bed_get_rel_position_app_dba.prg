CREATE PROGRAM bed_get_rel_position_app:dba
 FREE SET reply
 RECORD reply(
   1 rel_list[*]
     2 position_code_value = f8
     2 alist[*]
       3 app_grp_code_value = f8
       3 display = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_count = 0
 SET count = 0
 SET pcnt = size(request->plist,5)
 SET stat = alterlist(reply->rel_list,pcnt)
 FOR (x = 1 TO pcnt)
   SET reply->rel_list[x].position_code_value = request->plist[x].code_value
   SET stat = alterlist(reply->rel_list[x].alist,50)
   SET tot_count = 0
   SET count = 0
   SELECT INTO "NL:"
    FROM application_group ag,
     code_value cv500
    PLAN (ag
     WHERE (ag.position_cd=request->plist[x].code_value))
     JOIN (cv500
     WHERE cv500.active_ind=1
      AND cv500.code_set=500
      AND cv500.code_value=ag.app_group_cd)
    DETAIL
     tot_count = (tot_count+ 1), count = (count+ 1)
     IF (count > 50)
      stat = alterlist(reply->rel_list[x].alist,(tot_count+ 50)), count = 1
     ENDIF
     reply->rel_list[x].alist[tot_count].app_grp_code_value = ag.app_group_cd, reply->rel_list[x].
     alist[tot_count].display = cv500.display
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->rel_list[x].alist,tot_count)
 ENDFOR
 SET reply->status_data.status = "S"
#enditnow
END GO
