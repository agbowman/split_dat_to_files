CREATE PROGRAM aps_mmf_migration_common:dba
 IF (validate(apsdicomrtl_def,999)=999)
  DECLARE apsdicomrtl_def = i2 WITH persist
  SET apsdicomrtl_def = 1
  DECLARE uar_aps_initializedicom(p1=i4(value)) = i4 WITH image_axp = "apsdicomrtl", image_aix =
  "libapsdicom.a(libapsdicom.o)", image_win = "apsdicomrtl",
  uar = "APS_InitializeDicom", persist
  DECLARE uar_aps_closedicom(p1=i4(value)) = i4 WITH image_axp = "apsdicomrtl", image_aix =
  "libapsdicom.a(libapsdicom.o)", image_win = "apsdicomrtl",
  uar = "APS_CloseDicom", persist
  DECLARE uar_aps_dicomgetlocalport(p1=i4(value)) = i4 WITH image_axp = "apsdicomrtl", image_aix =
  "libapsdicom.a(libapsdicom.o)", image_win = "apsdicomrtl",
  uar = "APS_DicomGetLocalPort", persist
  DECLARE uar_aps_dicomgetlocaladdr(p1=i4(value),p2=vc(ref),p3=i4(value)) = i4 WITH image_axp =
  "apsdicomrtl", image_aix = "libapsdicom.a(libapsdicom.o)", image_win = "apsdicomrtl",
  uar = "APS_DicomGetLocalAddr", persist
  DECLARE uar_aps_dicomgetlocalfulladdr(p1=i4(value),p2=vc(ref),p3=i4(value)) = i4 WITH image_axp =
  "apsdicomrtl", image_aix = "libapsdicom.a(libapsdicom.o)", image_win = "apsdicomrtl",
  uar = "APS_DicomGetLocalFullAddr", persist
  DECLARE uar_aps_dicomgetlocalname(p1=i4(value),p2=vc(ref),p3=i4(value)) = i4 WITH image_axp =
  "apsdicomrtl", image_aix = "libapsdicom.a(libapsdicom.o)", image_win = "apsdicomrtl",
  uar = "APS_DicomGetLocalName", persist
  DECLARE uar_aps_dicomgetlocaltitle(p1=i4(value),p2=vc(ref),p3=i4(value)) = i4 WITH image_axp =
  "apsdicomrtl", image_aix = "libapsdicom.a(libapsdicom.o)", image_win = "apsdicomrtl",
  uar = "APS_DicomGetLocalTitle", persist
  DECLARE uar_aps_dicomgetfilename(p1=i4(value),p2=vc(ref),p3=i4(value)) = i4 WITH image_axp =
  "apsdicomrtl", image_aix = "libapsdicom.a(libapsdicom.o)", image_win = "apsdicomrtl",
  uar = "APS_DicomGetFilename", persist
  DECLARE uar_aps_retrievedicom(p1=i4(value),p2=vc(ref)) = i4 WITH image_axp = "apsdicomrtl",
  image_aix = "libapsdicom.a(libapsdicom.o)", image_win = "apsdicomrtl",
  uar = "APS_RetrieveDicom", persist
  DECLARE uar_aps_logdicom(p1=i4(value),p2=vc(ref),p3=vc(ref),p4=vc(ref)) = i4 WITH image_axp =
  "apsdicomrtl", image_aix = "libapsdicom.a(libapsdicom.o)", image_win = "apsdicomrtl",
  uar = "APS_LogDicom", persist
  DECLARE uar_srv_createproplist() = i4 WITH image_axp = "srvcore", image_aix =
  "libsrvcore.a(libsrvcore.o)", uar = "SRV_CreatePropList",
  persist
  DECLARE uar_srv_setpropstring(p1=i4(value),p2=vc(ref),p3=vc(ref)) = i4 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropString",
  persist
  DECLARE uar_srv_setpropreal(p1=i4(value),p2=vc(ref),p3=f8(value)) = i4 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropReal",
  persist
  DECLARE uar_srv_setpropint(p1=i4(value),p2=vc(ref),p3=i4(value)) = i4 WITH image_axp = "srvcore",
  image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropInt",
  persist
  DECLARE uar_srv_setprophandle(p1=i4(value),p2=vc(ref),p3=i4(value),p4=i4(value)) = i4 WITH
  image_axp = "srvcore", image_aix = "libsrvcore.a(libsrvcore.o)", uar = "SRV_SetPropHandle",
  persist
  DECLARE uar_srv_closehandle(p1=i4(value)) = i4 WITH image_axp = "srvcore", image_aix =
  "libsrvcore.a(libsrvcore.o)", image_win = "srvcore",
  uar = "SRV_CloseHandle", persist
 ENDIF
END GO
