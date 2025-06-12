CREATE PROGRAM bsc_solcap_acute_care_audit:dba
 SET modify = predeclare
 FREE RECORD capability
 RECORD capability(
   1 list[*]
     2 solution_cd = f8
     2 event_cd = f8
     2 identifier = vc
 )
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE res_count = i4 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE debug_ind = i2 WITH protect, noconstant(validate(request->debug_ind,0))
 DECLARE list_count = i2 WITH protect, noconstant(0)
 CALL alterlist(capability->list,50)
 CALL setcapability(1,"CAREADMIN","GS1","2010.1.00049.1")
 CALL setcapability(2,"CAREMOBILE","GS1","2010.1.00049.2")
 CALL setcapability(3,"RXWRKFLOWMON","GS1","2010.1.00049.3")
 CALL setcapability(4,"RXBARCODEVAL","GS1","2010.1.00049.4")
 CALL setcapability(5,"RXCOA","NDCSCANEVAL","2010.1.00103.2")
 CALL setcapability(6,"RXMEDMGR","DISPPKGINFO","2010.1.00044.3")
 CALL setcapability(7,"CAREADMIN","AUTOPROGSCAN","2010.2.00015.3")
 CALL setcapability(8,"CAREADMIN","INFMGMTASSOC","2010.2.00015.2")
 CALL setcapability(9,"CAREMOBILE","INFMGMTASSOC","2010.2.00015.1")
 CALL setcapability(10,"RESULTSTOEND","ENDORSERSLTS","2011.1.00064.1")
 CALL setcapability(11,"RXWRKFLOWMON","PRDSCAN","2012.1.00000.5")
 CALL setcapability(12,"RXWRKFLOWMON","PRDSCANNOQTY","2012.1.00000.6")
 CALL setcapability(13,"CAREADMIN","DEVICEIDCHRT","2011.2.00060.1")
 CALL setcapability(14,"CAREMOBILE","DEVICEIDCHRT","2011.2.00060.2")
 CALL setcapability(15,"DOSECALC","MAXGFRUSED","2011.2.00019.1")
 CALL setcapability(16,"DOSECALC","TARGDOSELOCK","2012.2.00000.4")
 CALL setcapability(17,"RXMEDMGR","RXAREFILL","2012.1.00066.1")
 CALL setcapability(18,"RXMEDMGR","RXAMODIFY","2012.1.00066.2")
 CALL setcapability(19,"RXMEDMGR","RXACANCEL","2012.1.00066.3")
 CALL setcapability(20,"RXMEDMGR","RXACANCELFIL","2012.1.00066.4")
 CALL setcapability(21,"RXMEDMGR","RXAVOID","2012.1.00066.5")
 CALL setcapability(22,"RXMEDMGR","RXAINTERVENE","2012.1.00066.6")
 CALL setcapability(23,"RXMEDMGR","RXACLAIM","2012.1.00066.7")
 CALL setcapability(24,"RXMEDMGR","RXALABEL","2012.1.00066.8")
 CALL setcapability(25,"RXMEDMGR","RXAREVIEW","2012.1.00066.9")
 CALL setcapability(26,"RXMEDMGR","RXAVERIFY","2012.1.00066.10")
 CALL setcapability(27,"RXMEDMGR","RXAFILL","2012.1.00066.11")
 CALL setcapability(28,"RXPATIENTMON","RXAPPLAUNCH","2012.1.00066.13")
 CALL setcapability(29,"RXCHARGECRED","RXFINANCIAL","2013.2.00003.1")
 CALL setcapability(30,"RXCHARGECRED","RXNOFINANCE","2013.2.00003.2")
 CALL setcapability(31,"DOSECALC","MAXBSAUSED","2013.2.00106.2")
 CALL setcapability(32,"DOSECALC","MAXDOSEUSED","2013.2.00106.3")
 CALL setcapability(33,"HASPHASE2","SIGNTIMECHK","2013.1.00054.6")
 CALL setcapability(34,"HASPHASE2","INOUTSEPARAT","2013.1.00054.7")
 CALL setcapability(35,"HASPHASE2","PROFILEALERT","2013.1.00054.8")
 CALL setcapability(36,"HASPHASE2","ORREASON","2013.1.00054.9")
 CALL setcapability(37,"HASPHASE2","BCBIVCOMPAT","2013.1.00054.10")
 CALL setcapability(38,"HASPHASE2","DRCWEEKS","2013.1.00054.11")
 CALL setcapability(39,"PFPEDIATRIC","PFPEDRPT","2014.1.00279.1")
 CALL setcapability(40,"EMAR","IMLOTSCANNED","2015.1.00246.1")
 CALL setcapability(41,"EMAR","IMLOTMANUAL","2015.1.00246.2")
 CALL setcapability(42,"ICAU","ICAUARREPORT","2015.1.00366.4")
 CALL setcapability(43,"ICAR","ICAUARREPORT","2015.1.00366.5")
 CALL setcapability(44,"ICDOT","ICDOTREPORT","2014.1.00263.6")
 CALL setcapability(45,"ICASPLOT","ICLOTREPORT","PJ003082.2")
 SET dstat = alterlist(capability->list,list_count)
 SET dstat = alterlist(reply->solcap,size(capability->list,5))
 FOR (lcnt = 1 TO size(capability->list,5))
   SET reply->solcap[lcnt].identifier = capability->list[lcnt].identifier
   SET reply->solcap[lcnt].degree_of_use_str = "NO"
   SET res_count = 0
   SELECT INTO "nl:"
    user_cnt = count(DISTINCT ac.audit_prsnl_id), use_cnt = count(ac.acute_care_audit_info_id)
    FROM acute_care_audit_info ac
    WHERE ac.audit_event_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     end_dt_tm)
     AND (ac.audit_event_type_cd=capability->list[lcnt].event_cd)
     AND (ac.audit_solution_cd=capability->list[lcnt].solution_cd)
    DETAIL
     reply->solcap[lcnt].degree_of_use_num = use_cnt, reply->solcap[lcnt].distinct_user_count =
     user_cnt
     IF (use_cnt > 0)
      reply->solcap[lcnt].degree_of_use_str = "YES"
     ENDIF
    WITH nocounter
   ;end select
   SET res_count = 0
   SELECT INTO "nl:"
    user_pos = uar_get_code_display(ac.position_cd), use_cnt = count(ac.acute_care_audit_info_id)
    FROM acute_care_audit_info ac
    WHERE ac.audit_event_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     end_dt_tm)
     AND (ac.audit_event_type_cd=capability->list[lcnt].event_cd)
     AND (ac.audit_solution_cd=capability->list[lcnt].solution_cd)
    GROUP BY ac.position_cd
    DETAIL
     res_count += 1
     IF (mod(res_count,10)=1)
      dstat = alterlist(reply->solcap[lcnt].position,(res_count+ 9))
     ENDIF
     reply->solcap[lcnt].position[res_count].display = trim(user_pos), reply->solcap[lcnt].position[
     res_count].value_num = use_cnt
    FOOT REPORT
     dstat = alterlist(reply->solcap[lcnt].position,res_count)
    WITH nocounter
   ;end select
   SET res_count = 0
   SELECT INTO "nl:"
    user_fac = uar_get_code_display(ac.audit_facility_cd), use_cnt = count(ac
     .acute_care_audit_info_id)
    FROM acute_care_audit_info ac
    WHERE ac.audit_event_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     end_dt_tm)
     AND (ac.audit_event_type_cd=capability->list[lcnt].event_cd)
     AND (ac.audit_solution_cd=capability->list[lcnt].solution_cd)
    GROUP BY ac.audit_facility_cd
    DETAIL
     res_count += 1
     IF (mod(res_count,10)=1)
      dstat = alterlist(reply->solcap[lcnt].facility,(res_count+ 9))
     ENDIF
     reply->solcap[lcnt].facility[res_count].display = trim(user_fac), reply->solcap[lcnt].facility[
     res_count].value_num = use_cnt
    FOOT REPORT
     dstat = alterlist(reply->solcap[lcnt].facility,res_count)
    WITH nocounter
   ;end select
 ENDFOR
#exit_script
 FREE RECORD capability
 SET last_mod = "024"
 SET mod_date = "06/11/2018"
 IF (debug_ind=1)
  CALL echorecord(reply)
  CALL echo(build("last_mod: ",last_mod))
  CALL echo(build("mod_date: ",mod_date))
 ENDIF
 SUBROUTINE (setcapability(idx=i4,solution=vc,event=vc,id=vc) =null)
   DECLARE solution_codeset = i4 WITH private, constant(4002138)
   DECLARE audit_event = i4 WITH private, constant(4002139)
   DECLARE capsize = i4 WITH private, noconstant(size(capability->list,5))
   IF (capsize <= idx)
    CALL alterlist(capability->list,(idx+ 50))
   ENDIF
   SET capability->list[idx].solution_cd = uar_get_code_by("MEANING",solution_codeset,solution)
   SET capability->list[idx].event_cd = uar_get_code_by("MEANING",audit_event,event)
   SET capability->list[idx].identifier = id
   SET list_count += 1
 END ;Subroutine
 SET modify = nopredeclare
END GO
