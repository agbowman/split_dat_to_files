CREATE PROGRAM bhs_athn_write_json_output
 DECLARE final_json = vc WITH protect, noconstant('{"OUT_REC":{}}')
 CALL echo(build("MOUTPUTDEVICE:",moutputdevice))
 IF (size(trim(moutputdevice,3)) > 0)
  SET final_json = trim(replace(replace(cnvtrectojson(out_rec),':""',":null",0),':"0"',":null",0),3)
 ENDIF
 SET _memory_reply_string = final_json
 CALL echo(_memory_reply_string)
END GO
