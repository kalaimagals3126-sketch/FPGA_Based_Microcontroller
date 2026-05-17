module testbench();
reg clk,rst;
reg[15:0]wr_data,adddr,gpio_in;
wire [7:0]pc_out;
wire [15:0]instr;
wire [15:0]instr_out;
wire [3:0] opcode,rd,rs,rt,alu_op;
wire pc_en,ir_en,imem_en,reg_wr,mem_rd,mem_wr,wr_en,rd_en;
wire [15:0]rd_data1,rd_data2;
wire [15:0]result,rd_data,gpio_out,rd_dataa;
wire zero;
microcontroller r1(clk,rst,gpio_in,adddr,pc_out,instr,instr_out,rd,rs,rt,opcode,pc_en,ir_en,imem_en,reg_wr,mem_rd,mem_wr,wr_en,rd_en,alu_op,wr_data,rd_data1,rd_data2,result,zero,rd_data,gpio_out,rd_dataa);
initial
begin
clk=0;rst=1;wr_data=16'h00A5;gpio_in=16'h00AA;adddr=16'h00F1;
#40 rst=0;wr_data=16'h00A5;gpio_in=16'h00AA;adddr=16'h00F0;
#300 $finish;
end
always #5clk=~clk;
endmodule
