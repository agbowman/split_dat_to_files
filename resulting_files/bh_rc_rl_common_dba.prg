CREATE PROGRAM bh_rc_rl_common:dba
 CALL echo("***** bh_rc_rl_common.prg - 677918 *****")
 SUBROUTINE (fillerrorcheck(soperation=vc) =i2 WITH copy)
   DECLARE cerrormsg = c255 WITH protect, noconstant("")
   DECLARE lerrorcode = i4 WITH protect, noconstant(0)
   DECLARE ierrchk = i2 WITH noconstant(false)
   SET lerrorcode = error(cerrormsg,0)
   IF (lerrorcode != 0)
    WHILE (lerrorcode != 0)
      SET reply->status_data.subeventstatus[1].operationname = soperation
      SET reply->status_data.subeventstatus[1].targetobjectname = cnvtstring(lerrorcode)
      SET reply->status_data.subeventstatus[1].targetobjectvalue = cerrormsg
      SET reply->status_data.status = "F"
      SET ierrchk = true
      IF ((reqdata->loglevel >= 4))
       CALL echo(cerrormsg)
      ENDIF
      SET lerrorcode = error(cerrormsg,0)
    ENDWHILE
   ENDIF
   RETURN(ierrchk)
 END ;Subroutine
 SUBROUTINE (writetotextfile(slogfile=vc,stext=vc) =i2 WITH copy)
   DECLARE blogging = i2 WITH noconstant(0)
   SELECT INTO value(slogfile)
    d.seq
    FROM dummyt d
    FOOT REPORT
     stext
    WITH nocounter, append, maxrow = 1,
     maxcol = 500, format = variable, formfeed = none
   ;end select
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (addtoreplyshorts(skey=vc,ivalue=i2) =null WITH copy)
   DECLARE laddtoreplycnt = i4 WITH noconstant(0)
   SET laddtoreplycnt = (size(reply->short_results,5)+ 1)
   SET stat = alterlist(reply->short_results,laddtoreplycnt)
   SET reply->short_results[laddtoreplycnt].key_txt = trim(cnvtupper(skey),3)
   SET reply->short_results[laddtoreplycnt].short_value = ivalue
 END ;Subroutine
 SUBROUTINE (addtoreplyintegers(skey=vc,ivalue=i4) =null WITH copy)
   DECLARE laddtoreplycnt = i4 WITH noconstant(0)
   SET laddtoreplycnt = (size(reply->integer_results,5)+ 1)
   SET stat = alterlist(reply->integer_results,laddtoreplycnt)
   SET reply->integer_results[laddtoreplycnt].key_txt = trim(cnvtupper(skey),3)
   SET reply->integer_results[laddtoreplycnt].integer_value = ivalue
 END ;Subroutine
 DECLARE writelogfile(null) = null WITH copy
 SUBROUTINE writelogfile(null)
   DECLARE shnamuser = vc WITH noconstant("")
   DECLARE sfilename = vc WITH noconstant("")
   DECLARE lwritelogcnt = i4 WITH noconstant(0)
   IF (findfile("bh_rule_logging_on.dat")=0)
    RETURN(null)
   ENDIF
   SELECT INTO "nl:"
    p.name_full_formatted
    FROM person p
    WHERE (p.person_id=reqinfo->updt_id)
     AND p.person_id > 0
    DETAIL
     shnamuser = p.name_full_formatted
    WITH nocounter
   ;end select
   SET sfilename = build("bh_rule_logging_",format(sysdate,"ddmmmyyyy;;d"),".log")
   SET sfilename = cnvtlower(build(sfilename))
   SET sfilename = replace(sfilename," ","",0)
   SET sfilename = replace(sfilename,char(0),"",0)
   CALL writetotextfile(sfilename,"--------------------------")
   CALL writetotextfile(sfilename,build("Program:",curprog))
   CALL writetotextfile(sfilename,build("Time:",format(sysdate,"dd-mmm-yyyy hh:mm:ss;;d")))
   CALL writetotextfile(sfilename,build("OS User:",curuser))
   CALL writetotextfile(sfilename,build("Hnam User:",shnamuser))
   CALL writetotextfile(sfilename,build("Node:",curnode))
   CALL writetotextfile(sfilename,build("Domain:",curdomain))
   CALL writetotextfile(sfilename,"+")
   CALL writetotextfile(sfilename,"REQUEST")
   CALL writetotextfile(sfilename,build("request->rca_rule_service_id:",request->rca_rule_service_id)
    )
   IF (size(request->short_params,5) > 0)
    CALL writetotextfile(sfilename,"+")
    CALL writetotextfile(sfilename,"SHORT VALUES:")
    FOR (lwritelogcnt = 1 TO size(request->short_params,5))
      CALL writetotextfile(sfilename,build("_",lwritelogcnt))
      CALL writetotextfile(sfilename,build("__key_txt:",request->short_params[lwritelogcnt].key_txt))
      CALL writetotextfile(sfilename,build("__short_value:",request->short_params[lwritelogcnt].
        short_value))
    ENDFOR
   ENDIF
   IF (size(request->integer_params,5) > 0)
    CALL writetotextfile(sfilename,"+")
    CALL writetotextfile(sfilename,"INTEGER VALUES:")
    FOR (lwritelogcnt = 1 TO size(request->integer_params,5))
      CALL writetotextfile(sfilename,build("_",lwritelogcnt))
      CALL writetotextfile(sfilename,build("__key_txt:",request->integer_params[lwritelogcnt].key_txt
        ))
      CALL writetotextfile(sfilename,build("__integer_value:",request->integer_params[lwritelogcnt].
        integer_value))
    ENDFOR
   ENDIF
   IF (size(request->string_params,5) > 0)
    CALL writetotextfile(sfilename,"+")
    CALL writetotextfile(sfilename,"STRING VALUES:")
    FOR (lwritelogcnt = 1 TO size(request->string_params,5))
      CALL writetotextfile(sfilename,build("_",lwritelogcnt))
      CALL writetotextfile(sfilename,build("__key_txt:",request->string_params[lwritelogcnt].key_txt)
       )
      CALL writetotextfile(sfilename,build("__integer_value:",request->string_params[lwritelogcnt].
        string_value))
    ENDFOR
   ENDIF
   CALL writetotextfile(sfilename,"+")
   CALL writetotextfile(sfilename,"REPLY")
   CALL writetotextfile(sfilename,"+")
   CALL writetotextfile(sfilename,"SHORT VALUES:")
   FOR (lwritelogcnt = 1 TO size(reply->short_results,5))
     CALL writetotextfile(sfilename,build("_",lwritelogcnt))
     CALL writetotextfile(sfilename,build("__key_txt:",reply->short_results[lwritelogcnt].key_txt))
     CALL writetotextfile(sfilename,build("__short_value:",reply->short_results[lwritelogcnt].
       short_value))
   ENDFOR
   CALL writetotextfile(sfilename,"+")
   CALL writetotextfile(sfilename,"INTEGER VALUES:")
   FOR (lwritelogcnt = 1 TO size(reply->integer_results,5))
     CALL writetotextfile(sfilename,build("_",lwritelogcnt))
     CALL writetotextfile(sfilename,build("__key_txt:",reply->integer_results[lwritelogcnt].key_txt))
     CALL writetotextfile(sfilename,build("__short_value:",reply->integer_results[lwritelogcnt].
       integer_value))
   ENDFOR
   CALL writetotextfile(sfilename,"+")
   CALL writetotextfile(sfilename,build("__reply->status_data->status:",reply->status_data.status))
   CALL writetotextfile(sfilename,build("__reply->status_data->subeventstatus[1].operationname:",
     reply->status_data.subeventstatus[1].operationname))
   CALL writetotextfile(sfilename,build("__reply->status_data->subeventstatus[1].targetobjectname:",
     reply->status_data.subeventstatus[1].targetobjectname))
   CALL writetotextfile(sfilename,build("__reply->status_data->subeventstatus[1].targetobjectvalue:",
     reply->status_data.subeventstatus[1].targetobjectvalue))
 END ;Subroutine
END GO
