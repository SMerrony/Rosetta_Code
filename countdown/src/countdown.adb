pragma Ada_2022;
with Ada.Text_IO;    use Ada.Text_IO;

procedure Countdown is
   type Op_T is ('+', '-', 'x', '/');
   Op_Chars  : constant String := "+-x/";
   N_Digits  : constant Integer := 6;
   Max_Depth : Positive := 5;
   type Number_Arr is array (1 .. N_Digits) of Natural;
   type Expr_T is record
      Num1     : Positive;
      Operator : Op_T;
      Num2     : Positive;
      Res      : Integer;
   end record;
   type Expr_Arr is array (1 .. Max_Depth) of Expr_T;
   Exprs, Solutions   : Expr_Arr;
   Sol_Len, Offby_Len : Positive;
   Near, Offby        : Integer;

   procedure Solve (Chosen : in out Number_Arr; Target : Positive; Depth : Positive) is
      Left_Term, Right_Term : Natural;
      Current_Result        : Integer;
   begin
      for i in 1 .. N_Digits loop
         Left_Term := Chosen (i);
         if Left_Term /= 0 then
            for j in 1 .. N_Digits loop
               Right_Term := Chosen (j);
               if i /= j and then Right_Term /= 0 then
                  for op in Op_T'First .. Op_T'Last loop
                     if (op < '/' or else Left_Term mod Right_Term = 0)
                     and then (op < 'x' or else Right_Term /= 1)
                     and then (Left_Term >= Right_Term)
                     then
                        Current_Result := Left_Term;
                        case op is
                           when '+' => Current_Result := Current_Result + Right_Term;
                           when '-' => Current_Result := Current_Result - Right_Term;
                           when 'x' => Current_Result := Current_Result * Right_Term;
                           when '/' => Current_Result := Current_Result / Right_Term;
                        end case;
                        Chosen (i) := Current_Result;
                        Chosen (j) := 0;
                        Exprs (Depth) := (Left_Term, op, Right_Term, Current_Result);
                        if Current_Result = Target then
                           if Depth < Sol_Len then
                              Sol_Len := Depth;
                              Max_Depth := Depth - 1;
                              Near := 0;
                              Solutions := Exprs;
                           end if;
                        else
                           Offby := abs (Target - Current_Result);
                           if Offby < Near then
                              Near := Offby;
                              Offby_Len := Depth;
                              Solutions := Exprs;
                           end if;
                           if Depth < Max_Depth then
                              Solve (Chosen, Target, Depth + 1);
                           end if;
                        end if;
                        Chosen (i) := Left_Term;
                        Chosen (j) := Right_Term;
                     end if;
                  end loop;
               end if;
            end loop;
         end if;
      end loop;
   end Solve;

   procedure Print_Solution (Expr_Count : Positive) is
      Count : Integer := 1;
   begin
      for Expr of Solutions loop
         Put_Line (Expr.Num1'Image & " " &
                   Op_Chars (Op_T'Pos (Expr.Operator) + 1) &
                   Expr.Num2'Image & " =" & Expr.Res'Image);
         Count := Count + 1;
         exit when Count > Expr_Count;
      end loop;
   end Print_Solution;

   procedure CD (Numbers : Number_Arr; Target : Positive) is
      Chosen    : Number_Arr;
      Depth     : Positive;
   begin
      Sol_Len := N_Digits + 1;
      Chosen := Numbers;
      Depth := 1;
      Max_Depth := 5;
      Near := Target;
      Solve (Chosen, Target, Depth);
      Put_Line ("Chosen: " & Chosen'Image & ", Target:" & Target'Image);
      if Near = 0 then
         Put_Line ("Exact solution...");
         Print_Solution (Sol_Len);
      else
         Put_Line ("Off by:" & Near'Image & "...");
         Print_Solution (Offby_Len);
      end if;
   end CD;

begin
   CD ([75, 50, 25, 100, 8, 2], 737);
   CD ([3, 6, 25, 50, 75, 100], 952);
   CD ([100, 75, 50, 25, 6, 3], 952);
   CD ([50, 100, 4, 2, 2, 4], 203);
   CD ([3, 7, 6, 2, 1, 7], 824);
end Countdown;