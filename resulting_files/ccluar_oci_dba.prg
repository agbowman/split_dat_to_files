CREATE PROGRAM ccluar_oci:dba
 PROMPT
  "uar_oci enable/disable (Y/N): " = "N",
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
  FREE SUBROUTINE uar_oci_get_code
  FREE SUBROUTINE uar_oci_get_code2
  FREE SUBROUTINE uar_oci_get_code_by
  FREE SUBROUTINE uar_oci_get_code_by_cki
  FREE SUBROUTINE uar_oci_get_code_cki
  FREE SUBROUTINE uar_oci_get_code_description
  FREE SUBROUTINE uar_oci_get_code_display
  FREE SUBROUTINE uar_oci_get_code_list_by_descr
  FREE SUBROUTINE uar_oci_get_code_list_by_dispkey
  FREE SUBROUTINE uar_oci_get_code_list_by_display
  FREE SUBROUTINE uar_oci_get_code_list_by_meaning
  FREE SUBROUTINE uar_oci_get_code_list_by_conceptcki
  FREE SUBROUTINE uar_oci_get_code_meaning
  FREE SUBROUTINE uar_oci_get_code_set
  FREE SUBROUTINE uar_oci_get_collation_seq
  FREE SUBROUTINE uar_oci_get_conceptcki
  FREE SUBROUTINE uar_oci_get_meaning_by_codeset
 ENDIF
 CASE (cnvtupper( $1))
  OF "Y":
   CALL echo("ccluar_oci, declaring uar_oci calls.")
   FREE SUBROUTINE uar_oci_show
   DECLARE uar_oci_show(p1=i4) = i4 WITH image_axp = "shrccluar", image_aix =
   "libshrccluar(libshrccluar.o)", image_win = "shrccluar",
   uar = "OCI_SHOW", persist
   DECLARE uar_oci_get_code(p1=f8,p2=vc,p3=vc,p4=vc) = i4 WITH image_axp = "shrccluar", image_aix =
   "libshrccluar(libshrccluar.o)", image_win = "shrccluar",
   uar = "OCI_GET_CODE", persist
   DECLARE uar_oci_get_code2(p1=f8,p2=vc,p3=vc,p4=vc,p5=vc,
    p6=i4) = i4 WITH image_axp = "shrccluar", image_aix = "libshrccluar(libshrccluar.o)", image_win
    = "shrccluar",
   uar = "OCI_GET_CODE2", persist
   DECLARE uar_oci_get_code_by(p1=vc,p2=i4,p3=vc) = f8 WITH image_axp = "shrccluar", image_aix =
   "libshrccluar(libshrccluar.o)", image_win = "shrccluar",
   uar = "OCI_GET_CODE_BY", persist
   DECLARE uar_oci_get_code_by_cki(p1=vc) = f8 WITH image_axp = "shrccluar", image_aix =
   "libshrccluar(libshrccluar.o)", image_win = "shrccluar",
   uar = "OCI_GET_CODE_BY_CKI", persist
   DECLARE uar_oci_get_code_cki(p1=f8) = c50 WITH image_axp = "shrccluar", image_aix =
   "libshrccluar(libshrccluar.o)", image_win = "shrccluar",
   uar = "OCI_GET_CODE_CKI", persist
   DECLARE uar_oci_get_code_description(p1=f8) = c60 WITH image_axp = "shrccluar", image_aix =
   "libshrccluar(libshrccluar.o)", image_win = "shrccluar",
   uar = "OCI_GET_CODE_DESCRIPTION", persist
   DECLARE uar_oci_get_code_display(p1=f8) = c40 WITH image_axp = "shrccluar", image_aix =
   "libshrccluar(libshrccluar.o)", image_win = "shrccluar",
   uar = "OCI_GET_CODE_DISPLAY", persist
   DECLARE uar_oci_get_code_list_by_descr(p1=i4,p2=vc,p3=i4,p4=i4,p5=i4,
    p6=f8) = i4 WITH image_axp = "shrccluar", image_aix = "libshrccluar(libshrccluar.o)", image_win
    = "shrccluar",
   uar = "OCI_GET_CODE_LIST_BY_DESCR", persist
   DECLARE uar_oci_get_code_list_by_dispkey(p1=i4,p2=vc,p3=i4,p4=i4,p5=i4,
    p6=f8) = i4 WITH image_axp = "shrccluar", image_aix = "libshrccluar(libshrccluar.o)", image_win
    = "shrccluar",
   uar = "OCI_GET_CODE_LIST_BY_DISPKEY", persist
   DECLARE uar_oci_get_code_list_by_display(p1=i4,p2=vc,p3=i4,p4=i4,p5=i4,
    p6=f8) = i4 WITH image_axp = "shrccluar", image_aix = "libshrccluar(libshrccluar.o)", image_win
    = "shrccluar",
   uar = "OCI_GET_CODE_LIST_BY_DISPLAY", persist
   DECLARE uar_oci_get_code_list_by_meaning(p1=i4,p2=vc,p3=i4,p4=i4,p5=i4,
    p6=f8) = i4 WITH image_axp = "shrccluar", image_aix = "libshrccluar(libshrccluar.o)", image_win
    = "shrccluar",
   uar = "OCI_GET_CODE_LIST_BY_MEANING", persist
   DECLARE uar_oci_get_code_list_by_conceptcki(p1=i4,p2=vc,p3=i4,p4=i4,p5=i4,
    p6=f8) = i4 WITH image_axp = "shrccluar", image_aix = "libshrccluar(libshrccluar.o)", image_win
    = "shrccluar",
   uar = "OCI_GET_CODE_LIST_BY_CONCEPTCKI", persist
   DECLARE uar_oci_get_code_meaning(p1=f8) = c12 WITH image_axp = "shrccluar", image_aix =
   "libshrccluar(libshrccluar.o)", image_win = "shrccluar",
   uar = "OCI_GET_CODE_MEANING", persist
   DECLARE uar_oci_get_code_set(p1=f8) = i4 WITH image_axp = "shrccluar", image_aix =
   "libshrccluar(libshrccluar.o)", image_win = "shrccluar",
   uar = "OCI_GET_CODE_SET", persist
   DECLARE uar_oci_get_collation_seq(p1=f8) = i4 WITH image_axp = "shrccluar", image_aix =
   "libshrccluar(libshrccluar.o)", image_win = "shrccluar",
   uar = "OCI_GET_COLLATION_SEQ", persist
   DECLARE uar_oci_get_conceptcki(p1=f8) = vc WITH image_axp = "shrccluar", image_aix =
   "libshrccluar(libshrccluar.o)", image_win = "shrccluar",
   uar = "OCI_GET_CONCEPTCKI", persist
   DECLARE uar_oci_get_meaning_by_codeset(p1=i4,p2=vc,p3=i4,p4=f8) = i4 WITH image_axp = "shrccluar",
   image_aix = "libshrccluar(libshrccluar.o)", image_win = "shrccluar",
   uar = "OCI_GET_MEANING_BY_CODESET", persist
 ENDCASE
 IF (( $2 > 0))
  SET cvalue = cnvtreal( $2)
  CALL uar_oci_show(1)
  CALL echo(build2("uar_oci_get_code_meaning         ",cvalue," = ",uar_oci_get_code_meaning(cvalue))
   )
  CALL echo(build2("uar_oci_get_code_display         ",cvalue," = ",uar_oci_get_code_display(cvalue))
   )
  CALL echo(build2("uar_oci_get_code_description     ",cvalue," = ",uar_oci_get_code_description(
     cvalue)))
  CALL echo(build2("uar_oci_get_code_cki             ",cvalue," = ",uar_oci_get_code_cki(cvalue)))
  CALL echo(build2("uar_oci_get_code_set             ",cvalue," = ",uar_oci_get_code_set(cvalue)))
  CALL echo(build2("uar_oci_get_collation_seq        ",cvalue," = ",uar_oci_get_collation_seq(cvalue)
    ))
  CALL echo(build2("uar_oci_get_code                 ",cvalue," = ",uar_oci_get_code(cvalue,rec->
     display,rec->mean,rec->description)))
  CALL echorecord(rec)
  CALL echo(build2("uar_oci_get_code2 for            ",cvalue," = ",uar_oci_get_code2(cvalue,rec->
     display,rec->mean,rec->description,rec->cki,
     rec->code_set)))
  CALL echorecord(rec)
  SET cvalue = 0.0
  SET stat = uar_oci_get_meaning_by_codeset(57,"MALE",1,cvalue)
  CALL echo(build2("uar_oci_get_meaning_by_codeset (57,MALE,1) stat=",stat," val=",cvalue))
 ENDIF
END GO
