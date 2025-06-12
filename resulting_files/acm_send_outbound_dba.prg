CREATE PROGRAM acm_send_outbound:dba
 IF (validate(reply,"-999")="-999")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i2 WITH public, constant(0)
 ENDIF
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i2 WITH public, constant(1)
 ENDIF
 IF (validate(gen_nbr_error,0)=0
  AND validate(gen_nbr_error,1)=1)
  DECLARE gen_nbr_error = i2 WITH public, constant(3)
 ENDIF
 IF (validate(insert_error,0)=0
  AND validate(insert_error,1)=1)
  DECLARE insert_error = i2 WITH public, constant(4)
 ENDIF
 IF (validate(update_error,0)=0
  AND validate(update_error,1)=1)
  DECLARE update_error = i2 WITH public, constant(5)
 ENDIF
 IF (validate(replace_error,0)=0
  AND validate(replace_error,1)=1)
  DECLARE replace_error = i2 WITH public, constant(6)
 ENDIF
 IF (validate(delete_error,0)=0
  AND validate(delete_error,1)=1)
  DECLARE delete_error = i2 WITH public, constant(7)
 ENDIF
 IF (validate(undelete_error,0)=0
  AND validate(undelete_error,1)=1)
  DECLARE undelete_error = i2 WITH public, constant(8)
 ENDIF
 IF (validate(remove_error,0)=0
  AND validate(remove_error,1)=1)
  DECLARE remove_error = i2 WITH public, constant(9)
 ENDIF
 IF (validate(attribute_error,0)=0
  AND validate(attribute_error,1)=1)
  DECLARE attribute_error = i2 WITH public, constant(10)
 ENDIF
 IF (validate(lock_error,0)=0
  AND validate(lock_error,1)=1)
  DECLARE lock_error = i2 WITH public, constant(11)
 ENDIF
 IF (validate(none_found,0)=0
  AND validate(none_found,1)=1)
  DECLARE none_found = i2 WITH public, constant(12)
 ENDIF
 IF (validate(select_error,0)=0
  AND validate(select_error,1)=1)
  DECLARE select_error = i2 WITH public, constant(13)
 ENDIF
 IF (validate(update_cnt_error,0)=0
  AND validate(update_cnt_error,1)=1)
  DECLARE update_cnt_error = i2 WITH public, constant(14)
 ENDIF
 IF (validate(not_found,0)=0
  AND validate(not_found,1)=1)
  DECLARE not_found = i2 WITH public, constant(15)
 ENDIF
 IF (validate(inactivate_error,0)=0
  AND validate(inactivate_error,1)=1)
  DECLARE inactivate_error = i2 WITH public, constant(17)
 ENDIF
 IF (validate(activate_error,0)=0
  AND validate(activate_error,1)=1)
  DECLARE activate_error = i2 WITH public, constant(18)
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 DECLARE failed = i2 WITH protect, noconstant(false)
 DECLARE table_name = vc WITH protect, noconstant(" ")
 DECLARE call_echo_ind = i2 WITH protect, noconstant(0)
 DECLARE pmhc_contributory_system_cd = f8 WITH protect, noconstant(0.0)
 DECLARE transaction_type = i2 WITH protect, noconstant(0)
 DECLARE get_person_action = i2 WITH protect, constant(105)
 DECLARE modify_person_action = i2 WITH protect, constant(101)
 DECLARE hsrvmsg = i4 WITH noconstant(0)
 DECLARE hsrvreqmsg = i4 WITH noconstant(0)
 DECLARE hsrvrep = i4 WITH noconstant(0)
 DECLARE hsrvreq = i4 WITH noconstant(0)
 DECLARE hcqmmsg = i4 WITH noconstant(0)
 DECLARE hcqminfo = i4 WITH noconstant(0)
 DECLARE hesoinfo = i4 WITH noconstant(0)
 DECLARE htriginfo = i4 WITH noconstant(0)
 DECLARE hlonglist = i4 WITH noconstant(0)
 DECLARE hstatus = i4 WITH noconstant(0)
 DECLARE htempperson = i4 WITH noconstant(0)
 DECLARE htempperson2 = i4 WITH noconstant(0)
 DECLARE hmsg = i4 WITH noconstant(0)
 DECLARE hrep = i4 WITH noconstant(0)
 DECLARE happ = i4 WITH noconstant(0)
 DECLARE htask = i4 WITH noconstant(0)
 DECLARE hreq = i4 WITH noconstant(0)
 DECLARE cclsrvsetdate(hinst,fldname,fdate) = i4
 IF ((request->person_id=0))
  SET failed = attribute_error
  SET table_name = "person_id is 0.0"
  GO TO exit_script
 ENDIF
 SET stat = uar_crmbeginapp(100000,happ)
 SET stat = uar_crmbegintask(happ,100000,htask)
 SET stat = uar_crmbeginreq(htask,"",114604,hmsg)
 SET hreq = uar_crmgetrequest(hmsg)
 SET stat = uar_srvsetshort(hreq,"action",get_person_action)
 SET stat = uar_srvsetdouble(hreq,"person_id",request->person_id)
 SET stat = uar_srvsetshort(hreq,"all_person_aliases",1)
 SET stat = uar_crmperform(hmsg)
 SET hrep = uar_crmgetreply(hmsg)
 SET htempperson = uar_srvgetstruct(hrep,"PERSON")
 SET htempperson2 = uar_srvgetstruct(htempperson,"PERSON")
 SET stat = uar_srvgetdouble(htempperson2,"PERSON_ID")
 SET hsrvreqmsg = uar_srvselectmessage(1215013)
 IF (hsrvreqmsg=0)
  SET failed = uar_error
  SET table_name = "Unable to obtain message for TDB 1215013"
  GO TO exit_script
 ENDIF
 SET hsrvreq = uar_srvcreaterequest(hsrvreqmsg)
 SET hsrvrep = uar_srvcreatereply(hsrvreqmsg)
 CALL uar_srvdestroymessage(hsrvreqmsg)
 SET hreqmsg = 0
 SET hcqmmsg = uar_srvgetstruct(hsrvreq,"message")
 SET hcqminfo = uar_srvgetstruct(hcqmmsg,"cqminfo")
 SET htriginfo = uar_srvgetstruct(hcqmmsg,"triginfo")
 SET hesoinfo = uar_srvgetstruct(hcqmmsg,"esoinfo")
 SET stat = uar_srvcopy(htriginfo,hrep)
 IF (stat=0)
  SET failed = uar_error
  SET table_name = "Error copying 114604 reply into 1215001 request"
  GO TO exit_script
 ENDIF
 SET stat = uar_srvsetstring(hcqminfo,"appname","FSIESO")
 SET stat = uar_srvsetstring(hcqminfo,"contribalias","PM_TRANSACTION")
 SET stat = uar_srvsetstring(hcqminfo,"contribrefnum","114704")
 SET stat = cclsrvsetdate(hcqminfo,"contribdttm",cnvtdatetime(curdate,curtime3))
 SET stat = uar_srvsetlong(hcqminfo,"priority",99)
 SET stat = uar_srvsetstring(hcqminfo,"class","PM_TRANS")
 SET stat = uar_srvsetstring(hcqminfo,"type","ADT")
 SET stat = uar_srvsetstring(hcqminfo,"subtype","A31")
 SET stat = uar_srvsetstring(hcqminfo,"subtype_detail",cnvtstring(request->person_id))
 SET stat = uar_srvsetlong(hcqminfo,"debug_ind",0)
 SET stat = uar_srvsetlong(hcqminfo,"verbosity_flag",1)
 SET hlonglist = uar_srvadditem(hesoinfo,"longList")
 SET stat = uar_srvsetstring(hlonglist,"StrMeaning","person first event")
 SET stat = uar_srvsetlong(hlonglist,"lVal",0)
 SET hlonglist = uar_srvadditem(hesoinfo,"longList")
 SET stat = uar_srvsetstring(hlonglist,"StrMeaning","encntr first event")
 SET stat = uar_srvsetlong(hlonglist,"lVal",0)
 SET hlonglist = uar_srvadditem(hesoinfo,"longList")
 SET stat = uar_srvsetstring(hlonglist,"StrMeaning","encntr event ind")
 SET stat = uar_srvsetlong(hlonglist,"lVal",0)
 SET hlonglist = uar_srvadditem(hesoinfo,"longList")
 SET stat = uar_srvsetstring(hlonglist,"StrMeaning","action type")
 SET stat = uar_srvsetlong(hlonglist,"lVal",modify_person_action)
 SET hsrvmsg = uar_srvselectmessage(1215001)
 IF (hsrvreqmsg=0)
  SET failed = uar_error
  SET table_name = "Unable to obtain message for TDB 1215001"
  GO TO exit_script
 ENDIF
 SET stat = uar_srvexecute(hsrvmsg,hsrvreq,hsrvrep)
 IF (stat != 0)
  SET failed = uar_error
  CASE (stat)
   OF 1:
    SET table_name = "Communication error in SrvExecute (1215001), no server available."
   OF 2:
    SET table_name = "Data inconsistency or mismatch in message in SrvExecute (1215001)."
   OF 3:
    SET table_name = "No handler to service request in SrvExecute (1215001)."
  ENDCASE
  GO TO exit_script
 ENDIF
 SET hstatus = uar_srvgetstruct(hsrvrep,"Sb")
 SET stat = uar_srvgetlong(hstatus,"STATUS_CD")
 IF (stat != 0)
  SET failed = uar_error
  SET table_name = "Request to FSI_SRVCQM Server failed."
 ENDIF
#exit_script
 IF (hsrvmsg)
  CALL uar_srvdestroymessage(hsrvmsg)
  SET hsrvmsg = 0
 ENDIF
 IF (hsrvreq)
  CALL uar_srvdestroyinstance(hsrvreq)
  SET hsrvreq = 0
 ENDIF
 IF (hsrvrep)
  CALL uar_srvdestroyinstance(hsrvrep)
  SET hsrvrep = 0
 ENDIF
 IF (hreq > 0)
  CALL uar_crmendreq(hmsg)
 ENDIF
 IF (htask > 0)
  CALL uar_crmendtask(htask)
 ENDIF
 IF (happ > 0)
  CALL uar_crmendapp(happ)
 ENDIF
 IF (failed=false)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  IF (failed != true
   AND failed != false)
   IF ((validate(pm_subeventstatus_sub_,- (99))=- (99)))
    DECLARE pm_subeventstatus_sub_ = i2 WITH public, constant(1)
    DECLARE s_next_subeventstatus(s_null=i4) = i4
    DECLARE s_add_subeventstatus(s_oname=vc,s_ostatus=c1,s_tname=vc,s_tvalue=vc) = i4
    DECLARE s_add_subeventstatus_cclerr(s_null=i4) = i4
    DECLARE s_log_subeventstatus(s_null=i4) = i4
    DECLARE s_clear_subeventstatus(s_null=i4) = i4
    SUBROUTINE s_next_subeventstatus(s_null)
      DECLARE s_stat = i4 WITH private, noconstant(0)
      DECLARE stx1 = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5))
      IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->status_data.
      subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.subeventstatus[stx1].
      targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].targetobjectvalue > " ")
      )) )) )) )
       SET stx1 = (stx1+ 1)
       SET s_stat = alter(reply->status_data.subeventstatus,stx1)
      ENDIF
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE s_add_subeventstatus(s_oname,s_ostatus,s_tname,s_tvalue)
      DECLARE stx1 = i4 WITH private, noconstant(s_next_subeventstatus(1))
      SET reply->status_data.subeventstatus[stx1].operationname = s_oname
      SET reply->status_data.subeventstatus[stx1].operationstatus = s_ostatus
      SET reply->status_data.subeventstatus[stx1].targetobjectname = s_tname
      SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE s_add_subeventstatus_cclerr(s_null)
      DECLARE serrmsg = vc WITH private, noconstant("")
      DECLARE ierrcode = i4 WITH private, noconstant(1)
      WHILE (ierrcode)
       SET ierrcode = error(serrmsg,0)
       IF (ierrcode)
        CALL s_add_subeventstatus("CCLERR","F",trim(curprog),serrmsg)
       ENDIF
      ENDWHILE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE s_log_subeventstatus(s_null)
      DECLARE wi = i4 WITH protect, noconstant(0)
      DECLARE s_curprog = vc WITH protect, constant(curprog)
      FOR (wi = 1 TO size(reply->status_data.subeventstatus,5))
        CALL s_sch_msgview(s_curprog,nullterm(build(reply->status_data.subeventstatus[wi].
           operationname,",",reply->status_data.subeventstatus[wi].operationstatus,",",reply->
           status_data.subeventstatus[wi].targetobjectname,
           ",",reply->status_data.subeventstatus[wi].targetobjectvalue)),0)
      ENDFOR
    END ;Subroutine
    SUBROUTINE s_clear_subeventstatus(s_null)
      SET stat = alter(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].operationname = ""
      SET reply->status_data.subeventstatus[1].operationstatus = ""
      SET reply->status_data.subeventstatus[1].targetobjectname = ""
      SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
    END ;Subroutine
    DECLARE s_sch_msgview(t_event=vc,t_message=vc,t_log_level=i4) = i2
    SUBROUTINE s_sch_msgview(t_event,t_message,t_log_level)
     IF (t_event > " "
      AND t_log_level BETWEEN 0 AND 4
      AND t_message > " ")
      DECLARE hlog = i4 WITH protect, noconstant(0)
      DECLARE hstat = i4 WITH protect, noconstant(0)
      CALL uar_syscreatehandle(hlog,hstat)
      IF (hlog != 0)
       CALL uar_sysevent(hlog,t_log_level,nullterm(t_event),nullterm(t_message))
       CALL uar_sysdestroyhandle(hlog)
      ENDIF
     ENDIF
     RETURN(1)
    END ;Subroutine
   ENDIF
   CASE (failed)
    OF lock_error:
     CALL s_add_subeventstatus("LOCK","F",trim(curprog),table_name)
    OF select_error:
     CALL s_add_subeventstatus("SELECT","F",trim(curprog),table_name)
    OF update_error:
     CALL s_add_subeventstatus("UPDATE","F",trim(curprog),table_name)
    OF insert_error:
     CALL s_add_subeventstatus("INSERT","F",trim(curprog),table_name)
    OF gen_nbr_error:
     CALL s_add_subeventstatus("GEN_NBR","F",trim(curprog),table_name)
    OF replace_error:
     CALL s_add_subeventstatus("REPLACE","F",trim(curprog),table_name)
    OF delete_error:
     CALL s_add_subeventstatus("DELETE","F",trim(curprog),table_name)
    OF undelete_error:
     CALL s_add_subeventstatus("UNDELETE","F",trim(curprog),table_name)
    OF remove_error:
     CALL s_add_subeventstatus("REMOVE","F",trim(curprog),table_name)
    OF attribute_error:
     CALL s_add_subeventstatus("ATTRIBUTE","F",trim(curprog),table_name)
    OF none_found:
     CALL s_add_subeventstatus("NONE_FOUND","F",trim(curprog),table_name)
    OF update_cnt_error:
     CALL s_add_subeventstatus("UPDATE_CNT","F",trim(curprog),table_name)
    OF not_found:
     CALL s_add_subeventstatus("NOT_FOUND","F",trim(curprog),table_name)
    OF inactivate_error:
     CALL s_add_subeventstatus("INACTIVATE","F",trim(curprog),table_name)
    OF activate_error:
     CALL s_add_subeventstatus("ACTIVATE","F",trim(curprog),table_name)
    OF uar_error:
     CALL s_add_subeventstatus("UAR_ERROR","F",trim(curprog),table_name)
    OF execute_error:
     CALL s_add_subeventstatus("EXECUTE","F",trim(curprog),table_name)
    OF duplicate_error:
     CALL s_add_subeventstatus("DUPLICATE","F",trim(curprog),table_name)
    OF ccl_error:
     CALL s_add_subeventstatus("CCLERROR","F",trim(curprog),table_name)
    ELSE
     CALL s_add_subeventstatus("UNKNOWN","F",trim(curprog),table_name)
   ENDCASE
   SET reqinfo->commit_ind = false
   CALL s_add_subeventstatus_cclerr(1)
   CALL s_log_subeventstatus(1)
  ENDIF
 ENDIF
 SUBROUTINE cclsrvsetdate(hinst,fldname,fdate)
   DECLARE datestr = vc
   FREE SET sdate
   RECORD sdate(
     1 d1 = c1
     1 d2 = c1
     1 d3 = c1
     1 d4 = c1
     1 d5 = c1
     1 d6 = c1
     1 d7 = c1
     1 d8 = c1
   )
   SET datestr = format(cnvtdatetimeutc(fdate,1),"yyyy-mm-dd hh:mm:ss.cc;;Q")
   SET sdate->d1 = char(cnvtint(substring(1,2,datestr)))
   SET sdate->d2 = char(cnvtint(substring(3,2,datestr)))
   SET sdate->d3 = char(cnvtint(substring(6,2,datestr)))
   SET sdate->d4 = char(cnvtint(substring(9,2,datestr)))
   SET sdate->d5 = char(cnvtint(substring(12,2,datestr)))
   SET sdate->d6 = char(cnvtint(substring(15,2,datestr)))
   SET sdate->d7 = char(cnvtint(substring(18,2,datestr)))
   SET sdate->d8 = char(cnvtint(substring(21,2,datestr)))
   RETURN(uar_srvsetdate2(hinst,nullterm(fldname),sdate))
 END ;Subroutine
END GO
