CREATE PROGRAM dm_rdm_reset_long_rows_c:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET modify maxvarlen 268435456
 DECLARE loopvar = i4 WITH public, noconstant( $1)
 DECLARE dtt_long = vc WITH public, noconstant("")
 CALL parser('SELECT  INTO "NL:" ')
 CALL parser(concat("  BLOBLEN = TEXTLEN(L.",dm_data->qual[loopvar].long_col,") "))
 CALL parser(concat("FROM ",dm_data->qual[loopvar].pe_name,"  L"))
 CALL parser(concat("WHERE L.",dm_data->qual[loopvar].root_col," = ",cnvtstring(dm_data->qual[loopvar
    ].pe_id,20,1)))
 CALL parser("HEAD REPORT ")
 CALL parser('  OUTBUF = FILLSTRING (32767 , " " )')
 CALL parser("  OFFSET =0 ")
 CALL parser("  RETLEN =0 ")
 CALL parser("DETAIL ")
 CALL parser(concat("  RETLEN = BLOBGET ( OUTBUF ,  OFFSET , L.",dm_data->qual[dtt_loop].long_col,")"
   ))
 CALL parser('  dtt_long =" "')
 CALL parser("  WHILE ( RETLEN >0 )")
 CALL parser('    IF (dtt_long = " ")')
 CALL parser("      dtt_long = NOTRIM(OUTBUF)")
 CALL parser("    ELSE")
 CALL parser(
  "      dtt_long = NOTRIM(CONCAT(NOTRIM(dtt_long), NOTRIM(SUBSTRING(1, RETLEN, OUTBUF))))")
 CALL parser("    ENDIF")
 CALL parser("    OFFSET = OFFSET + RETLEN")
 CALL parser(concat("    RETLEN = BLOBGET(OUTBUF, OFFSET, L.",dm_data->qual[dtt_loop].long_col,")"))
 CALL parser("  ENDWHILE")
 CALL parser("  dtt_long = TRIM(dtt_long)")
 CALL parser("foot report")
 CALL parser(concat("  dm_data->qual[",trim(cnvtstring(loopvar)),"].lt_len = size(dtt_long) "))
 CALL parser("WITH NOCOUNTER, RDBARRAYFETCH=1 go")
END GO
