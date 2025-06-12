CREATE PROGRAM bed_get_interface_codesets:dba
 FREE SET reply
 RECORD reply(
   1 segments[*]
     2 segment = vc
     2 fields[*]
       3 field_name = vc
       3 code_set = i4
       3 code_set_name = vc
       3 required_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tcnt = size(request->types,5)
 SET scnt = size(request->segments,5)
 SET stat = alterlist(reply->segments,scnt)
 FOR (s = 1 TO scnt)
   SET reply->segments[s].segment = request->segments[s].segment
   SET fcnt = 0
   SET alterlist_fcnt = 0
   SET stat = alterlist(reply->segments[s].fields,50)
   FOR (t = 1 TO tcnt)
    IF ((request->types[t].in_out_ind IN (1, 3)))
     CALL echo("***** getting inbound")
     SELECT INTO "NL:"
      FROM br_type_seg_r b1,
       br_seg_field_r b2,
       code_value_set cvs
      PLAN (b1
       WHERE (b1.interface_type=request->types[t].interface_type)
        AND b1.inbound_ind=1
        AND (b1.segment_name=request->segments[s].segment))
       JOIN (b2
       WHERE b2.br_type_seg_r_id=b1.br_type_seg_r_id)
       JOIN (cvs
       WHERE cvs.code_set=b2.codeset)
      DETAIL
       fcnt = (fcnt+ 1), alterlist_fcnt = (alterlist_fcnt+ 1)
       IF (alterlist_fcnt > 50)
        stat = alterlist(reply->segments[s].fields,(fcnt+ 50)), alterlist_fcnt = 1
       ENDIF
       reply->segments[s].fields[fcnt].field_name = b2.field_name, reply->segments[s].fields[fcnt].
       code_set = b2.codeset, reply->segments[s].fields[fcnt].code_set_name = cvs.display,
       reply->segments[s].fields[fcnt].required_ind = b2.required_ind
      WITH nocounter
     ;end select
    ENDIF
    IF ((request->types[t].in_out_ind IN (2, 3)))
     CALL echo("***** getting outbound")
     SELECT INTO "NL:"
      FROM br_type_seg_r b1,
       br_seg_field_r b2,
       code_value_set cvs
      PLAN (b1
       WHERE (b1.interface_type=request->types[t].interface_type)
        AND b1.outbound_ind=1
        AND (b1.segment_name=request->segments[s].segment))
       JOIN (b2
       WHERE b2.br_type_seg_r_id=b1.br_type_seg_r_id)
       JOIN (cvs
       WHERE cvs.code_set=b2.codeset)
      DETAIL
       fcnt = (fcnt+ 1), alterlist_fcnt = (alterlist_fcnt+ 1)
       IF (alterlist_fcnt > 50)
        stat = alterlist(reply->segments[s].fields,(fcnt+ 50)), alterlist_fcnt = 1
       ENDIF
       reply->segments[s].fields[fcnt].field_name = b2.field_name, reply->segments[s].fields[fcnt].
       code_set = b2.codeset, reply->segments[s].fields[fcnt].code_set_name = cvs.display,
       reply->segments[s].fields[fcnt].required_ind = b2.required_ind
      WITH nocounter
     ;end select
    ENDIF
   ENDFOR
   SET stat = alterlist(reply->segments[s].fields,fcnt)
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
