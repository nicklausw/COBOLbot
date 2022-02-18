       identification division.
       program-id. cobolstuff.
       environment division.
       
       data division.
       working-storage section.
      *    believe it or not, finding variable names in a language
      *    based on English is freaking impossible.
           01 math_string pic x(2000).
           01 i pic 9(9) value 0.

      *    These are our possible tokens.
           01 tok_end pic 9 value 0.
           01 tok_num pic 9 value 1.
           01 tok_add pic 9 value 2.
           01 tok_sub pic 9 value 3.
           01 tok_mul pic 9 value 4.
           01 tok_div pic 9 value 5.

           01 building_number pic x(1) value 'F'.
           01 building_offset pic 9(9) value 0.
           01 building_space pic x(100) value zeroes.

           01 current_token pic 9(9) value 1.

           01 token_list.
               05 token_type pic 9 value 0 occurs 2000 times.
               05 num pic s9(9)v9(9) value 0 occurs 2000 times.

           01 outnumber pic s9(9)v9(9) value 0.
       
       linkage section.
           01 c_communication pic x(2000).
       
       procedure division using by reference c_communication.
      *    copy input to where we can work with it piece-by-piece.
           move c_communication to math_string

           move 0 to outnumber
           string 'F' into building_number
           move 0 to building_space
           move 1 to current_token

           perform varying i from 1 by 1 until i = 2000
               move 0 to token_type(i)
               move 0 to num(1)
           end-perform

      *    end program if ending marker (semicolon) not found.
           perform varying i from 1 by 1 until i = 2000
               if math_string(i:1) = ';' then
                   exit perform
               end-if
           end-perform
           if i = 2000 then
               string  "No semicolon found." into c_communication
               exit section.

      *    first: split into tokens.
           perform varying i from 1 by 1 until i = 2000
      *        if we're still getting a number's contents...
               if building_number = 'F' then
                   if (math_string(i:1) is numeric) or
                      (math_string(i:1) = '.') then
                       string 'T' into building_number
                       move tok_num to token_type(current_token)
                       move 1 to building_offset
                       move math_string(i:1) to
                           building_space(building_offset:1)
                       add 1 to building_offset giving building_offset
                       exit perform cycle
                   else
                       if math_string(i:1) = '*' then
                           move tok_mul to token_type(current_token)
                           add 1 to current_token giving current_token
                           exit perform cycle
                       else if math_string(i:1) = '+' then
                           move tok_add to token_type(current_token)
                           add 1 to current_token giving current_token
                           exit perform cycle
                       else if math_string(i:1) = '-' then
                           move tok_sub to token_type(current_token)
                           add 1 to current_token giving current_token
                           exit perform cycle
                       else if math_string(i:1) = '/' then
                           move tok_div to token_type(current_token)
                           add 1 to current_token giving current_token
                           exit perform cycle
                       else if math_string(i:1) = ';' then
                           move tok_end to token_type(current_token)
                           exit perform
                       end-if
                       add 1 to current_token giving current_token
                   end-if
               else
                   if (math_string(i:1) is numeric) or
                      (math_string(i:1) = '.') then
                       move math_string(i:1) to
                           building_space(building_offset:1)
                       add 1 to building_offset giving building_offset
                   else
                       string 'F' into building_number
                       subtract 1 from building_offset
                           giving building_offset
                       unstring building_space(1:building_offset)
                           into num(current_token)
                       add 1 to current_token giving current_token
                        if math_string(i:1) = '*' then
                           move tok_mul to token_type(current_token)
                           add 1 to current_token giving current_token
                           exit perform cycle
                       else if math_string(i:1) = '+' then
                           move tok_add to token_type(current_token)
                           add 1 to current_token giving current_token
                           exit perform cycle
                       else if math_string(i:1) = '-' then
                           move tok_sub to token_type(current_token)
                           add 1 to current_token giving current_token
                           exit perform cycle
                       else if math_string(i:1) = '/' then
                           move tok_div to token_type(current_token)
                           add 1 to current_token giving current_token
                           exit perform cycle
                       else if math_string(i:1) = ';' then
                           move tok_end to token_type(current_token)
                           exit perform
                       end-if
                       add 1 to current_token giving current_token
                   end-if
               end-if
           end-perform

           add 1 to current_token giving current_token

           if current_token < 3 then
               string "Nothing to do." into c_communication
               exit section
           end-if
           if token_type(1) <> tok_num then
               string "First token must be a number."
                   into c_communication
               exit section
           end-if

           move num(1) to outnumber

           perform varying i from 2 by 1 until i = current_token
               if token_type(i) = tok_add then
                   add 1 to i giving i
                   add num(i) to outnumber giving outnumber
                   exit perform cycle
               else if token_type(i) = tok_sub then
                   add 1 to i giving i
                   subtract num(i) from outnumber giving outnumber
                   exit perform cycle
               else if token_type(i) = tok_mul then
                   add 1 to i giving i
                   multiply num(i) by outnumber giving outnumber
                   exit perform cycle
               else if token_type(i) = tok_div then
                   add 1 to i giving i
                   divide outnumber by num(i) giving outnumber
                   exit perform cycle
               end-if
           end-perform

           string outnumber into c_communication
               
           exit program.
