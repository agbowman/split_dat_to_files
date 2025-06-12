CREATE PROGRAM dm_ocd_readme:dba
 SET out_file_name = fillstring(30," ")
 SET dfile_name = trim(cnvtlower( $1))
 SET pname = trim(cnvtlower( $2))
 SET pname_len = 0
 SET pname_len = size(pname)
 IF (pname_len > 26)
  SET short_pname = substring(1,26,pname)
 ELSE
  SET short_pname = pname
 ENDIF
 SET blocks_to_process =  $3
 SET dm_ocd_number = format( $4,"######;P0")
 EXECUTE dm_readme_import value(dfile_name), value(pname), value(blocks_to_process),
 0
END GO
