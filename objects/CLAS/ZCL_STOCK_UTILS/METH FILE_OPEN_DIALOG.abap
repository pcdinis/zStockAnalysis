  METHOD file_open_dialog.

    DATA: lt_filetable TYPE filetable.
    DATA: lv_i         TYPE i.
    DATA: lv_file      TYPE localfile.

    REFRESH lt_filetable.
    CLEAR lv_i.

    cl_gui_frontend_services=>file_open_dialog(
      EXPORTING
        window_title            = 'Open CSV file'                 " Title Of File Open Dialog
        default_extension       = 'csv'                 " Default Extension
*        default_filename        =                  " Default File Name
*        file_filter             =                  " File Extension Filter String
*        with_encoding           =                  " File Encoding
*        initial_directory       =                  " Initial Directory
*        multiselection          =                  " Multiple selections poss.
      CHANGING
        file_table              = lt_filetable                 " Table Holding Selected Files
        rc                      = lv_i                 " Return Code, Number of Files or -1 If Error Occurred
*        user_action             =                  " User Action (See Class Constants ACTION_OK, ACTION_CANCEL)
*        file_encoding           =
*      EXCEPTIONS
*        file_open_dialog_failed = 1                " "Open File" dialog failed
*        cntl_error              = 2                " Control error
*        error_no_gui            = 3                " No GUI available
*        not_supported_by_gui    = 4                " GUI does not support this
*        others                  = 5
    ).
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      EXIT.
    ENDIF.

    lv_file = lt_filetable[ 1 ].
    e_filename = lv_file.
  ENDMETHOD.