CREATE PROGRAM cmn_get_conman_prefs:dba
 PROMPT
  "output device:  " = "MINE",
  "username:  " = ""
  WITH outdev, username
 RECORD reply(
   1 text = vc
   1 reportname = vc
   1 reportparams = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PUBLIC::appendvalue(valuelist=vc,value=vc) = vc
 DECLARE PUBLIC::showmessage(id_ten_t=vc) = null
 SUBROUTINE PUBLIC::showmessage(id_ten_t)
   SET reply->text = id_ten_t
   SELECT
    x = 0
    FROM dummyt
    DETAIL
     id_ten_t
    WITH nocounter
   ;end select
   CALL echo("")
   CALL echo("*******************************************************************************")
   CALL echo(id_ten_t)
   CALL echo("*******************************************************************************")
   CALL echo("")
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE PUBLIC::appendvalue(valuelist,value)
   IF (textlen(trim(valuelist,3)) > 0)
    RETURN(concat(valuelist,"; ",value))
   ELSE
    RETURN(value)
   ENDIF
 END ;Subroutine
 SET reply->status_data.status = "F"
 IF ((reqinfo->updt_id=0.0))
  CALL showmessage("The CCL session must be authenticated when running this script")
 ENDIF
 DECLARE prsnl_id = f8 WITH protect, noconstant(0.0)
 DECLARE str_prsnl_id = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE p.username=cnvtupper( $USERNAME)
  DETAIL
   prsnl_id = p.person_id
  WITH nocounter
 ;end select
 SET str_prsnl_id = trim(concat(format(prsnl_id,";T(1)"),".00"),3)
 IF (prsnl_id=0.0)
  CALL showmessage("There is no prsnl record for the provided username.")
 ENDIF
 EXECUTE cv_get_prefs_request  WITH replace("REQUEST",pref_req)
 EXECUTE cv_get_prefs_reply  WITH replace("REPLY",pref_rep)
 SET stat = alterlist(pref_req->context,1)
 SET pref_req->context[1].name = "user"
 SET pref_req->context[1].id = str_prsnl_id
 SET pref_req->sectionname = "application"
 SET pref_req->sectionid = "configuration-manager"
 EXECUTE cv_get_prefs  WITH replace("REQUEST",pref_req), replace("REPLY",pref_rep)
 IF ((pref_rep->status_data.status != "S"))
  SET stat = moverec(pref_rep->status_data,reply->status_data)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 DECLARE groupidx = i4 WITH protect, noconstant(0)
 DECLARE entryidx = i4 WITH protect, noconstant(0)
 DECLARE valueidx = i4 WITH protect, noconstant(0)
 FOR (groupidx = 1 TO size(pref_rep->group,5))
   IF (cnvtlower(pref_rep->group[groupidx].groupname)="application/configuration-manager")
    FOR (entryidx = 1 TO size(pref_rep->group[groupidx].entry,5))
      CASE (pref_rep->group[groupidx].entry[entryidx].entryname)
       OF "report-name":
        FOR (valueidx = 1 TO size(pref_rep->group[groupidx].entry[entryidx].values,5))
          SET reply->reportname = appendvalue(reply->reportname,pref_rep->group[groupidx].entry[
           entryidx].values[valueidx].value)
        ENDFOR
       OF "report-params":
        FOR (valueidx = 1 TO size(pref_rep->group[groupidx].entry[entryidx].values,5))
          SET reply->reportparams = appendvalue(reply->reportparams,pref_rep->group[groupidx].entry[
           entryidx].values[valueidx].value)
        ENDFOR
      ENDCASE
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 CALL echorecord(reply)
 IF (validate(_memory_reply_string)=true)
  SET _memory_reply_string = cnvtrectojson(reply)
 ENDIF
END GO
