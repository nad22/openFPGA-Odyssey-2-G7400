//
// User core top-level
//
// Instantiated by the real top-level: apf_top
//

`default_nettype none

module core_top (

//
// physical connections
//

///////////////////////////////////////////////////
// clock inputs 74.25mhz. not phase aligned, so treat these domains as asynchronous

input   wire            clk_74a, // mainclk1
input   wire            clk_74b, // mainclk1 

///////////////////////////////////////////////////
// cartridge interface
// switches between 3.3v and 5v mechanically
// output enable for multibit translators controlled by pic32

// GBA AD[15:8]
inout   wire    [7:0]   cart_tran_bank2,
output  wire            cart_tran_bank2_dir,

// GBA AD[7:0]
inout   wire    [7:0]   cart_tran_bank3,
output  wire            cart_tran_bank3_dir,

// GBA A[23:16]
inout   wire    [7:0]   cart_tran_bank1,
output  wire            cart_tran_bank1_dir,

// GBA [7] PHI#
// GBA [6] WR#
// GBA [5] RD#
// GBA [4] CS1#/CS#
//     [3:0] unwired
inout   wire    [7:4]   cart_tran_bank0,
output  wire            cart_tran_bank0_dir,

// GBA CS2#/RES#
inout   wire            cart_tran_pin30,
output  wire            cart_tran_pin30_dir,
// when GBC cart is inserted, this signal when low or weak will pull GBC /RES low with a special circuit
// the goal is that when unconfigured, the FPGA weak pullups won't interfere.
// thus, if GBC cart is inserted, FPGA must drive this high in order to let the level translators
// and general IO drive this pin.
output  wire            cart_pin30_pwroff_reset,

// GBA IRQ/DRQ
inout   wire            cart_tran_pin31,
output  wire            cart_tran_pin31_dir,

// infrared
input   wire            port_ir_rx,
output  wire            port_ir_tx,
output  wire            port_ir_rx_disable, 

// GBA link port
inout   wire            port_tran_si,
output  wire            port_tran_si_dir,
inout   wire            port_tran_so,
output  wire            port_tran_so_dir,
inout   wire            port_tran_sck,
output  wire            port_tran_sck_dir,
inout   wire            port_tran_sd,
output  wire            port_tran_sd_dir,
 
///////////////////////////////////////////////////
// cellular psram 0 and 1, two chips (64mbit x2 dual die per chip)

output  wire    [21:16] cram0_a,
inout   wire    [15:0]  cram0_dq,
input   wire            cram0_wait,
output  wire            cram0_clk,
output  wire            cram0_adv_n,
output  wire            cram0_cre,
output  wire            cram0_ce0_n,
output  wire            cram0_ce1_n,
output  wire            cram0_oe_n,
output  wire            cram0_we_n,
output  wire            cram0_ub_n,
output  wire            cram0_lb_n,

output  wire    [21:16] cram1_a,
inout   wire    [15:0]  cram1_dq,
input   wire            cram1_wait,
output  wire            cram1_clk,
output  wire            cram1_adv_n,
output  wire            cram1_cre,
output  wire            cram1_ce0_n,
output  wire            cram1_ce1_n,
output  wire            cram1_oe_n,
output  wire            cram1_we_n,
output  wire            cram1_ub_n,
output  wire            cram1_lb_n,

///////////////////////////////////////////////////
// sdram, 512mbit 16bit

output  wire    [12:0]  dram_a,
output  wire    [1:0]   dram_ba,
inout   wire    [15:0]  dram_dq,
output  wire    [1:0]   dram_dqm,
output  wire            dram_clk,
output  wire            dram_cke,
output  wire            dram_ras_n,
output  wire            dram_cas_n,
output  wire            dram_we_n,

///////////////////////////////////////////////////
// sram, 1mbit 16bit

output  wire    [16:0]  sram_a,
inout   wire    [15:0]  sram_dq,
output  wire            sram_oe_n,
output  wire            sram_we_n,
output  wire            sram_ub_n,
output  wire            sram_lb_n,

///////////////////////////////////////////////////
// vblank driven by dock for sync in a certain mode

input   wire            vblank,

///////////////////////////////////////////////////
// i/o to 6515D breakout usb uart

output  wire            dbg_tx,
input   wire            dbg_rx,

///////////////////////////////////////////////////
// i/o pads near jtag connector user can solder to

output  wire            user1,
input   wire            user2,

///////////////////////////////////////////////////
// RFU internal i2c bus 

inout   wire            aux_sda,
output  wire            aux_scl,

///////////////////////////////////////////////////
// RFU, do not use
output  wire            vpll_feed,


//
// logical connections
//

///////////////////////////////////////////////////
// video, audio output to scaler
output  wire    [23:0]  video_rgb,
output  wire            video_rgb_clock,
output  wire            video_rgb_clock_90,
output  wire            video_de,
output  wire            video_skip,
output  wire            video_vs,
output  wire            video_hs,
    
output  wire            audio_mclk,
input   wire            audio_adc,
output  wire            audio_dac,
output  wire            audio_lrck,

///////////////////////////////////////////////////
// bridge bus connection
// synchronous to clk_74a
output  wire            bridge_endian_little,
input   wire    [31:0]  bridge_addr,
input   wire            bridge_rd,
output  reg     [31:0]  bridge_rd_data,
input   wire            bridge_wr,
input   wire    [31:0]  bridge_wr_data,

///////////////////////////////////////////////////
// controller data
// 
// key bitmap:
//   [0]    dpad_up
//   [1]    dpad_down
//   [2]    dpad_left
//   [3]    dpad_right
//   [4]    face_a
//   [5]    face_b
//   [6]    face_x
//   [7]    face_y
//   [8]    trig_l1
//   [9]    trig_r1
//   [10]   trig_l2
//   [11]   trig_r2
//   [12]   trig_l3
//   [13]   trig_r3
//   [14]   face_select
//   [15]   face_start
//   [31:28] type
// joy values - unsigned
//   [ 7: 0] lstick_x
//   [15: 8] lstick_y
//   [23:16] rstick_x
//   [31:24] rstick_y
// trigger values - unsigned
//   [ 7: 0] ltrig
//   [15: 8] rtrig
//
input   wire    [31:0]  cont1_key,
input   wire    [31:0]  cont2_key,
input   wire    [31:0]  cont3_key,
input   wire    [31:0]  cont4_key,
input   wire    [31:0]  cont1_joy,
input   wire    [31:0]  cont2_joy,
input   wire    [31:0]  cont3_joy,
input   wire    [31:0]  cont4_joy,
input   wire    [15:0]  cont1_trig,
input   wire    [15:0]  cont2_trig,
input   wire    [15:0]  cont3_trig,
input   wire    [15:0]  cont4_trig
    
);

// not using the IR port, so turn off both the LED, and
// disable the receive circuit to save power
assign port_ir_tx = 0;
assign port_ir_rx_disable = 1;

// bridge endianness
assign bridge_endian_little = 0;

// cart is unused, so set all level translators accordingly
// directions are 0:IN, 1:OUT
assign cart_tran_bank3 = 8'hzz;
assign cart_tran_bank3_dir = 1'b0;
assign cart_tran_bank2 = 8'hzz;
assign cart_tran_bank2_dir = 1'b0;
assign cart_tran_bank1 = 8'hzz;
assign cart_tran_bank1_dir = 1'b0;
assign cart_tran_bank0 = 4'hf;
assign cart_tran_bank0_dir = 1'b1;
assign cart_tran_pin30 = 1'b0;      // reset or cs2, we let the hw control it by itself
assign cart_tran_pin30_dir = 1'bz;
assign cart_pin30_pwroff_reset = 1'b0;  // hardware can control this
assign cart_tran_pin31 = 1'bz;      // input
assign cart_tran_pin31_dir = 1'b0;  // input

// link port is unused, set to input only to be safe
// each bit may be bidirectional in some applications
assign port_tran_so = 1'bz;
assign port_tran_so_dir = 1'b0;     // SO is output only
assign port_tran_si = 1'bz;
assign port_tran_si_dir = 1'b0;     // SI is input only
assign port_tran_sck = 1'bz;
assign port_tran_sck_dir = 1'b0;    // clock direction can change
assign port_tran_sd = 1'bz;
assign port_tran_sd_dir = 1'b0;     // SD is input and not used

// tie off the rest of the pins we are not using
assign cram0_a = 'h0;
assign cram0_dq = {16{1'bZ}};
assign cram0_clk = 0;
assign cram0_adv_n = 1;
assign cram0_cre = 0;
assign cram0_ce0_n = 1;
assign cram0_ce1_n = 1;
assign cram0_oe_n = 1;
assign cram0_we_n = 1;
assign cram0_ub_n = 1;
assign cram0_lb_n = 1;

assign cram1_a = 'h0;
assign cram1_dq = {16{1'bZ}};
assign cram1_clk = 0;
assign cram1_adv_n = 1;
assign cram1_cre = 0;
assign cram1_ce0_n = 1;
assign cram1_ce1_n = 1;
assign cram1_oe_n = 1;
assign cram1_we_n = 1;
assign cram1_ub_n = 1;
assign cram1_lb_n = 1;

assign dram_a = 'h0;
assign dram_ba = 'h0;
assign dram_dq = {16{1'bZ}};
assign dram_dqm = 'h0;
assign dram_clk = 'h0;
assign dram_cke = 'h0;
assign dram_ras_n = 'h1;
assign dram_cas_n = 'h1;
assign dram_we_n = 'h1;

assign sram_a = 'h0;
assign sram_dq = {16{1'bZ}};
assign sram_oe_n  = 1;
assign sram_we_n  = 1;
assign sram_ub_n  = 1;
assign sram_lb_n  = 1;

assign dbg_tx = 1'bZ;
assign user1 = 1'bZ;
assign aux_scl = 1'bZ;
assign vpll_feed = 1'bZ;


// for bridge write data, we just broadcast it to all bus devices
// for bridge read data, we have to mux it
// add your own devices here
always @(*) begin
    casex(bridge_addr)
    default: begin
        bridge_rd_data <= 0;
    end
    32'h10xxxxxx: begin
        case (bridge_addr)
            32'h1000024C: bridge_rd_data <= controller_swap;
            32'h10000250: bridge_rd_data <= system_mode;
            default: bridge_rd_data <= 0;
        endcase
    end
    32'hF8xxxxxx: begin
        bridge_rd_data <= cmd_bridge_rd_data;
    end
    endcase
end


//
// host/target command handler
//
    wire            reset_n;
    wire    [31:0]  cmd_bridge_rd_data;
    reg     [1:0]   system_mode = 2'd0;
    reg             controller_swap = 1'b0;

always @(posedge clk_74a) begin
    if (bridge_wr && bridge_addr == 32'h10000250)
        system_mode <= bridge_wr_data[1:0];
    if (bridge_wr && bridge_addr == 32'h1000024C)
        controller_swap <= bridge_wr_data[0];
end
    
// bridge host commands
// synchronous to clk_74a
    wire            status_boot_done = pll_core_locked_s; 
    wire            status_setup_done = pll_core_locked_s && dataslot_allcomplete;
    wire            status_running = reset_n; // we are running as soon as reset_n goes high

    wire            dataslot_requestread;
    wire    [15:0]  dataslot_requestread_id;
    wire            dataslot_requestread_ack = 1;
    wire            dataslot_requestread_ok = 1;

    wire            dataslot_requestwrite;
    wire    [15:0]  dataslot_requestwrite_id;
    wire    [31:0]  dataslot_requestwrite_size;
    wire            dataslot_requestwrite_ack = 1;
    wire            dataslot_requestwrite_ok = 1;

    wire            dataslot_update;
    wire    [15:0]  dataslot_update_id;
    wire    [31:0]  dataslot_update_size;
    
    wire            dataslot_allcomplete;

    wire     [31:0] rtc_epoch_seconds;
    wire     [31:0] rtc_date_bcd;
    wire     [31:0] rtc_time_bcd;
    wire            rtc_valid;

    wire            savestate_supported;
    wire    [31:0]  savestate_addr;
    wire    [31:0]  savestate_size;
    wire    [31:0]  savestate_maxloadsize;

    wire            savestate_start;
    wire            savestate_start_ack;
    wire            savestate_start_busy;
    wire            savestate_start_ok;
    wire            savestate_start_err;

    wire            savestate_load;
    wire            savestate_load_ack;
    wire            savestate_load_busy;
    wire            savestate_load_ok;
    wire            savestate_load_err;
    
    wire            osnotify_inmenu;

// bridge target commands
// synchronous to clk_74a

    reg             target_dataslot_read;       
    reg             target_dataslot_write;
    reg             target_dataslot_getfile;    // require additional param/resp structs to be mapped
    reg             target_dataslot_openfile;   // require additional param/resp structs to be mapped
    
    wire            target_dataslot_ack;        
    wire            target_dataslot_done;
    wire    [2:0]   target_dataslot_err;

    reg     [15:0]  target_dataslot_id;
    reg     [31:0]  target_dataslot_slotoffset;
    reg     [31:0]  target_dataslot_bridgeaddr;
    reg     [31:0]  target_dataslot_length;
    
    wire    [31:0]  target_buffer_param_struct; // to be mapped/implemented when using some Target commands
    wire    [31:0]  target_buffer_resp_struct;  // to be mapped/implemented when using some Target commands
    
// bridge data slot access
// synchronous to clk_74a

    wire    [9:0]   datatable_addr;
    wire            datatable_wren;
    wire    [31:0]  datatable_data;
    wire    [31:0]  datatable_q;

core_bridge_cmd icb (

    .clk                ( clk_74a ),
    .reset_n            ( reset_n ),

    .bridge_endian_little   ( bridge_endian_little ),
    .bridge_addr            ( bridge_addr ),
    .bridge_rd              ( bridge_rd ),
    .bridge_rd_data         ( cmd_bridge_rd_data ),
    .bridge_wr              ( bridge_wr ),
    .bridge_wr_data         ( bridge_wr_data ),
    
    .status_boot_done       ( status_boot_done ),
    .status_setup_done      ( status_setup_done ),
    .status_running         ( status_running ),

    .dataslot_requestread       ( dataslot_requestread ),
    .dataslot_requestread_id    ( dataslot_requestread_id ),
    .dataslot_requestread_ack   ( dataslot_requestread_ack ),
    .dataslot_requestread_ok    ( dataslot_requestread_ok ),

    .dataslot_requestwrite      ( dataslot_requestwrite ),
    .dataslot_requestwrite_id   ( dataslot_requestwrite_id ),
    .dataslot_requestwrite_size ( dataslot_requestwrite_size ),
    .dataslot_requestwrite_ack  ( dataslot_requestwrite_ack ),
    .dataslot_requestwrite_ok   ( dataslot_requestwrite_ok ),

    .dataslot_update            ( dataslot_update ),
    .dataslot_update_id         ( dataslot_update_id ),
    .dataslot_update_size       ( dataslot_update_size ),
    
    .dataslot_allcomplete   ( dataslot_allcomplete ),

    .rtc_epoch_seconds      ( rtc_epoch_seconds ),
    .rtc_date_bcd           ( rtc_date_bcd ),
    .rtc_time_bcd           ( rtc_time_bcd ),
    .rtc_valid              ( rtc_valid ),
    
    .savestate_supported    ( savestate_supported ),
    .savestate_addr         ( savestate_addr ),
    .savestate_size         ( savestate_size ),
    .savestate_maxloadsize  ( savestate_maxloadsize ),

    .savestate_start        ( savestate_start ),
    .savestate_start_ack    ( savestate_start_ack ),
    .savestate_start_busy   ( savestate_start_busy ),
    .savestate_start_ok     ( savestate_start_ok ),
    .savestate_start_err    ( savestate_start_err ),

    .savestate_load         ( savestate_load ),
    .savestate_load_ack     ( savestate_load_ack ),
    .savestate_load_busy    ( savestate_load_busy ),
    .savestate_load_ok      ( savestate_load_ok ),
    .savestate_load_err     ( savestate_load_err ),

    .osnotify_inmenu        ( osnotify_inmenu ),
    
    .target_dataslot_read       ( target_dataslot_read ),
    .target_dataslot_write      ( target_dataslot_write ),
    .target_dataslot_getfile    ( target_dataslot_getfile ),
    .target_dataslot_openfile   ( target_dataslot_openfile ),
    
    .target_dataslot_ack        ( target_dataslot_ack ),
    .target_dataslot_done       ( target_dataslot_done ),
    .target_dataslot_err        ( target_dataslot_err ),

    .target_dataslot_id         ( target_dataslot_id ),
    .target_dataslot_slotoffset ( target_dataslot_slotoffset ),
    .target_dataslot_bridgeaddr ( target_dataslot_bridgeaddr ),
    .target_dataslot_length     ( target_dataslot_length ),

    .target_buffer_param_struct ( target_buffer_param_struct ),
    .target_buffer_resp_struct  ( target_buffer_resp_struct ),
    
    .datatable_addr         ( datatable_addr ),
    .datatable_wren         ( datatable_wren ),
    .datatable_data         ( datatable_data ),
    .datatable_q            ( datatable_q )

);

localparam [31:0] O2_BIOS_BASE = 32'h00000000;
localparam [31:0] G7400_BIOS_BASE = 32'h00000800;
localparam [31:0] CHARSET_BASE = 32'h00000C00;
localparam [31:0] EF_CHARSET_BASE = 32'h00000E00;
localparam [31:0] CART_BASE = 32'h00008000;

reg [31:0] bios_mem [0:767];
reg [31:0] char_mem [0:127];
reg [31:0] ef_char_mem [0:639];
reg [31:0] cart_mem [0:4095];
reg [14:0] cart_size_bytes = 15'd0;

wire [10:0] bios_addr;
reg [31:0] bios_word_q;
reg [1:0] bios_lane_q;
reg [31:0] char_word_q;
reg [1:0] char_lane_q;
reg [31:0] ef_char_word_q;
reg [1:0] ef_char_lane_q;
reg [31:0] cart_word_q;
reg [1:0] cart_lane_q;
reg [13:0] cart_rom_addr;
wire [8:0] char_addr;
wire [11:0] ef_char_addr;
wire [7:0] cart_data;
wire [7:0] bios_data;
wire [7:0] char_data;
wire [7:0] ef_char_data;
wire cart_cs;
wire cart_cs_n;
wire cart_wr_n;
wire cart_bank_0;
wire cart_bank_1;
wire cart_psen_n;
wire [11:0] cart_addr;
wire [7:0] cart_di;
wire char_en;
wire ef_char_en;
wire [1:0] joy_up_n;
wire [1:0] joy_down_n;
wire [1:0] joy_left_n;
wire [1:0] joy_right_n;
wire [1:0] joy_action_n;
wire [31:0] player1_key = controller_swap ? cont2_key : cont1_key;
wire [31:0] player2_key = controller_swap ? cont1_key : cont2_key;
wire [5:0] keyb_dec;

// Pocket buttons emulate the numeric keys of the Videopac+ keyboard.
// Matrix: encode line = row (bit 0 = row 7), decode line = column (bit 0 = column 1).
wire key_1 = player1_key[15] | player2_key[15];
wire key_2 = player1_key[14] | player2_key[14];
wire key_3 = player1_key[7] | player2_key[7];
wire key_4 = player1_key[6] | player2_key[6];
wire key_enter = player1_key[8] | player2_key[8];
wire key_clear = player1_key[9] | player2_key[9];
wire [7:0] keyb_enc = ~{
    key_enter & ~keyb_dec[5],
    key_clear & ~keyb_dec[5],
    1'b0,
    key_4 & ~keyb_dec[0],
    key_3 & ~keyb_dec[0],
    key_2 & ~keyb_dec[0],
    key_1 & ~keyb_dec[0],
    1'b0
};
reg clk_cpu_en;
reg clk_vdc_en;
reg [1:0] previous_system_mode = 2'd0;
reg [7:0] mode_reset_count = 8'hFF;
wire machine_reset_n = reset_n && (mode_reset_count == 0);
// Master tick = 6x VDC clock (NTSC) or 10x VDC clock (PAL). On this tick the same counters as the
// MiSTer core generate the CPU (every 8th / 12th tick) and VDC (every 6th / 10th tick) enables, so
// the CPU/VDC phase relation is identical to the MiSTer core.
localparam [31:0] MASTER_NTSC_STEP = (64'd42954540 << 32) / 74250000;
localparam [31:0] MASTER_PAL_STEP = (64'd70940000 << 32) / 74250000;
reg [31:0] master_phase = 32'd0;
reg [3:0] cpu_ctr = 4'd0;
reg [3:0] vdc_ctr = 4'd0;
wire [32:0] master_phase_sum = {1'b0, master_phase} + {1'b0, (system_mode == 2'd2 ? MASTER_NTSC_STEP : MASTER_PAL_STEP)};
wire [3:0] cpu_ctr_max = (system_mode == 2'd2) ? 4'd7 : 4'd11;
wire [3:0] vdc_ctr_max = (system_mode == 2'd2) ? 4'd5 : 4'd9;
wire [31:0] palette_color;
wire video_active = !video_hblank && !video_vblank;
wire [3:0] snd_vec;
wire snd;
wire video_r;
wire video_g;
wire video_b;
wire video_l;
wire video_hsync_n;
wire video_vsync_n;
wire video_hblank;
wire video_vblank;

function [7:0] select_byte;
    input [31:0] word;
    input [1:0] lane;
    begin
        case (lane)
            2'd0: select_byte = word[31:24];
            2'd1: select_byte = word[23:16];
            2'd2: select_byte = word[15:8];
            default: select_byte = word[7:0];
        endcase
    end
endfunction

always @(posedge clk_74a) begin
    if (bios_addr[10])
        bios_word_q <= bios_mem[10'd512 + bios_addr[9:2]];
    else
        bios_word_q <= bios_mem[bios_addr[9:2]];
    bios_lane_q <= bios_addr[1:0];
    // The MiSTer ROMs only update their output while the read enable is active and hold it otherwise.
    if (char_en) begin
        char_word_q <= char_mem[char_addr[8:2]];
        char_lane_q <= char_addr[1:0];
    end
    ef_char_word_q <= ef_char_mem[ef_char_addr[11:2]];
    ef_char_lane_q <= ef_char_addr[1:0];
    if (!cart_psen_n) begin
        cart_word_q <= cart_mem[cart_rom_addr[13:2]];
        cart_lane_q <= cart_rom_addr[1:0];
    end

    if (bridge_wr) begin
        if (bridge_addr >= O2_BIOS_BASE && bridge_addr < G7400_BIOS_BASE)
            bios_mem[bridge_addr[10:2]] <= bridge_wr_data;
        else if (bridge_addr >= G7400_BIOS_BASE && bridge_addr < CHARSET_BASE)
            bios_mem[10'd512 + ((bridge_addr - G7400_BIOS_BASE) >> 2)] <= bridge_wr_data;
        else if (bridge_addr >= CHARSET_BASE && bridge_addr < EF_CHARSET_BASE)
            char_mem[(bridge_addr - CHARSET_BASE) >> 2] <= bridge_wr_data;
        else if (bridge_addr >= EF_CHARSET_BASE && bridge_addr < 32'h00001800)
            ef_char_mem[(bridge_addr - EF_CHARSET_BASE) >> 2] <= bridge_wr_data;
        else if (bridge_addr >= CART_BASE && bridge_addr < 32'h0000C000) begin
            cart_mem[bridge_addr[13:2]] <= bridge_wr_data;
            if (bridge_addr == CART_BASE)
                cart_size_bytes <= 15'd4;
            else if ((bridge_addr - CART_BASE + 4) > cart_size_bytes)
                cart_size_bytes <= bridge_addr - CART_BASE + 4;
        end
    end
end

assign bios_data = select_byte(bios_word_q, bios_lane_q);
assign char_data = select_byte(char_word_q, char_lane_q);
assign ef_char_data = select_byte(ef_char_word_q, ef_char_lane_q);
assign cart_data = select_byte(cart_word_q, cart_lane_q);

always @* begin
    case (cart_size_bytes)
        15'd4096: cart_rom_addr = {1'b0, cart_bank_0, cart_addr[11], cart_addr[9:0]};
        15'd8192: cart_rom_addr = {cart_bank_1, cart_bank_0, cart_addr[11], cart_addr[9:0]};
        15'd16384: cart_rom_addr = {cart_bank_1, cart_bank_0, cart_addr[11:0]};
        default: cart_rom_addr = {3'b000, cart_addr[11], cart_addr[9:0]};
    endcase
end

// Index 1 = left joystick (player 1), index 0 = right joystick (player 2), as in the MiSTer top level.
assign joy_up_n = {~player1_key[0], ~player2_key[0]};
assign joy_down_n = {~player1_key[1], ~player2_key[1]};
assign joy_left_n = {~player1_key[2], ~player2_key[2]};
assign joy_right_n = {~player1_key[3], ~player2_key[3]};
assign joy_action_n = {~(player1_key[4] | player1_key[5]), ~(player2_key[4] | player2_key[5])};

always @(posedge clk_74a) begin
    if (!reset_n) begin
        master_phase <= 32'd0;
        cpu_ctr <= 4'd0;
        vdc_ctr <= 4'd0;
        clk_cpu_en <= 1'b0;
        clk_vdc_en <= 1'b0;
        mode_reset_count <= 8'hFF;
        previous_system_mode <= system_mode;
    end else begin
        master_phase <= master_phase_sum[31:0];
        clk_cpu_en <= 1'b0;
        clk_vdc_en <= 1'b0;
        if (system_mode != previous_system_mode || mode_reset_count != 0) begin
            cpu_ctr <= 4'd0;
            vdc_ctr <= 4'd0;
        end else if (master_phase_sum[32]) begin
            if (cpu_ctr >= cpu_ctr_max) begin cpu_ctr <= 4'd0; clk_cpu_en <= 1'b1; end else cpu_ctr <= cpu_ctr + 1'b1;
            if (vdc_ctr >= vdc_ctr_max) begin vdc_ctr <= 4'd0; clk_vdc_en <= 1'b1; end else vdc_ctr <= vdc_ctr + 1'b1;
        end
        if (system_mode != previous_system_mode) begin
            previous_system_mode <= system_mode;
            mode_reset_count <= 8'hFF;
        end else if (mode_reset_count != 0) begin
            mode_reset_count <= mode_reset_count - 1'b1;
        end
    end
end

vp_console vp (
    .is_pal_g       (system_mode == 2'd2 ? 0 : 1),
    .clk_i          (clk_74a),
    .clk_cpu_en_i   (clk_cpu_en),
    .clk_vdc_en_i   (clk_vdc_en),
    .clk_750k       (1'b0),
    .clk_2m5        (1'b0),
    .res_n_i        (machine_reset_n),
    .cart_cs_o      (cart_cs),
    .cart_cs_n_o    (cart_cs_n),
    .cart_wr_n_o    (cart_wr_n),
    .cart_a_o       (cart_addr),
    .cart_d_i       (cart_data),
    .cart_d_o       (cart_di),
    .cart_bs0_o     (cart_bank_0),
    .cart_bs1_o     (cart_bank_1),
    .cart_psen_n_o  (cart_psen_n),
    .cart_t0_i      (1'b1),
    .cart_t0_o      (),
    .cart_t0_dir_o  (),
    .char_a_o       (char_addr),
    .char_d_i       (char_data),
    .char_en        (char_en),
    .is_g7400_i     (system_mode == 2'd0),
    .bios_addr_o    (bios_addr),
    .bios_data_i    (bios_data),
    .ef_char_a_o    (ef_char_addr),
    .ef_char_d_i    (ef_char_data),
    .ef_char_en_o   (ef_char_en),
    .joy_up_n_i     (joy_up_n),
    .joy_down_n_i   (joy_down_n),
    .joy_left_n_i   (joy_left_n),
    .joy_right_n_i  (joy_right_n),
    .joy_action_n_i (joy_action_n),
    .keyb_dec_o     (keyb_dec),
    .keyb_enc_i     (keyb_enc),
    .r_o            (video_r),
    .g_o            (video_g),
    .b_o            (video_b),
    .l_o            (video_l),
    .hsync_n_o      (video_hsync_n),
    .vsync_n_o      (video_vsync_n),
    .hbl_o          (),
    .vbl_o          (),
    .hblank_o       (video_hblank),
    .vblank_o       (video_vblank),
    .snd_o          (snd),
    .snd_vec_o      (snd_vec[3:0]),
    .snd_voice_o    (),
    .voice_enable   (1'b0)
);

////////////////////////////////////////////////////////////////////////////////////////

// video generation
// ~12,288,000 hz pixel clock
//
// we want our video mode of 320x240 @ 60hz, this results in 204800 clocks per frame
// we need to add hblank and vblank times to this, so there will be a nondisplay area. 
// it can be thought of as a border around the visible area.
// to make numbers simple, we can have 400 total clocks per line, and 320 visible.
// dividing 204800 by 400 results in 512 total lines per frame, and 240 visible.
// this pixel clock is fairly high for the relatively low resolution, but that's fine.
// PLL output has a minimum output frequency anyway.


// The console video runs on its own (PAL or NTSC) timing. It is written into a frame buffer
// and read out again with a fixed 352x240 @ 60 Hz timing, which the Pocket scaler requires.
localparam FB_W = 352;
localparam FB_H = 242;
localparam FB_SIZE = FB_W * FB_H;
localparam H_SHIFT = 3;
localparam OUT_H_BPORCH = 10;
localparam OUT_V_BPORCH = 10;
localparam OUT_H_ACTIVE = 320;
localparam OUT_V_ACTIVE = 240;
localparam OUT_H_TOTAL = 400;
localparam OUT_V_TOTAL = 512;

(* ramstyle = "M10K" *) reg [3:0] frame_buf [0:FB_SIZE-1];
reg [16:0] fb_line_base = 17'd0;
reg [9:0] fb_wr_x = 10'd0;
reg fb_prev_hblank = 1'b0;
reg fb_prev_vblank = 1'b0;
reg fb_line_active = 1'b0;
reg [9:0] fb_line_w = 10'd352;
reg [9:0] fb_line_count = 10'd0;
reg [9:0] meas_w = 10'd352;
reg [9:0] meas_h = 10'd240;
wire [16:0] fb_wr_addr = fb_line_base + fb_wr_x;
wire fb_wr_valid = video_active && fb_wr_x < FB_W && fb_wr_addr < FB_SIZE;

// The visible size changes with the console mode (cropped for Plus games), so the
// size of the last frame is measured and used to scale the picture to the full output.
always @(posedge clk_74a) begin
    if (clk_vdc_en) begin
        fb_prev_hblank <= video_hblank;
        fb_prev_vblank <= video_vblank;

        if (video_vblank) begin
            fb_line_base <= 17'd0;
            fb_wr_x <= 10'd0;
            fb_line_active <= 1'b0;
            fb_line_count <= 10'd0;
            if (!fb_prev_vblank && fb_line_count > 10'd64 && fb_line_w > 10'd64) begin
                meas_w <= fb_line_w;
                meas_h <= (fb_line_count > OUT_V_ACTIVE) ? OUT_V_ACTIVE : fb_line_count;
            end
        end else if (video_hblank) begin
            fb_wr_x <= 10'd0;
            if (!fb_prev_hblank && fb_line_active) begin
                fb_line_base <= fb_line_base + FB_W;
                fb_line_active <= 1'b0;
                fb_line_w <= fb_wr_x;
                fb_line_count <= fb_line_count + 1'b1;
            end
        end else begin
            fb_wr_x <= fb_wr_x + 1'b1;
            fb_line_active <= 1'b1;
        end

        if (fb_wr_valid)
            frame_buf[fb_wr_addr] <= {video_r, video_g, video_b, video_l};
    end
end

reg [9:0] out_x = 10'd0;
reg [9:0] out_y = 10'd0;
wire out_active = out_x >= OUT_H_BPORCH && out_x < OUT_H_ACTIVE + OUT_H_BPORCH &&
                  out_y >= OUT_V_BPORCH && out_y < OUT_V_ACTIVE + OUT_V_BPORCH;

// The picture is output 1:1 (no resampling) and centered in the output window, so every
// source pixel keeps the same width after the Pocket's integer scaling.
wire signed [11:0] vis_x = $signed({2'b00, out_x}) - OUT_H_BPORCH;
wire signed [11:0] vis_y = $signed({2'b00, out_y}) - OUT_V_BPORCH;
wire signed [11:0] pad_x = (meas_w > OUT_H_ACTIVE) ? -12'sd3 : (OUT_H_ACTIVE - $signed({2'b00, meas_w})) >>> 1;
wire signed [11:0] pad_y = (OUT_V_ACTIVE - $signed({2'b00, meas_h})) >>> 1;
wire signed [11:0] src_col = vis_x - pad_x + H_SHIFT;
wire signed [11:0] src_row = vis_y - pad_y;
wire src_ok = src_col >= 0 && src_col < $signed({2'b00, meas_w}) && src_col < FB_W &&
              src_row >= 0 && src_row < $signed({2'b00, meas_h}) && src_row < FB_H;
wire [16:0] out_rd_addr = (src_row[9:0] * FB_W) + src_col[9:0];

reg [3:0] fb_pixel_q = 4'd0;
reg src_ok_0 = 1'b0;
reg src_ok_1 = 1'b0;
reg out_active_0 = 1'b0;
reg out_active_1 = 1'b0;
reg out_vs_1 = 1'b0;
reg out_hs_1 = 1'b0;
reg [23:0] video_rgb_q = 24'h000000;
reg video_de_q = 1'b0;
reg video_vs_q = 1'b0;
reg video_hs_q = 1'b0;

always @(posedge clk_core_12288) begin
    out_x <= out_x + 1'b1;
    if (out_x == OUT_H_TOTAL - 1) begin
        out_x <= 10'd0;
        out_y <= out_y + 1'b1;
        if (out_y == OUT_V_TOTAL - 1)
            out_y <= 10'd0;
    end

    fb_pixel_q <= frame_buf[out_rd_addr];
    src_ok_0 <= src_ok;
    src_ok_1 <= src_ok_0;
    out_active_0 <= out_active;
    out_active_1 <= out_active_0;
    out_vs_1 <= (out_x == 0 && out_y == 0);
    out_hs_1 <= (out_x == 3);

    video_rgb_q <= (out_active_1 && src_ok_1) ? vp_palette(fb_pixel_q) : 24'h000000;
    video_de_q <= out_active_1;
    video_vs_q <= out_vs_1;
    video_hs_q <= out_hs_1;
end

assign video_rgb_clock = clk_core_12288;
assign video_rgb_clock_90 = clk_core_12288_90deg;
assign video_rgb = video_rgb_q;
assign video_de = video_de_q;
assign video_skip = 1'b0;
assign video_vs = video_vs_q;
assign video_hs = video_hs_q;

function [23:0] vp_palette;
    input [3:0] color_index;
    begin
        case (color_index)
            4'h0: vp_palette = 24'h000000;
            4'h1: vp_palette = 24'h676767;
            4'h2: vp_palette = 24'h1A37BE;
            4'h3: vp_palette = 24'h5C80F6;
            4'h4: vp_palette = 24'h006D07;
            4'h5: vp_palette = 24'h56C469;
            4'h6: vp_palette = 24'h2AAABE;
            4'h7: vp_palette = 24'h77E6EB;
            4'h8: vp_palette = 24'h790000;
            4'h9: vp_palette = 24'hC75151;
            4'hA: vp_palette = 24'h94309F;
            4'hB: vp_palette = 24'hDC84E8;
            4'hC: vp_palette = 24'h77670B;
            4'hD: vp_palette = 24'hC6B86A;
            4'hE: vp_palette = 24'hCECECE;
            default: vp_palette = 24'hFFFFFF;
        endcase
    end
endfunction

/* unused template test pattern
    localparam  VID_V_BPORCH = 'd10;
    localparam  VID_V_ACTIVE = 'd240;
    localparam  VID_V_TOTAL = 'd512;
    localparam  VID_H_BPORCH = 'd10;
    localparam  VID_H_ACTIVE = 'd320;
    localparam  VID_H_TOTAL = 'd400;

    reg [15:0]  frame_count;
    
    reg [9:0]   x_count;
    reg [9:0]   y_count;
    
    wire [9:0]  visible_x = x_count - VID_H_BPORCH;
    wire [9:0]  visible_y = y_count - VID_V_BPORCH;

    reg [23:0]  vidout_rgb;
    reg         vidout_de, vidout_de_1;
    reg         vidout_skip;
    reg         vidout_vs;
    reg         vidout_hs, vidout_hs_1;
    
    reg [9:0]   square_x = 'd135;
    reg [9:0]   square_y = 'd95;

always @(posedge clk_core_12288 or negedge reset_n) begin

    if(~reset_n) begin
    
        x_count <= 0;
        y_count <= 0;
        
    end else begin
        vidout_de <= 0;
        vidout_skip <= 0;
        vidout_vs <= 0;
        vidout_hs <= 0;
        
        vidout_hs_1 <= vidout_hs;
        vidout_de_1 <= vidout_de;
        
        // x and y counters
        x_count <= x_count + 1'b1;
        if(x_count == VID_H_TOTAL-1) begin
            x_count <= 0;
            
            y_count <= y_count + 1'b1;
            if(y_count == VID_V_TOTAL-1) begin
                y_count <= 0;
            end
        end
        
        // generate sync 
        if(x_count == 0 && y_count == 0) begin
            // sync signal in back porch
            // new frame
            vidout_vs <= 1;
            frame_count <= frame_count + 1'b1;
        end
        
        // we want HS to occur a bit after VS, not on the same cycle
        if(x_count == 3) begin
            // sync signal in back porch
            // new line
            vidout_hs <= 1;
        end

        // inactive screen areas are black
        vidout_rgb <= 24'h0;
        // generate active video
        if(x_count >= VID_H_BPORCH && x_count < VID_H_ACTIVE+VID_H_BPORCH) begin

            if(y_count >= VID_V_BPORCH && y_count < VID_V_ACTIVE+VID_V_BPORCH) begin
                // data enable. this is the active region of the line
                vidout_de <= 1;
                
                vidout_rgb[23:16] <= 8'd60;
                vidout_rgb[15:8]  <= 8'd60;
                vidout_rgb[7:0]   <= 8'd60;
                
            end 
        end
    end
end
*/




//
// audio i2s silence generator
// see other examples for actual audio generation
//

assign audio_mclk = audgen_mclk;
assign audio_dac = audgen_dac;
assign audio_lrck = audgen_lrck;

// generate MCLK = 12.288mhz with fractional accumulator
    reg         [21:0]  audgen_accum = 0;
    reg                 audgen_mclk = 0;
    parameter   [20:0]  CYCLE_48KHZ = 21'd122880 * 2;
always @(posedge clk_74a) begin
    audgen_accum <= audgen_accum + CYCLE_48KHZ;
    if(audgen_accum >= 21'd742500) begin
        audgen_mclk <= ~audgen_mclk;
        audgen_accum <= audgen_accum - 21'd742500 + CYCLE_48KHZ;
    end
end

// generate SCLK = 3.072mhz by dividing MCLK by 4
    reg [1:0]   aud_mclk_divider = 0;
    wire        audgen_sclk = aud_mclk_divider[1] /* synthesis keep*/;
    reg         audgen_lrck_1;
always @(posedge audgen_mclk) begin
    aud_mclk_divider <= aud_mclk_divider + 1'b1;
end

// shift out audio data as I2S 
// 32 total bits per channel, but only 16 active bits at the start and then 16 dummy bits
//
    reg     [4:0]   audgen_lrck_cnt = 0;
    reg             audgen_lrck = 0;
    reg             audgen_dac = 0;
    reg     [15:0]  audgen_sample = 0;

always @(negedge audgen_sclk) begin
    if (audgen_lrck_cnt < 16)
        audgen_dac <= audgen_sample[15-audgen_lrck_cnt];
    else
        audgen_dac <= 1'b0;

    if (audgen_lrck_cnt == 31) begin
        audgen_lrck <= ~audgen_lrck;
        audgen_sample <= {2'b00, snd_vec, snd_vec, snd_vec, 2'b00};
    end
    audgen_lrck_cnt <= audgen_lrck_cnt + 1'b1;
end


///////////////////////////////////////////////


    wire    clk_core_12288;
    wire    clk_core_12288_90deg;
    
    wire    pll_core_locked;
    wire    pll_core_locked_s;
synch_3 s01(pll_core_locked, pll_core_locked_s, clk_74a);

mf_pllbase mp1 (
    .refclk         ( clk_74a ),
    .rst            ( 0 ),
    
    .outclk_0       ( clk_core_12288 ),
    .outclk_1       ( clk_core_12288_90deg ),
    
    .locked         ( pll_core_locked )
);


    
endmodule
