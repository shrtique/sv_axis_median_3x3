`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2018 13:34:13
// Design Name: 
// Module Name: AXIS_pixel_receiver
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


//DESCRIPTION:
//simple receiver of AXI Stream data for following image processing
//
//    DATA           KERNEL_BUFFER 5x5             LINE_BUFFER
// 47, 46, 45 -->  [ 44, 43, 42, 41, 40 ] --> [ 39, 38, 37, 36, 35 ] --> *
//          * -->  [ 34, 33, 32, 31, 30 ] --> [ 29, 28, 27, 26, 25 ] --> *
//          * -->  [ 24, 23, 22, 21, 20 ] --> [ 19, 18, 17, 16, 15 ] --> *
//          * -->  [ 14, 13, 12, 11, 10 ] --> [ 09, 08, 07, 06, 05 ] --> *
//          * -->  [ 04, 03, 02, 01, 00 ] --> ...  
//

module AXIS_pixel_receiver#(

  parameter DATA_WIDTH  = 8,
  parameter KERNEL_SIZE = 5,
  parameter IMAGE_WIDTH = 10

)(

  input  logic                  i_clk,
  input  logic                  i_aresetn,

  input  logic [DATA_WIDTH-1:0] i_data,
  input  logic                  i_data_valid,
  input  logic                  i_start_of_frame,

  output logic [DATA_WIDTH-1:0] o_image_kernel_buffer [0:KERNEL_SIZE-1] [0:KERNEL_SIZE-1],
  output logic                  o_data_valid,
  output logic                  o_start_of_frame
  

);



//signals
typedef logic [DATA_WIDTH-1:0] type_line_buffer [0:KERNEL_SIZE-2] [0:( IMAGE_WIDTH - KERNEL_SIZE )-1];
type_line_buffer line_buffer_array;
//
//

//shifting through kernel_buffer when data is valid
always_ff @( posedge i_clk, negedge i_aresetn )
  begin
    if   ( ~i_aresetn ) begin
      o_image_kernel_buffer <= '{default: 'b0};
      line_buffer_array     <= '{default: 'b0};
    end else begin	
     
      if ( i_data_valid ) begin

        o_image_kernel_buffer[0] <= {i_data, o_image_kernel_buffer[0][0:KERNEL_SIZE-2]};
        line_buffer_array[0]     <= {o_image_kernel_buffer[0][KERNEL_SIZE-1], line_buffer_array[0][0:( IMAGE_WIDTH - KERNEL_SIZE )-2]};
 
        for ( int i = 1; i < KERNEL_SIZE-1; i++ ) begin
          o_image_kernel_buffer[i] <= {line_buffer_array[i-1][(IMAGE_WIDTH - KERNEL_SIZE)-1],o_image_kernel_buffer[i][0:KERNEL_SIZE-2]};
          line_buffer_array[i]     <= {o_image_kernel_buffer[i][KERNEL_SIZE-1], line_buffer_array[i][0:( IMAGE_WIDTH - KERNEL_SIZE )-2]};
        end  

        o_image_kernel_buffer[KERNEL_SIZE-1] <= {line_buffer_array[KERNEL_SIZE-2][(IMAGE_WIDTH - KERNEL_SIZE)-1],o_image_kernel_buffer[KERNEL_SIZE-1][0:KERNEL_SIZE-2]};
        
      end  
    end             
  end
//
//

//reg these signals to sync with next module
always_ff @( posedge i_clk, negedge i_aresetn )
  begin
    if ( ~i_aresetn ) begin
      o_data_valid     <= 1'b0;
      o_start_of_frame <= 1'b0;
    end else begin
      o_data_valid     <= i_data_valid;
      o_start_of_frame <= i_start_of_frame;
    end 
  end  
endmodule
