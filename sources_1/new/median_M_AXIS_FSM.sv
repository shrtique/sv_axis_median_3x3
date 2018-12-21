`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.11.2018 16:10:49
// Design Name: 
// Module Name: median_M_AXIS_FSM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module median_M_AXIS_FSM #(
  parameter DATA_WIDTH  = 8,
  parameter IMG_WIDTH   = 10,
  parameter IMG_HEIGHT  = 10,
  parameter KERNEL_SIZE = 5
)(	
  input  logic                  i_clk,
  input  logic                  i_aresetn,

  input  logic [DATA_WIDTH-1:0] i_median_pixel,
  input  logic                  i_image_data_valid,
  input  logic                  i_start_of_frame,

  output logic [DATA_WIDTH-1:0] m_axis_tdata,
  output logic                  m_axis_tvalid,
  output logic                  m_axis_tuser,
  output logic                  m_axis_tlast

);

//DESCRIPTION:
//transmit pixels via AXI Stream interface
//first (KERNEL_SIZE-1) lines of image are blacked
//first (KERNEL_SIZE-1) pixels of each line are also blacked                                       
//this is done to simplify processing of boundary pixels

//   KERNEL_BUFFER 5x5                    RESULT
//     0   1   2    3   4            0   1   2   3   4
// 0 [ XX, XX, XX , XX, XX ] --> 0 [ BL, BL, BL, BL, BL  ] 
// 1 [ XX, XX, XX , XX, XX ] --> 1 [ BL, BL, BL, BL, BL  ] 
// 2 [ XX, XX, ?P?, XX, XX ] --> 2 [ BL, BL, BL, BL, BL  ] 
// 3 [ XX, XX, XX , XX, XX ] --> 3 [ BL, BL, BL, BL, BL  ] 
// 4 [ XX, XX, XX , XX, XX ] --> 4 [ BL, BL, BL, BL, !P! ]

// BL - blacked, ?P? - pixel for processing, !P! - processed pixel
//We process pixel with coordinates (2,2), but put it in the relative coordinates of image (4,4)..
//..this is why we put black boundaries not around the image but at the beginning

//SIGNALS
typedef enum logic [2:0] {IDLE, TUSER, DARK_PIX, VALID_PIX, TLAST} statetype;
statetype state, nextstate;

logic [DATA_WIDTH-1:0] axis_tdata;
logic                  axis_tvalid;
logic                  axis_tuser;
logic                  axis_tlast;

logic                  en_counter, en_counter_reg;

logic [11:0]           pixel_counter;
logic [11:0]           line_counter;


//state_reg
always_ff @( posedge i_clk, negedge i_aresetn )
  begin
    if   ( ~i_aresetn ) state <= IDLE;
    else                state <= nextstate;	
  end
//
//

//data_reg
always_ff @( posedge i_clk, negedge i_aresetn )
  begin
    if ( ~i_aresetn ) begin
      m_axis_tdata   <= '{ default: 'b0};
      m_axis_tvalid  <= 1'b0;
      m_axis_tuser   <= 1'b0;
      m_axis_tlast   <= 1'b0;

      en_counter_reg <= 1'b0;

    end else begin
      m_axis_tdata   <= axis_tdata;
      m_axis_tvalid  <= axis_tvalid;	
      m_axis_tuser   <= axis_tuser;
      m_axis_tlast   <= axis_tlast;

      en_counter_reg <= en_counter;

    end   
  end
//
//

//nextstage logic and output logic
always_comb
  begin
    
    nextstate   = state;
    
    axis_tdata  = m_axis_tdata;
    axis_tvalid = 1'b0;
    axis_tuser  = 1'b0;
    axis_tlast  = 1'b0;

    en_counter  = en_counter_reg;
    
    case ( state )
    
      IDLE : begin
      	en_counter    = 1'b0;

        if ( ( i_image_data_valid ) && ( i_start_of_frame ) ) begin
          
          axis_tdata  = 8'h00;
          axis_tvalid = 1'b1;
          axis_tuser  = 1'b1;

          en_counter  = 1'b1;

          nextstate   = TUSER;
        end	
      end //IDLE

      
      TUSER : begin
        if ( i_image_data_valid ) begin
          axis_tdata  = 8'h00;
          axis_tvalid = 1'b1;

          nextstate   = DARK_PIX;
        end
      end //TUSER


      DARK_PIX : begin
      	//en_counter    = 1'b0;

      	if ( i_image_data_valid ) begin

          en_counter    = 1'b1;

          if ( ( line_counter > (KERNEL_SIZE-2)  ) && ( pixel_counter > (KERNEL_SIZE-3) ) ) begin
            axis_tdata  = i_median_pixel;
            axis_tvalid = 1'b1;

            nextstate   = VALID_PIX;

          end else begin
            axis_tdata  = 8'b00;
            axis_tvalid = 1'b1;

            nextstate   = DARK_PIX;
          end
          
          if ( pixel_counter == (IMG_WIDTH-2) ) begin
            axis_tlast = 1'b1;
            nextstate  = TLAST;
          end	

        end	
      end //DARK_PIX


      VALID_PIX : begin
        if ( i_image_data_valid ) begin
          axis_tdata  = i_median_pixel;
          axis_tvalid = 1'b1;

          nextstate   = VALID_PIX;

          if ( pixel_counter == (IMG_WIDTH-2) ) begin
            axis_tlast = 1'b1;
            nextstate  = TLAST;
          end	
        end	
      end //VALID_PIX


      TLAST : begin

      	en_counter = 1'b0;
        nextstate  = DARK_PIX;

        if ( ( line_counter == (IMG_HEIGHT-1) ) && ( pixel_counter == (IMG_WIDTH-1) ) ) begin

          nextstate = IDLE;
        end	
      end //TLAST	
    

      default : nextstate = IDLE;

    endcase	

  end	
//
//

//COUNTER of transmitted pixels
always @( posedge i_clk, negedge i_aresetn )
  begin
    if ( ~i_aresetn ) begin
      pixel_counter <= 0;
      line_counter  <= 0;
    end else begin
      
      if ( ( i_image_data_valid ) && ( en_counter_reg ) ) begin
      //if  ( en_counter_reg )  begin
      //if ( i_image_data_valid ) begin  
        pixel_counter <= pixel_counter + 1;
      end
      
      //the stuff below is better to do without minding of s_axis_tvalid
      if ( pixel_counter == IMG_WIDTH - 1 ) begin
      	pixel_counter  <= 0;
        line_counter   <= line_counter + 1;

        if ( line_counter == IMG_HEIGHT - 1 ) begin
          line_counter <= 0;	
        end 	
      end    

    end
  end  
endmodule
