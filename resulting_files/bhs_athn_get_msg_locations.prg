CREATE PROGRAM bhs_athn_get_msg_locations
 FREE RECORD result
 RECORD result(
   1 user_facs[*]
     2 organization_id = f8
     2 facility_cd = f8
     2 facility_disp = vc
   1 loc_seq[*]
     2 ref_idx = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD locations
 RECORD locations(
   1 list[*]
     2 location_cd = f8
     2 location_disp = vc
     2 organization_id = f8
 ) WITH protect
 FREE RECORD req967702
 RECORD req967702(
   1 organizations[*]
     2 organization_id = f8
   1 location_type_cd = f8
 ) WITH protect
 FREE RECORD rep967702
 RECORD rep967702(
   1 organizations[*]
     2 organization_id = f8
     2 locations[*]
       3 location_name = vc
       3 location_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE getsecurityprefs(null) = i2 WITH protect
 DECLARE getuserfacilities(null) = i2 WITH protect
 DECLARE callmsgretrievelocationsbyorg(null) = i2 WITH protect
 DECLARE sortresults(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE errormsg = vc WITH protect, noconstant("")
 DECLARE inc_outpatient_ind = i2 WITH protect, constant(1)
 DECLARE secorgreltnind = i2 WITH protect, noconstant(0)
 DECLARE secconfidind = i2 WITH protect, noconstant(0)
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = getsecurityprefs(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = getuserfacilities(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = callmsgretrievelocationsbyorg(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = sortresults(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  FREE RECORD out_rec
  RECORD out_rec(
    1 locations[*]
      2 location_cd = f8
      2 location_disp = vc
      2 organization_id = f8
  ) WITH protect
  SET stat = alterlist(out_rec->locations,size(result->loc_seq,5))
  FOR (idx = 1 TO size(result->loc_seq,5))
    SET pos = result->loc_seq[idx].ref_idx
    SET out_rec->locations[idx].location_cd = locations->list[pos].location_cd
    SET out_rec->locations[idx].location_disp = locations->list[pos].location_disp
    SET out_rec->locations[idx].organization_id = locations->list[pos].organization_id
  ENDFOR
  CALL echorecord(out_rec)
  IF (validate(_memory_reply_string))
   SET _memory_reply_string = cnvtrectojson(out_rec)
  ELSE
   CALL echojson(out_rec,moutputdevice)
  ENDIF
  FREE RECORD out_rec
 ENDIF
 FREE RECORD result
 FREE RECORD req967702
 FREE RECORD rep967702
 SUBROUTINE getsecurityprefs(null)
   SELECT INTO "NL:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain="SECURITY"
      AND di.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID")
      AND ((di.info_number+ 0)=1.0))
    DETAIL
     IF (di.info_name="SEC_ORG_RELTN")
      secorgreltnind = 1
     ELSEIF (di.info_name="SEC_CONFID")
      secconfidind = 1, secorgreltnind = 1
     ENDIF
    WITH nocounter, time = 30
   ;end select
   IF (error(errormsg,1))
    RETURN(fail)
   ENDIF
   CALL echo(build("SECORGRELTNIND:",secorgreltnind))
   CALL echo(build("SECCONFIDIND:",secconfidind))
   RETURN(success)
 END ;Subroutine
 SUBROUTINE getuserfacilities(null)
   DECLARE faccnt = i4 WITH protect, noconstant(0)
   EXECUTE rx_get_facs_for_prsnl_rr_incl:dba  WITH replace("REQUEST","GET_FAC_REQ"), replace("REPLY",
    "GET_FAC_REP")
   SET get_fac_req->inc_outpt_fac_ind = inc_outpatient_ind
   SET get_fac_req->inc_inact_fac_ind = 0
   SET get_fac_req->evaluate_confid_level_ind = secconfidind
   SET stat = alterlist(get_fac_req->qual,1)
   SET get_fac_req->qual[1].person_id =  $2
   EXECUTE rx_get_facs_for_prsnl:dba  WITH replace("REQUEST","GET_FAC_REQ"), replace("REPLY",
    "GET_FAC_REP")
   IF ((get_fac_rep->status_data.status="F"))
    RETURN(fail)
   ELSEIF (size(get_fac_rep->qual,5) > 0)
    SET faccnt = size(get_fac_rep->qual[1].facility_list,5)
    IF (faccnt > 0)
     SET stat = alterlist(result->user_facs,faccnt)
     FOR (idx = 1 TO faccnt)
       SET result->user_facs[idx].organization_id = get_fac_rep->qual[1].facility_list[idx].
       organization_id
       SET result->user_facs[idx].facility_cd = get_fac_rep->qual[1].facility_list[idx].facility_cd
       SET result->user_facs[idx].facility_disp = get_fac_rep->qual[1].facility_list[idx].display
     ENDFOR
    ENDIF
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE callmsgretrievelocationsbyorg(null)
   DECLARE applicationid = i4 WITH constant(600005)
   DECLARE taskid = i4 WITH constant(967100)
   DECLARE requestid = i4 WITH constant(967702)
   DECLARE ambulatory_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"AMBULATORY"))
   SET stat = alterlist(req967702->organizations,size(result->user_facs,5))
   FOR (idx = 1 TO size(result->user_facs,5))
     SET req967702->organizations[idx].organization_id = result->user_facs[idx].organization_id
   ENDFOR
   SET req967702->location_type_cd = ambulatory_cd
   CALL echorecord(req967702)
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req967702,
    "REC",rep967702,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep967702)
   IF ((rep967702->status_data.status="F"))
    RETURN(fail)
   ENDIF
   RETURN(success)
 END ;Subroutine
 SUBROUTINE sortresults(null)
   DECLARE sortkey = vc WITH protect, noconstant("")
   DECLARE rcnt = i4 WITH protect, noconstant(0)
   DECLARE lcnt = i4 WITH protect, noconstant(0)
   FOR (idx = 1 TO size(rep967702->organizations,5))
     FOR (jdx = 1 TO size(rep967702->organizations[idx].locations,5))
       SET lcnt += 1
       SET stat = alterlist(locations->list,lcnt)
       SET locations->list[lcnt].location_cd = rep967702->organizations[idx].locations[jdx].
       location_id
       SET locations->list[lcnt].location_disp = rep967702->organizations[idx].locations[jdx].
       location_name
       SET locations->list[lcnt].organization_id = rep967702->organizations[idx].organization_id
     ENDFOR
   ENDFOR
   IF (lcnt > 0)
    SET stat = alterlist(result->loc_seq,lcnt)
    SELECT INTO "NL:"
     sortkey = cnvtupper(locations->list[d.seq].location_disp)
     FROM (dummyt d  WITH seq = value(lcnt))
     PLAN (d
      WHERE d.seq > 0)
     ORDER BY sortkey
     DETAIL
      rcnt += 1, result->loc_seq[rcnt].ref_idx = d.seq
     WITH nocounter, time = 30
    ;end select
   ENDIF
   RETURN(success)
 END ;Subroutine
END GO
