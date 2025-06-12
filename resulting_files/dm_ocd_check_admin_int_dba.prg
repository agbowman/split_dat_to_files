CREATE PROGRAM dm_ocd_check_admin_int:dba
 SET errcode = 0
 SET errmsg = fillstring(132," ")
 SELECT INTO "dm_ocd_chk_adm.dat"
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   "starting"
  WITH nocounter
 ;end select
 CALL parser("free define oraclesystem go",1)
 SET errcode = error(errmsg,1)
 CALL parser(concat("define oraclesystem '",asis( $1),"/",asis( $3),"@",
   asis( $2),"' go"),1)
 SET errcode = error(errmsg,0)
 IF (errcode=0)
  SELECT INTO "dm_ocd_chk_adm.dat"
   FROM (dummyt d  WITH seq = 1)
   DETAIL
    "success"
   WITH nocounter, append
  ;end select
 ENDIF
#end_program
END GO
