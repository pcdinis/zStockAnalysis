*&---------------------------------------------------------------------*
*& Report ZSTOCK_TAX_ANALYSIS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zstock_tax_analysis.

TYPES: BEGIN OF ty_datatab,
         row(1000) TYPE c,
       END OF ty_datatab.

DATA: gt_datatab            TYPE TABLE OF ty_datatab.
DATA: gt_file_data          TYPE TABLE OF zstock_degiro_transactions.
DATA: gs_file_data          TYPE zstock_degiro_transactions.
DATA: gt_stock_transactions TYPE TABLE OF zstock_transactions.
DATA: gs_stock_transactions TYPE zstock_transactions.
DATA: gt_stock_data         TYPE TABLE OF zstock_tax_data.
DATA: gs_stock_data         TYPE zstock_tax_data.
DATA: gr_salv               TYPE REF TO cl_salv_table.
DATA: gr_functions          TYPE REF TO cl_salv_functions_list.
DATA: gv_file               TYPE string.

PARAMETERS: p_isin TYPE zstock_isin.
PARAMETERS: p_file LIKE rlgrap-filename.
PARAMETERS: p_agg  TYPE abap_boolean AS CHECKBOX.

INCLUDE zstock_tax_analysis_f01.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

* File open dialog
  zcl_stock_utils=>file_open_dialog( IMPORTING e_filename = gv_file ).
  p_file = gv_file.

START-OF-SELECTION.

* Only to ensure that if a variant is selected the program does not break!
  IF p_file IS NOT INITIAL.
    gv_file = p_file.
  ENDIF.

* Upload file
  PERFORM upload_file.

* Convert filetable rawstring to a specific table
  PERFORM convert_raw_to_str.

* Take file data and transform to stock transaction structure
  PERFORM transform_data.

* Do the maths
  PERFORM do_tax_calculation.

* If Aggregation is selected than show the total values by YEAR
  PERFORM aggregation_by_year.

* Show data
  PERFORM show_data.