module microcontroller(clk,rst,gpio_in,adddr,pc_out,instr,instr_out,rd,rs,rt,opcode,pc_en,ir_en,imem_en,reg_wr,mem_rd,mem_wr,wr_en,rd_en,alu_op,wr_data,rd_data1,rd_data2,result,zero,rd_data,gpio_out,rd_dataa);
input clk,rst;
input[15:0]wr_data,gpio_in,adddr;
output [7:0]pc_out;
output [15:0]instr;
output [15:0]instr_out;
output [3:0] opcode,rd,rs,rt,alu_op;
output pc_en,ir_en,imem_en,reg_wr,mem_rd,mem_wr,wr_en,rd_en;
output [15:0]rd_data1,rd_data2;
output [15:0]result,rd_data,gpio_out,rd_dataa;
output zero;
wire pc_load = 1'b0;
programcounter aa(clk,rst,pc_en,pc_load,pc_out);
instructionmemory bb(clk,imem_en,pc_out,instr);
instructionregister cc(clk,rst,ir_en,instr,instr_out);
instructiondecoder dd(instr_out,opcode,rd,rs,rt);
controlunit ee(clk,rst,opcode,pc_en,ir_en,imem_en,reg_wr,alu_op,mem_rd,mem_wr,wr_en,rd_en);
registerfile ff(clk,reg_wr,rs,rt,rd,wr_data,rd_data1,rd_data2);
alu gg(rd_data1,rd_data2,alu_op,result,zero);
datamemory hh(clk,mem_rd,mem_wr,result,rd_data2,rd_data);
gpio ii(clk,wr_en,rd_en,adddr,result,gpio_in,gpio_out,rd_dataa);
endmodule

module programcounter(clk,rst,pc_en,pc_load,pc_out);
input clk,rst,pc_en,pc_load;
output [7:0]pc_out;
reg[7:0]pc_out;
always@(posedge clk or posedge rst)
begin
if(rst)
 pc_out<=8'h00;
else if (pc_en)
begin
if(pc_load)
  pc_out<=pc_out;
else 
  pc_out<=pc_out+8'h01;
end
end
endmodule

module instructionmemory (clk,imem_en,pc_out,instr);
input clk,imem_en;
input [7:0]pc_out;
output [15:0]instr;
reg [15:0]instr;
wire[7:0]pc_out;
initial instr = 16'h0000;
reg [15:0]rom[0:255];
integer i;
initial begin
rom[8'h00]=16'h8105;
rom[8'h01]=16'h9203;
rom[8'h02]=16'h1230;
rom[8'h03]=16'h2346;
rom[8'h04]=16'h3346;
rom[8'h05]=16'h4346;
for (i=6;i<256;i=i+1)
rom[i]=16'h00;
end 
always@(posedge clk)
begin
if (imem_en)
instr<=rom[pc_out];
end
endmodule

module instructionregister(clk,rst,ir_en,instr,instr_out);
input clk,rst,ir_en;
input [15:0] instr;
output [15:0]instr_out;
reg [15:0]instr_out;
wire [15:0]instr;
always@(posedge clk or posedge rst)
begin
if(rst)
instr_out<=16'h00;
else if(ir_en)
instr_out<=instr;
end
endmodule

module instructiondecoder(instr_out,opcode,rd,rs,rt);
input [15:0]instr_out;
output [3:0] opcode,rd,rs,rt;
wire [15:0]instr_out;
assign opcode=instr_out[15:12];
assign rd=instr_out[11:8];
assign rs=instr_out[7:4];
assign rt=instr_out[3:0];
endmodule

module controlunit(clk,rst,opcode,pc_en,ir_en,imem_en,reg_wr,alu_op,mem_rd,mem_wr,wr_en,rd_en);
input clk,rst;
input[3:0]opcode;
output pc_en,ir_en,imem_en,reg_wr,mem_rd,mem_wr,wr_en,rd_en;
output[3:0]alu_op;
reg pc_en,ir_en,imem_en,reg_wr,mem_rd,mem_wr,wr_en,rd_en;
reg [3:0]alu_op;
wire [3:0]opcode;
reg[2:0]state;
reg [2:0]next_state;
parameter fetch=3'b000;
parameter decode=3'b001;
parameter execute=3'b010;
parameter mem=3'b011;
parameter writeback=3'b100;
always@(posedge clk or posedge rst)
begin
if(rst)
state<=fetch;
else
state<=next_state;
end
always@(*)
begin
case(state)
fetch:next_state=decode;
decode:next_state=execute;
execute:next_state=mem;
mem:next_state=writeback;
writeback:next_state=fetch;
default:next_state=fetch;
endcase
end
always@(*)
begin
pc_en=0;
ir_en=0;
imem_en=0;
alu_op=4'd0;
reg_wr=0;
mem_rd=0;
mem_wr=0;
wr_en=0;
rd_en=0;
case(state)
fetch:begin pc_en=1;imem_en=1;end
decode:begin ir_en=1;end
execute:begin alu_op=opcode;end
mem:begin 
case(opcode)
4'h8:begin mem_rd=1;end
4'h9 :begin mem_wr=1;end 
4'h1:begin mem_rd=1; end
4'h2:begin mem_wr=1; end
4'h3:begin wr_en=1; end
4'h4:begin rd_en=1; end
endcase
end
writeback:begin 
case(opcode)
4'h8:begin reg_wr=1;end
4'h9 :begin reg_wr=1;end
4'h1 :begin reg_wr=1;end
4'h2 :begin reg_wr=1;end
endcase
end
endcase
end
endmodule

module registerfile(clk,reg_wr,rs,rt,rd,wr_data,rd_data1,rd_data2);
input clk,reg_wr;
wire reg_wr;
input[3:0]rs,rt,rd;
wire [3:0]rs,rt,rd;
input[15:0]wr_data;
output[15:0]rd_data1,rd_data2;
reg[15:0]regs[0:15];
integer i;
initial begin
    for (i=0; i<16; i=i+1)
         regs[i] = 16'h0000;
		   regs[1] = 16'h1111;
			regs[2] = 16'h2222;
			regs[3] = 16'h3333;
			regs[4] = 16'h4444;
			regs[5] = 16'h5555;
			regs[6] = 16'h6666;
end
always@(posedge clk)
begin
if(reg_wr)
regs[rd]<=wr_data;
end
assign rd_data1=regs[rs];
assign rd_data2=regs[rt];
endmodule

module alu(rd_data1,rd_data2,alu_op,result,zero);
input [15:0]rd_data1,rd_data2;
input[3:0]alu_op;
output [15:0]result;
output zero;
reg [15:0]result;
reg zero;
wire [15:0]rd_data1,rd_data2;
wire [3:0]alu_op;
always@(*)
begin
case(alu_op)
4'b0000:{zero,result}=rd_data1+rd_data2;
4'b0001:{zero,result}=rd_data1-rd_data2;
4'b0010: begin result=rd_data1&rd_data2;zero=0;end
4'b0011:begin result=rd_data1||rd_data2;zero=0;end
4'b1000:begin result=rd_data1^rd_data2;zero=0;end
default: begin result=16'h00;zero=0;end
endcase
end
endmodule

module datamemory(clk,mem_rd,mem_wr,result,rd_data2,rd_data);
input clk,mem_rd,mem_wr;
input [15:0]result,rd_data2;
output [15:0]rd_data;
reg [15:0]rd_data;
wire [15:0]rd_data2,result;
wire mem_rd,mem_wr;
reg[15:0]ram[0:255];
integer i;
initial begin
    for (i = 0; i < 256; i = i + 1)
        ram[i] = 16'h0000;
end
always@(posedge clk)
begin
if (mem_rd)
rd_data<=ram[result[7:0]];
else
rd_data<=16'h00;
end
always@(posedge clk)
begin
if(mem_wr)
ram[result[7:0]]<=rd_data2;
end
endmodule

module gpio(clk,wr_en,rd_en,adddr,result,gpio_in,gpio_out,rd_dataa);
input clk,wr_en,rd_en;
input [15:0]result,gpio_in,adddr;
output[15:0]gpio_out,rd_dataa;
reg[15:0]gpio_out,rd_dataa;
wire[15:0]result;
wire wr_en,rd_en;
reg [7:0]dir;
initial begin
    dir = 8'h00;
    gpio_out = 16'h0000;
    rd_dataa = 16'h0000;
end
always@(posedge clk)
begin
if(wr_en)
begin
if(adddr==16'h00F1)
dir<=result[7:0];
if(adddr==16'h00F0)
gpio_out<=result;
end
end
always@(*)
begin
if(rd_en&&adddr==16'h00F0)
rd_dataa=gpio_out;
else
rd_dataa=16'h0000;
end
endmodule
