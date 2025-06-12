CREATE PROGRAM cclsrvrtl:dba
 PAINT
  box(2,1,6,80), text(1,1," CCLSRVRTL Server RTL Viewer               "), text(3,2,
   "Server Number                   (1 to 999) "),
  text(4,2,"Instance Number                 (1 to 999) "), text(5,2,
   "Domain Number                   (1 to 999) "), accept(3,25,"999",0),
  accept(4,25,"999",1), accept(5,25,"999",1)
 SET p_file = fillstring(50," ")
 SET p_type = fillstring(30," ")
 SET p_server =  $1
 SET p_instance =  $2
 SET p_domain =  $3
 SET p_cmb_instance = 0
 SET p_node = " "
 SET p_cmb_instance = cnvtint(logical("CMB_INSTANCE"))
 SET p_node = logical("PNODE")
 IF (p_node=" ")
  SET p_node = "a"
 ENDIF
 SET p_file = concat("rtlsrv",format((mod((p_domain * 1024),1024)+ p_server),"####;rp0"),"_",format(
   p_instance,"##;rp0"),"_",
  format(p_cmb_instance,"#"),p_node,".log")
 IF (p_file > " ")
  FREE DEFINE rtl
  DEFINE rtl trim(p_file)
  SELECT INTO "MINE"
   rtlt.line
   FROM rtlt
   WITH counter
  ;end select
  FREE DEFINE rtl
 ENDIF
END GO
