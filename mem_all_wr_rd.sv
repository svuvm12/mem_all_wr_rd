class uvm_mem_single_all_wr_rd_seq extends uvm_reg_sequence #(uvm_sequence #(uvm_reg_item));

   `uvm_object_utils(uvm_mem_single_all_wr_rd_seq)


   // Variable: mem
   //
   // The memory to test; must be assigned prior to starting sequence.

   uvm_mem mem;


   // Function: new
   //
   // Creates a new instance of the class with the given name.

   function new(string name="uvm_mem_walk_seq");
     super.new(name);
   endfunction


   // Task: body
   //
   // Performs the walking-ones algorithm on each map of the memory
   // specifed in <mem>.

   virtual task body();
      uvm_reg_map maps[$];
      int n_bits;

      if (mem == null) begin
         `uvm_error("uvm_mem_walk_seq", "No memory specified to run sequence on");
         return;
      end

      // Memories with some attributes are not to be tested
      if (uvm_resource_db#(bit)::get_by_name({"REG::",mem.get_full_name()},
                                             "NO_REG_TESTS", 0) != null ||
          uvm_resource_db#(bit)::get_by_name({"REG::",mem.get_full_name()},
                                             "NO_MEM_TESTS", 0) != null ||
	  uvm_resource_db#(bit)::get_by_name({"REG::",mem.get_full_name()},
                                             "NO_MEM_WALK_TEST", 0) != null )
         return;

      n_bits = mem.get_n_bits();

      // Memories may be accessible from multiple physical interfaces (maps)
      mem.get_maps(maps);
      
      // Walk the memory via each map
      foreach (maps[j]) begin
         uvm_status_e status;
         uvm_reg_data_t  val, v;
         
         // Only deal with RW memories
         if (mem.get_access(maps[j]) != "RW") continue;

         `uvm_info("uvm_mem_walk_seq", $sformatf("Walking memory %s in map \"%s\"...",
                                    mem.get_full_name(), maps[j].get_full_name()), UVM_LOW);
         
        
         for (int k = 0; k < mem.get_size(); k++) begin

            mem.write(status, k, ~k, UVM_FRONTDOOR, maps[j], this);

            if (status != UVM_IS_OK) begin
               `uvm_error("uvm_mem_walk_seq", $sformatf("Status was %s when writing \"%s[%0d]\" through map \"%s\".",
                                           status.name(), mem.get_full_name(), k, maps[j].get_full_name()));
            end   
         end 
        
         for (int k = 0; k < mem.get_size(); k++) begin

            mem.read(status, k, val, UVM_FRONTDOOR, maps[j], this);    
           
            if (status != UVM_IS_OK) begin
               `uvm_error("uvm_mem_walk_seq", $sformatf("Status was %s when writing \"%s[%0d]\" through map \"%s\".",
                                           status.name(), mem.get_full_name(), k, maps[j].get_full_name()));
            end   
           if (val !== ~k) begin
                     `uvm_error("uvm_mem_walk_seq", $sformatf("\"%s[%0d]\" read back as 'h%h instead of 'h%h.",
                                                              mem.get_full_name(), k, val, ~k));
                     
            end 
         end
      end  
   endtask
endclass:  uvm_mem_single_all_wr_rd_seq 
