CREATE PROGRAM accrtl_sci_note:dba
 IF (validate(accrtl_sci_note_def,999)=999)
  CALL echo("Declaring accrtl_sci_note_def")
  DECLARE accrtl_sci_note_def = i2 WITH constant(1), persist
  DECLARE uar_accformatresultstringscinote(p1=i4(value),p2=i4(value),p3=i4(value),p4=f8(ref),p5=i4(
    value),
   p6=i2(value)) = vc WITH image_axp = "accrtl", image_aix = "libacc.a(libacc.o)", uar =
  "AccFormatResultStringSciNote",
  persist
 ENDIF
END GO
