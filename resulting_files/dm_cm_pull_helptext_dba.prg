CREATE PROGRAM dm_cm_pull_helptext:dba
 DECLARE daf_is_blank(dib_str=vc) = i2
 DECLARE daf_is_not_blank(dinb_str=vc) = i2
 SUBROUTINE daf_is_blank(dib_str)
  IF (textlen(trim(dib_str,3)) > 0)
   RETURN(false)
  ENDIF
  RETURN(true)
 END ;Subroutine
 SUBROUTINE daf_is_not_blank(dinb_str)
  IF (textlen(trim(dinb_str,3)) > 0)
   RETURN(true)
  ENDIF
  RETURN(false)
 END ;Subroutine
 DECLARE dm_get_long_text(glt_pe_name=vc,glt_id=f8,glt_table_flag=i4,dglt_rs=vc(ref)) = vc
 SUBROUTINE dm_get_long_text(glt_pe_name,glt_id,glt_table_flag,dglt_rs)
   DECLARE glt_table_name = vc WITH protect, noconstant("")
   DECLARE glt_pk_col = vc WITH protect, noconstant("")
   DECLARE glt_long_col = vc WITH protect, noconstant("")
   DECLARE glt_long_str = vc WITH protect, noconstant("")
   DECLARE dch_err_msg = vc WITH protect, noconstant("")
   DECLARE glt_pen_blank = i2 WITH protect, noconstant(0)
   DECLARE glt_rs_cnt = i4 WITH protect, noconstant(0)
   SET glt_pen_blank = daf_is_blank(glt_pe_name)
   IF ( NOT (glt_table_flag IN (1, 2, 3, 4)))
    SET dglt_rs->status = "F"
    SET dglt_rs->status_msg = "Failure: Please pass in valid table flag 1, 2, 3, or 4"
    RETURN(dglt_rs->status)
   ENDIF
   IF (glt_table_flag IN (1, 2))
    SET glt_table_name = evaluate(glt_table_flag,1,"LONG_TEXT","LONG_TEXT_REFERENCE")
    IF (glt_id=0.0
     AND daf_is_blank(glt_pe_name))
     SET dglt_rs->status = "F"
     SET dglt_rs->status_msg = concat("Please pass in a ",glt_table_name," value > 0.0")
     RETURN(dglt_rs->status)
    ELSEIF (glt_id=0.0
     AND daf_is_not_blank(glt_pe_name))
     SET dglt_rs->status = "F"
     SET dglt_rs->status_msg = concat("Please pass in a ",glt_table_name,
      " PARENT_ENTITY_ID value > 0.0")
     RETURN(dglt_rs->status)
    ENDIF
    SELECT
     IF (daf_is_blank(glt_pe_name))
      WHERE t.long_text_id=glt_id
     ELSE
      WHERE t.parent_entity_name=glt_pe_name
       AND t.parent_entity_id=glt_id
     ENDIF
     INTO "nl:"
     FROM (parser(glt_table_name) t)
     HEAD REPORT
      outbuf = fillstring(32767,""), offset = 0
     DETAIL
      retlen = 1, glt_rs_cnt = (glt_rs_cnt+ 1), stat = alterlist(dglt_rs->qual,glt_rs_cnt),
      glt_long_str = ""
      WHILE (retlen > 0)
        retlen = blobget(outbuf,offset,t.long_text), offset = (offset+ retlen)
        IF (glt_long_str="")
         glt_long_str = notrim(outbuf)
        ELSE
         glt_long_str = concat(notrim(glt_long_str),notrim(substring(1,retlen,outbuf)))
        ENDIF
      ENDWHILE
      dglt_rs->qual[glt_rs_cnt].line_data = trim(glt_long_str,5)
     WITH nocounter
    ;end select
   ELSE
    SET glt_table_name = evaluate(glt_table_flag,3,"LONG_BLOB","LONG_BLOB_REFERENCE")
    IF (glt_id=0.0
     AND daf_is_blank(glt_pe_name))
     SET dglt_rs->status = "F"
     SET dglt_rs->status_msg = concat("Please pass in a ",glt_table_name," value > 0.0")
     RETURN(dglt_rs->status)
    ELSEIF (glt_id=0.0
     AND daf_is_not_blank(glt_pe_name))
     SET dglt_rs->status = "F"
     SET dglt_rs->status_msg = concat("Please pass in a ",glt_table_name,
      " PARENT_ENTITY_ID value > 0.0")
     RETURN(dglt_rs->status)
    ENDIF
    SELECT
     IF (daf_is_blank(glt_pe_name))
      WHERE t.long_blob_id=glt_id
     ELSE
      WHERE t.parent_entity_name=glt_pe_name
       AND t.parent_entity_id=glt_id
     ENDIF
     INTO "nl:"
     FROM (parser(glt_table_name) t)
     HEAD REPORT
      outbuf = fillstring(32767,""), offset = 0
     DETAIL
      retlen = 1, glt_rs_cnt = (glt_rs_cnt+ 1), stat = alterlist(dglt_rs->qual,glt_rs_cnt),
      glt_long_str = ""
      WHILE (retlen > 0)
        retlen = blobget(outbuf,offset,t.long_blob), offset = (offset+ retlen)
        IF (glt_long_str="")
         glt_long_str = notrim(outbuf)
        ELSE
         glt_long_str = concat(notrim(glt_long_str),notrim(substring(1,retlen,outbuf)))
        ENDIF
      ENDWHILE
      dglt_rs->qual[glt_rs_cnt].line_data = trim(glt_long_str,5)
     WITH nocounter
    ;end select
   ENDIF
   IF (error(dch_err_msg,0) > 0)
    SET dglt_rs->status = "F"
    SET dglt_rs->status_msg = dch_err_msg
   ELSEIF (curqual=0)
    SET dglt_rs->status = "F"
    SET dglt_rs->status_msg = concat("No data found for ",glt_table_name)
   ELSE
    SET dglt_rs->status = "S"
    SET dglt_rs->status_msg = ""
   ENDIF
   RETURN(dglt_rs->status)
 END ;Subroutine
 DECLARE cph_emsg = vc WITH protect, noconstant("")
 DECLARE cph_enum = i4 WITH protect, noconstant(0)
 DECLARE cph_long_text_ret = vc WITH protect, noconstant("")
 FREE RECORD dcph_helptext
 RECORD dcph_helptext(
   1 status = c1
   1 status_msg = vc
   1 qual[*]
     2 line_data = vc
 )
 FREE RECORD reply
 RECORD reply(
   1 status = c1
   1 status_msg = vc
   1 help_text = vc
 )
 SET reply->status = "F"
 SET reply->help_text = ""
 SET cph_long_text_ret = dm_get_long_text("",request->long_pk_id,2,dcph_helptext)
 SET cph_enum = error(cph_emsg,1)
 SET reply->status = cph_long_text_ret
 SET reply->status_msg = dcph_helptext->status_msg
 IF ((reply->status="S"))
  SET reply->help_text = dcph_helptext->qual[1].line_data
 ENDIF
 CALL echorecord(reply)
END GO
