  METHOD upload_file.

    cl_gui_frontend_services=>gui_upload(
      EXPORTING
        filename                = filename          " Name of file
        filetype                = 'ASC'             " File Type (ASCII, Binary)
*      has_field_separator     = space            " Columns Separated by Tabs in Case of ASCII Upload
*      header_length           = 0                " Length of Header for Binary Data
*      read_by_line            = 'X'              " File Written Line-By-Line to the Internal Table
*      dat_mode                = space            " Numeric and date fields are in DAT format in WS_DOWNLOAD
*      codepage                =                  " Character Representation for Output
*      ignore_cerr             = abap_true        " Ignore character set conversion errors?
*      replacement             = '#'              " Replacement Character for Non-Convertible Characters
*      virus_scan_profile      =                  " Virus Scan Profile
*    IMPORTING
*      filelength              =                  " File Length
*      header                  =                  " File Header in Case of Binary Upload
      CHANGING
        data_tab                = data_table        " Transfer table for file contents
*      isscanperformed         = space            " File already scanned
*    EXCEPTIONS
*      file_open_error         = 1                " File does not exist and cannot be opened
*      file_read_error         = 2                " Error when reading file
*      no_batch                = 3                " Cannot execute front-end function in background
*      gui_refuse_filetransfer = 4                " Incorrect front end or error on front end
*      invalid_type            = 5                " Incorrect parameter FILETYPE
*      no_authority            = 6                " No upload authorization
*      unknown_error           = 7                " Unknown error
*      bad_data_format         = 8                " Cannot Interpret Data in File
*      header_not_allowed      = 9                " Invalid header
*      separator_not_allowed   = 10               " Invalid separator
*      header_too_long         = 11               " Header information currently restricted to 1023 bytes
*      unknown_dp_error        = 12               " Error when calling data provider
*      access_denied           = 13               " Access to file denied.
*      dp_out_of_memory        = 14               " Not enough memory in data provider
*      disk_full               = 15               " Storage medium is full.
*      dp_timeout              = 16               " Data provider timeout
*      not_supported_by_gui    = 17               " GUI does not support this
*      error_no_gui            = 18               " GUI not available
*      others                  = 19
    ).
    IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDMETHOD.