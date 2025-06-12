CREATE PROGRAM br_get_sol_step:dba
 FREE SET reply
 RECORD reply(
   1 sol_list[*]
     2 sol_mean = vc
     2 sol_disp = vc
     2 slist[*]
       3 step_mean = vc
       3 step_disp = vc
       3 step_type = vc
       3 sequence = i2
       3 est_min_to_complete = i2
       3 step_cat_mean = vc
       3 step_cat_disp = vc
       3 dlist[*]
         4 dep_step_mean = vc
         4 dep_step_disp = vc
   1 step_list[*]
     2 step_mean = vc
     2 step_disp = vc
     2 step_type = vc
     2 step_cat_mean = vc
     2 step_cat_disp = vc
     2 est_min_to_complete = i4
     2 deplist[*]
       3 dep_step_mean = vc
       3 dep_step_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET cnt = 0
 SET reply->status_data.status = "F"
 IF ((request->get_sol_ind=0)
  AND (request->get_step_ind=0))
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "BR_GET_SOL_STEP"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "All get indicators set to zero, invalid script call."
  GO TO exit_script
 ENDIF
 IF ((request->get_sol_ind=1))
  SELECT INTO "nl:"
   FROM br_solution bs,
    br_solution_step bss,
    br_step bstep,
    br_step_dep bsd,
    br_step bstep2
   PLAN (bs)
    JOIN (bss
    WHERE bss.solution_mean=bs.solution_mean)
    JOIN (bstep
    WHERE bstep.step_mean=bss.step_mean)
    JOIN (bsd
    WHERE bsd.step_mean=outerjoin(bstep.step_mean))
    JOIN (bstep2
    WHERE bstep2.step_mean=outerjoin(bsd.dep_step_mean))
   ORDER BY bs.solution_disp, bss.sequence
   HEAD REPORT
    cnt = 0
   HEAD bs.solution_disp
    cnt = (cnt+ 1), stat = alterlist(reply->sol_list,cnt), reply->sol_list[cnt].sol_mean = bs
    .solution_mean,
    reply->sol_list[cnt].sol_disp = bs.solution_disp, scnt = 0
   HEAD bss.step_mean
    scnt = (scnt+ 1), stat = alterlist(reply->sol_list[cnt].slist,scnt), reply->sol_list[cnt].slist[
    scnt].step_mean = bss.step_mean,
    reply->sol_list[cnt].slist[scnt].sequence = bss.sequence, reply->sol_list[cnt].slist[scnt].
    step_disp = bstep.step_disp, reply->sol_list[cnt].slist[scnt].step_type = bstep.step_type,
    reply->sol_list[cnt].slist[scnt].step_cat_mean = bstep.step_cat_mean, reply->sol_list[cnt].slist[
    scnt].step_cat_disp = bstep.step_cat_disp, reply->sol_list[cnt].slist[scnt].est_min_to_complete
     = bstep.est_min_to_complete,
    dcnt = 0
   DETAIL
    IF (bstep2.step_mean > " ")
     dcnt = (dcnt+ 1), stat = alterlist(reply->sol_list[cnt].slist[scnt].dlist,dcnt), reply->
     sol_list[cnt].slist[scnt].dlist[dcnt].dep_step_disp = bstep2.step_disp,
     reply->sol_list[cnt].slist[scnt].dlist[dcnt].dep_step_disp = bstep2.step_disp
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->get_step_ind=1))
  SELECT INTO "nl:"
   FROM br_step bs,
    br_step_dep bsd,
    br_step bs2
   PLAN (bs)
    JOIN (bsd
    WHERE bsd.step_mean=outerjoin(bs.step_mean))
    JOIN (bs2
    WHERE bs2.step_mean=outerjoin(bsd.dep_step_mean))
   ORDER BY bs.step_cat_disp, bs.step_disp
   HEAD REPORT
    cnt = 0
   HEAD bs.step_disp
    cnt = (cnt+ 1), stat = alterlist(reply->step_list,cnt), reply->step_list[cnt].step_mean = bs
    .step_mean,
    reply->step_list[cnt].step_disp = bs.step_disp, reply->step_list[cnt].step_type = bs.step_type,
    reply->step_list[cnt].step_cat_mean = bs.step_cat_mean,
    reply->step_list[cnt].step_cat_disp = bs.step_cat_disp, dcnt = 0
   DETAIL
    IF (bs2.step_mean > " ")
     dcnt = (dcnt+ 1), stat = alterlist(reply->step_list[cnt].deplist,dcnt), reply->step_list[cnt].
     deplist[dcnt].dep_step_mean = bs2.step_mean,
     reply->step_list[cnt].deplist[dcnt].dep_step_disp = bs2.step_disp
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
