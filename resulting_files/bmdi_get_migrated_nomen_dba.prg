CREATE PROGRAM bmdi_get_migrated_nomen:dba
 SET modify = predeclare
 RECORD reply(
   1 qual[*]
     2 doldnomenid = f8
     2 dnewnomenid = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE get_nomenid(gc_short_string) = f8
 DECLARE count1 = i4 WITH private, noconstant(0)
 DECLARE number_to_add = i4 WITH private, noconstant(0)
 DECLARE stat = i4 WITH private, noconstant(0)
 DECLARE iindex = i4 WITH private, noconstant(0)
 SET number_to_add = size(request->qual,5)
 SET stat = alterlist(reply->qual,number_to_add)
 SET reply->status_data.status = "F"
 FOR (iindex = 1 TO value(number_to_add))
   DECLARE strshortstring = vc WITH private, noconstant("")
   DECLARE doldnomenid = f8 WITH private, noconstant(0.0)
   DECLARE dnew = f8 WITH private, noconstant(0.0)
   SET strshortstring = trim(request->qual[iindex].strshortstring)
   SET doldnomenid = request->qual[iindex].doldnomenid
   CALL echo(build("Short String = [",strshortstring,"]"))
   CALL echo(build("Old NomenId =  [",doldnomenid,"]"))
   SET dnew = 0.0
   IF (doldnomenid > 0)
    SET dnew = get_nomenid(strshortstring)
   ENDIF
   SET reply->qual[iindex].doldnomenid = request->qual[iindex].doldnomenid
   SET reply->qual[iindex].dnewnomenid = dnew
 ENDFOR
 CALL echorecord(reply)
 SET reply->status_data.status = "S"
 SUBROUTINE get_nomenid(gc_short_string)
   DECLARE gc_dnew = f8 WITH public, noconstant(0.0)
   DECLARE cnt = i4 WITH public, noconstant(0)
   CALL echo(build("short_string = [",gc_short_string,"]"))
   SELECT INTO "nl:"
    n.nomenclature_id
    FROM nomenclature n
    WHERE n.short_string=gc_short_string
     AND gc_short_string > ""
    DETAIL
     cnt = (cnt+ 1), gc_dnew = n.nomenclature_id
    WITH nocounter
   ;end select
   IF (cnt=1)
    RETURN(gc_dnew)
   ELSE
    RETURN(0.0)
   ENDIF
 END ;Subroutine
END GO
