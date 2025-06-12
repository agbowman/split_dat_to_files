CREATE PROGRAM cpmstartup_eks:dba
 EXECUTE cpmstartup
 SET trace = callecho
 SET trace = symbolreset
 SET dictcache = 200
 IF (validate(request->log_level,99)=99)
  GO TO end_script
 ENDIF
 RECORD reply(
   1 echo_level = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET trace = server
 CALL echo(concat("turning range cache on, setting to:",cnvtstring(dictcache)))
 SET trace rangecache value(dictcache)
 CALL echo(concat("    Server number: ",build(request->server_number)))
 CALL echo(concat("  Server instance: ",build(request->server_instance)))
 CALL echo(concat("    Logging level: ",build(request->log_level)))
 CALL echo(concat("           Domain: ",build(request->domain)))
 CALL echo(concat("      Server type: ",build(request->server_type)))
 CALL echo(concat("     Server class: ",build(request->server_class)))
 SET trace = noflush
 IF ((request->log_level >= 4))
  SET trace flush 60
  SET trace = error
  SET trace = ekm
  SET trace = noekm2
  SET trace = notest
  SET trace = noechoinput
  SET trace = noechoinput2
  SET trace = progcache
  SET trace = echoprog
  SET trace = cost
  SET reply->echo_level = 0
  SET trace = callechotag
  SET trace = callecho
 ELSE
  SET trace flush 600
  SET trace = noerror
  SET trace = noekm
  SET trace = noekm2
  SET trace = notest
  SET trace = noechoinput
  SET trace = noechoinput2
  SET trace = progcache
  SET trace = noechoprog
  SET trace = nocost
  SET reply->echo_level = 10
  SET trace = nocallechotag
  SET trace = nocallecho
 ENDIF
 SET reply->status_data.status = "S"
 SET trace = lock
#end_script
END GO
