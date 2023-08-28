unit uICMP;

interface

uses windows;

const
// IP_STATUS codes returned from IP APIs

   IP_STATUS_BASE                 = 11000;
   IP_SUCCESS                     = 0;
   IP_BUF_TOO_SMALL               = (IP_STATUS_BASE + 1);
   IP_DEST_NET_UNREACHABLE        = (IP_STATUS_BASE + 2);
   IP_DEST_HOST_UNREACHABLE       = (IP_STATUS_BASE + 3);
   IP_DEST_PROT_UNREACHABLE       = (IP_STATUS_BASE + 4);
   IP_DEST_PORT_UNREACHABLE       = (IP_STATUS_BASE + 5);
   IP_NO_RESOURCES                = (IP_STATUS_BASE + 6);
   IP_BAD_OPTION                  = (IP_STATUS_BASE + 7);
   IP_HW_ERROR                    = (IP_STATUS_BASE + 8);
   IP_PACKET_TOO_BIG              = (IP_STATUS_BASE + 9);
   IP_REQ_TIMED_OUT               = (IP_STATUS_BASE + 10);
   IP_BAD_REQ                     = (IP_STATUS_BASE + 11);
   IP_BAD_ROUTE                   = (IP_STATUS_BASE + 12);
   IP_TTL_EXPIRED_TRANSIT         = (IP_STATUS_BASE + 13);
   IP_TTL_EXPIRED_REASSEM         = (IP_STATUS_BASE + 14);
   IP_PARAM_PROBLEM               = (IP_STATUS_BASE + 15);
   IP_SOURCE_QUENCH               = (IP_STATUS_BASE + 16);
   IP_OPTION_TOO_BIG              = (IP_STATUS_BASE + 17);
   IP_BAD_DESTINATION             = (IP_STATUS_BASE + 18);

// The next group are status codes passed up on status indications to
// transport layer protocols.
   IP_ADDR_DELETED                = (IP_STATUS_BASE + 19);
   IP_SPEC_MTU_CHANGE             = (IP_STATUS_BASE + 20);
   IP_MTU_CHANGE                  = (IP_STATUS_BASE + 21);
   IP_UNLOAD                      = (IP_STATUS_BASE + 22);
   IP_GENERAL_FAILURE             = (IP_STATUS_BASE + 50);
   MAX_IP_STATUS                  = IP_GENERAL_FAILURE;
   IP_PENDING                     = (IP_STATUS_BASE + 255);

// Values used in the IP header Flags field.
   IP_FLAG_DF                     = $2;        //  Don't fragment this packet.

// Supported IP Option Types.
// These types define the options which may be used in the OptionsData field
// of the ip_option_information structure.  See RFC 791 for a complete
// description of each.
   IP_OPT_EOL                     = 0;         //  End of list option
   IP_OPT_NOP                     = 1;         //  No operation
   IP_OPT_SECURITY                = $82;       //  Security option
   IP_OPT_LSRR                    = $83;       //  Loose source route
   IP_OPT_SSRR                    = $89;       //  Strict source route
   IP_OPT_RR                      = $7;        //  Record route
   IP_OPT_TS                      = $44;       //  Timestamp
   IP_OPT_SID                     = $88;       //  Stream ID (obsolete)

   MAX_OPT_SIZE                   = 40;        //  Maximum length of IP options in bytes


type
  TIPAddr = Integer;     // An IP address.
  TIPMask = Integer;     // An IP subnet mask.
  TIP_STATUS = Integer;  // Status code returned from IP APIs.

  POption_Information = ^TOption_Information;
  TOption_Information = packed record
    TTL: Byte;             // Time To Live
    TOS: Byte;             // Type Of Service
    Flags: Byte;           // IP header flags
    OptionsSize: Byte;     // Size in bytes of options data
    OptionsData: Pointer;  // Pointer to options data
  end;

  PIcmp_echo_reply = ^Ticmp_echo_reply;
  TIcmp_echo_reply = packed record
    Address: TIPAddr;                // Replying address
    Status: Integer;                 // Reply IP_STATUS
    RoundTripTime: Integer;          // RTT in milliseconds
    DataSize: Word;                  // Reply data size in bytes
    Reserved: Word;                  // Reserved for system use
    Data: Pointer;                   // Pointer to the reply data
    Options: TOption_Information;    // Reply options
  end;

  TsmICMP_Echo_Reply = packed record
    Address: TIPAddr;                // Replying address
    Status: Integer;                 // Reply IP_STATUS
    RoundTripTime: Integer;          // RTT in milliseconds
    DataSize: Word;                  // Reply data size in bytes
    Reserved: Word;                  // Reserved for system use
    DataPtr: Pointer;                // Pointer to the reply data
    Options: TOption_Information;    // Reply options
    Data: array[0..255] of Byte;
  end;

function IcmpCreateFile: THandle; stdcall;
function IcmpCloseHandle(IcmpHandle: THandle): Boolean; stdcall;
function IcmpSendEcho(IcmpHandle: THandle; DestinationAddress: TipAddr;
            		      RequestData: Pointer; RequestSize: Word;
                      RequestOptions: POption_Information; ReplyBuffer: Pointer;
		                  ReplySize: Integer; Timeout: Integer): Integer; stdcall;
implementation

function IcmpCreateFile;        external 'Icmp.Dll';
function IcmpCloseHandle;       external 'Icmp.Dll';
function IcmpSendEcho;          external 'Icmp.Dll';

end.
