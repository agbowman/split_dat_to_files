CREATE PROGRAM bhs_athn_write_crossing_text
 RECORD oreply(
   1 status = vc
 )
 RECORD e_request(
   1 blob = vc
   1 url_source_ind = i2
 )
 RECORD e_reply(
   1 blob = vc
 )
 DECLARE t_line = vc
 DECLARE t_file = vc
 DECLARE t_blob = vc
 DECLARE dclcom = vc
 DECLARE username = vc
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id= $3)
    AND p.active_ind=1)
  HEAD p.person_id
   username = p.username
  WITH nocounter, time = 30
 ;end select
 IF (( $6=1))
  SET t_blob =  $8
  SET e_request->blob = t_blob
  SET e_request->url_source_ind = 1
  EXECUTE bhs_athn_base64_decode  WITH replace("REQUEST",e_request), replace("REPLY",e_reply)
  SET t_blob = e_reply->blob
 ELSE
  IF (( $5 !=  $6))
   SET t_blob =  $8
   SET e_request->blob = t_blob
   SET e_request->url_source_ind = 1
   EXECUTE bhs_athn_base64_decode  WITH replace("REQUEST",e_request), replace("REPLY",e_reply)
   SET t_blob = e_reply->blob
   SET t_file = concat( $7,"_",trim(cnvtstring( $5)),".dat")
   SELECT INTO value(t_file)
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     col 0, t_blob
    WITH nocounter, maxcol = 15250
   ;end select
   GO TO exit_script
  ENDIF
  IF (( $5= $6))
   SET t_blob =  $8
   SET e_request->blob = t_blob
   SET e_request->url_source_ind = 1
   EXECUTE bhs_athn_base64_decode  WITH replace("REQUEST",e_request), replace("REPLY",e_reply)
   SET t_blob = e_reply->blob
   SET t_file = concat( $7,"_",trim(cnvtstring( $5)),".dat")
   SELECT INTO value(t_file)
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     col 0, t_blob
    WITH nocounter, maxcol = 15250
   ;end select
   SET t_blob = ""
   FOR (i = 1 TO  $6)
     SET t_file = concat( $7,"_",trim(cnvtstring(i)),".dat")
     FREE DEFINE rtl3
     DEFINE rtl3 t_file
     SELECT
      FROM rtl3t r
      DETAIL
       t_line = r.line
      WITH nocounter
     ;end select
     SET t_blob = concat(t_blob,t_line)
   ENDFOR
  ENDIF
 ENDIF
#exit_script
 IF (( $6=1))
  IF (( $4 IN ("ASSESSMENT", "DIAGNOSES")))
   EXECUTE uhs_mpg_upd_rounding_sum "mine",  $2,  $4,
   "", "", t_blob,
   "1"
  ELSE
   EXECUTE uhs_mpg_upd_rounding_sum "mine",  $2,  $4,
   "", "", t_blob,
   "0"
  ENDIF
 ENDIF
 IF (( $6 > 1))
  IF (( $5 !=  $6))
   SET oreply->status = concat("Successfully Sent Part ",trim(cnvtstring( $5))," of ",trim(cnvtstring
     ( $6)))
   CALL echojson(oreply, $1)
  ENDIF
  IF (( $5= $6))
   FOR (i = 1 TO  $6)
     SET t_file = concat( $7,"_",trim(cnvtstring(i)),".dat")
     SET dclcom = concat("rm ",t_file)
     SET stat = 0
     CALL dcl(dclcom,size(dclcom),stat)
   ENDFOR
   IF (( $4 IN ("ASSESSMENT", "DIAGNOSES")))
    EXECUTE uhs_mpg_upd_rounding_sum "mine",  $2,  $4,
    "", "", t_blob,
    "1"
   ELSE
    EXECUTE uhs_mpg_upd_rounding_sum "mine",  $2,  $4,
    "", "", t_blob,
    "0"
   ENDIF
  ENDIF
 ENDIF
END GO
