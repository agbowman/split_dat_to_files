CREATE PROGRAM ccldcacrm:dba
 PROMPT
  "ccldcacrm enable/disable (Y/N): " = "N",
  "rdbms login: " = "username/password@link",
  "debug code_value :" = 58
 DECLARE stat = i4 WITH protect
 DECLARE cvalue = f8 WITH protect
 RECORD rec(
   1 display = c40
   1 mean = c12
   1 description = c60
   1 cki = c64
   1 code_set = i4
 )
 IF (cnvtupper( $1) IN ("Y", "N"))
  FREE SUBROUTINE uar_get_code
  FREE SUBROUTINE uar_get_code2
  FREE SUBROUTINE uar_get_code_by
  FREE SUBROUTINE uar_get_code_by_cki
  FREE SUBROUTINE uar_get_code_cki
  FREE SUBROUTINE uar_get_code_description
  FREE SUBROUTINE uar_get_code_display
  FREE SUBROUTINE uar_get_code_list_by_descr
  FREE SUBROUTINE uar_get_code_list_by_dispkey
  FREE SUBROUTINE uar_get_code_list_by_display
  FREE SUBROUTINE uar_get_code_list_by_meaning
  FREE SUBROUTINE uar_get_code_list_by_conceptcki
  FREE SUBROUTINE uar_get_code_meaning
  FREE SUBROUTINE uar_get_code_set
  FREE SUBROUTINE uar_get_collation_seq
  FREE SUBROUTINE uar_get_conceptcki
  FREE SUBROUTINE uar_get_meaning_by_codeset
 ENDIF
 CASE (cnvtupper( $1))
  OF "Y":
   CALL echo("ccldcacrm enabled, switching to ccldcacrm uars")
   FREE SUBROUTINE uar_dca_init
   FREE SUBROUTINE uar_dca_term
   FREE SUBROUTINE uar_dca_show
   DECLARE uar_dca_init(p1=vc) = i4 WITH image_axp = "shrccluarx", image_aix =
   "libshrccluarx.a(libshrccluarx.o)", image_win = "shrccluarx",
   uar = "DCA_INIT", persist
   DECLARE uar_dca_term(p1=i4) = i4 WITH image_axp = "shrccluarx", image_aix =
   "libshrccluarx.a(libshrccluarx.o)", image_win = "shrccluarx",
   uar = "DCA_TERM", persist
   DECLARE uar_dca_show(p1=i4) = i4 WITH image_axp = "shrccluarx", image_aix =
   "libshrccluarx.a(libshrccluarx.o)", image_win = "shrccluarx",
   uar = "DCA_SHOW", persist
   DECLARE uar_get_code(p1=f8,p2=vc,p3=vc,p4=vc) = i4 WITH image_axp = "shrccluarx", image_aix =
   "libshrccluarx.a(libshrccluarx.o)", image_win = "shrccluarx",
   uar = "DCA_GET_CODE", persist
   DECLARE uar_get_code2(p1=f8,p2=vc,p3=vc,p4=vc,p5=vc,
    p6=i4) = i4 WITH image_axp = "shrccluarx", image_aix = "libshrccluarx.a(libshrccluarx.o)",
   image_win = "shrccluarx",
   uar = "DCA_GET_CODE2", persist
   DECLARE uar_get_code_by(p1=vc,p2=i4,p3=vc) = f8 WITH image_axp = "shrccluarx", image_aix =
   "libshrccluarx.a(libshrccluarx.o)", image_win = "shrccluarx",
   uar = "DCA_GET_CODE_BY", persist
   DECLARE uar_get_code_by_cki(p1=vc) = f8 WITH image_axp = "shrccluarx", image_aix =
   "libshrccluarx.a(libshrccluarx.o)", image_win = "shrccluarx",
   uar = "DCA_GET_CODE_BY_CKI", persist
   DECLARE uar_get_code_cki(p1=f8) = c50 WITH image_axp = "shrccluarx", image_aix =
   "libshrccluarx.a(libshrccluarx.o)", image_win = "shrccluarx",
   uar = "DCA_GET_CODE_CKI", persist
   DECLARE uar_get_code_description(p1=f8) = c60 WITH image_axp = "shrccluarx", image_aix =
   "libshrccluarx.a(libshrccluarx.o)", image_win = "shrccluarx",
   uar = "DCA_GET_CODE_DESCRIPTION", persist
   DECLARE uar_get_code_display(p1=f8) = c40 WITH image_axp = "shrccluarx", image_aix =
   "libshrccluarx.a(libshrccluarx.o)", image_win = "shrccluarx",
   uar = "DCA_GET_CODE_DISPLAY", persist
   DECLARE uar_get_code_list_by_descr(p1=i4,p2=vc,p3=i4,p4=i4,p5=i4,
    p6=f8) = i4 WITH image_axp = "shrccluarx", image_aix = "libshrccluarx.a(libshrccluarx.o)",
   image_win = "shrccluarx",
   uar = "DCA_GET_CODE_LIST_BY_DESCR", persist
   DECLARE uar_get_code_list_by_dispkey(p1=i4,p2=vc,p3=i4,p4=i4,p5=i4,
    p6=f8) = i4 WITH image_axp = "shrccluarx", image_aix = "libshrccluarx.a(libshrccluarx.o)",
   image_win = "shrccluarx",
   uar = "DCA_GET_CODE_LIST_BY_DISPKEY", persist
   DECLARE uar_get_code_list_by_display(p1=i4,p2=vc,p3=i4,p4=i4,p5=i4,
    p6=f8) = i4 WITH image_axp = "shrccluarx", image_aix = "libshrccluarx.a(libshrccluarx.o)",
   image_win = "shrccluarx",
   uar = "DCA_GET_CODE_LIST_BY_DISPLAY", persist
   DECLARE uar_get_code_list_by_meaning(p1=i4,p2=vc,p3=i4,p4=i4,p5=i4,
    p6=f8) = i4 WITH image_axp = "shrccluarx", image_aix = "libshrccluarx.a(libshrccluarx.o)",
   image_win = "shrccluarx",
   uar = "DCA_GET_CODE_LIST_BY_MEANING", persist
   DECLARE uar_get_code_list_by_conceptcki(p1=i4,p2=vc,p3=i4,p4=i4,p5=i4,
    p6=f8) = i4 WITH image_axp = "shrccluarx", image_aix = "libshrccluarx.a(libshrccluarx.o)",
   image_win = "shrccluarx",
   uar = "DCA_GET_CODE_LIST_BY_CONCEPTCKI", persist
   DECLARE uar_get_code_meaning(p1=f8) = c12 WITH image_axp = "shrccluarx", image_aix =
   "libshrccluarx.a(libshrccluarx.o)", image_win = "shrccluarx",
   uar = "DCA_GET_CODE_MEANING", persist
   DECLARE uar_get_code_set(p1=f8) = i4 WITH image_axp = "shrccluarx", image_aix =
   "libshrccluarx.a(libshrccluarx.o)", image_win = "shrccluarx",
   uar = "DCA_GET_CODE_SET", persist
   DECLARE uar_get_collation_seq(p1=f8) = i4 WITH image_axp = "shrccluarx", image_aix =
   "libshrccluarx.a(libshrccluarx.o)", image_win = "shrccluarx",
   uar = "DCA_GET_COLLATION_SEQ", persist
   DECLARE uar_get_conceptcki(p1=f8) = vc WITH image_axp = "shrccluarx", image_aix =
   "libshrccluarx.a(libshrccluarx.o)", image_win = "shrccluarx",
   uar = "DCA_GET_CONCEPTCKI", persist
   DECLARE uar_get_meaning_by_codeset(p1=i4,p2=vc,p3=i4,p4=f8) = i4 WITH image_axp = "shrccluarx",
   image_aix = "libshrccluarx.a(libshrccluarx.o)", image_win = "shrccluarx",
   uar = "DCA_GET_MEANING_BY_CODESET", persist
   SET stat = uar_dca_init(nullterm( $2))
  OF "N":
   CALL echo("ccldcacrm disabled, switching back to normal uars")
   SET stat = uar_dca_term(1)
   DECLARE uar_get_code(p1=f8,p2=vc,p3=vc,p4=vc) = i4 WITH persist
   DECLARE uar_get_code2(p1=f8,p2=vc,p3=vc,p4=vc,p5=vc,
    p6=i4) = i4 WITH persist
   DECLARE uar_get_code_by(p1=vc,p2=i4,p3=vc) = f8 WITH persist
   DECLARE uar_get_code_by_cki(p1=vc) = f8 WITH persist
   DECLARE uar_get_code_cki(p1=f8) = c50 WITH persist
   DECLARE uar_get_code_description(p1=f8) = c60 WITH persist
   DECLARE uar_get_code_display(p1=f8) = c40 WITH persist
   DECLARE uar_get_code_list_by_descr(p1=i4,p2=vc,p3=i4,p4=i4,p5=i4,
    p6=f8) = i4 WITH persist
   DECLARE uar_get_code_list_by_dispkey(p1=i4,p2=vc,p3=i4,p4=i4,p5=i4,
    p6=f8) = i4 WITH persist
   DECLARE uar_get_code_list_by_display(p1=i4,p2=vc,p3=i4,p4=i4,p5=i4,
    p6=f8) = i4 WITH persist
   DECLARE uar_get_code_list_by_meaning(p1=i4,p2=vc,p3=i4,p4=i4,p5=i4,
    p6=f8) = i4 WITH persist
   DECLARE uar_get_code_list_by_conceptcki(p1=i4,p2=vc,p3=i4,p4=i4,p5=i4,
    p6=f8) = i4 WITH persist
   DECLARE uar_get_code_meaning(p1=f8) = c12 WITH persist
   DECLARE uar_get_code_set(p1=f8) = i4 WITH persist
   DECLARE uar_get_collation_seq(p1=f8) = i4 WITH persist
   DECLARE uar_get_conceptcki(p1=f8) = vc WITH persist
   DECLARE uar_get_meaning_by_codeset(p1=i4,p2=vc,p3=i4,p4=f8) = i4 WITH persist
 ENDCASE
 IF (( $3 > 0))
  SET cvalue = cnvtreal( $3)
  CALL uar_dca_show(1)
  CALL echo(build2("uar_get_code_meaning         ",cvalue," = ",uar_get_code_meaning(cvalue)))
  CALL echo(build2("uar_get_code_display         ",cvalue," = ",uar_get_code_display(cvalue)))
  CALL echo(build2("uar_get_code_description     ",cvalue," = ",uar_get_code_description(cvalue)))
  CALL echo(build2("uar_get_code_cki             ",cvalue," = ",uar_get_code_cki(cvalue)))
  CALL echo(build2("uar_get_code_set             ",cvalue," = ",uar_get_code_set(cvalue)))
  CALL echo(build2("uar_get_collation_seq        ",cvalue," = ",uar_get_collation_seq(cvalue)))
  CALL echo(build2("uar_get_code                 ",cvalue," = ",uar_get_code(cvalue,rec->display,rec
     ->mean,rec->description)))
  CALL echorecord(rec)
  CALL echo(build2("uar_get_code2 for            ",cvalue," = ",uar_get_code2(cvalue,rec->display,rec
     ->mean,rec->description,rec->cki,
     rec->code_set)))
  CALL echorecord(rec)
  SET cvalue = 0.0
  SET stat = uar_get_meaning_by_codeset(57,"MALE",1,cvalue)
  CALL echo(build2("uar_get_meaning_by_codeset (57,MALE,1) stat=",stat," val=",cvalue))
 ENDIF
END GO
