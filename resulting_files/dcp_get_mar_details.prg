CREATE PROGRAM dcp_get_mar_details
 SET modify = predeclare
 DECLARE butcind = i2 WITH protect, constant(curutc)
 DECLARE ctime_zone_format = vc WITH protect, constant("ZZZ")
 DECLARE parsezeroes(passfieldin=f8) = vc
 DECLARE formatutcdatetime(sdatetime=vc,ltzindex=i4,bshowtz=i2) = vc
 DECLARE formatlabelbylength(slabel=vc,lmaxlen=i4) = vc
 DECLARE formatstrength(dstrength=f8) = vc
 DECLARE formatvolume(dvolume=f8) = vc
 DECLARE formatrate(drate=f8) = vc
 DECLARE formatpercentwithdecimal(dpercent=f8) = vc
 SUBROUTINE parsezeroes(pass_field_in)
   DECLARE dsvalue = c16 WITH noconstant(fillstring(16," "))
   DECLARE move_fld = c16 WITH noconstant(fillstring(16," "))
   DECLARE strfld = c16 WITH noconstant(fillstring(16," "))
   DECLARE sig_dig = i4 WITH noconstant(0)
   DECLARE sig_dec = i4 WITH noconstant(0)
   DECLARE str_cnt = i4 WITH noconstant(1)
   DECLARE len = i4 WITH noconstant(0)
   SET strfld = cnvtstring(pass_field_in,16,4,r)
   WHILE (str_cnt < 12
    AND substring(str_cnt,1,strfld) IN ("0", " "))
     SET str_cnt = (str_cnt+ 1)
   ENDWHILE
   SET sig_dig = (str_cnt - 1)
   SET str_cnt = 16
   WHILE (str_cnt > 12
    AND substring(str_cnt,1,strfld) IN ("0", " "))
     SET str_cnt = (str_cnt - 1)
   ENDWHILE
   IF (str_cnt=12
    AND substring(str_cnt,1,strfld)=".")
    SET str_cnt = (str_cnt - 1)
   ENDIF
   SET sig_dec = str_cnt
   IF (sig_dig=11
    AND sig_dec=11)
    SET dsvalue = ""
   ELSE
    SET len = movestring(strfld,(sig_dig+ 1),move_fld,1,(sig_dec - sig_dig))
    SET dsvalue = trim(move_fld)
    IF (substring(1,1,dsvalue)=".")
     SET dsvalue = concat("0",trim(move_fld))
    ENDIF
   ENDIF
   RETURN(dsvalue)
 END ;Subroutine
 SUBROUTINE formatutcdatetime(sdatetime,ltzindex,bshowtz)
   DECLARE lnewindex = i4 WITH protect, noconstant(curtimezoneapp)
   DECLARE snewdatetime = vc WITH protect, noconstant(" ")
   IF (ltzindex > 0)
    SET lnewindex = ltzindex
   ENDIF
   SET snewdatetime = datetimezoneformat(sdatetime,lnewindex,"@SHORTDATE")
   IF (size(trim(snewdatetime)) > 0)
    SET snewdatetime = concat(snewdatetime," ",datetimezoneformat(sdatetime,lnewindex,
      "@TIMENOSECONDS"))
    IF (butcind=1
     AND bshowtz=1)
     SET snewdatetime = concat(snewdatetime," ",datetimezoneformat(sdatetime,lnewindex,
       ctime_zone_format))
    ENDIF
   ENDIF
   SET snewdatetime = trim(snewdatetime)
   RETURN(snewdatetime)
 END ;Subroutine
 SUBROUTINE formatlabelbylength(slabel,lmaxlen)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = trim(slabel,3)
   IF (size(snewlabel) > 0
    AND lmaxlen > 0)
    IF (lmaxlen < 4)
     SET snewlabel = substring(1,lmaxlen,snewlabel)
    ELSEIF (size(snewlabel) > lmaxlen)
     SET snewlabel = concat(substring(1,(lmaxlen - 3),snewlabel),"...")
    ENDIF
   ENDIF
   RETURN(snewlabel)
 END ;Subroutine
 SUBROUTINE formatstrength(dstrength)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = nullterm(trim(format(dstrength,"######.####;It(1);F"),3))
   RETURN(snewlabel)
 END ;Subroutine
 SUBROUTINE formatvolume(dvolume)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = nullterm(trim(format(dvolume,"######.##;It(1);F"),3))
   RETURN(snewlabel)
 END ;Subroutine
 SUBROUTINE formatrate(drate)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = nullterm(trim(format(drate,"######.####;It(1);F"),3))
   RETURN(snewlabel)
 END ;Subroutine
 SUBROUTINE formatpercentwithdecimal(dpercent)
   DECLARE snewlabel = vc WITH protect, noconstant("")
   SET snewlabel = nullterm(format(dpercent,"###.##;I;F"))
   RETURN(snewlabel)
 END ;Subroutine
 FREE RECORD prsnl_request
 RECORD prsnl_request(
   1 person_id = f8
   1 username = c50
   1 providers[*]
     2 person_id = f8
 )
 FREE RECORD prsnl_reply
 RECORD prsnl_reply(
   1 person_id = f8
   1 name_full_formatted = vc
   1 name_last = vc
   1 name_first = vc
   1 username = vc
   1 position_cd = f8
   1 position_disp = vc
   1 physician_ind = i2
   1 department_cd = f8
   1 department_disp = vc
   1 section_cd = f8
   1 section_disp = vc
   1 email = vc
   1 active_ind = i2
   1 lookup_status = i4
   1 providers[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 name_last = vc
     2 name_first = vc
     2 name_middle = vc
     2 username = vc
     2 email = vc
     2 physician_ind = i2
     2 position_cd = f8
     2 position_disp = vc
     2 position_mean = vc
     2 department_cd = f8
     2 department_disp = vc
     2 department_mean = vc
     2 physician_status_cd = f8
     2 physician_status_disp = vc
     2 physician_status_mean = vc
     2 section_cd = f8
     2 section_disp = vc
     2 section_mean = vc
     2 active_ind = i2
     2 name_hist[*]
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 name_full_formatted = vc
       3 name_last = vc
       3 name_first = vc
       3 name_middle = vc
       3 normal_record = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE subroutinetime = f8 WITH protect, noconstant(0)
 DECLARE querytime = f8 WITH protect, noconstant(0)
 DECLARE processreply(null) = null
 DECLARE addprsnl(prsnl_id=f8) = null
 DECLARE getprsnl(null) = null
 DECLARE processprsnl(null) = null
 DECLARE getprsnlname(person_id=f8,actiondttm=f8,prsnl_name=vc) = vc
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE prsnl_name = vc WITH protect, noconstant(" ")
 DECLARE provider_cnt = i4 WITH protect, noconstant(0)
 DECLARE index_loc = i4 WITH protect, noconstant(0)
 DECLARE iterator = i4 WITH protect, noconstant(0)
 DECLARE order_cnt = i4 WITH protect, noconstant(0)
 DECLARE order_actions_cnt = i4 WITH protect, noconstant(0)
 DECLARE order_review_cnt = i4 WITH protect, noconstant(0)
 DECLARE admin_cnt = i4 WITH protect, noconstant(0)
 DECLARE event_prsnl_action_cnt = i4 WITH protect, noconstant(0)
 DECLARE admin_history_cnt = i4 WITH protect, noconstant(0)
 DECLARE ingredient_cnt = i4 WITH protect, noconstant(0)
 DECLARE result_comment_cnt = i4 WITH protect, noconstant(0)
 DECLARE event_prsnl_actions_cnt = i4 WITH protect, noconstant(0)
 DECLARE responseresult_cnt = i4 WITH protect, noconstant(0)
 DECLARE response_action_cnt = i4 WITH protect, noconstant(0)
 DECLARE event_cnt = i4 WITH protect, noconstant(0)
 DECLARE result_comments_cnt = i4 WITH protect, noconstant(0)
 SUBROUTINE processreply(null)
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   FOR (order_cnt = 1 TO size(mar_detail_reply->orders,5))
     FOR (order_actions_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].order_actions,5))
      CALL addprsnl(mar_detail_reply->orders[order_cnt].order_actions[order_actions_cnt].
       action_personnel_id)
      FOR (order_review_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].order_actions[
       order_actions_cnt].order_review,5))
        CALL addprsnl(mar_detail_reply->orders[order_cnt].order_actions[order_actions_cnt].
         order_review[order_review_cnt].review_personnel_id)
      ENDFOR
     ENDFOR
     FOR (admin_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].administrations,5))
       CALL addprsnl(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].
        performed_prsnl_id)
       FOR (result_comments_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].administrations[
        admin_cnt].result_comments,5))
         CALL addprsnl(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].
          result_comments[result_comments_cnt].note_prsnl_id)
       ENDFOR
       FOR (event_prsnl_action_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].administrations[
        admin_cnt].event_prsnl_actions,5))
         CALL addprsnl(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].
          event_prsnl_actions[event_prsnl_action_cnt].action_prsnl_id)
         CALL addprsnl(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].
          event_prsnl_actions[event_prsnl_action_cnt].request_prsnl_id)
         CALL addprsnl(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].
          event_prsnl_actions[event_prsnl_action_cnt].proxy_prsnl_id)
       ENDFOR
       FOR (admin_history_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].administrations[
        admin_cnt].admin_histories,5))
         CALL addprsnl(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].
          admin_histories[admin_history_cnt].performed_prsnl_id)
       ENDFOR
       FOR (ingredient_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].administrations[admin_cnt]
        .ingredients,5))
        FOR (result_comment_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].administrations[
         admin_cnt].ingredients[ingredient_cnt].result_comments,5))
          CALL addprsnl(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].ingredients[
           ingredient_cnt].result_comments[result_comment_cnt].note_prsnl_id)
        ENDFOR
        FOR (event_prsnl_actions_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].administrations[
         admin_cnt].ingredients[ingredient_cnt].event_prsnl_actions,5))
          CALL addprsnl(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].ingredients[
           ingredient_cnt].event_prsnl_actions[event_prsnl_actions_cnt].action_prsnl_id)
          CALL addprsnl(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].ingredients[
           ingredient_cnt].event_prsnl_actions[event_prsnl_actions_cnt].request_prsnl_id)
          CALL addprsnl(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].ingredients[
           ingredient_cnt].event_prsnl_actions[event_prsnl_actions_cnt].proxy_prsnl_id)
        ENDFOR
       ENDFOR
       FOR (discrete_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].
        discretes,5))
        FOR (result_comment_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].administrations[
         admin_cnt].discretes[discrete_cnt].result_comments,5))
          CALL addprsnl(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].discretes[
           discrete_cnt].result_comments[result_comment_cnt].note_prsnl_id)
        ENDFOR
        FOR (event_prsnl_actions_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].administrations[
         admin_cnt].discretes[discrete_cnt].event_prsnl_actions,5))
          CALL addprsnl(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].discretes[
           discrete_cnt].event_prsnl_actions[event_prsnl_actions_cnt].action_prsnl_id)
          CALL addprsnl(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].discretes[
           discrete_cnt].event_prsnl_actions[event_prsnl_actions_cnt].request_prsnl_id)
          CALL addprsnl(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].discretes[
           discrete_cnt].event_prsnl_actions[event_prsnl_actions_cnt].proxy_prsnl_id)
        ENDFOR
       ENDFOR
     ENDFOR
     FOR (responseresult_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].responseresults,5))
       FOR (response_action_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].responseresults[
        responseresult_cnt].response_actions,5))
         FOR (event_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].responseresults[
          responseresult_cnt].response_actions[response_action_cnt].events,5))
          FOR (result_comments_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].responseresults[
           responseresult_cnt].response_actions[response_action_cnt].events[event_cnt].
           result_comments,5))
            CALL addprsnl(mar_detail_reply->orders[order_cnt].responseresults[responseresult_cnt].
             response_actions[response_action_cnt].events[event_cnt].result_comments[
             result_comments_cnt].note_prsnl_id)
          ENDFOR
          FOR (event_prsnl_action_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].
           responseresults[responseresult_cnt].response_actions[response_action_cnt].events[event_cnt
           ].event_prsnl_actions,5))
            CALL addprsnl(mar_detail_reply->orders[order_cnt].responseresults[responseresult_cnt].
             response_actions[response_action_cnt].events[event_cnt].event_prsnl_actions[
             event_prsnl_action_cnt].action_prsnl_id)
            CALL addprsnl(mar_detail_reply->orders[order_cnt].responseresults[responseresult_cnt].
             response_actions[response_action_cnt].events[event_cnt].event_prsnl_actions[
             event_prsnl_action_cnt].request_prsnl_id)
            CALL addprsnl(mar_detail_reply->orders[order_cnt].responseresults[responseresult_cnt].
             response_actions[response_action_cnt].events[event_cnt].event_prsnl_actions[
             event_prsnl_action_cnt].proxy_prsnl_id)
          ENDFOR
         ENDFOR
       ENDFOR
     ENDFOR
   ENDFOR
   IF (debug_ind=1)
    CALL echo(build("********LoadPrsnlInfo - ProcessReply Total Subroutine Time = ",datetimediff(
       cnvtdatetime(curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE addprsnl(prsnl_id)
   DECLARE id_exists = i4 WITH protect, noconstant(0)
   DECLARE new_prsnl_cnt = i4 WITH protect, noconstant(0)
   IF (prsnl_id <= 0)
    RETURN
   ENDIF
   SET provider_cnt = size(prsnl_request->providers,5)
   IF (provider_cnt > 0)
    SET iterator = 0
    SET index_loc = locateval(iterator,1,provider_cnt,prsnl_id,prsnl_request->providers[iterator].
     person_id)
    IF (index_loc > 0)
     SET id_exists = 1
    ENDIF
   ENDIF
   IF (id_exists=0)
    SET new_prsnl_cnt = (provider_cnt+ 1)
    SET stat = alterlist(prsnl_request->providers,new_prsnl_cnt)
    SET prsnl_request->providers[new_prsnl_cnt].person_id = prsnl_id
   ENDIF
 END ;Subroutine
 SUBROUTINE getprsnl(null)
   IF (size(prsnl_request->providers,5) > 0)
    IF (debug_ind=1)
     SET subroutinetime = cnvtdatetime(curdate,curtime3)
    ENDIF
    SET modify = nopredeclare
    EXECUTE pts_get_prsnl_demo  WITH replace("REQUEST","PRSNL_REQUEST"), replace("REPLY",
     "PRSNL_REPLY")
    SET modify = predeclare
    IF (debug_ind=1)
     CALL echo(build("********LoadPrsnlInfo - GetPrsnl Total Subroutine Time = ",datetimediff(
        cnvtdatetime(curdate,curtime3),subroutinetime,5)))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE processprsnl(null)
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   FOR (order_cnt = 1 TO size(mar_detail_reply->orders,5))
     FOR (order_actions_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].order_actions,5))
       SET prsnl_name = mar_detail_reply->orders[order_cnt].order_actions[order_actions_cnt].
       action_personnel_name
       SET mar_detail_reply->orders[order_cnt].order_actions[order_actions_cnt].action_personnel_name
        = getprsnlname(mar_detail_reply->orders[order_cnt].order_actions[order_actions_cnt].
        action_personnel_id,cnvtdatetime(mar_detail_reply->orders[order_cnt].order_actions[
         order_actions_cnt].action_dt_tm),prsnl_name)
       SET mar_detail_reply->orders[order_cnt].order_actions[order_actions_cnt].action_person =
       mar_detail_reply->orders[order_cnt].order_actions[order_actions_cnt].action_personnel_name
       FOR (order_review_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].order_actions[
        order_actions_cnt].order_review,5))
         SET prsnl_name = mar_detail_reply->orders[order_cnt].order_actions[order_actions_cnt].
         order_review[order_review_cnt].review_personnel_name
         SET mar_detail_reply->orders[order_cnt].order_actions[order_actions_cnt].order_review[
         order_review_cnt].review_personnel_name = getprsnlname(mar_detail_reply->orders[order_cnt].
          order_actions[order_actions_cnt].order_review[order_review_cnt].review_personnel_id,
          cnvtdatetime(mar_detail_reply->orders[order_cnt].order_actions[order_actions_cnt].
           order_review[order_review_cnt].review_dt_tm),prsnl_name)
         SET mar_detail_reply->orders[order_cnt].order_actions[order_actions_cnt].order_review[
         order_review_cnt].reviewed_person_name = mar_detail_reply->orders[order_cnt].order_actions[
         order_actions_cnt].order_review[order_review_cnt].review_personnel_name
       ENDFOR
     ENDFOR
     FOR (admin_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].administrations,5))
       SET prsnl_name = mar_detail_reply->orders[order_cnt].administrations[admin_cnt].
       performed_prsnl_name
       SET mar_detail_reply->orders[order_cnt].administrations[admin_cnt].performed_prsnl_name =
       getprsnlname(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].performed_prsnl_id,
        cnvtdatetime(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].performed_dt_tm),
        prsnl_name)
       FOR (result_comments_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].administrations[
        admin_cnt].result_comments,5))
        SET prsnl_name = mar_detail_reply->orders[order_cnt].administrations[admin_cnt].
        result_comments[result_comments_cnt].note_prsnl_name
        SET mar_detail_reply->orders[order_cnt].administrations[admin_cnt].result_comments[
        result_comments_cnt].note_prsnl_name = getprsnlname(mar_detail_reply->orders[order_cnt].
         administrations[admin_cnt].result_comments[result_comments_cnt].note_prsnl_id,cnvtdatetime(
          mar_detail_reply->orders[order_cnt].administrations[admin_cnt].result_comments[
          result_comments_cnt].note_dt_tm),prsnl_name)
       ENDFOR
       FOR (event_prsnl_action_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].administrations[
        admin_cnt].event_prsnl_actions,5))
         SET prsnl_name = mar_detail_reply->orders[order_cnt].administrations[admin_cnt].
         event_prsnl_actions[event_prsnl_action_cnt].action_prsnl_name
         SET mar_detail_reply->orders[order_cnt].administrations[admin_cnt].event_prsnl_actions[
         event_prsnl_action_cnt].action_prsnl_name = getprsnlname(mar_detail_reply->orders[order_cnt]
          .administrations[admin_cnt].event_prsnl_actions[event_prsnl_action_cnt].action_prsnl_id,
          cnvtdatetime(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].
           event_prsnl_actions[event_prsnl_action_cnt].action_dt_tm),prsnl_name)
         SET prsnl_name = mar_detail_reply->orders[order_cnt].administrations[admin_cnt].
         event_prsnl_actions[event_prsnl_action_cnt].request_prsnl_name
         SET mar_detail_reply->orders[order_cnt].administrations[admin_cnt].event_prsnl_actions[
         event_prsnl_action_cnt].request_prsnl_name = getprsnlname(mar_detail_reply->orders[order_cnt
          ].administrations[admin_cnt].event_prsnl_actions[event_prsnl_action_cnt].request_prsnl_id,
          cnvtdatetime(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].
           event_prsnl_actions[event_prsnl_action_cnt].request_dt_tm),prsnl_name)
         SET prsnl_name = mar_detail_reply->orders[order_cnt].administrations[admin_cnt].
         event_prsnl_actions[event_prsnl_action_cnt].proxy_prsnl_name
         SET mar_detail_reply->orders[order_cnt].administrations[admin_cnt].event_prsnl_actions[
         event_prsnl_action_cnt].proxy_prsnl_name = getprsnlname(mar_detail_reply->orders[order_cnt].
          administrations[admin_cnt].event_prsnl_actions[event_prsnl_action_cnt].proxy_prsnl_id,
          cnvtdatetime(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].
           event_prsnl_actions[event_prsnl_action_cnt].action_dt_tm),prsnl_name)
       ENDFOR
       FOR (admin_history_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].administrations[
        admin_cnt].admin_histories,5))
        SET prsnl_name = mar_detail_reply->orders[order_cnt].administrations[admin_cnt].
        admin_histories[admin_history_cnt].performed_prsnl_name
        SET mar_detail_reply->orders[order_cnt].administrations[admin_cnt].admin_histories[
        admin_history_cnt].performed_prsnl_name = getprsnlname(mar_detail_reply->orders[order_cnt].
         administrations[admin_cnt].admin_histories[admin_history_cnt].performed_prsnl_id,
         cnvtdatetime(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].admin_histories[
          admin_history_cnt].performed_dt_tm),prsnl_name)
       ENDFOR
       FOR (ingredient_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].administrations[admin_cnt]
        .ingredients,5))
        FOR (result_comment_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].administrations[
         admin_cnt].ingredients[ingredient_cnt].result_comments,5))
         SET prsnl_name = mar_detail_reply->orders[order_cnt].administrations[admin_cnt].ingredients[
         ingredient_cnt].result_comments[result_comment_cnt].note_prsnl_name
         SET mar_detail_reply->orders[order_cnt].administrations[admin_cnt].ingredients[
         ingredient_cnt].result_comments[result_comment_cnt].note_prsnl_name = getprsnlname(
          mar_detail_reply->orders[order_cnt].administrations[admin_cnt].ingredients[ingredient_cnt].
          result_comments[result_comment_cnt].note_prsnl_id,cnvtdatetime(mar_detail_reply->orders[
           order_cnt].administrations[admin_cnt].ingredients[ingredient_cnt].result_comments[
           result_comment_cnt].note_dt_tm),prsnl_name)
        ENDFOR
        FOR (event_prsnl_actions_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].administrations[
         admin_cnt].ingredients[ingredient_cnt].event_prsnl_actions,5))
          SET prsnl_name = mar_detail_reply->orders[order_cnt].administrations[admin_cnt].
          ingredients[ingredient_cnt].event_prsnl_actions[event_prsnl_actions_cnt].action_prsnl_name
          SET mar_detail_reply->orders[order_cnt].administrations[admin_cnt].ingredients[
          ingredient_cnt].event_prsnl_actions[event_prsnl_actions_cnt].action_prsnl_name =
          getprsnlname(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].ingredients[
           ingredient_cnt].event_prsnl_actions[event_prsnl_actions_cnt].action_prsnl_id,cnvtdatetime(
            mar_detail_reply->orders[order_cnt].administrations[admin_cnt].ingredients[ingredient_cnt
            ].event_prsnl_actions[event_prsnl_actions_cnt].action_dt_tm),prsnl_name)
          SET prsnl_name = mar_detail_reply->orders[order_cnt].administrations[admin_cnt].
          ingredients[ingredient_cnt].event_prsnl_actions[event_prsnl_actions_cnt].request_prsnl_name
          SET mar_detail_reply->orders[order_cnt].administrations[admin_cnt].ingredients[
          ingredient_cnt].event_prsnl_actions[event_prsnl_actions_cnt].request_prsnl_name =
          getprsnlname(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].ingredients[
           ingredient_cnt].event_prsnl_actions[event_prsnl_actions_cnt].request_prsnl_id,cnvtdatetime
           (mar_detail_reply->orders[order_cnt].administrations[admin_cnt].ingredients[ingredient_cnt
            ].event_prsnl_actions[event_prsnl_actions_cnt].request_dt_tm),prsnl_name)
          SET prsnl_name = mar_detail_reply->orders[order_cnt].administrations[admin_cnt].
          ingredients[ingredient_cnt].event_prsnl_actions[event_prsnl_actions_cnt].proxy_prsnl_name
          SET mar_detail_reply->orders[order_cnt].administrations[admin_cnt].ingredients[
          ingredient_cnt].event_prsnl_actions[event_prsnl_actions_cnt].proxy_prsnl_name =
          getprsnlname(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].ingredients[
           ingredient_cnt].event_prsnl_actions[event_prsnl_actions_cnt].proxy_prsnl_id,cnvtdatetime(
            mar_detail_reply->orders[order_cnt].administrations[admin_cnt].ingredients[ingredient_cnt
            ].event_prsnl_actions[event_prsnl_actions_cnt].action_dt_tm),prsnl_name)
        ENDFOR
       ENDFOR
       FOR (discrete_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].administrations[admin_cnt].
        discretes,5))
        FOR (result_comment_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].administrations[
         admin_cnt].discretes[discrete_cnt].result_comments,5))
         SET prsnl_name = mar_detail_reply->orders[order_cnt].administrations[admin_cnt].discretes[
         discrete_cnt].result_comments[result_comment_cnt].note_prsnl_name
         SET mar_detail_reply->orders[order_cnt].administrations[admin_cnt].discretes[discrete_cnt].
         result_comments[result_comment_cnt].note_prsnl_name = getprsnlname(mar_detail_reply->orders[
          order_cnt].administrations[admin_cnt].discretes[discrete_cnt].result_comments[
          result_comment_cnt].note_prsnl_id,cnvtdatetime(mar_detail_reply->orders[order_cnt].
           administrations[admin_cnt].discretes[discrete_cnt].result_comments[result_comment_cnt].
           note_dt_tm),prsnl_name)
        ENDFOR
        FOR (event_prsnl_actions_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].administrations[
         admin_cnt].discretes[discrete_cnt].event_prsnl_actions,5))
          SET prsnl_name = mar_detail_reply->orders[order_cnt].administrations[admin_cnt].discretes[
          discrete_cnt].event_prsnl_actions[event_prsnl_actions_cnt].action_prsnl_name
          SET mar_detail_reply->orders[order_cnt].administrations[admin_cnt].discretes[discrete_cnt].
          event_prsnl_actions[event_prsnl_actions_cnt].action_prsnl_name = getprsnlname(
           mar_detail_reply->orders[order_cnt].administrations[admin_cnt].discretes[discrete_cnt].
           event_prsnl_actions[event_prsnl_actions_cnt].action_prsnl_id,cnvtdatetime(mar_detail_reply
            ->orders[order_cnt].administrations[admin_cnt].discretes[discrete_cnt].
            event_prsnl_actions[event_prsnl_actions_cnt].action_dt_tm),prsnl_name)
          SET prsnl_name = mar_detail_reply->orders[order_cnt].administrations[admin_cnt].discretes[
          discrete_cnt].event_prsnl_actions[event_prsnl_actions_cnt].request_prsnl_name
          SET mar_detail_reply->orders[order_cnt].administrations[admin_cnt].discretes[discrete_cnt].
          event_prsnl_actions[event_prsnl_actions_cnt].request_prsnl_name = getprsnlname(
           mar_detail_reply->orders[order_cnt].administrations[admin_cnt].discretes[discrete_cnt].
           event_prsnl_actions[event_prsnl_actions_cnt].request_prsnl_id,cnvtdatetime(
            mar_detail_reply->orders[order_cnt].administrations[admin_cnt].discretes[discrete_cnt].
            event_prsnl_actions[event_prsnl_actions_cnt].request_dt_tm),prsnl_name)
          SET prsnl_name = mar_detail_reply->orders[order_cnt].administrations[admin_cnt].discretes[
          discrete_cnt].event_prsnl_actions[event_prsnl_actions_cnt].proxy_prsnl_name
          SET mar_detail_reply->orders[order_cnt].administrations[admin_cnt].discretes[discrete_cnt].
          event_prsnl_actions[event_prsnl_actions_cnt].proxy_prsnl_name = getprsnlname(
           mar_detail_reply->orders[order_cnt].administrations[admin_cnt].discretes[discrete_cnt].
           event_prsnl_actions[event_prsnl_actions_cnt].proxy_prsnl_id,cnvtdatetime(mar_detail_reply
            ->orders[order_cnt].administrations[admin_cnt].discretes[discrete_cnt].
            event_prsnl_actions[event_prsnl_actions_cnt].action_dt_tm),prsnl_name)
        ENDFOR
       ENDFOR
     ENDFOR
     FOR (responseresult_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].responseresults,5))
       FOR (response_action_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].responseresults[
        responseresult_cnt].response_actions,5))
         FOR (event_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].responseresults[
          responseresult_cnt].response_actions[response_action_cnt].events,5))
          FOR (result_comments_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].responseresults[
           responseresult_cnt].response_actions[response_action_cnt].events[event_cnt].
           result_comments,5))
           SET prsnl_name = mar_detail_reply->orders[order_cnt].responseresults[responseresult_cnt].
           response_actions[response_action_cnt].events[event_cnt].result_comments[
           result_comments_cnt].note_prsnl_name
           SET mar_detail_reply->orders[order_cnt].responseresults[responseresult_cnt].
           response_actions[response_action_cnt].events[event_cnt].result_comments[
           result_comments_cnt].note_prsnl_name = getprsnlname(mar_detail_reply->orders[order_cnt].
            responseresults[responseresult_cnt].response_actions[response_action_cnt].events[
            event_cnt].result_comments[result_comments_cnt].note_prsnl_id,cnvtdatetime(
             mar_detail_reply->orders[order_cnt].responseresults[responseresult_cnt].
             response_actions[response_action_cnt].events[event_cnt].result_comments[
             result_comments_cnt].note_dt_tm),prsnl_name)
          ENDFOR
          FOR (event_prsnl_action_cnt = 1 TO size(mar_detail_reply->orders[order_cnt].
           responseresults[responseresult_cnt].response_actions[response_action_cnt].events[event_cnt
           ].event_prsnl_actions,5))
            SET prsnl_name = mar_detail_reply->orders[order_cnt].responseresults[responseresult_cnt].
            response_actions[response_action_cnt].events[event_cnt].event_prsnl_actions[
            event_prsnl_action_cnt].action_prsnl_name
            SET mar_detail_reply->orders[order_cnt].responseresults[responseresult_cnt].
            response_actions[response_action_cnt].events[event_cnt].event_prsnl_actions[
            event_prsnl_action_cnt].action_prsnl_name = getprsnlname(mar_detail_reply->orders[
             order_cnt].responseresults[responseresult_cnt].response_actions[response_action_cnt].
             events[event_cnt].event_prsnl_actions[event_prsnl_action_cnt].action_prsnl_id,
             cnvtdatetime(mar_detail_reply->orders[order_cnt].responseresults[responseresult_cnt].
              response_actions[response_action_cnt].events[event_cnt].event_prsnl_actions[
              event_prsnl_action_cnt].action_dt_tm),prsnl_name)
            SET prsnl_name = mar_detail_reply->orders[order_cnt].responseresults[responseresult_cnt].
            response_actions[response_action_cnt].events[event_cnt].event_prsnl_actions[
            event_prsnl_action_cnt].request_prsnl_name
            SET mar_detail_reply->orders[order_cnt].responseresults[responseresult_cnt].
            response_actions[response_action_cnt].events[event_cnt].event_prsnl_actions[
            event_prsnl_action_cnt].request_prsnl_name = getprsnlname(mar_detail_reply->orders[
             order_cnt].responseresults[responseresult_cnt].response_actions[response_action_cnt].
             events[event_cnt].event_prsnl_actions[event_prsnl_action_cnt].request_prsnl_id,
             cnvtdatetime(mar_detail_reply->orders[order_cnt].responseresults[responseresult_cnt].
              response_actions[response_action_cnt].events[event_cnt].event_prsnl_actions[
              event_prsnl_action_cnt].request_dt_tm),prsnl_name)
            SET prsnl_name = mar_detail_reply->orders[order_cnt].responseresults[responseresult_cnt].
            response_actions[response_action_cnt].events[event_cnt].event_prsnl_actions[
            event_prsnl_action_cnt].proxy_prsnl_name
            SET mar_detail_reply->orders[order_cnt].responseresults[responseresult_cnt].
            response_actions[response_action_cnt].events[event_cnt].event_prsnl_actions[
            event_prsnl_action_cnt].proxy_prsnl_name = getprsnlname(mar_detail_reply->orders[
             order_cnt].responseresults[responseresult_cnt].response_actions[response_action_cnt].
             events[event_cnt].event_prsnl_actions[event_prsnl_action_cnt].proxy_prsnl_id,
             cnvtdatetime(mar_detail_reply->orders[order_cnt].responseresults[responseresult_cnt].
              response_actions[response_action_cnt].events[event_cnt].event_prsnl_actions[
              event_prsnl_action_cnt].action_dt_tm),prsnl_name)
          ENDFOR
         ENDFOR
       ENDFOR
     ENDFOR
   ENDFOR
   IF (debug_ind=1)
    CALL echo(build("********LoadPrsnlInfo - ProcessPrsnl Total Subroutine Time = ",datetimediff(
       cnvtdatetime(curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE getprsnlname(person_id,actiondttm,prsnl_name)
   IF (person_id <= 0)
    RETURN(prsnl_name)
   ENDIF
   IF (actiondttm <= 0)
    RETURN(prsnl_name)
   ENDIF
   DECLARE provider_size = i4 WITH protect, noconstant(0)
   DECLARE name_hist_cnt = i4 WITH protect, noconstant(0)
   SET provider_size = size(prsnl_reply->providers,5)
   IF (provider_size <= 0)
    RETURN(prsnl_name)
   ENDIF
   SET iterator = 0
   SET index_loc = locateval(iterator,1,provider_size,person_id,prsnl_reply->providers[iterator].
    person_id)
   IF (index_loc > 0)
    FOR (name_hist_cnt = 1 TO size(prsnl_reply->providers[index_loc].name_hist,5))
      IF (cnvtdatetime(prsnl_reply->providers[index_loc].name_hist[name_hist_cnt].beg_effective_dt_tm
       ) <= actiondttm
       AND cnvtdatetime(prsnl_reply->providers[index_loc].name_hist[name_hist_cnt].
       end_effective_dt_tm) >= actiondttm)
       RETURN(prsnl_reply->providers[index_loc].name_hist[name_hist_cnt].name_full_formatted)
      ENDIF
    ENDFOR
   ENDIF
   RETURN(prsnl_name)
 END ;Subroutine
 DECLARE totalscripttime = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE subroutinetime = f8 WITH protect, noconstant(0)
 DECLARE querytime = f8 WITH protect, noconstant(0)
 EXECUTE dcp_gen_mar_detail_reqs
 DECLARE cpharmacy_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE ccanceled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"CANCELED"))
 DECLARE ccompleted_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE cdeleted_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"DELETED"))
 DECLARE cdiscontinued_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
 DECLARE ctrans_cancel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"TRANS/CANCEL"))
 DECLARE cvoidedwrslt_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"VOIDEDWRSLT"))
 DECLARE cpowerchart = f8 WITH protect, constant(uar_get_code_by("MEANING",73,"POWERCHART"))
 DECLARE ceventmed = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"MED"))
 DECLARE ceventimmun = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"IMMUN"))
 DECLARE cgrp = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"GRP"))
 DECLARE cplaceholder = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"PLACEHOLDER"))
 DECLARE cio = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"IO"))
 DECLARE cdate = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"DATE"))
 DECLARE cmed = f8 WITH protect, constant(uar_get_code_by("MEANING",18309,"MED"))
 DECLARE cint = f8 WITH protect, constant(uar_get_code_by("MEANING",18309,"INTERMITTENT"))
 DECLARE civ = f8 WITH protect, constant(uar_get_code_by("MEANING",18309,"IV"))
 DECLARE civparent = f8 WITH protect, constant(uar_get_code_by("MEANING",72,"IVPARENT"))
 DECLARE cnotdone = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE cinerror = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE cdcpgeneric = f8 WITH protect, noconstant(0.0)
 DECLARE cacknowledge_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002218,"ACKNOWLEDGE")
  )
 DECLARE cmedadmin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",255431,"MEDADMIN"))
 DECLARE cbase = i2 WITH protect, constant(2)
 DECLARE cadditive = i2 WITH protect, constant(3)
 DECLARE icompoundchild = i2 WITH protect, constant(5)
 DECLARE crtf = f8 WITH protect, constant(uar_get_code_by("MEANING",23,"RTF"))
 DECLARE ccompressed = f8 WITH protect, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE cclincalevent = f8 WITH protect, constant(uar_get_code_by("MEANING",18189,"CLINCALEVENT"))
 DECLARE crtaskevent = f8 WITH protect, constant(uar_get_code_by("MEANING",18189,"RTASKEVENT"))
 DECLARE cmodify = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"MODIFY"))
 DECLARE creschedule = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"RESCHEDULE"))
 DECLARE corder = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE cdisplay_anchor_first = i4 WITH protect, constant(1)
 DECLARE cdisplay_additives_first = i4 WITH protect, constant(2)
 DECLARE cdisplay_diluent_first = i4 WITH protect, constant(3)
 SELECT INTO "NL:"
  FROM code_value_alias cva
  PLAN (cva
   WHERE cva.contributor_source_cd=cpowerchart
    AND cva.alias=cnvtupper("DCPGENERIC"))
  DETAIL
   cdcpgeneric = cva.code_value
  WITH nocounter
 ;end select
 DECLARE validaterequest(null) = null
 DECLARE loadordersandactions(null) = null
 DECLARE loadactionsschedules(null) = null
 DECLARE loadactioningred(null) = null
 DECLARE loadactionnotes(null) = null
 DECLARE loadactionorderreview(null) = null
 DECLARE loadactiondetails(null) = null
 DECLARE loadadminingredcomments(null) = null
 DECLARE loadadminingredprsnl(null) = null
 DECLARE loadadministrations(null) = null
 DECLARE loadadminnotes(null) = null
 DECLARE loadadminprsnl(null) = null
 DECLARE loadadminingreds(null) = null
 DECLARE loaddiscretes(null) = null
 DECLARE loaddiscrhistcomments(null) = null
 DECLARE loaddiscrprsnl(null) = null
 DECLARE loadacknowledgments(null) = null
 DECLARE loadacknowlnotes(null) = null
 DECLARE loadresponseresults(null) = null
 DECLARE loadresponsecomments(null) = null
 DECLARE loadresponseprsnl(null) = null
 DECLARE loadtasks(null) = null
 DECLARE mapneedrxclinreviewflag(null) = null
 DECLARE saveerrordata(error_desc=vc,order_id=f8,event_id=f8) = null
 DECLARE displayerrorinfo(subroutinename=vc,parama=vc,paramb=vc,paramc=vc,paramd=vc) = null
 DECLARE parsecommentlb(note_fromat_cd=f8,compression_cd=f8,long_blob=vc) = vc
 DECLARE parseactionseqiv(order_action_seq=i4,collating_seq=vc) = i4
 DECLARE loadprsnlinfo(null) = null
 DECLARE sortingredientsforiv(null) = null
 DECLARE sortingredients(order_idx=i4,action_idx=i4,sort_flag=i4) = null
 DECLARE copyingredientstotemp(order_idx=i4,action_idx=i4,ingred_idx=i4,temp_ingred_idx=i4) = null
 DECLARE last_mod = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE max_action_cnt = i4 WITH noconstant(0)
 DECLARE max_admin_cnt = i4 WITH noconstant(0)
 DECLARE max_admin_hist_cnt = i4 WITH noconstant(0)
 DECLARE max_dta_cnt = i4 WITH noconstant(0)
 DECLARE max_ack_cnt = i4 WITH noconstant(0)
 DECLARE max_admin_ingred = i4 WITH noconstant(0)
 DECLARE max_response_cnt = i4 WITH noconstant(0)
 DECLARE max_resp_action_cnt = i4 WITH noconstant(0)
 DECLARE max_resp_ce_cnt = i4 WITH noconstant(0)
 DECLARE max_event_cd_cnt = i4 WITH noconstant(0)
 DECLARE max_ingred_cd_cnt = i4 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE debug_ind = i4 WITH noconstant(0)
 DECLARE error_cnt = i4 WITH noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i2 WITH protect, noconstant(0)
 DECLARE debug_param_a_id = f8 WITH protect, noconstant(0.0)
 DECLARE debug_param_b_id = f8 WITH protect, noconstant(0.0)
 DECLARE debug_param_c_id = f8 WITH protect, noconstant(0.0)
 DECLARE debug_param_d_id = f8 WITH protect, noconstant(0.0)
 DECLARE return_inactive_orders = i2 WITH noconstant(0)
 DECLARE return_order_review = i2 WITH noconstant(0)
 DECLARE return_order_details = i2 WITH noconstant(0)
 DECLARE return_order_ingredients = i2 WITH noconstant(0)
 DECLARE return_future_tasks = i2 WITH noconstant(0)
 DECLARE i18nhandledetails = i4 WITH protect, noconstant(0)
 SET stat = uar_i18nlocalizationinit(i18nhandledetails,curprog,"",curcclrev)
 DECLARE i18n_snotgiven = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandledetails,
    "i18n_NOT_GIVEN","Not Given"),3))
 DECLARE i18n_snotdone = vc WITH protect, constant(trim(uar_i18ngetmessage(i18nhandledetails,
    "i18n_NOT_DONE","Not Done"),3))
 FREE SET temp_ingreds
 RECORD temp_ingreds(
   1 order_ingredients[*]
     2 action_sequence = i2
     2 comp_sequence = i2
     2 order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 hna_order_mnemonic = vc
     2 strength = f8
     2 strength_unit = f8
     2 volume = f8
     2 volume_unit = f8
     2 volume_flag = f8
     2 total_volume = f8
     2 bag_freq = f8
     2 dose_quantity = f8
     2 dose_quantity_unit_cd = f8
     2 freetext_dose = vc
     2 ingredient_type_flag = i2
     2 normalized_rate = f8
     2 normalized_rate_unit_cd = f8
     2 normalized_rate_unit_cd_disp = vc
     2 normalized_rate_unit_cd_desc = vc
     2 normalized_rate_unit_cd_mean = vc
     2 ingredient_rate_conversion_ind = i2
     2 already_sorted_ind = i2
 )
 CALL validaterequest(null)
 CALL loadordersandactions(null)
 IF (max_action_cnt > 0)
  CALL loadactionsschedules(null)
  CALL loadactionnotes(null)
  IF (return_order_ingredients=1)
   CALL loadactioningred(null)
   CALL sortingredientsforiv(null)
  ENDIF
  IF (return_order_review=1)
   CALL loadactionorderreview(null)
  ENDIF
  IF (return_order_details=1)
   CALL loadactiondetails(null)
  ENDIF
 ENDIF
 CALL mapneedrxclinreviewflag(null)
 CALL loadadministrations(null)
 IF (max_admin_cnt > 0)
  CALL loadadminnotes(null)
  CALL loadadminprsnl(null)
  CALL loadadminingreds(null)
  IF (max_admin_ingred > 0)
   CALL loadadminingredcomments(null)
   CALL loadadminingredprsnl(null)
  ENDIF
  CALL loaddiscretes(null)
  IF (max_dta_cnt > 0)
   CALL loaddiscrhistcomments(null)
   CALL loaddiscrprsnl(null)
  ENDIF
  CALL loadacknowledgments(null)
  IF (max_ack_cnt > 0)
   CALL loadacknowlnotes(null)
  ENDIF
  CALL loadresponseresults(null)
  IF (max_response_cnt > 0)
   CALL loadresponsecomments(null)
   CALL loadresponseprsnl(null)
  ENDIF
 ENDIF
 IF (return_future_tasks=1)
  CALL loadtasks(null)
 ENDIF
 IF (size(mar_detail_reply->orders,5) > 0)
  CALL loadprsnlinfo(null)
 ENDIF
 IF (debug_ind=1)
  CALL echo("*********************************")
  CALL echo(build("Total script time in seconds = ",datetimediff(cnvtdatetime(curdate,curtime3),
     totalscripttime,5)))
  CALL echo("*********************************")
 ENDIF
#exit_program
 SUBROUTINE validaterequest(null)
   CALL echo("ValidateRequest")
   IF (validate(mar_detail_request->debug_ind))
    SET debug_ind = mar_detail_request->debug_ind
   ELSE
    SET debug_ind = 0
   ENDIF
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   IF (validate(mar_detail_request->return_inactive_orders))
    SET return_inactive_orders = mar_detail_request->return_inactive_orders
   ELSE
    SET return_inactive_orders = 1
   ENDIF
   IF (validate(mar_detail_request->return_order_review_data))
    SET return_order_review = mar_detail_request->return_order_review_data
   ELSE
    SET return_order_review = 1
   ENDIF
   IF (validate(mar_detail_request->return_order_detail_data))
    SET return_order_details = mar_detail_request->return_order_detail_data
   ELSE
    SET return_order_details = 0
   ENDIF
   IF (validate(mar_detail_request->return_order_ingredient_data))
    SET return_order_ingredients = mar_detail_request->return_order_ingredient_data
   ELSE
    SET return_order_ingredients = 1
   ENDIF
   IF (validate(mar_detail_request->return_future_task_data))
    SET return_future_tasks = mar_detail_request->return_future_task_data
   ELSE
    SET return_future_tasks = 0
   ENDIF
   SET mar_detail_reply->status_data.status = "F"
   IF (debug_ind=1)
    CALL echo(build("********ValidateRequest Total Subroutine Time = ",datetimediff(cnvtdatetime(
        curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadordersandactions(null)
   CALL echo("LoadOrdersAndActions")
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   DECLARE order_cnt = i4 WITH noconstant(0)
   DECLARE action_cnt = i4 WITH noconstant(0)
   DECLARE encntr_cnt = i4 WITH noconstant(0)
   RECORD encntrs_to_load(
     1 encntr_list[*]
       2 encntr_id = f8
   )
   IF ((mar_detail_request->scope_flag=5))
    SET stat = alterlist(encntrs_to_load->encntr_list,size(mar_detail_request->encntr_list,5))
    FOR (encntr_cnt = 1 TO size(mar_detail_request->encntr_list,5))
      SET encntrs_to_load->encntr_list[encntr_cnt].encntr_id = mar_detail_request->encntr_list[
      encntr_cnt].encntr_id
    ENDFOR
   ELSE
    SET stat = alterlist(encntrs_to_load->encntr_list,1)
    SET encntrs_to_load->encntr_list[1].encntr_id = mar_detail_request->encntr_id
   ENDIF
   IF (debug_ind=1)
    SET querytime = cnvtdatetime(curdate,curtime3)
   ENDIF
   SELECT INTO "nl:"
    FROM orders o,
     order_action oa,
     prsnl p,
     (dummyt dencntrs  WITH seq = value(size(encntrs_to_load->encntr_list,5)))
    PLAN (dencntrs)
     JOIN (o
     WHERE (o.person_id=mar_detail_request->person_id)
      AND o.catalog_type_cd=cpharmacy_cd
      AND ((o.template_order_id+ 0)=0)
      AND ((o.template_order_flag+ 0) IN (0, 1, 4))
      AND ((o.orderable_type_flag+ 0) IN (0, 1, 8, 10, 11,
     13))
      AND (o.encntr_id=encntrs_to_load->encntr_list[dencntrs.seq].encntr_id)
      AND ((o.orig_ord_as_flag+ 0) IN (0, 5))
      AND  NOT (((o.order_status_cd+ 0) IN (evaluate(return_inactive_orders,0,ccanceled_cd,1,0),
     evaluate(return_inactive_orders,0,ccompleted_cd,1,0), evaluate(return_inactive_orders,0,
      cdeleted_cd,1,0), evaluate(return_inactive_orders,0,cdiscontinued_cd,1,0), evaluate(
      return_inactive_orders,0,ctrans_cancel_cd,1,0),
     evaluate(return_inactive_orders,0,cvoidedwrslt_cd,1,0)))))
     JOIN (oa
     WHERE oa.order_id=o.order_id)
     JOIN (p
     WHERE p.person_id=oa.action_personnel_id)
    ORDER BY o.order_id, oa.action_sequence
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadOrdersAndActions Query Time = ",datetimediff(cnvtdatetime(curdate,
         curtime3),querytime,5)))
     ENDIF
     order_cnt = 0
    HEAD o.order_id
     debug_param_a_id = o.order_id, action_cnt = 0, order_cnt = (order_cnt+ 1)
     IF (order_cnt > size(mar_detail_reply->orders,5))
      stat = alterlist(mar_detail_reply->orders,(order_cnt+ 9))
     ENDIF
     mar_detail_reply->orders[order_cnt].top_level_order_id = o.order_id, mar_detail_reply->orders[
     order_cnt].top_level_encntr_id = o.encntr_id, mar_detail_reply->orders[order_cnt].
     top_level_order_type = o.med_order_type_cd,
     mar_detail_reply->orders[order_cnt].top_level_core_action_seq = o.last_core_action_sequence,
     mar_detail_reply->orders[order_cnt].top_level_freq_type = o.freq_type_flag, mar_detail_reply->
     orders[order_cnt].top_level_prn_ind = o.prn_ind,
     mar_detail_reply->orders[order_cnt].top_level_order_mnemonic = o.order_mnemonic,
     mar_detail_reply->orders[order_cnt].top_level_ordered_as_mnemonic = o.ordered_as_mnemonic,
     mar_detail_reply->orders[order_cnt].top_level_hna_order_mnemonic = o.hna_order_mnemonic,
     mar_detail_reply->orders[order_cnt].top_level_verify_ind = o.need_rx_verify_ind,
     mar_detail_reply->orders[order_cnt].top_level_need_rx_clin_review_flag = o
     .need_rx_clin_review_flag, mar_detail_reply->orders[order_cnt].top_level_cosign_ind = o
     .need_doctor_cosign_ind,
     mar_detail_reply->orders[order_cnt].top_level_need_nurse_review_ind = o.need_nurse_review_ind,
     mar_detail_reply->orders[order_cnt].top_level_need_physician_validate_ind = o
     .need_physician_validate_ind, mar_detail_reply->orders[order_cnt].top_level_catalog_cd = o
     .catalog_cd,
     mar_detail_reply->orders[order_cnt].top_level_catalog_type_cd = o.catalog_type_cd,
     mar_detail_reply->orders[order_cnt].top_level_activity_type_cd = o.activity_type_cd,
     mar_detail_reply->orders[order_cnt].top_level_order_status_cd = o.order_status_cd
    HEAD oa.action_sequence
     action_cnt = (action_cnt+ 1), debug_param_b_id = oa.action_sequence, debug_param_c_id =
     action_cnt
     IF (action_cnt > size(mar_detail_reply->orders[order_cnt].order_actions,5))
      stat = alterlist(mar_detail_reply->orders[order_cnt].order_actions,(action_cnt+ 9))
     ENDIF
     IF (action_cnt > max_action_cnt)
      max_action_cnt = action_cnt
     ENDIF
     mar_detail_reply->orders[order_cnt].order_actions[action_cnt].action_type_cd = oa.action_type_cd,
     mar_detail_reply->orders[order_cnt].order_actions[action_cnt].action_dt_tm = oa.action_dt_tm,
     mar_detail_reply->orders[order_cnt].order_actions[action_cnt].action_tz = oa.action_tz,
     mar_detail_reply->orders[order_cnt].order_actions[action_cnt].needs_verify_ind = oa
     .needs_verify_ind, mar_detail_reply->orders[order_cnt].order_actions[action_cnt].
     need_rx_clin_review_flag = oa.need_clin_review_flag, mar_detail_reply->orders[order_cnt].
     order_actions[action_cnt].order_app_nbr = oa.order_app_nbr,
     mar_detail_reply->orders[order_cnt].order_actions[action_cnt].effective_dt_tm = oa
     .effective_dt_tm, mar_detail_reply->orders[order_cnt].order_actions[action_cnt].effective_tz =
     oa.effective_tz, mar_detail_reply->orders[order_cnt].order_actions[action_cnt].action_sequence
      = oa.action_sequence,
     mar_detail_reply->orders[order_cnt].order_actions[action_cnt].action_personnel_id = oa
     .action_personnel_id, mar_detail_reply->orders[order_cnt].order_actions[action_cnt].
     clinical_display_line = oa.clinical_display_line, mar_detail_reply->orders[order_cnt].
     order_actions[action_cnt].core_ind = oa.core_ind,
     mar_detail_reply->orders[order_cnt].order_actions[action_cnt].prn_ind = oa.prn_ind,
     mar_detail_reply->orders[order_cnt].order_actions[action_cnt].order_id = oa.order_id,
     mar_detail_reply->orders[order_cnt].order_actions[action_cnt].frequency_id = oa.frequency_id,
     mar_detail_reply->orders[order_cnt].order_actions[action_cnt].action_person = p
     .name_full_formatted, mar_detail_reply->orders[order_cnt].order_actions[action_cnt].
     action_personnel_name = p.name_full_formatted
    FOOT  o.order_id
     stat = alterlist(mar_detail_reply->orders[order_cnt].order_actions,action_cnt)
    FOOT REPORT
     stat = alterlist(mar_detail_reply->orders,order_cnt)
     IF (debug_ind=1)
      CALL echo(build("********LoadOrdersAndActions Query Total Time = ",datetimediff(cnvtdatetime(
         curdate,curtime3),querytime,5)))
     ENDIF
    WITH nocounter
   ;end select
   FREE RECORD encntrs_to_load
   CALL displayerrorinfo("LoadOrdersAndActions","o.order_id","oa.action_sequence","action_cnt","")
   IF (debug_ind=1)
    CALL echo(build("********LoadOrdersAndActions Total Subroutine Time = ",datetimediff(cnvtdatetime
       (curdate,curtime3),subroutinetime,5)))
   ENDIF
   IF (curqual=0)
    SET mar_detail_reply->status_data.status = "Z"
    GO TO exit_program
   ELSE
    SET mar_detail_reply->status_data.status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE loadactionsschedules(null)
   CALL echo("LoadActionsSchedules")
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   DECLARE sched_act_cnt = i4 WITH noconstant(0)
   IF (debug_ind=1)
    SET querytime = cnvtdatetime(curdate,curtime3)
   ENDIF
   SELECT INTO "nl:"
    FROM frequency_schedule fs,
     scheduled_time_of_day stod,
     (dummyt dorders  WITH seq = value(size(mar_detail_reply->orders,5))),
     (dummyt dactions  WITH seq = value(max_action_cnt))
    PLAN (dorders)
     JOIN (dactions
     WHERE dactions.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].order_actions,5)))
     JOIN (fs
     WHERE fs.frequency_id=outerjoin(mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq
      ].frequency_id))
     JOIN (stod
     WHERE stod.frequency_cd=outerjoin(fs.frequency_cd)
      AND stod.freq_qualifier=outerjoin(fs.freq_qualifier)
      AND stod.parent_entity_id=outerjoin(fs.parent_entity_id)
      AND stod.parent_entity=outerjoin(fs.parent_entity)
      AND stod.activity_type_cd=outerjoin(fs.activity_type_cd)
      AND stod.facility_cd=outerjoin(fs.facility_cd)
      AND stod.instance=outerjoin(fs.instance))
    ORDER BY dorders.seq, dactions.seq, fs.frequency_id,
     stod.time_of_day
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadActionsSchedules Query Time = ",datetimediff(cnvtdatetime(curdate,
         curtime3),querytime,5)))
     ENDIF
    HEAD dorders.seq
     debug_param_a_id = mar_detail_reply->orders[dorders.seq].top_level_order_id, sched_act_cnt = 0
    HEAD dactions.seq
     debug_param_b_id = mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].
     action_sequence, sched_act_cnt = 0
    DETAIL
     sched_act_cnt = (sched_act_cnt+ 1), debug_param_c_id = fs.frequency_id, debug_param_d_id =
     sched_act_cnt
     IF (sched_act_cnt > size(mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].
      schedule,5))
      stat = alterlist(mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].schedule,(
       sched_act_cnt+ 9))
     ENDIF
     mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].schedule[sched_act_cnt].
     time_of_day = stod.time_of_day
    FOOT  dactions.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].schedule,
      sched_act_cnt)
    FOOT  dorders.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].schedule,
      sched_act_cnt)
    FOOT REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadActionsSchedules Query Total Time = ",datetimediff(cnvtdatetime(
         curdate,curtime3),querytime,5)))
     ENDIF
    WITH nocounter
   ;end select
   CALL displayerrorinfo("LoadActionsSchedules","order_id","action_sequence","fs.frequency_id",
    "sched_act_cnt")
   IF (debug_ind=1)
    CALL echo(build("********LoadActionsSchedules Total Subroutine Time = ",datetimediff(cnvtdatetime
       (curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadactioningred(null)
   CALL echo("LoadActionIngred")
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   DECLARE act_ing_cnt = i4 WITH noconstant(0)
   IF (debug_ind=1)
    SET querytime = cnvtdatetime(curdate,curtime3)
   ENDIF
   SELECT INTO "nl:"
    FROM order_ingredient oi,
     order_catalog_synonym ocs,
     (dummyt dorders  WITH seq = value(size(mar_detail_reply->orders,5))),
     (dummyt dactions  WITH seq = value(max_action_cnt))
    PLAN (dorders)
     JOIN (dactions
     WHERE dactions.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].order_actions,5)))
     JOIN (oi
     WHERE (oi.order_id=mar_detail_reply->orders[dorders.seq].top_level_order_id)
      AND (oi.action_sequence=mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].
     action_sequence)
      AND oi.ingredient_type_flag != icompoundchild)
     JOIN (ocs
     WHERE ocs.synonym_id=oi.synonym_id)
    ORDER BY oi.order_id, oi.action_sequence, oi.comp_sequence
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadActionIngred Query Time = ",datetimediff(cnvtdatetime(curdate,
         curtime3),querytime,5)))
     ENDIF
    HEAD dorders.seq
     act_ing_cnt = 0
    HEAD dactions.seq
     act_ing_cnt = 0
    HEAD oi.comp_sequence
     act_ing_cnt = (act_ing_cnt+ 1), debug_param_a_id = oi.order_id, debug_param_b_id = oi
     .action_sequence,
     debug_param_c_id = oi.comp_sequence, debug_param_d_id = act_ing_cnt
     IF (act_ing_cnt > size(mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].
      order_ingredients,5))
      stat = alterlist(mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].
       order_ingredients,(act_ing_cnt+ 9))
     ENDIF
     mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].order_ingredients[act_ing_cnt]
     .action_sequence = oi.action_sequence, mar_detail_reply->orders[dorders.seq].order_actions[
     dactions.seq].order_ingredients[act_ing_cnt].comp_sequence = oi.comp_sequence, mar_detail_reply
     ->orders[dorders.seq].order_actions[dactions.seq].order_ingredients[act_ing_cnt].order_mnemonic
      = oi.order_mnemonic,
     mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].order_ingredients[act_ing_cnt]
     .ordered_as_mnemonic = oi.ordered_as_mnemonic, mar_detail_reply->orders[dorders.seq].
     order_actions[dactions.seq].order_ingredients[act_ing_cnt].hna_order_mnemonic = oi
     .hna_order_mnemonic, mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].
     order_ingredients[act_ing_cnt].strength = oi.strength,
     mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].order_ingredients[act_ing_cnt]
     .strength_unit = oi.strength_unit, mar_detail_reply->orders[dorders.seq].order_actions[dactions
     .seq].order_ingredients[act_ing_cnt].volume = oi.volume, mar_detail_reply->orders[dorders.seq].
     order_actions[dactions.seq].order_ingredients[act_ing_cnt].volume_unit = oi.volume_unit,
     mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].order_ingredients[act_ing_cnt]
     .volume_flag = oi.include_in_total_volume_flag, mar_detail_reply->orders[dorders.seq].
     order_actions[dactions.seq].order_ingredients[act_ing_cnt].bag_freq = oi.freq_cd,
     mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].order_ingredients[act_ing_cnt]
     .dose_quantity = oi.dose_quantity,
     mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].order_ingredients[act_ing_cnt]
     .dose_quantity_unit_cd = oi.dose_quantity_unit, mar_detail_reply->orders[dorders.seq].
     order_actions[dactions.seq].order_ingredients[act_ing_cnt].freetext_dose = oi.freetext_dose,
     mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].order_ingredients[act_ing_cnt]
     .ingredient_type_flag = oi.ingredient_type_flag,
     mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].order_ingredients[act_ing_cnt]
     .normalized_rate = oi.normalized_rate, mar_detail_reply->orders[dorders.seq].order_actions[
     dactions.seq].order_ingredients[act_ing_cnt].normalized_rate_unit_cd = oi
     .normalized_rate_unit_cd, mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].
     order_ingredients[act_ing_cnt].ingredient_rate_conversion_ind = ocs
     .ingredient_rate_conversion_ind
     IF ((mar_detail_reply->orders[dorders.seq].top_level_order_type=civ))
      IF (validate(ocs.display_additives_first_ind))
       IF (ocs.display_additives_first_ind=1)
        mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].display_additives_first_ind
         = 1
       ENDIF
      ENDIF
      IF (ocs.ingredient_rate_conversion_ind=1)
       mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].titratable_iv_ind = 1
      ENDIF
     ENDIF
    FOOT  dactions.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].
      order_ingredients,act_ing_cnt)
    FOOT  dorders.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].
      order_ingredients,act_ing_cnt)
    FOOT REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadActionIngred Query Total Time = ",datetimediff(cnvtdatetime(
         curdate,curtime3),querytime,5)))
     ENDIF
    WITH nocounter
   ;end select
   CALL displayerrorinfo("LoadActionIngred","oi.order_id","oi.action_sequence","oi.comp_sequence",
    "act_ing_cnt")
   IF (debug_ind=1)
    CALL echo(build("********LoadActionIngred Total Subroutine Time = ",datetimediff(cnvtdatetime(
        curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE sortingredientsforiv(null)
   CALL echo("SortIngredientsForIV")
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE j = i4 WITH protect, noconstant(0)
   FOR (i = 1 TO size(mar_detail_reply->orders,5))
     IF ((mar_detail_reply->orders[i].top_level_order_type=civ))
      FOR (j = 1 TO size(mar_detail_reply->orders[i].order_actions,5))
        IF ((mar_detail_reply->orders[i].order_actions[j].titratable_iv_ind=1))
         CALL sortingredients(i,j,cdisplay_anchor_first)
        ELSE
         IF ((mar_detail_reply->orders[i].order_actions[j].display_additives_first_ind=1))
          CALL sortingredients(i,j,cdisplay_additives_first)
         ELSE
          CALL sortingredients(i,j,cdisplay_diluent_first)
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (debug_ind=1)
    CALL echo(build("********SortIngredientsForIV Total Subroutine Time = ",datetimediff(cnvtdatetime
       (curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE sortingredients(order_idx,action_idx,sort_flag)
   IF (debug_ind=1)
    CALL echo("SortIngredients")
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   DECLARE order_cnt = i4 WITH protect, noconstant(0)
   DECLARE action_cnt = i4 WITH protect, noconstant(0)
   DECLARE ingred_cnt = i4 WITH protect, noconstant(0)
   DECLARE temp_ingred_cnt = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   SET order_cnt = size(mar_detail_reply->orders,5)
   IF (((order_idx < 0) OR (order_idx > order_cnt)) )
    RETURN
   ENDIF
   SET action_cnt = size(mar_detail_reply->orders[order_idx].order_actions,5)
   IF (((action_idx < 0) OR (action_idx > action_cnt)) )
    RETURN
   ENDIF
   SET ingred_cnt = size(mar_detail_reply->orders[order_idx].order_actions[action_idx].
    order_ingredients,5)
   SET stat = alterlist(temp_ingreds->order_ingredients,0)
   SET stat = alterlist(temp_ingreds->order_ingredients,ingred_cnt)
   SET temp_ingred_cnt = 0
   IF (sort_flag=cdisplay_anchor_first)
    FOR (i = 1 TO ingred_cnt)
      IF ((mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
      normalized_rate_unit_cd > 0))
       SET temp_ingred_cnt = (temp_ingred_cnt+ 1)
       CALL copyingredientstotemp(order_idx,action_idx,i,temp_ingred_cnt)
       SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
       already_sorted_ind = 1
      ENDIF
    ENDFOR
    FOR (i = 1 TO ingred_cnt)
      IF ((mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
      already_sorted_ind=0)
       AND (mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
      ingredient_type_flag=cadditive))
       SET temp_ingred_cnt = (temp_ingred_cnt+ 1)
       CALL copyingredientstotemp(order_idx,action_idx,i,temp_ingred_cnt)
       SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
       already_sorted_ind = 1
      ENDIF
    ENDFOR
    FOR (i = 1 TO ingred_cnt)
      IF ((mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
      already_sorted_ind=0)
       AND (mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
      ingredient_type_flag=cbase))
       SET temp_ingred_cnt = (temp_ingred_cnt+ 1)
       CALL copyingredientstotemp(order_idx,action_idx,i,temp_ingred_cnt)
       SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
       already_sorted_ind = 1
      ENDIF
    ENDFOR
   ELSEIF (sort_flag=cdisplay_additives_first)
    FOR (i = 1 TO ingred_cnt)
      IF ((mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
      already_sorted_ind=0)
       AND (mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
      ingredient_type_flag=cadditive))
       SET temp_ingred_cnt = (temp_ingred_cnt+ 1)
       CALL copyingredientstotemp(order_idx,action_idx,i,temp_ingred_cnt)
       SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
       already_sorted_ind = 1
      ENDIF
    ENDFOR
    FOR (i = 1 TO ingred_cnt)
      IF ((mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
      already_sorted_ind=0)
       AND (mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
      ingredient_type_flag=cbase))
       SET temp_ingred_cnt = (temp_ingred_cnt+ 1)
       CALL copyingredientstotemp(order_idx,action_idx,i,temp_ingred_cnt)
       SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
       already_sorted_ind = 1
      ENDIF
    ENDFOR
   ELSEIF (sort_flag=cdisplay_diluent_first)
    FOR (i = 1 TO ingred_cnt)
      IF ((mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
      already_sorted_ind=0)
       AND (mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
      ingredient_type_flag=cbase))
       SET temp_ingred_cnt = (temp_ingred_cnt+ 1)
       CALL copyingredientstotemp(order_idx,action_idx,i,temp_ingred_cnt)
       SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
       already_sorted_ind = 1
      ENDIF
    ENDFOR
    FOR (i = 1 TO ingred_cnt)
      IF ((mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
      already_sorted_ind=0)
       AND (mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
      ingredient_type_flag=cadditive))
       SET temp_ingred_cnt = (temp_ingred_cnt+ 1)
       CALL copyingredientstotemp(order_idx,action_idx,i,temp_ingred_cnt)
       SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
       already_sorted_ind = 1
      ENDIF
    ENDFOR
   ENDIF
   FOR (i = 1 TO ingred_cnt)
     IF ((mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
     already_sorted_ind=0))
      SET temp_ingred_cnt = (temp_ingred_cnt+ 1)
      CALL copyingredientstotemp(order_idx,action_idx,i,temp_ingred_cnt)
      SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
      already_sorted_ind = 1
     ENDIF
   ENDFOR
   IF (debug_ind=1
    AND temp_ingred_cnt != ingred_cnt)
    CALL echo(build("******SortIngredients - missing ingredients for order_id: ",mar_detail_reply->
      orders[order_idx].top_level_order_id))
    CALL echo(build("******SortIngredients - temp_ingred_cnt: ",temp_ingred_cnt))
    CALL echo(build("******SortIngredients - ingred_cnt: ",ingred_cnt))
   ENDIF
   SET stat = alterlist(mar_detail_reply->orders[order_idx].order_actions[action_idx].
    order_ingredients,0)
   SET stat = alterlist(mar_detail_reply->orders[order_idx].order_actions[action_idx].
    order_ingredients,temp_ingred_cnt)
   FOR (i = 1 TO temp_ingred_cnt)
     SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
     action_sequence = temp_ingreds->order_ingredients[i].action_sequence
     SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
     comp_sequence = temp_ingreds->order_ingredients[i].comp_sequence
     SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
     order_mnemonic = temp_ingreds->order_ingredients[i].order_mnemonic
     SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
     ordered_as_mnemonic = temp_ingreds->order_ingredients[i].ordered_as_mnemonic
     SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
     hna_order_mnemonic = temp_ingreds->order_ingredients[i].hna_order_mnemonic
     SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].strength
      = temp_ingreds->order_ingredients[i].strength
     SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
     strength_unit = temp_ingreds->order_ingredients[i].strength_unit
     SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].volume =
     temp_ingreds->order_ingredients[i].volume
     SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
     volume_unit = temp_ingreds->order_ingredients[i].volume_unit
     SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
     volume_flag = temp_ingreds->order_ingredients[i].volume_flag
     SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
     total_volume = temp_ingreds->order_ingredients[i].total_volume
     SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].bag_freq
      = temp_ingreds->order_ingredients[i].bag_freq
     SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
     dose_quantity = temp_ingreds->order_ingredients[i].dose_quantity
     SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
     dose_quantity_unit_cd = temp_ingreds->order_ingredients[i].dose_quantity_unit_cd
     SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
     freetext_dose = temp_ingreds->order_ingredients[i].freetext_dose
     SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
     ingredient_type_flag = temp_ingreds->order_ingredients[i].ingredient_type_flag
     SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
     normalized_rate = temp_ingreds->order_ingredients[i].normalized_rate
     SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
     normalized_rate_unit_cd = temp_ingreds->order_ingredients[i].normalized_rate_unit_cd
     SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
     normalized_rate_unit_cd_disp = temp_ingreds->order_ingredients[i].normalized_rate_unit_cd_disp
     SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
     normalized_rate_unit_cd_desc = temp_ingreds->order_ingredients[i].normalized_rate_unit_cd_desc
     SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
     normalized_rate_unit_cd_mean = temp_ingreds->order_ingredients[i].normalized_rate_unit_cd_mean
     SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
     ingredient_rate_conversion_ind = temp_ingreds->order_ingredients[i].
     ingredient_rate_conversion_ind
     SET mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[i].
     already_sorted_ind = temp_ingreds->order_ingredients[i].already_sorted_ind
   ENDFOR
   IF (debug_ind=1)
    CALL echo(build("********SortIngredients Total Subroutine Time = ",datetimediff(cnvtdatetime(
        curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE copyingredientstotemp(order_idx,action_idx,ingred_idx,temp_ingred_idx)
   DECLARE order_cnt = i4 WITH protect, noconstant(0)
   DECLARE action_cnt = i4 WITH protect, noconstant(0)
   DECLARE ingred_cnt = i4 WITH protect, noconstant(0)
   DECLARE temp_ingred_cnt = i4 WITH protect, noconstant(0)
   SET order_cnt = size(mar_detail_reply->orders,5)
   IF (((order_idx < 0) OR (order_idx > order_cnt)) )
    RETURN
   ENDIF
   SET action_cnt = size(mar_detail_reply->orders[order_idx].order_actions,5)
   IF (((action_idx < 0) OR (action_idx > action_cnt)) )
    RETURN
   ENDIF
   SET ingred_cnt = size(mar_detail_reply->orders[order_idx].order_actions[action_idx].
    order_ingredients,5)
   IF (((ingred_idx < 0) OR (ingred_idx > ingred_cnt)) )
    RETURN
   ENDIF
   SET temp_ingred_cnt = size(temp_ingreds->order_ingredients,5)
   IF (temp_ingred_cnt < temp_ingred_idx)
    SET stat = alterlist(temp_ingreds->order_ingredients,temp_ingred_idx)
   ENDIF
   SET temp_ingreds->order_ingredients[temp_ingred_idx].action_sequence = mar_detail_reply->orders[
   order_idx].order_actions[action_idx].order_ingredients[ingred_idx].action_sequence
   SET temp_ingreds->order_ingredients[temp_ingred_idx].comp_sequence = mar_detail_reply->orders[
   order_idx].order_actions[action_idx].order_ingredients[ingred_idx].comp_sequence
   SET temp_ingreds->order_ingredients[temp_ingred_idx].order_mnemonic = mar_detail_reply->orders[
   order_idx].order_actions[action_idx].order_ingredients[ingred_idx].order_mnemonic
   SET temp_ingreds->order_ingredients[temp_ingred_idx].ordered_as_mnemonic = mar_detail_reply->
   orders[order_idx].order_actions[action_idx].order_ingredients[ingred_idx].ordered_as_mnemonic
   SET temp_ingreds->order_ingredients[temp_ingred_idx].hna_order_mnemonic = mar_detail_reply->
   orders[order_idx].order_actions[action_idx].order_ingredients[ingred_idx].hna_order_mnemonic
   SET temp_ingreds->order_ingredients[temp_ingred_idx].strength = mar_detail_reply->orders[order_idx
   ].order_actions[action_idx].order_ingredients[ingred_idx].strength
   SET temp_ingreds->order_ingredients[temp_ingred_idx].strength_unit = mar_detail_reply->orders[
   order_idx].order_actions[action_idx].order_ingredients[ingred_idx].strength_unit
   SET temp_ingreds->order_ingredients[temp_ingred_idx].volume = mar_detail_reply->orders[order_idx].
   order_actions[action_idx].order_ingredients[ingred_idx].volume
   SET temp_ingreds->order_ingredients[temp_ingred_idx].volume_unit = mar_detail_reply->orders[
   order_idx].order_actions[action_idx].order_ingredients[ingred_idx].volume_unit
   SET temp_ingreds->order_ingredients[temp_ingred_idx].volume_flag = mar_detail_reply->orders[
   order_idx].order_actions[action_idx].order_ingredients[ingred_idx].volume_flag
   SET temp_ingreds->order_ingredients[temp_ingred_idx].total_volume = mar_detail_reply->orders[
   order_idx].order_actions[action_idx].order_ingredients[ingred_idx].total_volume
   SET temp_ingreds->order_ingredients[temp_ingred_idx].bag_freq = mar_detail_reply->orders[order_idx
   ].order_actions[action_idx].order_ingredients[ingred_idx].bag_freq
   SET temp_ingreds->order_ingredients[temp_ingred_idx].dose_quantity = mar_detail_reply->orders[
   order_idx].order_actions[action_idx].order_ingredients[ingred_idx].dose_quantity
   SET temp_ingreds->order_ingredients[temp_ingred_idx].dose_quantity_unit_cd = mar_detail_reply->
   orders[order_idx].order_actions[action_idx].order_ingredients[ingred_idx].dose_quantity_unit_cd
   SET temp_ingreds->order_ingredients[temp_ingred_idx].freetext_dose = mar_detail_reply->orders[
   order_idx].order_actions[action_idx].order_ingredients[ingred_idx].freetext_dose
   SET temp_ingreds->order_ingredients[temp_ingred_idx].ingredient_type_flag = mar_detail_reply->
   orders[order_idx].order_actions[action_idx].order_ingredients[ingred_idx].ingredient_type_flag
   SET temp_ingreds->order_ingredients[temp_ingred_idx].normalized_rate = mar_detail_reply->orders[
   order_idx].order_actions[action_idx].order_ingredients[ingred_idx].normalized_rate
   SET temp_ingreds->order_ingredients[temp_ingred_idx].normalized_rate_unit_cd = mar_detail_reply->
   orders[order_idx].order_actions[action_idx].order_ingredients[ingred_idx].normalized_rate_unit_cd
   SET temp_ingreds->order_ingredients[temp_ingred_idx].normalized_rate_unit_cd_disp =
   mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[ingred_idx].
   normalized_rate_unit_cd_disp
   SET temp_ingreds->order_ingredients[temp_ingred_idx].normalized_rate_unit_cd_desc =
   mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[ingred_idx].
   normalized_rate_unit_cd_desc
   SET temp_ingreds->order_ingredients[temp_ingred_idx].normalized_rate_unit_cd_mean =
   mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[ingred_idx].
   normalized_rate_unit_cd_mean
   SET temp_ingreds->order_ingredients[temp_ingred_idx].ingredient_rate_conversion_ind =
   mar_detail_reply->orders[order_idx].order_actions[action_idx].order_ingredients[ingred_idx].
   ingredient_rate_conversion_ind
   SET temp_ingreds->order_ingredients[temp_ingred_idx].already_sorted_ind = mar_detail_reply->
   orders[order_idx].order_actions[action_idx].order_ingredients[ingred_idx].already_sorted_ind
 END ;Subroutine
 SUBROUTINE loadactiondetails(null)
   CALL echo("LoadActionDetails")
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   DECLARE act_detail_cnt = i4 WITH noconstant(0)
   IF (debug_ind=1)
    SET querytime = cnvtdatetime(curdate,curtime3)
   ENDIF
   SELECT INTO "nl:"
    FROM order_detail od,
     (dummyt dorders  WITH seq = value(size(mar_detail_reply->orders,5))),
     (dummyt dactions  WITH seq = value(max_action_cnt))
    PLAN (dorders)
     JOIN (dactions
     WHERE dactions.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].order_actions,5)))
     JOIN (od
     WHERE (od.order_id=mar_detail_reply->orders[dorders.seq].top_level_order_id)
      AND (od.action_sequence=mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].
     action_sequence))
    ORDER BY od.order_id, od.action_sequence, od.oe_field_id
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadActionDetails Query Time = ",datetimediff(cnvtdatetime(curdate,
         curtime3),querytime,5)))
     ENDIF
    HEAD dorders.seq
     act_detail_cnt = 0
    HEAD dactions.seq
     act_detail_cnt = 0
    HEAD od.oe_field_id
     act_detail_cnt = (act_detail_cnt+ 1), debug_param_a_id = od.order_id, debug_param_b_id = od
     .action_sequence,
     debug_param_c_id = od.oe_field_id, debug_param_d_id = act_detail_cnt
     IF (act_detail_cnt > size(mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].
      order_details,5))
      stat = alterlist(mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].
       order_details,(act_detail_cnt+ 9))
     ENDIF
     mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].order_details[act_detail_cnt].
     action_sequence = od.action_sequence, mar_detail_reply->orders[dorders.seq].order_actions[
     dactions.seq].order_details[act_detail_cnt].oe_field_id = od.oe_field_id, mar_detail_reply->
     orders[dorders.seq].order_actions[dactions.seq].order_details[act_detail_cnt].oe_field_meaning
      = od.oe_field_meaning,
     mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].order_details[act_detail_cnt].
     oe_field_value = od.oe_field_value, mar_detail_reply->orders[dorders.seq].order_actions[dactions
     .seq].order_details[act_detail_cnt].oe_field_meaning_id = od.oe_field_meaning_id,
     mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].order_details[act_detail_cnt].
     oe_field_display_value = od.oe_field_display_value
    FOOT  dactions.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].order_details,
      act_detail_cnt)
    FOOT  dorders.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].order_details,
      act_detail_cnt)
    FOOT REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadActionDetails Query Total Time = ",datetimediff(cnvtdatetime(
         curdate,curtime3),querytime,5)))
     ENDIF
    WITH nocounter
   ;end select
   CALL displayerrorinfo("LoadActionDetails","od.order_id","od.action_sequence","od.oe_field_id",
    "act_detail_cnt")
   IF (debug_ind=1)
    CALL echo(build("********LoadActionDetails Total Subroutine Time = ",datetimediff(cnvtdatetime(
        curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadactionnotes(null)
   CALL echo("LoadActionNotes")
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   DECLARE act_note_cnt = i4 WITH noconstant(0)
   IF (debug_ind=1)
    SET querytime = cnvtdatetime(curdate,curtime3)
   ENDIF
   SELECT INTO "nl:"
    FROM order_comment oc,
     long_text lt,
     (dummyt dorders  WITH seq = value(size(mar_detail_reply->orders,5))),
     (dummyt dactions  WITH seq = value(max_action_cnt))
    PLAN (dorders)
     JOIN (dactions
     WHERE dactions.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].order_actions,5)))
     JOIN (oc
     WHERE (oc.order_id=mar_detail_reply->orders[dorders.seq].top_level_order_id)
      AND (oc.action_sequence=mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].
     action_sequence))
     JOIN (lt
     WHERE lt.long_text_id=oc.long_text_id)
    ORDER BY oc.order_id, oc.action_sequence, oc.comment_type_cd
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadActionNotes Query Time = ",datetimediff(cnvtdatetime(curdate,
         curtime3),querytime,5)))
     ENDIF
    HEAD dorders.seq
     act_note_cnt = 0
    HEAD dactions.seq
     act_note_cnt = 0
    DETAIL
     act_note_cnt = (act_note_cnt+ 1), debug_param_a_id = oc.order_id, debug_param_b_id = oc
     .action_sequence,
     debug_param_c_id = lt.long_text_id, debug_param_d_id = act_note_cnt
     IF (act_note_cnt > size(mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].notes,
      5))
      stat = alterlist(mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].notes,(
       act_note_cnt+ 9))
     ENDIF
     mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].notes[act_note_cnt].
     comment_type_cd = oc.comment_type_cd, mar_detail_reply->orders[dorders.seq].order_actions[
     dactions.seq].notes[act_note_cnt].comment_text = lt.long_text
    FOOT  dactions.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].notes,
      act_note_cnt)
    FOOT  dorders.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].notes,
      act_note_cnt)
    FOOT REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadActionNotes Query Total Time = ",datetimediff(cnvtdatetime(curdate,
         curtime3),querytime,5)))
     ENDIF
    WITH nocounter
   ;end select
   CALL displayerrorinfo("LoadActionNotes","oc.order_id","oc.action_sequence","lt.long_text_id",
    "act_note_cnt")
   IF (debug_ind=1)
    CALL echo(build("********LoadActionNotes Total Subroutine Time = ",datetimediff(cnvtdatetime(
        curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadactionorderreview(null)
   CALL echo("LoadActionOrderReview")
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   DECLARE act_review_cnt = i4 WITH noconstant(0)
   IF (debug_ind=1)
    SET querytime = cnvtdatetime(curdate,curtime3)
   ENDIF
   SELECT INTO "nl:"
    FROM order_review ordr,
     prsnl p,
     (dummyt dorders  WITH seq = value(size(mar_detail_reply->orders,5))),
     (dummyt dactions  WITH seq = value(max_action_cnt))
    PLAN (dorders)
     JOIN (dactions
     WHERE dactions.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].order_actions,5)))
     JOIN (ordr
     WHERE (ordr.order_id=mar_detail_reply->orders[dorders.seq].top_level_order_id)
      AND (ordr.action_sequence=mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].
     action_sequence)
      AND ordr.review_personnel_id > 0)
     JOIN (p
     WHERE p.person_id=ordr.review_personnel_id)
    ORDER BY ordr.order_id, ordr.action_sequence, ordr.review_sequence
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadActionOrderReview Query Time = ",datetimediff(cnvtdatetime(curdate,
         curtime3),querytime,5)))
     ENDIF
    HEAD dorders.seq
     act_review_cnt = 0
    HEAD dactions.seq
     act_review_cnt = 0
    DETAIL
     act_review_cnt = (act_review_cnt+ 1), debug_param_a_id = ordr.order_id, debug_param_b_id = ordr
     .action_sequence,
     debug_param_c_id = ordr.review_sequence, debug_param_d_id = act_review_cnt
     IF (act_review_cnt > size(mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].
      order_review,5))
      stat = alterlist(mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].order_review,
       (act_review_cnt+ 9))
     ENDIF
     mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].order_review[act_review_cnt].
     review_dt_tm = ordr.review_dt_tm, mar_detail_reply->orders[dorders.seq].order_actions[dactions
     .seq].order_review[act_review_cnt].review_tz = ordr.review_tz, mar_detail_reply->orders[dorders
     .seq].order_actions[dactions.seq].order_review[act_review_cnt].review_personnel_id = ordr
     .review_personnel_id,
     mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].order_review[act_review_cnt].
     reviewed_status_flag = ordr.reviewed_status_flag, mar_detail_reply->orders[dorders.seq].
     order_actions[dactions.seq].order_review[act_review_cnt].action_sequence = ordr.action_sequence,
     mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].order_review[act_review_cnt].
     review_sequence = ordr.review_sequence,
     mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].order_review[act_review_cnt].
     review_type_flag = ordr.review_type_flag, mar_detail_reply->orders[dorders.seq].order_actions[
     dactions.seq].order_review[act_review_cnt].review_personnel_name = p.name_full_formatted,
     mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].order_review[act_review_cnt].
     reviewed_person_name = p.name_full_formatted
    FOOT  dactions.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].order_review,
      act_review_cnt)
    FOOT  dorders.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].order_actions[dactions.seq].order_review,
      act_review_cnt)
    FOOT REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadActionOrderReview Query Total Time = ",datetimediff(cnvtdatetime(
         curdate,curtime3),querytime,5)))
     ENDIF
    WITH nocounter
   ;end select
   CALL displayerrorinfo("LoadActionOrderReview","ordr.order_id","ordr.action_sequence",
    "ordr.review_sequence","act_review_cnt")
   IF (debug_ind=1)
    CALL echo(build("********LoadActionOrderReview Total Subroutine Time = ",datetimediff(
       cnvtdatetime(curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadadministrations(null)
   CALL echo("LoadAdministrations")
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   DECLARE admin_cnt = i4 WITH noconstant(0)
   DECLARE admin_hist_cnt = i4 WITH noconstant(0)
   DECLARE event_cd_cnt = i4 WITH noconstant(0)
   DECLARE iterator = i4 WITH noconstant(0)
   DECLARE index = i4 WITH noconstant(0)
   DECLARE action_count = i4 WITH noconstant(0)
   DECLARE num = i4 WITH noconstant(0)
   DECLARE nstart = i4 WITH protect, noconstant(1)
   DECLARE nsize = i4 WITH protect, constant(60)
   DECLARE iordercnt = i4 WITH protect, noconstant(size(mar_detail_reply->orders,5))
   DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(iordercnt)/ nsize)) * nsize))
   IF (debug_ind=1)
    SET querytime = cnvtdatetime(curdate,curtime3)
   ENDIF
   SET stat = alterlist(mar_detail_reply->orders,ntotal)
   FOR (i = (iordercnt+ 1) TO ntotal)
    SET mar_detail_reply->orders[i].top_level_order_id = mar_detail_reply->orders[iordercnt].
    top_level_order_id
    SET mar_detail_reply->orders[i].top_level_catalog_cd = mar_detail_reply->orders[iordercnt].
    top_level_catalog_cd
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     order_ingredient oi,
     code_value_event_r cver
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (oi
     WHERE expand(iterator,nstart,(nstart+ (nsize - 1)),oi.order_id,mar_detail_reply->orders[iterator
      ].top_level_order_id))
     JOIN (cver
     WHERE cver.parent_cd=oi.catalog_cd)
    ORDER BY oi.order_id, cver.event_cd
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadAdministrations Query #1 Time = ",datetimediff(cnvtdatetime(
         curdate,curtime3),querytime,5)))
     ENDIF
    HEAD oi.order_id
     event_cd_cnt = 0, index = locateval(iterator,1,iordercnt,oi.order_id,mar_detail_reply->orders[
      iterator].top_level_order_id)
    HEAD cver.event_cd
     event_cd_cnt = (event_cd_cnt+ 1), debug_param_a_id = oi.order_id, debug_param_b_id = oi
     .catalog_cd,
     debug_param_c_id = cver.parent_cd
     IF (event_cd_cnt > size(mar_detail_reply->orders[index].related_event_cds,5))
      stat = alterlist(mar_detail_reply->orders[index].related_event_cds,(event_cd_cnt+ 4))
     ENDIF
     mar_detail_reply->orders[index].related_event_cds[event_cd_cnt].event_cd = cver.event_cd
    FOOT  oi.order_id
     stat = alterlist(mar_detail_reply->orders[index].related_event_cds,event_cd_cnt),
     mar_detail_reply->orders[index].ingred_event_cd_cnt = event_cd_cnt, mar_detail_reply->orders[
     index].event_cd_cnt = event_cd_cnt
     IF (event_cd_cnt > max_event_cd_cnt)
      max_event_cd_cnt = event_cd_cnt, max_ingred_cd_cnt = event_cd_cnt
     ENDIF
    FOOT REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadAdministrations Query #1 Total Time = ",datetimediff(cnvtdatetime(
         curdate,curtime3),querytime,5)))
     ENDIF
    WITH nocounter
   ;end select
   CALL displayerrorinfo("LoadAdministrations - Query 1","oi.order_id","oi.catalog_cd",
    "cver.parent_cd","")
   IF (debug_ind=1)
    SET querytime = cnvtdatetime(curdate,curtime3)
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     orders o,
     order_task_xref otxr,
     order_task_response otr,
     order_task ot
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (o
     WHERE expand(iterator,nstart,(nstart+ (nsize - 1)),o.order_id,mar_detail_reply->orders[iterator]
      .top_level_order_id))
     JOIN (otxr
     WHERE otxr.catalog_cd=o.catalog_cd)
     JOIN (otr
     WHERE otr.reference_task_id=otxr.reference_task_id)
     JOIN (ot
     WHERE ot.reference_task_id=otr.response_task_id)
    ORDER BY o.order_id, ot.event_cd
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadAdministrations Query #2 Time = ",datetimediff(cnvtdatetime(
         curdate,curtime3),querytime,5)))
     ENDIF
    HEAD o.order_id
     index = locateval(iterator,1,iordercnt,o.order_id,mar_detail_reply->orders[iterator].
      top_level_order_id), event_cd_cnt = mar_detail_reply->orders[index].ingred_event_cd_cnt
    HEAD ot.event_cd
     debug_param_a_id = otxr.catalog_cd, debug_param_b_id = otr.reference_task_id, debug_param_c_id
      = ot.reference_task_id,
     debug_param_d_id = ot.event_cd
     IF (ot.event_cd > 0)
      event_cd_cnt = (event_cd_cnt+ 1)
      IF (event_cd_cnt > size(mar_detail_reply->orders[index].related_event_cds,5))
       stat = alterlist(mar_detail_reply->orders[index].related_event_cds,(event_cd_cnt+ 1))
      ENDIF
      mar_detail_reply->orders[index].related_event_cds[event_cd_cnt].event_cd = ot.event_cd
     ENDIF
    FOOT  o.order_id
     mar_detail_reply->orders[index].event_cd_cnt = event_cd_cnt
     IF (event_cd_cnt > max_event_cd_cnt)
      max_event_cd_cnt = event_cd_cnt
     ENDIF
    FOOT REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadAdministrations Query #2 Total Time = ",datetimediff(cnvtdatetime(
         curdate,curtime3),querytime,5)))
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(mar_detail_reply->orders,iordercnt)
   CALL displayerrorinfo("LoadAdministrations - Query 2","otxr.catalog_cd","otr.reference_task_id",
    "ot.reference_task_id","ot.event_cd")
   IF (debug_ind=1)
    SET querytime = cnvtdatetime(curdate,curtime3)
   ENDIF
   SELECT INTO "nl:"
    FROM clinical_event time_qual_event,
     clinical_event ce,
     orders o,
     prsnl p,
     (dummyt dorders  WITH seq = value(size(mar_detail_reply->orders,5))),
     (dummyt drelatedevents  WITH seq = value(max_event_cd_cnt)),
     (dummyt dingred  WITH seq = value(max_ingred_cd_cnt))
    PLAN (dorders)
     JOIN (drelatedevents
     WHERE drelatedevents.seq <= cnvtint(mar_detail_reply->orders[dorders.seq].event_cd_cnt))
     JOIN (dingred
     WHERE dingred.seq <= cnvtint(mar_detail_reply->orders[dorders.seq].ingred_event_cd_cnt))
     JOIN (o
     WHERE (((o.order_id=mar_detail_reply->orders[dorders.seq].top_level_order_id)) OR ((o
     .template_order_id=mar_detail_reply->orders[dorders.seq].top_level_order_id))) )
     JOIN (time_qual_event
     WHERE time_qual_event.order_id=o.order_id
      AND (time_qual_event.person_id=mar_detail_request->person_id)
      AND time_qual_event.event_end_dt_tm >= cnvtdatetime(mar_detail_request->start_dt_tm)
      AND time_qual_event.event_end_dt_tm <= cnvtdatetime(mar_detail_request->end_dt_tm)
      AND time_qual_event.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
      AND ((time_qual_event.event_class_cd IN (ceventmed, ceventimmun)) OR (((time_qual_event
     .result_status_cd=cnotdone
      AND (mar_detail_reply->orders[dorders.seq].related_event_cds[drelatedevents.seq].event_cd=
     time_qual_event.event_cd)) OR (time_qual_event.result_status_cd=cinerror
      AND (mar_detail_reply->orders[dorders.seq].related_event_cds[dingred.seq].event_cd=
     time_qual_event.event_cd))) ))
      AND ((o.med_order_type_cd=civ
      AND time_qual_event.event_cd != cdcpgeneric) OR (o.med_order_type_cd IN (cmed, cint)))
      AND  NOT (time_qual_event.event_class_cd IN (cplaceholder, cio)))
     JOIN (ce
     WHERE ce.event_id=time_qual_event.parent_event_id
      AND ce.parent_event_id=ce.event_id
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     JOIN (p
     WHERE p.person_id=ce.performed_prsnl_id)
    ORDER BY ce.event_end_dt_tm, ce.clinical_event_id
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadAdministrations Query #3 Time = ",datetimediff(cnvtdatetime(
         curdate,curtime3),querytime,5)))
     ENDIF
    HEAD dorders.seq
     admin_cnt = size(mar_detail_reply->orders[dorders.seq].administrations,5)
    HEAD ce.event_end_dt_tm
     num = 0
    HEAD ce.clinical_event_id
     debug_param_a_id = ce.order_id, debug_param_b_id = ce.clinical_event_id, admin_cnt = (admin_cnt
     + 1),
     debug_param_c_id = admin_cnt
     IF (admin_cnt > max_admin_cnt)
      max_admin_cnt = admin_cnt
     ENDIF
     debug_param_d_id = max_admin_cnt
     IF (admin_cnt > size(mar_detail_reply->orders[dorders.seq].administrations,5))
      stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations,(admin_cnt+ 9))
     ENDIF
     mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].event_id = ce.event_id,
     mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].event_end_dt_tm = ce
     .event_end_dt_tm, mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].
     event_start_dt_tm = ce.event_start_dt_tm,
     mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].event_start_tz = ce
     .event_start_tz, mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].event_end_tz
      = ce.event_end_tz, mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].
     performed_dt_tm = ce.performed_dt_tm,
     mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].performed_tz = ce.performed_tz,
     mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].parent_event_id = ce
     .parent_event_id, mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].
     event_class_cd = ce.event_class_cd,
     mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].result_status_cd = ce
     .result_status_cd, mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].event_tag =
     ce.event_tag, mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].order_id = ce
     .order_id,
     mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].performed_prsnl_id = ce
     .performed_prsnl_id, mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].
     valid_until_dt_tm = ce.valid_until_dt_tm, mar_detail_reply->orders[dorders.seq].administrations[
     admin_cnt].valid_from_dt_tm = ce.valid_from_dt_tm,
     mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].order_idx = dorders.seq,
     mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].result_idx = admin_cnt,
     mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].event_cd = ce.event_cd,
     mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].device_free_txt = ce
     .device_free_txt, mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].
     performed_prsnl_name = p.name_full_formatted
     IF (o.med_order_type_cd IN (cmed, cint)
      AND o.prn_ind=0
      AND o.freq_type_flag != 5)
      mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].scheduled_admin_dt_tm = o
      .current_start_dt_tm, mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].
      scheduled_admin_tz = o.current_start_tz
     ENDIF
     IF (o.med_order_type_cd IN (cmed, cint)
      AND ((o.prn_ind=1) OR (o.freq_type_flag=5))
      AND ce.order_action_sequence > 0)
      mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].core_action_sequence = ce
      .order_action_sequence
     ELSEIF (o.med_order_type_cd IN (cmed, cint))
      IF (o.template_order_id=0)
       FOR (action_count = 1 TO size(mar_detail_reply->orders[dorders.seq].order_actions,5))
         IF (ce.valid_from_dt_tm < cnvtdatetime(mar_detail_reply->orders[dorders.seq].order_actions[
          action_count].action_dt_tm))
          IF (action_count > 1)
           mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].core_action_sequence =
           mar_detail_reply->orders[dorders.seq].order_actions[(action_count - 1)].action_sequence,
           action_count = (size(mar_detail_reply->orders[dorders.seq].order_actions,5)+ 1)
          ENDIF
         ENDIF
       ENDFOR
       IF ((mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].core_action_sequence=0))
        action_count = size(mar_detail_reply->orders[dorders.seq].order_actions,5), mar_detail_reply
        ->orders[dorders.seq].administrations[admin_cnt].core_action_sequence = mar_detail_reply->
        orders[dorders.seq].order_actions[action_count].action_sequence
       ENDIF
      ELSE
       mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].core_action_sequence = o
       .template_core_action_sequence
      ENDIF
     ELSEIF (o.med_order_type_cd=civ)
      mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].core_action_sequence =
      parseactionseqiv(ce.order_action_sequence,ce.collating_seq)
     ENDIF
     IF ((mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].core_action_sequence > 1))
      action_count = size(mar_detail_reply->orders[dorders.seq].order_actions,5), index = locateval(
       iterator,1,action_count,mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].
       core_action_sequence,mar_detail_reply->orders[dorders.seq].order_actions[iterator].
       action_sequence)
      IF (index > 1)
       IF ( NOT ((mar_detail_reply->orders[dorders.seq].order_actions[index].action_type_cd IN (
       corder, cmodify, creschedule))))
        WHILE (index > 1)
         index = (index - 1),
         IF ((mar_detail_reply->orders[dorders.seq].order_actions[index].action_type_cd IN (corder,
         cmodify, creschedule)))
          mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].core_action_sequence =
          mar_detail_reply->orders[dorders.seq].order_actions[index].action_sequence, index = 0
         ENDIF
        ENDWHILE
       ENDIF
      ENDIF
     ENDIF
     IF ((mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].core_action_sequence=0))
      mar_detail_reply->orders[dorders.seq].administrations[admin_cnt].core_action_sequence = 1
     ENDIF
    FOOT  ce.clinical_event_id
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations,admin_cnt)
    FOOT  ce.event_end_dt_tm
     num = 0
    FOOT  dorders.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations,admin_cnt)
    FOOT REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadAdministrations Query #3 Total Time = ",datetimediff(cnvtdatetime(
         curdate,curtime3),querytime,5)))
     ENDIF
    WITH orahintcbo("LEADING(o time_qual_event ce p) USE_NL(time_qual_event ce p)")
   ;end select
   CALL displayerrorinfo("LoadAdministrations - Query 3","ce.order_id","ce.clinical_event_id",
    "admin_cnt","max_admin_cnt")
   IF (max_admin_cnt > 0)
    IF (debug_ind=1)
     SET querytime = cnvtdatetime(curdate,curtime3)
    ENDIF
    SELECT INTO "nl:"
     FROM clinical_event ce,
      prsnl p,
      (dummyt dorders  WITH seq = value(size(mar_detail_reply->orders,5))),
      (dummyt dadmins  WITH seq = value(max_admin_cnt))
     PLAN (dorders)
      JOIN (dadmins
      WHERE dadmins.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].administrations,5)))
      JOIN (ce
      WHERE (ce.event_id=mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].event_id)
       AND ce.valid_until_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00.00"))
      JOIN (p
      WHERE p.person_id=ce.performed_prsnl_id)
     ORDER BY ce.order_id, ce.parent_event_id, ce.valid_until_dt_tm DESC
     HEAD REPORT
      IF (debug_ind=1)
       CALL echo(build("********LoadAdministrations Query #4 Time = ",datetimediff(cnvtdatetime(
          curdate,curtime3),querytime,5)))
      ENDIF
     HEAD dorders.seq
      admin_hist_cnt = 0
     HEAD dadmins.seq
      admin_hist_cnt = size(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
       admin_histories,5)
     HEAD ce.clinical_event_id
      debug_param_a_id = ce.order_id, debug_param_b_id = ce.clinical_event_id
      IF (ce.valid_until_dt_tm <= cnvtdatetime(curdate,curtime3))
       admin_hist_cnt = (admin_hist_cnt+ 1), debug_param_c_id = admin_hist_cnt, debug_param_d_id =
       max_admin_cnt
       IF (admin_hist_cnt > max_admin_hist_cnt)
        max_admin_hist_cnt = admin_hist_cnt
       ENDIF
       IF (admin_hist_cnt > size(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
        admin_histories,5))
        stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
         admin_histories,(admin_hist_cnt+ 9))
       ENDIF
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_histories[
       admin_hist_cnt].event_id = ce.event_id, mar_detail_reply->orders[dorders.seq].administrations[
       dadmins.seq].admin_histories[admin_hist_cnt].event_end_dt_tm = ce.event_end_dt_tm,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_histories[
       admin_hist_cnt].event_start_dt_tm = ce.event_start_dt_tm,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_histories[
       admin_hist_cnt].event_start_tz = ce.event_start_tz, mar_detail_reply->orders[dorders.seq].
       administrations[dadmins.seq].admin_histories[admin_hist_cnt].event_end_tz = ce.event_end_tz,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_histories[
       admin_hist_cnt].performed_dt_tm = ce.performed_dt_tm,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_histories[
       admin_hist_cnt].performed_tz = ce.performed_tz, mar_detail_reply->orders[dorders.seq].
       administrations[dadmins.seq].admin_histories[admin_hist_cnt].event_class_cd = ce
       .event_class_cd, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
       admin_histories[admin_hist_cnt].result_status_cd = ce.result_status_cd,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_histories[
       admin_hist_cnt].event_tag = ce.event_tag, mar_detail_reply->orders[dorders.seq].
       administrations[dadmins.seq].admin_histories[admin_hist_cnt].order_id = ce.order_id,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_histories[
       admin_hist_cnt].performed_prsnl_id = ce.performed_prsnl_id,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_histories[
       admin_hist_cnt].valid_until_dt_tm = ce.valid_until_dt_tm, mar_detail_reply->orders[dorders.seq
       ].administrations[dadmins.seq].admin_histories[admin_hist_cnt].valid_from_dt_tm = ce
       .valid_from_dt_tm, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
       admin_histories[admin_hist_cnt].order_idx = dorders.seq,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_histories[
       admin_hist_cnt].result_idx = dadmins.seq, mar_detail_reply->orders[dorders.seq].
       administrations[dadmins.seq].admin_histories[admin_hist_cnt].event_cd = ce.event_cd,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_histories[
       admin_hist_cnt].device_free_txt = ce.device_free_txt,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_histories[
       admin_hist_cnt].performed_prsnl_name = p.name_full_formatted, mar_detail_reply->orders[dorders
       .seq].administrations[dadmins.seq].admin_histories[admin_hist_cnt].scheduled_admin_dt_tm =
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].scheduled_admin_dt_tm,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_histories[
       admin_hist_cnt].scheduled_admin_tz = mar_detail_reply->orders[dorders.seq].administrations[
       dadmins.seq].scheduled_admin_tz,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_histories[
       admin_hist_cnt].core_action_sequence = mar_detail_reply->orders[dorders.seq].administrations[
       dadmins.seq].core_action_sequence
      ELSE
       CALL saveerrordata("admin_histories",ce.order_id,ce.event_id)
      ENDIF
     FOOT  ce.clinical_event_id
      stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
       admin_histories,admin_hist_cnt)
     FOOT  dadmins.seq
      stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
       admin_histories,admin_hist_cnt)
     FOOT  dorders.seq
      stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
       admin_histories,admin_hist_cnt)
     FOOT REPORT
      IF (debug_ind=1)
       CALL echo(build("********LoadAdministrations Query #4 Total Time = ",datetimediff(cnvtdatetime
         (curdate,curtime3),querytime,5)))
      ENDIF
     WITH nocounter
    ;end select
    CALL displayerrorinfo("LoadAdministrations - Query 4","ce.order_id","ce.clinical_event_id",
     "admin_hist_cnt","max_admin_cnt")
    IF (debug_ind=1)
     SET querytime = cnvtdatetime(curdate,curtime3)
    ENDIF
    SELECT INTO "nl:"
     FROM ce_med_result cem,
      (dummyt dorders  WITH seq = value(size(mar_detail_reply->orders,5))),
      (dummyt dadmins  WITH seq = value(max_admin_cnt))
     PLAN (dorders)
      JOIN (dadmins
      WHERE dadmins.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].administrations,5)))
      JOIN (cem
      WHERE (cem.event_id=mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].event_id
      )
       AND cem.valid_until_dt_tm=cnvtdatetime(mar_detail_reply->orders[dorders.seq].administrations[
       dadmins.seq].valid_until_dt_tm))
     ORDER BY cem.event_id
     HEAD REPORT
      IF (debug_ind=1)
       CALL echo(build("********LoadAdministrations Query #5 Time = ",datetimediff(cnvtdatetime(
          curdate,curtime3),querytime,5)))
      ENDIF
     DETAIL
      debug_param_a_id = mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].order_id,
      debug_param_b_id = cem.event_id, debug_param_c_id = dadmins.seq,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].initial_dose = cem
      .initial_dosage, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_dose
       = cem.admin_dosage, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      dose_unit_cd = cem.dosage_unit_cd,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].initial_volume = cem
      .initial_volume, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      admin_volume = cem.infused_volume, mar_detail_reply->orders[dorders.seq].administrations[
      dadmins.seq].volume_unit_cd = cem.infused_volume_unit_cd,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_route_cd = cem
      .admin_route_cd, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      admin_site_cd = cem.admin_site_cd, mar_detail_reply->orders[dorders.seq].administrations[
      dadmins.seq].infusion_rate = cem.infusion_rate,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].infusion_rate_unit_cd = cem
      .infusion_unit_cd, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      substance_lot_number = cem.substance_lot_number, mar_detail_reply->orders[dorders.seq].
      administrations[dadmins.seq].substance_exp_dt_tm = cem.substance_exp_dt_tm,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].substance_manufacturer_cd =
      cem.substance_manufacturer_cd, mar_detail_reply->orders[dorders.seq].administrations[dadmins
      .seq].iv_event_cd = cem.iv_event_cd, mar_detail_reply->orders[dorders.seq].administrations[
      dadmins.seq].order_idx = dorders.seq,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].result_idx = dadmins.seq
     FOOT REPORT
      IF (debug_ind=1)
       CALL echo(build("********LoadAdministrations Query #5 Total Time = ",datetimediff(cnvtdatetime
         (curdate,curtime3),querytime,5)))
      ENDIF
     WITH nocounter
    ;end select
    CALL displayerrorinfo("LoadAdministrations - Query 5","ce.order_id","cem.event_id","dAdmins.seq",
     "")
    IF (debug_ind=1)
     CALL echo(build("********LoadAdministrations Total Subroutine Time = ",datetimediff(cnvtdatetime
        (curdate,curtime3),subroutinetime,5)))
    ENDIF
    IF (debug_ind=1)
     SET querytime = cnvtdatetime(curdate,curtime3)
    ENDIF
    SELECT INTO "nl:"
     FROM ce_med_result cem,
      (dummyt dorders  WITH seq = value(size(mar_detail_reply->orders,5))),
      (dummyt dadmins  WITH seq = value(max_admin_cnt)),
      (dummyt dadminhists  WITH seq = value(max_admin_hist_cnt))
     PLAN (dorders)
      JOIN (dadmins
      WHERE dadmins.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].administrations,5)))
      JOIN (dadminhists
      WHERE dadminhists.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].administrations[
        dadmins.seq].admin_histories,5)))
      JOIN (cem
      WHERE (cem.event_id=mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      admin_histories[dadminhists.seq].event_id)
       AND cem.valid_until_dt_tm=cnvtdatetime(mar_detail_reply->orders[dorders.seq].administrations[
       dadmins.seq].admin_histories[dadminhists.seq].valid_until_dt_tm))
     ORDER BY cem.event_id
     HEAD REPORT
      IF (debug_ind=1)
       CALL echo(build("********LoadAdministrations Query #5 Time = ",datetimediff(cnvtdatetime(
          curdate,curtime3),querytime,5)))
      ENDIF
     DETAIL
      debug_param_a_id = mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].order_id,
      debug_param_b_id = cem.event_id, debug_param_c_id = dadmins.seq,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_histories[dadminhists
      .seq].initial_dose = cem.initial_dosage, mar_detail_reply->orders[dorders.seq].administrations[
      dadmins.seq].admin_histories[dadminhists.seq].admin_dose = cem.admin_dosage, mar_detail_reply->
      orders[dorders.seq].administrations[dadmins.seq].admin_histories[dadminhists.seq].dose_unit_cd
       = cem.dosage_unit_cd,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_histories[dadminhists
      .seq].initial_volume = cem.initial_volume, mar_detail_reply->orders[dorders.seq].
      administrations[dadmins.seq].admin_histories[dadminhists.seq].admin_volume = cem.infused_volume,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_histories[dadminhists
      .seq].volume_unit_cd = cem.infused_volume_unit_cd,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_histories[dadminhists
      .seq].admin_route_cd = cem.admin_route_cd, mar_detail_reply->orders[dorders.seq].
      administrations[dadmins.seq].admin_histories[dadminhists.seq].admin_site_cd = cem.admin_site_cd,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_histories[dadminhists
      .seq].infusion_rate = cem.infusion_rate,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_histories[dadminhists
      .seq].infusion_rate_unit_cd = cem.infusion_unit_cd, mar_detail_reply->orders[dorders.seq].
      administrations[dadmins.seq].admin_histories[dadminhists.seq].substance_lot_number = cem
      .substance_lot_number, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      admin_histories[dadminhists.seq].substance_exp_dt_tm = cem.substance_exp_dt_tm,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_histories[dadminhists
      .seq].substance_manufacturer_cd = cem.substance_manufacturer_cd, mar_detail_reply->orders[
      dorders.seq].administrations[dadmins.seq].admin_histories[dadminhists.seq].iv_event_cd = cem
      .iv_event_cd, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      admin_histories[dadminhists.seq].order_idx = dorders.seq,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_histories[dadminhists
      .seq].result_idx = dadmins.seq
     FOOT REPORT
      IF (debug_ind=1)
       CALL echo(build("********LoadAdministrations Query #5 Total Time = ",datetimediff(cnvtdatetime
         (curdate,curtime3),querytime,5)))
      ENDIF
     WITH nocounter
    ;end select
    CALL displayerrorinfo("LoadAdministrations - Query 5","ce.order_id","cem.event_id","dAdmins.seq",
     "")
   ENDIF
   IF (debug_ind=1)
    CALL echo(build("********LoadAdministrations History Total Subroutine Time = ",datetimediff(
       cnvtdatetime(curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadadminnotes(null)
   CALL echo("LoadAdminNotes")
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   DECLARE admin_note_cnt = i4 WITH noconstant(0)
   IF (debug_ind=1)
    SET querytime = cnvtdatetime(curdate,curtime3)
   ENDIF
   SELECT INTO "nl:"
    FROM ce_event_note cen,
     long_blob lb,
     prsnl p,
     (dummyt dorders  WITH seq = value(size(mar_detail_reply->orders,5))),
     (dummyt dadmins  WITH seq = value(max_admin_cnt))
    PLAN (dorders)
     JOIN (dadmins
     WHERE dadmins.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].administrations,5)))
     JOIN (cen
     WHERE (cen.event_id=mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].event_id)
     )
     JOIN (lb
     WHERE lb.parent_entity_id=cen.ce_event_note_id
      AND lb.parent_entity_name="CE_EVENT_NOTE")
     JOIN (p
     WHERE p.person_id=cen.note_prsnl_id)
    ORDER BY cen.event_id, cnvtdatetime(cen.valid_until_dt_tm)
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadAdminNotes Query Time = ",datetimediff(cnvtdatetime(curdate,
         curtime3),querytime,5)))
     ENDIF
    HEAD dorders.seq
     admin_note_cnt = 0
    HEAD dadmins.seq
     admin_note_cnt = 0
    DETAIL
     admin_note_cnt = (admin_note_cnt+ 1), debug_param_a_id = mar_detail_reply->orders[dorders.seq].
     administrations[dadmins.seq].order_id, debug_param_b_id = cen.event_id,
     debug_param_c_id = cen.ce_event_note_id, debug_param_d_id = admin_note_cnt
     IF (admin_note_cnt > size(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      result_comments,5))
      stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
       result_comments,(admin_note_cnt+ 9))
     ENDIF
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].result_comments[
     admin_note_cnt].valid_from_dt_tm = cen.valid_from_dt_tm, mar_detail_reply->orders[dorders.seq].
     administrations[dadmins.seq].result_comments[admin_note_cnt].valid_until_dt_tm = cen
     .valid_until_dt_tm, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
     result_comments[admin_note_cnt].note_prsnl_id = cen.note_prsnl_id,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].result_comments[
     admin_note_cnt].note_dt_tm = cen.note_dt_tm, mar_detail_reply->orders[dorders.seq].
     administrations[dadmins.seq].result_comments[admin_note_cnt].note_tz = cen.note_tz,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].result_comments[
     admin_note_cnt].note_type_cd = cen.note_type_cd,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].result_comments[
     admin_note_cnt].comment_text = parsecommentlb(cen.note_format_cd,cen.compression_cd,lb.long_blob
      ), mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].result_comments[
     admin_note_cnt].note_prsnl_name = p.name_full_formatted
    FOOT  dorders.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      result_comments,admin_note_cnt)
    FOOT  dadmins.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      result_comments,admin_note_cnt)
    FOOT REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadAdminNotes Query Total Time = ",datetimediff(cnvtdatetime(curdate,
         curtime3),querytime,5)))
     ENDIF
    WITH nocounter
   ;end select
   CALL displayerrorinfo("LoadAdminNotes","ce.order_id","cen.event_id","cen.ce_event_note_id",
    "admin_note_cnt")
   IF (debug_ind=1)
    CALL echo(build("********LoadAdminNotes Total Subroutine Time = ",datetimediff(cnvtdatetime(
        curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadadminprsnl(null)
   CALL echo("LoadAdminPrsnl")
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   DECLARE admin_prsnl_cnt = i4 WITH noconstant(0)
   IF (debug_ind=1)
    SET querytime = cnvtdatetime(curdate,curtime3)
   ENDIF
   SELECT INTO "nl:"
    FROM ce_event_prsnl cep,
     prsnl p_action,
     prsnl p_proxy,
     prsnl p_request,
     (dummyt dorders  WITH seq = value(size(mar_detail_reply->orders,5))),
     (dummyt dadmins  WITH seq = value(max_admin_cnt))
    PLAN (dorders)
     JOIN (dadmins
     WHERE dadmins.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].administrations,5)))
     JOIN (cep
     WHERE (cep.event_id=mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].event_id)
     )
     JOIN (p_action
     WHERE p_action.person_id=cep.action_prsnl_id)
     JOIN (p_proxy
     WHERE p_proxy.person_id=cep.proxy_prsnl_id)
     JOIN (p_request
     WHERE p_request.person_id=cep.request_prsnl_id)
    ORDER BY cep.event_id, cnvtdatetime(cep.valid_until_dt_tm)
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadAdminPrsnl Query Time = ",datetimediff(cnvtdatetime(curdate,
         curtime3),querytime,5)))
     ENDIF
    HEAD dorders.seq
     admin_prsnl_cnt = 0
    HEAD dadmins.seq
     admin_prsnl_cnt = 0
    HEAD cep.ce_event_prsnl_id
     admin_prsnl_cnt = (admin_prsnl_cnt+ 1), debug_param_a_id = mar_detail_reply->orders[dorders.seq]
     .administrations[dadmins.seq].order_id, debug_param_b_id = cep.event_id,
     debug_param_c_id = cep.ce_event_prsnl_id, debug_param_d_id = admin_prsnl_cnt
     IF (admin_prsnl_cnt > size(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      event_prsnl_actions,5))
      stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
       event_prsnl_actions,(admin_prsnl_cnt+ 9))
     ENDIF
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].event_prsnl_actions[
     admin_prsnl_cnt].valid_until_dt_tm = cep.valid_until_dt_tm, mar_detail_reply->orders[dorders.seq
     ].administrations[dadmins.seq].event_prsnl_actions[admin_prsnl_cnt].valid_from_dt_tm = cep
     .valid_from_dt_tm, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
     event_prsnl_actions[admin_prsnl_cnt].action_prsnl_id = cep.action_prsnl_id,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].event_prsnl_actions[
     admin_prsnl_cnt].action_type_cd = cep.action_type_cd, mar_detail_reply->orders[dorders.seq].
     administrations[dadmins.seq].event_prsnl_actions[admin_prsnl_cnt].action_status_cd = cep
     .action_status_cd, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
     event_prsnl_actions[admin_prsnl_cnt].action_dt_tm = cep.action_dt_tm,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].event_prsnl_actions[
     admin_prsnl_cnt].action_tz = cep.action_tz, mar_detail_reply->orders[dorders.seq].
     administrations[dadmins.seq].event_prsnl_actions[admin_prsnl_cnt].action_comment = cep
     .action_comment, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
     event_prsnl_actions[admin_prsnl_cnt].request_prsnl_id = cep.request_prsnl_id,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].event_prsnl_actions[
     admin_prsnl_cnt].request_dt_tm = cep.request_dt_tm, mar_detail_reply->orders[dorders.seq].
     administrations[dadmins.seq].event_prsnl_actions[admin_prsnl_cnt].request_tz = cep.request_tz,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].event_prsnl_actions[
     admin_prsnl_cnt].proxy_prsnl_id = cep.proxy_prsnl_id,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].event_prsnl_actions[
     admin_prsnl_cnt].request_comment = cep.request_comment, mar_detail_reply->orders[dorders.seq].
     administrations[dadmins.seq].event_prsnl_actions[admin_prsnl_cnt].action_prsnl_name = p_action
     .name_full_formatted, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
     event_prsnl_actions[admin_prsnl_cnt].request_prsnl_name = p_request.name_full_formatted,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].event_prsnl_actions[
     admin_prsnl_cnt].proxy_prsnl_name = p_proxy.name_full_formatted
    FOOT  dadmins.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      event_prsnl_actions,admin_prsnl_cnt)
    FOOT  dorders.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      event_prsnl_actions,admin_prsnl_cnt)
    FOOT REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadAdminPrsnl Query Total Time = ",datetimediff(cnvtdatetime(curdate,
         curtime3),querytime,5)))
     ENDIF
    WITH nocounter
   ;end select
   CALL displayerrorinfo("LoadAdminPrsnl","ce.order_id","cep.event_id","cep.ce_event_prsnl_id",
    "admin_prsnl_cnt")
   IF (debug_ind=1)
    CALL echo(build("********LoadAdminPrsnl Total Subroutine Time = ",datetimediff(cnvtdatetime(
        curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadadminingreds(null)
   CALL echo("LoadAdminIngreds")
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   DECLARE admin_ing_cnt = i4 WITH noconstant(0)
   DECLARE admin_ing_hist_cnt = i4 WITH noconstant(0)
   IF (debug_ind=1)
    SET querytime = cnvtdatetime(curdate,curtime3)
   ENDIF
   SELECT INTO "nl:"
    FROM clinical_event ce,
     ce_med_result cem,
     (dummyt dorders  WITH seq = value(size(mar_detail_reply->orders,5))),
     (dummyt dadmins  WITH seq = value(max_admin_cnt)),
     (dummyt dingred  WITH seq = value(max_ingred_cd_cnt))
    PLAN (dorders)
     JOIN (dadmins
     WHERE dadmins.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].administrations,5)))
     JOIN (dingred
     WHERE dingred.seq <= cnvtint(mar_detail_reply->orders[dorders.seq].ingred_event_cd_cnt))
     JOIN (ce
     WHERE (ce.parent_event_id=mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
     event_id)
      AND ce.parent_event_id != ce.event_id
      AND ((ce.event_class_cd IN (ceventmed, ceventimmun)) OR (ce.result_status_cd IN (cnotdone,
     cinerror)
      AND (mar_detail_reply->orders[dorders.seq].related_event_cds[dingred.seq].event_cd=ce.event_cd)
     )) )
     JOIN (cem
     WHERE cem.event_id=outerjoin(ce.event_id)
      AND cem.valid_from_dt_tm <= outerjoin(ce.valid_from_dt_tm)
      AND cem.valid_until_dt_tm >= outerjoin(ce.valid_until_dt_tm))
    ORDER BY dorders.seq, dadmins.seq, ce.parent_event_id,
     ce.event_id, ce.valid_until_dt_tm DESC, cem.valid_until_dt_tm,
     ce.clinical_event_id
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadAdminIngreds Query Time = ",datetimediff(cnvtdatetime(curdate,
         curtime3),querytime,5)))
     ENDIF
    HEAD dorders.seq
     admin_ing_cnt = 0, admin_ing_hist_cnt = 0
    HEAD dadmins.seq
     admin_ing_cnt = 0, admin_ing_hist_cnt = 0
    HEAD ce.clinical_event_id
     debug_param_a_id = mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].order_id,
     debug_param_b_id = ce.clinical_event_id
     IF (ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
      admin_ing_cnt = (admin_ing_cnt+ 1), admin_ing_hist_cnt = 0, debug_param_c_id = admin_ing_cnt
      IF (admin_ing_cnt > size(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
       ingredients,5))
       stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
        ingredients,(admin_ing_cnt+ 9))
      ENDIF
      IF (admin_ing_cnt > max_admin_ingred)
       max_admin_ingred = admin_ing_cnt
      ENDIF
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
      event_id = ce.event_id, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      ingredients[admin_ing_cnt].result_status_cd = ce.result_status_cd, mar_detail_reply->orders[
      dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].event_class_cd = ce
      .event_class_cd,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
      event_tag = ce.event_tag, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      ingredients[admin_ing_cnt].event_cd = ce.event_cd, mar_detail_reply->orders[dorders.seq].
      administrations[dadmins.seq].ingredients[admin_ing_cnt].catalog_cd = ce.catalog_cd,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
      valid_from_dt_tm = ce.valid_from_dt_tm, mar_detail_reply->orders[dorders.seq].administrations[
      dadmins.seq].ingredients[admin_ing_cnt].valid_until_dt_tm = ce.valid_until_dt_tm,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
      device_free_txt = ce.device_free_txt,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
      order_idx = dorders.seq, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      ingredients[admin_ing_cnt].result_idx = dadmins.seq, mar_detail_reply->orders[dorders.seq].
      administrations[dadmins.seq].ingredients[admin_ing_cnt].synonym_id = cem.synonym_id,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
      initial_dose = cem.initial_dosage, mar_detail_reply->orders[dorders.seq].administrations[
      dadmins.seq].ingredients[admin_ing_cnt].admin_dose = cem.admin_dosage, mar_detail_reply->
      orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].dose_unit_cd = cem
      .dosage_unit_cd,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
      initial_volume = cem.initial_volume, mar_detail_reply->orders[dorders.seq].administrations[
      dadmins.seq].ingredients[admin_ing_cnt].admin_volume = cem.infused_volume, mar_detail_reply->
      orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].volume_unit_cd =
      cem.infused_volume_unit_cd,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
      admin_route_cd = cem.admin_route_cd, mar_detail_reply->orders[dorders.seq].administrations[
      dadmins.seq].ingredients[admin_ing_cnt].admin_site_cd = cem.admin_site_cd, mar_detail_reply->
      orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].infusion_rate = cem
      .infusion_rate,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
      infusion_rate_unit_cd = cem.infusion_unit_cd, mar_detail_reply->orders[dorders.seq].
      administrations[dadmins.seq].ingredients[admin_ing_cnt].substance_lot_number = cem
      .substance_lot_number, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      ingredients[admin_ing_cnt].substance_manufacturer_cd = cem.substance_manufacturer_cd,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
      substance_exp_dt_tm = cem.substance_exp_dt_tm
      IF (ce.result_status_cd=cnotdone)
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].result_status_cd = ce
       .result_status_cd
       IF (ce.event_class_cd IN (ceventmed, ceventimmun))
        mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].event_tag = i18n_snotgiven
       ELSE
        mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].event_tag = i18n_snotdone
       ENDIF
      ENDIF
     ELSE
      IF ((mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[
      admin_ing_cnt].event_id=ce.event_id))
       admin_ing_hist_cnt = (admin_ing_hist_cnt+ 1), debug_param_d_id = admin_ing_hist_cnt
       IF (admin_ing_hist_cnt > size(mar_detail_reply->orders[dorders.seq].administrations[dadmins
        .seq].ingredients[admin_ing_cnt].ingredient_histories,5))
        stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
         ingredients[admin_ing_cnt].ingredient_histories,admin_ing_hist_cnt)
       ENDIF
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
       ingredient_histories[admin_ing_hist_cnt].event_id = ce.event_id, mar_detail_reply->orders[
       dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].ingredient_histories[
       admin_ing_hist_cnt].result_status_cd = ce.result_status_cd, mar_detail_reply->orders[dorders
       .seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].ingredient_histories[
       admin_ing_hist_cnt].event_class_cd = ce.event_class_cd,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
       ingredient_histories[admin_ing_hist_cnt].event_tag = ce.event_tag, mar_detail_reply->orders[
       dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].ingredient_histories[
       admin_ing_hist_cnt].event_cd = ce.event_cd, mar_detail_reply->orders[dorders.seq].
       administrations[dadmins.seq].ingredients[admin_ing_cnt].ingredient_histories[
       admin_ing_hist_cnt].catalog_cd = ce.catalog_cd,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
       ingredient_histories[admin_ing_hist_cnt].valid_from_dt_tm = ce.valid_from_dt_tm,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
       ingredient_histories[admin_ing_hist_cnt].valid_to_dt_tm = ce.valid_until_dt_tm,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
       ingredient_histories[admin_ing_hist_cnt].device_free_txt = ce.device_free_txt,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
       ingredient_histories[admin_ing_hist_cnt].order_idx = dorders.seq, mar_detail_reply->orders[
       dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].ingredient_histories[
       admin_ing_hist_cnt].result_idx = dadmins.seq, mar_detail_reply->orders[dorders.seq].
       administrations[dadmins.seq].ingredients[admin_ing_cnt].ingredient_histories[
       admin_ing_hist_cnt].synonym_id = cem.synonym_id,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
       ingredient_histories[admin_ing_hist_cnt].initial_dose = cem.initial_dosage, mar_detail_reply->
       orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
       ingredient_histories[admin_ing_hist_cnt].admin_dose = cem.admin_dosage, mar_detail_reply->
       orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
       ingredient_histories[admin_ing_hist_cnt].dose_unit_cd = cem.dosage_unit_cd,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
       ingredient_histories[admin_ing_hist_cnt].initial_volume = cem.initial_volume, mar_detail_reply
       ->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
       ingredient_histories[admin_ing_hist_cnt].admin_volume = cem.infused_volume, mar_detail_reply->
       orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
       ingredient_histories[admin_ing_hist_cnt].volume_unit_cd = cem.infused_volume_unit_cd,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
       ingredient_histories[admin_ing_hist_cnt].admin_route_cd = cem.admin_route_cd, mar_detail_reply
       ->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
       ingredient_histories[admin_ing_hist_cnt].admin_site_cd = cem.admin_site_cd, mar_detail_reply->
       orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
       ingredient_histories[admin_ing_hist_cnt].infusion_rate = cem.infusion_rate,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
       ingredient_histories[admin_ing_hist_cnt].infusion_rate_unit_cd = cem.infusion_unit_cd,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
       ingredient_histories[admin_ing_hist_cnt].substance_lot_number = cem.substance_lot_number,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
       ingredient_histories[admin_ing_hist_cnt].substance_manufacturer_cd = cem
       .substance_manufacturer_cd,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt].
       ingredient_histories[admin_ing_hist_cnt].substance_exp_dt_tm = cem.substance_exp_dt_tm
       IF (ce.result_status_cd=cnotdone)
        FOR (admin_hist_it = 1 TO size(mar_detail_reply->orders[dorders.seq].administrations[dadmins
         .seq].admin_histories,5))
          mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].admin_histories[
          admin_hist_it].result_status_cd = ce.result_status_cd
        ENDFOR
       ENDIF
       IF (cem.iv_event_cd > 0)
        mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt]
        .ingredient_histories[admin_ing_hist_cnt].core_action_sequence = parseactionseqiv(ce
         .order_action_sequence,ce.collating_seq)
       ELSEIF (ce.order_action_sequence > 0)
        mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt]
        .ingredient_histories[admin_ing_hist_cnt].core_action_sequence = ce.order_action_sequence
       ELSE
        mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[admin_ing_cnt]
        .ingredient_histories[admin_ing_hist_cnt].core_action_sequence = 1
       ENDIF
      ELSE
       stat = saveerrordata("ingredient_histories",ce.order_id,ce.event_id)
      ENDIF
     ENDIF
    FOOT  dadmins.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients,
      admin_ing_cnt), stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins
      .seq].ingredients[admin_ing_cnt].ingredient_histories,admin_ing_hist_cnt)
    FOOT  dorders.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients,
      admin_ing_cnt), stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins
      .seq].ingredients[admin_ing_cnt].ingredient_histories,admin_ing_hist_cnt)
    FOOT REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadAdminIngreds Query Total Time = ",datetimediff(cnvtdatetime(
         curdate,curtime3),querytime,5)))
     ENDIF
    WITH nocounter
   ;end select
   CALL displayerrorinfo("LoadAdminIngreds","ce.order_id","ce.clinical_event_id","admin_ing_cnt",
    "admin_ing_hist_cnt")
   IF (debug_ind=1)
    CALL echo(build("********LoadAdminIngreds Total Subroutine Time = ",datetimediff(cnvtdatetime(
        curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadadminingredcomments(null)
   CALL echo("LoadAdminIngredComments")
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   DECLARE admin_ing_note_cnt = i4 WITH noconstant(0)
   IF (debug_ind=1)
    SET querytime = cnvtdatetime(curdate,curtime3)
   ENDIF
   SELECT INTO "nl:"
    FROM ce_event_note cen,
     long_blob lb,
     prsnl p,
     (dummyt dorders  WITH seq = value(size(mar_detail_reply->orders,5))),
     (dummyt dadmins  WITH seq = value(max_admin_cnt)),
     (dummyt dingreds  WITH seq = value(max_admin_ingred))
    PLAN (dorders)
     JOIN (dadmins
     WHERE dadmins.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].administrations,5)))
     JOIN (dingreds
     WHERE dingreds.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].administrations[dadmins
       .seq].ingredients,5)))
     JOIN (cen
     WHERE (cen.event_id=mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
     ingredients[dingreds.seq].event_id))
     JOIN (lb
     WHERE lb.parent_entity_id=cen.ce_event_note_id
      AND lb.parent_entity_name="CE_EVENT_NOTE")
     JOIN (p
     WHERE p.person_id=cen.note_prsnl_id)
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadAdminIngredComments Query Time = ",datetimediff(cnvtdatetime(
         curdate,curtime3),querytime,5)))
     ENDIF
    HEAD dorders.seq
     admin_ing_note_cnt = 0
    HEAD dadmins.seq
     admin_ing_note_cnt = 0
    HEAD dingreds.seq
     admin_ing_note_cnt = 0
    DETAIL
     admin_ing_note_cnt = (admin_ing_note_cnt+ 1), debug_param_a_id = mar_detail_reply->orders[
     dorders.seq].administrations[dadmins.seq].order_id, debug_param_b_id = cen.event_id,
     debug_param_c_id = cen.ce_event_note_id, debug_param_d_id = admin_ing_note_cnt
     IF (admin_ing_note_cnt > size(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq]
      .ingredients[dingreds.seq].result_comments,5))
      stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
       ingredients[dingreds.seq].result_comments,(admin_ing_note_cnt+ 9))
     ENDIF
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[dingreds.seq].
     result_comments[admin_ing_note_cnt].valid_from_dt_tm = cen.valid_from_dt_tm, mar_detail_reply->
     orders[dorders.seq].administrations[dadmins.seq].ingredients[dingreds.seq].result_comments[
     admin_ing_note_cnt].valid_to_dt_tm = cen.valid_until_dt_tm, mar_detail_reply->orders[dorders.seq
     ].administrations[dadmins.seq].ingredients[dingreds.seq].result_comments[admin_ing_note_cnt].
     note_prsnl_id = cen.note_prsnl_id,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[dingreds.seq].
     result_comments[admin_ing_note_cnt].note_dt_tm = cen.note_dt_tm, mar_detail_reply->orders[
     dorders.seq].administrations[dadmins.seq].ingredients[dingreds.seq].result_comments[
     admin_ing_note_cnt].note_tz = cen.note_tz, mar_detail_reply->orders[dorders.seq].
     administrations[dadmins.seq].ingredients[dingreds.seq].result_comments[admin_ing_note_cnt].
     note_type_cd = cen.note_type_cd,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[dingreds.seq].
     result_comments[admin_ing_note_cnt].comment_text = parsecommentlb(cen.note_format_cd,cen
      .compression_cd,lb.long_blob), mar_detail_reply->orders[dorders.seq].administrations[dadmins
     .seq].ingredients[dingreds.seq].result_comments[admin_ing_note_cnt].note_prsnl_name = p
     .name_full_formatted
    FOOT  dingreds.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[
      dingreds.seq].result_comments,admin_ing_note_cnt)
    FOOT  dadmins.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[
      dingreds.seq].result_comments,admin_ing_note_cnt)
    FOOT  dorders.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[
      dingreds.seq].result_comments,admin_ing_note_cnt)
    FOOT REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadAdminIngredComments Query Total Time = ",datetimediff(cnvtdatetime
        (curdate,curtime3),querytime,5)))
     ENDIF
    WITH nocounter
   ;end select
   CALL displayerrorinfo("LoadAdminIngredComments","ce.order_id","cen.event_id",
    "cen.ce_event_note_id","admin_ing_note_cnt")
   IF (debug_ind=1)
    CALL echo(build("********LoadAdminIngredComments Total Subroutine Time = ",datetimediff(
       cnvtdatetime(curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadadminingredprsnl(null)
   CALL echo("LoadAdminIngredPrsnl")
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   DECLARE admin_ing_prsnl_cnt = i4 WITH noconstant(0)
   IF (debug_ind=1)
    SET querytime = cnvtdatetime(curdate,curtime3)
   ENDIF
   SELECT INTO "nl:"
    FROM ce_event_prsnl cep,
     prsnl p_action,
     prsnl p_proxy,
     prsnl p_request,
     (dummyt dorders  WITH seq = value(size(mar_detail_reply->orders,5))),
     (dummyt dadmins  WITH seq = value(max_admin_cnt)),
     (dummyt dingreds  WITH seq = value(max_admin_ingred))
    PLAN (dorders)
     JOIN (dadmins
     WHERE dadmins.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].administrations,5)))
     JOIN (dingreds
     WHERE dingreds.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].administrations[dadmins
       .seq].ingredients,5)))
     JOIN (cep
     WHERE (cep.event_id=mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
     ingredients[dingreds.seq].event_id))
     JOIN (p_action
     WHERE p_action.person_id=cep.action_prsnl_id)
     JOIN (p_proxy
     WHERE p_proxy.person_id=cep.proxy_prsnl_id)
     JOIN (p_request
     WHERE p_request.person_id=cep.request_prsnl_id)
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadAdminIngredPrsnl Query Time = ",datetimediff(cnvtdatetime(curdate,
         curtime3),querytime,5)))
     ENDIF
    HEAD dorders.seq
     admin_ing_prsnl_cnt = 0
    HEAD dadmins.seq
     admin_ing_prsnl_cnt = 0
    HEAD dingreds.seq
     admin_ing_prsnl_cnt = 0
    HEAD cep.ce_event_prsnl_id
     admin_ing_prsnl_cnt = (admin_ing_prsnl_cnt+ 1), debug_param_a_id = mar_detail_reply->orders[
     dorders.seq].administrations[dadmins.seq].order_id, debug_param_b_id = cep.event_id,
     debug_param_c_id = cep.action_prsnl_id, debug_param_d_id = admin_ing_prsnl_cnt
     IF (admin_ing_prsnl_cnt > size(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq
      ].ingredients[dingreds.seq].event_prsnl_actions,5))
      stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
       ingredients[dingreds.seq].event_prsnl_actions,(admin_ing_prsnl_cnt+ 9))
     ENDIF
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[dingreds.seq].
     event_prsnl_actions[admin_ing_prsnl_cnt].valid_until_dt_tm = cep.valid_until_dt_tm,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[dingreds.seq].
     event_prsnl_actions[admin_ing_prsnl_cnt].valid_from_dt_tm = cep.valid_from_dt_tm,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[dingreds.seq].
     event_prsnl_actions[admin_ing_prsnl_cnt].action_prsnl_id = cep.action_prsnl_id,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[dingreds.seq].
     event_prsnl_actions[admin_ing_prsnl_cnt].action_type_cd = cep.action_type_cd, mar_detail_reply->
     orders[dorders.seq].administrations[dadmins.seq].ingredients[dingreds.seq].event_prsnl_actions[
     admin_ing_prsnl_cnt].action_status_cd = cep.action_status_cd, mar_detail_reply->orders[dorders
     .seq].administrations[dadmins.seq].ingredients[dingreds.seq].event_prsnl_actions[
     admin_ing_prsnl_cnt].action_dt_tm = cep.action_dt_tm,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[dingreds.seq].
     event_prsnl_actions[admin_ing_prsnl_cnt].action_tz = cep.action_tz, mar_detail_reply->orders[
     dorders.seq].administrations[dadmins.seq].ingredients[dingreds.seq].event_prsnl_actions[
     admin_ing_prsnl_cnt].action_comment = cep.action_comment, mar_detail_reply->orders[dorders.seq].
     administrations[dadmins.seq].ingredients[dingreds.seq].event_prsnl_actions[admin_ing_prsnl_cnt].
     request_prsnl_id = cep.request_prsnl_id,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[dingreds.seq].
     event_prsnl_actions[admin_ing_prsnl_cnt].request_dt_tm = cep.request_dt_tm, mar_detail_reply->
     orders[dorders.seq].administrations[dadmins.seq].ingredients[dingreds.seq].event_prsnl_actions[
     admin_ing_prsnl_cnt].request_tz = cep.request_tz, mar_detail_reply->orders[dorders.seq].
     administrations[dadmins.seq].ingredients[dingreds.seq].event_prsnl_actions[admin_ing_prsnl_cnt].
     proxy_prsnl_id = cep.proxy_prsnl_id,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[dingreds.seq].
     event_prsnl_actions[admin_ing_prsnl_cnt].request_comment, mar_detail_reply->orders[dorders.seq].
     administrations[dadmins.seq].ingredients[dingreds.seq].event_prsnl_actions[admin_ing_prsnl_cnt].
     action_prsnl_name = p_action.name_full_formatted, mar_detail_reply->orders[dorders.seq].
     administrations[dadmins.seq].ingredients[dingreds.seq].event_prsnl_actions[admin_ing_prsnl_cnt].
     request_prsnl_name = p_request.name_full_formatted,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[dingreds.seq].
     event_prsnl_actions[admin_ing_prsnl_cnt].proxy_prsnl_name = p_proxy.name_full_formatted
    FOOT  dingreds.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[
      dingreds.seq].event_prsnl_actions,admin_ing_prsnl_cnt)
    FOOT  dadmins.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[
      dingreds.seq].event_prsnl_actions,admin_ing_prsnl_cnt)
    FOOT  dorders.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].ingredients[
      dingreds.seq].event_prsnl_actions,admin_ing_prsnl_cnt)
    FOOT REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadAdminIngredPrsnl Query Total Time = ",datetimediff(cnvtdatetime(
         curdate,curtime3),querytime,5)))
     ENDIF
    WITH nocounter
   ;end select
   CALL displayerrorinfo("LoadAdminIngredPrsnl","ce.order_id","cep.event_id","cep.action_prsnl_id",
    "admin_ing_prsnl_cnt")
   IF (debug_ind=1)
    CALL echo(build("********LoadAdminIngredPrsnl Total Subroutine Time = ",datetimediff(cnvtdatetime
       (curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loaddiscretes(null)
   CALL echo("LoadDiscretes")
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   DECLARE dta_cnt = i4 WITH noconstant(0)
   DECLARE dta_hist_cnt = i4 WITH noconstant(0)
   IF (debug_ind=1)
    SET querytime = cnvtdatetime(curdate,curtime3)
   ENDIF
   SELECT INTO "nl:"
    FROM clinical_event ce,
     (dummyt dorders  WITH seq = value(size(mar_detail_reply->orders,5))),
     (dummyt dadmins  WITH seq = value(max_admin_cnt))
    PLAN (dorders)
     JOIN (dadmins
     WHERE dadmins.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].administrations,5)))
     JOIN (ce
     WHERE (ce.parent_event_id=mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
     event_id)
      AND ((ce.task_assay_cd+ 0) > 0)
      AND ((ce.order_action_sequence+ 0) > 0))
    ORDER BY ce.event_id, cnvtdatetime(ce.valid_until_dt_tm) DESC
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadDiscretes Query Time = ",datetimediff(cnvtdatetime(curdate,
         curtime3),querytime,5)))
     ENDIF
    HEAD dorders.seq
     dta_cnt = 0
    HEAD dadmins.seq
     dta_cnt = 0
    DETAIL
     debug_param_a_id = ce.order_id, debug_param_b_id = ce.clinical_event_id
     IF (ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
      dta_cnt = (dta_cnt+ 1), dta_hist_cnt = 0, debug_param_c_id = dta_cnt
      IF (dta_cnt > size(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes,
       5))
       stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes,
        (dta_cnt+ 9))
      ENDIF
      IF (dta_cnt > max_dta_cnt)
       max_dta_cnt = dta_cnt
      ENDIF
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[dta_cnt].
      event_end_dt_tm = ce.event_end_dt_tm, mar_detail_reply->orders[dorders.seq].administrations[
      dadmins.seq].discretes[dta_cnt].event_end_tz = ce.event_end_tz, mar_detail_reply->orders[
      dorders.seq].administrations[dadmins.seq].discretes[dta_cnt].valid_from_dt_tm = ce
      .valid_from_dt_tm,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[dta_cnt].
      valid_until_dt_tm = ce.valid_until_dt_tm, mar_detail_reply->orders[dorders.seq].
      administrations[dadmins.seq].discretes[dta_cnt].event_id = ce.event_id, mar_detail_reply->
      orders[dorders.seq].administrations[dadmins.seq].discretes[dta_cnt].parent_event_id = ce
      .parent_event_id,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[dta_cnt].event_cd
       = ce.event_cd, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[
      dta_cnt].event_class_cd = ce.event_class_cd, mar_detail_reply->orders[dorders.seq].
      administrations[dadmins.seq].discretes[dta_cnt].event_tag = ce.event_tag,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[dta_cnt].
      result_val = ce.result_val, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      discretes[dta_cnt].result_unit_cd = ce.result_units_cd, mar_detail_reply->orders[dorders.seq].
      administrations[dadmins.seq].discretes[dta_cnt].task_assay_cd = ce.task_assay_cd,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[dta_cnt].
      result_status_cd = ce.result_status_cd, mar_detail_reply->orders[dorders.seq].administrations[
      dadmins.seq].discretes[dta_cnt].normalcy_cd = ce.normalcy_cd, mar_detail_reply->orders[dorders
      .seq].administrations[dadmins.seq].discretes[dta_cnt].normal_low = ce.normal_low,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[dta_cnt].
      normal_high = ce.normal_high, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq
      ].discretes[dta_cnt].critical_low = ce.critical_low, mar_detail_reply->orders[dorders.seq].
      administrations[dadmins.seq].discretes[dta_cnt].critical_high = ce.critical_high,
      mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[dta_cnt].order_id
       = ce.order_id, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[
      dta_cnt].order_idx = dorders.seq, mar_detail_reply->orders[dorders.seq].administrations[dadmins
      .seq].discretes[dta_cnt].result_idx = dadmins.seq
     ELSE
      IF ((mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[dta_cnt].
      event_id=ce.event_id))
       dta_hist_cnt = (dta_hist_cnt+ 1), debug_param_d_id = dta_hist_cnt
       IF (dta_hist_cnt > size(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
        discretes[dta_cnt].result_histories,5))
        stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
         discretes[dta_cnt].result_histories,(dta_hist_cnt+ 9))
       ENDIF
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[dta_cnt].
       result_histories[dta_hist_cnt].valid_from_dt_tm = ce.valid_from_dt_tm, mar_detail_reply->
       orders[dorders.seq].administrations[dadmins.seq].discretes[dta_cnt].result_histories[
       dta_hist_cnt].valid_until_dt_tm = ce.valid_until_dt_tm, mar_detail_reply->orders[dorders.seq].
       administrations[dadmins.seq].discretes[dta_cnt].result_histories[dta_hist_cnt].event_end_dt_tm
        = ce.event_end_dt_tm,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[dta_cnt].
       result_histories[dta_hist_cnt].performed_dt_tm = ce.performed_dt_tm, mar_detail_reply->orders[
       dorders.seq].administrations[dadmins.seq].discretes[dta_cnt].result_histories[dta_hist_cnt].
       performed_tz = ce.performed_tz, mar_detail_reply->orders[dorders.seq].administrations[dadmins
       .seq].discretes[dta_cnt].result_histories[dta_hist_cnt].event_end_dt_tm = ce.event_end_dt_tm,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[dta_cnt].
       result_histories[dta_hist_cnt].event_end_tz = ce.event_end_tz, mar_detail_reply->orders[
       dorders.seq].administrations[dadmins.seq].discretes[dta_cnt].result_histories[dta_hist_cnt].
       performed_dt_tm = ce.performed_dt_tm, mar_detail_reply->orders[dorders.seq].administrations[
       dadmins.seq].discretes[dta_cnt].result_histories[dta_hist_cnt].performed_tz = ce.performed_tz,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[dta_cnt].
       result_histories[dta_hist_cnt].event_id = ce.person_id, mar_detail_reply->orders[dorders.seq].
       administrations[dadmins.seq].discretes[dta_cnt].result_histories[dta_hist_cnt].event_tag = ce
       .event_tag, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[
       dta_cnt].result_histories[dta_hist_cnt].event_cd = ce.event_cd,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[dta_cnt].
       result_histories[dta_hist_cnt].result_val = ce.result_val, mar_detail_reply->orders[dorders
       .seq].administrations[dadmins.seq].discretes[dta_cnt].result_histories[dta_hist_cnt].
       result_status_cd = ce.result_status_cd, mar_detail_reply->orders[dorders.seq].administrations[
       dadmins.seq].discretes[dta_cnt].result_histories[dta_hist_cnt].result_unit_cd = ce
       .result_units_cd,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[dta_cnt].
       result_histories[dta_hist_cnt].normalcy_cd = ce.normalcy_cd, mar_detail_reply->orders[dorders
       .seq].administrations[dadmins.seq].discretes[dta_cnt].result_histories[dta_hist_cnt].
       normal_low = ce.normal_low, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq]
       .discretes[dta_cnt].result_histories[dta_hist_cnt].normal_high = ce.normal_high,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[dta_cnt].
       result_histories[dta_hist_cnt].critical_low = ce.critical_low, mar_detail_reply->orders[
       dorders.seq].administrations[dadmins.seq].discretes[dta_cnt].result_histories[dta_hist_cnt].
       critical_high = ce.critical_high, mar_detail_reply->orders[dorders.seq].administrations[
       dadmins.seq].discretes[dta_cnt].result_histories[dta_hist_cnt].order_idx = dorders.seq,
       mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[dta_cnt].
       result_histories[dta_hist_cnt].result_idx = dadmins.seq
      ELSE
       CALL saveerrordata("result_histories",ce.order_id,ce.event_id)
      ENDIF
     ENDIF
    FOOT  dadmins.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes,
      dta_cnt), stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      discretes[dta_cnt].result_histories,dta_hist_cnt)
    FOOT  dorders.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes,
      dta_cnt), stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      discretes[dta_cnt].result_histories,dta_hist_cnt)
    FOOT REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadDiscretes Query Total Time = ",datetimediff(cnvtdatetime(curdate,
         curtime3),querytime,5)))
     ENDIF
    WITH nocounter
   ;end select
   CALL displayerrorinfo("LoadDiscretes","ce.order_id","ce.clinical_event_id","dta_cnt",
    "dta_hist_cnt")
   IF (debug_ind=1)
    CALL echo(build("********LoadDiscretes Total Subroutine Time = ",datetimediff(cnvtdatetime(
        curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loaddiscrhistcomments(null)
   CALL echo("LoadDiscrHistComments")
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   DECLARE dta_note_cnt = i4 WITH noconstant(0)
   IF (debug_ind=1)
    SET querytime = cnvtdatetime(curdate,curtime3)
   ENDIF
   SELECT INTO "nl:"
    FROM ce_event_note cen,
     long_blob lb,
     prsnl p,
     (dummyt dorders  WITH seq = value(size(mar_detail_reply->orders,5))),
     (dummyt dadmins  WITH seq = value(max_admin_cnt)),
     (dummyt ddtas  WITH seq = value(max_dta_cnt))
    PLAN (dorders)
     JOIN (dadmins
     WHERE dadmins.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].administrations,5)))
     JOIN (ddtas
     WHERE ddtas.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].administrations[dadmins
       .seq].discretes,5)))
     JOIN (cen
     WHERE (cen.event_id=mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
     discretes[ddtas.seq].event_id))
     JOIN (lb
     WHERE lb.parent_entity_id=cen.ce_event_note_id
      AND lb.parent_entity_name="CE_EVENT_NOTE")
     JOIN (p
     WHERE p.person_id=cen.note_prsnl_id)
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadDiscrHistComments Query Time = ",datetimediff(cnvtdatetime(curdate,
         curtime3),querytime,5)))
     ENDIF
    HEAD dorders.seq
     dta_note_cnt = 0
    HEAD dadmins.seq
     dta_note_cnt = 0
    HEAD ddtas.seq
     dta_note_cnt = 0
    DETAIL
     dta_note_cnt = (dta_note_cnt+ 1), debug_param_a_id = mar_detail_reply->orders[dorders.seq].
     administrations[dadmins.seq].order_id, debug_param_b_id = cen.event_id,
     debug_param_c_id = lb.parent_entity_id, debug_param_d_id = dta_note_cnt
     IF (dta_note_cnt > size(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      discretes[ddtas.seq].result_comments,5))
      stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[
       ddtas.seq].result_comments,(dta_note_cnt+ 9))
     ENDIF
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[ddtas.seq].
     result_comments[dta_note_cnt].valid_from_dt_tm = cen.valid_from_dt_tm, mar_detail_reply->orders[
     dorders.seq].administrations[dadmins.seq].discretes[ddtas.seq].result_comments[dta_note_cnt].
     valid_until_dt_tm = cen.valid_until_dt_tm, mar_detail_reply->orders[dorders.seq].
     administrations[dadmins.seq].discretes[ddtas.seq].result_comments[dta_note_cnt].note_prsnl_id =
     cen.note_prsnl_id,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[ddtas.seq].
     result_comments[dta_note_cnt].note_dt_tm = cen.note_dt_tm, mar_detail_reply->orders[dorders.seq]
     .administrations[dadmins.seq].discretes[ddtas.seq].result_comments[dta_note_cnt].note_tz = cen
     .note_tz, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[ddtas.seq
     ].result_comments[dta_note_cnt].note_type_cd = cen.note_type_cd,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[ddtas.seq].
     result_comments[dta_note_cnt].comment_text = parsecommentlb(cen.note_format_cd,cen
      .compression_cd,lb.long_blob), mar_detail_reply->orders[dorders.seq].administrations[dadmins
     .seq].discretes[ddtas.seq].result_comments[dta_note_cnt].note_prsnl_name = p.name_full_formatted
    FOOT  ddtas.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[
      ddtas.seq].result_comments,dta_note_cnt)
    FOOT  dadmins.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[
      ddtas.seq].result_comments,dta_note_cnt)
    FOOT  dorders.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[
      ddtas.seq].result_comments,dta_note_cnt)
    FOOT REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadDiscrHistComments Query Total Time = ",datetimediff(cnvtdatetime(
         curdate,curtime3),querytime,5)))
     ENDIF
    WITH nocounter
   ;end select
   CALL displayerrorinfo("LoadDiscrHistComments","ce.order_id","cen.event_id","lb.parent_entity_id",
    "dta_note_cnt")
   IF (debug_ind=1)
    CALL echo(build("********LoadDiscrHistComments Total Subroutine Time = ",datetimediff(
       cnvtdatetime(curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loaddiscrprsnl(null)
   CALL echo("LoadDiscrPrsnl")
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   DECLARE dta_prsnl_cnt = i4 WITH noconstant(0)
   IF (debug_ind=1)
    SET querytime = cnvtdatetime(curdate,curtime3)
   ENDIF
   SELECT INTO "nl:"
    FROM ce_event_prsnl cep,
     prsnl p_action,
     prsnl p_proxy,
     prsnl p_request,
     (dummyt dorders  WITH seq = value(size(mar_detail_reply->orders,5))),
     (dummyt dadmins  WITH seq = value(max_admin_cnt)),
     (dummyt ddtas  WITH seq = value(max_dta_cnt))
    PLAN (dorders)
     JOIN (dadmins
     WHERE dadmins.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].administrations,5)))
     JOIN (ddtas
     WHERE ddtas.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].administrations[dadmins
       .seq].discretes,5)))
     JOIN (cep
     WHERE (cep.event_id=mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
     discretes[ddtas.seq].event_id))
     JOIN (p_action
     WHERE p_action.person_id=cep.action_prsnl_id)
     JOIN (p_proxy
     WHERE p_proxy.person_id=cep.proxy_prsnl_id)
     JOIN (p_request
     WHERE p_request.person_id=cep.request_prsnl_id)
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadDiscrPrsnl Query Time = ",datetimediff(cnvtdatetime(curdate,
         curtime3),querytime,5)))
     ENDIF
    HEAD dorders.seq
     dta_prsnl_cnt = 0
    HEAD dadmins.seq
     dta_prsnl_cnt = 0
    HEAD ddtas.seq
     dta_prsnl_cnt = 0
    DETAIL
     dta_prsnl_cnt = (dta_prsnl_cnt+ 1), debug_param_a_id = mar_detail_reply->orders[dorders.seq].
     administrations[dadmins.seq].order_id, debug_param_b_id = cep.event_id,
     debug_param_c_id = p_action.person_id, debug_param_d_id = dta_prsnl_cnt
     IF (dta_prsnl_cnt > size(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      discretes[ddtas.seq].event_prsnl_actions,5))
      stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[
       ddtas.seq].event_prsnl_actions,(dta_prsnl_cnt+ 9))
     ENDIF
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[ddtas.seq].
     event_prsnl_actions[dta_prsnl_cnt].valid_until_dt_tm = cep.valid_until_dt_tm, mar_detail_reply->
     orders[dorders.seq].administrations[dadmins.seq].discretes[ddtas.seq].event_prsnl_actions[
     dta_prsnl_cnt].action_prsnl_id = cep.action_prsnl_id, mar_detail_reply->orders[dorders.seq].
     administrations[dadmins.seq].discretes[ddtas.seq].event_prsnl_actions[dta_prsnl_cnt].
     action_type_cd = cep.action_type_cd,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[ddtas.seq].
     event_prsnl_actions[dta_prsnl_cnt].action_status_cd = cep.action_status_cd, mar_detail_reply->
     orders[dorders.seq].administrations[dadmins.seq].discretes[ddtas.seq].event_prsnl_actions[
     dta_prsnl_cnt].action_dt_tm = cep.action_dt_tm, mar_detail_reply->orders[dorders.seq].
     administrations[dadmins.seq].discretes[ddtas.seq].event_prsnl_actions[dta_prsnl_cnt].action_tz
      = cep.action_tz,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[ddtas.seq].
     event_prsnl_actions[dta_prsnl_cnt].action_comment = cep.action_comment, mar_detail_reply->
     orders[dorders.seq].administrations[dadmins.seq].discretes[ddtas.seq].event_prsnl_actions[
     dta_prsnl_cnt].request_prsnl_id = cep.request_prsnl_id, mar_detail_reply->orders[dorders.seq].
     administrations[dadmins.seq].discretes[ddtas.seq].event_prsnl_actions[dta_prsnl_cnt].
     request_dt_tm = cep.request_dt_tm,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[ddtas.seq].
     event_prsnl_actions[dta_prsnl_cnt].request_tz = cep.request_tz, mar_detail_reply->orders[dorders
     .seq].administrations[dadmins.seq].discretes[ddtas.seq].event_prsnl_actions[dta_prsnl_cnt].
     proxy_prsnl_id = cep.proxy_prsnl_id, mar_detail_reply->orders[dorders.seq].administrations[
     dadmins.seq].discretes[ddtas.seq].event_prsnl_actions[dta_prsnl_cnt].request_comment = cep
     .request_comment,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[ddtas.seq].
     event_prsnl_actions[dta_prsnl_cnt].action_prsnl_name = p_action.name_full_formatted,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[ddtas.seq].
     event_prsnl_actions[dta_prsnl_cnt].request_prsnl_name = p_request.name_full_formatted,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[ddtas.seq].
     event_prsnl_actions[dta_prsnl_cnt].proxy_prsnl_name = p_proxy.name_full_formatted
    FOOT  ddtas.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[
      ddtas.seq].event_prsnl_actions,dta_prsnl_cnt)
    FOOT  dadmins.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[
      ddtas.seq].event_prsnl_actions,dta_prsnl_cnt)
    FOOT  dorders.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].discretes[
      ddtas.seq].event_prsnl_actions,dta_prsnl_cnt)
    FOOT REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadDiscrPrsnl Query Total Time = ",datetimediff(cnvtdatetime(curdate,
         curtime3),querytime,5)))
     ENDIF
    WITH nocounter
   ;end select
   CALL displayerrorinfo("LoadDiscrPrsnl","ce.order_id","cep.event_id","p_action.person_id",
    "dta_prsnl_cnt")
   IF (debug_ind=1)
    CALL echo(build("********LoadDiscrPrsnl Total Subroutine Time = ",datetimediff(cnvtdatetime(
        curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadacknowledgments(null)
   CALL echo("LoadAcknowledgments")
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   DECLARE ack_cnt = i4 WITH noconstant(0)
   IF (debug_ind=1)
    SET querytime = cnvtdatetime(curdate,curtime3)
   ENDIF
   SELECT INTO "nl:"
    FROM clinical_event ce,
     ce_result_set_link rsl,
     ce_result_set_link rsl2,
     (dummyt dorders  WITH seq = value(size(mar_detail_reply->orders,5))),
     (dummyt dadmins  WITH seq = value(max_admin_cnt))
    PLAN (dorders)
     JOIN (dadmins
     WHERE dadmins.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].administrations,5)))
     JOIN (rsl
     WHERE (rsl.event_id=mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].event_id)
      AND rsl.entry_type_cd=cmedadmin_cd)
     JOIN (rsl2
     WHERE rsl2.result_set_id=rsl.result_set_id
      AND rsl2.relation_type_cd=cacknowledge_cd)
     JOIN (ce
     WHERE ce.event_id=rsl2.event_id
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadAcknowledgments Query Time = ",datetimediff(cnvtdatetime(curdate,
         curtime3),querytime,5)))
     ENDIF
    HEAD dorders.seq
     ack_cnt = 0
    HEAD dadmins.seq
     ack_cnt = 0
    DETAIL
     ack_cnt = (ack_cnt+ 1), debug_param_a_id = rsl.event_id, debug_param_b_id = rsl2.result_set_id,
     debug_param_c_id = ce.clinical_event_id, debug_param_d_id = ack_cnt
     IF (ack_cnt > size(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      acknowledgements,5))
      stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
       acknowledgements,(ack_cnt+ 9))
     ENDIF
     IF (ack_cnt > max_ack_cnt)
      max_ack_cnt = ack_cnt
     ENDIF
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].acknowledgements[ack_cnt].
     event_id = ce.event_id, mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
     acknowledgements[ack_cnt].event_cd = ce.event_cd, mar_detail_reply->orders[dorders.seq].
     administrations[dadmins.seq].acknowledgements[ack_cnt].event_end_dt_tm = ce.event_end_dt_tm,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].acknowledgements[ack_cnt].
     event_end_tz = ce.event_end_tz, mar_detail_reply->orders[dorders.seq].administrations[dadmins
     .seq].acknowledgements[ack_cnt].result_val = ce.result_val, mar_detail_reply->orders[dorders.seq
     ].administrations[dadmins.seq].acknowledgements[ack_cnt].result_units_cd = ce.result_units_cd,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].acknowledgements[ack_cnt].
     result_status_cd = ce.result_status_cd, mar_detail_reply->orders[dorders.seq].administrations[
     dadmins.seq].acknowledgements[ack_cnt].valid_from_dt_tm = ce.valid_from_dt_tm, mar_detail_reply
     ->orders[dorders.seq].administrations[dadmins.seq].acknowledgements[ack_cnt].valid_until_dt_tm
      = ce.valid_until_dt_tm
    FOOT  dadmins.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      acknowledgements,ack_cnt)
    FOOT  dorders.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      acknowledgements,ack_cnt)
    FOOT REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadAcknowledgments Query Total Time = ",datetimediff(cnvtdatetime(
         curdate,curtime3),querytime,5)))
     ENDIF
    WITH nocounter
   ;end select
   CALL displayerrorinfo("LoadAcknowledgments","rsl.event_id","rsl2.result_set_id",
    "ce.clinical_event_id","ack_cnt")
   IF (debug_ind=1)
    CALL echo(build("********LoadAcknowledgments Total Subroutine Time = ",datetimediff(cnvtdatetime(
        curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadacknowlnotes(null)
   CALL echo("LoadAcknowlNotes")
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   DECLARE ack_note_cnt = i4 WITH noconstant(0)
   IF (debug_ind=1)
    SET querytime = cnvtdatetime(curdate,curtime3)
   ENDIF
   SELECT INTO "nl:"
    FROM ce_event_note cen,
     long_blob lb,
     (dummyt dorders  WITH seq = value(size(mar_detail_reply->orders,5))),
     (dummyt dadmins  WITH seq = value(max_admin_cnt)),
     (dummyt dacks  WITH seq = value(max_ack_cnt))
    PLAN (dorders)
     JOIN (dadmins
     WHERE dadmins.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].administrations,5)))
     JOIN (dacks
     WHERE dacks.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].administrations[dadmins
       .seq].acknowledgements,5)))
     JOIN (cen
     WHERE (cen.event_id=mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
     acknowledgements[dacks.seq].event_id))
     JOIN (lb
     WHERE lb.parent_entity_id=cen.ce_event_note_id
      AND lb.parent_entity_name="CE_EVENT_NOTE")
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadAcknowlNotes Query Time = ",datetimediff(cnvtdatetime(curdate,
         curtime3),querytime,5)))
     ENDIF
    HEAD dorders.seq
     ack_note_cnt = 0
    HEAD dadmins.seq
     ack_note_cnt = 0
    HEAD dacks.seq
     ack_note_cnt = 0
    DETAIL
     ack_note_cnt = (ack_note_cnt+ 1), debug_param_a_id = mar_detail_reply->orders[dorders.seq].
     administrations[dadmins.seq].event_id, debug_param_b_id = cen.event_id,
     debug_param_c_id = lb.parent_entity_id, debug_param_d_id = ack_note_cnt
     IF (ack_note_cnt > size(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      acknowledgements[dacks.seq].result_comments,5))
      stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
       acknowledgements[dacks.seq].result_comments,(ack_note_cnt+ 9))
     ENDIF
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].acknowledgements[dacks.seq].
     result_comments[ack_note_cnt].valid_from_dt_tm = cen.valid_from_dt_tm, mar_detail_reply->orders[
     dorders.seq].administrations[dadmins.seq].acknowledgements[dacks.seq].result_comments[
     ack_note_cnt].valid_until_dt_tm = cen.valid_until_dt_tm, mar_detail_reply->orders[dorders.seq].
     administrations[dadmins.seq].acknowledgements[dacks.seq].result_comments[ack_note_cnt].
     note_dt_tm = cen.note_dt_tm,
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].acknowledgements[dacks.seq].
     result_comments[ack_note_cnt].note_tz = cen.note_tz, mar_detail_reply->orders[dorders.seq].
     administrations[dadmins.seq].acknowledgements[dacks.seq].result_comments[ack_note_cnt].
     note_type_cd = cen.note_type_cd, mar_detail_reply->orders[dorders.seq].administrations[dadmins
     .seq].acknowledgements[dacks.seq].result_comments[ack_note_cnt].comment_text = parsecommentlb(
      cen.note_format_cd,cen.compression_cd,lb.long_blob)
    FOOT  dacks.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      acknowledgements[dacks.seq].result_comments,ack_note_cnt)
    FOOT  dadmins.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      acknowledgements[dacks.seq].result_comments,ack_note_cnt)
    FOOT  dorders.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
      acknowledgements[dacks.seq].result_comments,ack_note_cnt)
    FOOT REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadAcknowlNotes Query Total Time = ",datetimediff(cnvtdatetime(
         curdate,curtime3),querytime,5)))
     ENDIF
    WITH nocounter
   ;end select
   CALL displayerrorinfo("LoadAcknowlNotes","ce.event_id","cen.event_id","lb.parent_entity_id",
    "ack_note_cnt")
   IF (debug_ind=1)
    CALL echo(build("********LoadAcknowlNotes Total Subroutine Time = ",datetimediff(cnvtdatetime(
        curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadresponseresults(null)
   CALL echo("LoadResponseResults")
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   DECLARE temp_max_response_cnt = i4 WITH noconstant(0)
   DECLARE response_cnt = i4 WITH noconstant(0)
   DECLARE response_ce_cnt = i4 WITH noconstant(0)
   DECLARE event_idx = i4 WITH noconstant(0)
   FREE RECORD response_list
   RECORD response_list(
     1 orders[*]
       2 responseresults[*]
         3 admin_parent_event_id = f8
         3 order_idx = i4
         3 result_idx = i4
         3 admin_core_action_seq = i4
         3 response_events[*]
           4 event_id = f8
           4 search_for_child_ind = i2
   )
   SET stat = alterlist(response_list->orders,size(mar_detail_reply->orders,5))
   IF (debug_ind=1)
    SET querytime = cnvtdatetime(curdate,curtime3)
   ENDIF
   SELECT INTO "nl:"
    FROM dcp_forms_activity_comp dfac,
     dcp_forms_activity_comp parent_dfac,
     (dummyt dorders  WITH seq = value(size(mar_detail_reply->orders,5))),
     (dummyt dadmins  WITH seq = value(max_admin_cnt))
    PLAN (dorders)
     JOIN (dadmins
     WHERE dadmins.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].administrations,5)))
     JOIN (dfac
     WHERE (dfac.parent_entity_id=mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].
     event_id)
      AND dfac.parent_entity_name="CLINICAL_EVENT")
     JOIN (parent_dfac
     WHERE parent_dfac.dcp_forms_activity_id=dfac.dcp_forms_activity_id
      AND parent_dfac.component_cd=cclincalevent)
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadResponseResults Query #1 Time = ",datetimediff(cnvtdatetime(
         curdate,curtime3),querytime,5)))
     ENDIF
    HEAD dorders.seq
     response_cnt = 0
    HEAD parent_dfac.dcp_forms_activity_id
     response_cnt = (response_cnt+ 1), debug_param_a_id = mar_detail_reply->orders[dorders.seq].
     administrations[dadmins.seq].order_id, debug_param_b_id = dfac.parent_entity_id,
     debug_param_c_id = parent_dfac.dcp_forms_activity_id, debug_param_d_id = response_cnt
     IF (response_cnt > size(response_list->orders[dorders.seq].responseresults,5))
      stat = alterlist(response_list->orders[dorders.seq].responseresults,(response_cnt+ 9)), stat =
      alterlist(mar_detail_reply->orders[dorders.seq].responseresults,(response_cnt+ 9))
     ENDIF
     IF (response_cnt > temp_max_response_cnt)
      temp_max_response_cnt = response_cnt
     ENDIF
     response_list->orders[dorders.seq].responseresults[response_cnt].admin_parent_event_id =
     mar_detail_reply->orders[dorders.seq].administrations[dadmins.seq].event_id, response_list->
     orders[dorders.seq].responseresults[response_cnt].admin_core_action_seq = mar_detail_reply->
     orders[dorders.seq].administrations[dadmins.seq].core_action_sequence, response_list->orders[
     dorders.seq].responseresults[response_cnt].order_idx = dorders.seq,
     response_list->orders[dorders.seq].responseresults[response_cnt].result_idx = dadmins.seq, stat
      = alterlist(response_list->orders[dorders.seq].responseresults[response_cnt].response_events,1),
     response_list->orders[dorders.seq].responseresults[response_cnt].response_events[1].event_id =
     parent_dfac.parent_entity_id,
     response_list->orders[dorders.seq].responseresults[response_cnt].response_events[1].
     search_for_child_ind = 1
    FOOT  dorders.seq
     stat = alterlist(response_list->orders[dorders.seq].responseresults,response_cnt), stat =
     alterlist(mar_detail_reply->orders[dorders.seq].responseresults,response_cnt)
    FOOT REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadResponseResults Query #1 Total Time = ",datetimediff(cnvtdatetime(
         curdate,curtime3),querytime,5)))
     ENDIF
    WITH nocounter
   ;end select
   CALL displayerrorinfo("LoadResponseResults Query 1","ce.order_id","dfac.parent_entity_id",
    "parent_dfac.dcp_forms_activity_id","response_cnt")
   IF (temp_max_response_cnt > 0)
    DECLARE continue_lookup = i2 WITH protect, noconstant(1)
    DECLARE temp_max_response_ce_cnt = i2 WITH protect, noconstant(1)
    DECLARE response_action_cnt = i2 WITH protect, noconstant(0)
    DECLARE iterator = i4 WITH protect, noconstant(0)
    DECLARE loopquerytime = f8 WITH protect, noconstant(0)
    IF (debug_ind=1)
     SET querytime = cnvtdatetime(curdate,curtime3)
    ENDIF
    WHILE (continue_lookup)
      SET continue_lookup = 0
      IF (debug_ind=1)
       SET loopquerytime = cnvtdatetime(curdate,curtime3)
      ENDIF
      SELECT INTO "nl:"
       FROM clinical_event ce,
        (dummyt dorders  WITH seq = value(size(response_list->orders,5))),
        (dummyt drespons  WITH seq = value(temp_max_response_cnt)),
        (dummyt dresponseevents  WITH seq = value(temp_max_response_ce_cnt))
       PLAN (dorders)
        JOIN (drespons
        WHERE drespons.seq <= cnvtint(size(response_list->orders[dorders.seq].responseresults,5)))
        JOIN (dresponseevents
        WHERE dresponseevents.seq <= cnvtint(size(response_list->orders[dorders.seq].responseresults[
          drespons.seq].response_events,5)))
        JOIN (ce
        WHERE (response_list->orders[dorders.seq].responseresults[drespons.seq].response_events[
        dresponseevents.seq].search_for_child_ind=1)
         AND (ce.parent_event_id=response_list->orders[dorders.seq].responseresults[drespons.seq].
        response_events[dresponseevents.seq].event_id))
       ORDER BY ce.parent_event_id, ce.event_id, ce.valid_until_dt_tm DESC
       HEAD REPORT
        IF (debug_ind=1)
         CALL echo(build("********LoadResponseResults Query #2 Loop Query Time = ",datetimediff(
           cnvtdatetime(curdate,curtime3),loopquerytime,5)))
        ENDIF
       HEAD dorders.seq
        response_ce_cnt = 0
       HEAD drespons.seq
        response_ce_cnt = 0
       HEAD ce.event_id
        debug_param_a_id = ce.order_id, debug_param_b_id = ce.clinical_event_id, debug_param_c_id =
        ce.event_id,
        response_ce_cnt = size(response_list->orders[dorders.seq].responseresults[drespons.seq].
         response_events,5), debug_param_d_id = response_ce_cnt, event_idx = locateval(iterator,1,
         response_ce_cnt,ce.event_id,response_list->orders[dorders.seq].responseresults[drespons.seq]
         .response_events[iterator].event_id)
        IF (event_idx <= 0)
         response_ce_cnt = (response_ce_cnt+ 1)
         IF (response_ce_cnt > temp_max_response_ce_cnt)
          temp_max_response_ce_cnt = response_ce_cnt
         ENDIF
         stat = alterlist(response_list->orders[dorders.seq].responseresults[drespons.seq].
          response_events,response_ce_cnt), response_list->orders[dorders.seq].responseresults[
         drespons.seq].response_events[response_ce_cnt].event_id = ce.event_id, response_list->
         orders[dorders.seq].responseresults[drespons.seq].response_events[response_ce_cnt].
         search_for_child_ind = 1,
         continue_lookup = 1
        ELSE
         response_list->orders[dorders.seq].responseresults[drespons.seq].response_events[event_idx].
         search_for_child_ind = 0
        ENDIF
       FOOT REPORT
        IF (debug_ind=1)
         CALL echo(build("********LoadResponseResults Query #2 Loop Total Time = ",datetimediff(
           cnvtdatetime(curdate,curtime3),loopquerytime,5)))
        ENDIF
       WITH nocounter
      ;end select
      CALL displayerrorinfo("LoadResponseResults Query 2","ce.order_id","ce.clinical_event_id",
       "ce.event_id","response_ce_cnt")
    ENDWHILE
    IF (debug_ind=1)
     CALL echo(build("********LoadResponseResults Query #2 Total Time = ",datetimediff(cnvtdatetime(
         curdate,curtime3),querytime,5)))
    ENDIF
    IF (debug_ind=1)
     SET querytime = cnvtdatetime(curdate,curtime3)
    ENDIF
    SELECT INTO "nl:"
     FROM clinical_event ce,
      (dummyt dorders  WITH seq = value(size(response_list->orders,5))),
      (dummyt drespons  WITH seq = value(temp_max_response_cnt)),
      (dummyt dresponseevents  WITH seq = value(temp_max_response_ce_cnt))
     PLAN (dorders)
      JOIN (drespons
      WHERE drespons.seq <= cnvtint(size(response_list->orders[dorders.seq].responseresults,5)))
      JOIN (dresponseevents
      WHERE dresponseevents.seq <= cnvtint(size(response_list->orders[dorders.seq].responseresults[
        drespons.seq].response_events,5)))
      JOIN (ce
      WHERE (ce.event_id=response_list->orders[dorders.seq].responseresults[drespons.seq].
      response_events[dresponseevents.seq].event_id))
     ORDER BY ce.valid_from_dt_tm, ce.parent_event_id, ce.event_id
     HEAD REPORT
      IF (debug_ind=1)
       CALL echo(build("********LoadResponseResults Query #3 Time = ",datetimediff(cnvtdatetime(
          curdate,curtime3),querytime,5)))
      ENDIF
     HEAD dorders.seq
      response_action_cnt = 0, response_ce_cnt = 0
     HEAD drespons.seq
      response_action_cnt = size(mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
       response_actions,5), response_ce_cnt = 0, debug_param_a_id = ce.clinical_event_id,
      debug_param_b_id = drespons.seq
      IF (drespons.seq > max_response_cnt)
       max_response_cnt = drespons.seq
      ENDIF
      mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].admin_parent_event_id =
      response_list->orders[dorders.seq].responseresults[drespons.seq].admin_parent_event_id,
      mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].admin_core_action_seq =
      response_list->orders[dorders.seq].responseresults[drespons.seq].admin_core_action_seq
     HEAD ce.valid_from_dt_tm
      response_action_cnt = (response_action_cnt+ 1), response_ce_cnt = 0, debug_param_c_id =
      response_action_cnt
      IF (response_action_cnt > max_resp_action_cnt)
       max_resp_action_cnt = response_action_cnt
      ENDIF
      IF (response_action_cnt > size(mar_detail_reply->orders[dorders.seq].responseresults[drespons
       .seq].response_actions,5))
       stat = alterlist(mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
        response_actions,(response_action_cnt+ 9))
      ENDIF
     DETAIL
      response_ce_cnt = (response_ce_cnt+ 1), debug_param_d_id = response_ce_cnt
      IF (response_ce_cnt > size(mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
       response_actions[response_action_cnt].events,5))
       stat = alterlist(mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
        response_actions[response_action_cnt].events,(response_ce_cnt+ 9))
      ENDIF
      IF (response_ce_cnt > max_resp_ce_cnt)
       max_resp_ce_cnt = response_ce_cnt
      ENDIF
      mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[
      response_action_cnt].events[response_ce_cnt].event_end_dt_tm = ce.event_end_dt_tm,
      mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[
      response_action_cnt].events[response_ce_cnt].event_end_tz = ce.event_end_tz, mar_detail_reply->
      orders[dorders.seq].responseresults[drespons.seq].response_actions[response_action_cnt].events[
      response_ce_cnt].performed_dt_tm = ce.performed_dt_tm,
      mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[
      response_action_cnt].events[response_ce_cnt].performed_tz = ce.performed_tz, mar_detail_reply->
      orders[dorders.seq].responseresults[drespons.seq].response_actions[response_action_cnt].events[
      response_ce_cnt].event_id = ce.event_id, mar_detail_reply->orders[dorders.seq].responseresults[
      drespons.seq].response_actions[response_action_cnt].events[response_ce_cnt].parent_event_id =
      ce.parent_event_id,
      mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[
      response_action_cnt].events[response_ce_cnt].event_class_cd = ce.event_class_cd,
      mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[
      response_action_cnt].events[response_ce_cnt].event_cd = ce.event_cd, mar_detail_reply->orders[
      dorders.seq].responseresults[drespons.seq].response_actions[response_action_cnt].events[
      response_ce_cnt].event_tag = ce.event_tag,
      mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[
      response_action_cnt].events[response_ce_cnt].result_val = ce.result_val, mar_detail_reply->
      orders[dorders.seq].responseresults[drespons.seq].response_actions[response_action_cnt].events[
      response_ce_cnt].result_unit_cd = ce.result_units_cd, mar_detail_reply->orders[dorders.seq].
      responseresults[drespons.seq].response_actions[response_action_cnt].events[response_ce_cnt].
      task_assay_cd = ce.task_assay_cd,
      mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[
      response_action_cnt].events[response_ce_cnt].result_status_cd = ce.result_status_cd,
      mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[
      response_action_cnt].events[response_ce_cnt].normalcy_cd = ce.normalcy_cd, mar_detail_reply->
      orders[dorders.seq].responseresults[drespons.seq].response_actions[response_action_cnt].events[
      response_ce_cnt].normal_low = ce.normal_low,
      mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[
      response_action_cnt].events[response_ce_cnt].normal_high = ce.normal_high, mar_detail_reply->
      orders[dorders.seq].responseresults[drespons.seq].response_actions[response_action_cnt].events[
      response_ce_cnt].critical_low = ce.critical_low, mar_detail_reply->orders[dorders.seq].
      responseresults[drespons.seq].response_actions[response_action_cnt].events[response_ce_cnt].
      critical_high = ce.critical_high,
      mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[
      response_action_cnt].events[response_ce_cnt].event_title_text = ce.event_title_text,
      mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[
      response_action_cnt].events[response_ce_cnt].valid_from_dt_tm = ce.valid_from_dt_tm,
      mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[
      response_action_cnt].events[response_ce_cnt].valid_until_dt_tm = ce.valid_until_dt_tm,
      mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[
      response_action_cnt].events[response_ce_cnt].order_idx = response_list->orders[dorders.seq].
      responseresults[drespons.seq].order_idx, mar_detail_reply->orders[dorders.seq].responseresults[
      drespons.seq].response_actions[response_action_cnt].events[response_ce_cnt].result_idx =
      response_list->orders[dorders.seq].responseresults[drespons.seq].result_idx
     FOOT  ce.valid_from_dt_tm
      stat = alterlist(mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
       response_actions[response_action_cnt].events,response_ce_cnt)
     FOOT  drespons.seq
      stat = alterlist(mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
       response_actions,response_action_cnt)
     FOOT  dorders.seq
      response_action_cnt = 0
     FOOT REPORT
      IF (debug_ind=1)
       CALL echo(build("********LoadResponseResults Query #3 Total Time = ",datetimediff(cnvtdatetime
         (curdate,curtime3),querytime,5)))
      ENDIF
     WITH nocounter
    ;end select
    CALL displayerrorinfo("LoadResponseResults Query 3","ce.clinical_event_id","dRespons.seq",
     "response_action_cnt","response_ce_cnt")
    IF (debug_ind=1)
     SET querytime = cnvtdatetime(curdate,curtime3)
    ENDIF
    SELECT INTO "nl:"
     FROM ce_date_result cdr,
      (dummyt dorders  WITH seq = value(size(mar_detail_reply->orders,5))),
      (dummyt drespons  WITH seq = value(max_response_cnt)),
      (dummyt dractions  WITH seq = value(max_resp_action_cnt)),
      (dummyt drevents  WITH seq = value(max_resp_ce_cnt))
     PLAN (dorders)
      JOIN (drespons
      WHERE drespons.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].responseresults,5)))
      JOIN (dractions
      WHERE dractions.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].responseresults[
        drespons.seq].response_actions,5)))
      JOIN (drevents
      WHERE drevents.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].responseresults[
        drespons.seq].response_actions[dractions.seq].events,5)))
      JOIN (cdr
      WHERE (mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[
      dractions.seq].events[drevents.seq].event_class_cd=cdate)
       AND (cdr.event_id=mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
      response_actions[dractions.seq].events[drevents.seq].event_id)
       AND cdr.valid_from_dt_tm=cnvtdatetime(mar_detail_reply->orders[dorders.seq].responseresults[
       drespons.seq].response_actions[dractions.seq].events[drevents.seq].valid_from_dt_tm))
     ORDER BY cdr.event_id
     HEAD REPORT
      IF (debug_ind=1)
       CALL echo(build("********LoadResponseResults Query #4 Time = ",datetimediff(cnvtdatetime(
          curdate,curtime3),querytime,5)))
      ENDIF
     DETAIL
      debug_param_a_id = mar_detail_reply->orders[dorders.seq].top_level_order_id, debug_param_b_id
       = cdr.event_id, debug_param_c_id = dractions.seq,
      debug_param_d_id = drevents.seq, mar_detail_reply->orders[dorders.seq].responseresults[drespons
      .seq].response_actions[dractions.seq].events[drevents.seq].event_tag = formatutcdatetime(cdr
       .result_dt_tm,cdr.result_tz,1), mar_detail_reply->orders[dorders.seq].responseresults[drespons
      .seq].response_actions[dractions.seq].events[drevents.seq].result_val = mar_detail_reply->
      orders[dorders.seq].responseresults[drespons.seq].response_actions[dractions.seq].events[
      drevents.seq].event_tag
     FOOT REPORT
      IF (debug_ind=1)
       CALL echo(build("********LoadResponseResults Query #4 Total Time = ",datetimediff(cnvtdatetime
         (curdate,curtime3),querytime,5)))
      ENDIF
     WITH nocounter
    ;end select
    CALL displayerrorinfo("LoadResponseResults Query 4","top_level_order_id","cdr.event_id",
     "dRActions.seq","dREvents.seq")
   ENDIF
   IF (debug_ind=1)
    CALL echo(build("********LoadResponseResults Total Subroutine Time = ",datetimediff(cnvtdatetime(
        curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadresponsecomments(null)
   CALL echo("LoadResponseComments")
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   DECLARE resp_note_cnt = i4 WITH noconstant(0)
   IF (debug_ind=1)
    SET querytime = cnvtdatetime(curdate,curtime3)
   ENDIF
   SELECT INTO "nl:"
    FROM ce_event_note cen,
     long_blob lb,
     prsnl p,
     (dummyt dorders  WITH seq = value(size(mar_detail_reply->orders,5))),
     (dummyt drespons  WITH seq = value(max_response_cnt)),
     (dummyt dractions  WITH seq = value(max_resp_action_cnt)),
     (dummyt drevents  WITH seq = value(max_resp_ce_cnt))
    PLAN (dorders)
     JOIN (drespons
     WHERE drespons.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].responseresults,5)))
     JOIN (dractions
     WHERE dractions.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].responseresults[
       drespons.seq].response_actions,5)))
     JOIN (drevents
     WHERE drevents.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].responseresults[
       drespons.seq].response_actions[dractions.seq].events,5)))
     JOIN (cen
     WHERE (cen.event_id=mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
     response_actions[dractions.seq].events[drevents.seq].event_id)
      AND cen.valid_from_dt_tm=cnvtdatetime(mar_detail_reply->orders[dorders.seq].responseresults[
      drespons.seq].response_actions[dractions.seq].events[drevents.seq].valid_from_dt_tm))
     JOIN (lb
     WHERE lb.parent_entity_id=cen.ce_event_note_id
      AND lb.parent_entity_name="CE_EVENT_NOTE")
     JOIN (p
     WHERE p.person_id=cen.note_prsnl_id)
    ORDER BY cen.event_id, cnvtdatetime(cen.valid_until_dt_tm)
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadResponseComments Query Time = ",datetimediff(cnvtdatetime(curdate,
         curtime3),querytime,5)))
     ENDIF
    HEAD dorders.seq
     resp_note_cnt = 0
    HEAD drespons.seq
     resp_note_cnt = 0
    HEAD dractions.seq
     resp_note_cnt = 0
    HEAD drevents.seq
     resp_note_cnt = 0
    DETAIL
     resp_note_cnt = (resp_note_cnt+ 1), debug_param_a_id = cen.event_id, debug_param_b_id = lb
     .parent_entity_id,
     debug_param_c_id = drevents.seq, debug_param_d_id = resp_note_cnt
     IF (resp_note_cnt > size(mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
      response_actions[dractions.seq].events[drevents.seq].result_comments,5))
      stat = alterlist(mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
       response_actions[dractions.seq].events[drevents.seq].result_comments,(resp_note_cnt+ 9))
     ENDIF
     mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[dractions
     .seq].events[drevents.seq].result_comments[resp_note_cnt].valid_from_dt_tm = cen
     .valid_from_dt_tm, mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
     response_actions[dractions.seq].events[drevents.seq].result_comments[resp_note_cnt].
     valid_until_dt_tm = cen.valid_until_dt_tm, mar_detail_reply->orders[dorders.seq].
     responseresults[drespons.seq].response_actions[dractions.seq].events[drevents.seq].
     result_comments[resp_note_cnt].note_prsnl_id = cen.note_prsnl_id,
     mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[dractions
     .seq].events[drevents.seq].result_comments[resp_note_cnt].note_dt_tm = cen.note_dt_tm,
     mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[dractions
     .seq].events[drevents.seq].result_comments[resp_note_cnt].note_tz = cen.note_tz,
     mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[dractions
     .seq].events[drevents.seq].result_comments[resp_note_cnt].note_type_cd = cen.note_type_cd,
     mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[dractions
     .seq].events[drevents.seq].result_comments[resp_note_cnt].event_id = cen.event_id,
     mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[dractions
     .seq].events[drevents.seq].result_comments[resp_note_cnt].note_prsnl_name = p
     .name_full_formatted, mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
     response_actions[dractions.seq].events[drevents.seq].result_comments[resp_note_cnt].comment_text
      = parsecommentlb(cen.note_format_cd,cen.compression_cd,lb.long_blob)
    FOOT  drevents.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
      response_actions[dractions.seq].events[drevents.seq].result_comments,resp_note_cnt)
    FOOT  dractions.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
      response_actions[dractions.seq].events[drevents.seq].result_comments,resp_note_cnt)
    FOOT  drespons.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
      response_actions[dractions.seq].events[drevents.seq].result_comments,resp_note_cnt)
    FOOT  dorders.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
      response_actions[dractions.seq].events[drevents.seq].result_comments,resp_note_cnt)
    FOOT REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadResponseComments Query Total Time = ",datetimediff(cnvtdatetime(
         curdate,curtime3),querytime,5)))
     ENDIF
    WITH nocounter
   ;end select
   CALL displayerrorinfo("LoadResponseComments","cen.event_id","lb.parent_entity_id","dREvents.seq",
    "resp_note_cnt")
   IF (debug_ind=1)
    CALL echo(build("********LoadResponseComments Total Subroutine Time = ",datetimediff(cnvtdatetime
       (curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadresponseprsnl(null)
   CALL echo("LoadResponsePrsnl")
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   DECLARE res_prnl_cnt = i4 WITH noconstant(0)
   IF (debug_ind=1)
    SET querytime = cnvtdatetime(curdate,curtime3)
   ENDIF
   SELECT INTO "nl:"
    FROM ce_event_prsnl cep,
     prsnl p_action,
     prsnl p_proxy,
     prsnl p_request,
     (dummyt dorders  WITH seq = value(size(mar_detail_reply->orders,5))),
     (dummyt drespons  WITH seq = value(max_response_cnt)),
     (dummyt dractions  WITH seq = value(max_resp_action_cnt)),
     (dummyt drevents  WITH seq = value(max_resp_ce_cnt))
    PLAN (dorders)
     JOIN (drespons
     WHERE drespons.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].responseresults,5)))
     JOIN (dractions
     WHERE dractions.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].responseresults[
       drespons.seq].response_actions,5)))
     JOIN (drevents
     WHERE drevents.seq <= cnvtint(size(mar_detail_reply->orders[dorders.seq].responseresults[
       drespons.seq].response_actions[dractions.seq].events,5)))
     JOIN (cep
     WHERE (cep.event_id=mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
     response_actions[dractions.seq].events[drevents.seq].event_id)
      AND cep.valid_from_dt_tm=cnvtdatetime(mar_detail_reply->orders[dorders.seq].responseresults[
      drespons.seq].response_actions[dractions.seq].events[drevents.seq].valid_from_dt_tm))
     JOIN (p_action
     WHERE p_action.person_id=cep.action_prsnl_id)
     JOIN (p_proxy
     WHERE p_proxy.person_id=cep.proxy_prsnl_id)
     JOIN (p_request
     WHERE p_request.person_id=cep.request_prsnl_id)
    HEAD REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadResponsePrsnl Query Time = ",datetimediff(cnvtdatetime(curdate,
         curtime3),querytime,5)))
     ENDIF
    HEAD dorders.seq
     res_prnl_cnt = 0
    HEAD drespons.seq
     res_prnl_cnt = 0
    HEAD dractions.seq
     res_prnl_cnt = 0
    HEAD drevents.seq
     res_prnl_cnt = 0
    DETAIL
     res_prnl_cnt = (res_prnl_cnt+ 1), debug_param_a_id = cep.event_id, debug_param_b_id = p_action
     .person_id,
     debug_param_c_id = drevents.seq, debug_param_d_id = res_prnl_cnt
     IF (res_prnl_cnt > size(mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
      response_actions[dractions.seq].events[drevents.seq].event_prsnl_actions,5))
      stat = alterlist(mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
       response_actions[dractions.seq].events[drevents.seq].event_prsnl_actions,(res_prnl_cnt+ 9))
     ENDIF
     mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[dractions
     .seq].events[drevents.seq].event_prsnl_actions[res_prnl_cnt].valid_until_dt_tm = cep
     .valid_until_dt_tm, mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
     response_actions[dractions.seq].events[drevents.seq].event_prsnl_actions[res_prnl_cnt].
     valid_from_dt_tm = cep.valid_from_dt_tm, mar_detail_reply->orders[dorders.seq].responseresults[
     drespons.seq].response_actions[dractions.seq].events[drevents.seq].event_prsnl_actions[
     res_prnl_cnt].action_prsnl_id = cep.action_prsnl_id,
     mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[dractions
     .seq].events[drevents.seq].event_prsnl_actions[res_prnl_cnt].action_type_cd = cep.action_type_cd,
     mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[dractions
     .seq].events[drevents.seq].event_prsnl_actions[res_prnl_cnt].action_status_cd = cep
     .action_status_cd, mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
     response_actions[dractions.seq].events[drevents.seq].event_prsnl_actions[res_prnl_cnt].
     action_dt_tm = cep.action_dt_tm,
     mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[dractions
     .seq].events[drevents.seq].event_prsnl_actions[res_prnl_cnt].action_tz = cep.action_tz,
     mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[dractions
     .seq].events[drevents.seq].event_prsnl_actions[res_prnl_cnt].action_comment = cep.action_comment,
     mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[dractions
     .seq].events[drevents.seq].event_prsnl_actions[res_prnl_cnt].request_prsnl_id = cep
     .request_prsnl_id,
     mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[dractions
     .seq].events[drevents.seq].event_prsnl_actions[res_prnl_cnt].request_dt_tm = cep.request_dt_tm,
     mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[dractions
     .seq].events[drevents.seq].event_prsnl_actions[res_prnl_cnt].request_tz = cep.request_tz,
     mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[dractions
     .seq].events[drevents.seq].event_prsnl_actions[res_prnl_cnt].proxy_prsnl_id = cep.proxy_prsnl_id,
     mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[dractions
     .seq].events[drevents.seq].event_prsnl_actions[res_prnl_cnt].event_id = cep.event_id,
     mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[dractions
     .seq].events[drevents.seq].event_prsnl_actions[res_prnl_cnt].request_comment = cep
     .request_comment, mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
     response_actions[dractions.seq].events[drevents.seq].event_prsnl_actions[res_prnl_cnt].
     action_prsnl_name = p_action.name_full_formatted,
     mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].response_actions[dractions
     .seq].events[drevents.seq].event_prsnl_actions[res_prnl_cnt].request_prsnl_name = p_request
     .name_full_formatted, mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
     response_actions[dractions.seq].events[drevents.seq].event_prsnl_actions[res_prnl_cnt].
     proxy_prsnl_name = p_proxy.name_full_formatted
    FOOT  drevents.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
      response_actions[dractions.seq].events[drevents.seq].event_prsnl_actions,res_prnl_cnt)
    FOOT  dractions.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
      response_actions[dractions.seq].events[drevents.seq].event_prsnl_actions,res_prnl_cnt)
    FOOT  drespons.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
      response_actions[dractions.seq].events[drevents.seq].event_prsnl_actions,res_prnl_cnt)
    FOOT  dorders.seq
     stat = alterlist(mar_detail_reply->orders[dorders.seq].responseresults[drespons.seq].
      response_actions[dractions.seq].events[drevents.seq].event_prsnl_actions,res_prnl_cnt)
    FOOT REPORT
     IF (debug_ind=1)
      CALL echo(build("********LoadResponsePrsnl Query Total Time = ",datetimediff(cnvtdatetime(
         curdate,curtime3),querytime,5)))
     ENDIF
    WITH nocounter
   ;end select
   CALL displayerrorinfo("LoadResponsePrsnl","cep.event_id","p_action.person_id","dREvents.seq",
    "res_prnl_cnt")
   IF (debug_ind=1)
    CALL echo(build("********LoadResponsePrsnl Total Subroutine Time = ",datetimediff(cnvtdatetime(
        curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadtasks(null)
   DECLARE cpendingtaskcd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"PENDING"))
   DECLARE coverduetaskcd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"OVERDUE"))
   DECLARE cinprocesstaskcd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"INPROCESS"))
   DECLARE cpendingvaltaskcd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"VALIDATION"))
   DECLARE cprncd = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"PRN"))
   DECLARE ccontinuouscd = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"CONT"))
   DECLARE cnonscheduledcd = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"NSCH"))
   DECLARE cpendingcd = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"PENDING"))
   DECLARE itaskseq = i2 WITH protect, noconstant(0)
   DECLARE taskcnt = i2 WITH protect, noconstant(0)
   DECLARE cinfusebilltypecd = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,"INFUSEBILL")
    )
   DECLARE cendbagtasktypedcd = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,"IVENDBAG"))
   DECLARE iordercnt = i4 WITH protect, noconstant(size(mar_detail_reply->orders,5))
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   IF ((mar_detail_request->scope_flag=5))
    SELECT INTO "nl:"
     FROM task_activity ta,
      orders o,
      order_task ot,
      (dummyt d  WITH seq = value(size(mar_detail_request->encntr_list,5)))
     PLAN (d)
      JOIN (ta
      WHERE (ta.person_id=mar_detail_request->person_id)
       AND (ta.encntr_id=mar_detail_request->encntr_list[d.seq].encntr_id)
       AND ta.task_status_cd IN (cpendingtaskcd, coverduetaskcd)
       AND ta.task_type_cd != cinfusebilltypecd
       AND ta.task_type_cd != cendbagtasktypedcd)
      JOIN (o
      WHERE o.order_id=ta.order_id
       AND o.catalog_type_cd=cpharmacy_cd
       AND o.orig_ord_as_flag IN (0, 5))
      JOIN (ot
      WHERE ta.reference_task_id=ot.reference_task_id)
     ORDER BY o.template_order_id, o.order_id, ta.task_id
     HEAD o.template_order_id
      IF (o.template_order_id > 0)
       idx = locateval(itaskseq,1,iordercnt,o.template_order_id,mar_detail_reply->orders[itaskseq].
        top_level_order_id), taskcnt = 0
      ENDIF
     HEAD o.order_id
      debug_order_id = o.order_id
      IF (o.template_order_id=0)
       idx = locateval(itaskseq,1,iordercnt,o.order_id,mar_detail_reply->orders[itaskseq].
        top_level_order_id), taskcnt = 0
      ENDIF
     DETAIL
      IF (((ta.task_class_cd IN (cprncd, ccontinuouscd, cnonscheduledcd)) OR ((ta.task_dt_tm >=
      mar_detail_request->task_start_dt_tm)
       AND (ta.task_dt_tm <= mar_detail_request->task_end_dt_tm)))
       AND uar_get_code_meaning(ta.task_type_cd) != "CLINPHARM")
       taskcnt = (taskcnt+ 1)
       IF (mod(taskcnt,10)=1)
        stat = alterlist(mar_detail_reply->orders[idx].tasks,(taskcnt+ 9))
       ENDIF
       mar_detail_reply->orders[idx].tasks[taskcnt].task_id = ta.task_id, mar_detail_reply->orders[
       idx].tasks[taskcnt].order_id = ta.order_id, mar_detail_reply->orders[idx].tasks[taskcnt].
       task_status_cd = ta.task_status_cd,
       mar_detail_reply->orders[idx].tasks[taskcnt].task_class_cd = ta.task_class_cd,
       mar_detail_reply->orders[idx].tasks[taskcnt].task_activity_cd = ta.task_activity_cd,
       mar_detail_reply->orders[idx].tasks[taskcnt].careset_id = ta.careset_id,
       mar_detail_reply->orders[idx].tasks[taskcnt].iv_ind = ta.iv_ind, mar_detail_reply->orders[idx]
       .tasks[taskcnt].tpn_ind = ta.tpn_ind, mar_detail_reply->orders[idx].tasks[taskcnt].task_dt_tm
        = ta.task_dt_tm,
       mar_detail_reply->orders[idx].tasks[taskcnt].dcp_forms_ref_id = ot.dcp_forms_ref_id
       IF (ta.task_class_cd IN (cprncd, ccontinuouscd, cnonscheduledcd)
        AND ta.task_status_cd=cpendingcd)
        IF (cnvtdatetime(curdate,curtime) > cnvtdatetime(ta.task_dt_tm))
         mar_detail_reply->orders[idx].tasks[taskcnt].task_dt_tm = cnvtdatetime(curdate,curtime)
        ENDIF
       ENDIF
       mar_detail_reply->orders[idx].tasks[taskcnt].updt_cnt = ta.updt_cnt, mar_detail_reply->orders[
       idx].tasks[taskcnt].event_id = ta.event_id, mar_detail_reply->orders[idx].tasks[taskcnt].
       reference_task_id = ta.reference_task_id,
       mar_detail_reply->orders[idx].tasks[taskcnt].task_type_cd = ta.task_type_cd, mar_detail_reply
       ->orders[idx].tasks[taskcnt].description = ot.task_description, mar_detail_reply->orders[idx].
       tasks[taskcnt].chart_not_done_ind = ot.chart_not_cmplt_ind,
       mar_detail_reply->orders[idx].tasks[taskcnt].quick_chart_ind = ot.quick_chart_ind,
       mar_detail_reply->orders[idx].tasks[taskcnt].event_cd = ot.event_cd, mar_detail_reply->orders[
       idx].tasks[taskcnt].reschedule_time = ot.reschedule_time,
       mar_detail_reply->orders[idx].tasks[taskcnt].task_priority_cd = ta.task_priority_cd,
       mar_detail_reply->orders[idx].tasks[taskcnt].task_tz = ta.task_tz
      ENDIF
     FOOT  o.order_id
      IF (o.template_order_id=0.0)
       stat = alterlist(mar_detail_reply->orders[idx].tasks,taskcnt)
      ENDIF
     FOOT  o.template_order_id
      IF (o.template_order_id > 0)
       stat = alterlist(mar_detail_reply->orders[idx].tasks,taskcnt)
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM task_activity ta,
      orders o,
      order_task ot
     PLAN (ta
      WHERE (ta.person_id=mar_detail_request->person_id)
       AND (ta.encntr_id=mar_detail_request->encntr_id)
       AND ta.task_status_cd IN (cpendingtaskcd, coverduetaskcd)
       AND ta.task_type_cd != cinfusebilltypecd
       AND ta.task_type_cd != cendbagtasktypedcd)
      JOIN (o
      WHERE o.order_id=ta.order_id
       AND o.catalog_type_cd=cpharmacy_cd
       AND o.orig_ord_as_flag IN (0, 5))
      JOIN (ot
      WHERE ta.reference_task_id=ot.reference_task_id)
     ORDER BY o.template_order_id, o.order_id, ta.task_id
     HEAD o.template_order_id
      IF (o.template_order_id > 0)
       idx = locateval(itaskseq,1,iordercnt,o.template_order_id,mar_detail_reply->orders[itaskseq].
        top_level_order_id), taskcnt = 0
      ENDIF
     HEAD o.order_id
      debug_order_id = o.order_id
      IF (o.template_order_id=0)
       idx = locateval(itaskseq,1,iordercnt,o.order_id,mar_detail_reply->orders[itaskseq].
        top_level_order_id), taskcnt = 0
      ENDIF
     DETAIL
      IF (((ta.task_class_cd IN (cprncd, ccontinuouscd, cnonscheduledcd)) OR ((ta.task_dt_tm >=
      mar_detail_request->task_start_dt_tm)
       AND (ta.task_dt_tm <= mar_detail_request->task_end_dt_tm)))
       AND uar_get_code_meaning(ta.task_type_cd) != "CLINPHARM")
       taskcnt = (taskcnt+ 1)
       IF (mod(taskcnt,10)=1)
        stat = alterlist(mar_detail_reply->orders[idx].tasks,(taskcnt+ 9))
       ENDIF
       mar_detail_reply->orders[idx].tasks[taskcnt].task_id = ta.task_id, mar_detail_reply->orders[
       idx].tasks[taskcnt].order_id = ta.order_id, mar_detail_reply->orders[idx].tasks[taskcnt].
       task_status_cd = ta.task_status_cd,
       mar_detail_reply->orders[idx].tasks[taskcnt].task_class_cd = ta.task_class_cd,
       mar_detail_reply->orders[idx].tasks[taskcnt].task_activity_cd = ta.task_activity_cd,
       mar_detail_reply->orders[idx].tasks[taskcnt].careset_id = ta.careset_id,
       mar_detail_reply->orders[idx].tasks[taskcnt].iv_ind = ta.iv_ind, mar_detail_reply->orders[idx]
       .tasks[taskcnt].tpn_ind = ta.tpn_ind, mar_detail_reply->orders[idx].tasks[taskcnt].task_dt_tm
        = ta.task_dt_tm,
       mar_detail_reply->orders[idx].tasks[taskcnt].dcp_forms_ref_id = ot.dcp_forms_ref_id
       IF (ta.task_class_cd IN (cprncd, ccontinuouscd, cnonscheduledcd)
        AND ta.task_status_cd=cpendingcd)
        IF (cnvtdatetime(curdate,curtime) > cnvtdatetime(ta.task_dt_tm))
         mar_detail_reply->orders[idx].tasks[taskcnt].task_dt_tm = cnvtdatetime(curdate,curtime)
        ENDIF
       ENDIF
       mar_detail_reply->orders[idx].tasks[taskcnt].updt_cnt = ta.updt_cnt, mar_detail_reply->orders[
       idx].tasks[taskcnt].event_id = ta.event_id, mar_detail_reply->orders[idx].tasks[taskcnt].
       reference_task_id = ta.reference_task_id,
       mar_detail_reply->orders[idx].tasks[taskcnt].task_type_cd = ta.task_type_cd, mar_detail_reply
       ->orders[idx].tasks[taskcnt].description = ot.task_description, mar_detail_reply->orders[idx].
       tasks[taskcnt].chart_not_done_ind = ot.chart_not_cmplt_ind,
       mar_detail_reply->orders[idx].tasks[taskcnt].quick_chart_ind = ot.quick_chart_ind,
       mar_detail_reply->orders[idx].tasks[taskcnt].event_cd = ot.event_cd, mar_detail_reply->orders[
       idx].tasks[taskcnt].reschedule_time = ot.reschedule_time,
       mar_detail_reply->orders[idx].tasks[taskcnt].task_priority_cd = ta.task_priority_cd,
       mar_detail_reply->orders[idx].tasks[taskcnt].task_tz = ta.task_tz
      ENDIF
     FOOT  o.order_id
      IF (o.template_order_id=0.0)
       stat = alterlist(mar_detail_reply->orders[idx].tasks,taskcnt)
      ENDIF
     FOOT  o.template_order_id
      IF (o.template_order_id > 0)
       stat = alterlist(mar_detail_reply->orders[idx].tasks,taskcnt)
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   CALL displayerrorinfo("LoadTasks","ta.order_id","ot.reference_task_id","dOrders.seq","task_cnt")
   IF (debug_ind=1)
    CALL echo(build("********LoadTasks Total Subroutine Time = ",datetimediff(cnvtdatetime(curdate,
        curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE loadprsnlinfo(null)
   CALL echo("LoadPrsnlInfo")
   IF (debug_ind=1)
    DECLARE totalprsnlinfoscripttime = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
   ENDIF
   CALL processreply(null)
   CALL getprsnl(null)
   CALL processprsnl(null)
   IF (debug_ind=1)
    CALL echo(build("********LoadPrsnlInfo Total Subroutine Time = ",datetimediff(cnvtdatetime(
        curdate,curtime3),totalprsnlinfoscripttime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE mapneedrxclinreviewflag(null)
   CALL echo("MapNeedRxClinReviewFlag")
   IF (debug_ind=1)
    SET subroutinetime = cnvtdatetime(curdate,curtime3)
   ENDIF
   RECORD map_request(
     1 mapping_ind = i2
     1 map_from_value = i2
   )
   RECORD map_reply(
     1 map_to_value = i2
   )
   DECLARE x = i4 WITH noconstant(0), private
   DECLARE y = i4 WITH noconstant(0), private
   FOR (x = 1 TO size(mar_detail_reply->orders,5))
    IF ((mar_detail_reply->orders[x].top_level_need_rx_clin_review_flag=0))
     SET map_request->mapping_ind = 1
     SET map_request->map_from_value = mar_detail_reply->orders[x].top_level_verify_ind
     SET modify = nopredeclare
     EXECUTE dcp_map_clin_review_flag  WITH replace("REQUEST","MAP_REQUEST"), replace("REPLY",
      "MAP_REPLY")
     SET modify = predeclare
     SET mar_detail_reply->orders[x].top_level_need_rx_clin_review_flag = map_reply->map_to_value
    ENDIF
    FOR (y = 1 TO size(mar_detail_reply->orders[x].order_actions,5))
      IF ((mar_detail_reply->orders[x].order_actions[y].need_rx_clin_review_flag=0))
       SET map_request->mapping_ind = 2
       SET map_request->map_from_value = mar_detail_reply->orders[x].order_actions[y].
       needs_verify_ind
       SET modify = nopredeclare
       EXECUTE dcp_map_clin_review_flag  WITH replace("REQUEST","MAP_REQUEST"), replace("REPLY",
        "MAP_REPLY")
       SET modify = predeclare
       SET mar_detail_reply->orders[x].order_actions[y].need_rx_clin_review_flag = map_reply->
       map_to_value
      ENDIF
    ENDFOR
   ENDFOR
   IF (debug_ind=1)
    CALL echo(build("********MapNeedRxClinReviewFlag Total Subroutine Time = ",datetimediff(
       cnvtdatetime(curdate,curtime3),subroutinetime,5)))
   ENDIF
 END ;Subroutine
 SUBROUTINE saveerrordata(error_desc,order_id,event_id)
   CALL echo("SaveErrorData")
   SET error_cnt = (error_cnt+ 1)
   SET stat = alterlist(mar_detail_reply->errors,error_cnt)
   SET mar_detail_reply->errors[error_cnt].error_desc = error_desc
   SET mar_detail_reply->errors[error_cnt].event_id = event_id
   SET mar_detail_reply->errors[error_cnt].order_id = order_id
 END ;Subroutine
 SUBROUTINE parsecommentlb(note_format_cd,compression_cd,long_blob)
   CALL echo("ParseComment")
   DECLARE inbuffer = vc WITH protect, noconstant("")
   DECLARE inbuflen = i4 WITH noconstant(0)
   DECLARE outbuffer = c32000 WITH noconstant("")
   DECLARE outbuflen = i4 WITH noconstant(32000)
   DECLARE retbuflen = i4 WITH noconstant(0)
   DECLARE comment_text = vc WITH protect, noconstant("")
   DECLARE ocf = i2 WITH protect, noconstant(0)
   DECLARE bflag = i4 WITH protect, noconstant(0)
   IF (note_format_cd=crtf)
    IF (compression_cd=ccompressed)
     SET inbuflen = size(long_blob)
     CALL uar_ocf_uncompress(long_blob,inbuflen,outbuffer,30000,outbuflen)
     SET inbuflen = size(outbuffer)
     CALL uar_rtf2(outbuffer,inbuflen,outbuffer,outbuflen,retbuflen,
      bflag)
     SET comment_text = outbuffer
    ELSE
     SET inbuffer = long_blob
     SET inbuflen = size(inbuffer)
     CALL uar_rtf2(inbuffer,inbuflen,outbuffer,outbuflen,retbuflen,
      bflag)
     SET comment_text = outbuffer
    ENDIF
   ELSE
    IF (compression_cd=ccompressed)
     SET inbuflen = size(long_blob)
     CALL uar_ocf_uncompress(long_blob,inbuflen,outbuffer,30000,outbuflen)
     SET inbuflen = size(outbuffer)
     CALL uar_rtf2(outbuffer,inbuflen,outbuffer,outbuflen,retbuflen,
      bflag)
     SET comment_text = outbuffer
    ELSE
     SET comment_text = long_blob
    ENDIF
   ENDIF
   SET ocf = findstring("ocf_blob",comment_text)
   IF (ocf=0)
    SET comment_text = comment_text
   ELSE
    SET comment_text = substring(1,(ocf - 1),comment_text)
   ENDIF
   RETURN(comment_text)
 END ;Subroutine
 SUBROUTINE parseactionseqiv(order_action_sequence,collating_seq)
   CALL echo("ParseActionSeqIV")
   DECLARE lactseq = i4 WITH noconstant(0)
   IF (order_action_sequence > 0)
    SET lactseq = order_action_sequence
   ELSE
    IF (findstring(";",collating_seq,1,1) > 0)
     SET lactseq = cnvtint(substring(1,(findstring(";",collating_seq,1,1) - 1),collating_seq))
    ELSE
     SET lactseq = cnvtint(collating_seq)
    ENDIF
   ENDIF
   RETURN(lactseq)
 END ;Subroutine
 SUBROUTINE displayerrorinfo(subroutinename,parama,paramb,paramc,paramd)
   IF (debug_ind=1)
    SET errcode = error(errmsg,1)
    IF (errcode != 0)
     CALL echo("**************************************************")
     CALL echo(build("SUBROUTINE    : ",subroutinename))
     CALL echo(build("ERROR MESSAGE : ",errmsg))
     IF (parama != "")
      CALL echo(build("***",parama,": ",debug_param_a_id))
     ENDIF
     IF (paramb != "")
      CALL echo(build("***",paramb,": ",debug_param_b_id))
     ENDIF
     IF (paramc != "")
      CALL echo(build("***",paramc,": ",debug_param_c_id))
     ENDIF
     IF (paramd != "")
      CALL echo(build("***",paramd,": ",debug_param_d_id))
     ENDIF
     CALL echo("**************************************************")
    ENDIF
   ENDIF
   SET debug_param_a_id = 0.0
   SET debug_param_b_id = 0.0
   SET debug_param_c_id = 0.0
   SET debug_param_d_id = 0.0
 END ;Subroutine
 SET last_mod = "043 04/18/12"
 IF (debug_ind=1)
  CALL echo(build("DCP_GET_MAR_DETAILS Last Mod: ",last_mod))
 ENDIF
 SET modify = nopredeclare
END GO
