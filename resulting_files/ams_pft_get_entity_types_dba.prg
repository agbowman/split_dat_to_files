CREATE PROGRAM ams_pft_get_entity_types:dba
 DECLARE visibile_ind = i2 WITH protect, constant(1)
 DECLARE invisibile_ind = i2 WITH protect, constant(0)
 DECLARE last_mod = vc WITH protect
 DECLARE loopcnt = i4 WITH protect
 DECLARE entitypos = i4 WITH protect
 DECLARE disppos = i4 WITH protect
 DECLARE valuepos = i4 WITH protect
 DECLARE i = i4 WITH protect
 RECORD pft_reply(
   1 pft_entity_type[*]
     2 code = f8
     2 meaning = c12
     2 display = vc
     2 description = vc
     2 group_cd = f8
     2 group_display = vc
     2 pft_entity_status[*]
       3 code = f8
       3 meaning = c12
       3 display = vc
       3 description = vc
       3 assign_type = i2
       3 pft_queue_event[*]
         4 code = f8
         4 meaning = c12
         4 display = vc
         4 description = vc
         4 type_flag = i2
         4 default_ind = i2
         4 action_ind = i2
       3 value_specifier[*]
         4 code = f8
         4 meaning = c12
         4 display = vc
         4 description = vc
         4 type = vc
         4 data = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 pft_status_data
     2 status = c1
     2 subeventstatus[*]
       3 status = c1
       3 table_name = vc
       3 pk_values = vc
   1 mod_objs[*]
     2 entity_type = vc
     2 mod_recs[*]
       3 table_name = vc
       3 pk_values = vc
       3 mod_flds[*]
         4 field_name = vc
         4 field_type = vc
         4 field_value_obj = vc
         4 field_value_db = vc
   1 failure_stack
     2 failures[*]
       3 programname = vc
       3 routinename = vc
       3 message = vc
 ) WITH protect
 RECORD entities(
   1 list[*]
     2 code = f8
 ) WITH protect
 EXECUTE pft_fetch_queue_data  WITH replace("REPLY",pft_reply)
 IF (size(pft_reply->pft_entity_type,5) > 0)
  EXECUTE ccl_prompt_api_dataset "AUTOSET", "DATASET", "ADVAPI"
  SET stat = makedataset(10)
  SET disppos = addstringfield("DISP","Display",visibile_ind,40)
  SET valuepos = addrealfield("VALUE","Value",invisibile_ind)
  SET stat = setkeyfield(valuepos,1)
  FOR (loopcnt = 1 TO size(pft_reply->pft_entity_type,5))
   SET entitypos = locateval(i,1,size(entities->list,5),pft_reply->pft_entity_type[loopcnt].code,
    entities->list[i].code)
   IF (entitypos=0)
    SET recordpos = getnextrecord(0)
    SET stat = setstringfield(recordpos,disppos,substring(1,40,pft_reply->pft_entity_type[loopcnt].
      display))
    SET stat = setrealfield(recordpos,valuepos,pft_reply->pft_entity_type[loopcnt].code)
    SET entitypos = (size(entities->list,5)+ 1)
    SET stat = alterlist(entities->list,entitypos)
    SET entities->list[entitypos].code = pft_reply->pft_entity_type[loopcnt].code
   ENDIF
  ENDFOR
  SET stat = closedataset(0)
 ENDIF
 SET last_mod = "000"
END GO
