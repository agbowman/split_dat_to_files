CREATE PROGRAM ct_get_prtcldocs_pt_is_on:dba
 RECORD reply(
   1 amendments[*]
     2 prot_alias = vc
     2 date_on_study = dq8
     2 prot_amendment_id = f8
     2 prot_master_id = f8
     2 amendment_nbr = i4
     2 amendment_descn = vc
     2 documents[*]
       3 file_name = vc
       3 doc_type_cd = f8
       3 doc_type_cd_disp = vc
       3 doc_type_cd_mean = vc
       3 description = vc
       3 title = vc
       3 version_nbr = i4
       3 version_description = vc
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
 SET doccnt = 0
 SET prot_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=17304
   AND cv.cdf_meaning="PROTOCOL"
  DETAIL
   prot_cd = cv.code_value,
   CALL echo(build("Prot_Cd=",prot_cd))
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  p_pr_r.on_study_dt_tm, pr_am.prot_amendment_id, pr_m.primary_mnemonic,
  cd.ct_document_id, cdv.ct_document_version_id
  FROM prot_master pr_m,
   pt_prot_reg p_pr_r,
   prot_amendment pr_am,
   ct_document cd,
   ct_document_version cdv
  PLAN (p_pr_r
   WHERE (p_pr_r.person_id=request->person_id)
    AND p_pr_r.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND p_pr_r.off_study_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00"))
   JOIN (pr_am
   WHERE p_pr_r.prot_amendment_id=pr_am.prot_amendment_id)
   JOIN (pr_m
   WHERE pr_am.prot_master_id=pr_m.prot_master_id)
   JOIN (cd
   WHERE cd.prot_amendment_id=p_pr_r.prot_amendment_id
    AND cd.document_type_cd=prot_cd)
   JOIN (cdv
   WHERE cd.ct_document_id=cdv.ct_document_id
    AND cdv.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00"))
  HEAD p_pr_r.pt_prot_reg_id
   cnt = (cnt+ 1), stat = alterlist(reply->amendments,cnt), reply->amendments[cnt].prot_alias = pr_m
   .primary_mnemonic,
   reply->amendments[cnt].date_on_study = p_pr_r.on_study_dt_tm, reply->amendments[cnt].
   prot_amendment_id = pr_am.prot_amendment_id, reply->amendments[cnt].amendment_nbr = pr_am
   .amendment_nbr,
   reply->amendments[cnt].amendment_descn = pr_am.amendment_description, reply->amendments[cnt].
   prot_master_id = pr_m.prot_master_id
  DETAIL
   doccnt = (doccnt+ 1), stat = alterlist(reply->amendments[cnt].documents,doccnt), reply->
   amendments[cnt].documents[doccnt].doc_type_cd = cd.document_type_cd,
   reply->amendments[cnt].documents[doccnt].doc_type_cd_disp = uar_get_code_display(cd
    .document_type_cd), reply->amendments[cnt].documents[doccnt].doc_type_cd_mean =
   uar_get_code_meaning(cd.document_type_cd), reply->amendments[cnt].documents[doccnt].description =
   cd.description,
   reply->amendments[cnt].documents[doccnt].title = cd.title, reply->amendments[cnt].documents[doccnt
   ].file_name = cdv.file_name, reply->amendments[cnt].documents[doccnt].version_nbr = cdv
   .version_nbr,
   reply->amendments[cnt].documents[doccnt].version_description = cdv.version_description
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSEIF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echo("Reply->status_data->status =",0)
 CALL echo(reply->status_data.status,1)
 CALL echo("--------------------------------------------------------------")
 FOR (x = 1 TO cnt)
   CALL echo("Value of x = ",0)
   CALL echo(x,1)
   CALL echo("Reply->amendments[x]->Date_On_Study = ",0)
   CALL echo(reply->amendments[x].date_on_study,1)
   CALL echo("Reply->amendments[x]->Prot_Alias = ",0)
   CALL echo(reply->amendments[x].prot_alias,1)
   CALL echo("Reply->amendments[x]->Prot_Amendment_ID = ",0)
   CALL echo(reply->amendments[x].prot_amendment_id,1)
   CALL echo("Reply->amendments[x]->Amendment_Nbr = ",0)
   CALL echo(reply->amendments[x].amendment_nbr,1)
   CALL echo("Reply->amendments[x]->Documents[1]->description",0)
   CALL echo(reply->amendments[x].documents[1].description,1)
   CALL echo("--------------------------------------------------------------")
 ENDFOR
#skipecho
END GO
