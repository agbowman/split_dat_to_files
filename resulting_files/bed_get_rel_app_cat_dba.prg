CREATE PROGRAM bed_get_rel_app_cat:dba
 FREE SET reply
 RECORD reply(
   1 rel_list[*]
     2 category_group = c40
     2 group_seq = i4
     2 clist[*]
       3 category_id = f8
       3 description = c40
       3 alist[*]
         4 app_grp_code_value = f8
         4 display = c40
         4 desc = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 SET reply->status_data.status = "F"
 SET reply->too_many_results_ind = 0
 SET tot_count = 0
 SET count = 0
 IF ((request->max_reply > 0))
  SET max_reply = request->max_reply
 ELSE
  SET max_reply = 10000
 ENDIF
 SET stat = alterlist(reply->rel_list,50)
 SELECT INTO "NL:"
  FROM br_app_cat_comp bacc,
   br_app_category bac,
   code_value cv500,
   br_long_text lt
  PLAN (bac
   WHERE bac.active_ind=1)
   JOIN (bacc
   WHERE bacc.category_id=outerjoin(bac.category_id))
   JOIN (cv500
   WHERE cv500.active_ind=outerjoin(1)
    AND cv500.code_set=outerjoin(500)
    AND cv500.code_value=outerjoin(bacc.application_group_cd))
   JOIN (lt
   WHERE lt.parent_entity_name=outerjoin("CODE_VALUE")
    AND lt.parent_entity_id=outerjoin(bacc.application_group_cd))
  ORDER BY bac.display_group_seq, bac.sequence, bacc.sequence,
   bac.category_id
  HEAD bac.display_group_desc
   tot_count = (tot_count+ 1), count = (count+ 1)
   IF (count > 50)
    stat = alterlist(reply->rel_list,(tot_count+ 50)), count = 1
   ENDIF
   reply->rel_list[tot_count].category_group = bac.display_group_desc, reply->rel_list[tot_count].
   group_seq = bac.display_group_seq, ctot_count = 0,
   ccount = 0, stat = alterlist(reply->rel_list[tot_count].clist,20)
  HEAD bac.category_id
   ctot_count = (ctot_count+ 1), ccount = (ccount+ 1)
   IF (ccount > 20)
    stat = alterlist(reply->rel_list[tot_count].clist,(ctot_count+ 20)), count = 1
   ENDIF
   reply->rel_list[tot_count].clist[ctot_count].description = bac.description, reply->rel_list[
   tot_count].clist[ctot_count].category_id = bac.category_id, atot_count = 0,
   acount = 0, stat = alterlist(reply->rel_list[tot_count].clist[ctot_count].alist,20)
  DETAIL
   IF (bacc.application_group_cd > 0
    AND cv500.active_ind=1)
    atot_count = (atot_count+ 1), acount = (acount+ 1)
    IF (acount > 20)
     stat = alterlist(reply->rel_list[tot_count].clist[ctot_count].alist,(atot_count+ 20)), count = 1
    ENDIF
    reply->rel_list[tot_count].clist[ctot_count].alist[atot_count].app_grp_code_value = bacc
    .application_group_cd, reply->rel_list[tot_count].clist[ctot_count].alist[atot_count].display =
    cv500.display
    IF (lt.long_text > "     *")
     reply->rel_list[tot_count].clist[ctot_count].alist[atot_count].desc = lt.long_text
    ELSE
     reply->rel_list[tot_count].clist[ctot_count].alist[atot_count].desc =
     "Description not available."
    ENDIF
   ENDIF
  FOOT  bac.category_id
   stat = alterlist(reply->rel_list[tot_count].clist[ctot_count].alist,atot_count)
  FOOT  bac.display_group_desc
   stat = alterlist(reply->rel_list[tot_count].clist,ctot_count)
  WITH maxrec = value(max_reply), nocounter
 ;end select
 SELECT INTO "NL:"
  cv.display, cv.code_value
  FROM code_value cv,
   br_long_text lt
  PLAN (cv
   WHERE cv.active_ind=1
    AND cv.code_set=500
    AND  NOT ( EXISTS (
   (SELECT
    bacc.category_id
    FROM br_app_cat_comp bacc
    WHERE cv.code_value=bacc.application_group_cd))))
   JOIN (lt
   WHERE lt.parent_entity_name=outerjoin("CODE_VALUE")
    AND lt.parent_entity_id=outerjoin(cv.code_value))
  HEAD REPORT
   tot_count = (tot_count+ 1), count = (count+ 1)
   IF (count > 50)
    stat = alterlist(reply->rel_list,(tot_count+ 50)), count = 1
   ENDIF
   reply->rel_list[tot_count].category_group = "Non-Specified Category", reply->rel_list[tot_count].
   group_seq = 0, ctot_count = 0,
   ccount = 0, stat = alterlist(reply->rel_list[tot_count].clist,1), reply->rel_list[tot_count].
   clist[1].category_id = 0,
   reply->rel_list[tot_count].clist[1].description = "Non-Specified Application Groups", atot_count
    = 0, acount = 0,
   stat = alterlist(reply->rel_list[tot_count].clist[1].alist,20)
  DETAIL
   atot_count = (atot_count+ 1), acount = (acount+ 1)
   IF (acount > 20)
    stat = alterlist(reply->rel_list[tot_count].clist[1].alist,(atot_count+ 20)), count = 1
   ENDIF
   reply->rel_list[tot_count].clist[1].alist[atot_count].app_grp_code_value = cv.code_value, reply->
   rel_list[tot_count].clist[1].alist[atot_count].display = cv.display
   IF (lt.long_text > "     *")
    reply->rel_list[tot_count].clist[1].alist[atot_count].desc = lt.long_text
   ELSE
    reply->rel_list[tot_count].clist[1].alist[atot_count].desc = "Description not available."
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->rel_list[tot_count].clist[1].alist,atot_count)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->rel_list,tot_count)
#enditnow
 IF (tot_count >= max_reply)
  SET stat = alterlist(reply->rel_list,0)
  SET reply->too_many_results_ind = 1
  SET reply->status_data.status = "S"
 ELSEIF (tot_count > 0)
  SET reply->status_data.status = "S"
 ELSEIF (tot_count=0)
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
