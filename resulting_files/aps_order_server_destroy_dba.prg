CREATE PROGRAM aps_order_server_destroy:dba
 CALL echo("Destroying persistent record structure of order format information.")
 FREE SET order_encntr_info
 FREE SET oe_format_info
END GO
