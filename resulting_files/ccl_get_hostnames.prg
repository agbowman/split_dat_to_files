CREATE PROGRAM ccl_get_hostnames
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE hostnames = vc WITH protect
 DECLARE host = vc WITH protect
 DECLARE domainname = vc WITH protect
 DECLARE ihostcount = i4 WITH noconstant(0), protect
 DECLARE istartindex = i4 WITH noconstant(1), protect
 DECLARE ifoundindex = i4 WITH noconstant(0), protect
 DECLARE firsthost = vc WITH protect
 EXECUTE ccluarxhost
 EXECUTE ccl_prompt_api_dataset "dataset", "advapi"
 SET stat = setstatus("F")
 SET stat = makedataset(10)
 SET fhostname = addstringfield("hostname","Host name",1,100)
 SET domainname = cnvtupper(trim(reqdata->domain))
 SET hostnames = uar_gethostnames(nullterm(domainname))
 SET ifoundindex = findstring("|",hostnames,istartindex,0)
 WHILE (ifoundindex > 0)
   SET host = substring(istartindex,(ifoundindex - istartindex),hostnames)
   IF (size(host,1) > 0)
    SET rec = getnextrecord(0)
    SET stat = setstringfield(rec,fhostname,host)
    IF (istartindex=1)
     SET firsthost = host
    ENDIF
   ENDIF
   SET istartindex = (ifoundindex+ 1)
   SET ifoundindex = findstring("|",hostnames,istartindex,0)
 ENDWHILE
 SET host = substring(istartindex,((size(hostnames,1) - istartindex)+ 1),hostnames)
 IF (size(host,1) > 0)
  SET rec = getnextrecord(0)
  SET stat = setstringfield(rec,fhostname,host)
  IF (size(firsthost,1) < 1)
   SET firsthost = host
  ENDIF
 ENDIF
 IF (size(firsthost,1) > 0)
  SET stat = adddefaultkey(firsthost)
 ENDIF
 SET stat = closedataset(0)
 SET stat = setstatus("S")
END GO
