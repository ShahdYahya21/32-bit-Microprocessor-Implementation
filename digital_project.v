module alu(opcode,a,b,result);
	input [5:0] opcode;
	input [31:0] a,b;
	output reg [31:0] result;	
	
	always @(*) begin
			case (opcode)	// choose the operation based on the opcode
				6'b000101: result <= a + b;        
		  		6'b001000: result <= a - b;        
		      	6'b001101: result <= (a < 0) ? -a : a; 
				6'b000111: result <= -a;          
				6'b000011: result <= (a > b) ? a:b;
				6'b000110: result <= (a < b) ? a:b;  
				6'b001010: result <= (a + b)/2;  
				6'b000010: result <= ~a;           
				6'b001111: result <= a | b;        
				6'b000100: result <= a & b;        
				6'b001100: result <= a ^ b; 
			
			endcase
		end
endmodule




module reg_file(clk,valid_opcode,addr1, addr2, addr3, in, out1, out2); 
	input clk;
	input [5:0] valid_opcode;
	input [4:0] addr1, addr2, addr3;
	input signed [31:0] in;
	output reg signed [31:0] out1,out2;  
	reg signed [31:0]mem [31:0];
							   
	initial begin  
		// Fill the reg file
			mem[0]  = 32'h0;
			mem[1]  = 32'h1066;
			mem[2]  = 32'h15DC;
			mem[3]  = 32'h385A;
			mem[4]  = 32'h1DBC;
			mem[5]  = 32'h19EE;
			mem[6]  = 32'h2738;
			mem[7]  = 32'hF5A;
			mem[8]  = 32'h1036;
			mem[9]  = 32'h11FE;
			mem[10] = 32'h1518;
			mem[11] = 32'h217C;
			mem[12] = 32'h3FC4;
			mem[13] = 32'h2288;
			mem[14] = 32'h2042;
			mem[15] = 32'h2BDC;
			mem[16] = 32'h210E;
			mem[17] = 32'h33E4;
			mem[18] = 32'h1244;
			mem[19] = 32'hF8C;
			mem[20] = 32'h1602;
			mem[21] = 32'h1DD0;
			mem[22] = 32'h2676;
			mem[23] = 32'h1542;
			mem[24] = 32'h30C8;
			mem[25] = 32'h1A00;
			mem[26] = 32'h340;
			mem[27] = 32'h1238;
			mem[28] = 32'h1A8E;
			mem[29] = 32'h3756;
			mem[30] = 32'hCAE;
			mem[31] = 32'h0;
		end
	
	always @(posedge clk) begin  
	// make sure that the opcode is valid	 
    if (valid_opcode >= 2 && valid_opcode <= 15 && valid_opcode != 9 && valid_opcode != 11 && valid_opcode != 14) begin
					out1 <= mem[addr1]; 
					out2 <= mem[addr2];  
					mem[addr3] <= in; 

	end	 
end
	
endmodule 


 //this module to instantiate opcode ,addr1,addr2 and addr3 
module instruction_reg(clk,machineInstruction,addr1,addr2,addr3,opcode); 
	input clk;
	input [31:0]machineInstruction;
	output reg [4:0] addr1,addr2,addr3;
	output reg [5:0] opcode;
	always@(posedge clk) begin		
			opcode <= machineInstruction[5:0];	// opcode is the first 6 bits of the instruction
			addr1 <= machineInstruction[10:6];	// adrr1 is the next 5 bits of the instruction
			addr2 <= machineInstruction[15:11];  // adrr2 is the next 5 bits of the instruction
			addr3 <= machineInstruction[20:16];	 // adrr3 is the next 5 bits of the instruction
		end 
endmodule


// this module to delay the opcode before entering the alu 
module opcode_delay(clk,opcode1,opcode); 
	input clk;
	input [5:0] opcode;
	output reg [5:0] opcode1;
	always@(posedge clk) begin 
			opcode1 <= opcode;
 		end
	
	
endmodule


// module of microprocesses
module mp_top (clk,instruction, result);
	input clk;
	input [31:0] instruction;
	output reg [31:0] result;	
	reg [4:0] addr1,addr2,addr3;
	reg [31:0] regFile_out1,regFile_out2;
	reg[5:0] opcode,opcode1; // opcode1 is the delayed version of opcode that enters alu		
	
	
	instruction_reg instructionReg(.clk(clk),.machineInstruction(instruction),.addr1(addr1),.addr2(addr2),.addr3(addr3),.opcode(opcode));  
	reg_file regFile(.clk(clk),.valid_opcode(opcode),.addr1(addr1),.addr2(addr2),.addr3(addr3),.in(result),.out1(regFile_out1),.out2(regFile_out2));
	opcode_delay opcode_delay1(clk,opcode1,opcode);                                                          
	alu Alu(.opcode(opcode1),.a(regFile_out1),.b(regFile_out2),.result(result));  
	
endmodule  


module mp_top_test;                                                                                                            
  reg clk;                                                                                                                     
  reg [31:0] instruction;                                                                                                      
  wire signed [31:0] result;   
  reg [31:0] instructionsArray [14:0] ; //array of instruction	
  reg signed [31:0] a,b;  
  int i;  //array of instruction index
  reg signed [31:0] expectedResult;
  string opration,isPassed;	 
  int passOrFail = 1;  
  initial begin
	  $display("           instruction               a           b      operation   expected result    result    test"); 	  
	  $display("---------------------------------------------------------------------------------------------------------"); 
	  clk = 0;
	  i = 0; 
	  a = 32'h1066;
	  b = 32'h15DC;	 
	  // Fill array of instruction
	  instructionsArray[0] = 32'b00000000000000110001000001000101; // a + b	  
	  instructionsArray[1] = 32'b00000000000000110001000001001000; // a - b
	  instructionsArray[2] = 32'b00000000000000110001000001001101; // |a|
	  instructionsArray[3] = 32'b00000000000000110001000001000111; // -a
	  instructionsArray[4] = 32'b00000000000000110001000001000011; // max(a,b)
	  instructionsArray[5] = 32'b00000000000000110001000001000110; // min(a,b)
	  instructionsArray[6] = 32'b00000000000000110001000001001010; // avg(a,b)
	  instructionsArray[7] = 32'b00000000000000110001000001000010; // ~a
	  instructionsArray[8] = 32'b00000000000000110001000001000001; //instuction of non valid opcode
	  instructionsArray[9] = 32'b00000000000000110001000001001111; // a | b
	  instructionsArray[10] = 32'b00000000000000110001000001001001; //instuction of non valid opcode
	  instructionsArray[11] = 32'b00000000000000110001000001000100; // a & b	 
	  instructionsArray[12] = 32'b00000000000000110001000001001011; //instuction of non valid opcode
	  instructionsArray[13] = 32'b00000000000000110001000001001100; // a ^ b 
	  instructionsArray[14] = 32'b00000000000000110001000001001110; //instuction of non valid opcode
	  
	  // Try all instructions
	  for(i = 0; i <= 14; i++)begin  
		  #20ns instruction = instructionsArray[i];		  
	  end		
	  #20ns i++;
	  
	  // check if the program passes or not
	    if(passOrFail == 0) $display("The Program Failed");
		  else $display("The Program Passed");
	  end

  mp_top mp(clk,instruction, result);                                                                                                 
                                                                                                                              
   
  always #5ns begin
	  clk = ~clk; 
  end 
  
  


  always@(i) begin	 
	if(i <= 15) begin	
	// find the expected result	
	#15001	 
	 case(instructionsArray[i - 1][5:0])
		 	    6'b000101: begin expectedResult = 32'h00002642;   opration = " a + b   ";   end   
		  		6'b001000: begin expectedResult = 32'hFFFFFA8A;   opration = " a - b   ";   end    
		      	6'b001101: begin expectedResult = 32'h00001066;   opration = "  |a|    ";   end
				6'b000111: begin expectedResult = 32'hFFFFEF9A;   opration = "  -a     ";   end
				6'b000011: begin expectedResult = 32'h000015DC;   opration = "max(a,b) ";   end
				6'b000110: begin expectedResult = 32'h00001066;   opration = "min(a,b) ";   end
				6'b001010: begin expectedResult = 32'h00001321;   opration = "avg(a,b) ";   end
				6'b000010: begin expectedResult = 32'hFFFFEF99;   opration = "  ~a     ";   end   
				6'b001111: begin expectedResult = 32'h000015FE;   opration = "   or    ";   end 
				6'b000100: begin expectedResult = 32'h00001044;   opration = "  and    ";   end 
				6'b001100: begin expectedResult = 32'h000005BA;   opration = "  xor    ";   end
				default : begin  opration = "non valid";   end	
				
	 endcase   
	 // compare the result with the expected result for each instruction
	 if (result == expectedResult && opration != "non valid")
        isPassed = "pass";
     else if (result == expectedResult && opration == "non valid") 
        isPassed = "not valid(the result remain the same)";		 
	 else begin 
		isPassed = "fail";
		passOrFail = 0;	
		end
		 
	  $display("%b  %h   %h    %s      %h      %h   %s",instructionsArray[i - 1],a,b,opration,expectedResult,result,isPassed);
	  isPassed = ""; 
  		end
		  end
	  
                                                                                                                                                                                                                                                     
endmodule	


module alu_test;
  reg [5:0] opcode;
  reg signed [31:0] a, b;
  wire signed [31:0] result;  
  reg [31:0] expectedResult;
  reg [5:0] opcodeArray [13:0];
  int i;
  string operation, isPassed;
  int passOrFail = 1;
  
  // ALU instantiation
  alu Alu(opcode, a, b, result);

  initial begin
    $display("opcode      a           b      operation   expected result   result       test");
    $display("-------------------------------------------------------------------------------------");
    i = 0;
    a = 32'h1066;
    b = 32'h15DC;
    opcodeArray[0] = 6'b000101;	 // a + b
    opcodeArray[1] = 6'b001000;	 // a - b
    opcodeArray[2] = 6'b001101;	 // |a|
    opcodeArray[3] = 6'b000111;	 // -a
    opcodeArray[4] = 6'b000011;	 // max(a,b)
    opcodeArray[5] = 6'b000110;	 // min(a,b)
    opcodeArray[6] = 6'b001010;	 // avg(a,b)
    opcodeArray[7] = 6'b000010;	 // ~a
    opcodeArray[8] = 6'b000001;  // instruction of non-valid opcode
    opcodeArray[9] = 6'b001111;	// a | b
    opcodeArray[10] = 6'b001001; // instruction of non-valid opcode
    opcodeArray[11] = 6'b000100; //	a & b
    opcodeArray[12] = 6'b001011; // instruction of non-valid opcode
    opcodeArray[13] = 6'b001100; // a ^ b

    for (i = 0; i <= 13; i = i + 1) begin
      #10ns opcode = opcodeArray[i];
    end
    #10ns i = i + 1;
    // Check if the program passes or not
    if (passOrFail == 0) $display("The Program Failed");
    else $display("The Program Passed");
  end

  // Compare results
  always @(i) begin
    if (i <= 14) begin
		#1 // delay
      // Find the expected result
      case (opcodeArray[i - 1])
        6'b000101: begin expectedResult = 32'h00002642; operation = " a + b   "; end
        6'b001000: begin expectedResult = 32'hFFFFFA8A; operation = " a - b   "; end
        6'b001101: begin expectedResult = 32'h00001066; operation = "  |a|    "; end
        6'b000111: begin expectedResult = 32'hFFFFEF9A; operation = "  -a     "; end
        6'b000011: begin expectedResult = 32'h000015DC; operation = "max(a,b) "; end
        6'b000110: begin expectedResult = 32'h00001066; operation = "min(a,b) "; end
        6'b001010: begin expectedResult = 32'h00001321; operation = "avg(a,b) "; end
        6'b000010: begin expectedResult = 32'hFFFFEF99; operation = "  ~a     "; end
        6'b001111: begin expectedResult = 32'h000015FE; operation = "   or    "; end
        6'b000100: begin expectedResult = 32'h00001044; operation = "  and    "; end
        6'b001100: begin expectedResult = 32'h000005BA; operation = "  xor    "; end
         default : begin  operation = "non valid";   end
      endcase

      // Compare the result with the expected result for each opcode
       if (result == expectedResult && operation != "non valid")
        isPassed = "pass";
     else if (result == expectedResult && operation == "non valid") 
        isPassed = "not valid(the result remain the same)";		 
	 else begin 
		isPassed = "fail";
		passOrFail = 0;	
		end

      $display("%b   %h    %h   %s     %h      %h      %s", opcodeArray[i - 1], a, b, operation, expectedResult, result, isPassed);
      isPassed = "";
    end
  end
endmodule; 



module reg_file_test;
	reg clk; 
	reg [5:0] validOpcode;
	reg [4:0] addr1,addr2,addr3;   
	reg signed [31:0] in;
	wire signed [31:0] regOut1,regOut2;
	
	reg_file regFile(clk,validOpcode,addr1,addr2,addr3,in,regOut1,regOut2);	 
	
   integer i;

    initial begin
    clk = 0;
    for (i = 0; i < 7; i = i + 1) begin
        #5ns;
        clk = ~clk;
    end
  end
	 
	initial begin 
		$display("opcode       addr1      addr2          Out1             Out2 ");
		$display("---------------------------------------------------------------");	 
		clk = 0;
		validOpcode = 6'b000101;
		addr1 = 8;
		addr2 = 10;
		addr3 = 0; 
		in = 32'h55;  		  
		#10ns
		validOpcode = 6'b001000;
		addr1 = 0;
		addr2 = 9;
		addr3 = 2; 
		in = 32'h42;  
		#10ns
		validOpcode = 6'b000010;
		addr1 = 2;
		addr2 = 4;
		addr3 = 31; 
		in = 32'h33;
		#10ns
		validOpcode = 6'b011111;
		addr1 = 15;
		addr2 = 31;
		addr3 = 0; 
		in = 32'h11;
		end	  
		
	    always@(posedge clk) begin 
			#1ns
		 $display("%b        %h        %h          %h          %h", validOpcode, addr1, addr2, regOut1,regOut2);		
			end
endmodule
	
	
	
	
	
	
	
	
	
	
	
                                                                                                                                                                                                   
                                                                                                                                                                                                 	              