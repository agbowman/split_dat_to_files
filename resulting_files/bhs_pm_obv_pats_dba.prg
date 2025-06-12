CREATE PROGRAM bhs_pm_obv_pats:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
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
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET prt_loc = value( $1)
 SET prg_name = "s_cn_diet_rpt_by_ops"
 SET rpt_name = "Patient Unit Meal Report - "
 SET call_echo = 1
 SET call_echo = 0
 DECLARE es_cd = f8
 DECLARE et_cd = f8
 SET es_cd = 0.0
 SET et_cd = 0.0
 SET cmpt_day = format(cnvtlookbehind("1,H",cnvtdatetime(curdate,curtime)),";;q")
 SET run_dt_tm = cnvtdatetime(curdate,curtime3)
 SET try_dttm = cnvtdatetime(cmpt_day)
 SELECT INTO "nl:"
  cv = cv.code_value, d_key = cv.display_key
  FROM code_value cv
  WHERE cv.code_set IN (71, 261)
   AND cv.active_ind=1
  DETAIL
   CASE (d_key)
    OF "OBSERVATION":
     et_cd = cv
    OF "ACTIVE":
     es_cd = cv
   ENDCASE
  WITH check, nocounter
 ;end select
 SET lookback = cnvtlookbehind("5,M",cnvtdatetime(curdate,curtime3))
 SET d1 = cnvtdatetime("05-jun-2003 11:04:00.00")
 IF (call_echo)
  CALL echo(build("et_cd =",et_cd))
  CALL echo(build("es_cd =",es_cd))
  CALL echo(build("cmpt_day =",cmpt_day))
  CALL echo(build("try_dttm =",try_dttm))
  CALL echo(build("run_dt_tm = ",run_dt_tm))
  CALL echo(build("lookback = ",lookback))
  CALL echo(build("d1 = ",d1))
 ENDIF
 DELETE  FROM bhs_observe_temp temp
  WHERE temp.person_id > 0
   AND temp.encntr_id > 0
 ;end delete
 COMMIT
 INSERT  FROM bhs_observe_temp b
  (b.person_id, b.encntr_id, b.reg_dt_tm)(SELECT
   p.person_id, e.encntr_id, e.reg_dt_tm
   FROM person p,
    encounter e
   WHERE e.encntr_type_cd=et_cd
    AND p.person_id > 0
    AND e.encntr_id > 0
    AND e.encntr_status_cd=es_cd
    AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND e.reg_dt_tm <= cnvtlookbehind("1,H",cnvtdatetime(curdate,curtime3))
    AND p.person_id=e.person_id
    AND p.active_ind=1
   WITH check)
 ;end insert
 COMMIT
 DELETE  FROM bhs_observe_temp temp
  WHERE (temp.person_id=
  (SELECT
   perm.person_id
   FROM bhs_observe_perm perm
   WHERE perm.person_id > 0
    AND perm.person_id=temp.person_id))
   AND (temp.encntr_id=
  (SELECT
   perm.encntr_id
   FROM bhs_observe_perm perm
   WHERE perm.encntr_id > 0
    AND perm.encntr_id=temp.encntr_id))
 ;end delete
 COMMIT
 SELECT INTO "nl:"
  temp.person_id, temp.encntr_id
  FROM bhs_observe_temp temp
  HEAD REPORT
   cnt = 0, eksopsrequest->expert_trigger = "bhs_pm_obv_pats"
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(eksopsrequest->qual,cnt), eksopsrequest->qual[cnt].person_id =
   temp.person_id,
   eksopsrequest->qual[cnt].encntr_id = temp.encntr_id
  WITH check, nocounter
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
   CALL echo(concat("curenv = ",build(curenv)))
   IF (curenv=0)
    EXECUTE srvrtl
    EXECUTE crmrtl
    EXECUTE cclseclogin
    SET crmstatus = uar_crmbeginapp(app,happ)
    CALL echo(concat("beginapp status = ",build(crmstatus)))
   ELSE
    SET happ = uar_crmgetapphandle()
   ENDIF
   IF (happ > 0)
    SET crmstatus = uar_crmbegintask(happ,task,htask)
    IF (crmstatus != ecrmok)
     CALL echo("Invalid CrmBeginTask return status")
     SET retval = - (1)
    ELSE
     SET crmstatus = uar_crmbeginreq(htask,0,req,hreq)
     IF (crmstatus != ecrmok)
      SET retval = - (1)
      CALL echo(concat("Invalid CrmBeginReq return status of ",build(crmstatus)))
     ELSEIF (hreq=null)
      SET retval = - (1)
      CALL echo("Invalid hReq handle")
     ELSE
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
   CALL echo("Ending CRM Request")
   CALL uar_crmendreq(hreq)
 END ;Subroutine
 SET dparam = 0
 CALL srvrequest(dparam)
 CALL echorecord(eksopsrequest)
 INSERT  FROM bhs_observe_perm perm
  (perm.person_id, perm.encntr_id, perm.reg_dt_tm)(SELECT
   temp.person_id, temp.encntr_id, temp.reg_dt_tm
   FROM bhs_observe_temp temp
   WITH check)
 ;end insert
 COMMIT
#exit_script
 IF (validate(request->ops_date,999) != 999)
  SET reply->status_data.status = "S"
 ENDIF
END GO
