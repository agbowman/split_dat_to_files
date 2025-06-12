CREATE PROGRAM da_import_metadata:dba
 SET modify maxvarlen 52428800
 DECLARE uar_fopen(p1=vc(ref),p2=vc(ref)) = i4 WITH image_axp = "decc$shr", uar_axp = "decc$fopen",
 image_aix = "libc.a(shr.o)",
 uar_aix = "fopen"
 DECLARE uar_fread(p1=vc(ref),p2=i4(value),p3=i4(value),p4=i4(value)) = i4 WITH image_axp =
 "decc$shr", uar_axp = "decc$fread", image_aix = "libc.a(shr.o)",
 uar_aix = "fread"
 DECLARE uar_feof(p1=i4(value)) = i4 WITH image_axp = "decc$shr", uar_axp = "decc$feof", image_aix =
 "libc.a(shr.o)",
 uar_aix = "feof"
 DECLARE uar_fclose(p1=i4(value)) = i4 WITH image_axp = "decc$shr", uar_axp = "decc$fclose",
 image_aix = "libc.a(shr.o)",
 uar_aix = "fclose"
 DECLARE getcurrenttime() = f8
 DECLARE filename = vc WITH protect, noconstant("")
 DECLARE osfilename = vc WITH protect, noconstant("")
 DECLARE importtype = i2 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE importxml = vc WITH protect
 DECLARE xmllength = i4 WITH protect, noconstant(0)
 DECLARE happlication = i4 WITH protect, noconstant(0)
 DECLARE htask = i4 WITH protect, noconstant(0)
 DECLARE hstep = i4 WITH protect, noconstant(0)
 DECLARE scriptbegintime = f8 WITH protect, constant(getcurrenttime(0))
 DECLARE importbegintime = f8 WITH protect, noconstant(0)
 DECLARE importendtime = f8 WITH protect, noconstant(0)
 SET filename = parameter(1,0)
 SET importtype = parameter(2,0)
 IF (reflect(parameter(2,0))=" ")
  SET importtype = getimporttype(filename)
 ENDIF
 IF (((importtype < 1) OR (importtype > 3)) )
  SET readme_data->status = "F"
  SET readme_data->message =
  "Invalid import type! Specify 1 for logical view, 2 for business view, or 3 for domain."
  GO TO exit_now
 ENDIF
 SET osfilename = getosfilename(filename)
 CALL echo(concat("*** Using file ",osfilename))
 SET xmllength = readfile(osfilename,importxml)
 CALL echo(build("*** Read import file:",xmllength," bytes"))
 IF (xmllength=0)
  GO TO exit_now
 ENDIF
 SET stat = uar_crmbeginapp(3202004,happlication)
 IF (stat=0
  AND happlication != 0)
  SET stat = uar_crmbegintask(happlication,3202004,htask)
  IF (stat=0
   AND htask != 0)
   SET stat = uar_crmbeginreq(htask,"",5009203,hstep)
   IF (stat=0
    AND hstep != 0)
    SET stat = populateimportrequest(hstep,importxml,xmllength)
    IF (stat != 0)
     SET importbegintime = getcurrenttime(0)
     CALL echo("***************************************************************")
     CALL echo(build("*** Executing request (",format(importbegintime,";;q"),") with type=",
       importtype))
     SET stat = uar_crmperform(hstep)
     SET importendtime = getcurrenttime(0)
     CALL echo(build("*** Request returned (",format(importendtime,";;q"),") elapsed time=",
       cnvtstring(((importendtime - importbegintime)/ 10000000.),17,2)," sec"))
     CALL echo("***************************************************************")
     IF (stat=0)
      SET stat = checkreply(hstep)
     ELSE
      SET readme_data->status = "F"
      SET readme_data->message = build("Cannot import: CrmPerform failed (crmStat=",stat,").")
     ENDIF
    ENDIF
    SET stat = uar_crmendreq(hstep)
   ELSE
    SET readme_data->status = "F"
    SET readme_data->message = build("Failed to start CRM request (crmStat=",stat,").")
   ENDIF
   SET stat = uar_crmendtask(htask)
  ELSE
   SET readme_data->status = "F"
   SET readme_data->message = build("Failed to start CRM task (crmStat=",stat,").")
  ENDIF
  SET stat = uar_crmendapp(happlication)
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = build("Failed to start CRM application (crmStat=",stat,").")
 ENDIF
 GO TO exit_now
 SUBROUTINE (populateimportrequest(hstep=i4,xml=vc(ref),length=i4) =i4)
   DECLARE hrequest = i4 WITH protect, noconstant(0)
   SET hrequest = uar_crmgetrequest(hstep)
   IF (hrequest=0)
    SET readme_data->status = "F"
    SET readme_data->message = "Failed to get handle to request structure."
    RETURN(0)
   ENDIF
   SET stat = uar_srvsetshort(hrequest,"import_type",importtype)
   SET stat = uar_srvsetasis(hrequest,"xml",xml,length)
   IF (stat=0)
    SET readme_data->status = "F"
    SET readme_data->message = "Failed to add XML data to request."
   ENDIF
   RETURN(stat)
 END ;Subroutine
 SUBROUTINE (checkreply(hstep=i4) =i4)
   DECLARE hreply = i4 WITH protect, noconstant(0)
   DECLARE hstatus = i4 WITH protect, noconstant(0)
   DECLARE success_ind = i4 WITH protect, noconstant(0)
   DECLARE elapsedtime = f8 WITH protect, noconstant(0)
   SET hreply = uar_crmgetreply(hstep)
   IF (hreply=0)
    SET readme_data->status = "F"
    SET readme_data->message = "Failed to get handle to reply structure."
    RETURN(0)
   ENDIF
   SET hstatus = uar_srvgetstruct(hreply,"transaction_status")
   IF (hstatus=0)
    SET readme_data->status = "F"
    SET readme_data->message = "Failed to get status block from reply."
    RETURN(0)
   ENDIF
   SET success_ind = uar_srvgetshort(hstatus,"success_ind")
   SET error_msg = uar_srvgetstringptr(hstatus,"debug_error_message")
   IF (success_ind=0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Import failed: ",error_msg)
   ELSE
    SET elapsedtime = (getcurrenttime(0) - scriptbegintime)
    SET readme_data->status = "S"
    SET readme_data->message = build("The import was successful (",cnvtstring((elapsedtime/ 10000000.
      ),17,2)," sec elapsed).")
   ENDIF
   RETURN(success_ind)
 END ;Subroutine
 SUBROUTINE (readfile(filename=vc(ref),contents=vc(ref)) =i4)
   DECLARE hfile = i4 WITH protect, noconstant(0)
   DECLARE count = i4 WITH protect, noconstant(0)
   DECLARE buf = c16384 WITH protect
   SET hfile = uar_fopen(nullterm(filename),"r")
   IF (hfile=0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Could not open file '",filename,"' for reading.")
    RETURN(0)
   ENDIF
   SET stat = error(error_msg,1)
   WHILE (uar_feof(hfile)=0)
     SET stat = uar_fread(buf,1,16384,hfile)
     SET count += stat
     IF (stat > 0)
      SET contents = notrim(concat(contents,substring(1,stat,buf)))
     ENDIF
     IF (error(error_msg,0) != 0)
      SET readme_data->status = "F"
      SET readme_data->message = concat("Error reading file: ",error_msg)
      SET stat = uar_fclose(hfile)
      RETURN(0)
     ENDIF
   ENDWHILE
   SET stat = uar_fclose(hfile)
   IF (count=0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Metadata import file '",filename,"' is empty.")
   ENDIF
   RETURN(count)
 END ;Subroutine
 SUBROUTINE (getimporttype(filename=vc(ref)) =i2)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE typeword = vc WITH protect, noconstant("")
   SET pos = findstring(".xml",cnvtlower(filename))
   IF (pos >= 5)
    SET typeword = substring((pos - 3),3,filename)
    CASE (typeword)
     OF "_lv":
      RETURN(1)
     OF "_bv":
      RETURN(2)
     OF "_bd":
      RETURN(3)
    ENDCASE
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (getosfilename(filename=vc(ref)) =vc)
   DECLARE name = vc WITH noconstant(filename)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE log_value = vc WITH protect, noconstant("")
   SET pos = findstring(":",name)
   IF (pos=0
    AND cursys="AIX")
    SET pos = findstring("/",name)
   ENDIF
   IF (pos=0)
    SET name = build("cer_install:",name)
   ENDIF
   IF (cursys="AIX")
    SET pos = findstring(":",name)
    IF (pos > 1)
     SET log_value = logical(substring(1,(pos - 1),name))
     IF (substring(textlen(log_value),1,log_value) != "/")
      SET log_value = concat(log_value,"/")
     ENDIF
     SET name = concat(log_value,substring((pos+ 1),(textlen(name) - pos),name))
    ENDIF
   ENDIF
   RETURN(name)
 END ;Subroutine
 SUBROUTINE getcurrenttime(dummy)
   RETURN((sysdate+ (mod(curtime3,100) * 10000)))
 END ;Subroutine
#exit_now
END GO
