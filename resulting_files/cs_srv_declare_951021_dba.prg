CREATE PROGRAM cs_srv_declare_951021:dba
 FREE SET rqin
 RECORD rqin(
   1 process_type_cd = f8
   1 charge_event_qual = i2
   1 process_event[*]
     2 charge_event_id = f8
     2 charge_acts[*]
       3 charge_event_act_id = f8
     2 charge_item_qual = i2
     2 charge_item[*]
       3 charge_item_id = f8
 ) WITH persistscript
 FREE SET rpout
 RECORD rpout(
   1 status = c1
 ) WITH persistscript
END GO
