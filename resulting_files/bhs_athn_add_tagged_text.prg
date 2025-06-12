CREATE PROGRAM bhs_athn_add_tagged_text
 RECORD e_request(
   1 blob = vc
   1 url_source_ind = i2
 )
 RECORD e_reply(
   1 blob = vc
 )
 RECORD t_request(
   1 param = vc
 )
 RECORD t_reply(
   1 param = vc
 )
 RECORD out_rec(
   1 status = vc
 )
 DECLARE t_line = vc
 DECLARE t_file = vc
 DECLARE t_blob = vc
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
 SET namelen = (textlen(username)+ 1)
 SET domainnamelen = (textlen(curdomain)+ 2)
 SET statval = memalloc(name,1,build("C",namelen))
 SET statval = memalloc(domainname,1,build("C",domainnamelen))
 SET name = username
 SET domainname = curdomain
 SET setcntxt = uar_secimpersonate(nullterm(username),nullterm(domainname))
 IF (( $7=1))
  SET t_blob =  $5
 ELSE
  IF (( $6 !=  $7))
   SET t_file = concat( $8,"_",trim(cnvtstring( $6)),".dat")
   SELECT INTO value(t_file)
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     col 0,  $5
    WITH nocounter, maxcol = 15250
   ;end select
   GO TO exit_script
  ENDIF
  IF (( $6= $7))
   SET t_file = concat( $8,"_",trim(cnvtstring( $6)),".dat")
   SELECT INTO value(t_file)
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     col 0,  $5
    WITH nocounter, maxcol = 15250
   ;end select
   FOR (i = 1 TO  $7)
     SET t_file = concat( $8,"_",trim(cnvtstring(i)),".dat")
     FREE DEFINE rtl3
     DEFINE rtl3 t_file
     SELECT
      FROM rtl3t r
      DETAIL
       t_line = r.line
      WITH nocounter
     ;end select
     SET t_blob = concat(trim(t_blob),trim(t_line))
   ENDFOR
  ENDIF
 ENDIF
 SET e_request->blob = t_blob
 SET e_request->url_source_ind = 1
 EXECUTE bhs_athn_base64_decode  WITH replace("REQUEST",e_request), replace("REPLY",e_reply)
 DECLARE h_string = vc
 SET t_request->param = e_reply->blob
 EXECUTE bhs_athn_format_str_param  WITH replace("REQUEST",t_request), replace("REPLY",t_reply)
 SET h_string = t_reply->param
 DECLARE c_string = vc
 SET c_string = concat(
  "<?xml version='1.0' encoding='UTF-8'?><category-data xmlns:xsi='http://www.w3.org/2001/",
  "XMLSchema-instance' xsi:noNamespaceSchemaLocation='categorization.xsd'><category display='Tagged Text' />",
  "</category-data>")
 DECLARE t_string = vc
 SET t_string = concat(format(sysdate,"yyyy-mm-dd;;q"),"T",format(sysdate,"hh:mm:ss;;q"),"Z")
 DECLARE json_string = vc
 SET json_string = '{"SAVE_TAGS": {"TAG_LIST": ['
 SET json_string = concat(json_string,'{"EMR_TYPE": "TAGTEXT","EMR_TYPE_CD": "TAGTEXT",',
  '"TAG_ENTITY_ID": "',trim(cnvtstring( $4)),'.00",',
  '"TAG_DT_TM": "',t_string,'",','"CATEGORIZATION_XML": "',c_string,
  '",','"FORMAT_CD": "XHTML",','"STORAGE_CD": "",','"BLOB_HANDLE": "",','"TAG_TEXT": "',
  trim(h_string),'"}')
 SET json_string = concat(json_string,"]}}")
 EXECUTE mp_save_tagged_results "mine", cnvtreal( $2), cnvtreal( $3),
 json_string
#exit_script
 IF (( $7=1))
  CALL echojson(out_rec, $1)
 ENDIF
 IF (( $7 > 1))
  IF (( $6 !=  $7))
   SET out_rec->status = concat("Successfully Sent Part ",trim(cnvtstring( $6))," of ",trim(
     cnvtstring( $7)))
   CALL echojson(out_rec, $1)
  ENDIF
  IF (( $6= $7))
   SET out_rec->status = "S"
   CALL echojson(out_rec, $1)
   FOR (i = 1 TO  $7)
     SET t_file = concat( $8,"_",trim(cnvtstring(i)),".dat")
     DECLARE dclcom = vc
     SET dclcom = concat("rm ",t_file)
     SET stat = 0
     CALL dcl(dclcom,size(dclcom),stat)
   ENDFOR
  ENDIF
 ENDIF
END GO
