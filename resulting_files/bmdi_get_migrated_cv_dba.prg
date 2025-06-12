CREATE PROGRAM bmdi_get_migrated_cv:dba
 SET modify = predeclare
 RECORD reply(
   1 qual[*]
     2 doldcodevalue = f8
     2 dnewcodevalue = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE get_cv_from_cv_table(gc_code_set,gc_cdf_meaning,gc_display_key) = f8
 DECLARE count1 = i4 WITH private, noconstant(0)
 DECLARE number_to_add = i4 WITH private, noconstant(0)
 DECLARE stat = i4 WITH private, noconstant(0)
 DECLARE iindex = i4 WITH private, noconstant(0)
 DECLARE strcdfmean = vc WITH private, noconstant("")
 DECLARE strdispkey = c100 WITH private
 DECLARE dcs = i4 WITH private, noconstant(0)
 DECLARE dnew = f8 WITH private, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET number_to_add = size(request->qual,5)
 SET stat = alterlist(reply->qual,number_to_add)
 FOR (iindex = 1 TO value(number_to_add))
   SET strcdfmean = request->qual[iindex].strcdfmeaning
   SET strdispkey = request->qual[iindex].strdisplaykey
   SET dcs = request->qual[iindex].dcodeset
   SET dnew = 0.0
   CALL echo(build("Code Set = [",dcs,"]"))
   CALL echo(build("Disp Key = [",strdispkey,"]"))
   CALL echo(build("Cdf Mean = [",strcdfmean,"]"))
   IF (strcdfmean="+++")
    SET dnew = uar_get_code_by("DISPLAYKEY",dcs,nullterm(strdispkey))
   ELSE
    SET dnew = get_cv_from_cv_table(dcs,strcdfmean,strdispkey)
   ENDIF
   IF (dnew < 0.0)
    SET dnew = 0.0
   ENDIF
   SET reply->qual[iindex].doldcodevalue = request->qual[iindex].doldcodevalue
   SET reply->qual[iindex].dnewcodevalue = dnew
 ENDFOR
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
 SUBROUTINE get_cv_from_cv_table(gc_code_set,gc_cdf_meaning,gc_display_key)
   DECLARE gc_dnew = f8 WITH public, noconstant(0.0)
   DECLARE cnt = i4 WITH public, noconstant(0)
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=gc_code_set
     AND cv.cdf_meaning=gc_cdf_meaning
     AND cv.display_key=gc_display_key
    DETAIL
     cnt = (cnt+ 1), gc_dnew = cv.code_value
    WITH nocounter
   ;end select
   IF (cnt=1)
    RETURN(gc_dnew)
   ELSE
    RETURN(0.0)
   ENDIF
 END ;Subroutine
END GO
