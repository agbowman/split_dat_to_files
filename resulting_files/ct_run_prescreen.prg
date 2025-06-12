CREATE PROGRAM ct_run_prescreen
 DECLARE sql_xxx1(p1,p2) = c1
 RDB asis ( "create or replace function sql_xxx1(i_num1 number,i_num2 char)" ) asis (
 "return char is o_num2 char; begin return(i_num2); end;" )
 END ;Rdb
 SUBROUTINE (nextlongtextsequence(x=i2) =f8)
   DECLARE nsequence = f8 WITH protect
   SELECT INTO "nl:"
    nextseqnum = seq(long_data_seq,nextval)
    FROM dual
    DETAIL
     nsequence = nextseqnum
    WITH nocounter
   ;end select
   RETURN(nsequence)
 END ;Subroutine
 SUBROUTINE (insert_long_text(long_text_id=f8,text=vc,parent_name=vc,parent_id=f8) =i2)
  INSERT  FROM long_text lt
   SET lt.long_text_id =
    IF (long_text_id > 0) long_text_id
    ELSE seq(long_data_seq,nextval)
    ENDIF
    , lt.long_text = text, lt.parent_entity_name = parent_name,
    lt.parent_entity_id = parent_id, lt.updt_dt_tm = cnvtdatetime(sysdate), lt.updt_id = reqinfo->
    updt_id,
    lt.updt_applctx = reqinfo->updt_applctx, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
    lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
    cnvtdatetime(sysdate),
    lt.active_status_prsnl_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   RETURN(false)
  ELSE
   RETURN(true)
  ENDIF
 END ;Subroutine
 RECORD tctrequest(
   1 opsind = i2
   1 execmodeflag = i2
   1 screenerid = f8
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 order_id = f8
     2 accession_id = f8
     2 sex_cd = f8
     2 birth_dt_tm = dq8
     2 race_cd = f8
     2 currentct[*]
       3 prot_master_id = f8
       3 primary_mnemonic = vc
   1 checkct[*]
     2 prot_master_id = f8
     2 primary_mnemonic = vc
 )
 RECORD reply(
   1 ctfndind = i2
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 ctcnt = i4
     2 ctqual[*]
       3 pt_prot_prescreen_id = f8
       3 primary_mnemonic = vc
       3 prot_master_id = f8
       3 comment = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(jobdetailrequest,0)))
  RECORD jobdetailrequest(
    1 type_flag = i2
    1 job_details = vc
  )
 ENDIF
 RECORD manuallyadded(
   1 qual[*]
     2 person_id = f8
     2 prot_id = f8
     2 primary_mnemonic = vc
   1 qual_cnt = i4
 )
 RECORD pinterest(
   1 notcnt = i4
   1 currentcnt = i4
   1 qual[*]
     2 not_interested_ind = i2
 )
 IF ( NOT (validate(syscancel,0)))
  RECORD syscancel(
    1 cnt = i4
    1 qual[*]
      2 pt_prot_prescreen_id = f8
  )
 ENDIF
 IF ( NOT (validate(org_sec_reply,0)))
  RECORD org_sec_reply(
    1 orgsecurityflag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(pref_request,0)))
  RECORD pref_request(
    1 pref_entry = vc
  )
 ENDIF
 IF ( NOT (validate(pref_reply,0)))
  RECORD pref_reply(
    1 pref_value = i4
    1 pref_values[*]
      2 values = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD history_request(
   1 status_list[*]
     2 prot_status_cd = f8
   1 protocol_list[*]
     2 prot_master_id = f8
 )
 RECORD history_reply(
   1 protocol_list[*]
     2 prot_master_id = f8
 )
 CALL echorecord(eksctrequest)
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE y = i4 WITH protect, noconstant(0)
 DECLARE z = i4 WITH protect, noconstant(0)
 IF ( NOT (validate(eksctrequest)))
  CALL echo("EKSCTRequest was not defined")
  RECORD eksctrequest(
    1 opsind = i2
    1 execmodeflag = i2
    1 screenerid = f8
    1 qual[*]
      2 person_id = f8
      2 encntr_id = f8
      2 order_id = f8
      2 accession_id = f8
      2 sex_cd = f8
      2 birth_dt_tm = dq8
      2 race_cd = f8
      2 currentct[*]
        3 prot_master_id = f8
        3 primary_mnemonic = vc
    1 checkct[*]
      2 prot_master_id = f8
      2 primary_mnemonic = vc
  )
  RECORD eksctreply(
    1 ctfndind = i2
    1 qual[*]
      2 person_id = f8
      2 encntr_id = f8
      2 ctcnt = i4
      2 ctqual[*]
        3 pt_prot_prescreen_id = f8
        3 primary_mnemonic = vc
        3 prot_master_id = f8
        3 comment = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  DECLARE req = i4
  DECLARE happ = i4
  DECLARE htask = i4
  DECLARE hreq = i4
  DECLARE hreply = i4
  DECLARE crmstatus = i4
  SET ecrmok = 0
  SET null = 0
  IF (validate(recdate,"Y")="Y"
   AND validate(recdate,"N")="N")
   RECORD recdate(
     1 datetime = dq8
   )
  ENDIF
  SUBROUTINE srvrequest(dparam)
    IF (eksctrequest->opsind)
     SET req = 3091003
    ELSE
     SET req = 3091002
    ENDIF
    SET happ = 0
    SET app = 3055000
    SET task = 4801
    SET endapp = 0
    SET endtask = 0
    SET endreq = 0
    CALL echo(concat("curenv = ",build(curenv)))
    IF (curenv=0)
     CALL echo("Calling srv, crm, cclsec")
     EXECUTE srvrtl
     EXECUTE crmrtl
     IF ( NOT (xxcclseclogin->loggedin))
      EXECUTE cclseclogin
     ENDIF
     SET crmstatus = uar_crmbeginapp(app,happ)
     CALL echo(concat("beginapp status = ",build(crmstatus)))
     IF (happ)
      SET endapp = 1
     ENDIF
    ELSE
     SET happ = uar_crmgetapphandle()
    ENDIF
    IF (happ > 0)
     SET crmstatus = uar_crmbegintask(happ,task,htask)
     IF (crmstatus != ecrmok)
      CALL echo("Invalid CrmBeginTask return status")
      SET retval = - (1)
     ELSE
      SET endtask = 1
      SET crmstatus = uar_crmbeginreq(htask,0,req,hreq)
      IF (crmstatus != ecrmok)
       SET retval = - (1)
       CALL echo(concat("Invalid CrmBeginReq return status of ",build(crmstatus)))
      ELSEIF (hreq=null)
       SET retval = - (1)
       CALL echo("Invalid hReq handle")
      ELSE
       SET endreq = 1
       SET request_handle = hreq
       SET heksctrequest = uar_crmgetrequest(hreq)
       IF (heksctrequest=null)
        SET retval = - (1)
        CALL echo("Invalid request handle return from CrmGetRequest")
       ELSE
        SET stat = uar_srvsetshort(heksctrequest,"OPSIND",eksctrequest->opsind)
        SET stat = uar_srvsetshort(heksctrequest,"EXECMODEFLAG",eksctrequest->execmodeflag)
        SET stat = uar_srvsetdouble(heksctrequest,"SCREENERID",eksctrequest->screenerid)
        FOR (ndx1 = 1 TO size(eksctrequest->qual,5))
         SET hqual = uar_srvadditem(heksctrequest,"QUAL")
         IF (hqual=null)
          CALL echo("QUAL","Invalid handle")
         ELSE
          SET stat = uar_srvsetdouble(hqual,"PERSON_ID",eksctrequest->qual[ndx1].person_id)
          SET stat = uar_srvsetdouble(hqual,"SEX_CD",eksctrequest->qual[ndx1].sex_cd)
          SET recdate->datetime = eksctrequest->qual[ndx1].birth_dt_tm
          SET stat = uar_srvsetdate2(hqual,"BIRTH_DT_TM",recdate)
          SET stat = uar_srvsetdouble(hqual,"ENCNTR_ID",eksctrequest->qual[ndx1].encntr_id)
          SET stat = uar_srvsetdouble(hqual,"ACCESSION_ID",eksctrequest->qual[ndx1].accession_id)
          SET stat = uar_srvsetdouble(hqual,"ORDER_ID",eksctrequest->qual[ndx1].order_id)
          SET stat = uar_srvsetdouble(hqual,"RACE_CD",eksctrequest->qual[ndx1].race_cd)
          FOR (ndx2 = 1 TO size(eksctrequest->qual[ndx1].currentct,5))
           SET hdata = uar_srvadditem(hqual,"CURRENTCT")
           IF (hdata=null)
            CALL echo("CURRENTCT","Invalid handle")
           ELSE
            SET stat = uar_srvsetstring(hdata,"PRIMARY_MNEMONIC",nullterm(eksctrequest->qual[ndx1].
              currentct[ndx2].primary_mnemonic))
            SET stat = uar_srvsetdouble(hdata,"PROT_MASTER_ID_ID",eksctrequest->qual[ndx1].currentct[
             ndx2].prot_master_id)
           ENDIF
          ENDFOR
          SET retval = 100
         ENDIF
        ENDFOR
        FOR (ndx1 = 1 TO size(eksctrequest->checkct,5))
         SET hqual = uar_srvadditem(heksctrequest,"CHECKCT")
         IF (hqual=null)
          CALL echo("CHECKCT","Invalid handle")
         ELSE
          SET stat = uar_srvsetdouble(hqual,"PROT_MASTER_ID",eksctrequest->checkct[ndx1].
           prot_master_id)
          SET stat = uar_srvsetstring(hqual,"PRIMARY_MNEMONIC",nullterm(eksctrequest->checkct[ndx1].
            primary_mnemonic))
         ENDIF
        ENDFOR
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF (crmstatus=ecrmok)
     CALL echo(concat("**** Begin perform request #",cnvtstring(req)," -EKS Event @",format(curdate,
        "dd-mmm-yyyy;;d")," ",
       format(curtime3,"hh:mm:ss.cc;3;m")))
     SET crmstatus = uar_crmperform(hreq)
     CALL echo(concat("**** End perform request #",cnvtstring(req)," -EKS Event @",format(curdate,
        "dd-mmm-yyyy;;d")," ",
       format(curtime3,"hh:mm:ss.cc;3;m")))
     IF (crmstatus != ecrmok)
      SET retval = - (1)
      CALL echo("Invalid CrmPerform return status")
     ELSE
      SET retval = 100
      CALL echo("CrmPerform was successful")
      IF (req=3091002)
       SET hreply = uar_crmgetreply(hreq)
       IF (hreply=null)
        CALL echo("Error in CrmGetReply, invalid handle returned.")
       ELSE
        CALL echo("Retrieving reply message...")
        SET eksctreply->ctfndind = uar_srvgetshort(hreply,"ctFndInd")
        SET cur_qualcnt = uar_srvgetitemcount(hreply,"qual")
        SET stat = alterlist(eksctreply->qual,cur_qualcnt)
        FOR (cur_qual = 1 TO cur_qualcnt)
         SET hquallist = uar_srvgetitem(hreply,"qual",(cur_qual - 1))
         IF (hquallist=null)
          CALL echo("Invalid hQualList handle returned from SrvGetItem")
          SET cur_qual = cur_qualcnt
         ELSE
          SET eksctreply->qual[cur_qual].person_id = uar_srvgetdouble(hquallist,"person_id")
          SET eksctreply->qual[cur_qual].encntr_id = uar_srvgetdouble(hquallist,"encntr_id")
          SET eksctreply->qual[cur_qual].ctcnt = uar_srvgetlong(hquallist,"ctCnt")
          SET cur_ctqualcnt = uar_srvgetitemcount(hquallist,"ctQual")
          IF (cur_ctqualcnt)
           SET stat = alterlist(eksctreply->qual[cur_qual].ctqual,cur_ctqualcnt)
           CALL echo(concat(build(cur_ctqualcnt)," entries are in ctQual"))
           FOR (cur_ctqual = 1 TO cur_ctqualcnt)
            SET hctquallist = uar_srvgetitem(hquallist,"ctQual",(cur_ctqual - 1))
            IF (hctquallist=null)
             CALL echo("Invalid hctQualList handle returned from SrvGetItem")
             SET cur_ctqual = cur_ctqualcnt
            ELSE
             SET eksctreply->qual[cur_qual].ctqual[cur_ctqual].pt_prot_prescreen_id =
             uar_srvgetdouble(hctquallist,"pt_prot_prescreen_id")
             SET eksctreply->qual[cur_qual].ctqual[cur_ctqual].prot_master_id = uar_srvgetdouble(
              hctquallist,"prot_master_id")
             SET eksctreply->qual[cur_qual].ctqual[cur_ctqual].primary_mnemonic = uar_srvgetstringptr
             (hctquallist,"primary_mnemonic")
             SET eksctreply->qual[cur_qual].ctqual[cur_ctqual].comment = uar_srvgetstringptr(
              hctquallist,"comment")
            ENDIF
           ENDFOR
          ENDIF
         ENDIF
        ENDFOR
        CALL echorecord(eksctreply)
       ENDIF
      ENDIF
     ENDIF
    ELSE
     SET retval = - (1)
     CALL echo("CrmPerform not executed do to begin request error")
    ENDIF
    IF (endreq)
     CALL echo("Ending CRM Request")
     CALL uar_crmendreq(hreq)
    ENDIF
    IF (endtask)
     CALL echo("Ending CRM Task")
     CALL uar_crmendtask(htask)
    ENDIF
    IF (endapp)
     CALL echo("Ending CRM App")
     CALL uar_crmendapp(happ)
    ENDIF
  END ;Subroutine
  SET eksctrequest->opsind = request->opsind
  SET eksctrequest->execmodeflag = request->execmodeflag
  SET eksctrequest->screenerid = request->screenerid
  SET stat = alterlist(eksctrequest->qual,size(request->qual,5))
  FOR (x = 1 TO size(request->qual,5))
    SET eksctrequest->qual[x].person_id = request->qual[x].person_id
    SET eksctrequest->qual[x].encntr_id = request->qual[x].encntr_id
    SET eksctrequest->qual[x].order_id = request->qual[x].order_id
    SET eksctrequest->qual[x].accession_id = request->qual[x].accession_id
    SET eksctrequest->qual[x].sex_cd = request->qual[x].sex_cd
    SET eksctrequest->qual[x].birth_dt_tm = request->qual[x].birth_dt_tm
    SET eksctrequest->qual[x].race_cd = request->qual[x].race_cd
    IF (size(request->qual[x].currentct,5) > 0)
     SET stat = alterlist(eksctrequest->qual[x].currentct,size(request->qual[x].currentct,5))
     FOR (y = 1 TO size(request->qual[x].currentct,5))
      SET eksctrequest->qual[x].currentct[y].prot_master_id = request->qual[x].currentct[y].
      prot_master_id
      SET eksctrequest->qual[x].currentct[y].primary_mnemonic = request->qual[x].currentct[y].
      primary_mnemonic
     ENDFOR
    ENDIF
  ENDFOR
  SET stat = alterlist(eksctrequest->checkct,size(request->checkct,5))
  FOR (z = 1 TO size(request->checkct,5))
   SET eksctrequest->checkct[z].prot_master_id = request->checkct[z].prot_master_id
   SET eksctrequest->checkct[z].primary_mnemonic = request->checkct[z].primary_mnemonic
  ENDFOR
 ELSE
  CALL echo("EKSCTRequest already existed")
 ENDIF
 DECLARE getactiveprotocolsbytype(org_security_ind=i2,registry_cfg_cd=f8,status_cd_str=vc,
  screener_str=vc) = i2
 SUBROUTINE (getallactiveprotocols(org_security_ind=i2,status_cd_str=vc,screener_str=vc) =i2)
  IF (org_security_ind=1)
   SET userorgstr = builduserorglist("pr.organization_id")
   SELECT INTO "nl:"
    pm.prot_master_id, pm.primary_mnemonic
    FROM prot_master pm,
     prot_role pr,
     prot_amendment pa
    PLAN (pm
     WHERE pm.prot_master_id > 0
      AND parser(status_cd_str)
      AND parser(screener_str)
      AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (pa
     WHERE pa.prot_master_id=pm.prot_master_id
      AND pa.amendment_status_cd=pm.prot_status_cd)
     JOIN (pr
     WHERE pr.prot_amendment_id=pa.prot_amendment_id
      AND pr.prot_role_type_cd=institution_cd
      AND parser(userorgstr)
      AND pr.end_effective_dt_tm >= cnvtdatetime(sysdate))
    HEAD REPORT
     prot_cnt = 0
    DETAIL
     prot_cnt += 1
     IF (prot_cnt > size(tctrequest->checkct,5))
      stat = alterlist(tctrequest->checkct,(prot_cnt+ 5)), stat = alterlist(eksctrequest->checkct,(
       prot_cnt+ 5))
     ENDIF
     tctrequest->checkct[prot_cnt].primary_mnemonic = pm.primary_mnemonic, tctrequest->checkct[
     prot_cnt].prot_master_id = pm.prot_master_id, eksctrequest->checkct[prot_cnt].primary_mnemonic
      = pm.primary_mnemonic,
     eksctrequest->checkct[prot_cnt].prot_master_id = pm.prot_master_id
    FOOT REPORT
     stat = alterlist(tctrequest->checkct,prot_cnt), stat = alterlist(eksctrequest->checkct,prot_cnt)
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    pm.prot_master_id, pm.primary_mnemonic
    FROM prot_master pm
    WHERE pm.prot_master_id > 0
     AND parser(status_cd_str)
     AND parser(screener_str)
     AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
    HEAD REPORT
     prot_cnt = 0
    DETAIL
     prot_cnt += 1
     IF (prot_cnt > size(tctrequest->checkct,5))
      stat = alterlist(tctrequest->checkct,(prot_cnt+ 5)), stat = alterlist(eksctrequest->checkct,(
       prot_cnt+ 5))
     ENDIF
     tctrequest->checkct[prot_cnt].primary_mnemonic = pm.primary_mnemonic, tctrequest->checkct[
     prot_cnt].prot_master_id = pm.prot_master_id, eksctrequest->checkct[prot_cnt].primary_mnemonic
      = pm.primary_mnemonic,
     eksctrequest->checkct[prot_cnt].prot_master_id = pm.prot_master_id
    FOOT REPORT
     stat = alterlist(tctrequest->checkct,prot_cnt), stat = alterlist(eksctrequest->checkct,prot_cnt)
    WITH nocounter
   ;end select
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE (getallactivediscernprotocols(org_security_ind=i2,status_cd_str=vc,screener_str=vc) =i2)
  IF (org_security_ind=1)
   SET userorgstr = builduserorglist("pr.organization_id")
   SELECT INTO "nl:"
    pm.prot_master_id, pm.primary_mnemonic
    FROM prot_master pm,
     prot_role pr,
     prot_amendment pa
    PLAN (pm
     WHERE pm.prot_master_id > 0
      AND parser(status_cd_str)
      AND parser(screener_str)
      AND pm.prescreen_type_flag=0
      AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (pa
     WHERE pa.prot_master_id=pm.prot_master_id
      AND pa.amendment_status_cd=pm.prot_status_cd)
     JOIN (pr
     WHERE pr.prot_amendment_id=pa.prot_amendment_id
      AND pr.prot_role_type_cd=institution_cd
      AND parser(userorgstr)
      AND pr.end_effective_dt_tm >= cnvtdatetime(sysdate))
    HEAD REPORT
     prot_cnt = 0
    DETAIL
     prot_cnt += 1
     IF (prot_cnt > size(tctrequest->checkct,5))
      stat = alterlist(tctrequest->checkct,(prot_cnt+ 5)), stat = alterlist(eksctrequest->checkct,(
       prot_cnt+ 5))
     ENDIF
     tctrequest->checkct[prot_cnt].primary_mnemonic = pm.primary_mnemonic, tctrequest->checkct[
     prot_cnt].prot_master_id = pm.prot_master_id, eksctrequest->checkct[prot_cnt].primary_mnemonic
      = pm.primary_mnemonic,
     eksctrequest->checkct[prot_cnt].prot_master_id = pm.prot_master_id
    FOOT REPORT
     stat = alterlist(tctrequest->checkct,prot_cnt), stat = alterlist(eksctrequest->checkct,prot_cnt)
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    pm.prot_master_id, pm.primary_mnemonic
    FROM prot_master pm
    WHERE pm.prot_master_id > 0
     AND parser(status_cd_str)
     AND parser(screener_str)
     AND pm.prescreen_type_flag=0
     AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
    HEAD REPORT
     prot_cnt = 0
    DETAIL
     prot_cnt += 1
     IF (prot_cnt > size(tctrequest->checkct,5))
      stat = alterlist(tctrequest->checkct,(prot_cnt+ 5)), stat = alterlist(eksctrequest->checkct,(
       prot_cnt+ 5))
     ENDIF
     tctrequest->checkct[prot_cnt].primary_mnemonic = pm.primary_mnemonic, tctrequest->checkct[
     prot_cnt].prot_master_id = pm.prot_master_id, eksctrequest->checkct[prot_cnt].primary_mnemonic
      = pm.primary_mnemonic,
     eksctrequest->checkct[prot_cnt].prot_master_id = pm.prot_master_id
    FOOT REPORT
     stat = alterlist(tctrequest->checkct,prot_cnt), stat = alterlist(eksctrequest->checkct,prot_cnt)
    WITH nocounter
   ;end select
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE getactiveprotocols(org_security_ind,registry_cfg_cd,status_cd_str,screener_str)
  IF (org_security_ind=1)
   SET userorgstr = builduserorglist("pr.organization_id")
   SELECT INTO "nl:"
    pm.prot_master_id, pm.primary_mnemonic
    FROM prot_master pm,
     prot_role pr,
     prot_amendment pa,
     ct_prot_type_config cfg
    PLAN (pm
     WHERE pm.prot_master_id > 0
      AND parser(status_cd_str)
      AND parser(screener_str)
      AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (pa
     WHERE pa.prot_master_id=pm.prot_master_id
      AND pa.amendment_status_cd=pm.prot_status_cd)
     JOIN (pr
     WHERE pr.prot_amendment_id=pa.prot_amendment_id
      AND pr.prot_role_type_cd=institution_cd
      AND parser(userorgstr)
      AND pr.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (cfg
     WHERE cfg.protocol_type_cd=pa.participation_type_cd
      AND cfg.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND cfg.item_cd=registry_type_cd
      AND cfg.config_value_cd=registry_cfg_cd)
    HEAD REPORT
     prot_cnt = 0
    DETAIL
     prot_cnt += 1
     IF (prot_cnt > size(tctrequest->checkct,5))
      stat = alterlist(tctrequest->checkct,(prot_cnt+ 5)), stat = alterlist(eksctrequest->checkct,(
       prot_cnt+ 5))
     ENDIF
     tctrequest->checkct[prot_cnt].primary_mnemonic = pm.primary_mnemonic, tctrequest->checkct[
     prot_cnt].prot_master_id = pm.prot_master_id, eksctrequest->checkct[prot_cnt].primary_mnemonic
      = pm.primary_mnemonic,
     eksctrequest->checkct[prot_cnt].prot_master_id = pm.prot_master_id
    FOOT REPORT
     stat = alterlist(tctrequest->checkct,prot_cnt), stat = alterlist(eksctrequest->checkct,prot_cnt)
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    pm.prot_master_id, pm.primary_mnemonic
    FROM prot_master pm,
     prot_amendment pa,
     ct_prot_type_config cfg
    PLAN (pm
     WHERE pm.prot_master_id > 0
      AND parser(status_cd_str)
      AND parser(screener_str)
      AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (pa
     WHERE pa.prot_master_id=pm.prot_master_id
      AND pa.amendment_status_cd=pm.prot_status_cd)
     JOIN (cfg
     WHERE cfg.protocol_type_cd=pa.participation_type_cd
      AND cfg.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND cfg.item_cd=registry_type_cd
      AND cfg.config_value_cd=registry_cfg_cd)
    HEAD REPORT
     prot_cnt = 0
    DETAIL
     prot_cnt += 1
     IF (prot_cnt > size(tctrequest->checkct,5))
      stat = alterlist(tctrequest->checkct,(prot_cnt+ 5)), stat = alterlist(eksctrequest->checkct,(
       prot_cnt+ 5))
     ENDIF
     tctrequest->checkct[prot_cnt].primary_mnemonic = pm.primary_mnemonic, tctrequest->checkct[
     prot_cnt].prot_master_id = pm.prot_master_id, eksctrequest->checkct[prot_cnt].primary_mnemonic
      = pm.primary_mnemonic,
     eksctrequest->checkct[prot_cnt].prot_master_id = pm.prot_master_id,
     CALL echo(build("prot is:",pm.primary_mnemonic))
    FOOT REPORT
     stat = alterlist(tctrequest->checkct,prot_cnt), stat = alterlist(eksctrequest->checkct,prot_cnt)
    WITH nocounter
   ;end select
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE (getactivediscernprotocols(org_security_ind=i2,registry_cfg_cd=f8,status_cd_str=vc,
  screener_str=vc) =i2)
  IF (org_security_ind=1)
   SET userorgstr = builduserorglist("pr.organization_id")
   SELECT INTO "nl:"
    pm.prot_master_id, pm.primary_mnemonic
    FROM prot_master pm,
     prot_role pr,
     prot_amendment pa,
     ct_prot_type_config cfg
    PLAN (pm
     WHERE pm.prot_master_id > 0
      AND parser(status_cd_str)
      AND parser(screener_str)
      AND pm.prescreen_type_flag=0
      AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (pa
     WHERE pa.prot_master_id=pm.prot_master_id
      AND pa.amendment_status_cd=pm.prot_status_cd)
     JOIN (pr
     WHERE pr.prot_amendment_id=pa.prot_amendment_id
      AND pr.prot_role_type_cd=institution_cd
      AND parser(userorgstr)
      AND pr.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (cfg
     WHERE cfg.protocol_type_cd=pa.participation_type_cd
      AND cfg.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND cfg.item_cd=registry_type_cd
      AND cfg.config_value_cd=registry_cfg_cd)
    HEAD REPORT
     prot_cnt = 0
    DETAIL
     prot_cnt += 1
     IF (prot_cnt > size(tctrequest->checkct,5))
      stat = alterlist(tctrequest->checkct,(prot_cnt+ 5)), stat = alterlist(eksctrequest->checkct,(
       prot_cnt+ 5))
     ENDIF
     tctrequest->checkct[prot_cnt].primary_mnemonic = pm.primary_mnemonic, tctrequest->checkct[
     prot_cnt].prot_master_id = pm.prot_master_id, eksctrequest->checkct[prot_cnt].primary_mnemonic
      = pm.primary_mnemonic,
     eksctrequest->checkct[prot_cnt].prot_master_id = pm.prot_master_id
    FOOT REPORT
     stat = alterlist(tctrequest->checkct,prot_cnt), stat = alterlist(eksctrequest->checkct,prot_cnt)
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    pm.prot_master_id, pm.primary_mnemonic
    FROM prot_master pm,
     prot_amendment pa,
     ct_prot_type_config cfg
    PLAN (pm
     WHERE pm.prot_master_id > 0
      AND parser(status_cd_str)
      AND parser(screener_str)
      AND pm.prescreen_type_flag=0
      AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (pa
     WHERE pa.prot_master_id=pm.prot_master_id
      AND pa.amendment_status_cd=pm.prot_status_cd)
     JOIN (cfg
     WHERE cfg.protocol_type_cd=pa.participation_type_cd
      AND cfg.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND cfg.item_cd=registry_type_cd
      AND cfg.config_value_cd=registry_cfg_cd)
    HEAD REPORT
     prot_cnt = 0
    DETAIL
     prot_cnt += 1
     IF (prot_cnt > size(tctrequest->checkct,5))
      stat = alterlist(tctrequest->checkct,(prot_cnt+ 5)), stat = alterlist(eksctrequest->checkct,(
       prot_cnt+ 5))
     ENDIF
     tctrequest->checkct[prot_cnt].primary_mnemonic = pm.primary_mnemonic, tctrequest->checkct[
     prot_cnt].prot_master_id = pm.prot_master_id, eksctrequest->checkct[prot_cnt].primary_mnemonic
      = pm.primary_mnemonic,
     eksctrequest->checkct[prot_cnt].prot_master_id = pm.prot_master_id,
     CALL echo(build("prot is:",pm.primary_mnemonic))
    FOOT REPORT
     stat = alterlist(tctrequest->checkct,prot_cnt), stat = alterlist(eksctrequest->checkct,prot_cnt)
    WITH nocounter
   ;end select
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE (nextsequence(x=i2) =f8)
   DECLARE nsequence = f8 WITH protect
   SELECT INTO "nl:"
    nextseqnum = seq(protocol_def_seq,nextval)
    FROM dual
    DETAIL
     nsequence = nextseqnum
    WITH nocounter
   ;end select
   RETURN(nsequence)
 END ;Subroutine
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE syscancelcd = f8 WITH protect, constant(uar_get_code_by("MEANING",17901,"SYSCANCEL"))
 DECLARE pendingcd = f8 WITH protect, constant(uar_get_code_by("MEANING",17901,"PENDING"))
 DECLARE pendingjobcd = f8 WITH protect, constant(uar_get_code_by("MEANING",17917,"PENDING"))
 DECLARE institution_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17296,"INSTITUTION"))
 DECLARE reqsize = i4 WITH protect, noconstant(size(eksctrequest->qual,5))
 DECLARE allactivectind = i2 WITH noconstant(0)
 DECLARE activated_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17274,"ACTIVATED"))
 DECLARE concept_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17274,"CONCEPT"))
 DECLARE discontinued_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17274,"DISCONTINUED"))
 DECLARE prot_cnt = i4 WITH protect, noconstant(0)
 DECLARE chkctcnt = i4 WITH protect, noconstant(0)
 DECLARE allctind = i2 WITH protect, noconstant(0)
 DECLARE tindx = i4 WITH protect, noconstant(0)
 DECLARE tcnt = i4 WITH protect, noconstant(0)
 DECLARE notmovedcnt = i4 WITH protect, noconstant(0)
 DECLARE movept = i4 WITH protect, noconstant(0)
 DECLARE cctcnt = i4 WITH protect, noconstant(0)
 DECLARE curctmatchcnt = i4 WITH protect, noconstant(0)
 DECLARE cindx = i4 WITH protect, noconstant(0)
 DECLARE jindx = i4 WITH protect, noconstant(0)
 DECLARE screener_id = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE org_security_ind = i2 WITH protect, noconstant(0)
 DECLARE userorgstr = vc WITH protect
 DECLARE nindex = i4 WITH protect, noconstant(0)
 DECLARE ndefaultinterest = i2 WITH protect, noconstant(0)
 DECLARE allactivenonregind = i2 WITH protect, noconstant(0)
 DECLARE allactiveregind = i2 WITH protect, noconstant(0)
 DECLARE registry_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17906,"REGISTRY"))
 DECLARE cfg_yes_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17907,"YES"))
 DECLARE cfg_no_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17907,"NO"))
 DECLARE screener_pref = i2 WITH protect, noconstant(0)
 DECLARE status_cd_str = vc WITH protect
 DECLARE screener_str = vc WITH protect
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(0)
 DECLARE batch_size = i4 WITH protect, noconstant(0)
 DECLARE cur_list_size = i4 WITH protect, noconstant(0)
 DECLARE loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE new_list_size = i4 WITH protect, noconstant(0)
 DECLARE iptr = i4 WITH protect, noconstant(0)
 DECLARE xx = i4 WITH protect, noconstant(0)
 DECLARE yy = i4 WITH protect, noconstant(0)
 DECLARE zz = i4 WITH protect, noconstant(0)
 DECLARE ii = i4 WITH protect, noconstant(0)
 DECLARE jj = i4 WITH protect, noconstant(0)
 DECLARE new_long_text_id = f8 WITH protect, noconstant(0.0)
 DECLARE mcnt = i4 WITH protect, noconstant(0)
 DECLARE mindx = i4 WITH protect, noconstant(0)
 DECLARE msize = i4 WITH protect, noconstant(0)
 DECLARE beginindex = i4 WITH protect, noconstant(0)
 CALL echo(concat("Request contains ",build(reqsize)," entries...sysCancelCd = ",build(syscancelcd),
   "  PendingCd = ",
   build(pendingcd)))
 SET stat = alterlist(pinterest->qual,reqsize)
 SET stat = alterlist(tctrequest->qual,reqsize)
 SET tctrequest->opsind = eksctrequest->opsind
 SET tctrequest->execmodeflag = eksctrequest->execmodeflag
 SET tctrequest->screenerid = eksctrequest->screenerid
 SET screener_id = tctrequest->screenerid
 RECORD user_org_reply(
   1 organizations[*]
     2 organization_id = f8
     2 confid_cd = f8
     2 confid_level = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE userorgsize = i2 WITH protect, noconstant(0)
 DECLARE orgidx = i2 WITH protect, noconstant(0)
 DECLARE orgstr = vc WITH protect
 SUBROUTINE (builduserorglist(tablestr=vc) =vc)
   EXECUTE ct_get_user_orgs  WITH replace("REPLY","USER_ORG_REPLY")
   SET userorgsize = size(user_org_reply->organizations,5)
   IF (userorgsize > 0)
    SET orgstr = build("expand(orgIdx, 1, userOrgSize, ",tablestr,
     ", user_org_reply->organizations[orgIdx]->organization_id)")
   ELSE
    SET orgstr = "1=1"
   ENDIF
   RETURN(orgstr)
 END ;Subroutine
 SET pref_request->pref_entry = "default_interest"
 EXECUTE ct_get_pref  WITH replace("REQUEST_STRUCT","PREF_REQUEST"), replace("REPLY","PREF_REPLY")
 CALL echo(build("pref",pref_reply->pref_value))
 IF ((pref_reply->pref_value=1))
  SET ndefaultinterest = 1
  SET pinterest->notcnt = reqsize
 ELSE
  SET ndefaultinterest = 0
 ENDIF
 FOR (nindex = 1 TO reqsize)
   SET pinterest->qual[nindex].not_interested_ind = ndefaultinterest
 ENDFOR
 SET pinterest->notcnt = 0
 SET nstart = 1
 SET batch_size = 100
 SET idx = 0
 SET cur_list_size = reqsize
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(eksctrequest->qual,new_list_size)
 CALL echo("before ct_pt_settings")
 CALL echo(reqsize)
 IF (loop_cnt > 0)
  SELECT INTO "nl:"
   cps.not_interested_ind, cps.person_id
   FROM ct_pt_settings cps,
    (dummyt d1  WITH seq = value(loop_cnt))
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (cps
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),cps.person_id,eksctrequest->qual[idx].
     person_id)
     AND cps.active_ind=1)
   DETAIL
    iptr = locateval(idx,1,reqsize,cps.person_id,eksctrequest->qual[idx].person_id), pinterest->qual[
    iptr].not_interested_ind = cps.not_interested_ind
    IF (cps.not_interested_ind=1)
     CALL echo(concat("person_id = ",build(cps.person_id)," is not interested in Clinical Trials"))
     IF ((pref_reply->pref_value=0))
      pinterest->notcnt += 1
     ENDIF
    ELSE
     CALL echo(concat("person_id = ",build(cps.person_id)," is interested in Clinical Trials")),
     pinterest->notcnt -= 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(eksctrequest->qual,cur_list_size)
 IF ((pinterest->notcnt < reqsize))
  SET chkctcnt = size(eksctrequest->checkct,5)
  IF (chkctcnt > 0)
   SET allctind = 0
   SET stat = alterlist(tctrequest->checkct,chkctcnt)
   FOR (tindx = 1 TO chkctcnt)
     IF (cnvtupper(eksctrequest->checkct[tindx].primary_mnemonic)="*ALL TRIALS")
      SET allctind = 1
      CALL echo("ALL TRIALS detected")
      IF (chkctcnt > 1)
       SET stat = alterlist(eksctrequest->checkct,1)
       SET eksctrequest->checkct[1].primary_mnemonic = "*ALL TRIALS"
       SET eksctrequest->checkct[1].prot_master_id = 0.0
      ENDIF
      SET stat = alterlist(tctrequest->checkct,1)
      SET tctrequest->checkct[1].primary_mnemonic = "*ALL TRIALS"
      SET tctrequest->checkct[1].prot_master_id = 0.0
      SET tindx = chkctcnt
     ELSEIF (cnvtupper(eksctrequest->checkct[tindx].primary_mnemonic)="*ALL ACTIVE TRIALS")
      SET allactivectind = 1
     ELSEIF (cnvtupper(eksctrequest->checkct[tindx].primary_mnemonic)="*ALL ACTIVE NON REG TRIALS")
      SET allactivenonregind = 1
     ELSEIF (cnvtupper(eksctrequest->checkct[tindx].primary_mnemonic)="*ALL ACTIVE REG TRIALS")
      SET allactiveregind = 1
     ELSE
      SET tctrequest->checkct[tindx].primary_mnemonic = eksctrequest->checkct[tindx].primary_mnemonic
      SET tctrequest->checkct[tindx].prot_master_id = eksctrequest->checkct[tindx].prot_master_id
     ENDIF
   ENDFOR
   IF (((allactivectind=1) OR (((allactivenonregind=1) OR (allactiveregind=1)) )) )
    EXECUTE ct_get_org_security  WITH replace("REPLY","ORG_SEC_REPLY")
    CALL echo(build("org_sec_reply->OrgSecurityFlag: ",org_sec_reply->orgsecurityflag))
    SET org_security_ind = org_sec_reply->orgsecurityflag
    SET pref_request->pref_entry = "screener_pref"
    EXECUTE ct_get_pref  WITH replace("REQUEST_STRUCT","PREF_REQUEST"), replace("REPLY","PREF_REPLY")
    IF ((pref_reply->pref_value=2))
     CALL echo("screener_pref = 2")
     SET screener_pref = 2
     SET status_cd_str = "pm.prot_status_cd = concept_cd"
     SET screener_str = "((pm.screener_ind = 1) and (pm.network_flag < 2))"
    ELSE
     SET status_cd_str = "pm.prot_status_cd = activated_cd"
     SET screener_str = "1=1"
    ENDIF
   ENDIF
   IF (allactivectind=1)
    CALL getallactivediscernprotocols(org_security_ind,status_cd_str,screener_str)
    SET chkctcnt = size(eksctrequest->checkct,5)
    SET allctind = 1
   ELSEIF (allactivenonregind=1)
    CALL getactivediscernprotocols(org_security_ind,cfg_no_cd,status_cd_str,screener_str)
    SET chkctcnt = size(eksctrequest->checkct,5)
    SET allctind = 1
   ELSEIF (allactiveregind=1)
    CALL getactivediscernprotocols(org_security_ind,cfg_yes_cd,status_cd_str,screener_str)
    SET chkctcnt = size(eksctrequest->checkct,5)
    SET allctind = 1
   ENDIF
   IF (screener_pref=2)
    SET stat = alterlist(tctrequest->checkct,chkctcnt)
    SET stat = alterlist(history_request->protocol_list,chkctcnt)
    SET stat = alterlist(history_request->status_list,2)
    SET stat = alterlist(history_request->protocol_list,chkctcnt)
    SET history_request->status_list[1].prot_status_cd = concept_cd
    SET history_request->status_list[2].prot_status_cd = discontinued_cd
    FOR (idx = 0 TO chkctcnt)
      SET history_request->protocol_list[idx].prot_master_id = eksctrequest->checkct[idx].
      prot_master_id
      SET tctrequest->checkct[idx].prot_master_id = eksctrequest->checkct[idx].prot_master_id
      SET tctrequest->checkct[idx].primary_mnemonic = eksctrequest->checkct[idx].primary_mnemonic
    ENDFOR
    EXECUTE ct_get_prot_by_status_history  WITH replace("REQUEST","HISTORY_REQUEST"), replace("REPLY",
     "HISTORY_REPLY")
    SET qualifiedprotcnt = size(history_reply->protocol_list,5)
    SET stat = alterlist(eksctrequest->checkct,qualifiedprotcnt)
    FOR (idx = 0 TO qualifiedprotcnt)
      SET pos = locateval(num,1,chkctcnt,history_reply->protocol_list[idx].prot_master_id,tctrequest
       ->checkct[num].prot_master_id)
      SET eksctrequest->checkct[idx].prot_master_id = tctrequest->checkct[pos].prot_master_id
      SET eksctrequest->checkct[idx].primary_mnemonic = tctrequest->checkct[pos].primary_mnemonic
    ENDFOR
    SET chkctcnt = qualifiedprotcnt
   ENDIF
   SET pinterest->currentcnt = 0
   SET cur_list_size = reqsize
   SET batch_size = 10
   SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET stat = alterlist(eksctrequest->qual,new_list_size)
   SET nstart = 1
   SET idx = 0
   FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET eksctrequest->qual[idx].person_id = eksctrequest->qual[cur_list_size].person_id
    SET eksctrequest->qual[idx].encntr_id = eksctrequest->qual[cur_list_size].encntr_id
   ENDFOR
   SET idx = 0
   CALL echo(concat("new_list_size = ",build(new_list_size)))
   SELECT INTO "nl:"
    p_id = ppp.person_id, prot_id = ppp.prot_master_id, pmnemonic = pm1.primary_mnemonic,
    sstatuscd = ppp.screening_status_cd, ptable = sql_xxx1(ppp.updt_id,"1"), ppp_id = ppp
    .pt_prot_prescreen_id
    FROM (dummyt d1  WITH seq = value(loop_cnt)),
     pt_prot_prescreen ppp,
     prot_master pm1
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
     JOIN (ppp
     WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),ppp.person_id,eksctrequest->qual[idx].
      person_id)
      AND ppp.screening_status_cd != syscancelcd
      AND ppp.mode_ind=0
      AND ppp.added_via_flag=0)
     JOIN (pm1
     WHERE ppp.prot_master_id=pm1.prot_master_id
      AND ((pm1.prescreen_type_flag=0) UNION (
     (SELECT
      ppr.person_id, ppr.prot_master_id, pm2.primary_mnemonic,
      0.0, "0", 0.0
      FROM pt_prot_reg ppr,
       prot_master pm2
      WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),ppr.person_id,eksctrequest->qual[idx].
       person_id)
       AND ppr.prot_master_id=pm2.prot_master_id
       AND pm2.prescreen_type_flag=0
       AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate)))) )
    ORDER BY p_id, prot_id
    HEAD p_id
     ptr = locateval(idx,1,reqsize,p_id,eksctrequest->qual[idx].person_id),
     CALL echo(concat("Found existing trials for patient index ",build(ptr))), pinterest->currentcnt
      += 1
    HEAD prot_id
     pendingind = 0, pcancel_id = 0.0
    DETAIL
     CALL echo(concat("ppp.person_id = ",build(ppp.person_id),"  ppp.prot_master_id = ",build(ppp
       .prot_master_id),"  ppp.added_via_flag = ",
      build(ppp.added_via_flag),"  ppp.pt_prot_prescreen_id = ",build(ppp.pt_prot_prescreen_id),
      "   ppp.updt_id = ",build(ppp.updt_id),
      "  pTable = ",build(ptable)))
     IF (ptable)
      pmnemonic = pm1.primary_mnemonic
      IF (ppp.screening_status_cd=pendingcd)
       pendingind = 1, icancel = 0
       FOR (tindx = 1 TO chkctcnt)
         IF (cnvtupper(eksctrequest->checkct[tindx].primary_mnemonic)=cnvtupper(pm1.primary_mnemonic)
         )
          icancel = 1, tindx = chkctcnt
         ENDIF
       ENDFOR
       IF (icancel)
        syscancel->cnt += 1
        IF (mod(syscancel->cnt,100)=1)
         stat = alterlist(syscancel->qual,(syscancel->cnt+ 99))
        ENDIF
        syscancel->qual[syscancel->cnt].pt_prot_prescreen_id = ppp_id,
        CALL echo(concat(trim(pm1.primary_mnemonic),"  ",build(ppp_id),
         " was found pending and will be updated to SYSCANCEL"))
       ENDIF
      ENDIF
     ENDIF
    FOOT  prot_id
     IF ((pinterest->qual[ptr].not_interested_ind=0)
      AND  NOT (pendingind))
      ccnt = (size(eksctrequest->qual[ptr].currentct,5)+ 1), stat = alterlist(eksctrequest->qual[ptr]
       .currentct,ccnt), eksctrequest->qual[ptr].currentct[ccnt].prot_master_id = prot_id,
      eksctrequest->qual[ptr].currentct[ccnt].primary_mnemonic = pmnemonic,
      CALL echo(concat(eksctrequest->qual[ptr].currentct[ccnt].primary_mnemonic,
       " was added to currentCT with prot_id of ",build(prot_id)))
     ENDIF
    FOOT REPORT
     IF (syscancel->cnt)
      stat = alterlist(syscancel->qual,syscancel->cnt)
     ENDIF
    WITH nocounter, rdbunion
   ;end select
   SET stat = alterlist(eksctrequest->qual,reqsize)
   IF (allctind
    AND (pinterest->notcnt=0))
    CALL echo("Use EKSCTRequest AsIs")
   ELSE
    SET tcnt = 0
    SET notmovedcnt = 0
    FOR (tindx = 1 TO reqsize)
      SET movept = 0
      SET cctcnt = 0
      IF ((pinterest->qual[tindx].not_interested_ind=0))
       SET cctcnt = size(eksctrequest->qual[tindx].currentct,5)
       IF ( NOT (allctind)
        AND cctcnt)
        SET curctmatchcnt = 0
        SET jindx = 1
        WHILE (jindx <= chkctcnt)
         FOR (cindx = 1 TO cctcnt)
           IF (cnvtupper(eksctrequest->checkct[jindx].primary_mnemonic)=cnvtupper(eksctrequest->qual[
            tindx].currentct[cindx].primary_mnemonic))
            SET cindx = cctcnt
            SET curctmatchcnt += 1
           ENDIF
         ENDFOR
         SET jindx += 1
        ENDWHILE
        IF (curctmatchcnt=chkctcnt)
         SET notmovedcnt += 1
         CALL echo(concat("Patient ",build(tindx),
           " will not be evaluated since they have already been considered for all trials being evaluated"
           ))
        ELSE
         SET movept = 1
        ENDIF
       ELSE
        SET movept = 1
       ENDIF
      ELSE
       SET notmovedcnt += 1
       CALL echo(concat("Patient ",build(tindx),
         " will not be evaluated since they are not interested in any Clinical Trials"))
      ENDIF
      IF (movept)
       SET tcnt += 1
       SET tctrequest->qual[tcnt].person_id = eksctrequest->qual[tindx].person_id
       SET tctrequest->qual[tcnt].encntr_id = eksctrequest->qual[tindx].encntr_id
       SET tctrequest->qual[tcnt].order_id = eksctrequest->qual[tindx].order_id
       SET tctrequest->qual[tcnt].accession_id = eksctrequest->qual[tindx].accession_id
       SET tctrequest->qual[tcnt].sex_cd = eksctrequest->qual[tindx].sex_cd
       SET tctrequest->qual[tcnt].birth_dt_tm = eksctrequest->qual[tindx].birth_dt_tm
       SET tctrequest->qual[tcnt].race_cd = eksctrequest->qual[tindx].race_cd
       IF (cctcnt)
        SET stat = alterlist(tctrequest->qual[tcnt].currentct,cctcnt)
        FOR (cindx = 1 TO cctcnt)
         SET tctrequest->qual[tcnt].currentct[cindx].primary_mnemonic = eksctrequest->qual[tindx].
         currentct[cindx].primary_mnemonic
         SET tctrequest->qual[tcnt].currentct[cindx].prot_master_id = eksctrequest->qual[tindx].
         currentct[cindx].prot_master_id
        ENDFOR
       ENDIF
      ENDIF
    ENDFOR
    IF (notmovedcnt)
     CALL echo(concat(build(notmovedcnt),
       " patient(s) to be excluded, copying temp structure back to EKSCTRequest"))
     SET stat = alterlist(tctrequest->qual,tcnt)
     SET stat = initrec(eksctrequest)
     SET eksctrequest->opsind = tctrequest->opsind
     SET eksctrequest->execmodeflag = tctrequest->execmodeflag
     SET eksctrequest->screenerid = tctrequest->screenerid
     SET stat = alterlist(eksctrequest->qual,size(tctrequest->qual,5))
     FOR (xx = 1 TO size(tctrequest->qual,5))
       SET eksctrequest->qual[xx].person_id = tctrequest->qual[xx].person_id
       SET eksctrequest->qual[xx].encntr_id = tctrequest->qual[xx].encntr_id
       SET eksctrequest->qual[xx].order_id = tctrequest->qual[xx].order_id
       SET eksctrequest->qual[xx].accession_id = tctrequest->qual[xx].accession_id
       SET eksctrequest->qual[xx].sex_cd = tctrequest->qual[xx].sex_cd
       SET eksctrequest->qual[xx].birth_dt_tm = tctrequest->qual[xx].birth_dt_tm
       SET eksctrequest->qual[xx].race_cd = tctrequest->qual[xx].race_cd
       IF (size(tctrequest->qual[xx].currentct,5) > 0)
        SET stat = alterlist(eksctrequest->qual[xx].currentct,size(tctrequest->qual[xx].currentct,5))
        FOR (yy = 1 TO size(tctrequest->qual[xx].currentct,5))
         SET eksctrequest->qual[xx].currentct[yy].prot_master_id = tctrequest->qual[xx].currentct[yy]
         .prot_master_id
         SET eksctrequest->qual[xx].currentct[yy].primary_mnemonic = tctrequest->qual[xx].currentct[
         yy].primary_mnemonic
        ENDFOR
       ENDIF
     ENDFOR
     SET stat = alterlist(eksctrequest->checkct,size(tctrequest->checkct,5))
     FOR (zz = 1 TO size(tctrequest->checkct,5))
      SET eksctrequest->checkct[zz].prot_master_id = tctrequest->checkct[zz].prot_master_id
      SET eksctrequest->checkct[zz].primary_mnemonic = tctrequest->checkct[zz].primary_mnemonic
     ENDFOR
     SET reqsize = size(eksctrequest->qual,5)
    ENDIF
   ENDIF
   CALL echorecord(eksctrequest)
   SELECT INTO "nl:"
    ppp.person_id
    FROM pt_prot_prescreen ppp,
     prot_master pm
    PLAN (ppp
     WHERE ppp.added_via_flag=1)
     JOIN (pm
     WHERE pm.prot_master_id=ppp.prot_master_id)
    HEAD REPORT
     mcnt = 0
    DETAIL
     mcnt += 1
     IF (mod(mcnt,10)=1)
      stat = alterlist(manuallyadded->qual,(mcnt+ 9))
     ENDIF
     manuallyadded->qual[mcnt].person_id = ppp.person_id, manuallyadded->qual[mcnt].prot_id = ppp
     .prot_master_id, manuallyadded->qual[mcnt].primary_mnemonic = pm.primary_mnemonic
    FOOT REPORT
     stat = alterlist(manuallyadded->qual,mcnt), manuallyadded->qual_cnt = mcnt
    WITH nocounter
   ;end select
   CALL echorecord(manuallyadded)
   FOR (mindx = 1 TO size(eksctrequest->qual,5))
     SET pos = 1
     SET beginindex = 1
     CALL echo(pos)
     WHILE (pos != 0)
       SET pos = locateval(idx,beginindex,manuallyadded->qual_cnt,eksctrequest->qual[mindx].person_id,
        manuallyadded->qual[idx].person_id)
       CALL echo(pos)
       IF (pos != 0)
        SET msize = (size(eksctrequest->qual[mindx].currentct,5)+ 1)
        SET stat = alterlist(eksctrequest->qual[mindx].currentct,msize)
        SET eksctrequest->qual[mindx].currentct[msize].primary_mnemonic = manuallyadded->qual[pos].
        primary_mnemonic
        SET eksctrequest->qual[mindx].currentct[msize].prot_master_id = manuallyadded->qual[pos].
        prot_id
       ENDIF
       SET beginindex = (pos+ 1)
     ENDWHILE
   ENDFOR
   CALL echorecord(eksctrequest)
   IF (reqsize)
    CALL echo(concat("execModeFlag = ",build(eksctrequest->execmodeflag)))
    IF ((eksctrequest->execmodeflag > 0)
     AND syscancel->cnt)
     IF (screener_id=0)
      SET screener_id = reqinfo->updt_id
     ENDIF
     CALL echo(concat(build(screener_id)," Updating ",build(syscancel->cnt),
       " row(s) on the PT_PROT_PRESCREEN table to SYSCANCEL  ",build(syscancelcd)))
     SET idx = 0
     UPDATE  FROM pt_prot_prescreen ppp
      SET ppp.screening_status_cd = syscancelcd, ppp.updt_id = screener_id, ppp.updt_dt_tm =
       cnvtdatetime(sysdate),
       ppp.updt_cnt = (ppp.updt_cnt+ 1), ppp.comment_text = concat("SYSCANCEL:  ",trim(ppp
         .comment_text))
      WHERE expand(idx,1,syscancel->cnt,ppp.pt_prot_prescreen_id,syscancel->qual[idx].
       pt_prot_prescreen_id)
      WITH nocounter
     ;end update
     COMMIT
    ENDIF
    IF ((((eksctrequest->execmodeflag=1)) OR ((eksctrequest->execmodeflag=0)))
     AND (eksctrequest->opsind=1))
     IF (pending_job_created_ind=0)
      SET pending_job_created_ind = 1
      SET prescreen_parent_job_id = nextsequence(0)
      CALL echo(build("ct_run_prescreen:prescreen_parent_job_id = ",prescreen_parent_job_id))
      CALL echo(build("JobDetailRequest->type_flag = ",jobdetailrequest->type_flag))
      CALL echo(build("JobDetailRequest->job_details = ",jobdetailrequest->job_details))
      SET new_long_text_id = nextlongtextsequence(0)
      CALL echo(build("new_long_text_id = ",new_long_text_id))
      IF (insert_long_text(new_long_text_id,jobdetailrequest->job_details,"ct_prescreen_job",
       prescreen_parent_job_id) != true)
       SET new_long_text_id = 0
      ENDIF
      INSERT  FROM ct_prescreen_job cpj
       SET cpj.ct_prescreen_job_id = prescreen_parent_job_id, cpj.prsnl_id = reqinfo->updt_id, cpj
        .job_type_flag = jobdetailrequest->type_flag,
        cpj.job_start_dt_tm = cnvtdatetime(sysdate), cpj.job_status_cd = pendingjobcd, cpj
        .long_text_id = new_long_text_id,
        cpj.updt_cnt = 1, cpj.updt_id = reqinfo->updt_id, cpj.updt_task = reqinfo->updt_task,
        cpj.updt_applctx = reqinfo->updt_applctx, cpj.updt_dt_tm = cnvtdatetime(sysdate)
       WITH nocounter
      ;end insert
      SET prot_cnt = size(eksctrequest->checkct,5)
      INSERT  FROM (dummyt d  WITH seq = prot_cnt),
        ct_prot_prescreen_job_info cji
       SET cji.ct_prot_prescreen_job_info_id = cnvtreal(seq(protocol_def_seq,nextval)), cji
        .ct_prescreen_job_id = prescreen_parent_job_id, cji.prot_master_id = eksctrequest->checkct[d
        .seq].prot_master_id,
        cji.completed_flag = 0, cji.chunk_nbr = chunks, cji.updt_cnt = 0,
        cji.updt_id = reqinfo->updt_id, cji.updt_task = reqinfo->updt_task, cji.updt_applctx =
        reqinfo->updt_applctx
       PLAN (d)
        JOIN (cji)
       WITH nocounter
      ;end insert
     ENDIF
    ENDIF
    COMMIT
    CALL srvrequest(0)
   ENDIF
  ELSE
   CALL echo("No trials were specified to be evaluated")
  ENDIF
 ENDIF
 SET stat = alterlist(reply->qual,size(eksctreply->qual,5))
 SET reply->ctfndind = eksctreply->ctfndind
 FOR (ii = 1 TO size(eksctreply->qual,5))
   SET reply->qual[ii].person_id = eksctreply->qual[ii].person_id
   SET reply->qual[ii].encntr_id = eksctreply->qual[ii].encntr_id
   SET reply->qual[ii].ctcnt = eksctreply->qual[ii].ctcnt
   IF (reply->qual[ii].ctcnt)
    SET stat = alterlist(reply->qual[ii].ctqual,reply->qual[ii].ctcnt)
    FOR (jj = 1 TO reply->qual[ii].ctcnt)
      SET reply->qual[ii].ctqual[jj].pt_prot_prescreen_id = eksctreply->qual[ii].ctqual[jj].
      pt_prot_prescreen_id
      SET reply->qual[ii].ctqual[jj].primary_mnemonic = eksctreply->qual[ii].ctqual[jj].
      primary_mnemonic
      SET reply->qual[ii].ctqual[jj].prot_master_id = eksctreply->qual[ii].ctqual[jj].prot_master_id
      SET reply->qual[ii].ctqual[jj].comment = eksctreply->qual[ii].ctqual[jj].comment
    ENDFOR
   ENDIF
 ENDFOR
 SET reply->status_data.status = eksctreply->status_data.status
 SET last_mod = "015"
 SET mod_date = "January 14, 2019"
END GO
