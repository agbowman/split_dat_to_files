CREATE PROGRAM aps_mmf_store_image:dba
 SET modify = predeclare
 SUBROUTINE (subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value
   )) =null WITH protect)
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
 IF (validate(dmsmanagementrtl_def,999)=999)
  DECLARE dmsmanagementrtl_def = i2 WITH persist
  SET dmsmanagementrtl_def = 1
  FREE SET uar_dmsm_addxref
  DECLARE uar_dmsm_addxref(p1=i4(value),p2=vc(ref),p3=f8(ref)) = i4 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", uar = "DMSM_AddXRef",
  persist
  DECLARE uar_dmsm_createassociation(p1=vc(ref),p2=vc(ref),p2=i2(value)) = i1 WITH image_axp =
  "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_CreateAssociation", persist
  DECLARE uar_dmsm_createcopy(p1=vc(ref),p2=h(value),p3=i1(value),p4=i1(value),p5=i1(value)) = i4
  WITH image_axp = "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win
   = "dmsmanagement",
  uar = "DMSM_CreateCopy", persist
  DECLARE uar_dmsm_getcontenttypelist() = i4 WITH image_axp = "dmsmanagement", image_aix =
  "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetContentTypeList", persist
  DECLARE uar_dmsm_getcontenttype(p1=vc(ref)) = i4 WITH image_axp = "dmsmanagement", image_aix =
  "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetContentType", persist
  DECLARE uar_dmsm_getcontenttypeprops(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix
   = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetContentTypeProps", persist
  DECLARE uar_dmsm_createclassifiedmedia(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_CreateClassifiedMedia", persist
  DECLARE uar_dmsm_getclassifiedmedia(p1=vc(ref),p2=h(value)) = i4 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetClassifiedMedia", persist
  DECLARE uar_dmsm_getmediacontent(p1=i4(value),p2=i4(value),p3=h(value)) = i1 WITH image_axp =
  "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetMediaContent", persist
  DECLARE uar_dmsm_getmediaprops(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix =
  "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetMediaProps", persist
  DECLARE uar_dmsm_setmediacontent(p1=i4(value),p2=i4(value),p3=vc(ref),p4=h(value)) = i1 WITH
  image_axp = "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win =
  "dmsmanagement",
  uar = "DMSM_SetMediaContent", persist
  DECLARE uar_dmsm_storeclassifiedmedia(p1=i4(value)) = i1 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_StoreClassifiedMedia", persist
  DECLARE uar_dmsm_addmediatrackingevent(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i1(value)) = i1
  WITH image_axp = "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win
   = "dmsmanagement",
  uar = "DMSM_AddMediaTrackingEvent", persist
  DECLARE uar_dmsm_getinternalmediacontent(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetInternalMediaContent", persist
  DECLARE uar_dmsm_setmediaprops(p1=i4(value),p2=i4(value)) = i1 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_SetMediaProps", persist
  DECLARE uar_dmsm_getmediabyxref(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix =
  "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetMediaByXRef", persist
  DECLARE uar_dmsm_setmediaxref(p1=i4(value),p2=i4(value)) = i1 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_SetMediaXRef", persist
  DECLARE uar_dmsm_getmediaxref(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix =
  "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetMediaXRef", persist
  DECLARE uar_dmsm_setmetadata(p1=i4(value),p2=i4(value),p3=h(value)) = i1 WITH image_axp =
  "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_SetMetadata", persist
  DECLARE uar_dmsm_getmetadataschema(p1=i4(value),p2=h(value),p3=i4(value)) = i1 WITH image_axp =
  "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetMetadataSchema", persist
  DECLARE uar_dmsm_getmediaevents(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix =
  "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetMediaEvents", persist
  DECLARE uar_dmsm_getmediacodes(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix =
  "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetMediaCodes", persist
  DECLARE uar_dmsm_getclassifiedmedialist(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetClassifiedMediaList", persist
  DECLARE uar_dmsm_maintainmediaattributes(p1=i4(value),p2=i1(value),p3=i1(value)) = i4 WITH
  image_axp = "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win =
  "dmsmanagement",
  uar = "DMSM_MaintainMediaAttributes", persist
  DECLARE uar_dmsm_maintainmediaattributesex(p1=i4(value),p2=i1(value),p3=i1(value),p4=i1(value)) =
  i4 WITH image_axp = "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)",
  image_win = "dmsmanagement",
  uar = "DMSM_MaintainMediaAttributesEx", persist
 ENDIF
 EXECUTE aps_mmf_migration_common:dba
 DECLARE lstat = i4 WITH protect, noconstant(0)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 blob_handle = vc
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
 DECLARE lfilebuffer = i4 WITH protect, noconstant(0)
 DECLARE lcontenttype = i4 WITH protect, noconstant(0)
 DECLARE lmedia = i4 WITH protect, noconstant(0)
 DECLARE lmediaprops = i4 WITH protect, noconstant(0)
 DECLARE lxrefproplist = i4 WITH protect, noconstant(0)
 DECLARE lpropcnt = i4 WITH protect, noconstant(0)
 DECLARE nsuccess = i2 WITH protect, noconstant(0)
 DECLARE lpropsize = i4 WITH protect, noconstant(0)
 DECLARE sblobhandle = c200 WITH protect, noconstant("")
 DECLARE linvalid_handle = i4 WITH protect, constant(0)
 DECLARE lread_access = i4 WITH protect, constant(1)
 DECLARE lstd_content = i4 WITH protect, constant(0)
 DECLARE suid = vc WITH protect, constant("uid")
 DECLARE sperson = vc WITH protect, constant("PERSON")
 DECLARE scase = vc WITH protect, constant("PATHOLOGY_CASE")
 DECLARE sacrnema = vc WITH protect, constant("image/acrnema")
 DECLARE lpropmax = i4 WITH protect, constant(200)
 DECLARE sapimage = vc WITH protect, constant("APIMAGE")
 SET reply->status_data.status = "F"
 SET lcontenttype = uar_dmsm_getcontenttype(nullterm(sapimage))
 IF (lcontenttype=linvalid_handle)
  CALL subevent_add("GET","F","Content Type",build("Error getting handle - ",sapimage))
  GO TO exit_script
 ENDIF
 SET lfilebuffer = uar_srv_createfilebuffer(lread_access,nullterm(request->filename))
 IF (lfilebuffer=linvalid_handle)
  CALL subevent_add("GET","F","FileBuffer",build("Error getting handle  - ",request->filename))
  GO TO exit_script
 ENDIF
 SET nsuccess = 0
 SET lmedia = uar_dmsm_createclassifiedmedia(lcontenttype)
 IF (lmedia != linvalid_handle)
  IF (uar_dmsm_setmediacontent(lmedia,lfilebuffer,nullterm(sacrnema),lstd_content))
   IF (uar_dmsm_storeclassifiedmedia(lmedia))
    SET nsuccess = 1
   ENDIF
  ENDIF
 ENDIF
 IF (nsuccess=0)
  CALL subevent_add("STORE","F","Media",build("Error storing to MMF archive(",lmedia,")"))
  GO TO exit_script
 ENDIF
 SET nsuccess = 0
 SET lmediaprops = uar_dmsm_getmediaprops(lmedia)
 IF (lmediaprops != linvalid_handle)
  SET lpropsize = lpropmax
  IF (uar_srv_getpropstring(lmediaprops,nullterm(suid),sblobhandle,lpropsize))
   SET nsuccess = 1
  ENDIF
 ENDIF
 IF (nsuccess=0)
  CALL subevent_add("GET","F","Media UID","Error retrieving media unique identifier")
  GO TO exit_script
 ENDIF
 IF ((((request->patient_id > 0.0)) OR ((request->case_id > 0.0))) )
  SET nsuccess = 0
  SET lxrefproplist = uar_srv_createproplist()
  IF (lxrefproplist != linvalid_handle)
   IF (addxref(sperson,request->patient_id)=1
    AND addxref(scase,request->case_id)=1)
    IF (uar_dmsm_setmediaxref(lmedia,lxrefproplist))
     SET nsuccess = 1
    ENDIF
   ENDIF
  ENDIF
  IF (nsuccess=0)
   CALL subevent_add("CREATE","F","XRef","Error adding cross-reference property list")
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->blob_handle = trim(sblobhandle)
#exit_script
 IF (lxrefproplist != linvalid_handle)
  SET lstat = uar_srv_closehandle(lxrefproplist)
 ENDIF
 IF (lmediaprops != linvalid_handle)
  SET lstat = uar_srv_closehandle(lmediaprops)
 ENDIF
 IF (lmedia != linvalid_handle)
  SET lstat = uar_srv_closehandle(lmedia)
 ENDIF
 IF (lcontenttype != linvalid_handle)
  SET lstat = uar_srv_closehandle(lcontenttype)
 ENDIF
 IF (lfilebuffer != linvalid_handle)
  SET lstat = uar_srv_closehandle(lfilebuffer)
 ENDIF
 SUBROUTINE (addxref(sentityvalue=vc(ref),dentityid=f8) =i2 WITH private)
   DECLARE lsubproplist = i4 WITH protect, noconstant(0)
   DECLARE nsuccess = i2 WITH protect, noconstant(0)
   DECLARE ladd = i4 WITH protect, constant(1)
   DECLARE lowner = i4 WITH protect, constant(1)
   DECLARE sentityid = vc WITH protect, constant("entityId")
   DECLARE sentityname = vc WITH protect, constant("entityName")
   DECLARE stransaction = vc WITH protect, constant("transaction")
   SET nsuccess = 0
   IF (dentityid > 0)
    SET lsubproplist = uar_srv_createproplist()
    IF (lsubproplist != linvalid_handle)
     IF (uar_srv_setpropstring(lsubproplist,nullterm(sentityname),nullterm(sentityvalue))
      AND uar_srv_setpropreal(lsubproplist,nullterm(sentityid),dentityid)
      AND uar_srv_setpropint(lsubproplist,nullterm(stransaction),ladd))
      IF (uar_srv_setprophandle(lxrefproplist,nullterm(cnvtstring(lpropcnt)),lsubproplist,lowner))
       SET nsuccess = 1
       SET lpropcnt += 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(nsuccess)
 END ;Subroutine
 SET modify = nopredeclare
END GO
