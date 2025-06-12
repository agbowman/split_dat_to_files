CREATE PROGRAM bsc_process_patient_barcode:dba
 SET modify = predeclare
 RECORD reply(
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 privilege_ind = i2
     2 mulrecencntrfound = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD formats
 RECORD formats(
   1 qual[*]
     2 alias_type_cd = f8
     2 check_digit_ind = i2
     2 prefix = vc
     2 z_data = vc
     2 alias_pool_cd = f8
     2 code_set = i4
     2 bc_alias = vc
     2 org_id = f8
 )
 FREE RECORD tempprefix
 RECORD tempprefix(
   1 qual[*]
     2 value = vc
 )
 DECLARE bfound = i2 WITH protect, noconstant(0)
 DECLARE bstripzeros = i2 WITH protect, noconstant(0)
 DECLARE lpos = i4 WITH protect, noconstant(0)
 DECLARE lcount1 = i4 WITH protect, noconstant(0)
 DECLARE lidx1 = i4 WITH protect, noconstant(0)
 DECLARE lidx2 = i4 WITH protect, noconstant(0)
 DECLARE lbclength = i4 WITH protect, noconstant(0)
 DECLARE dorgid = f8 WITH protect, noconstant(0.0)
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE encounter_alias_cs = f8 WITH protect, constant(319.00)
 DECLARE person_alias_cs = f8 WITH protect, constant(4.00)
 DECLARE last_mod = c3 WITH protect, noconstant("")
 DECLARE mod_date = c10 WITH protect, noconstant("")
 DECLARE sbarcode = vc WITH protect, noconstant(trim(request->barcode,3))
 DECLARE sbarcodeprefix = vc WITH protect, noconstant("")
 DECLARE sbarcodezdata = vc WITH protect, noconstant("")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE iindex = i4 WITH protect, noconstant(0)
 DECLARE dbarcodetypecd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",28520,"PTWRISTBAND"))
 DECLARE iprefixind = i2 WITH protect, noconstant(0)
 DECLARE iendsinspaceind = i2 WITH protect, noconstant(0)
 DECLARE debug_ind = i2 WITH protect, noconstant(0)
 DECLARE dorganizationid = f8 WITH protect, noconstant(0.0)
 DECLARE lperpos = i4 WITH protect, noconstant(0)
 DECLARE lperidx = i4 WITH protect, noconstant(0)
 DECLARE encntrs_api_stat = i2 WITH protect, noconstant(0)
 IF (validate(request->debug_ind))
  SET debug_ind = request->debug_ind
 ENDIF
 IF (validate(request->barcode_type_cd))
  IF ((request->barcode_type_cd > 0.0))
   SET dbarcodetypecd = request->barcode_type_cd
  ENDIF
 ENDIF
 IF (validate(request->organization_id))
  SET dorganizationid = request->organization_id
 ENDIF
 DECLARE bcheckdigithyphen = i2 WITH protect, noconstant(0)
 DECLARE checksecurity(null) = null
 DECLARE checkorgsecurity(null) = null
 SET reply->status_data.status = "F"
 IF (substring(size(request->barcode,1),1,request->barcode)="-")
  SET bcheckdigithyphen = 1
 ENDIF
 SET sbarcode = replace(sbarcode,"-","",0)
 CALL getprefix(sbarcode)
 CALL getzdata(sbarcode,sbarcodezdata)
 CALL echo(build("dOrganizationId:",dorganizationid))
 IF ((request->location_cd=0.0)
  AND dorganizationid > 0.0)
  SELECT INTO "nl:"
   FROM organization o
   PLAN (o
    WHERE o.organization_id=dorganizationid
     AND o.active_ind=1)
   DETAIL
    dorgid = o.organization_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET serrmsg = concat("Proper organization not found, request->organization_id: ",cnvtstring(
     dorganizationid))
   CALL logstatus("SELECT","F","LOCATION",serrmsg)
   IF (debug_ind)
    CALL echo("*** Org could not be found")
   ENDIF
   GO TO exit_prg
  ENDIF
 ELSE
  SELECT INTO "nl:"
   FROM location l
   PLAN (l
    WHERE (l.location_cd=request->location_cd)
     AND l.active_ind=1)
   DETAIL
    dorgid = l.organization_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET serrmsg = concat("Organization not found for given location_cd: ",cnvtstring(request->
     location_cd))
   CALL logstatus("SELECT","F","LOCATION",serrmsg)
   IF (debug_ind)
    CALL echo("*** No Org Found")
   ENDIF
   GO TO exit_prg
  ELSEIF (curqual > 1)
   IF (debug_ind)
    CALL echo(concat("*** Multiple orgs found for a given location_cd ",cnvtstring(request->
       location_cd)))
   ENDIF
  ELSE
   IF (debug_ind)
    CALL echo(concat("*** OrgId: ",cnvtstring(dorgid)))
   ENDIF
  ENDIF
 ENDIF
 SELECT DISTINCT INTO "nl:"
  obf.org_barcode_format_id
  FROM org_barcode_org obo,
   org_barcode_format obf,
   org_alias_pool_reltn oapr,
   code_value cv
  PLAN (obo
   WHERE ((obo.scan_organization_id=dorgid) OR (obo.scan_organization_id=0)) )
   JOIN (obf
   WHERE ((obf.organization_id=obo.label_organization_id
    AND obo.scan_organization_id > 0
    AND obf.barcode_type_cd=dbarcodetypecd) OR (obf.organization_id=dorgid
    AND obo.scan_organization_id=0
    AND obf.barcode_type_cd=dbarcodetypecd)) )
   JOIN (oapr
   WHERE oapr.alias_entity_alias_type_cd=obf.alias_type_cd
    AND oapr.organization_id=obf.organization_id
    AND oapr.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=obf.alias_type_cd
    AND cv.active_ind=1)
  ORDER BY obf.org_barcode_format_id
  HEAD REPORT
   lcount1 = 0
  HEAD obf.org_barcode_format_id
   FOR (iindex = 1 TO size(tempprefix->qual,5))
     IF ((tempprefix->qual[iindex].value=trim(obf.prefix,3))
      AND sbarcodezdata=trim(obf.z_data,3))
      lcount1 += 1
      IF (mod(lcount1,10)=1)
       dstat = alterlist(formats->qual,(lcount1+ 9))
      ENDIF
      formats->qual[lcount1].alias_type_cd = obf.alias_type_cd, formats->qual[lcount1].
      check_digit_ind = obf.check_digit_ind, formats->qual[lcount1].prefix = obf.prefix,
      formats->qual[lcount1].z_data = obf.z_data, formats->qual[lcount1].alias_pool_cd = oapr
      .alias_pool_cd, formats->qual[lcount1].code_set = cv.code_set,
      formats->qual[lcount1].org_id = obf.organization_id
     ENDIF
   ENDFOR
  FOOT REPORT
   dstat = alterlist(formats->qual,lcount1)
  WITH nocounter
 ;end select
 IF (lcount1=0)
  SET serrmsg = concat("Formats did not qualify for organization_id: ",cnvtstring(dorgid))
  CALL logstatus("SELECT","F","ORG_BARCODE_FORMAT",serrmsg)
  GO TO exit_prg
 ENDIF
#reprocess_barcode
 FOR (lidx1 = 1 TO value(size(formats->qual,5)))
   SET formats->qual[lidx1].bc_alias = trim(sbarcode,3)
   IF (trim(formats->qual[lidx1].prefix) > " ")
    SET lpos = findstring(trim(formats->qual[lidx1].prefix,3),formats->qual[lidx1].bc_alias)
    IF (lpos=1)
     SET formats->qual[lidx1].bc_alias = substring((lpos+ size(trim(formats->qual[lidx1].prefix,3),1)
      ),size(formats->qual[lidx1].bc_alias,1),formats->qual[lidx1].bc_alias)
    ENDIF
   ENDIF
   IF (trim(formats->qual[lidx1].z_data) > " ")
    SET lpos = findstring("/Z",formats->qual[lidx1].bc_alias)
    IF (lpos > 0)
     SET formats->qual[lidx1].bc_alias = substring(1,(lpos - 1),formats->qual[lidx1].bc_alias)
    ENDIF
   ENDIF
   IF ((formats->qual[lidx1].check_digit_ind=1))
    IF (bcheckdigithyphen=1)
     SET formats->qual[lidx1].bc_alias = concat(formats->qual[lidx1].bc_alias,"-")
    ENDIF
    IF ((request->ends_in_space_ind=0))
     IF (((trim(formats->qual[lidx1].z_data) > " ") OR (substring(size(request->barcode,1),1,request
      ->barcode) != " ")) )
      SET formats->qual[lidx1].bc_alias = substring(1,(size(trim(formats->qual[lidx1].bc_alias),1) -
       1),formats->qual[lidx1].bc_alias)
     ENDIF
    ENDIF
   ENDIF
   IF (bstripzeros=1)
    SET lpos = 0
    SET lbclength = textlen(formats->qual[lidx1].bc_alias)
    FOR (lidx2 = 1 TO lbclength)
      IF (substring(lidx2,1,formats->qual[lidx1].bc_alias)="0")
       SET lpos = lidx2
      ELSE
       SET lidx2 = lbclength
      ENDIF
    ENDFOR
    IF (lpos > 0)
     SET formats->qual[lidx1].bc_alias = substring((lpos+ 1),(lbclength - lpos),formats->qual[lidx1].
      bc_alias)
     IF (debug_ind)
      CALL echo(concat("*** Stripped zeros alias: ",formats->qual[lidx1].bc_alias))
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 FOR (lidx1 = 1 TO value(size(formats->qual,5)))
  IF (debug_ind)
   CALL echo(concat("*** formats->qual[lIdx1]->alias_pool_cd: ",cnvtstring(formats->qual[lidx1].
      alias_pool_cd)))
   CALL echo(concat("*** formats->qual[lIdx1]->alias_type_cd: ",cnvtstring(formats->qual[lidx1].
      alias_type_cd)))
   CALL echo(concat("*** formats->qual[lIdx1]->bc_alias: ",cnvtstring(formats->qual[lidx1].bc_alias))
    )
   CALL echo(concat("*** formats->qual[lIdx1]->org_id: ",cnvtstring(formats->qual[lidx1].org_id)))
  ENDIF
  IF ((formats->qual[lidx1].code_set=encounter_alias_cs)
   AND (dorgid=formats->qual[lidx1].org_id))
   SELECT INTO "nl:"
    FROM encntr_alias ea,
     encounter e
    PLAN (ea
     WHERE (ea.alias_pool_cd=formats->qual[lidx1].alias_pool_cd)
      AND (ea.encntr_alias_type_cd=formats->qual[lidx1].alias_type_cd)
      AND (ea.alias=formats->qual[lidx1].bc_alias)
      AND ea.active_ind=1)
     JOIN (e
     WHERE e.encntr_id=ea.encntr_id
      AND e.active_ind=1)
    HEAD REPORT
     lcount1 = size(reply->qual,5)
    DETAIL
     IF (e.person_id > 0)
      lperpos = locateval(lperidx,1,size(reply->qual,5),e.person_id,reply->qual[lperidx].person_id)
      IF (lperpos=0)
       bfound = 0
       FOR (lidx2 = 1 TO value(size(reply->qual,5)))
         IF ((reply->qual[lcount1].person_id=e.person_id)
          AND (reply->qual[lcount1].encntr_id=e.encntr_id))
          bfound = 1
         ENDIF
       ENDFOR
       IF (bfound=0)
        lcount1 += 1, dstat = alterlist(reply->qual,lcount1), reply->qual[lcount1].person_id = e
        .person_id,
        reply->qual[lcount1].encntr_id = e.encntr_id, reply->qual[lcount1].mulrecencntrfound =
        lcount1
       ENDIF
      ELSE
       reply->qual[lperpos].mulrecencntrfound += 1
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
  ELSEIF ((formats->qual[lidx1].code_set=person_alias_cs))
   SELECT INTO "nl:"
    FROM person_alias pa
    PLAN (pa
     WHERE (pa.alias_pool_cd=formats->qual[lidx1].alias_pool_cd)
      AND (pa.person_alias_type_cd=formats->qual[lidx1].alias_type_cd)
      AND (pa.alias=formats->qual[lidx1].bc_alias)
      AND pa.active_ind=1)
    HEAD REPORT
     lcount1 = size(reply->qual,5)
    HEAD pa.person_id
     IF (pa.person_id > 0)
      bfound = 0
      FOR (lidx2 = 1 TO value(size(reply->qual,5)))
        IF ((reply->qual[lcount1].person_id=pa.person_id)
         AND (reply->qual[lcount1].encntr_id=0))
         bfound = 1
        ENDIF
      ENDFOR
      IF (bfound=0)
       lcount1 += 1, dstat = alterlist(reply->qual,lcount1), reply->qual[lcount1].person_id = pa
       .person_id,
       reply->qual[lcount1].encntr_id = 0
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
#exit_prg
 IF (size(reply->qual,5)=0)
  IF (bstripzeros=0
   AND size(formats->qual,5) > 0)
   SET bstripzeros = 1
   IF (debug_ind)
    CALL echo("***** Reprocessing barcode stripping leading zeros *****")
   ENDIF
   GO TO reprocess_barcode
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  CALL checksecurity(null)
  IF (encntrs_api_stat=2)
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 IF (debug_ind)
  CALL echorecord(formats)
  CALL echorecord(reply)
 ENDIF
 FREE RECORD formats
 FREE RECORD tempprefix
 SUBROUTINE (getprefix(sbarcodein=vc) =null)
   DECLARE ibarcodeindex = i4 WITH protect, noconstant(0)
   DECLARE ibarcodelength = i4 WITH protect, noconstant(0)
   DECLARE schar = c1 WITH protect, noconstant("")
   DECLARE dstattemp = f8 WITH protect, noconstant(0.0)
   DECLARE ibarcodeindexcnt = i4 WITH protect, noconstant(1)
   SET ibarcodelength = textlen(sbarcodein)
   IF (ibarcodelength > 1)
    SET dstattemp = alterlist(tempprefix->qual,ibarcodelength)
    SET tempprefix->qual[1].value = ""
   ENDIF
   FOR (ibarcodeindex = 1 TO ibarcodelength)
    SET schar = substring(ibarcodeindex,1,sbarcodein)
    IF (isnumeric(schar) > 0)
     SET ibarcodeindex = ibarcodelength
    ELSE
     IF ((request->prefix_flag=0))
      SET tempprefix->qual[1].value = substring(1,ibarcodeindex,sbarcodein)
      SET ibarcodeindexcnt = 1
     ELSE
      SET tempprefix->qual[(ibarcodeindex+ 1)].value = substring(1,ibarcodeindex,sbarcodein)
      SET ibarcodeindexcnt = (ibarcodeindex+ 1)
     ENDIF
    ENDIF
   ENDFOR
   SET dstattemp = alterlist(tempprefix->qual,ibarcodeindexcnt)
   IF (debug_ind)
    CALL echo(build("tempPrefix->qual[barcodeIndex]->value",
      "leading character(s) was found, adding to list of prefixes to try"))
   ENDIF
   IF (debug_ind)
    CALL echorecord(tempprefix)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getzdata(sbarcodein=vc,szdata=vc(ref)) =null)
   DECLARE lpos = i4 WITH protect, noconstant(0)
   SET lpos = findstring("/Z",sbarcodein)
   IF (lpos > 0)
    SET szdata = substring((lpos+ 2),(textlen(sbarcodein) - (lpos+ 1)),sbarcodein)
   ENDIF
   IF (debug_ind)
    CALL echo(build2("*** Barcode Z-data:",szdata))
   ENDIF
 END ;Subroutine
 SUBROUTINE (logstatus(operationname=vc,operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc
  ) =null)
   SET reply->status_data.subeventstatus[1].operationname = operationname
   SET reply->status_data.subeventstatus[1].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[1].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[1].targetobjectvalue = targetobjectvalue
 END ;Subroutine
 SUBROUTINE checksecurity(null)
   IF (debug_ind)
    CALL echo("*** Checking Security ***")
   ENDIF
   DECLARE lencntrcnt = i4 WITH protect, noconstant(0)
   DECLARE lencntridx = i4 WITH protect, noconstant(0)
   DECLARE lidx1 = i4 WITH protect, noconstant(0)
   DECLARE lpos = i4 WITH protect, noconstant(0)
   SET modify = nopredeclare
   RECORD accessible_encntr_person_ids(
     1 person_ids[*]
       2 person_id = f8
   ) WITH public
   RECORD accessible_encntr_ids(
     1 accessible_encntrs_cnt = i4
     1 accessible_encntrs[*]
       2 accessible_encntr_id = f8
   ) WITH public
   RECORD accessible_encntr_ids_maps(
     1 persons_cnt = i4
     1 persons[*]
       2 person_id = f8
       2 accessible_encntrs_cnt = i4
       2 accessible_encntrs[*]
         3 accessible_encntr_id = f8
   ) WITH public
   DECLARE getaccessibleencntrerrormsg = vc WITH protect
   DECLARE getaccessibleencntrtoggleerrormsg = vc WITH protect
   DECLARE h3202611srvmsg = i4 WITH noconstant(0), protect
   DECLARE h3202611srvreq = i4 WITH noconstant(0), protect
   DECLARE h3202611srvrep = i4 WITH noconstant(0), protect
   DECLARE hsys = i4 WITH noconstant(0), protect
   DECLARE sysstat = i4 WITH noconstant(0), protect
   DECLARE slogtext = vc WITH noconstant(""), protect
   DECLARE access_encntr_req_number = i4 WITH constant(3202611), protect
   SUBROUTINE (get_accessible_encntr_ids_by_person_id(person_id=f8,concept=vc,
    disable_access_security_ind=i2(value,0)) =i4)
     SET h3202611srvmsg = uar_srvselectmessage(access_encntr_req_number)
     IF (h3202611srvmsg=0)
      SET getaccessibleencntrerrormsg = build2("*** Failed to select message ",build(
        access_encntr_req_number))
      RETURN(1)
     ENDIF
     SET h3202611srvreq = uar_srvcreaterequest(h3202611srvmsg)
     IF (h3202611srvreq=0)
      SET getaccessibleencntrerrormsg = build2("*** Failed to create request ",build(
        access_encntr_req_number))
      RETURN(1)
     ENDIF
     SET h3202611srvrep = uar_srvcreatereply(h3202611srvmsg)
     IF (h3202611srvrep=0)
      SET getaccessibleencntrerrormsg = build2("*** Failed to create reply ",build(
        access_encntr_req_number))
      RETURN(1)
     ENDIF
     DECLARE e_count = i4 WITH noconstant(0), protect
     DECLARE encounter_count = i4 WITH noconstant(0), protect
     DECLARE htransactionstatus = i4 WITH noconstant(0), protect
     DECLARE hencounter = i4 WITH noconstant(0), protect
     SET stat = uar_srvsetdouble(h3202611srvreq,"patientId",person_id)
     IF (disable_access_security_ind=0)
      SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm(concept))
     ELSE
      SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm("No_Security"))
     ENDIF
     SET stat = uar_srvexecute(h3202611srvmsg,h3202611srvreq,h3202611srvrep)
     IF (stat=0)
      SET htransactionstatus = uar_srvgetstruct(h3202611srvrep,"transactionStatus")
      IF (htransactionstatus=0)
       SET getaccessibleencntrerrormsg = build2("Failed to get transaction status from reply of ",
        build(access_encntr_req_number))
       RETURN(1)
      ELSE
       IF (uar_srvgetshort(htransactionstatus,"successIndicator") != 1)
        SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(
          access_encntr_req_number),". Debug Msg =",uar_srvgetstringptr(htransactionstatus,
          "debugErrorMessage"))
        RETURN(1)
       ELSE
        SET encounter_count = uar_srvgetitemcount(h3202611srvrep,"encounterIds")
        SET stat = alterlist(accessible_encntr_ids->accessible_encntrs,encounter_count)
        SET accessible_encntr_ids->accessible_encntrs_cnt = encounter_count
        FOR (e_count = 1 TO encounter_count)
         SET hencounter = uar_srvgetitem(h3202611srvrep,"encounterIds",(e_count - 1))
         SET accessible_encntr_ids->accessible_encntrs[e_count].accessible_encntr_id =
         uar_srvgetdouble(hencounter,"encounterId")
        ENDFOR
       ENDIF
      ENDIF
      RETURN(0)
     ELSE
      SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(access_encntr_req_number)
       )
      RETURN(1)
     ENDIF
   END ;Subroutine
   SUBROUTINE (get_accessible_encntr_ids_by_person_ids(accessible_encntr_person_ids=vc(ref),concept=
    vc,disable_access_security_ind=i2(value,0),user_id=f8(value,0.0)) =i4)
     SET h3202611srvmsg = uar_srvselectmessage(access_encntr_req_number)
     IF (h3202611srvmsg=0)
      SET getaccessibleencntrerrormsg = build2("*** Failed to select message ",build(
        access_encntr_req_number))
      RETURN(1)
     ENDIF
     SET h3202611srvreq = uar_srvcreaterequest(h3202611srvmsg)
     IF (h3202611srvreq=0)
      SET getaccessibleencntrerrormsg = build2("*** Failed to create request ",build(
        access_encntr_req_number))
      RETURN(1)
     ENDIF
     SET h3202611srvrep = uar_srvcreatereply(h3202611srvmsg)
     IF (h3202611srvrep=0)
      SET getaccessibleencntrerrormsg = build2("*** Failed to create reply ",build(
        access_encntr_req_number))
      RETURN(1)
     ENDIF
     DECLARE p_count = i4 WITH noconstant(0), protect
     DECLARE person_count = i4 WITH noconstant(0), protect
     DECLARE e_count = i4 WITH noconstant(0), protect
     DECLARE encounter_count = i4 WITH noconstant(0), protect
     DECLARE htransactionstatus = i4 WITH noconstant(0), protect
     DECLARE hencounter = i4 WITH noconstant(0), protect
     DECLARE curr_encntr_cnt = i4 WITH noconstant(0), protect
     DECLARE prev_encntr_cnt = i4 WITH noconstant(0), protect
     SET person_count = size(accessible_encntr_person_ids->person_ids,5)
     FOR (p_count = 1 TO person_count)
       SET stat = uar_srvsetdouble(h3202611srvreq,"patientId",accessible_encntr_person_ids->
        person_ids[p_count].person_id)
       IF (disable_access_security_ind=0)
        SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm(concept))
       ELSE
        SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm("No_Security"))
       ENDIF
       SET stat = uar_srvsetdouble(h3202611srvreq,"userId",user_id)
       SET stat = uar_srvexecute(h3202611srvmsg,h3202611srvreq,h3202611srvrep)
       IF (stat=0)
        SET htransactionstatus = uar_srvgetstruct(h3202611srvrep,"transactionStatus")
        IF (htransactionstatus=0)
         SET getaccessibleencntrerrormsg = build2("Failed to get transaction status from reply of ",
          build(access_encntr_req_number))
         RETURN(1)
        ELSE
         IF (uar_srvgetshort(htransactionstatus,"successIndicator") != 1)
          SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(
            access_encntr_req_number),". Debug Msg =",uar_srvgetstringptr(htransactionstatus,
            "debugErrorMessage"))
          RETURN(1)
         ELSE
          SET encounter_count = uar_srvgetitemcount(h3202611srvrep,"encounterIds")
          SET prev_encntr_cnt = curr_encntr_cnt
          SET curr_encntr_cnt += encounter_count
          SET stat = alterlist(accessible_encntr_ids->accessible_encntrs,curr_encntr_cnt)
          SET accessible_encntr_ids->accessible_encntrs_cnt = curr_encntr_cnt
          FOR (e_count = 1 TO encounter_count)
           SET hencounter = uar_srvgetitem(h3202611srvrep,"encounterIds",(e_count - 1))
           SET accessible_encntr_ids->accessible_encntrs[(e_count+ prev_encntr_cnt)].
           accessible_encntr_id = uar_srvgetdouble(hencounter,"encounterId")
          ENDFOR
         ENDIF
        ENDIF
       ELSE
        SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(
          access_encntr_req_number))
        RETURN(1)
       ENDIF
     ENDFOR
     RETURN(0)
   END ;Subroutine
   SUBROUTINE (get_accessible_encntr_ids_by_person_ids_map(accessible_encntr_person_ids=vc(ref),
    concept=vc,disable_access_security_ind=i2(value,0)) =i4)
     SET h3202611srvmsg = uar_srvselectmessage(access_encntr_req_number)
     IF (h3202611srvmsg=0)
      SET getaccessibleencntrerrormsg = build2("*** Failed to select message ",build(
        access_encntr_req_number))
      RETURN(1)
     ENDIF
     SET h3202611srvreq = uar_srvcreaterequest(h3202611srvmsg)
     IF (h3202611srvreq=0)
      SET getaccessibleencntrerrormsg = build2("*** Failed to create request ",build(
        access_encntr_req_number))
      RETURN(1)
     ENDIF
     SET h3202611srvrep = uar_srvcreatereply(h3202611srvmsg)
     IF (h3202611srvrep=0)
      SET getaccessibleencntrerrormsg = build2("*** Failed to create reply ",build(
        access_encntr_req_number))
      RETURN(1)
     ENDIF
     DECLARE p_count = i4 WITH noconstant(0), protect
     DECLARE person_count = i4 WITH noconstant(0), protect
     DECLARE e_count = i4 WITH noconstant(0), protect
     DECLARE encounter_count = i4 WITH noconstant(0), protect
     DECLARE htransactionstatus = i4 WITH noconstant(0), protect
     DECLARE hencounter = i4 WITH noconstant(0), protect
     SET person_count = size(accessible_encntr_person_ids->person_ids,5)
     SET accessible_encntr_ids_maps->persons_cnt = person_count
     FOR (p_count = 1 TO person_count)
       SET stat = uar_srvsetdouble(h3202611srvreq,"patientId",accessible_encntr_person_ids->
        person_ids[p_count].person_id)
       IF (disable_access_security_ind=0)
        SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm(concept))
       ELSE
        SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm("No_Security"))
       ENDIF
       SET accessible_encntr_ids_maps->persons[p_count].person_id = accessible_encntr_person_ids->
       person_ids[p_count].person_id
       SET stat = uar_srvexecute(h3202611srvmsg,h3202611srvreq,h3202611srvrep)
       IF (stat=0)
        SET htransactionstatus = uar_srvgetstruct(h3202611srvrep,"transactionStatus")
        IF (htransactionstatus=0)
         SET getaccessibleencntrerrormsg = build2("Failed to get transaction status from reply of ",
          build(access_encntr_req_number))
         RETURN(1)
        ELSE
         IF (uar_srvgetshort(htransactionstatus,"successIndicator") != 1)
          SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(
            access_encntr_req_number),". Debug Msg =",uar_srvgetstringptr(htransactionstatus,
            "debugErrorMessage"))
          RETURN(1)
         ELSE
          SET encounter_count = uar_srvgetitemcount(h3202611srvrep,"encounterIds")
          SET stat = alterlist(accessible_encntr_ids_maps->persons[p_count].accessible_encntrs,
           encounter_count)
          SET accessible_encntr_ids_maps->persons[p_count].accessible_encntrs_cnt = encounter_count
          FOR (e_count = 1 TO encounter_count)
           SET hencounter = uar_srvgetitem(h3202611srvrep,"encounterIds",(e_count - 1))
           SET accessible_encntr_ids_maps->persons[p_count].accessible_encntrs[e_count].
           accessible_encntr_id = uar_srvgetdouble(hencounter,"encounterId")
          ENDFOR
         ENDIF
        ENDIF
       ELSE
        SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(
          access_encntr_req_number))
        RETURN(1)
       ENDIF
     ENDFOR
     RETURN(0)
   END ;Subroutine
   SUBROUTINE (get_accessible_encntr_toggle(result=i4(ref)) =i4)
     DECLARE concept_policies_req_concept = vc WITH constant("PowerChart_Framework"), protect
     DECLARE featuretoggleflag = i2 WITH noconstant(false), protect
     DECLARE chartaccessflag = i2 WITH noconstant(false), protect
     DECLARE featuretogglestat = i2 WITH noconstant(0), protect
     DECLARE chartaccessstat = i2 WITH noconstant(0), protect
     SET featuretogglestat = isfeaturetoggleon(
      "urn:cerner:millennium:accessible-encounters-by-concept","urn:cerner:millennium",
      featuretoggleflag)
     CALL uar_syscreatehandle(hsys,sysstat)
     IF (hsys > 0)
      SET slogtext = build2("get_accessible_encntr_toggle - featureToggleStat is ",build(
        featuretogglestat))
      CALL uar_sysevent(hsys,4,"pm_get_access_encntr_by_person",nullterm(slogtext))
      SET slogtext = build2("get_accessible_encntr_toggle - featureToggleFlag is ",build(
        featuretoggleflag))
      CALL uar_sysevent(hsys,4,"pm_get_access_encntr_by_person",nullterm(slogtext))
      CALL uar_sysdestroyhandle(hsys)
     ENDIF
     IF (featuretogglestat=0
      AND featuretoggleflag=true)
      SET result = 1
      RETURN(0)
     ENDIF
     IF (featuretogglestat != 0)
      CALL uar_syscreatehandle(hsys,sysstat)
      IF (hsys > 0)
       SET slogtext = build("Feature toggle service returned failure status.")
       CALL uar_sysevent(hsys,1,"pm_get_access_encntr_by_person",nullterm(slogtext))
       CALL uar_sysdestroyhandle(hsys)
      ENDIF
     ENDIF
     SET chartaccessstat = ischartaccesson(concept_policies_req_concept,chartaccessflag)
     CALL uar_syscreatehandle(hsys,sysstat)
     IF (hsys > 0)
      SET slogtext = build2("get_accessible_encntr_toggle - chartAccessStat is ",build(
        chartaccessstat))
      CALL uar_sysevent(hsys,4,"pm_get_access_encntr_by_person",nullterm(slogtext))
      SET slogtext = build2("get_accessible_encntr_toggle - chartAccessFlag is ",build(
        chartaccessflag))
      CALL uar_sysevent(hsys,4,"pm_get_access_encntr_by_person",nullterm(slogtext))
      CALL uar_sysdestroyhandle(hsys)
     ENDIF
     IF (chartaccessstat != 0)
      RETURN(1)
     ENDIF
     IF (chartaccessflag=true)
      SET result = 1
     ENDIF
     RETURN(0)
   END ;Subroutine
   SUBROUTINE (isfeaturetoggleon(togglename=vc,systemidentifier=vc,featuretoggleflag=i2(ref)) =i4)
     DECLARE feature_toggle_req_number = i4 WITH constant(2030001), protect
     DECLARE toggle = vc WITH noconstant(""), protect
     DECLARE htransactionstatus = i4 WITH noconstant(0), protect
     DECLARE hfeatureflagmsg = i4 WITH noconstant(0), protect
     DECLARE hfeatureflagreq = i4 WITH noconstant(0), protect
     DECLARE hfeatureflagrep = i4 WITH noconstant(0), protect
     DECLARE rep2030001count = i4 WITH noconstant(0), protect
     DECLARE rep2030001successind = i2 WITH noconstant(0), protect
     SET hfeatureflagmsg = uar_srvselectmessage(feature_toggle_req_number)
     IF (hfeatureflagmsg=0)
      RETURN(0)
     ENDIF
     SET hfeatureflagreq = uar_srvcreaterequest(hfeatureflagmsg)
     IF (hfeatureflagreq=0)
      RETURN(0)
     ENDIF
     SET hfeatureflagrep = uar_srvcreatereply(hfeatureflagmsg)
     IF (hfeatureflagrep=0)
      RETURN(0)
     ENDIF
     SET stat = uar_srvsetstring(hfeatureflagreq,"system_identifier",nullterm(systemidentifier))
     SET stat = uar_srvsetshort(hfeatureflagreq,"ignore_overrides_ind",1)
     IF (uar_srvexecute(hfeatureflagmsg,hfeatureflagreq,hfeatureflagrep)=0)
      SET htransactionstatus = uar_srvgetstruct(hfeatureflagrep,"transaction_status")
      IF (htransactionstatus != 0)
       SET rep2030001successind = uar_srvgetshort(htransactionstatus,"success_ind")
      ELSE
       SET getaccessibleencntrtoggleerrormsg = build2(
        "Failed to get transaction status from reply of ",build(feature_toggle_req_number))
       RETURN(1)
      ENDIF
      IF (rep2030001successind=1)
       IF (uar_srvgetitem(hfeatureflagrep,"feature_toggle_keys",0) > 0)
        SET rep2030001count = uar_srvgetitemcount(hfeatureflagrep,"feature_toggle_keys")
        FOR (loop = 0 TO (rep2030001count - 1))
         SET toggle = uar_srvgetstringptr(uar_srvgetitem(hfeatureflagrep,"feature_toggle_keys",loop),
          "key")
         IF (togglename=toggle)
          SET featuretoggleflag = true
          RETURN(0)
         ENDIF
        ENDFOR
       ENDIF
      ELSE
       SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
         feature_toggle_req_number),". Debug Msg =",uar_srvgetstringptr(htransactionstatus,
         "debug_error_message"))
       RETURN(1)
      ENDIF
     ELSE
      SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
        feature_toggle_req_number))
      RETURN(1)
     ENDIF
     RETURN(0)
   END ;Subroutine
   SUBROUTINE (ischartaccesson(concept=vc,chartaccessflag=i2(ref)) =i4)
     DECLARE concept_policies_req_number = i4 WITH constant(3202590), protect
     DECLARE htransactionstatus = i4 WITH noconstant(0), protect
     DECLARE hconceptpoliciesreqstruct = i4 WITH noconstant(0), protect
     DECLARE hconceptpoliciesmsg = i4 WITH noconstant(0), protect
     DECLARE hconceptpoliciesreq = i4 WITH noconstant(0), protect
     DECLARE hconceptpoliciesrep = i4 WITH noconstant(0), protect
     DECLARE hconceptpoliciesstruct = i4 WITH noconstant(0), protect
     DECLARE rep3202590count = i4 WITH noconstant(0), protect
     DECLARE rep3202590successind = i2 WITH noconstant(0), protect
     SET hconceptpoliciesmsg = uar_srvselectmessage(concept_policies_req_number)
     IF (hconceptpoliciesmsg=0)
      RETURN(0)
     ENDIF
     SET hconceptpoliciesreq = uar_srvcreaterequest(hconceptpoliciesmsg)
     IF (hconceptpoliciesreq=0)
      RETURN(0)
     ENDIF
     SET hconceptpoliciesrep = uar_srvcreatereply(hconceptpoliciesmsg)
     IF (hconceptpoliciesrep=0)
      RETURN(0)
     ENDIF
     SET hconceptpoliciesreqstruct = uar_srvadditem(hconceptpoliciesreq,"concepts")
     IF (hconceptpoliciesreqstruct > 0)
      SET stat = uar_srvsetstring(hconceptpoliciesreqstruct,"concept",nullterm(concept))
      IF (uar_srvexecute(hconceptpoliciesmsg,hconceptpoliciesreq,hconceptpoliciesrep)=0)
       SET htransactionstatus = uar_srvgetstruct(hconceptpoliciesrep,"transaction_status")
       IF (htransactionstatus != 0)
        SET rep3202590successind = uar_srvgetshort(htransactionstatus,"success_ind")
       ELSE
        SET getaccessibleencntrtoggleerrormsg = build2(
         "Failed to get transaction status from reply of ",build(concept_policies_req_number))
        RETURN(1)
       ENDIF
       IF (rep3202590successind=1)
        IF (uar_srvgetitem(hconceptpoliciesrep,"concept_policies_batch",0) > 0)
         SET rep3202590count = uar_srvgetitemcount(hconceptpoliciesrep,"concept_policies_batch")
         FOR (loop = 0 TO (rep3202590count - 1))
          SET hconceptpoliciesstruct = uar_srvgetstruct(uar_srvgetitem(hconceptpoliciesrep,
            "concept_policies_batch",loop),"policies")
          IF (hconceptpoliciesstruct > 0)
           IF (uar_srvgetshort(hconceptpoliciesstruct,"chart_access_group_security_ind")=1)
            SET chartaccessflag = true
            RETURN(0)
           ENDIF
          ELSE
           SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
             concept_policies_req_number),build("Found an invalid hConceptPoliciesStruct : ",
             hconceptpoliciesstruct))
           RETURN(1)
          ENDIF
         ENDFOR
        ENDIF
       ELSE
        SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
          concept_policies_req_number),". Debug Msg =",uar_srvgetstringptr(htransactionstatus,
          "debug_error_message"))
        RETURN(1)
       ENDIF
      ELSE
       SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
         concept_policies_req_number))
       RETURN(1)
      ENDIF
     ELSE
      SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
        concept_policies_req_number),build("Found an invalid hConceptPoliciesReqStruct : ",
        hconceptpoliciesreqstruct))
      RETURN(1)
     ENDIF
     RETURN(0)
   END ;Subroutine
   SUBROUTINE (getaccessibleencounters(person_id=f8,debug_ind=i2) =i4)
     DECLARE accessible_encntrs_stat = i4 WITH protect, noconstant(0)
     DECLARE chart_access_stat = i2 WITH protect, noconstant(0)
     DECLARE chart_access_flag = i2 WITH protect, noconstant(false)
     DECLARE mrd_concept_string = vc WITH protect, constant("MEDICATION_RECORD")
     SET accessible_encntrs_stat = get_accessible_encntr_ids_by_person_id(person_id,
      mrd_concept_string)
     IF (accessible_encntrs_stat=0)
      IF (debug_ind)
       CALL echo("User's Accessible Encounters: ")
       CALL echorecord(accessible_encntr_ids)
      ENDIF
      RETURN(0)
     ELSE
      IF (debug_ind)
       CALL echo(build("Encounter Retrieval Failed because:",getaccessibleencntrerrormsg))
      ENDIF
      SET chart_access_stat = ischartaccesson(mrd_concept_string,chart_access_flag)
      IF (chart_access_stat=0
       AND chart_access_flag=false)
       IF (debug_ind)
        CALL echo("Chart Access is disabled, so legacy implementation can be used")
       ENDIF
       RETURN(1)
      ELSE
       IF (debug_ind)
        CALL echo("Chart Access is enabled, so legacy implementation can't be used")
       ENDIF
       RETURN(2)
      ENDIF
     ENDIF
   END ;Subroutine
   SET modify = predeclare
   FOR (lidx1 = 1 TO value(size(reply->qual,5)))
    SET encntrs_api_stat = getaccessibleencounters(reply->qual[lidx1].person_id,debug_ind)
    IF (encntrs_api_stat=0)
     SET lencntrcnt = accessible_encntr_ids->accessible_encntrs_cnt
     IF (lencntrcnt > 0)
      IF ((reply->qual[lidx1].encntr_id > 0))
       SET lpos = locateval(lencntridx,1,lencntrcnt,reply->qual[lidx1].encntr_id,
        accessible_encntr_ids->accessible_encntrs[lencntridx].accessible_encntr_id)
       IF (lpos > 0)
        SET reply->qual[lidx1].privilege_ind = 1
       ENDIF
      ELSE
       IF (lencntrcnt > 0)
        SET reply->qual[lidx1].privilege_ind = 1
       ENDIF
      ENDIF
     ENDIF
    ELSEIF (encntrs_api_stat=1)
     CALL checkorgsecurity(null)
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE checkorgsecurity(null)
   IF (debug_ind)
    CALL echo("*** Checking Org Security ***")
   ENDIF
   DECLARE borgsecurity = i2 WITH protect, noconstant(0)
   DECLARE bconfidentialsecurity = i2 WITH protect, noconstant(0)
   DECLARE lconfidentiallevel = i4 WITH protect, noconstant(0)
   DECLARE lorgcnt = i4 WITH protect, noconstant(0)
   DECLARE lorgidx = i4 WITH protect, noconstant(0)
   DECLARE lidx1 = i4 WITH protect, noconstant(0)
   DECLARE lpos = i4 WITH protect, noconstant(0)
   IF (validate(ccldminfo->mode,0))
    SET borgsecurity = ccldminfo->sec_org_reltn
    SET bconfidentialsecurity = ccldminfo->sec_confid
   ELSE
    SELECT INTO "nl:"
     FROM dm_info di
     PLAN (di
      WHERE di.info_domain="SECURITY"
       AND di.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID"))
     DETAIL
      IF (di.info_name="SEC_ORG_RELTN"
       AND di.info_number=1)
       borgsecurity = 1
      ELSEIF (di.info_name="SEC_CONFID"
       AND di.info_number=1)
       bconfidentialsecurity = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (debug_ind)
    CALL echo(build("*** OrgSecInd: ",borgsecurity))
    CALL echo(build("*** ConfidentialInd: ",bconfidentialsecurity))
   ENDIF
   IF (borgsecurity=1)
    SET modify = nopredeclare
    IF (validate(_sacrtl_org_inc_,99999)=99999)
     DECLARE _sacrtl_org_inc_ = i2 WITH constant(1)
     RECORD sac_org(
       1 organizations[*]
         2 organization_id = f8
         2 confid_cd = f8
         2 confid_level = i4
     )
     EXECUTE secrtl
     EXECUTE sacrtl
     DECLARE orgcnt = i4 WITH protected, noconstant(0)
     DECLARE secstat = i2
     DECLARE logontype = i4 WITH protect, noconstant(- (1))
     DECLARE dynamic_org_ind = i4 WITH protect, noconstant(- (1))
     DECLARE dcur_trustid = f8 WITH protect, noconstant(0.0)
     DECLARE dynorg_enabled = i4 WITH constant(1)
     DECLARE dynorg_disabled = i4 WITH constant(0)
     DECLARE logontype_nhs = i4 WITH constant(1)
     DECLARE logontype_legacy = i4 WITH constant(0)
     DECLARE confid_cnt = i4 WITH protected, noconstant(0)
     RECORD confid_codes(
       1 list[*]
         2 code_value = f8
         2 coll_seq = f8
     )
     CALL uar_secgetclientlogontype(logontype)
     CALL echo(build("logontype:",logontype))
     IF (logontype != logontype_nhs)
      SET dynamic_org_ind = dynorg_disabled
     ENDIF
     IF (logontype=logontype_nhs)
      SUBROUTINE (getdynamicorgpref(dtrustid=f8) =i4)
        DECLARE scur_trust = vc
        DECLARE pref_val = vc
        DECLARE is_enabled = i4 WITH constant(1)
        DECLARE is_disabled = i4 WITH constant(0)
        SET scur_trust = cnvtstring(dtrustid)
        SET scur_trust = concat(scur_trust,".00")
        IF ( NOT (validate(pref_req,0)))
         RECORD pref_req(
           1 write_ind = i2
           1 delete_ind = i2
           1 pref[*]
             2 contexts[*]
               3 context = vc
               3 context_id = vc
             2 section = vc
             2 section_id = vc
             2 subgroup = vc
             2 entries[*]
               3 entry = vc
               3 values[*]
                 4 value = vc
         )
        ENDIF
        IF ( NOT (validate(pref_rep,0)))
         RECORD pref_rep(
           1 pref[*]
             2 section = vc
             2 section_id = vc
             2 subgroup = vc
             2 entries[*]
               3 pref_exists_ind = i2
               3 entry = vc
               3 values[*]
                 4 value = vc
           1 status_data
             2 status = c1
             2 subeventstatus[1]
               3 operationname = c25
               3 operationstatus = c1
               3 targetobjectname = c25
               3 targetobjectvalue = vc
         )
        ENDIF
        SET stat = alterlist(pref_req->pref,1)
        SET stat = alterlist(pref_req->pref[1].contexts,2)
        SET stat = alterlist(pref_req->pref[1].entries,1)
        SET pref_req->pref[1].contexts[1].context = "organization"
        SET pref_req->pref[1].contexts[1].context_id = scur_trust
        SET pref_req->pref[1].contexts[2].context = "default"
        SET pref_req->pref[1].contexts[2].context_id = "system"
        SET pref_req->pref[1].section = "workflow"
        SET pref_req->pref[1].section_id = "UK Trust Security"
        SET pref_req->pref[1].entries[1].entry = "dynamic organizations"
        EXECUTE ppr_preferences  WITH replace("REQUEST","PREF_REQ"), replace("REPLY","PREF_REP")
        IF (cnvtupper(pref_rep->pref[1].entries[1].values[1].value)="ENABLED")
         RETURN(is_enabled)
        ELSE
         RETURN(is_disabled)
        ENDIF
      END ;Subroutine
      DECLARE hprop = i4 WITH protect, noconstant(0)
      DECLARE tmpstat = i2
      DECLARE spropname = vc
      DECLARE sroleprofile = vc
      SET hprop = uar_srvcreateproperty()
      SET tmpstat = uar_secgetclientattributesext(5,hprop)
      SET spropname = uar_srvfirstproperty(hprop)
      SET sroleprofile = uar_srvgetpropertyptr(hprop,nullterm(spropname))
      SELECT INTO "nl:"
       FROM prsnl_org_reltn_type prt,
        prsnl_org_reltn por
       PLAN (prt
        WHERE prt.role_profile=sroleprofile
         AND prt.active_ind=1
         AND prt.beg_effective_dt_tm <= cnvtdatetime(sysdate)
         AND prt.end_effective_dt_tm > cnvtdatetime(sysdate))
        JOIN (por
        WHERE (por.organization_id= Outerjoin(prt.organization_id))
         AND (por.person_id= Outerjoin(prt.prsnl_id))
         AND (por.active_ind= Outerjoin(1))
         AND (por.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
         AND (por.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
       ORDER BY por.prsnl_org_reltn_id
       DETAIL
        orgcnt = 1, secstat = alterlist(sac_org->organizations,1), user_person_id = prt.prsnl_id,
        sac_org->organizations[1].organization_id = prt.organization_id, sac_org->organizations[1].
        confid_cd = por.confid_level_cd, confid_cd = uar_get_collation_seq(por.confid_level_cd),
        sac_org->organizations[1].confid_level =
        IF (confid_cd > 0) confid_cd
        ELSE 0
        ENDIF
       WITH maxrec = 1
      ;end select
      SET dcur_trustid = sac_org->organizations[1].organization_id
      SET dynamic_org_ind = getdynamicorgpref(dcur_trustid)
      CALL uar_srvdestroyhandle(hprop)
     ENDIF
     IF (dynamic_org_ind=dynorg_disabled)
      SET confid_cnt = 0
      SELECT INTO "NL:"
       c.code_value, c.collation_seq
       FROM code_value c
       WHERE c.code_set=87
       DETAIL
        confid_cnt += 1
        IF (mod(confid_cnt,10)=1)
         secstat = alterlist(confid_codes->list,(confid_cnt+ 9))
        ENDIF
        confid_codes->list[confid_cnt].code_value = c.code_value, confid_codes->list[confid_cnt].
        coll_seq = c.collation_seq
       WITH nocounter
      ;end select
      SET secstat = alterlist(confid_codes->list,confid_cnt)
      SELECT DISTINCT INTO "nl:"
       FROM prsnl_org_reltn por
       WHERE (por.person_id=reqinfo->updt_id)
        AND por.active_ind=1
        AND por.beg_effective_dt_tm < cnvtdatetime(sysdate)
        AND por.end_effective_dt_tm >= cnvtdatetime(sysdate)
       HEAD REPORT
        IF (orgcnt > 0)
         secstat = alterlist(sac_org->organizations,100)
        ENDIF
       DETAIL
        orgcnt += 1
        IF (mod(orgcnt,100)=1)
         secstat = alterlist(sac_org->organizations,(orgcnt+ 99))
        ENDIF
        sac_org->organizations[orgcnt].organization_id = por.organization_id, sac_org->organizations[
        orgcnt].confid_cd = por.confid_level_cd
       FOOT REPORT
        secstat = alterlist(sac_org->organizations,orgcnt)
       WITH nocounter
      ;end select
      SELECT INTO "NL:"
       FROM (dummyt d1  WITH seq = value(orgcnt)),
        (dummyt d2  WITH seq = value(confid_cnt))
       PLAN (d1)
        JOIN (d2
        WHERE (sac_org->organizations[d1.seq].confid_cd=confid_codes->list[d2.seq].code_value))
       DETAIL
        sac_org->organizations[d1.seq].confid_level = confid_codes->list[d2.seq].coll_seq
       WITH nocounter
      ;end select
     ELSEIF (dynamic_org_ind=dynorg_enabled)
      DECLARE nhstrustchild_org_org_reltn_cd = f8
      SET nhstrustchild_org_org_reltn_cd = uar_get_code_by("MEANING",369,"NHSTRUSTCHLD")
      SELECT INTO "nl:"
       FROM org_org_reltn oor
       PLAN (oor
        WHERE oor.organization_id=dcur_trustid
         AND oor.active_ind=1
         AND oor.beg_effective_dt_tm < cnvtdatetime(sysdate)
         AND oor.end_effective_dt_tm >= cnvtdatetime(sysdate)
         AND oor.org_org_reltn_cd=nhstrustchild_org_org_reltn_cd)
       HEAD REPORT
        IF (orgcnt > 0)
         secstat = alterlist(sac_org->organizations,10)
        ENDIF
       DETAIL
        IF (oor.related_org_id > 0)
         orgcnt += 1
         IF (mod(orgcnt,10)=1)
          secstat = alterlist(sac_org->organizations,(orgcnt+ 9))
         ENDIF
         sac_org->organizations[orgcnt].organization_id = oor.related_org_id
        ENDIF
       FOOT REPORT
        secstat = alterlist(sac_org->organizations,orgcnt)
       WITH nocounter
      ;end select
     ELSE
      CALL echo(build("Unexpected login type: ",dynamimc_org_ind))
     ENDIF
    ENDIF
    SET modify = predeclare
    SET lorgcnt = size(sac_org->organizations,5)
   ENDIF
   IF (debug_ind)
    CALL echorecord(sac_org)
   ENDIF
   FOR (lidx1 = 1 TO value(size(reply->qual,5)))
     IF (borgsecurity=0
      AND bconfidentialsecurity=0)
      IF (debug_ind)
       CALL echo(
        "*** privilege_ind = 1 override because OrgSecurity is OFF and ConfidentialSecurity is OFF")
      ENDIF
      SET reply->qual[lidx1].privilege_ind = 1
     ELSE
      IF ((reply->qual[lidx1].encntr_id > 0))
       SELECT INTO "nl:"
        FROM encounter e
        PLAN (e
         WHERE (e.encntr_id=reply->qual[lidx1].encntr_id))
        DETAIL
         lpos = locateval(lorgidx,1,lorgcnt,e.organization_id,sac_org->organizations[lorgidx].
          organization_id)
         IF (lpos > 0)
          IF (bconfidentialsecurity=1)
           lconfidentiallevel = uar_get_collation_seq(e.confid_level_cd)
           IF ((sac_org->organizations[lpos].confid_level >= lconfidentiallevel))
            IF (debug_ind)
             CALL echo(
             "*** privilege_ind = 1 because user's org confid_level >= encounter confid_level")
            ENDIF
            reply->qual[lidx1].privilege_ind = 1
           ENDIF
          ELSE
           IF (debug_ind)
            CALL echo(
            "*** privilege_ind = 1 because user has org access and confidential security is off")
           ENDIF
           reply->qual[lidx1].privilege_ind = 1
          ENDIF
         ENDIF
        WITH nocounter
       ;end select
      ELSE
       SELECT INTO "nl:"
        FROM encounter e
        PLAN (e
         WHERE (e.person_id=reply->qual[lidx1].person_id))
        DETAIL
         lpos = locateval(lorgidx,1,lorgcnt,e.organization_id,sac_org->organizations[lorgidx].
          organization_id)
         IF (lpos > 0)
          IF (bconfidentialsecurity=1)
           lconfidentiallevel = uar_get_collation_seq(e.confid_level_cd)
           IF ((sac_org->organizations[lpos].confid_level >= lconfidentiallevel))
            IF (debug_ind)
             CALL echo(
             "*** privilege_ind = 1 because user's org confid_level >= encounter confid_level")
            ENDIF
            reply->qual[lidx1].privilege_ind = 1
           ENDIF
          ELSE
           IF (debug_ind)
            CALL echo(
            "*** privilege_ind = 1 because user has org access and confidential security is off")
           ENDIF
           reply->qual[lidx1].privilege_ind = 1
          ENDIF
         ENDIF
        WITH nocounter
       ;end select
      ENDIF
      IF ((reply->qual[lidx1].privilege_ind=0))
       SELECT INTO "nl:"
        FROM person_prsnl_reltn ppr
        PLAN (ppr
         WHERE (ppr.person_id=reply->qual[lidx1].person_id)
          AND (ppr.prsnl_person_id=reqinfo->updt_id)
          AND ppr.end_effective_dt_tm >= cnvtdatetime(sysdate)
          AND ppr.active_ind=1)
        DETAIL
         IF (debug_ind)
          CALL echo("*** privilege_ind = 1 override because PPR exists")
         ENDIF
         reply->qual[lidx1].privilege_ind = 1
        WITH nocounter
       ;end select
      ENDIF
      IF ((reply->qual[lidx1].privilege_ind=0))
       IF ((reply->qual[lidx1].encntr_id > 0))
        SELECT INTO "nl:"
         FROM encntr_prsnl_reltn epr
         PLAN (epr
          WHERE (epr.encntr_id=reply->qual[lidx1].encntr_id)
           AND (epr.prsnl_person_id=reqinfo->updt_id)
           AND epr.end_effective_dt_tm >= cnvtdatetime(sysdate)
           AND epr.active_ind=1)
         DETAIL
          IF (debug_ind)
           CALL echo("*** privilege_ind = 1 override because EPR exists for encntr")
          ENDIF
          reply->qual[lidx1].privilege_ind = 1
         WITH nocounter
        ;end select
       ELSE
        SELECT INTO "nl:"
         FROM encounter e,
          encntr_prsnl_reltn epr
         PLAN (e
          WHERE (e.person_id=reply->qual[lidx1].person_id))
          JOIN (epr
          WHERE epr.encntr_id=e.encntr_id
           AND (epr.prsnl_person_id=reqinfo->updt_id)
           AND epr.end_effective_dt_tm >= cnvtdatetime(sysdate)
           AND epr.active_ind=1)
         DETAIL
          IF (debug_ind)
           CALL echo("*** privilege_ind = 1 override because EPR exists")
          ENDIF
          reply->qual[lidx1].privilege_ind = 1
         WITH nocounter
        ;end select
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SET last_mod = "011"
 SET mod_date = "03/03/2021"
 SET modify = nopredeclare
END GO
