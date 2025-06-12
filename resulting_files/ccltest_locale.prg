CREATE PROGRAM ccltest_locale
 DECLARE uar_setlocale(p1=i4(value),p2=vc(ref)) = vc WITH image_axp = "decc$shr", image_aix =
 "libc.a(shr.o)", uar_axp = "decc$setlocale",
 uar_aix = "setlocale", persist
 DECLARE buffer = c200 WITH noconstant("")
 DECLARE buffer2 = c200 WITH noconstant(" ")
 DECLARE lc_all = i4 WITH constant(- (1))
 SET buffer2 = uar_setlocale(lc_all,buffer)
 CALL echo(build("locale(",check(buffer2),")"))
END GO
