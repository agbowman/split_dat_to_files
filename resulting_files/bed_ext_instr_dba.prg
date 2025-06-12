CREATE PROGRAM bed_ext_instr:dba
 SELECT INTO "CER_INSTALL:instr.csv"
  FROM br_instr b
  ORDER BY b.br_instr_id
  HEAD REPORT
   "sequence,supplier,model,type,code_name,uni,bi,hq,poc,multiplexor,robotics,",
   "previous_supplier,activity_type,supplier_alias,model_alias"
  DETAIL
   supplier = concat('"',trim(b.manufacturer),'"'), model = concat('"',trim(b.model),'"'), type =
   concat('"',trim(b.type),'"'),
   code_name = concat('"',trim(b.code_name),'"'), prev_supplier = concat('"',trim(b.prev_manufacturer
     ),'"'), activity_type = concat('"',trim(b.activity_type_mean),'"'),
   supplier_alias = concat('"',trim(b.manufacturer_alias),'"'), model_alias = concat('"',trim(b
     .model_alias),'"'), row + 1,
   line = concat(trim(cnvtstring(b.br_instr_id)),",",trim(supplier),",",trim(model),
    ",",trim(type),",",trim(code_name),",")
   IF (b.uni_ind=1)
    line = concat(trim(line),"X,")
   ELSE
    line = concat(trim(line),",")
   ENDIF
   IF (b.bi_ind=1)
    line = concat(trim(line),"X,")
   ELSE
    line = concat(trim(line),",")
   ENDIF
   IF (b.hq_ind=1)
    line = concat(trim(line),"X,")
   ELSE
    line = concat(trim(line),",")
   ENDIF
   IF (b.point_of_care_ind=1)
    line = concat(trim(line),"X,")
   ELSE
    line = concat(trim(line),",")
   ENDIF
   IF (b.multiplexor_ind=1)
    line = concat(trim(line),"X,")
   ELSE
    line = concat(trim(line),",")
   ENDIF
   IF (b.robotics_ind=1)
    line = concat(trim(line),"X,")
   ELSE
    line = concat(trim(line),",")
   ENDIF
   line = concat(trim(line),trim(prev_supplier),",",trim(activity_type),",",
    trim(supplier_alias),",",trim(model_alias)), line
  WITH maxcol = 1000, noformfeed, format = variable,
   nocounter
 ;end select
END GO
