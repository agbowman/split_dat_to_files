CREATE PROGRAM ct_get_prtcls_pt_is_on:dba
 RECORD reply(
   1 amendments[*]
     2 protalias = vc
     2 dateonstudy = dq8
     2 dateoffstudy = dq8
     2 dateontherapy = dq8
     2 dateofftherapy = dq8
     2 protmasterid = f8
     2 protamendmentid = f8
     2 amendmentdesc = vc
     2 amendmentnbr = f8
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
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET new = 0
 SET x = 0
 SELECT INTO "NL:"
  p_pr_r.on_study_dt_tm, p_pr_r.off_study_dt_tm, p_pr_r.tx_start_dt_tm,
  p_pr_r.tx_completion_dt_tm, pr_am.prot_amendment_id, pr_am.amendment_description,
  pr_am.amendment_nbr, pr_am.prot_master_id, pr_m.primary_mnemonic
  FROM prot_master pr_m,
   pt_prot_reg p_pr_r,
   prot_amendment pr_am
  PLAN (p_pr_r
   WHERE (p_pr_r.person_id=request->personid)
    AND p_pr_r.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (pr_am
   WHERE p_pr_r.prot_amendment_id=pr_am.prot_amendment_id)
   JOIN (pr_m
   WHERE pr_am.prot_master_id=pr_m.prot_master_id)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    new = (cnt+ 10), stat = alterlist(reply->amendments,new)
   ENDIF
   reply->amendments[cnt].protalias = pr_m.primary_mnemonic, reply->amendments[cnt].dateonstudy =
   p_pr_r.on_study_dt_tm, reply->amendments[cnt].dateoffstudy = p_pr_r.off_study_dt_tm,
   reply->amendments[cnt].dateontherapy = p_pr_r.tx_start_dt_tm, reply->amendments[cnt].
   dateofftherapy = p_pr_r.tx_completion_dt_tm, reply->amendments[cnt].protmasterid = pr_am
   .prot_master_id,
   reply->amendments[cnt].protamendmentid = pr_am.prot_amendment_id, reply->amendments[cnt].
   amendmentdesc = pr_am.amendment_description, reply->amendments[cnt].amendmentnbr = pr_am
   .amendment_nbr,
   reply->amendments[cnt].regid = p_pr_r.reg_id, reply->amendments[cnt].prottype_cd = pr_m
   .prot_type_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->amendments,cnt)
 SET reply->status_data.status = "S"
 CALL echo("Reply->status_data->status =",0)
 CALL echo(reply->status_data.status,1)
 CALL echo(build("cnt = ",cnt))
 CALL echo("--------------------------------------------------------------")
 FOR (x = 1 TO cnt)
   CALL echo("Value of x = ",0)
   CALL echo(x,1)
   CALL echo("Reply->amendments[x]->DateOnStudy = ",0)
   CALL echo(reply->amendments[x].dateonstudy,1)
   CALL echo("Reply->amendments[x]->DateOffStudy = ",0)
   CALL echo(reply->amendments[x].dateoffstudy,1)
   CALL echo("Reply->amendments[x]->DateOnTherapy = ",0)
   CALL echo(reply->amendments[x].dateontherapy,1)
   CALL echo("Reply->amendments[x]->DateOffTherapy = ",0)
   CALL echo(reply->amendments[x].dateofftherapy,1)
   CALL echo("Reply->amendments[x]->ProtAlias = ",0)
   CALL echo(reply->amendments[x].protalias,1)
   CALL echo("Reply->amendments[x]->ProtMasterID = ",0)
   CALL echo(reply->amendments[x].protmasterid,1)
   CALL echo("Reply->amendments[x]->ProtAmendmentID = ",0)
   CALL echo(reply->amendments[x].protamendmentid,1)
   CALL echo("Reply->amendments[x]->AmendmentDesc = ",0)
   CALL echo(reply->amendments[x].amendmentdesc,1)
   CALL echo("Reply->amendments[x]->AmendmentNbr = ",0)
   CALL echo(reply->amendments[x].amendmentnbr,1)
   CALL echo(build("Reply->amendments[",x,"]->RegID = ",reply->amendments[x].regid))
   CALL echo(build("Reply->amendments[",x,"]->ProtType_CD = ",reply->amendments[x].prottype_cd))
   CALL echo("--------------------------------------------------------------")
 ENDFOR
#skipecho
END GO
