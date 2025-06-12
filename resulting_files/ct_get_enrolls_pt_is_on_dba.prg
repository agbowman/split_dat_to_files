CREATE PROGRAM ct_get_enrolls_pt_is_on:dba
 RECORD reply(
   1 enrolls[*]
     2 protalias = vc
     2 dateonstudy = dq8
     2 dateoffstudy = dq8
     2 dateontherapy = dq8
     2 dateofftherapy = dq8
     2 protmasterid = f8
     2 regid = f8
     2 prottype_cd = f8
     2 prottype_disp = vc
     2 prottype_desc = vc
     2 prottype_mean = c12
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
  p_pr_r.on_study_dt_tm, p_pr_r.off_study_dt_tm, p_pr_r.tx_start_dt_tm,
  p_pr_r.tx_completion_dt_tm, pr_am.prot_amendment_id, pr_m.primary_mnemonic
  FROM prot_master pr_m,
   pt_prot_reg p_pr_r
  PLAN (p_pr_r
   WHERE (p_pr_r.person_id=request->personid)
    AND p_pr_r.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (pr_m
   WHERE pr_m.prot_master_id=p_pr_r.prot_master_id)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    new = (cnt+ 10), stat = alterlist(reply->enrolls,new)
   ENDIF
   reply->enrolls[cnt].protalias = pr_m.primary_mnemonic, reply->enrolls[cnt].dateonstudy = p_pr_r
   .on_study_dt_tm, reply->enrolls[cnt].dateoffstudy = p_pr_r.off_study_dt_tm,
   reply->enrolls[cnt].dateontherapy = p_pr_r.tx_start_dt_tm, reply->enrolls[cnt].dateofftherapy =
   p_pr_r.tx_completion_dt_tm, reply->enrolls[cnt].protmasterid = pr_am.prot_master_id,
   reply->enrolls[cnt].regid = p_pr_r.reg_id, reply->enrolls[cnt].prottype_cd = pr_m.prot_type_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->enrolls,cnt)
 SET reply->status_data.status = "S"
 GO TO noecho
 CALL echo("Reply->status_data->status =",0)
 CALL echo(reply->status_data.status,1)
 CALL echo(build("cnt = ",cnt))
 CALL echo("--------------------------------------------------------------")
 FOR (x = 1 TO cnt)
   CALL echo("Value of x = ",0)
   CALL echo(x,1)
   CALL echo("Reply->Enrolls[x]->DateOnStudy = ",0)
   CALL echo(reply->enrolls[x].dateonstudy,1)
   CALL echo("Reply->Enrolls[x]->DateOffStudy = ",0)
   CALL echo(reply->enrolls[x].dateoffstudy,1)
   CALL echo("Reply->Enrolls[x]->DateOnTherapy = ",0)
   CALL echo(reply->enrolls[x].dateontherapy,1)
   CALL echo("Reply->Enrolls[x]->DateOffTherapy = ",0)
   CALL echo(reply->enrolls[x].dateofftherapy,1)
   CALL echo("Reply->Enrolls[x]->ProtAlias = ",0)
   CALL echo(reply->enrolls[x].protalias,1)
   CALL echo("Reply->Enrolls[x]->ProtMasterID = ",0)
   CALL echo(reply->enrolls[x].protmasterid,1)
   CALL echo(build("Reply->Enrolls[",x,"]->RegID = ",reply->enrolls[x].regid))
   CALL echo(build("Reply->Enrolls[",x,"]->ProtType_CD = ",reply->enrolls[x].prottype_cd))
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
