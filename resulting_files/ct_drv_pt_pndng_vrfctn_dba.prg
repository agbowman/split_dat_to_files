CREATE PROGRAM ct_drv_pt_pndng_vrfctn:dba
 RECORD reply(
   1 filename = vc
   1 node = vc
   1 enrolls[*]
     2 cur_dateamendassignstart = dq8
     2 cur_dateamendassignend = dq8
     2 cur_protamendid = f8
     2 first_dateamendassignstart = dq8
     2 first_dateamendassignend = dq8
     2 first_protamendid = f8
     2 elig_protamendid = f8
     2 enrollingorgid = f8
     2 regid = f8
     2 personid = f8
     2 protocolid = f8
     2 lastname = vc
     2 firstname = vc
     2 namefullformatted = vc
     2 stratumlabel = vc
     2 protalias = vc
     2 dateonstudy = dq8
     2 pteligtrackingid = f8
     2 cur_amendmentnbr = i2
     2 cur_revisionnbrtxt = c30
     2 follow_up_status_disp = vc
     2 protaccessionnbr = vc
     2 registry_ind = i2
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
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE temp_reg_ind = i2 WITH protect, noconstant(- (1))
 IF ((request->modeflag=1))
  SET trace = recpersist
  EXECUTE ct_get_pt_pndng_vrfctn
  IF ((reply->status_data.status="F"))
   GO TO exit_script
  ENDIF
  SET enrolls_size = size(reply->enrolls,5)
  SET stat = alterlist(request->enrolls,enrolls_size)
  FOR (i = 1 TO enrolls_size)
    SET request->enrolls[i].personid = reply->enrolls[i].personid
    SET request->enrolls[i].protocolid = reply->enrolls[i].protocolid
    SET request->enrolls[i].lastname = reply->enrolls[i].lastname
    SET request->enrolls[i].firstname = reply->enrolls[i].firstname
    SET request->enrolls[i].namefullformatted = reply->enrolls[i].namefullformatted
    SET request->enrolls[i].stratumlabel = reply->enrolls[i].stratumlabel
    SET request->enrolls[i].protalias = reply->enrolls[i].protalias
    SET request->enrolls[i].dateonstudy = reply->enrolls[i].dateonstudy
    SET request->enrolls[i].cur_amendmentnbr = reply->enrolls[i].cur_amendmentnbr
    SET request->enrolls[i].cur_revisionnbrtxt = reply->enrolls[i].cur_revisionnbrtxt
    SET request->enrolls[i].protaccessionnbr = reply->enrolls[i].protaccessionnbr
    SET request->enrolls[i].cohort_label = reply->enrolls[i].cohort_label
    IF (temp_reg_ind != 0)
     SET temp_reg_ind = reply->enrolls[i].registry_ind
    ENDIF
    FOR (x = 1 TO value(size(reply->enrolls[i].mrns,5)))
      SET stat = alterlist(request->enrolls[i].mrns,x)
      SET request->enrolls[i].mrns[x].mrn = trim(reply->enrolls[i].mrns[x].mrn)
      SET request->enrolls[i].mrns[x].alias_pool_disp = uar_get_code_display(reply->enrolls[i].mrns[x
       ].alias_pool_cd)
    ENDFOR
  ENDFOR
  SET request->registry_only_ind = temp_reg_ind
  SET trace = norecpersist
 ENDIF
 EXECUTE ct_pt_rpt_shell
#exit_script
 SET last_mod = "003"
 SET mod_date = "Aug 29, 2008"
END GO
