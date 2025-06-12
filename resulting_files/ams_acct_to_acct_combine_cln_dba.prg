CREATE PROGRAM ams_acct_to_acct_combine_cln:dba
 RECORD reply(
   1 status = c1
   1 message = vc
   1 acct_combines[1]
     2 fromacctid = f8
     2 toacctid = f8
     2 status = c1
     2 message = vc
     2 clone_merge[*]
       3 frompftencntrid = f8
       3 topftencntrid = f8
       3 status = c1
       3 message = vc
 )
 SET reply->status = "F"
 DECLARE cs18936_patient_cd = f8 WITH constant(getcodevalue(18936,"PATIENT",0)), protect
 DECLARE cs222_facility_cd = f8 WITH constant(getcodevalue(222,"FACILITY",0)), protect
 DECLARE updt_task = i4 WITH constant(- (8675309)), protect
 DECLARE fromacctid = f8 WITH noconstant(0.0), protect
 DECLARE toacctid = f8 WITH noconstant(0.0), protect
 DECLARE personid = f8 WITH noconstant(0.0), protect
 SET reqinfo->updt_task = updt_task
 IF ((request->fromacctid > 0.0))
  SET fromacctid = request->fromacctid
  SET reply->acct_combines[1].fromacctid = request->fromacctid
 ELSE
  SET reply->status = "F"
  SET reply->message = "INVALID PARAMETERS: (request->fromAcctId)"
  GO TO exit_script
 ENDIF
 IF ((request->toacctid > 0.0))
  SET toacctid = request->toacctid
  SET reply->acct_combines[1].toacctid = request->toacctid
 ELSE
  SET reply->status = "F"
  SET reply->message = "INVALID PARAMETERS: (request->toAcctId)"
  GO TO exit_script
 ENDIF
 DECLARE checklogicaldomain(personid=f8) = i2
 DECLARE getpersonid(fromacctid=f8,toacctid=f8) = i2
 DECLARE checktimezoneandbillingentity(fromacctid=f8,toacctid=f8) = i2
 DECLARE runprofitaccountcombine(fromacctid=f8,toacctid=f8) = i2
 DECLARE removeaccountreltnrows(fromacctid=f8) = i2
 DECLARE clonemerge(toacctid=f8) = i2
 DECLARE getcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) = f8 WITH private, protect
 IF ( NOT (getpersonid(fromacctid,toacctid)))
  GO TO exit_script
 ENDIF
 IF ( NOT (checktimezoneandbillingentity(toacctid,fromacctid)))
  GO TO exit_script
 ENDIF
 IF ( NOT (checklogicaldomain(personid)))
  GO TO exit_script
 ENDIF
 IF ( NOT (runprofitaccountcombine(toacctid,fromacctid)))
  GO TO exit_script
 ENDIF
 IF ( NOT (clonemerge(toacctid)))
  SET reply->status = "F"
  SET reply->acct_combines[1].status = "F"
  SET reply->acct_combines[1].message = "FAILED CLONEMERGE"
  GO TO exit_script
 ENDIF
 CALL removeaccountreltnrows(fromacctid)
 IF ( NOT (checklogicaldomain(personid)))
  GO TO exit_script
 ENDIF
 SET reqinfo->updt_task = 0
 SET reply->status = "S"
 SET reply->message = "ITS ALL GOOD!"
 SUBROUTINE removeaccountreltnrows(fromacctid)
  UPDATE  FROM pft_acct_reltn par
   SET par.role_type_cd = 0.0, par.updt_task = updt_task, par.updt_id = reqinfo->updt_id,
    par.updt_dt_tm = cnvtdatetime(curdate,curtime), par.updt_cnt = (updt_cnt+ 1), par.active_ind =
    false
   WHERE par.acct_id=fromacctid
    AND par.active_ind=false
    AND par.updt_task=updt_task
    AND par.parent_entity_name="PERSON"
    AND par.role_type_cd=cs18936_patient_cd
   WITH nocounter
  ;end update
  RETURN(true)
 END ;Subroutine
 SUBROUTINE getpersonid(fromacctid,toacctid)
   DECLARE personcnt = i4 WITH noconstant(0)
   DECLARE accountcnt = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM account a,
     pft_acct_reltn par,
     person p
    PLAN (a
     WHERE a.acct_id IN (fromacctid, toacctid)
      AND a.active_ind=true)
     JOIN (par
     WHERE par.acct_id=a.acct_id
      AND par.active_ind=true
      AND par.parent_entity_name="PERSON"
      AND par.role_type_cd=cs18936_patient_cd)
     JOIN (p
     WHERE p.person_id=par.parent_entity_id)
    ORDER BY par.parent_entity_id, a.acct_id
    HEAD par.parent_entity_id
     personcnt = (personcnt+ 1), personid = par.parent_entity_id
    HEAD a.acct_id
     accountcnt = (accountcnt+ 1)
    WITH nocounter
   ;end select
   IF (personcnt > 1)
    SET reply->status = "F"
    SET reply->message = "ACCOUNTS ARE NOT FROM SAME PERSON"
    RETURN(false)
   ENDIF
   IF (accountcnt < 2)
    SET reply->status = "F"
    SET reply->message = "ACCOUNTS ID'S ARE NOT VALID"
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE clonemerge(toacctid)
   DECLARE encntrcnt = i4 WITH noconstant(0), protect
   DECLARE cloneidx = i4 WITH noconstant(0), protect
   DECLARE frompftencntrid = f8 WITH noconstant(0), protect
   DECLARE topftencntrid = f8 WITH noconstant(0), protect
   RECORD cloneencounter(
     1 objarray[*]
       2 encntrid = f8
       2 firstpftencntrid = f8
       2 lastpftencntrid = f8
   ) WITH protect
   SELECT INTO "nl:"
    FROM pft_encntr pe
    WHERE pe.acct_id=toacctid
     AND pe.active_ind=true
     AND pe.recur_ind=0
    ORDER BY pe.encntr_id, pe.pft_encntr_id
    HEAD pe.encntr_id
     firstpftencntrid = pe.pft_encntr_id
    FOOT  pe.encntr_id
     IF (firstpftencntrid != pe.pft_encntr_id)
      encntrcnt = (encntrcnt+ 1), stat = alterlist(cloneencounter->objarray,encntrcnt),
      cloneencounter->objarray[encntrcnt].encntrid = pe.encntr_id,
      cloneencounter->objarray[encntrcnt].firstpftencntrid = firstpftencntrid, cloneencounter->
      objarray[encntrcnt].lastpftencntrid = pe.pft_encntr_id
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM pft_encntr pe,
     pft_encntr pe1
    PLAN (pe
     WHERE pe.acct_id=toacctid
      AND pe.active_ind=true
      AND pe.recur_ind=1)
     JOIN (pe1
     WHERE pe1.acct_id=toacctid
      AND pe1.active_ind=true
      AND pe1.recur_ind=1
      AND pe1.encntr_id=pe.encntr_id
      AND pe1.recur_current_year=pe.recur_current_year
      AND pe1.recur_current_month=pe.recur_current_month
      AND pe1.pft_encntr_id != pe.pft_encntr_id)
    ORDER BY pe.pft_encntr_id
    HEAD pe.pft_encntr_id
     encntrcnt = (encntrcnt+ 1)
     IF (locateval(cloneidx,1,size(cloneencounter->objarray,5),pe.pft_encntr_id,cloneencounter->
      objarray[cloneidx].lastpftencntrid)=0)
      stat = alterlist(cloneencounter->objarray,encntrcnt), cloneencounter->objarray[encntrcnt].
      encntrid = pe.encntr_id, cloneencounter->objarray[encntrcnt].firstpftencntrid = pe
      .pft_encntr_id,
      cloneencounter->objarray[encntrcnt].lastpftencntrid = pe1.pft_encntr_id
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->acct_combines[1].clone_merge,size(cloneencounter->objarray,5))
   FOR (cloneidx = 1 TO size(cloneencounter->objarray,5))
     FREE RECORD fincmbrequest
     RECORD fincmbrequest(
       1 objarray[2]
         2 src_pft_encntr_id = f8
         2 tgt_pft_encntr_id = f8
     )
     FREE RECORD fincmbreply
     RECORD fincmbreply(
       1 status_data
         2 status = c1
         2 subeventstatus[1]
           3 operationname = c25
           3 operationstatus = c1
           3 targetobjectname = c25
           3 targetobjectvalue = vc
       1 pft_status_data
         2 status = c1
         2 subeventstatus[*]
           3 status = c1
           3 table_name = vc
           3 pk_values = vc
       1 mod_objs[*]
         2 entity_type = vc
         2 mod_recs[*]
           3 table_name = vc
           3 pk_values = vc
           3 mod_flds[*]
             4 field_name = vc
             4 field_type = vc
             4 field_value_obj = vc
             4 field_value_db = vc
       1 failure_stack
         2 failures[*]
           3 programname = vc
           3 routinename = vc
           3 message = vc
     )
     SET frompftencntrid = cloneencounter->objarray[cloneidx].lastpftencntrid
     SET topftencntrid = cloneencounter->objarray[cloneidx].firstpftencntrid
     SET reply->acct_combines[1].clone_merge[cloneidx].frompftencntrid = frompftencntrid
     SET reply->acct_combines[1].clone_merge[cloneidx].topftencntrid = topftencntrid
     SET fincmbrequest->objarray[1].src_pft_encntr_id = frompftencntrid
     SET fincmbrequest->objarray[1].tgt_pft_encntr_id = topftencntrid
     SET fincmbrequest->objarray[2].src_pft_encntr_id = topftencntrid
     SET fincmbrequest->objarray[2].tgt_pft_encntr_id = topftencntrid
     IF (frompftencntrid > 0
      AND topftencntrid > 0)
      EXECUTE pft_combine_financial_encntr  WITH replace("REQUEST",fincmbrequest), replace("REPLY",
       fincmbreply)
     ELSE
      SET reply->acct_combines[1].clone_merge[cloneidx].message = build(
       "INVALID INPUT TO PFT_COMBINE_FINANCIAL_ENCNTR:from_pft_encntr_od|to_pft_encntr_id",
       frompftencntrid,"|",topftencntrid)
      SET reply->acct_combines[1].clone_merge[cloneidx].status = "F"
      SET reply->status = "F"
      SET reply->message = "PROBLEMS COMBINING FIN ENCOUNTERS"
      RETURN(false)
     ENDIF
     IF ((fincmbreply->status_data.status != "S"))
      SET reply->acct_combines[1].clone_merge[cloneidx].message =
      "PFT_COMBINE_FINANCIAL_ENCNTR DID NOT RETURN SUCCESS"
      SET reply->acct_combines[1].clone_merge[cloneidx].status = "F"
      SET reply->status = "F"
      SET reply->message = "COMBINING FIN ENCOUNTERS FAILED"
      RETURN(false)
     ENDIF
     SET reply->acct_combines[1].clone_merge[cloneidx].status = "S"
     SET reply->acct_combines[1].clone_merge[cloneidx].message = "SUCCESSFUL"
   ENDFOR
   RETURN(true)
 END ;Subroutine
 SUBROUTINE checklogicaldomain(personid)
   IF ((reqinfo->updt_id=0))
    SET reply->status = "F"
    SET reply->message = build("YOU MUST BE LOGGED INTO CCL")
    RETURN(false)
   ENDIF
   SELECT INTO "nl:"
    FROM person p,
     prsnl p1
    PLAN (p
     WHERE p.person_id=personid)
     JOIN (p1
     WHERE (p1.person_id=reqinfo->updt_id)
      AND p1.logical_domain_id=p.logical_domain_id)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->status = "F"
    SET reply->message = "USER AND ACCOUNT LOGICAL DOMAINS DONT MATCH"
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE checktimezoneandbillingentity(fromacctid,toacctid)
   DECLARE timezoneidx = i4 WITH noconstant(0)
   DECLARE billingentitycnt = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM account a,
     billing_entity be,
     organization o,
     location l,
     time_zone_r tzr
    PLAN (a
     WHERE a.acct_id IN (fromacctid, toacctid)
      AND a.active_ind=true)
     JOIN (be
     WHERE be.billing_entity_id=a.billing_entity_id
      AND be.active_ind=true)
     JOIN (o
     WHERE o.organization_id=be.organization_id
      AND o.active_ind=true)
     JOIN (l
     WHERE l.organization_id=o.organization_id
      AND l.location_type_cd=cs222_facility_cd
      AND l.active_ind=true
      AND l.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND l.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (tzr
     WHERE outerjoin(l.location_cd)=tzr.parent_entity_id
      AND outerjoin("LOCATION")=tzr.parent_entity_name)
    ORDER BY be.billing_entity_id
    HEAD be.billing_entity_id
     billingentitycnt = (billingentitycnt+ 1), timezoneidx = datetimezonebyname(tzr.time_zone)
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    SET reply->status = "F"
    SET reply->message = "FAILED TO GET TIME ZONE"
    RETURN(false)
   ENDIF
   IF (billingentitycnt > 1)
    SET reply->status = "F"
    SET reply->message = "ACCOUNTS ARE NOT FROM SAME BILLING ENTITY"
    RETURN(false)
   ENDIF
   IF (timezoneidx != datetimezonebyname(curtimezone)
    AND timezoneidx != 0)
    SET reply->status = "F"
    SET reply->message = "DOMAIN AND ACCOUNT TIME ZONES DO NOT MATCH"
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE getcodevalue(code_set,cdf_meaning,option_flag)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0.0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      SET pft_failed = uar_error
      EXECUTE pft_log "getcodevalue", pa_table_name, 0
      SET reply->status = "F"
      SET reply->message = build("FAILED TO ACQUIRE CODE VALUE:CDFMEANING|CODE_SET:",cdfmeaning,"|",
       code_set)
      GO TO exit_script
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 SUBROUTINE runprofitaccountcombine(toacctid,fromacctid)
   RECORD acctrequest(
     1 parent_acct_id = f8
     1 child_acct_id = f8
   ) WITH protect
   RECORD acctreply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c8
         3 operationstatus = c1
         3 targetobjectname = c15
         3 targetobjectvalue = c100
     1 pft_status_data
       2 status = c1
       2 subeventstatus[*]
         3 status = c1
         3 table_name = vc
         3 pk_values = vc
     1 mod_objs[*]
       2 entity_type = vc
       2 mod_recs[*]
         3 table_name = vc
         3 pk_values = vc
         3 mod_flds[*]
           4 field_name = vc
           4 field_type = vc
           4 field_value_obj = vc
           4 field_value_db = vc
     1 failure_stack
       2 failures[*]
         3 programname = vc
         3 routinename = vc
         3 message = vc
   ) WITH protect
   SET acctrequest->parent_acct_id = toacctid
   SET acctrequest->child_acct_id = fromacctid
   EXECUTE pft_mod_acct_acct_combine  WITH replace("REQUEST",acctrequest), replace("REPLY",acctreply)
   IF ((acctreply->status_data.status="F"))
    SET reply->status = "F"
    SET reply->message = build("THE COMBINE FAILED")
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
#exit_script
 IF (request->debugmode)
  CALL echorecord(reply)
 ENDIF
END GO
