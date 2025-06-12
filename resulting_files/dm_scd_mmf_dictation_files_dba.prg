CREATE PROGRAM dm_scd_mmf_dictation_files:dba
 EXECUTE dmsmanagementrtl
 FREE RECORD media_list
 RECORD media_list(
   1 qual[*]
     2 mmf_id = vc
 )
 DECLARE gauditmode = i4 WITH constant(3)
 DECLARE mmf_cnt = i4 WITH noconstant(0)
 DECLARE qual_size = i4 WITH protect, noconstant(0)
 DECLARE v_days_to_keep = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = cnvtreal(request->tokens[tok_ndx].value)
   ENDIF
 ENDFOR
 IF (v_days_to_keep < 2.0)
  DECLARE smsg = vc WITH noconstant("")
  SET smsg = uar_i18ngetmessage(i18nhandle,"Error1","Days to keep must be at least 2 days.")
  SET reply->err_msg = smsg
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dms_content_type dct,
   dms_media_instance dmi,
   dms_media_identifier dmid
  PLAN (dct
   WHERE dct.content_type_key="DICTATION")
   JOIN (dmi
   WHERE dmi.created_dt_tm < cnvtdatetime((curdate - v_days_to_keep),curtime3)
    AND dmi.dms_content_type_id=dct.dms_content_type_id
    AND  NOT ( EXISTS (
   (SELECT
    dmx.dms_media_identifier_id
    FROM dms_media_xref dmx
    WHERE dmx.dms_media_identifier_id=dmi.dms_media_identifier_id))))
   JOIN (dmid
   WHERE dmid.dms_media_identifier_id=dmi.dms_media_identifier_id)
  ORDER BY dmid.media_object_identifier
  HEAD dmid.media_object_identifier
   mmf_cnt = (mmf_cnt+ 1)
   IF (mmf_cnt > qual_size)
    qual_size = (qual_size+ 10), stat = alterlist(media_list->qual,qual_size)
   ENDIF
   media_list->qual[mmf_cnt].mmf_id = dmid.media_object_identifier
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dms_content_type dct,
   dms_media_instance dmi,
   dms_media_xref dmx,
   dms_media_identifier dmid
  PLAN (dct
   WHERE dct.content_type_key="DICTATION")
   JOIN (dmi
   WHERE dmi.created_dt_tm < cnvtdatetime((curdate - v_days_to_keep),curtime3)
    AND dmi.dms_content_type_id=dct.dms_content_type_id)
   JOIN (dmx
   WHERE dmx.dms_media_identifier_id=dmi.dms_media_identifier_id
    AND dmx.parent_entity_name="READYTOPURGE"
    AND dmx.updt_dt_tm < cnvtdatetime((curdate - v_days_to_keep),curtime3))
   JOIN (dmid
   WHERE dmid.dms_media_identifier_id=dmx.dms_media_identifier_id)
  ORDER BY dmi.dms_media_identifier_id
  HEAD dmi.dms_media_identifier_id
   mmf_cnt = (mmf_cnt+ 1)
   IF (mmf_cnt > qual_size)
    qual_size = (qual_size+ 10), stat = alterlist(media_list->qual,qual_size)
   ENDIF
   media_list->qual[mmf_cnt].mmf_id = dmid.media_object_identifier
  FOOT REPORT
   stat = alterlist(media_list->qual,mmf_cnt), qual_size = mmf_cnt
  WITH nocounter
 ;end select
 IF ((qual_size > request->max_rows))
  SET qual_size = request->max_rows
 ENDIF
 DECLARE irtn = i4 WITH protect, noconstant(0)
 DECLARE isuccess = i4 WITH protect, noconstant(0)
 DECLARE smessage = vc WITH protect, noconstant("")
 IF ((request->purge_flag != gauditmode))
  FOR (mmf_cnt = 1 TO qual_size)
    SET irtn = 0
    SET irtn = uar_dmsm_deletemediaobject(nullterm(media_list->qual[mmf_cnt].mmf_id),0)
    IF (irtn > 0)
     SET isuccess = (isuccess+ 1)
    ENDIF
  ENDFOR
  SET smessage = uar_i18nbuildmessage(i18nhandle,nullterm("PurgeOut1"),nullterm(
    "%1 out of %2 dictation audio files sucessfully deleted"),nullterm("ii"),isuccess,
   qual_size)
 ELSE
  SET smessage = uar_i18nbuildmessage(i18nhandle,nullterm("PurgeOut2"),nullterm(
    "%1 dictation audio files identified as needing to be purged"),nullterm("i"),qual_size)
 ENDIF
 SET reply->err_msg = smessage
 SET reply->table_name = "dms_media_identifier"
 IF (qual_size > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 FREE RECORD media_list
END GO
