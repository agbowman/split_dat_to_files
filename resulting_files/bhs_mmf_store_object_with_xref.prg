CREATE PROGRAM bhs_mmf_store_object_with_xref
 DECLARE mf_person_id = f8 WITH protect, noconstant(0.0)
 IF (validate(dmsmanagementrtl_def,999)=999)
  DECLARE dmsmanagementrtl_def = i2 WITH persist
  SET dmsmanagementrtl_def = 1
  DECLARE uar_dmsm_createcopy(p1=vc(ref),p2=i4(value),p3=i4(value),p4=i4(value),p5=i4(value)) = i4
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
  DECLARE uar_dmsm_getclassifiedmedia(p1=vc(ref),p2=i4(value)) = i4 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetClassifiedMedia", persist
  DECLARE uar_dmsm_getmediacontent(p1=i4(value),p2=i4(value),p3=i4(value)) = i4 WITH image_axp =
  "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetMediaContent", persist
  DECLARE uar_dmsm_getmediaprops(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix =
  "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetMediaProps", persist
  DECLARE uar_dmsm_setmediacontent(p1=i4(value),p2=i4(value),p3=vc(ref),p4=i4(value)) = i4 WITH
  image_axp = "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win =
  "dmsmanagement",
  uar = "DMSM_SetMediaContent", persist
  DECLARE uar_dmsm_storeclassifiedmedia(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_StoreClassifiedMedia", persist
  DECLARE uar_dmsm_addmediatrackingevent(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(value)) = i4
  WITH image_axp = "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win
   = "dmsmanagement",
  uar = "DMSM_AddMediaTrackingEvent", persist
  DECLARE uar_dmsm_getinternalmediacontent(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetInternalMediaContent", persist
  DECLARE uar_dmsm_setmediaprops(p1=i4(value),p2=i4(value)) = i4 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_SetMediaProps", persist
  DECLARE uar_dmsm_getmediabyxref(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix =
  "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetMediaByXRef", persist
  DECLARE uar_dmsm_setmediaxref(p1=i4(value),p2=i4(value)) = i4 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_SetMediaXRef", persist
  DECLARE uar_dmsm_getmediaxref(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix =
  "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetMediaXRef", persist
  DECLARE uar_dmsm_setmetadata(p1=i4(value),p2=i4(value),p3=i4(value)) = i4 WITH image_axp =
  "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_SetMetadata", persist
  DECLARE uar_dmsm_getmetadataschema(p1=i4(value),p2=i4(value),p3=i4(value)) = i4 WITH image_axp =
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
  DECLARE uar_srv_getpropcount(p1=i4(value),p2=i4(ref)) = i4 WITH image_axp = "srvcore", image_aix =
  "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_GetPropCount", persist
  DECLARE uar_srv_getprophandle(p1=i4(value),p2=vc(ref),p3=i4(ref)) = i4 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_GetPropHandle", persist
  DECLARE uar_srv_getpropstring(p1=i4(value),p2=vc(ref),p3=vc(ref),p4=i4(ref)) = i4 WITH image_axp =
  "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_GetPropString", persist
  DECLARE uar_srv_getpropint(p1=i4(value),p2=vc(ref),p3=i4(ref)) = i4 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_GetPropInt", persist
  DECLARE uar_srv_creatememorybuffer(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(value),p5=i4(value),
   p6=vc(ref)) = i4 WITH image_axp = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", image_win
   = "srvcore",
  uar = "SRV_CreateMemoryBuffer", persist
  DECLARE uar_srv_getmemorybuffer(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(value)) = i4 WITH
  image_axp = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_GetMemoryBuffer", persist
  DECLARE uar_srv_getmemorybuffersize(p1=i4(value),p2=i4(ref)) = i4 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_GetMemoryBufferSize", persist
  DECLARE uar_srv_createfilebuffer(p1=i4(value),p2=vc(ref)) = i4 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_CreateFileBuffer", persist
  DECLARE uar_srv_writebuffer(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(ref)) = i4 WITH image_axp =
  "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_WriteBuffer", persist
  DECLARE uar_srv_readbuffer(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(ref)) = i4 WITH image_axp =
  "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_ReadBuffer", persist
  DECLARE uar_srv_setbufferpos(p1=i4(value),p2=i4(value),p3=i4(value),p4=i4(ref)) = i4 WITH image_axp
   = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_SetBufferPos", persist
  DECLARE uar_srv_getbufferpos(p1=i4(value),p2=i4(ref)) = i4 WITH image_axp = "srvcore", image_aix =
  "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_GetBufferPos", persist
  FREE SET uar_srv_closehandle
  DECLARE uar_srv_closehandle(p1=i4(value)) = i4 WITH image_axp = "srvcore", image_aix =
  "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_CloseHandle", persist
  FREE SET uar_srv_createproplist
  DECLARE uar_srv_createproplist() = i4 WITH image_axp = "srvcore", image_aix =
  "libsrvcore.a(libsrvcore.o)", uar = "SRV_CreatePropList",
  persist
  FREE SET uar_srv_setpropstring
  DECLARE uar_srv_setpropstring(p1=i4(value),p2=vc(ref),p3=vc(ref)) = i4 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropString",
  persist
  FREE SET uar_srv_setpropreal
  DECLARE uar_srv_setpropreal(p1=i4(value),p2=vc(ref),p3=f8(value)) = i4 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropReal",
  persist
  CALL echo("Declare uar_srv_setproptint")
  FREE SET uar_srv_setpropint
  DECLARE uar_srv_setpropint(p1=i4(value),p2=vc(ref),p3=i4(value)) = i4 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropInt",
  persist
  FREE SET uar_srv_setprophandle
  DECLARE uar_srv_setprophandle(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(value)) = i4 WITH
  image_axp = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropHandle",
  persist
 ENDIF
 FREE SET uar_setpropstring
 DECLARE uar_setpropstring(p1=i4(value),p2=vc(ref),p3=vc(ref)) = i4 WITH image_axp = "srvcore",
 image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropString",
 persist
 FREE SET uar_srv_createproplist
 DECLARE uar_srv_createproplist() = i4 WITH image_axp = "srvcore", image_aix =
 "libsrvcore.a(libsrvcore.o)", uar = "SRV_CreatePropList",
 persist
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 identifier = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(dmsmanagementrtl_def,999)=999)
  DECLARE dmsmanagementrtl_def = i2 WITH persist
  SET dmsmanagementrtl_def = 1
  DECLARE uar_dmsm_createcopy(p1=vc(ref),p2=i4(value),p3=i4(value),p4=i4(value),p5=i4(value)) = i4
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
  DECLARE uar_dmsm_getclassifiedmedia(p1=vc(ref),p2=i4(value)) = i4 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetClassifiedMedia", persist
  DECLARE uar_dmsm_getmediacontent(p1=i4(value),p2=i4(value),p3=i4(value)) = i4 WITH image_axp =
  "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetMediaContent", persist
  DECLARE uar_dmsm_getmediaprops(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix =
  "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetMediaProps", persist
  DECLARE uar_dmsm_setmediacontent(p1=i4(value),p2=i4(value),p3=vc(ref),p4=i4(value)) = i4 WITH
  image_axp = "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win =
  "dmsmanagement",
  uar = "DMSM_SetMediaContent", persist
  DECLARE uar_dmsm_storeclassifiedmedia(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_StoreClassifiedMedia", persist
  DECLARE uar_dmsm_addmediatrackingevent(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(value)) = i4
  WITH image_axp = "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win
   = "dmsmanagement",
  uar = "DMSM_AddMediaTrackingEvent", persist
  DECLARE uar_dmsm_getinternalmediacontent(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetInternalMediaContent", persist
  DECLARE uar_dmsm_setmediaprops(p1=i4(value),p2=i4(value)) = i4 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_SetMediaProps", persist
  DECLARE uar_dmsm_getmediabyxref(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix =
  "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetMediaByXRef", persist
  DECLARE uar_dmsm_setmediaxref(p1=i4(value),p2=i4(value)) = i4 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_SetMediaXRef", persist
  DECLARE uar_dmsm_getmediaxref(p1=i4(value)) = i4 WITH image_axp = "dmsmanagement", image_aix =
  "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_GetMediaXRef", persist
  DECLARE uar_dmsm_setmetadata(p1=i4(value),p2=i4(value),p3=i4(value)) = i4 WITH image_axp =
  "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_SetMetadata", persist
  DECLARE uar_dmsm_getmetadataschema(p1=i4(value),p2=i4(value),p3=i4(value)) = i4 WITH image_axp =
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
  DECLARE uar_srv_getpropcount(p1=i4(value),p2=i4(ref)) = i4 WITH image_axp = "srvcore", image_aix =
  "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_GetPropCount", persist
  DECLARE uar_srv_getprophandle(p1=i4(value),p2=vc(ref),p3=i4(ref)) = i4 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_GetPropHandle", persist
  DECLARE uar_srv_getpropstring(p1=i4(value),p2=vc(ref),p3=vc(ref),p4=i4(ref)) = i4 WITH image_axp =
  "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_GetPropString", persist
  DECLARE uar_srv_getpropint(p1=i4(value),p2=vc(ref),p3=i4(ref)) = i4 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_GetPropInt", persist
  DECLARE uar_srv_creatememorybuffer(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(value),p5=i4(value),
   p6=vc(ref)) = i4 WITH image_axp = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", image_win
   = "srvcore",
  uar = "SRV_CreateMemoryBuffer", persist
  DECLARE uar_srv_getmemorybuffer(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(value)) = i4 WITH
  image_axp = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_GetMemoryBuffer", persist
  DECLARE uar_srv_getmemorybuffersize(p1=i4(value),p2=i4(ref)) = i4 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_GetMemoryBufferSize", persist
  DECLARE uar_srv_createfilebuffer(p1=i4(value),p2=vc(ref)) = i4 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_CreateFileBuffer", persist
  DECLARE uar_srv_writebuffer(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(ref)) = i4 WITH image_axp =
  "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_WriteBuffer", persist
  DECLARE uar_srv_readbuffer(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(ref)) = i4 WITH image_axp =
  "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_ReadBuffer", persist
  DECLARE uar_srv_setbufferpos(p1=i4(value),p2=i4(value),p3=i4(value),p4=i4(ref)) = i4 WITH image_axp
   = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_SetBufferPos", persist
  DECLARE uar_srv_getbufferpos(p1=i4(value),p2=i4(ref)) = i4 WITH image_axp = "srvcore", image_aix =
  "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_GetBufferPos", persist
  FREE SET uar_srv_closehandle
  DECLARE uar_srv_closehandle(p1=i4(value)) = i4 WITH image_axp = "srvcore", image_aix =
  "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_CloseHandle", persist
  FREE SET uar_srv_createproplist
  DECLARE uar_srv_createproplist() = i4 WITH image_axp = "srvcore", image_aix =
  "libsrvcore.a(libsrvcore.o)", uar = "SRV_CreatePropList",
  persist
  FREE SET uar_srv_setpropstring
  DECLARE uar_srv_setpropstring(p1=i4(value),p2=vc(ref),p3=vc(ref)) = i4 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropString",
  persist
  FREE SET uar_srv_setpropreal
  DECLARE uar_srv_setpropreal(p1=i4(value),p2=vc(ref),p3=f8(value)) = i4 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropReal",
  persist
  CALL echo("Declare uar_srv_setproptint")
  FREE SET uar_srv_setpropint
  DECLARE uar_srv_setpropint(p1=i4(value),p2=vc(ref),p3=i4(value)) = i4 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropInt",
  persist
  FREE SET uar_srv_setprophandle
  DECLARE uar_srv_setprophandle(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(value)) = i4 WITH
  image_axp = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropHandle",
  persist
 ENDIF
 DECLARE lstatus = i4 WITH protect, noconstant(0)
 DECLARE lfilebuffer = i4 WITH protect, noconstant(0)
 DECLARE lcontenttype = i4 WITH protect, noconstant(0)
 DECLARE lmedia = i4 WITH protect, noconstant(0)
 DECLARE lmediaprops = i4 WITH protect, noconstant(0)
 DECLARE smediaobjectidentifier = c200 WITH protect, noconstant("")
 DECLARE lpropmax = i4 WITH protect, constant(199)
 DECLARE lpropsize = i4 WITH protect, noconstant(0)
 DECLARE linvalid_handle = i4 WITH protect, constant(0)
 DECLARE lread_access = i4 WITH protect, constant(1)
 DECLARE lstd_content = i4 WITH protect, constant(0)
 DECLARE lwrite_access = i4 WITH protect, constant(2)
 DECLARE lcreate_access = i4 WITH protect, constant(2)
 SET reply->status_data.status = "F"
 CALL echo(build2("contenttype: ",request->contenttype))
 SET lcontenttype = uar_dmsm_getcontenttype(value(request->contenttype))
 CALL echo(build2("lcontenttype: ",lcontenttype))
 CALL echo(build2("linvalid_handle: ",linvalid_handle))
 IF (lcontenttype=linvalid_handle)
  CALL echo(concat("invalid content type specified - ",request->contenttype))
  SET reply->status_data.subeventstatus[1].operationname = "invalid contenttype error"
  CALL echo(build("***** failed "))
  GO TO exit_script
 ENDIF
 SET lmedia = uar_dmsm_createclassifiedmedia(lcontenttype)
 IF (lmedia=linvalid_handle)
  CALL echo(concat("Unable to create object for content type: - ",request->contenttype))
  SET reply->status_data.subeventstatus[1].operationname = "Unable create contentType object"
  CALL echo(build("***** failed "))
  GO TO exit_script
 ENDIF
 SET lmediaprops = uar_srv_createproplist()
 IF (lmediaprops=linvalid_handle)
  CALL echo(concat("Error getting media props handle  - ",request->contenttype))
  SET reply->status_data.subeventstatus[1].operationname = "Unable create prop handle"
  CALL echo(build("***** failed "))
  GO TO exit_script
 ENDIF
 SET lstatus = uar_setpropstring(lmediaprops,nullterm("name"),nullterm(request->name))
 CALL echo(build("uar_SetPropString lStatus:",lstatus))
 SET lstatus = uar_dmsm_setmediaprops(lmedia,lmediaprops)
 SET lfilebuffer = uar_srv_createfilebuffer(lread_access,nullterm(request->filename))
 IF (lfilebuffer=linvalid_handle)
  CALL echo(concat("Error getting file handle  - ",request->filename,":"))
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "file not found"
  CALL echo(build("***** failed "))
  GO TO exit_script
 ENDIF
 CALL uar_dmsm_setmediacontent(lmedia,lfilebuffer,nullterm(request->mediatype),lstd_content)
 CALL echo(build("***** attempt to store a media object"))
 CALL uar_dmsm_storeclassifiedmedia(lmedia)
 SET lstatus = addxref(lmedia,request->personid,request->encounterid)
 IF (lstatus=0)
  CALL echo("Error adding cross-reference property list")
  SET reply->status_data.subeventstatus[1].operationname = "Unable add xref"
  GO TO exit_script
  CALL echo(build("***** failed "))
 ELSE
  CALL echo("cross-reference added")
 ENDIF
 SET smediaobjectidentifier = fillstring(200," ")
 SET lmediaprops = uar_dmsm_getmediaprops(lmedia)
 IF (lmediaprops != linvalid_handle)
  SET lpropsize = lpropmax
  IF (uar_srv_getpropstring(lmediaprops,nullterm("uid"),smediaobjectidentifier,lpropsize)=0)
   CALL echo("unable to get the media object identifier from the saved object")
   SET reply->status_data.subeventstatus[1].operationname = "Unable get identifier"
   CALL echo(build("***** failed "))
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->identifier = nullterm(trim(smediaobjectidentifier))
 CALL echo(build("UID:",reply->identifier))
 SET reply->status_data.status = "S"
 CALL echo(build("***** object stored successfully"))
#exit_script
 IF (lmediaprops != linvalid_handle)
  SET lstatus = uar_srv_closehandle(lmediaprops)
 ENDIF
 IF (lmedia != linvalid_handle)
  SET lstatus = uar_srv_closehandle(lmedia)
 ENDIF
 IF (lcontenttype != linvalid_handle)
  SET lstatus = uar_srv_closehandle(lcontenttype)
 ENDIF
 IF (lfilebuffer != linvalid_handle)
  SET lstatus = uar_srv_closehandle(lfilebuffer)
 ENDIF
 IF (size(trim(reply->identifier,3)) > 0)
  SELECT INTO "nl:"
   FROM prsnl p
   WHERE p.username="FHAUTH"
   HEAD REPORT
    mf_person_id = p.person_id
   WITH nocounter
  ;end select
  IF (mf_person_id=0.0)
   CALL echo("**** person id for user FHAUTH was not found... ")
  ELSE
   UPDATE  FROM dms_media_instance
    SET created_by_id = mf_person_id
    WHERE dms_media_identifier_id IN (
    (SELECT
     d.dms_media_identifier_id
     FROM dms_media_identifier d
     WHERE (d.media_object_identifier=reply->identifier)))
   ;end update
  ENDIF
 ENDIF
 SUBROUTINE addxref(lmediaitem,dpersonid,dencounterid)
   DECLARE lqual = i4 WITH private, noconstant(0)
   DECLARE lcriteria = i4 WITH private, noconstant(0)
   DECLARE lpersonxref = i4 WITH private, noconstant(0)
   DECLARE lencounterxref = i4 WITH private, noconstant(0)
   DECLARE lres = i4 WITH private, noconstant(0)
   DECLARE lreturnval = i4 WITH private, noconstant(false)
   IF (((lmediaitem <= 0) OR (dpersonid=0)) )
    RETURN(false)
   ENDIF
   SET lpersonxref = uar_srv_createproplist()
   IF (lpersonxref=0)
    RETURN(false)
   ENDIF
   SET lres = uar_srv_setpropint(lpersonxref,"transaction",1)
   IF (lres=0)
    RETURN(false)
   ENDIF
   SET lres = uar_srv_setpropstring(lpersonxref,"ENTITYNAME","PERSON")
   IF (lres=0)
    RETURN(false)
   ENDIF
   SET lres = uar_srv_setpropreal(lpersonxref,"ENTITYID",dpersonid)
   IF (lres=0)
    RETURN(false)
   ENDIF
   IF (dencounterid != 0)
    SET lencounterxref = uar_srv_createproplist()
    IF (lencounterxref=0)
     RETURN(false)
    ENDIF
    SET lres = uar_srv_setpropint(lencounterxref,"transaction",1)
    IF (lres=0)
     RETURN(false)
    ENDIF
    SET lres = uar_srv_setpropstring(lencounterxref,"ENTITYNAME","ENCOUNTER")
    IF (lres=0)
     RETURN(false)
    ENDIF
    SET lres = uar_srv_setpropreal(lencounterxref,"ENTITYID",dencounterid)
    IF (lres=0)
     RETURN(false)
    ENDIF
   ENDIF
   SET lqual = uar_srv_createproplist()
   IF (lqual=0)
    RETURN(false)
   ENDIF
   SET lres = uar_srv_setprophandle(lqual,"0",lpersonxref,1)
   IF (dencounterid != 0)
    SET lres = uar_srv_setprophandle(lqual,"1",lencounterxref,1)
   ENDIF
   IF (lres=0)
    RETURN(false)
   ENDIF
   SET lreturnval = uar_dmsm_setmediaxref(lmediaitem,lqual)
   IF (lreturnval=1)
    SET lreturnval = true
   ENDIF
   SET lres = uar_srv_closehandle(lpersonxref)
   IF (dencounterid != 0)
    SET lres = uar_srv_closehandle(lencounterxref)
   ENDIF
   SET lres = uar_srv_closehandle(lqual)
   RETURN(lreturnval)
 END ;Subroutine
END GO
