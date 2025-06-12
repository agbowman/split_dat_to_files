CREATE PROGRAM acm_migrate_373_elig_prop:dba
 DECLARE scp = i4
 DECLARE readmsg = i4
 DECLARE readreq = i4
 DECLARE readrep = i4
 DECLARE modifymsg = i4
 DECLARE modifyreq = i4
 DECLARE modifyrep = i4
 DECLARE nodename = vc
 DECLARE elig_host_prop_name = vc WITH protect, constant("ELIGIBILITY_HOST")
 DECLARE elig_protocol_prop_name = vc WITH protect, constant("ELIGIBILITY_PROTOCOL")
 DECLARE elig_context_root_prop_name = vc WITH protect, constant("ELIGIBILITY_CONTEXT_ROOT")
 DECLARE elig_auto_host_prop_name = vc WITH protect, constant("ELIGIBILITY_AUTO_HOST")
 DECLARE elig_auto_protocol_prop_name = vc WITH protect, constant("ELIGIBILITY_AUTO_PROTOCOL")
 DECLARE elig_auto_context_root_prop_name = vc WITH protect, constant("ELIGIBILITY_AUTO_CONTEXT_ROOT"
  )
 DECLARE elig_host = vc WITH protect, noconstant("")
 DECLARE elig_protocol = vc WITH protect, noconstant("")
 DECLARE elig_context_root = vc WITH protect, noconstant("")
 DECLARE elig_auto_host = vc WITH protect, noconstant("")
 DECLARE elig_auto_protocol = vc WITH protect, noconstant("")
 DECLARE elig_auto_context_root = vc WITH protect, noconstant("")
 DECLARE hostlength = i4
 DECLARE protocollength = i4
 DECLARE contextrootlength = i4
 DECLARE autohostlength = i4
 DECLARE autoprotocollength = i4
 DECLARE autocontextrootlength = i4
 EXECUTE dpsrtl
 SET nodename = trim(curnode,3)
 SET scp = uar_scpcreate(nullterm(nodename))
 SET readmsg = uar_scpselect(scp,scp_queryentry)
 SET readreq = uar_srvcreaterequest(readmsg)
 SET readrep = uar_srvcreatereply(readmsg)
 SET queryitem = uar_srvadditem(readreq,"querylist")
 SET stat = uar_srvsetushort(queryitem,"entryid",373)
 SET stat = uar_srvexecute(readmsg,readreq,readrep)
 IF (stat != 0)
  CALL echo(build("Failed to retrieve the server properties of server 373, exit code:",stat))
  CALL echo("Please ensure you are securely signed into the CCL session before running the utility.")
  GO TO exit_program
 ENDIF
 SET elig_host = trim(scp_read_prop(elig_host_prop_name),3)
 SET elig_protocol = trim(scp_read_prop(elig_protocol_prop_name),3)
 SET elig_context_root = trim(scp_read_prop(elig_context_root_prop_name),3)
 SET elig_auto_host = trim(scp_read_prop(elig_auto_host_prop_name),3)
 SET elig_auto_protocol = trim(scp_read_prop(elig_auto_protocol_prop_name),3)
 SET elig_auto_context_root = trim(scp_read_prop(elig_auto_context_root_prop_name),3)
 SET hostlength = textlen(elig_host)
 SET protocollength = textlen(elig_protocol)
 SET contextrootlength = textlen(elig_context_root)
 SET autohostlength = textlen(elig_auto_host)
 SET autoprotocollength = textlen(elig_auto_protocol)
 SET autocontextrootlength = textlen(elig_auto_context_root)
 IF (((hostlength > 0) OR (((protocollength > 0) OR (((contextrootlength > 0) OR (((autohostlength >
 0) OR (((autoprotocollength > 0) OR (autocontextrootlength > 0)) )) )) )) )) )
  SET modifymsg = uar_scpselect(scp,scp_modifyentryprop)
  SET modifyreq = uar_srvcreaterequest(modifymsg)
  SET modifyrep = uar_srvcreatereply(modifymsg)
  SET stat = uar_srvsetushort(modifyreq,"entryid",369)
  IF (hostlength > 0)
   SET propertyitem = uar_srvadditem(modifyreq,"proplist")
   SET stat = uar_srvsetstring(propertyitem,"propname",nullterm(elig_host_prop_name))
   SET stat = uar_srvsetstring(propertyitem,"propvalue",nullterm(elig_host))
  ENDIF
  IF (protocollength > 0)
   SET propertyitem = uar_srvadditem(modifyreq,"proplist")
   SET stat = uar_srvsetstring(propertyitem,"propname",nullterm(elig_protocol_prop_name))
   SET stat = uar_srvsetstring(propertyitem,"propvalue",nullterm(elig_protocol))
  ENDIF
  IF (contextrootlength > 0)
   SET propertyitem = uar_srvadditem(modifyreq,"proplist")
   SET stat = uar_srvsetstring(propertyitem,"propname",nullterm(elig_context_root_prop_name))
   SET stat = uar_srvsetstring(propertyitem,"propvalue",nullterm(elig_context_root))
  ENDIF
  IF (autohostlength > 0)
   SET propertyitem = uar_srvadditem(modifyreq,"proplist")
   SET stat = uar_srvsetstring(propertyitem,"propname",nullterm(elig_auto_host_prop_name))
   SET stat = uar_srvsetstring(propertyitem,"propvalue",nullterm(elig_auto_host))
  ENDIF
  IF (autoprotocollength > 0)
   SET propertyitem = uar_srvadditem(modifyreq,"proplist")
   SET stat = uar_srvsetstring(propertyitem,"propname",nullterm(elig_auto_protocol_prop_name))
   SET stat = uar_srvsetstring(propertyitem,"propvalue",nullterm(elig_auto_protocol))
  ENDIF
  IF (autocontextrootlength > 0)
   SET propertyitem = uar_srvadditem(modifyreq,"proplist")
   SET stat = uar_srvsetstring(propertyitem,"propname",nullterm(elig_auto_context_root_prop_name))
   SET stat = uar_srvsetstring(propertyitem,"propvalue",nullterm(elig_auto_context_root))
  ENDIF
  SET stat = uar_srvexecute(modifymsg,modifyreq,modifyrep)
  IF (stat != 0)
   CALL echo(build("Failed to modify the server properties of server 369, exit code:",stat))
   GO TO exit_program
  ENDIF
 ENDIF
 GO TO exit_program
 SUBROUTINE (scp_read_prop(scp_prop_name=vc) =vc)
   SET entryitem = uar_srvgetitem(readrep,"entrylist",0)
   SET itemcnt = uar_srvgetitemcount(entryitem,"proplist")
   FOR (idx = 0 TO (itemcnt - 1))
     SET propitem = uar_srvgetitem(entryitem,"proplist",idx)
     SET propname = uar_srvgetstringptr(propitem,"propname")
     IF (propname=scp_prop_name)
      SET propvalue = uar_srvgetstringptr(propitem,"propvalue")
      CALL echo(build("scp_read_prop:",propname,", value= ",propvalue))
      RETURN(propvalue)
     ENDIF
   ENDFOR
   RETURN("")
 END ;Subroutine
#exit_program
 IF (readreq)
  CALL uar_srvdestroyinstance(readreq)
 ENDIF
 IF (readrep)
  CALL uar_srvdestroyinstance(readrep)
 ENDIF
 IF (modifyreq)
  CALL uar_srvdestroyinstance(modifyreq)
 ENDIF
 IF (modifyrep)
  CALL uar_srvdestroyinstance(modifyrep)
 ENDIF
END GO
