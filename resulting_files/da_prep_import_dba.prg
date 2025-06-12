CREATE PROGRAM da_prep_import:dba
 DECLARE readmeid = i4 WITH protect, noconstant( $1)
 DECLARE typestring = vc WITH protect, noconstant(cnvtupper( $2))
 DECLARE uuid = vc WITH protect, noconstant( $3)
 DECLARE filename = vc WITH protect, noconstant( $4)
 DECLARE typenum = i4 WITH protect, noconstant(0)
 DECLARE infotext = vc WITH protect, noconstant("")
 DECLARE preperror = vc WITH protect, noconstant("")
 DECLARE existingrowind = i2 WITH protect, noconstant(0)
 DECLARE existingtype = i4 WITH protect, noconstant(0)
 DECLARE existingtext = vc WITH protect, noconstant("")
 DECLARE existingcnt = i4 WITH protect, noconstant(0)
 DECLARE textseparator = i4 WITH protect, noconstant(0)
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
 SET readme_data->status = "F"
 SET readme_data->message = "Starting da_prep_import script"
 CASE (typestring)
  OF "LV":
  OF "LOGICALVIEW":
   SET typenum = 100
  OF "BV":
  OF "BUSINESSVIEW":
   SET typenum = 200
  OF "BD":
  OF "BUSINESSDOMAIN":
   SET typenum = 300
  OF "DQ":
  OF "DAQUERY":
  OF "QUERY":
   SET typenum = 400
  OF "DR":
  OF "DAREPORT":
  OF "REPORT":
   SET typenum = 500
  OF "DC":
  OF "DACATALOG":
  OF "CATALOG":
   SET typenum = 600
 ENDCASE
 IF (typenum=0)
  SET readme_data->message = concat("Invalid type was given for import (",typestring,").")
  GO TO end_prep
 ENDIF
 IF (uuid="")
  SET readme_data->message = "No valid UUID was given for import."
  GO TO end_prep
 ENDIF
 IF (filename="")
  SET readme_data->message = "No valid file name was given for import."
  GO TO end_prep
 ENDIF
 CALL echo(concat("Import file=",filename))
 CALL echo(concat("UUID=",uuid))
 CALL echo(concat("Type=",build(typenum)," (from '",typestring,"')"))
 SET infotext = concat(build(readmeid),"|",filename)
 SELECT INTO "nl:"
  i.info_char, i.info_number, i.updt_cnt
  FROM dm_info i
  WHERE i.info_domain="DA2 Import"
   AND i.info_domain_id=0
   AND i.info_name=uuid
  DETAIL
   existingrowind = 1, existingtext = i.info_char, existingtype = i.info_number,
   existingcnt = i.updt_cnt
  WITH nocounter
 ;end select
 IF (error(preperror,0) != 0)
  SET readme_data->message = concat("Error looking for existing row: ",preperror)
  GO TO end_prep
 ENDIF
 IF (existingrowind=1)
  SET textseparator = findstring("|",existingtext)
  IF (textseparator > 0)
   CALL echo(build("Found existing row from readme=",substring(1,(textseparator - 1),existingtext),
     " with file=",substring((textseparator+ 1),(textlen(existingtext) - textseparator),existingtext)
     ))
  ELSE
   CALL echo(concat("Found existing row with text=",existingtext))
  ENDIF
  CALL echo("Updating row")
  SET readme_data->message = "Import row successfully updated"
  UPDATE  FROM dm_info i
   SET i.info_char = infotext, i.info_number = typenum, i.updt_applctx = 0,
    i.updt_task = 0, i.updt_id = 0, i.updt_dt_tm = cnvtdatetime(sysdate),
    i.updt_cnt = (i.updt_cnt+ 1)
   WHERE i.info_domain="DA2 Import"
    AND i.info_domain_id=0
    AND i.info_name=uuid
   WITH nocounter
  ;end update
  IF (error(preperror,0) != 0)
   SET readme_data->message = concat("Error updating table: ",preperror)
   GO TO end_prep
  ENDIF
 ELSE
  CALL echo("Inserting new row")
  SET readme_data->message = "Import row successfully inserted"
  INSERT  FROM dm_info i
   SET i.info_domain = "DA2 Import", i.info_name = uuid, i.info_char = infotext,
    i.info_number = typenum, i.info_date = cnvtdatetime(sysdate), i.info_domain_id = 0,
    i.updt_applctx = 0, i.updt_task = 0, i.updt_id = 0,
    i.updt_dt_tm = cnvtdatetime(sysdate), i.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (error(preperror,0) != 0)
   SET readme_data->message = concat("Error inserting row: ",preperror)
   GO TO end_prep
  ENDIF
 ENDIF
 SET readme_data->status = "S"
#end_prep
 IF ((readme_data->status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO
