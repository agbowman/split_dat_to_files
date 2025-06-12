CREATE PROGRAM ct_drv_pt_consent_list:dba
 RECORD reply(
   1 filename = vc
   1 node = vc
   1 transfercd = f8
   1 transfersafcd = f8
   1 consents[*]
     2 protocolid = f8
     2 personid = f8
     2 lastname = vc
     2 firstname = vc
     2 stratumlabel = vc
     2 namefullformatted = vc
     2 protalias = vc
     2 amendment_nbr = i4
     2 revision_nbr_txt = vc
     2 dateconissued = dq8
     2 dateconsigned = dq8
     2 dateconreturned = dq8
     2 dateconnotreturned = dq8
     2 reasonnotreturned_cd = f8
     2 reasonnotreturned_disp = vc
     2 reasonforcon_cd = f8
     2 reasonforcon_disp = vc
     2 reasonforcon_desc = vc
     2 reasonforcon_mean = vc
     2 conprotamendmentid = f8
     2 eligprotamendmentid = f8
     2 pteligtrackingid = f8
     2 protquestionnaireid = f8
     2 conid = f8
     2 ptconid = f8
     2 regid = f8
     2 protaccessionnbr = vc
     2 cohort_label = c30
     2 mrns[*]
       3 mrn = vc
       3 orgid = f8
       3 orgname = vc
       3 alias_pool_cd = f8
       3 alias_pool_disp = vc
       3 alias_pool_desc = vc
       3 alias_pool_mean = c12
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
 DECLARE consent_size = i4 WITH public, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 IF ((request->modeflag=1))
  SET trace = recpersist
  EXECUTE ct_get_pt_consent_list
  IF ((reply->status_data.status="F"))
   GO TO exit_script
  ENDIF
  SET consent_size = size(reply->consents,5)
  SET stat = alterlist(request->consents,consent_size)
  FOR (i = 1 TO consent_size)
    SET request->consents[i].protocolid = reply->consents[i].protocolid
    SET request->consents[i].personid = reply->consents[i].personid
    SET request->consents[i].lastname = reply->consents[i].lastname
    SET request->consents[i].firstname = reply->consents[i].firstname
    SET request->consents[i].stratumlabel = reply->consents[i].stratumlabel
    SET request->consents[i].namefullformatted = reply->consents[i].namefullformatted
    SET request->consents[i].protalias = reply->consents[i].protalias
    SET request->consents[i].dateconissued = reply->consents[i].dateconissued
    SET request->consents[i].dateconreturned = reply->consents[i].dateconreturned
    SET request->consents[i].dateconsigned = reply->consents[i].dateconsigned
    SET request->consents[i].dateconnotreturned = reply->consents[i].dateconnotreturned
    SET request->consents[i].reasonforcon_disp = uar_get_code_display(reply->consents[i].
     reasonforcon_cd)
    SET request->consents[i].reasonnotreturned_disp = uar_get_code_display(reply->consents[i].
     reasonnotreturned_cd)
    SET request->consents[i].cur_amendmentnbr = reply->consents[i].amendment_nbr
    SET request->consents[i].cur_revisionnbrtxt = reply->consents[i].revision_nbr_txt
    SET request->consents[i].conprotamendmentid = reply->consents[i].conprotamendmentid
    SET request->consents[i].eligprotamendmentid = reply->consents[i].eligprotamendmentid
    SET request->consents[i].protaccessionnbr = reply->consents[i].protaccessionnbr
    SET request->consents[i].cohort_label = reply->consents[i].cohort_label
    FOR (x = 1 TO value(size(reply->consents[i].mrns,5)))
      SET stat = alterlist(request->consents[i].mrns,x)
      SET request->consents[i].mrns[x].mrn = trim(reply->consents[i].mrns[x].mrn)
      SET request->consents[i].mrns[x].alias_pool_disp = uar_get_code_display(reply->consents[i].
       mrns[x].alias_pool_cd)
    ENDFOR
  ENDFOR
  SET trace = norecpersist
 ENDIF
 EXECUTE ct_pt_rpt_shell
#exit_script
 SET last_mod = "002"
 SET mod_date = "July 30, 2008"
END GO
