CREATE PROGRAM cclocdcopy:dba
 SET errmsg = fillstring(132," ")
 SET error_check = error(errmsg,1)
 SET errorcode = 0
 SET hsys = 0
 SET sysstat = 0
 CALL uar_syscreatehandle(hsys,sysstat)
 SET interactive = validate(reply->ops_event,"ZZZ")
 IF (interactive="ZZZ")
  RECORD request(
    1 output_dist = vc
  )
  SET request->output_dist = ""
  RECORD reply(
    1 ops_event = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET reply->ops_event = ""
 SET dclstatus = 0
 SET pstart = 0
 SET pstart = findstring("P1=",cnvtupper(request->output_dist))
 IF (pstart > 0)
  SET pstart = (pstart+ 3)
  SET pend = 0
  SET pend = findstring(";;",cnvtupper(request->output_dist),pstart)
  IF (pend=0)
   SET reply->ops_event = substring(1,100,concat("Invalid output_dist format: ",trim(request->
      output_dist),"."))
   GO TO exit_script
  ENDIF
  SET target_node = fillstring(16," ")
  SET target_node = substring(pstart,(pend - pstart),request->output_dist)
  SET sts = 0
  SET node_name = fillstring(16," ")
  IF (cursys="AIX")
   CALL dcl("hostname > ocdnode.dat",24,sts)
   FREE DEFINE rtl
   SET rtl_name = "ocdnode.dat"
   DEFINE rtl rtl_name
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    DETAIL
     node_name = cnvtupper(trim(r.line))
   ;end select
   FREE DEFINE rtl
   IF (curqual=0)
    SET reply->ops_event = "Error retrieving current node name from AIX."
    GO TO exit_script
   ENDIF
  ELSE
   CALL uar_get_nodename(node_name,sts)
   IF (sts != 0)
    SET reply->ops_event = "Error retrieving current node name from AXP."
    GO TO exit_script
   ENDIF
  ENDIF
  IF (trim(cnvtupper(node_name)) != trim(cnvtupper(target_node)))
   SET reply->ops_event = substring(1,100,concat("Current node ",trim(node_name),
     " does not match expected target node ",trim(target_node),"."))
   GO TO exit_script
  ENDIF
 ENDIF
 SET ocdnum = cnvtint( $1)
 SET ocdnumstring = format(ocdnum,"######;rp0")
 SET errorcode = error(errmsg,0)
 IF (errorcode != 0)
  SET reply->ops_event = substring(1,100,"CCL error reading input parameters.")
  GO TO exit_script
 ENDIF
 IF (cursys="AIX")
  SET logical ocddir value(concat(trim(logical("cer_ocd")),"/",ocdnumstring))
 ELSE
  SET cerocd = logical("cer_ocd")
  SET len = findstring("]",cerocd)
  SET line = concat(substring(1,(len - 1),cerocd),ocdnumstring,"]")
  SET logical ocddir line
 ENDIF
 SET minidic = cnvtlower(concat("dicocd",ocdnumstring,".dat"))
 FREE SET fstat
 FREE SET dfile
 SET dfile = concat("ocddir:",trim(minidic))
 SET fstat = findfile(dfile)
 IF (fstat=0)
  SET reply->ops_event = substring(1,100,concat("CCL mini-dictionary does not exist: ",trim(minidic),
    "."))
  GO TO exit_script
 ENDIF
 FREE DEFINE dicocd
 FREE SET minidictionary
 SET minidictionary = concat("ocddir:",minidic)
 DEFINE dicocd value(minidictionary)  WITH modify
 UPDATE  FROM dprotectocd dpocd
  SET dpocd.app_minor_version = ocdnum
  WHERE dpocd.app_minor_version != ocdnum
  WITH counter
 ;end update
 SET textfile = cnvtlower(minidictionary)
 SET lpos = findstring(".dat",textfile)
 SET lpos = (lpos - 1)
 SET textfile2 = substring(1,lpos,textfile)
 SET textfile3 = concat(trim(textfile2),"txt")
 EXECUTE cclocdselectrpt textfile3, "/", ";"
 FREE DEFINE dicocd
 SET textfile4 = concat(trim(textfile3),".dat")
 IF (cursys="AIX")
  SET textfile2s = replace(textfile2,"ocddir:"," ",0)
  SET textfile4s = replace(textfile4,"ocddir:"," ",0)
  FREE SET com
  SET com = concat("mv ",trim(logical("cer_ocd")),"/",ocdnumstring,"/",
   trim(textfile4s,3)," ",trim(logical("cer_ocd")),"/",ocdnumstring,
   "/",trim(textfile2s,3),".txt")
  CALL dcl(com,size(trim(com)),dclstatus)
 ELSE
  FREE SET com
  SET com = concat("$ren ",trim(textfile4)," ",trim(textfile2),".txt")
  CALL dcl(com,size(trim(com)),dclstatus)
 ENDIF
 IF (dclstatus=0)
  SET reply->ops_event = substring(1,100,concat("DCL error: ",trim(com)))
  GO TO exit_script
 ENDIF
 SET errorcode = error(errmsg,0)
 IF (errorcode != 0)
  SET reply->ops_event = substring(1,100,concat("CCL error reapplying version stamp to contents of ",
    trim(minidic),"."))
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->ops_event = "CCLOCDCopy Successful"
#exit_script
 IF ((reply->status_data.status="F"))
  CALL uar_sysevent(hsys,0,"CCLOCDCopy",nullterm(trim(reply->ops_event)))
 ENDIF
 IF (errorcode=0
  AND (reply->status_data.status="F"))
  SET errorcode = error(errmsg,0)
 ENDIF
 WHILE (errorcode != 0)
  CALL uar_sysevent(hsys,0,"CCLOCDCopy",nullterm(trim(errmsg)))
  SET errorcode = error(errmsg,0)
 ENDWHILE
 IF (interactive="ZZZ")
  CALL echo(concat("***Status: ",trim(reply->status_data.status)))
  CALL echo(concat("***Text: ",trim(reply->ops_event)))
  CALL echo("***")
 ENDIF
 CALL uar_sysdestroyhandle(hsys)
 SET error_check = error(errmsg,1)
END GO
