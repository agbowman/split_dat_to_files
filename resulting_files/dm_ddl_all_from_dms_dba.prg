CREATE PROGRAM dm_ddl_all_from_dms:dba
 RECORD tmp(
   1 qual[*]
     2 dms_section = vc
 )
 SET dmcount = 0
 SELECT DISTINCT INTO "nl:"
  d.data_model_section
  FROM dm_tables_doc d
  WHERE  NOT (d.data_model_section IN ("UNKNOWN", "USE, LEE - Powerchart/Doc Mgmt"))
   AND d.data_model_section > ""
  DETAIL
   dmcount = (dmcount+ 1), stat = alterlist(tmp->qual,dmcount), tmp->qual[dmcount].dms_section =
   concat("EXECUTE DM_DDL_FROM_DMS ",char(34),trim(d.data_model_section,3),char(34)," go")
  WITH nocounter
 ;end select
 SET xx = 0
 FOR (xx = 1 TO dmcount)
  CALL echo(tmp->qual[xx].dms_section)
  CALL parser(tmp->qual[xx].dms_section)
 ENDFOR
 SET tablestring = concat("Data models processed: ",cnvtstring(dmcount))
 CALL echo("+")
 CALL echo(tablestring)
 CALL echo("+")
 CALL echo("****************************")
 CALL echo("***  program sucessfull ***")
 CALL echo("***************************")
 CALL echo("***************************")
 CALL echo("+")
 CALL echo("@END@")
#9999_end_program
END GO
