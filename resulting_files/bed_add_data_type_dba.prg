CREATE PROGRAM bed_add_data_type:dba
 SET data_type_name = "FORMULARY"
 SET data_type_id = 0.0
 SELECT INTO "nl:"
  y = seq(bedrock_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   data_type_id = cnvtreal(y)
  WITH format, counter
 ;end select
 INSERT  FROM br_cki_data_type b
  SET b.data_type_id = data_type_id, b.data_type_name = data_type_name
  WITH nocounter
 ;end insert
END GO
