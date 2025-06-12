CREATE PROGRAM dcp_get_ord_tasks:dba
 DECLARE program_version = vc WITH private, constant("009")
 SET count1 = 0
 SET count2 = 0
 SET e_super_parent = 4
 SET super_parent_exist_flag = 0
 SET reply->status_data.status = "F"
 SET nbr_to_get = cnvtint(size(request->order_list,5))
 IF (nbr_to_get=0)
  GO TO exit_script
 ENDIF
 DECLARE response = f8
 SET iret = uar_get_meaning_by_codeset(6026,nullterm("RESPONSE"),1,response)
 SELECT INTO "nl:"
  ta.order_id, o.order_id, ta.updt_id
  FROM (dummyt d  WITH seq = value(nbr_to_get)),
   task_activity ta,
   orders o,
   prsnl p
  PLAN (d)
   JOIN (ta
   WHERE (ta.order_id=request->order_list[d.seq].order_id)
    AND ta.active_ind=1
    AND ta.task_type_cd != response)
   JOIN (o
   WHERE ta.order_id=o.order_id
    AND o.active_ind=1)
   JOIN (p
   WHERE p.person_id=ta.updt_id)
  ORDER BY ta.order_id
  HEAD REPORT
   count1 = 0
  HEAD ta.order_id
   count2 = 0, count1 += 1
   IF (count1 > size(reply->get_list,5))
    stat = alterlist(reply->get_list,(count1+ 10))
   ENDIF
   reply->get_list[count1].order_id = ta.order_id, reply->get_list[count1].updt_cnt = o.updt_cnt,
   reply->get_list[count1].order_status_cd = o.order_status_cd
   IF (band(o.cs_flag,e_super_parent))
    reply->get_list[count1].super_parent_flag = 1, super_parent_exist_flag = 1
   ELSE
    reply->get_list[count1].super_parent_flag = 0
   ENDIF
  DETAIL
   count2 += 1
   IF (count2 > size(reply->get_list[count1].status_list,5))
    stat = alterlist(reply->get_list[count1].status_list,(count2+ 10))
   ENDIF
   reply->get_list[count1].status_list[count2].task_status_cd = ta.task_status_cd, reply->get_list[
   count1].status_list[count2].reference_task_id = ta.reference_task_id, reply->get_list[count1].
   status_list[count2].task_id = ta.task_id,
   reply->get_list[count1].status_list[count2].updt_id = ta.updt_id, reply->get_list[count1].
   status_list[count2].name_full_formatted = p.name_full_formatted, reply->get_list[count1].
   status_list[count2].updt_cnt = ta.updt_cnt,
   reply->get_list[count1].status_list[count2].task_dt_tm = ta.task_dt_tm, reply->get_list[count1].
   status_list[count2].task_priority_cd = ta.task_priority_cd
  FOOT  ta.order_id
   stat = alterlist(reply->get_list[count1].status_list,count2)
  FOOT REPORT
   stat = alterlist(reply->get_list,count1)
  WITH check
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "P"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET reply_cnt = cnvtint(size(reply->get_list,5))
 IF (super_parent_exist_flag)
  IF (reply_cnt > 0)
   SELECT INTO "nl:"
    o.cs_order_id, o.updt_cnt
    FROM (dummyt d  WITH seq = value(reply_cnt)),
     orders o
    PLAN (d
     WHERE (reply->get_list[d.seq].super_parent_flag=1))
     JOIN (o
     WHERE (o.cs_order_id=reply->get_list[d.seq].order_id)
      AND o.active_ind=1)
    ORDER BY o.cs_order_id
    HEAD o.cs_order_id
     count2 = 0
    DETAIL
     count2 += 1
     IF (count2 > size(reply->get_list[d.seq].super_children_list,5))
      stat = alterlist(reply->get_list[d.seq].super_children_list,(count2+ 5))
     ENDIF
     reply->get_list[d.seq].super_children_list[count2].child_order_id = o.order_id, reply->get_list[
     d.seq].super_children_list[count2].child_updt_cnt = o.updt_cnt
    FOOT  o.cs_order_id
     stat = alterlist(reply->get_list[d.seq].super_children_list,count2)
    WITH check
   ;end select
  ENDIF
 ENDIF
 FOR (x = 1 TO count1)
   CALL echo(build("order_id =",reply->get_list[x].order_id,"super_parent_flag= ",reply->get_list[x].
     super_parent_flag))
   SET count2 = size(reply->get_list[x].status_list,5)
   CALL echo(build("order_status_cd= ",reply->get_list[x].order_status_cd))
   CALL echo(build("x =",x,"  StatusCount=",count2))
   FOR (y = 1 TO count2)
     CALL echo(build("task_status_cd=",reply->get_list[x].status_list[y].task_status_cd))
   ENDFOR
   SET count2 = size(reply->get_list[x].super_children_list,5)
   CALL echo(build("x =",x,"  ChildrenCount=",count2))
   FOR (y = 1 TO count2)
     CALL echo(build("child_order_id=",reply->get_list[x].super_children_list[y].child_order_id))
   ENDFOR
 ENDFOR
 CALL echo(build("curqual =",curqual))
 CALL echo(build("status =",reply->status_data.status))
#exit_script
END GO
