with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Text_IO;

procedure Eulers_Constant is
   package LF_Funcs is new Ada.Numerics.Generic_Elementary_Functions (Long_Float);

   function Euler_Simple (Iterations : Integer) return Long_Float is
      Gamma : Long_Float := 0.0;
   begin
      for N in 1 .. Iterations loop
         Gamma := Gamma + Long_Float (1.0) / Long_Float (N);
      end loop;
      Gamma := Gamma - LF_Funcs.Log (Long_Float (Iterations)) + 1.0 / (2.0 * Long_Float (Iterations));
      return Gamma / 10.0;
   end Euler_Simple;

   function Euler_Macys (Iterations : Integer) return Long_Float is
      Gamma : Long_Float := 1.0;
      N     : Long_Float := 1.0;
   begin
      while N <= Long_Float (Iterations) loop
         Gamma := Gamma + (1.0 / N) - (1.0 / (N + 1.0)) - (1.0 / ((N * N) + (N - 1.0)));
         N := N + 1.0;
      end loop;
      return Gamma;
   end Euler_Macys;

   Iters : Integer;
begin
   Ada.Text_IO.Put_Line ("Iterations    Simple     Macys");
   Iters := 1;
   Ada.Text_IO.Put_Line (Iters'Image & " " & Euler_Simple (Iters)'Image & " " & Euler_Macys (Iters)'Image);
   Iters := 10;
   Ada.Text_IO.Put_Line (Iters'Image & " " & Euler_Simple (Iters)'Image & " " & Euler_Macys (Iters)'Image);
   Iters := 100;
   Ada.Text_IO.Put_Line (Iters'Image & " " & Euler_Simple (Iters)'Image & " " & Euler_Macys (Iters)'Image);
   Iters := 1000;
   Ada.Text_IO.Put_Line (Iters'Image & " " & Euler_Simple (Iters)'Image & " " & Euler_Macys (Iters)'Image);
end Eulers_Constant;
