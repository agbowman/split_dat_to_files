CREATE PROGRAM bed_create_rli_supplier
 INSERT  FROM br_rli_supplier b
  SET b.supplier_flag = 1, b.supplier_meaning = "ARUP RLI", b.supplier_name = "ARUP RLI",
   b.supplier_prefix = "ARUP", b.br_client_id = 0, b.content_loaded_ind = 0,
   b.default_selected_ind = 0
  WITH nocounter
 ;end insert
 INSERT  FROM br_rli_supplier b
  SET b.supplier_flag = 2, b.supplier_meaning = "Mayo RLI", b.supplier_name = "Mayo RLI",
   b.supplier_prefix = "Mayo", b.br_client_id = 0, b.content_loaded_ind = 0,
   b.default_selected_ind = 0
  WITH nocounter
 ;end insert
 INSERT  FROM br_rli_supplier b
  SET b.supplier_flag = 3, b.supplier_meaning = "LabOne RLI", b.supplier_name = "LabOne RLI",
   b.supplier_prefix = "LabOne", b.br_client_id = 0, b.content_loaded_ind = 0,
   b.default_selected_ind = 0
  WITH nocounter
 ;end insert
 INSERT  FROM br_rli_supplier b
  SET b.supplier_flag = 4, b.supplier_meaning = "Quest Toplab RLI", b.supplier_name =
   "Quest RLI - TopLab",
   b.supplier_prefix = "Quest", b.br_client_id = 0, b.content_loaded_ind = 0,
   b.default_selected_ind = 0
  WITH nocounter
 ;end insert
 INSERT  FROM br_rli_supplier b
  SET b.supplier_flag = 5, b.supplier_meaning = "Quest Antrim RLI", b.supplier_name =
   "Quest RLI - Antrim",
   b.supplier_prefix = "Quest", b.br_client_id = 0, b.content_loaded_ind = 0,
   b.default_selected_ind = 0
  WITH nocounter
 ;end insert
 INSERT  FROM br_rli_supplier b
  SET b.supplier_flag = 6, b.supplier_meaning = "Quest AML RLI", b.supplier_name = "Quest RLI - AML",
   b.supplier_prefix = "Quest", b.br_client_id = 0, b.content_loaded_ind = 0,
   b.default_selected_ind = 0
  WITH nocounter
 ;end insert
END GO
