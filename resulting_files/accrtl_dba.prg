CREATE PROGRAM accrtl:dba
 IF (validate(accrtl_def,999)=999)
  CALL echo("Declaring accrtl_def")
  DECLARE accrtl_def = i2 WITH constant(1), persist
  DECLARE uar_accloadreference() = i4 WITH image_axp = "accrtl", image_aix = "libacc.a(libacc.o)",
  uar = "AccLoadReference",
  persist
  DECLARE uar_accfreereference() = null WITH image_axp = "accrtl", image_aix = "libacc.a(libacc.o)",
  uar = "AccFreeReference",
  persist
  DECLARE uar_accgetcontainernbr(p1=vc(ref)) = i4 WITH image_axp = "accrtl", image_aix =
  "libacc.a(libacc.o)", uar = "AccGetContainerNbr",
  persist
  DECLARE uar_accgetcontaineralpha(p1=i4(value)) = i1 WITH image_axp = "accrtl", image_aix =
  "libacc.a(libacc.o)", uar = "AccGetContainerAlpha",
  persist
  DECLARE uar_accisjulian(p1=vc(ref),p2=h(value)) = i4 WITH image_axp = "accrtl", image_aix =
  "libacc.a(libacc.o)", uar = "AccIsJulian",
  persist
  DECLARE uar_accformatunformatted(p1=vc(ref),p2=h(value)) = vc WITH image_axp = "accrtl", image_aix
   = "libacc.a(libacc.o)", uar = "AccFormatUnformatted",
  persist
  DECLARE accformatunformattedcntnr(p1=vc(ref),p2=i4(value),p3=h(value)) = vc WITH image_axp =
  "accrtl", image_aix = "libacc.a(libacc.o)", uar = "AccFormatUnformattedCntnr",
  persist
  DECLARE uar_accunformatformatted(p1=vc(ref),p2=h(value),p3=i2(value)) = vc WITH image_axp =
  "accrtl", image_aix = "libacc.a(libacc.o)", uar = "AccUnformatFormatted",
  persist
  DECLARE uar_acctruncateunformatted(p1=vc(ref),p2=h(value),p3=i2(value)) = vc WITH image_axp =
  "accrtl", image_aix = "libacc.a(libacc.o)", uar = "AccTruncateUnformatted",
  persist
  DECLARE uar_acctruncateformatted(p1=vc(ref),p2=h(value),p3=i2(value)) = vc WITH image_axp =
  "accrtl", image_aix = "libacc.a(libacc.o)", uar = "AccTruncateFormatted",
  persist
  DECLARE uar_accformattruncated(p1=vc(ref),p2=h(value)) = vc WITH image_axp = "accrtl", image_aix =
  "libacc.a(libacc.o)", uar = "AccFormatTruncated",
  persist
  DECLARE uar_accrebuildtruncated(p1=vc(ref),p2=h(value)) = vc WITH image_axp = "accrtl", image_aix
   = "libacc.a(libacc.o)", uar = "AccRebuildTruncated",
  persist
  DECLARE uar_accmillenniumtoclassic(p1=vc(ref)) = vc WITH image_axp = "accrtl", image_aix =
  "libacc.a(libacc.o)", uar = "AccMillenniumToClassic",
  persist
  DECLARE uar_accclassictomillennium(p1=vc(ref)) = vc WITH image_axp = "accrtl", image_aix =
  "libacc.a(libacc.o)", uar = "AccClassicToMillennium",
  persist
  DECLARE uar_accgetaccessiontype(p1=vc(ref),p2=i2(value),p3=h(value)) = i2 WITH image_axp = "accrtl",
  image_aix = "libacc.a(libacc.o)", uar = "AccGetAccessionType",
  persist
 ENDIF
 IF (validate(accrtl_def2,999)=999)
  DECLARE accrtl_def2 = i2 WITH constant(1), persist
  DECLARE uar_acchascontainer(p1=vc(ref)) = i4 WITH image_aix = "libacc.a(libacc.o)", uar =
  "AccHasContainer", persist
  DECLARE uar_accgetaccessioncontainernbr(p1=vc(ref)) = i4 WITH image_aix = "libacc.a(libacc.o)", uar
   = "AccGetAccessionContainerNbr", persist
  DECLARE uar_accgetaccessioncontaineralpha(p1=vc(ref)) = i4 WITH image_aix = "libacc.a(libacc.o)",
  uar = "AccGetAccessionContainerAlpha", persist
  DECLARE uar_accgetaccessionwithoutcontainer(p1=vc(ref)) = vc WITH image_aix = "libacc.a(libacc.o)",
  uar = "AccGetAccessionWithoutContainer", persist
  DECLARE uar_accbuildbarcodeaccession(p1=vc(ref),p2=i4(value)) = vc WITH image_aix =
  "libacc.a(libacc.o)", uar = "AccBuildBarcodeAccession", persist
  DECLARE uar_accgetformatstate(p1=vc(ref)) = i2 WITH image_aix = "libacc.a(libacc.o)", uar =
  "AccGetFormatState", persist
 ENDIF
 IF (validate(accrtl_init,999)=999)
  DECLARE accrtl_init = i4 WITH noconstant(0), persist
  SET stat = uar_accloadreference()
 ELSE
  IF (accrtl_init=0)
   SET accrtl_init = uar_accloadreference()
  ENDIF
 ENDIF
END GO
