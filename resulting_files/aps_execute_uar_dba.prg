CREATE PROGRAM aps_execute_uar:dba
 RECORD reply(
   1 nortftext = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET request->rtftext = replace(request->rtftext,"{\*\txdiagcoding}","/",0)
 SET rtftextsize = textlen(request->rtftext)
 SET rtftext = fillstring(value(rtftextsize)," ")
 SET nortftext = fillstring(value(rtftextsize)," ")
 SET rtftext = request->rtftext
 CALL uar_rtf2(rtftext,rtftextsize,nortftext,rtftextsize,rtftextsize,
  request->bflag_ind)
 CALL echo(reply->nortftext)
 SET reply->nortftext = nortftext
END GO
