CREATE PROGRAM ct_get_enroll_details:dba
 RECORD reply(
   1 amendments[*]
     2 assign_start_dt_tm = dq8
     2 assign_end_dt_tm = dq8
     2 protamendmentid = f8
     2 amendmentdesc = vc
     2 amendmentnbr = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 debug[*]
     2 str = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET new = 0
 SET x = 0
 SELECT INTO "NL:"
  cpaa.*, pr_am.prot_amendment_id, pr_am.amendment_description,
  pr_am.amendment_nbr
  FROM ct_pt_amd_assignment cpaa,
   prot_amendment pr_am
  PLAN (cpaa
   WHERE (cpaa.reg_id=request->regid)
    AND cpaa.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00"))
   JOIN (pr_am
   WHERE cpaa.prot_amendment_id=pr_am.prot_amendment_id)
  ORDER BY pr_am.amendment_nbr
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    new = (cnt+ 10), stat = alterlist(reply->amendments,new)
   ENDIF
   reply->amendments[cnt].assign_start_dt_tm = cpaa.assign_start_dt_tm, reply->amendments[cnt].
   assign_end_dt_tm = cpaa.assign_end_dt_tm, reply->amendments[cnt].protamendmentid = pr_am
   .prot_amendment_id,
   reply->amendments[cnt].amendmentdesc = pr_am.amendment_description, reply->amendments[cnt].
   amendmentnbr = pr_am.amendment_nbr
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->amendments,cnt)
 SET reply->status_data.status = "S"
 GO TO noecho
 CALL echo("Reply->status_data->status =",0)
 CALL echo(reply->status_data.status,1)
 CALL echo("--------------------------------------------------------------")
 FOR (x = 1 TO cnt)
   CALL echo(build("Reply->amendments[",x,"]->assign_start_dt_tm =  ",reply->amendments[x].
     assign_start_dt_tm))
   CALL echo(build("Reply->amendments[",x,"]->assign_end_dt_tm =  ",reply->amendments[x].
     assign_end_dt_tm))
   CALL echo(build("Reply->amendments[",x,"]->ProtAmendmentID =  ",reply->amendments[x].
     protamendmentid))
   CALL echo(build("Reply->amendments[",x,"]->AmendmentDesc =  ",reply->amendments[x].amendmentdesc))
   CALL echo(build("Reply->amendments[",x,"]->AmendmentNbr =  ",reply->amendments[x].amendmentnbr))
   CALL echo("--------------------------------------------------------------")
 ENDFOR
#noecho
 SET debug_code_stemp = fillstring(999," ")
 SET debug_code_ecode = 1
 SET debug_code_cntd = size(reply->debug,5)
 WHILE (debug_code_ecode != 0)
  SET debug_code_ecode = error(debug_code_stemp,0)
  IF (debug_code_ecode != 0)
   SET debug_code_cntd = (debug_code_cntd+ 1)
   SET stat = alterlist(reply->debug,debug_code_cntd)
   SET reply->debug[debug_code_cntd].str = debug_code_stemp
  ENDIF
 ENDWHILE
END GO
