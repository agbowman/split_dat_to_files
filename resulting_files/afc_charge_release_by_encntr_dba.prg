CREATE PROGRAM afc_charge_release_by_encntr:dba
 EXECUTE crmrtl
 EXECUTE srvrtl
 DECLARE hreq = i4
 DECLARE releaseappid = i4
 DECLARE releasetaskid = i4
 DECLARE releasereqid = i4
 DECLARE happrelease = i4
 DECLARE htaskrelease = i4
 DECLARE hsteprelease = i4
 DECLARE srvstat = i4
 DECLARE iret = i4
 DECLARE hprocess = i4
 DECLARE hcharge = i4
 DECLARE code_set = i4
 DECLARE cnt = i4
 DECLARE cdf_meaning = c12
 DECLARE suspense_cd = f8
 DECLARE inactive_cd = f8
 EXECUTE cs_srv_declare_951021
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 FREE SET item
 RECORD item(
   1 items[*]
     2 charge_event_id = f8
     2 charge_item_id = f8
 )
 FREE SET profit_charges
 RECORD profit_charges(
   1 charges[*]
     2 charge_item_id = f8
     2 reprocess_ind = i2
     2 dupe_ind = i2
 )
 FREE SET profit_reply
 RECORD profit_reply(
   1 success_cnt = i4
   1 failed_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET event_cnt = 0
 SET item_cnt = 0
 SET stat = 0
 SET profit_cnt = 0
 SET releaseappid = 951020
 SET releasetaskid = 951020
 SET releasereqid = 951021
 SET codeset = 13019
 SET cdf_meaning = "SUSPENSE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,suspense_cd)
 CALL echo(build("the suspense code is : ",suspense_cd))
 SET codeset = 48
 SET cdf_meaning = "INACTIVE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,inactive_cd)
 CALL echo(build("the active code is : ",inactive_cd))
 SET count1 = 0
 IF (size(request->person,5) > 0)
  SELECT INTO "nl:"
   FROM encounter e,
    (dummyt d1  WITH seq = value(size(request->person,5)))
   PLAN (d1)
    JOIN (e
    WHERE (e.person_id=request->person[d1.seq].person_id))
   DETAIL
    count1 = (count1+ 1), stat = alterlist(request->encntr,count1), request->encntr[d1.seq].encntr_id
     = e.encntr_id
   WITH nocounter
  ;end select
 ENDIF
 IF (size(request->encntr,5) > 0)
  SELECT INTO "nl:"
   c.charge_event_id, c.charge_item_id
   FROM charge c,
    charge_mod cm,
    code_value_extension cve,
    dummyt d1,
    dummyt d2,
    (dummyt d3  WITH seq = value(size(request->encntr,5)))
   PLAN (d3)
    JOIN (c
    WHERE c.process_flg=1
     AND c.active_ind=1
     AND (c.encntr_id=request->encntr[d3.seq].encntr_id))
    JOIN (d1)
    JOIN (cm
    WHERE cm.charge_item_id=c.charge_item_id
     AND cm.active_ind=1
     AND cm.charge_mod_type_cd=suspense_cd)
    JOIN (d2)
    JOIN (cve
    WHERE cve.code_value=cm.field1_id
     AND cve.code_set=13030
     AND cve.field_name="SKIP_CHARGING_SERVER")
   ORDER BY c.charge_event_id, c.charge_item_id
   HEAD c.charge_item_id
    IF (cnvtint(cve.field_value)=1)
     profit_cnt = (profit_cnt+ 1), stat = alterlist(profit_charges->charges,profit_cnt),
     profit_charges->charges[profit_cnt].charge_item_id = c.charge_item_id,
     profit_charges->charges[profit_cnt].reprocess_ind = 0, profit_charges->charges[profit_cnt].
     dupe_ind = 0
    ELSE
     item_cnt = (item_cnt+ 1), stat = alterlist(item->items,item_cnt), item->items[item_cnt].
     charge_event_id = c.charge_event_id,
     item->items[item_cnt].charge_item_id = c.charge_item_id
    ENDIF
   DETAIL
    dummy_var = 0
   WITH nocounter, outerjoin = d1, outerjoin = d2
  ;end select
 ENDIF
 CALL echo(build("number of server items: ",item_cnt))
 CALL echo(build("number of ProFit items: ",profit_cnt))
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  IF (size(profit_charges->charges,5) > 0)
   UPDATE  FROM charge c,
     (dummyt d  WITH seq = value(size(profit_charges->charges,5)))
    SET c.process_flg = 0
    PLAN (d)
     JOIN (c
     WHERE (c.charge_item_id=profit_charges->charges[d.seq].charge_item_id))
   ;end update
   UPDATE  FROM charge_mod cm,
     (dummyt d  WITH seq = value(size(profit_charges->charges,5)))
    SET cm.active_ind = 0, cm.active_status_cd = inactive_cd, cm.updt_dt_tm = cnvtdatetime(curdate,
      curtime)
    PLAN (d)
     JOIN (cm
     WHERE (cm.charge_item_id=profit_charges->charges[d.seq].charge_item_id)
      AND cm.charge_mod_type_cd=suspense_cd)
   ;end update
   COMMIT
   CALL echo("Sending ProFit charges.")
   EXECUTE pft_nt_chrg_billing  WITH replace(request,profit_charges), replace(reply,profit_reply)
   CASE (profit_reply->status_data.status)
    OF "S":
     CALL echo("Charges are posted to profit")
    OF "F":
     CALL echo("Script Failed")
    ELSE
     CALL echo(build("Unknown status returned from ProFit script:",profit_reply->status_data.status))
   ENDCASE
   CALL echo(build("Success count from ProFit script:",profit_reply->success_cnt))
   CALL echo(build("Failure count from ProFit script:",profit_reply->failed_cnt))
  ENDIF
  IF (size(item->items,5) > 0)
   SET iret = uar_crmbeginapp(releaseappid,happrelease)
   IF (iret=0)
    CALL echo("Successful begin app")
    SET iret = uar_crmbegintask(happrelease,releasetaskid,htaskrelease)
    IF (iret=0)
     CALL echo("Successful begin task")
     FOR (reprocess_cnt = 1 TO item_cnt)
      SET iret = uar_crmbeginreq(htaskrelease,"",releasereqid,hsteprelease)
      IF (iret=0)
       CALL echo("Begin request successful")
       SET hreq = uar_crmgetrequest(hsteprelease)
       SET srvstat = uar_srvsetshort(hreq,"charge_event_qual",1)
       SET hprocess = uar_srvadditem(hreq,"process_event")
       SET srvstat = uar_srvsetdouble(hprocess,"charge_event_id",item->items[reprocess_cnt].
        charge_event_id)
       SET srvstat = uar_srvsetshort(hprocess,"charge_item_qual",1)
       SET hcharge = uar_srvadditem(hprocess,"charge_item")
       SET srvstat = uar_srvsetdouble(hcharge,"charge_item_id",item->items[reprocess_cnt].
        charge_item_id)
       CALL echo(build("charge_event_id: ",item->items[reprocess_cnt].charge_event_id))
       CALL echo(build("charge_item_id: ",item->items[reprocess_cnt].charge_item_id))
       SET iret = uar_crmperform(hsteprelease)
       IF (iret != 0)
        CALL echo(concat("CRM perform failed:",build(iret)))
       ELSE
        CALL echo("crmperform success")
       ENDIF
       CALL uar_crmendreq(hsteprelease)
      ELSE
       CALL echo(concat("Begin request unsuccessful: ",build(iret)))
      ENDIF
     ENDFOR
     CALL uar_crmendtask(htaskrelease)
    ELSE
     CALL echo(concat("Unsuccessful begin task: ",build(iret)))
    ENDIF
    CALL uar_crmendapp(happrelease)
   ELSE
    CALL echo(concat("Begin app failed with code: ",build(iret)))
   ENDIF
   CALL echo(build("AFC_BATCH_CHARGE_RELEASE: ",item_cnt," Suspended charges submitted."))
  ENDIF
 ELSE
  SET reply->status_data.status = "Z"
  CALL echo("No charges to release")
 ENDIF
#end_program
 CALL echo(build("status is: ",reply->status_data.status))
END GO
