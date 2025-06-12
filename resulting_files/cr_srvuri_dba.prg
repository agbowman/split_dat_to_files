CREATE PROGRAM cr_srvuri:dba
 IF (validate(cr_srvuri_def,999)=999)
  CALL echo("Declaring cr_srvuri_def")
  DECLARE cr_srvuri_def = i2 WITH persist
  SET cr_srvuri_def = 1
  DECLARE uar_srv_geturistring(p1=i4(value),p2=vc(ref)) = i1 WITH image_axp = "srvuri", image_aix =
  "libsrvuri.a(libsrvuri.o)", uar = "SRV_GetURIString",
  persist
  DECLARE uar_srv_geturiparts(p1=vc(ref)) = i4 WITH image_axp = "srvuri", image_aix =
  "libsrvuri.a(libsrvuri.o)", uar = "SRV_GetURIParts",
  persist
  DECLARE uar_srv_createwebrequest(p1=i4(value)) = i4 WITH image_axp = "srvuri", image_aix =
  "libsrvuri.a(libsrvuri.o)", uar = "SRV_CreateWebRequest",
  persist
  DECLARE uar_srv_setwebrequestprops(p1=i4(value),p2=i4(value)) = i1 WITH image_axp = "srvuri",
  image_aix = "libsrvuri.a(libsrvuri.o)", uar = "SRV_SetWebRequestProps",
  persist
  DECLARE uar_srv_getwebresponse(p1=i4(value),p2=i4(value)) = i4 WITH image_axp = "srvuri", image_aix
   = "libsrvuri.a(libsrvuri.o)", uar = "SRV_GetWebResponse",
  persist
  DECLARE uar_srv_getwebresponseprops(p1=i4(value)) = i4 WITH image_axp = "srvuri", image_aix =
  "libsrvuri.a(libsrvuri.o)", uar = "SRV_GetWebResponseProps",
  persist
  DECLARE uar_srv_resetwebrequest(p1=i4(value)) = i1 WITH image_axp = "srvuri", image_aix =
  "libsrvuri.a(libsrvuri.o)", uar = "SRV_ResetWebRequest",
  persist
  DECLARE uar_srv_creatememorybuffer(p1=i4(value),p2=i4(value),p3=i4(value),p4=i4(value),p5=i4(value),
   p6=i4(value)) = i4 WITH image_axp = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar =
  "SRV_CreateMemoryBuffer",
  persist
  DECLARE uar_srv_createfilebuffer(p1=i4(value),p2=vc(ref)) = i4 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_CreateFileBuffer",
  persist
  DECLARE uar_srv_writebuffer(p1=i4(value),p2=vc(ref),p3=h(value),p4=h(ref)) = i1 WITH image_axp =
  "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_WriteBuffer",
  persist
  DECLARE uar_srv_readbuffer(p1=i4(value),p2=vc(ref),p3=h(value),p4=h(ref)) = i1 WITH image_axp =
  "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_ReadBuffer",
  persist
  DECLARE uar_srv_setbufferpos(p1=i4(value),p2=i4(value),p3=h(value),p4=h(ref)) = i1 WITH image_axp
   = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetBufferPos",
  persist
  DECLARE uar_srv_getbufferpos(p1=i4(value),p2=h(ref)) = i1 WITH image_axp = "srvcore", image_aix =
  "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetBufferPos",
  persist
  DECLARE uar_srv_getmemorybuffer(p1=i4(value),p2=vc(ref),p3=h(value),p4=h(value)) = i1 WITH
  image_axp = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetMemoryBuffer",
  persist
  DECLARE uar_srv_getmemorybuffersize(p1=i4(value),p2=h(ref)) = i1 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetMemoryBufferSize",
  persist
  DECLARE uar_srv_getfilebuffername(p1=i4(value),p2=vc(ref),p3=h(value)) = i1 WITH image_axp =
  "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetFileBufferName",
  persist
  DECLARE uar_srv_getfilebuffersize(p1=i4(value),p2=h(ref)) = i1 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetFileBufferSize",
  persist
  DECLARE uar_srv_createproplist() = i4 WITH image_axp = "srvcore", image_aix =
  "libsrvcore.a(libsrvcore.o)", uar = "SRV_CreatePropList",
  persist
  DECLARE uar_srv_getpropstring(p1=i4(value),p2=vc(ref),p3=vc(ref),p4=i4(ref)) = i1 WITH image_axp =
  "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetPropString",
  persist
  DECLARE uar_srv_getpropint(p1=i4(value),p2=vc(ref),p3=i4(ref)) = i1 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetPropInt",
  persist
  DECLARE uar_srv_getprophandle(p1=i4(value),p2=vc(ref),p3=i4(ref)) = i1 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetPropHandle",
  persist
  DECLARE uar_srv_setpropstring(p1=i4(value),p2=vc(ref),p3=vc(ref)) = i1 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropString",
  persist
  DECLARE uar_srv_setpropint(p1=i4(value),p2=vc(ref),p3=i4(value)) = i1 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropInt",
  persist
  DECLARE uar_srv_setprophandle(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(value)) = i1 WITH
  image_axp = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropHandle",
  persist
  DECLARE uar_srv_removeprop(p1=i4(value),p2=vc(ref)) = i1 WITH image_axp = "srvcore", image_aix =
  "libsrvcore.a(libsrvcore.o)", uar = "SRV_RemoveProp",
  persist
  DECLARE uar_srv_firstprop(p1=i4(value),p2=vc(ref),p3=i4(ref)) = i1 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_FirstProp",
  persist
  DECLARE uar_srv_nextprop(p1=i4(value),p2=vc(ref),p3=i4(ref)) = i1 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_NextProp",
  persist
  DECLARE uar_srv_getpropcount(p1=i4(value),p2=i4(ref)) = i1 WITH image_axp = "srvcore", image_aix =
  "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetPropCount",
  persist
  DECLARE uar_srv_clearproplist(p1=i4(value)) = i1 WITH image_axp = "srvcore", image_aix =
  "libsrvcore.a(libsrvcore.o)", uar = "SRV_ClearPropList",
  persist
  DECLARE uar_srv_geterror() = i4 WITH image_axp = "srvcore", image_aix =
  "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetError",
  persist
  DECLARE uar_srv_geterrorspecific() = i4 WITH image_axp = "srvcore", image_aix =
  "libsrvcore.a(libsrvcore.o)", uar = "SRV_GetErrorSpecific",
  persist
  DECLARE uar_srv_closehandle(p1=i4(value)) = i1 WITH image_axp = "srvcore", image_aix =
  "libsrvcore.a(libsrvcore.o)", uar = "SRV_CloseHandle",
  persist
  DECLARE uar_srv_allocate(p1=i4(value)) = h WITH image_axp = "srvcore", image_aix =
  "libsrvcore.a(libsrvcore.o)", uar = "SRV_Allocate",
  persist
  DECLARE uar_srv_free(p1=i4(value)) = null WITH image_axp = "srvcore", image_aix =
  "libsrvcore.a(libsrvcore.o)", uar = "SRV_Free",
  persist
 ENDIF
END GO
