CREATE PROGRAM bed_get_def_sched_personnel:dba
 FREE SET reply
 RECORD reply(
   1 personnel[*]
     2 person_id = f8
     2 person_name = vc
     2 position_code_value = f8
     2 position_display = vc
   1 too_many_results_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 FREE SET sch_get_person_list_req
 RECORD sch_get_person_list_req(
   1 name = vc
   1 max_rec = i4
 )
 FREE SET sch_get_person_list_rep
 RECORD sch_get_person_list_rep(
   1 qual_cnt = i4
   1 qual[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 prsnl_position_cd = f8
     2 prsnl_position_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp
 RECORD temp(
   1 resources[*]
     2 person_id = f8
     2 person_name = vc
     2 position_code_value = f8
     2 position_display = vc
     2 username = vc
     2 first_name = vc
     2 last_name = vc
     2 physician_ind = i2
 )
 IF ((request->search_string=null))
  SET request->search_string = " "
 ENDIF
 IF ((request->search_type_flag=null))
  SET request->search_type_flag = "S"
 ENDIF
 DECLARE search_string = vc
 IF ((request->search_type_flag="S"))
  SET search_string = build('"',trim(cnvtupper(request->search_string)),'*"')
 ELSEIF ((request->search_type_flag="C"))
  SET search_string = build('"*',trim(cnvtupper(request->search_string)),'*"')
 ENDIF
 DECLARE prsnl_parse = vc
 SET prsnl_parse = build2("cnvtupper(p.name_full_formatted) = ",search_string)
 SET tcnt = 0
 SET rcnt = 0
 SET sch_get_person_list_req->max_rec = 0
 SET sch_get_person_list_req->name = " "
 EXECUTE sch_get_person_list  WITH replace("REQUEST",sch_get_person_list_req), replace("REPLY",
  sch_get_person_list_rep)
 IF ((sch_get_person_list_rep->qual_cnt > 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(sch_get_person_list_rep->qual_cnt)),
    prsnl p,
    code_value cv,
    sch_resource sr
   PLAN (d)
    JOIN (p
    WHERE parser(prsnl_parse)
     AND (p.person_id=sch_get_person_list_rep->qual[d.seq].person_id)
     AND p.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=outerjoin(p.position_cd)
     AND cv.active_ind=outerjoin(1))
    JOIN (sr
    WHERE sr.person_id=outerjoin(p.person_id)
     AND sr.active_ind=outerjoin(1))
   DETAIL
    IF (sr.resource_cd=0)
     tcnt = (tcnt+ 1), stat = alterlist(temp->resources,tcnt), temp->resources[tcnt].person_id = p
     .person_id,
     temp->resources[tcnt].person_name = p.name_full_formatted, temp->resources[tcnt].
     position_code_value = cv.code_value, temp->resources[tcnt].position_display = cv.display,
     temp->resources[tcnt].username = p.username, temp->resources[tcnt].first_name = p.name_first,
     temp->resources[tcnt].last_name = p.name_last,
     temp->resources[tcnt].physician_ind = p.physician_ind
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (tcnt > 0)
  DECLARE search_username = vc
  DECLARE search_first_name = vc
  DECLARE search_last_name = vc
  DECLARE username_size = i4
  DECLARE first_name_size = i4
  DECLARE last_name_size = i4
  IF ((request->username > " "))
   SET username_size = size(request->username,1)
  ENDIF
  IF ((request->first_name > " "))
   SET first_name_size = size(request->first_name,1)
  ENDIF
  IF ((request->last_name > " "))
   SET last_name_size = size(request->last_name,1)
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tcnt))
   PLAN (d)
   DETAIL
    move_ind = 1
    IF ((request->username > " "))
     search_username = cnvtupper(temp->resources[d.seq].username)
    ENDIF
    IF ((request->first_name > " "))
     search_first_name = cnvtupper(temp->resources[d.seq].first_name)
    ENDIF
    IF ((request->last_name > " "))
     search_last_name = cnvtupper(temp->resources[d.seq].last_name)
    ENDIF
    IF ((((request->username > " ")
     AND substring(1,username_size,search_username) != cnvtupper(request->username)) OR ((((request->
    first_name > " ")
     AND substring(1,first_name_size,search_first_name) != cnvtupper(request->first_name)) OR ((((
    request->last_name > " ")
     AND substring(1,last_name_size,search_last_name) != cnvtupper(request->last_name)) OR ((((
    request->position_code_value > 0)
     AND (temp->resources[d.seq].position_code_value != request->position_code_value)) OR ((request->
    physicians_only_ind=1)
     AND (temp->resources[d.seq].physician_ind != 1))) )) )) )) )
     move_ind = 0
    ENDIF
    IF (move_ind=1)
     rcnt = (rcnt+ 1), stat = alterlist(reply->personnel,rcnt), reply->personnel[rcnt].person_id =
     temp->resources[d.seq].person_id,
     reply->personnel[rcnt].person_name = temp->resources[d.seq].person_name, reply->personnel[rcnt].
     position_code_value = temp->resources[d.seq].position_code_value, reply->personnel[rcnt].
     position_display = temp->resources[d.seq].position_display
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF ((request->max_reply > 0)
  AND (rcnt > request->max_reply))
  SET stat = alterlist(reply->personnel,0)
  SET reply->too_many_results_ind = 1
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
