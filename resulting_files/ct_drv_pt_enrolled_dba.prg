CREATE PROGRAM ct_drv_pt_enrolled:dba
 RECORD reply(
   1 filename = vc
   1 node = vc
   1 curdate = dq8
   1 tara = i4
   1 groupwidetara = i4
   1 prot_status_cd = f8
   1 prot_status_disp = vc
   1 prot_status_desc = vc
   1 prot_status_mean = c12
   1 as[*]
     2 amendstatus_cd = f8
     2 amendstatus_disp = vc
     2 amendstatus_desc = vc
     2 amendstatus_mean = c12
     2 datebegactive = dq8
     2 dateendactive = dq8
     2 datebegsusp = dq8
     2 nbr = i4
     2 id = f8
     2 revisionnbrtxt = c30
     2 revisionind = i2
   1 activeamendid = f8
   1 activeamendnbr = f8
   1 activedttm = dq8
   1 activerevisionind = i2
   1 activerevisionnbrtxt = c30
   1 highestamendid = f8
   1 highestamendnbr = f8
   1 registry_only_ind = i2
   1 enrolls[*]
     2 prot_master_id = f8
     2 prot_status_cd = f8
     2 prot_status_disp = vc
     2 prot_status_desc = vc
     2 prot_status_mean = c12
     2 prot_type_cd = f8
     2 prot_type_disp = vc
     2 prot_type_desc = vc
     2 prot_type_mean = c12
     2 cur_dateamendassignstart = dq8
     2 cur_dateamendassignend = dq8
     2 cur_protamendid = f8
     2 cur_amendmentnbr = i4
     2 cur_revisionnbrtxt = c30
     2 cur_revisionind = i2
     2 first_dateamendassignstart = dq8
     2 first_dateamendassignend = dq8
     2 first_protamendid = f8
     2 elig_protamendid = f8
     2 ptprotregid = f8
     2 regid = f8
     2 eligid = f8
     2 protalias = vc
     2 nomenclatureid = f8
     2 removalorgid = f8
     2 removalorgname = vc
     2 removalperid = f8
     2 removalpername = vc
     2 protaccessionnbr = vc
     2 dateonstudy = dq8
     2 dateoffstudy = dq8
     2 dateontherapy = dq8
     2 dateofftherapy = dq8
     2 datefirstpdfail = dq8
     2 firstdisrelevent_cd = f8
     2 firstdisrelevent_disp = vc
     2 firstdisrelevent_desc = vc
     2 firstdisrelevent_mean = c12
     2 enrollingorgid = f8
     2 enrollingorgname = vc
     2 protarmid = f8
     2 diagtype_cd = f8
     2 diagtype_disp = vc
     2 diagtype_desc = vc
     2 diagtype_mean = c12
     2 bestresp_cd = f8
     2 bestresp_disp = vc
     2 bestresp_desc = vc
     2 bestresp_mean = c12
     2 datefirstpd = dq8
     2 datefirstcr = dq8
     2 regupdtcnt = i4
     2 personid = f8
     2 lastname = vc
     2 firstname = vc
     2 namefullformatted = vc
     2 stratumlabel = vc
     2 follow_up_status_cd = f8
     2 follow_up_status_disp = vc
     2 txremovalorgid = f8
     2 txremovalorgname = vc
     2 txremovalperid = f8
     2 txremovalpername = vc
     2 txremovalreason_cd = f8
     2 txremovalreason_disp = vc
     2 txremovalreason_desc = vc
     2 txremovalreason_mean = c12
     2 txremovalreason = c255
     2 removalreason_cd = f8
     2 removalreason_disp = vc
     2 removalreason_desc = vc
     2 removalreason_mean = c12
     2 removalreason = c255
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
 DECLARE enrolls_size = i4 WITH public, noconstant(0)
 DECLARE stat = i4 WITH public, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 IF ((request->modeflag=1))
  SET trace = recpersist
  EXECUTE ct_get_pt_enrollments
  IF ((reply->status_data.status="F"))
   GO TO exit_script
  ENDIF
  SET enrolls_size = size(reply->enrolls,5)
  SET stat = alterlist(request->enrolls,enrolls_size)
  FOR (i = 1 TO enrolls_size)
    SET request->enrolls[i].prot_master_id = reply->enrolls[i].prot_master_id
    SET request->enrolls[i].prot_mnemonic = reply->enrolls[i].protalias
    SET request->enrolls[i].cur_protamendid = reply->enrolls[i].cur_protamendid
    SET request->enrolls[i].cur_amendmentnbr = reply->enrolls[i].cur_amendmentnbr
    SET request->enrolls[i].cur_revisionnbrtxt = reply->enrolls[i].cur_revisionnbrtxt
    SET request->enrolls[i].cur_revisionind = reply->enrolls[i].cur_revisionind
    SET request->enrolls[i].protalias = reply->enrolls[i].protalias
    SET request->enrolls[i].dateonstudy = reply->enrolls[i].dateonstudy
    SET request->enrolls[i].dateoffstudy = reply->enrolls[i].dateoffstudy
    SET request->enrolls[i].dateofftherapy = reply->enrolls[i].dateofftherapy
    SET request->enrolls[i].personid = reply->enrolls[i].personid
    SET request->enrolls[i].lastname = reply->enrolls[i].lastname
    SET request->enrolls[i].firstname = reply->enrolls[i].firstname
    SET request->enrolls[i].namefullformatted = reply->enrolls[i].namefullformatted
    SET request->enrolls[i].stratumlabel = reply->enrolls[i].stratumlabel
    SET request->enrolls[i].followup_status = reply->enrolls[i].follow_up_status_disp
    SET request->enrolls[i].protaccessionnbr = reply->enrolls[i].protaccessionnbr
    SET request->enrolls[i].cohort_label = reply->enrolls[i].cohort_label
    SET request->registry_only_ind = reply->registry_only_ind
    FOR (x = 1 TO value(size(reply->enrolls[i].mrns,5)))
      SET stat = alterlist(request->enrolls[i].mrns,x)
      SET request->enrolls[i].mrns[x].mrn = trim(reply->enrolls[i].mrns[x].mrn)
      SET request->enrolls[i].mrns[x].alias_pool_disp = uar_get_code_display(reply->enrolls[i].mrns[x
       ].alias_pool_cd)
    ENDFOR
  ENDFOR
  SET trace = norecpersist
 ENDIF
 EXECUTE ct_pt_rpt_shell
#exit_script
 SET last_mod = "005"
 SET mod_date = "Sep 12, 2013"
END GO
