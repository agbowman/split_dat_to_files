CREATE PROGRAM dmsmanagementrtl:dba
 IF (validate(dmsmanagementrtl_def,999)=999)
  DECLARE dmsmanagementrtl_def = i2 WITH persist
  SET dmsmanagementrtl_def = 1
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
  DECLARE uar_dmsm_verifymediaobject(p1=vc(ref),p2=h(value),p3=f8(ref),p4=i1(ref),p5=i1(ref)) = i1
  WITH image_axp = "dmsmanagement", image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win
   = "dmsmanagement",
  uar = "DMSM_VerifyMediaObject", persist
  DECLARE uar_dmsm_deletemediaobject(p1=vc(ref),p2=h(value)) = i1 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_DeleteMediaObject", persist
  DECLARE uar_dmsm_deletecontent(p1=vc(ref),p2=f8(value)) = i1 WITH image_axp = "dmsmanagement",
  image_aix = "libdmsmanagement.a(libdmsmanagement.o)", image_win = "dmsmanagement",
  uar = "DMSM_DeleteContent", persist
 ENDIF
END GO
