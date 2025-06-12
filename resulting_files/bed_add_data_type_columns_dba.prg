CREATE PROGRAM bed_add_data_type_columns:dba
 DECLARE screen_display = vc
 DECLARE column_name = vc
 SET data_type_id = 35058
 FOR (x = 1 TO 15)
  IF (x=1)
   SET column_name = "client_unique_identifier"
   SET screen_display = ""
  ELSEIF (x=2)
   SET column_name = "long_name"
   SET screen_display = "Display"
  ELSEIF (x=3)
   SET column_name = "short_name"
   SET screen_display = "Description"
  ELSEIF (x=4)
   SET column_name = "catalog_type"
   SET screen_display = "Catalog Type"
  ELSEIF (x=5)
   SET column_name = "activity_type"
   SET screen_display = "Activity Type"
  ELSEIF (x=6)
   SET column_name = "activity_subtype"
   SET screen_display = ""
  ELSEIF (x=7)
   SET column_name = "CPT4"
   SET screen_display = ""
  ELSEIF (x=8)
   SET column_name = "CDM"
   SET screen_display = ""
  ELSEIF (x=9)
   SET column_name = "Loinc"
   SET screen_display = ""
  ELSEIF (x=10)
   SET column_name = "Alias1"
   SET screen_display = ""
  ELSEIF (x=11)
   SET column_name = "Alias2"
   SET screen_display = ""
  ELSEIF (x=12)
   SET column_name = "Alias3"
   SET screen_display = ""
  ELSEIF (x=13)
   SET column_name = "Alias4"
   SET screen_display = ""
  ELSEIF (x=14)
   SET column_name = "Alias5"
   SET screen_display = ""
  ELSEIF (x=15)
   SET column_name = "concept_cki"
   SET screen_display = ""
  ENDIF
  INSERT  FROM br_cki_data_type_columns b
   SET b.data_type_id = data_type_id, b.column_display = column_name, b.column_position = x,
    b.screen_display = screen_display
   WITH nocounter
  ;end insert
 ENDFOR
END GO
