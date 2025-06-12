CREATE PROGRAM bhs_oen_bmd_mgmt:dba
 DECLARE acct_nbr = vc
 DECLARE unit = vc
 DECLARE bed = vc
 DECLARE room = vc
 DECLARE tmp1 = vc
 DECLARE fac_id = vc
 DECLARE loc_type_cd = vc
 SET acct_nbr = cnvtstring(acct_id)
 SET unit = unit_param
 SET bed = bed_param
 SET room = rm_param
 SET fac_id = facility_id
 SET loc_cd = location_type_cd
 SET tmp1 = temp_status
 SET bed_code = ed_bmd_mgmt_param
 RECORD eksopsrequest(
   1 expert_trigger = vc
   1 qual[*]
     2 person_id = f8
     2 sex_cd = f8
     2 birth_dt_tm = dq8
     2 encntr_id = f8
     2 accession_id = f8
     2 order_id = f8
     2 data[*]
       3 vc_var = vc
       3 double_var = f8
       3 long_var = i4
       3 short_var = i2
 )
 SELECT INTO "NL:"
  e.encntr_id, e.person_id, e.reg_dt_tm,
  p.birth_dt_tm, p.sex_cd
  FROM encntr_alias ea,
   person p,
   encounter e
  PLAN (ea
   WHERE ea.alias=acct_nbr
    AND ea.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
  HEAD REPORT
   cnt = 0, eksopsrequest->expert_trigger = "bhs_oen_bmd_mgmt"
  DETAIL
   cnt = 1, stat = alterlist(eksopsrequest->qual,1), stat = alterlist(eksopsrequest->qual[1].data,1),
   CALL echo("inside detail section"), eksopsrequest->qual[cnt].person_id = p.person_id,
   eksopsrequest->qual[cnt].sex_cd = p.sex_cd,
   eksopsrequest->qual[cnt].birth_dt_tm = p.birth_dt_tm, eksopsrequest->qual[cnt].encntr_id = e
   .encntr_id, eksopsrequest->qual[cnt].data[1].vc_var = build(bed_code,"~",unit,"~",room,
    "~",bed,"~",fac_id,"~",
    loc_cd,"~",tmp1)
  FOOT REPORT
   stat = alterlist(eksopsrequest->qual,cnt)
  WITH nocounter
 ;end select
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
   SET req = 3091001
   SET happ = 0
   SET app = 3055000
   SET task = 4801
   SET endapp = 0
   SET endtask = 0
   SET endreq = 0
   CALL echo(concat("curenv = ",build(curenv)))
   IF (curenv=0)
    EXECUTE srvrtl
    EXECUTE crmrtl
    EXECUTE cclseclogin
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
      SET heksopsrequest = uar_crmgetrequest(hreq)
      IF (heksopsrequest=null)
       SET retval = - (1)
       CALL echo("Invalid request handle return from CrmGetRequest")
      ELSE
       SET stat = uar_srvsetstring(heksopsrequest,"EXPERT_TRIGGER",nullterm(eksopsrequest->
         expert_trigger))
       FOR (ndx1 = 1 TO size(eksopsrequest->qual,5))
        SET hqual = uar_srvadditem(heksopsrequest,"QUAL")
        IF (hqual=null)
         CALL echo("QUAL","Invalid handle")
        ELSE
         SET stat = uar_srvsetdouble(hqual,"PERSON_ID",eksopsrequest->qual[ndx1].person_id)
         SET stat = uar_srvsetdouble(hqual,"SEX_CD",eksopsrequest->qual[ndx1].sex_cd)
         SET recdate->datetime = eksopsrequest->qual[ndx1].birth_dt_tm
         SET stat = uar_srvsetdate2(hqual,"BIRTH_DT_TM",recdate)
         SET stat = uar_srvsetdouble(hqual,"ENCNTR_ID",eksopsrequest->qual[ndx1].encntr_id)
         SET stat = uar_srvsetdouble(hqual,"ACCESSION_ID",eksopsrequest->qual[ndx1].accession_id)
         SET stat = uar_srvsetdouble(hqual,"ORDER_ID",eksopsrequest->qual[ndx1].order_id)
         FOR (ndx2 = 1 TO size(eksopsrequest->qual[ndx1].data,5))
          SET hdata = uar_srvadditem(hqual,"DATA")
          IF (hdata=null)
           CALL echo("DATA","Invalid handle")
          ELSE
           SET stat = uar_srvsetstring(hdata,"VC_VAR",nullterm(eksopsrequest->qual[ndx1].data[ndx2].
             vc_var))
           SET stat = uar_srvsetdouble(hdata,"DOUBLE_VAR",eksopsrequest->qual[ndx1].data[ndx2].
            double_var)
           SET stat = uar_srvsetlong(hdata,"LONG_VAR",eksopsrequest->qual[ndx1].data[ndx2].long_var)
           SET stat = uar_srvsetshort(hdata,"SHORT_VAR",eksopsrequest->qual[ndx1].data[ndx2].
            short_var)
          ENDIF
         ENDFOR
         SET retval = 100
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
 SET dparam = 0
 CALL srvrequest(dparam)
 CALL echorecord(request)
 CALL echorecord(reqinfo)
 SET retval = 100
END GO
