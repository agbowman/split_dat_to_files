CREATE PROGRAM aps_retrieve_dicom:dba
 SET modify = predeclare
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 EXECUTE aps_mmf_migration_common:dba
 DECLARE lstat = i4 WITH protect, noconstant(0)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 image_pathname = vc
    1 dicom_services_handle = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ELSE
  SET lstat = initrec(reply)
  IF (size(reply->status_data.subeventstatus,5) != 1)
   SET lstat = alter(reply->status_data.subeventstatus,1)
  ENDIF
 ENDIF
 DECLARE initializedicom(null) = i4 WITH private
 DECLARE logcclerror(soperation=vc(value),stable=vc(value)) = i2 WITH protect
 DECLARE sbuffer = c4000 WITH protect, noconstant(" ")
 DECLARE bshutdownonexit = i2 WITH protect, noconstant(1)
 DECLARE scclerror = vc WITH protect, noconstant(" ")
 DECLARE glmsglvl_error = i4 WITH protect, constant(0)
 DECLARE glmsglvl_warning = i4 WITH protect, constant(1)
 DECLARE glmsglvl_audit = i4 WITH protect, constant(2)
 DECLARE glmsglvl_info = i4 WITH protect, constant(3)
 DECLARE glmsglvl_debug = i4 WITH protect, constant(4)
 SET reply->dicom_services_handle = request->dicom_services_handle
 SET reply->image_pathname = " "
 SET reply->status = "F"
 COMMIT
 IF (textlen(trim(request->dicom_uid,3)) <= 1)
  SET reply->status = "S"
  GO TO exit_script
 ENDIF
 IF ((reply->dicom_services_handle=0))
  SET reply->dicom_services_handle = initializedicom(null)
  IF ((reply->dicom_services_handle=0))
   GO TO exit_script
  ENDIF
 ENDIF
 SET lstat = uar_aps_retrievedicom(reply->dicom_services_handle,nullterm(trim(request->dicom_uid,3)))
 IF (lstat=0)
  CALL subevent_add("APS_RetrieveDicom","F","Dicom Image",request->dicom_uid)
  GO TO exit_script
 ENDIF
 SET lstat = uar_aps_dicomgetfilename(reply->dicom_services_handle,sbuffer,4000)
 IF (lstat <= 0)
  CALL subevent_add("APS_DicomGetFileName","F","UAR","failed to get filename")
  GO TO exit_script
 ENDIF
 SET reply->image_pathname = substring(1,lstat,sbuffer)
 SET bshutdownonexit = 0
 SET reply->status = "S"
 GO TO exit_script
 SUBROUTINE initializedicom(null)
   DECLARE ldicomhandle = i4 WITH protect, noconstant(0)
   DECLARE lprophandle = i4 WITH protect, noconstant(0)
   DECLARE lstat = i4 WITH protect, noconstant(0)
   DECLARE saetitle = vc WITH protect, noconstant(" ")
   DECLARE saehostname = vc WITH protect, noconstant(" ")
   DECLARE saehostaddr = vc WITH protect, noconstant(" ")
   DECLARE saefulladdr = vc WITH protect, noconstant(" ")
   DECLARE laehostport = i4 WITH protect, noconstant(0)
   DECLARE daeid = f8 WITH protect, noconstant(0.0)
   DECLARE lqualcnt = i4 WITH protect, noconstant(0)
   DECLARE nerrorind = i2 WITH protect, noconstant(0)
   SET lstat = error(scclerror,1)
   SET lprophandle = uar_srv_createproplist()
   IF (lprophandle=0)
    CALL subevent_add("SRV_CreatePropList","F","UAR","failure")
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    di.info_name
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain="ANATOMIC PATHOLOGY"
      AND di.info_name="IMG MIGRATE*")
    DETAIL
     lstat = uar_srv_setpropstring(lprophandle,nullterm(trim(di.info_name)),nullterm(trim(di
        .info_char)))
    WITH nocounter
   ;end select
   IF (logcclerror("SELECT","DM_INFO")=0)
    SET lstat = uar_srv_closehandle(lprophandle)
    RETURN(0)
   ENDIF
   SET ldicomhandle = uar_aps_initializedicom(lprophandle)
   IF (lprophandle != 0)
    SET lstat = uar_srv_closehandle(lprophandle)
   ENDIF
   IF (ldicomhandle=0)
    CALL subevent_add("APS_InitializeDicom","F","UAR","failure")
    RETURN(0)
   ENDIF
   SET nerrorind = 0
   SET laehostport = uar_aps_dicomgetlocalport(ldicomhandle)
   SET lstat = uar_aps_dicomgetlocaladdr(ldicomhandle,sbuffer,4000)
   IF (lstat <= 0)
    CALL subevent_add("APS_DicomGetLocalAddr","F","UAR","failure")
    SET nerrorind = 1
   ELSE
    SET saehostaddr = substring(1,lstat,sbuffer)
   ENDIF
   SET lstat = uar_aps_dicomgetlocalfulladdr(ldicomhandle,sbuffer,4000)
   IF (lstat <= 0)
    CALL subevent_add("APS_DicomGetLocalFullAddr","F","UAR","failure")
    SET nerrorind = 1
   ELSE
    SET saefulladdr = substring(1,lstat,sbuffer)
   ENDIF
   SET lstat = uar_aps_dicomgetlocalname(ldicomhandle,sbuffer,4000)
   IF (lstat <= 0)
    CALL subevent_add("APS_DicomGetLocalName","F","UAR","failure")
    SET nerrorind = 1
   ELSE
    SET saehostname = substring(1,lstat,sbuffer)
   ENDIF
   SET lstat = uar_aps_dicomgetlocaltitle(ldicomhandle,sbuffer,4000)
   IF (lstat <= 0)
    CALL subevent_add("APS_DicomGetLocalName","F","UAR","failure")
    SET nerrorind = 1
   ELSE
    SET saetitle = substring(1,lstat,sbuffer)
   ENDIF
   IF (nerrorind != 0)
    SET lstat = uar_aps_closedicom(ldicomhandle)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    de.ae_id
    FROM pvw_dicomae de
    PLAN (de
     WHERE de.ae_title=saetitle)
    DETAIL
     daeid = de.ae_id
    WITH nocounter, forupdate
   ;end select
   SET lqualcnt = curqual
   IF (logcclerror("SELECT","PVW_DICOMAE")=0)
    ROLLBACK
    SET lstat = uar_aps_closedicom(ldicomhandle)
    RETURN(0)
   ENDIF
   IF (lqualcnt=0)
    SELECT INTO "nl:"
     seq_nbr = seq(proview_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      daeid = cnvtreal(seq_nbr)
     WITH format, counter
    ;end select
    IF (logcclerror("SELECT","proview_seq")=0)
     ROLLBACK
     SET lstat = uar_aps_closedicom(ldicomhandle)
     RETURN(0)
    ENDIF
    INSERT  FROM pvw_dicomae p
     SET p.ae_id = daeid, p.ae_title = saetitle, p.ae_host_name = saehostname,
      p.ae_host_addr = saehostaddr, p.port_number = laehostport, p.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
      updt_applctx,
      p.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (logcclerror("INSERT","PVW_DICOMAE")=0)
     ROLLBACK
     SET lstat = uar_aps_closedicom(ldicomhandle)
     RETURN(0)
    ENDIF
   ELSEIF (curqual=1)
    UPDATE  FROM pvw_dicomae p
     SET p.ae_title = saetitle, p.ae_host_name = saehostname, p.ae_host_addr = saehostaddr,
      p.port_number = laehostport, p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo
      ->updt_id,
      p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = (p
      .updt_cnt+ 1)
     WHERE p.ae_id=daeid
     WITH nocounter
    ;end update
    SET lqualcnt = curqual
    IF (logcclerror("UPDATE","PVW_DICOMAE")=0)
     ROLLBACK
     SET lstat = uar_aps_closedicom(ldicomhandle)
     RETURN(0)
    ENDIF
    IF (lqualcnt != 1)
     ROLLBACK
     CALL subevent_add("UPDATE","F","PVW_DICOMAE","update statement did not qualify 1 row")
     SET lstat = uar_aps_closedicom(ldicomhandle)
     RETURN(0)
    ENDIF
   ELSE
    ROLLBACK
    CALL subevent_add("SELECT","F","PVW_DICOMAE",concat("Multiple rows with title=",saetitle))
    SET lstat = uar_aps_closedicom(ldicomhandle)
    RETURN(0)
   ENDIF
   COMMIT
   SET lstat = uar_aps_logdicom(glmsglvl_audit,nullterm("aps_retrieve_dicom"),nullterm("registered"),
    nullterm(concat(saetitle," - ",saefulladdr)))
   RETURN(ldicomhandle)
 END ;Subroutine
 SUBROUTINE logcclerror(soperation,stablename)
  IF (error(scclerror,1) != 0)
   CALL subevent_add(build(soperation),"F",build(stablename),scclerror)
   RETURN(0)
  ENDIF
  RETURN(1)
 END ;Subroutine
#exit_script
 IF (bshutdownonexit)
  IF ((reply->dicom_services_handle != 0))
   SET lstat = uar_aps_closedicom(reply->dicom_services_handle)
   SET reply->dicom_services_handle = 0
  ENDIF
 ENDIF
END GO
