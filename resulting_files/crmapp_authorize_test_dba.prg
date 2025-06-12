CREATE PROGRAM crmapp_authorize_test:dba
 PAINT
 FREE RECORD displayinfo
 RECORD displayinfo(
   1 fname = c40
   1 aname = c45
   1 ulist = c1
   1 position = c40
   1 pcode = f8
   1 personid = f8
   1 appgroupcd = f8
   1 common_ind = i4
   1 log_level = i4
   1 appaccess = i4
   1 authorizedtasks[*]
     2 task_number = f8
     2 task_name = c40
     2 subordinate_ind = i4
   1 apptaskreqs[*]
     2 task_number = f8
     2 request_number = f8
     2 request_name = vc
 )
 DECLARE cline = c53
 DECLARE uname = c10
#start
 CALL clear(1,1)
 CALL video(i)
 CALL box(1,1,19,70)
 CALL box(4,4,12,60)
 CALL line(3,1,70,xhoraz)
 CALL video(l)
 CALL text(2,3,"CRM Troubleshooting - Application/Authorization Test")
 CALL text(5,5,"Application Number: ")
 CALL text(7,5,"Username: ")
 CALL text(18,60,"<PF3> Exit")
#startaccept
 SET help =
 SELECT INTO "nl:"
  a.application_number, a.description
  FROM application a
 ;end select
 CALL accept(5,25,"99999999;N")
 SET appnbr = curaccept
 CALL text(10,5,"                                          ")
 SET help = off
 SELECT INTO "nl:"
  FROM application a
  WHERE a.application_number=appnbr
   AND appnbr > 0
  DETAIL
   displayinfo->aname = a.description
   IF (a.common_application_ind=1)
    displayinfo->common_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL text(10,5,"Application Number not Found")
  GO TO startaccept
 ENDIF
 IF ((((displayinfo->common_ind=1)) OR (appnbr=5000)) )
  CALL text(10,5,"Application is Common")
  GO TO startaccept
 ENDIF
 CALL text(5,25,cnvtstring(appnbr,8,0,r))
 CALL text(6,15,displayinfo->aname)
 CALL text(10,5,cline)
 CALL accept(7,25,"#############;CU",uname)
 SET uname = curaccept
 SET user_active_ind = 0
 SELECT INTO "nl:"
  p.name_full_formatted, p.position_cd, p.person_id,
  p.log_level, c.display
  FROM prsnl p,
   code_value c
  PLAN (p
   WHERE p.username=uname)
   JOIN (c
   WHERE p.position_cd=c.code_value)
  DETAIL
   IF (p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND ((p.end_effective_dt_tm=0) OR (p.end_effective_dt_tm > cnvtdatetime(curdate,curtime)))
    AND p.active_ind=1)
    user_active_ind = 1
   ENDIF
   displayinfo->fname = p.name_full_formatted, displayinfo->position = c.display, displayinfo->pcode
    = p.position_cd,
   displayinfo->personid = p.person_id, displayinfo->log_level = p.log_level
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL text(10,5,"Username not found")
  GO TO start
 ENDIF
 IF (user_active_ind=0)
  CALL text(10,5,"User not active ")
  GO TO startaccept
 ENDIF
 CALL video(b)
 CALL text(18,5,"Working...")
 CALL video(n)
 CALL video(l)
 CALL text(7,25,uname)
 CALL text(10,5,cline)
 CALL text(8,15,displayinfo->fname)
 SELECT INTO "nl:"
  atr.task_number, trr.request_number, r.request_name
  FROM request r,
   task_request_r trr,
   application_task_r atr,
   application_task at,
   dummyt d
  PLAN (atr
   WHERE atr.application_number=appnbr)
   JOIN (at
   WHERE at.task_number=atr.task_number
    AND at.active_ind=1)
   JOIN (d)
   JOIN (trr
   WHERE trr.task_number=atr.task_number)
   JOIN (r
   WHERE r.request_number=trr.request_number
    AND r.active_ind=1)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1)
    stat = alterlist(displayinfo->apptaskreqs,(count1+ 9))
   ENDIF
   displayinfo->apptaskreqs[count1].task_number = atr.task_number, displayinfo->apptaskreqs[count1].
   request_number = trr.request_number, displayinfo->apptaskreqs[count1].request_name = r
   .request_name
  FOOT REPORT
   stat = alterlist(displayinfo->apptaskreqs,count1)
  WITH nocounter, outerjoin = d
 ;end select
 SELECT DISTINCT INTO "nl:"
  ta.task_number, at.description, at.subordinate_task_ind
  FROM task_access ta,
   application_task at,
   application_group ag,
   application_task_r atr
  PLAN (atr
   WHERE atr.application_number=appnbr)
   JOIN (ta
   WHERE ta.task_number=atr.task_number)
   JOIN (ag
   WHERE (ag.position_cd=displayinfo->pcode)
    AND ag.app_group_cd=ta.app_group_cd
    AND ag.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ag.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (at
   WHERE at.task_number=ta.task_number
    AND at.active_ind=1)
  HEAD REPORT
   count2 = 0
  DETAIL
   count2 += 1
   IF (mod(count2,10)=1)
    stat = alterlist(displayinfo->authorizedtasks,(count2+ 9))
   ENDIF
   displayinfo->authorizedtasks[count2].task_number = ta.task_number, displayinfo->authorizedtasks[
   count2].task_name = at.description, displayinfo->authorizedtasks[count2].subordinate_ind = at
   .subordinate_task_ind
  FOOT REPORT
   stat = alterlist(displayinfo->authorizedtasks,count2)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  aa.application_number
  FROM application_access aa,
   application_group ag
  WHERE aa.application_number=appnbr
   AND (ag.position_cd=displayinfo->pcode)
   AND ag.app_group_cd=aa.app_group_cd
  DETAIL
   displayinfo->appaccess = 1
  WITH nocounter
 ;end select
 SELECT
  d.*
  FROM dual d
  HEAD REPORT
   lbound = 0
  DETAIL
   row + 1, col 0, "Person id: ",
   col 23, displayinfo->personid, col 45,
   uname, displayinfo->fname, row + 1,
   col 0, "application number: ", col 23,
   appnbr, col 45, displayinfo->aname,
   row + 1, col 0, "position code: ",
   col 23, displayinfo->pcode, col 45,
   displayinfo->position, row + 1, col 0,
   "Application Access: "
   IF (displayinfo->appaccess)
    col 31, "yes"
   ELSE
    col 32, "no"
   ENDIF
   row + 1, col 0, "log level: ",
   col 23, displayinfo->log_level, row + 2,
   lbound = size(displayinfo->authorizedtasks,5), col 0, "Task Number",
   col 15, "Subordinate Task Ind", row + 1
   FOR (x = 1 TO lbound)
     col 0, displayinfo->authorizedtasks[x].task_number, col 15,
     displayinfo->authorizedtasks[x].subordinate_ind, row + 1
   ENDFOR
   row + 3, col 0, "Application Task (All associated with application)",
   row + 1, col 0, "Task Number",
   col 15, "Request Number", col 30,
   "Request Name", row + 1, lbound = size(displayinfo->apptaskreqs,5)
   FOR (x = 1 TO lbound)
     col 0, displayinfo->apptaskreqs[x].task_number, col 15,
     displayinfo->apptaskreqs[x].request_number, col 30, displayinfo->apptaskreqs[x].request_name,
     row + 1
   ENDFOR
  WITH nocounter
 ;end select
 FREE DEFINE displayinfo
 CALL video(n)
 GO TO start
END GO
