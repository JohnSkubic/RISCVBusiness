/*
*   Copyright 2016 Purdue University
*   
*   Licensed under the Apache License, Version 2.0 (the "License");
*   you may not use this file except in compliance with the License.
*   You may obtain a copy of the License at
*   
*       http://www.apache.org/licenses/LICENSE-2.0
*   
*   Unless required by applicable law or agreed to in writing, software
*   distributed under the License is distributed on an "AS IS" BASIS,
*   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*   See the License for the specific language governing permissions and
*   limitations under the License.
*
*
*   Filename:     fetch_stage.sv
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 06/19/2016
*   Description:  Fetch stage for the two stage pipeline
*/

`include "fetch_execute_if.vh"
`include "hazard_unit_if.vh"
`include "predictor_pipeline_if.vh"
`include "ram_if.vh"

module fetch_stage (
  input logic CLK, nRST,
  fetch_execute_if.fetch fetch_ex_if,
  hazard_unit_if.fetch hazard_if,
  predictor_pipeline_if.access predict_if,
  ram_if.cpu iram_if
);
  import rv32i_types_pkg::*;

  parameter RESET_PC = 32'h200;

  word_t  pc, pc4, npc, instr;

  //PC logic

  always @ (posedge CLK, negedge nRST) begin
    if(~nRST) begin
      pc <= RESET_PC;
    end else if (hazard_if.pc_en) begin
      pc <= npc;
    end
  end

  assign pc4 = pc + 4;
  assign predict_if.current_pc = pc;
  assign npc = hazard_if.insert_priv_pc ? hazard_if.priv_pc : (hazard_if.npc_sel ? fetch_ex_if.brj_addr : 
                (predict_if.predict_taken ? predict_if.target_addr : pc4));

  //Instruction Access logic
  assign hazard_if.iren        = 1'b1;
  assign hazard_if.i_ram_busy  = iram_if.busy;
  assign iram_if.addr         = pc;
  assign iram_if.ren          = 1'b1;
  assign iram_if.wen          = 1'b0;
  assign iram_if.byte_en      = 4'h0;
  assign iram_if.wdata        = '0;
  
  endian_swapper ltb_endian (
    .word_in(iram_if.rdata),
    .word_out(instr)
  );

  //Fetch Execute Pipeline Signals
  always_ff @ (posedge CLK, negedge nRST) begin
    if (!nRST)
      fetch_ex_if.fetch_ex_reg <= '0;
    else if (hazard_if.if_ex_flush)
      fetch_ex_if.fetch_ex_reg <= '0;
    else if (!hazard_if.if_ex_stall) begin
      fetch_ex_if.fetch_ex_reg.token       <= 1'b1;
      fetch_ex_if.fetch_ex_reg.pc          <= pc;
      fetch_ex_if.fetch_ex_reg.pc4         <= pc4;
      fetch_ex_if.fetch_ex_reg.instr       <= instr;
      fetch_ex_if.fetch_ex_reg.prediction  <= predict_if.predict_taken;
    end
  end

  //Send exceptions to Hazard Unit
  logic mal_addr;
  assign mal_addr = (iram_if.addr[1:0] != 2'b00);
  assign hazard_if.fault_insn = 1'b0;
  assign hazard_if.mal_insn = iram_if.ren & mal_addr;

  assign hazard_if.badaddr_f = iram_if.addr;
  assign hazard_if.epc_f = pc; 

endmodule

